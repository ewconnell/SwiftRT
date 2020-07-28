//******************************************************************************
// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import Foundation

//==============================================================================
/// DiscreteStorage
public final class DiscreteStorage: StorageBuffer {
    // StorageBuffer protocol properties
    public let alignment: Int
    public let byteCount: Int
    public let id: Int
    public var isReadOnly: Bool
    public var isReference: Bool
    
    public var name: String {
        didSet { replicas.forEach { $0?.name = name } }
    }

    //------------------------------------
    // private properties
    /// replicated device memory buffers
    public var replicas: [DeviceMemory?]

    /// the last queue used to access storage
    public var lastQueue: DeviceQueue?

    /// whenever a buffer write pointer is taken, the associated DeviceMemory
    /// becomes the master copy for replication. Synchronization across threads
    /// is still required for taking multiple write pointers, however
    /// this does automatically synchronize data migrations.
    /// The value will be `nil` if no access has been taken yet
    public var master: DeviceMemory?

    /// this is incremented each time a write pointer is taken
    /// all replicated buffers will stay in sync with this version
    public var masterVersion: Int

    //------------------------------------
    // testing properties
    /// testing: `true` if the last access caused the contents of the
    /// buffer to be copied
    @inlinable public var testLastAccessCopiedDeviceMemory: Bool {
        _lastAccessCopiedMemory
    }
    public var _lastAccessCopiedMemory: Bool
    

    //--------------------------------------------------------------------------
    // init(type:count:order:name:
    @inlinable public init<Element>(
        storedType: Element.Type,
        count: Int,
        name: String
    ) {
        self.name = name
        alignment = MemoryLayout<Element>.alignment
        byteCount = MemoryLayout<Element>.size * count
        id = Context.nextBufferId
        isReadOnly = false
        isReference = false
        masterVersion = -1
        _lastAccessCopiedMemory = false

        // setup replica managment
        let numDevices = Context.local.platform.devices.count
        replicas = [DeviceMemory?](repeating: nil, count: numDevices)
    }
    
    //--------------------------------------------------------------------------
    /// `init(storedElement:name:
    public convenience init<Element>(storedElement: Element, name: String) {
        // TODO: change this to cache single scalars
        self.init(storedType: Element.self, count: 1, name: name)
        let buffer = readWrite(type: Element.self, at: 0, count: 1,
                               using: Context.appThreadQueue)
        buffer[0] = storedElement
    }
    
    //--------------------------------------------------------------------------
    // init(type:other:using:
    @inlinable public init<Element>(
        type: Element.Type,
        copying other: DiscreteStorage,
        using queue: DeviceQueue
    ) {
        id = Context.nextBufferId
        alignment = other.alignment
        byteCount = other.byteCount
        isReadOnly = other.isReadOnly
        isReference = other.isReference
        name = other.name
        masterVersion = -1
        _lastAccessCopiedMemory = false

        // setup replica managment
        replicas = [DeviceMemory?](repeating: nil, count: other.replicas.count)

        // copy other master to self using the current queue
        let queue = Context.currentQueue
        let otherMemory = other.getDeviceMemory(Element.self, queue)
        let selfMemory = getDeviceMemory(Element.self, queue)
        diagnostic("\(copyString) \(other.name)(\(other.id)) --> " +
                    "\(name)(\(id)) \(Element.self)" +
                    "[\(byteCount / MemoryLayout<Element>.size)]",
                    categories: .dataCopy)
        queue.copy(from: otherMemory, to: selfMemory)
    }
    
    //--------------------------------------------------------------------------
    // init(buffer:order:
    @inlinable public convenience init<Element>(
        referenceTo buffer: UnsafeBufferPointer<Element>,
        name: String
    ) {
        self.init(storedType: Element.self, count: buffer.count, name: name)
        isReadOnly = true
        isReference = true
        let p = UnsafeMutableBufferPointer(mutating: buffer)
        let raw = UnsafeMutableRawBufferPointer(p)
        replicas[0] = CpuDeviceMemory(0, raw, .unified, isReference: true)
        diagnostic("\(referenceString) \(name)(\(id)) " +
                    "\(Element.self)[\(buffer.count)]", categories: .dataAlloc)
    }
    
    //--------------------------------------------------------------------------
    // init(type:buffer:order:
    @inlinable public convenience init<Element>(
        referenceTo buffer: UnsafeMutableBufferPointer<Element>,
        name: String
    ) {
        self.init(storedType: Element.self, count: buffer.count, name: name)
        isReference = true
        let raw = UnsafeMutableRawBufferPointer(buffer)
        replicas[0] = CpuDeviceMemory(0, raw, .unified, isReference: true)
        diagnostic("\(referenceString) \(name)(\(id)) " +
                    "\(Element.self)[\(buffer.count)]", categories: .dataAlloc)
    }

    //--------------------------------------------------------------------------
    /// waitForCompletion
    /// blocks the caller until pending write operations have completed
    @inlinable public func waitForCompletion() {
        lastQueue?.waitForCompletion()
    }

    //--------------------------------------------------------------------------
    //
    @inlinable public init<S, Stream>(
        block shape: S,
        bufferedBlocks: Int,
        stream: Stream
    ) where S : TensorShape, Stream : BufferStream {
        fatalError()
    }
    
    //--------------------------------------------------------------------------
    // ensure that all pending work is complete before releasing memory
    @inlinable deinit {
        waitForCompletion()
    }
    
    //--------------------------------------------------------------------------
    //
    @inlinable public func read<Element>(
        type: Element.Type,
        at index: Int,
        count: Int,
        using queue: DeviceQueue
    ) -> UnsafeBufferPointer<Element> {
        let buffer = migrate(type, willMutate: false, using: queue)
        assert(index + count <= buffer.count, "range is out of bounds")
        let start = buffer.baseAddress!.advanced(by: index)
        return UnsafeBufferPointer(start: start, count: count)
    }
    
    //--------------------------------------------------------------------------
    //
    @inlinable public func readWrite<Element>(
        type: Element.Type,
        at index: Int,
        count: Int,
        using queue: DeviceQueue
    ) -> UnsafeMutableBufferPointer<Element> {
        let buffer = migrate(type, willMutate: true, using: queue)
        assert(index + count <= buffer.count, "range is out of bounds")
        let start = buffer.baseAddress!.advanced(by: index)
        return UnsafeMutableBufferPointer(start: start, count: count)
    }

    //--------------------------------------------------------------------------
    // getDeviceMemory
    // Manages an array of replicated device memory indexed by the deviceId
    // associated with `queue`. It will lazily create device memory if needed
    @inlinable public func getDeviceMemory<Element>(
        _ type: Element.Type,
        _ queue: DeviceQueue
    ) -> DeviceMemory {
        if let memory = replicas[queue.deviceIndex] {
            return memory
        } else {
            // allocate the buffer for the target device
            // and save in the replica list
            let memory = queue.allocate(byteCount)
            replicas[queue.deviceIndex] = memory
            
            if willLog(level: .diagnostic) {
                let count = byteCount / MemoryLayout<Element>.size
                let msg = "(\(id)) on \(queue.deviceName) " +
                          " \(Element.self)[\(count)]"
                diagnostic("\(allocString) \(name)\(msg)", categories: .dataAlloc)
                memory.name = name
                memory.releaseMessage = msg
            }
            return memory
        }
    }

    //--------------------------------------------------------------------------
    /// migrate(type:readOnly:queue:
    /// returns a buffer on the device associated with `queue`, lazily
    /// allocating it if it does not exist. The buffer contents will match
    /// the contents of the master version (most recently mutated).
    ///
    /// - Parameters:
    ///  - type: the `Element` type
    ///  - willMutate: `true` if the returned buffer will be mutated
    ///  - queue: the queue that the returned buffer will be used
    ///
    /// - Returns: a buffer pointer to the data
    @inlinable public func migrate<Element>(
        _ type: Element.Type,
        willMutate: Bool,
        using queue: DeviceQueue
    ) -> UnsafeMutableBufferPointer<Element> {
        assert(willMutate || master != nil,
               "attempting to read uninitialized memory")

        // Get a buffer for this tensor on the device associated
        // with `queue`. This is a synchronous operation.
        let replica = getDeviceMemory(type, queue)
        

        // if let lastQueue = lastQueue, queue.id != lastQueue.id &&
        //    lastQueue.mode == .async && queue.mode == .async
        // {
        //     let event = lastQueue.createEvent()
        //     diagnostic("\(syncString) \(queue.name) synchronizing with" +
        //                 " \(lastQueue.name) to " +
        //                 "\(willMutate ? "write" : "read") \(name)(\(id))",
        //                categories: .queueSync)
        //     queue.wait(for: lastQueue.record(event: event))
        // }
        
        // if master.type == .unified {
        //     if dst.type == .unified {
        //         // host --> host
        //         cpu_copy(from: src, to: dst)
        //     } else {
        //         // host --> device
        //     }
        // } else {
        //     if dst.type == .unified {
        //         // device --> host
        //     } else {
        //         // device --> device
        //     }
        // }


        // copy contents from the master to the replica
        // if the versions don't match
        if let master = master, replica.version != master.version {
            // we shouldn't get here if both buffers are in unified memory
            assert(master.type == .discrete || replica.type == .discrete)
            _lastAccessCopiedMemory = true


            queue.copyAsync(from: master, to: replica)
            diagnostic(
                "\(copyString) \(name)(\(id)) dev:\(master.deviceIndex)" +
                "\(setText(" --> ", color: .blue))" +
                "\(queue.deviceName)_q\(queue.id)  " +
                "\(Element.self)[\(replica.count(of: Element.self))]",
                categories: .dataCopy)
        }
        
        // increment version if mutating
        if willMutate {
            masterVersion += 1
            master = replica
        }
        
        // the replica version either matches the master by copying
        // or is the new master
        replica.version = masterVersion

        // store a reference to the accessing queue for safe shutdown
        lastQueue = queue

        // bind to the element type
        return replica.buffer.bindMemory(to: Element.self)
    }
}

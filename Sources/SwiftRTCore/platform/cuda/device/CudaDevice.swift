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
@_implementationOnly
import SwiftRTCuda

//==============================================================================
/// CudaDevice
public final class CudaDevice: ComputeDevice {
    // properties
    public let index: Int
    public let memoryType: MemoryType
    public let name: String
    public var queues: [CudaQueue]

    @inlinable public init(index: Int) {
        let isCpu = index == 0
        self.index = index
        self.name = "dev:\(index)"
        self.memoryType = isCpu ? .unified : .discrete
        queues = []

        //----------------------------
        // report device stats
        let description = isCpu ? getCpuProperties() : getCudaDeviceProperties()
        diagnostic(.device, "\(name) \(description)", categories: .device)

        //----------------------------
        // create queues
        if isCpu {
            // cpu device case
            for i in 0..<Platform.cpuQueueCount {
                queues.append(CudaQueue(deviceIndex: index,
                                        name: "\(name)_q\(i)",
                                        queueMode: .async,
                                        useGpu: false))
            }
        } else {
            // gpu device case
            for i in 0..<Platform.acceleratorQueueCount {
                queues.append(CudaQueue(deviceIndex: index,
                                        name: "\(name)_q\(i)",
                                        queueMode: .async,
                                        useGpu: true))
            }
        }
    }

    //--------------------------------------------------------------------------
    // select
    @inlinable public func select() {
        // device 0 is the cpu, so subtract 1 to get the gpu hardware index
        cudaCheck(cudaSetDevice(Int32(index - 1)))
    }

    //--------------------------------------------------------------------------
    // note: physicalMemory is being under reported on Ubuntu by ~750MB, so
    // we add one
    @inlinable func getCpuProperties() -> String {
        let info = ProcessInfo.processInfo
        let oneGB = UInt64(1.GB)
        return "[type: cpu, cores: \(info.activeProcessorCount), memory: " +
            "\(info.physicalMemory / oneGB + 1) GB, addressing: \(memoryType)]"
    }

    //--------------------------------------------------------------------------
    @inlinable func getCudaDeviceProperties() -> String {
        // get device properties
        let oneGB = Int(1.GB)
        var props = cudaDeviceProp()
        cudaCheck(cudaGetDeviceProperties(&props, 0))
        let nameCapacity = MemoryLayout.size(ofValue: props.name)
        let deviceName = withUnsafePointer(to: &props.name) {
            $0.withMemoryRebound(to: UInt8.self, capacity: nameCapacity) {
                String(cString: $0)
            }
        }
        return "[type: \(deviceName), multiprocessors: \(props.multiProcessorCount), " +
            "memory: \(props.totalGlobalMem / oneGB) GB, " +
            "addressing: \(memoryType)]"

    }
}


//==============================================================================
/// CudaDeviceMemory
public final class CudaDeviceMemory: DeviceMemory {
    /// base address and size of buffer
    public let buffer: UnsafeMutableRawBufferPointer
    /// index of device where memory is located
    public let deviceIndex: Int
    /// diagnostic name
    public var name: String?
    /// diagnostic message
    public var releaseMessage: String?
    /// specifies the device memory type for data transfer
    public let type: MemoryType
    /// version
    public var version: Int
    /// `true` if the buffer is a reference
    public let isReference: Bool

    /// mutable raw pointer to memory buffer to simplify driver calls
    @inlinable public var mutablePointer: UnsafeMutableRawPointer {
        UnsafeMutableRawPointer(buffer.baseAddress!)
    }

    /// mutable raw pointer to memory buffer to simplify driver calls
    @inlinable public var pointer: UnsafeRawPointer {
        UnsafeRawPointer(buffer.baseAddress!)
    }

    //--------------------------------------------------------------------------
    // init
    @inlinable public init(_ deviceIndex: Int, _ byteCount: Int) {
        self.deviceIndex = deviceIndex

        // select the device
        cudaCheck(cudaSetDevice(Int32(deviceIndex - 1)))

        // pad end of memory buffer so that it is rounded up to the
        // largest vector element size. This provides safe padding to
        // avoid vector instructions from accessing out of bounds
        let paddedByteCount = roundUp(byteCount, 
                                      multiple: MemoryLayout<double4>.size) 

        // TODO: for now we will fail if memory is exhausted
        // later catch and do shuffling
		var devicePointer: UnsafeMutableRawPointer?
	    cudaCheck(cudaMalloc(&devicePointer, paddedByteCount))

        self.buffer = UnsafeMutableRawBufferPointer(start: devicePointer!, 
                                                    count: byteCount)
        self.type = .discrete
        self.isReference = false
        self.version = -1
        self.releaseMessage = nil
    }
    
    @inlinable deinit {
        // select the device
        cudaCheck(cudaSetDevice(Int32(deviceIndex - 1)))
		cudaCheck(cudaFree(buffer.baseAddress!))

        #if DEBUG
        if let name = name, let msg = releaseMessage {
            diagnostic(.release, "\(name)\(msg)", categories: .dataAlloc)
        }
        #endif
    }
}

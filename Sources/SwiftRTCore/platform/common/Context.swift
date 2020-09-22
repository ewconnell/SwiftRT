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
// Platform types
#if canImport(SwiftRTCuda)
public typealias Platform = CudaPlatform
#else
public typealias Platform = CpuPlatform
#endif

//==============================================================================
/// Context
/// Manages the scope for the current devices, log, and error handlers
public final class Context: Logging {
    /// TODO: evaluate the performance if Context is thread local
    public static let local: Context = Context()
    
    /// specifies whether operators in the current scope are
    /// evaluated for inferring or training
    public var evaluationModeStack: [EvaluationMode]
    /// the time that the platform was first accessed
    public static let startTime = Date()
    /// the log output object
    public static var logWriter: Log = Log()

    //-------------------------------------
    /// a storage buffer with a single zero value which is shared
    /// every time Element.zero is obtained by AD.
    // used to minimize AD overhead. AD needs to fix this problem.
    public static var zeroStorage: Platform.Storage = {
        Platform.Storage(storedElement: Int64(0), name: "Zero")
    }()

    //-------------------------------------
    /// counter for unique buffer ids
    public static var objectId = AtomicCounter()
    /// a platform instance unique id for queue events
    public static var queueId = AtomicCounter()
    /// a platform instance unique id for queue events
    public static var eventId = AtomicCounter()
    /// the number of async cpu queues to create
    public static var cpuQueueCount: Int = Platform.defaultCpuQueueCount
    /// the number of async cpu queues to create
    public static var acceleratorQueueCount: Int =
        Platform.defaultAcceleratorQueueCount

    /// a static instance of the compute platform
    /// The platform type is specified in Types.swift and selected
    /// via build settings
    // maybe make this thread local
    public let platform: Platform

    //--------------------------------------------------------------------------
    @inlinable public init() {
        platform = Platform()
        evaluationModeStack = [.inferring]
    }
    
    //--------------------------------------------------------------------------
    @inlinable public static var discreteMemoryDeviceId: Int {
        local.platform.discreteMemoryDeviceId
    }
    
    //--------------------------------------------------------------------------
    /// the ComputePlatform log writing object
    @inlinable public static var log: Log {
        get { logWriter }
        set { logWriter = newValue }
    }

    //--------------------------------------------------------------------------
    /// the currently scoped device that platform functions will use
    /// - Returns: the current device queue
    @inlinable public static var currentDevice: Platform.Device {
        Context.local.platform.currentDevice
    }

    /// - Returns: the current device queue
    @inlinable public static var devices: [Platform.Device] {
        Context.local.platform.devices
    }

    /// the currently scoped queue that platform functions will use
    /// - Returns: the current device queue
    @inlinable public static var currentQueue: Platform.Device.Queue {
        Context.local.platform.currentQueue
    }

    /// the application thread data interchange queue
    @inlinable public static var appThreadQueue: Platform.Device.Queue {
        Context.local.platform.appThreadQueue
    }

    //--------------------------------------------------------------------------
    /// a convenience property. `true` if the context is inferring
    @inlinable
    public static var isInferring: Bool {
        Context.local.evaluationModeStack.last! == .inferring
    }

    /// a convenience property. `true` if the context is training
    @inlinable
    public static var isTraining: Bool {
        Context.local.evaluationModeStack.last! == .training
    }

    @inlinable
    public static func whileInferring<R>(_ body: () throws -> R) rethrows -> R {
        Context.local.evaluationModeStack.append(.inferring)
        defer { _ = Context.local.evaluationModeStack.popLast() }
        return try body()
    }

    @inlinable
    public static func whileTraining<R>(_ body: () throws -> R) rethrows -> R {
        Context.local.evaluationModeStack.append(.training)
        defer { _ = Context.local.evaluationModeStack.popLast() }
        return try body()
    }

    //--------------------------------------------------------------------------
    /// randomSeed
    /// - Note: Whenever obtained, the random seed is also updated so that
    /// future stateless random TensorFlow op executions will result
    /// in non-deterministic results.
    @inlinable public static var randomSeed: RandomSeed {
        get {
            let seed = _randomSeed
            _randomSeed = (seed.0, seed.1 + 1)
            return seed
        }
        set { _randomSeed = newValue }
    }

    public static var _randomSeed: RandomSeed = generateRandomSeed()

    @inlinable
    static func createRandomNumberGenerator(using seed: RandomSeed? = nil) ->
        AnyRandomNumberGenerator
    {
        let randomSeed = seed ?? Context.randomSeed
        let generatorSeed = UInt64(msb: UInt32(bitPattern: randomSeed.op),
                                   lsb: UInt32(bitPattern: randomSeed.graph))
        return AnyRandomNumberGenerator(
            PhiloxRandomNumberGenerator(uint64Seed: generatorSeed))
    }
}


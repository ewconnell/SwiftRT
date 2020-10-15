//******************************************************************************
// Copyright 2019 Google LLC
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
/// CudaEvent
/// An event that is recorded on a device queue, which will block
/// the caller until signaled when it's position in the queue has been reached
public class CudaEvent: QueueEvent, Logging {
    public let id = Platform.eventId.next
    // used to synchronize with a cpu async queue
    @usableFromInline let cpuEvent: DispatchSemaphore
    // used to synchronize with a cuda stream
    @usableFromInline let handle: cudaEvent_t

    //--------------------------------------------------------------------------
    // initializer
    @inlinable public init(
        recordedOn queue: CudaQueue,
        options: QueueEventOptions = []
    ) {
        // init as blocking only for the async cpu case
        // for sync cpu and cuda stream, init as signaled so it falls through
        let value = queue.deviceIndex == 0 && queue.mode == .async ? 0 : 1
        cpuEvent = DispatchSemaphore(value: value)

        // the default is a non host blocking, non timing, non inter process event
        var flags: Int32 = cudaEventDisableTiming
        if !options.contains(.timing)      { flags &= ~cudaEventDisableTiming }
        if options.contains(.interprocess) { flags |= cudaEventInterprocess |
                                                    cudaEventDisableTiming }
        // if options.contains(.hostSync)     { flags |= cudaEventBlockingSync }

        var temp: cudaEvent_t?
        cudaCheck(cudaEventCreateWithFlags(&temp, UInt32(flags)))
        handle = temp!
    }

    // event must be signaled before going out of scope to ensure
    @inlinable deinit {
        _ = cudaEventDestroy(handle)
    }

    //--------------------------------------------------------------------------
    // this is only called by the cpu async queue implementation 
    @inlinable public func signal() {
        cpuEvent.signal()
        cudaEventRecord(handle, unsafeBitCast(0, to: cudaStream_t.self))
    }

    @inlinable public func wait() {
        // wait for the first occurence of the event
        cpuEvent.wait()
        // signal to allow all waiters to pass through
        cpuEvent.signal()
        cudaEventSynchronize(handle)
    }
}

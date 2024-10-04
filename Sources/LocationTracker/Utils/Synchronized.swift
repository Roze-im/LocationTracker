//
//  Synchronized.swift
//  Roze
//
//  Created by Benjamin Garrigues on 28/10/2020.
//  Copyright © 2020 Roze. All rights reserved.
//

import Foundation


//Synchronize access to a resource using a DispatchQueue
public struct Synchronized<T> {
    private var obj: T
    private var queue: DispatchQueue
    //warning : don't use concurrent queue. only use serial queues.
    public init(_ obj: T,
                accessQueueLabel: String = "synchronized.\(T.self).\(UUID().uuidString)",
                accessQueueQos: DispatchQoS = .userInitiated,
                targetQueue: DispatchQueue? = nil // targetQueue set to global queue prevents creating too many threads.
    ) {
        self.obj = obj
        self.queue = DispatchQueue(label: accessQueueLabel,
                                   qos: accessQueueQos,
                                   target: targetQueue)
    }

    public init( _ obj: T,
          accessQueue: DispatchQueue) {
        self.obj = obj
        self.queue = accessQueue
    }

    public mutating func callAsFunction(_ operation: (inout T) -> Void) {
        // Special case when queue is main thread and we're already on the main thread.
        // It's the only case we can detect, as there is no way to detect the current queue
        // (dispatch_get_current_queue is for debugging purpose only, and deprecated)
//        print("queue: \(queue.label). queue is main : \(queue == DispatchQueue.main). thread is main : \(Thread.isMainThread)")
        if queue == DispatchQueue.main && Thread.isMainThread {
            operation(&obj)
        } else {
//            print("… not same queue. call .sync")
//            print("… entering \(queue.label).sync")
            queue.sync {
                operation(&obj)
            }
//            print("… exiting \(queue.label).sync")
        }
    }

    public func getValueSync() -> T {
        // Same as above.
        if queue == DispatchQueue.main && Thread.isMainThread {
            return obj
        }
        return queue.sync {
            return obj
        }
    }

    public mutating func setValueSync(_ val: T) {
        self { $0 = val }
    }
}

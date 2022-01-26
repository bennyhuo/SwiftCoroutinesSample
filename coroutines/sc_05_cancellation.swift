//
// Created by benny on 2022/1/21.
//

import Foundation

func sc05_01() async {
    let task = Task {
        log("task start")
        await Task.sleepMs(10000)
        log("task finish, isCancelled: \(Task.isCancelled)")
    }

    await Task.sleepMs(500)
    task.cancel()
    log(await task.result)
}

func sc05_02() async {
    let task = Task {
        if !Task.isCancelled {
            log("task start")
            await Task.sleepMs(10000)
            if !Task.isCancelled {
                log("task finish, isCancelled: \(Task.isCancelled)")
            }
        }
    }

    await Task.sleepMs(500)
    task.cancel()
    log(await task.result)
}

func sc05_03() async {
    let task = Task {
        log("task start")
        try await Task.sleepMsCancellable(10000)
        log("task finish, isCancelled: \(Task.isCancelled)")
    }

    await Task.sleepMs(500)
    task.cancel()
    log(await task.result)
}

func doHardWork(_ i: Int) {

}

func sc05_04() async {
    let task = Task {
        log("task start")
        for i in 0...10000 {
//            if Task.isCancelled {
//                throw CancellationError()
//            }
            try Task.checkCancellation()
            doHardWork(i)
        }
        log("task finish, isCancelled: \(Task.isCancelled)")
    }

    await Task.sleepMs(500)
    task.cancel()
    log(await task.result)
}

class ContinuationWorkItem<T, E> where E: Error {

    var continuation: CheckedContinuation<T, E>?
    let block: (ContinuationWorkItem) -> T

    lazy var dispatchItem: DispatchWorkItem = DispatchWorkItem {
        self.continuation?.resume(returning: self.block(self))
    }

    var isCancelled: Bool {
        get {
            self.dispatchItem.isCancelled
        }
    }

    init(block: @escaping (ContinuationWorkItem<T, E>) -> T) {
        self.block = block
    }

    func installContinuation(continuation: CheckedContinuation<T, E>) {
        self.continuation = continuation
    }

    func cancel() {
        dispatchItem.cancel()
    }

}

func sc05_05() async {
    let task = Task { () -> Int in
        let asyncRequest = ContinuationWorkItem<Int, Never> { context in
            log("async start")
            var i = 0
            while i < 10 && !context.isCancelled {
                Thread.sleep(forTimeInterval: 0.1)
                i += 1
                log("i = \(i)")
            }
            if context.isCancelled {
                log("async cancelled, \(i)")
                return 0
            } else {
                log("async finish")
                return 1
            }
        }

        return await withTaskCancellationHandler {
            await withCheckedContinuation { (continuation: CheckedContinuation<Int, Never>) in
                asyncRequest.installContinuation(continuation: continuation)
                DispatchQueue.global().async(execute: asyncRequest.dispatchItem)
            }
        } onCancel: {
            asyncRequest.cancel()
        }
    }

    await Task.sleepMs(500)
    task.cancel()
    log(await task.result)
}

func sc05_0a() async {
    let max = 10
    let tasks = 10

    await withTaskGroup(of: (Int, Int).self) { group -> Void in
        for i in 0..<tasks {
            group.addTask {
                var count = 0
                while !Task.isCancelled && count < max {
                    await Task.sleepMs(1000 + UInt64(arc4random_uniform(500)))
                    count += 1

                    log("Task: \(i), count: \(count)")
                }
                return (i, count)
            }
        }

        await Task.sleepMs(5500)
        group.cancelAll()

        for await result in group {
            log("result: \(result)")
        }
    }
}
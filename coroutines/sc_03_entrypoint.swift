//
// Created by benny on 2022/1/21.
//

import Foundation


func helloAsync() async -> Int {
    await withCheckedContinuation { continuation in
        DispatchQueue.global().async {
            continuation.resume(returning: Int(arc4random()))
        }
    }
}

func sc03_01() {
    Task.detached {
        print(await helloAsync())
    }

    Task {
        print(await helloAsync())
    }

    Thread.sleep(forTimeInterval: 1)
}

func errorThrown() async throws {
    throw "Runtime Error"
}

func sc_03_02() async throws {
    let task = Task {
        try await errorThrown()
    }

    await Task.sleep(1000_000_000)
}

func sc_03_03() async throws {
    let task = Task {
        try await errorThrown()
    }

    do {
        try await task.value
    } catch {
        print(error)
    }
}
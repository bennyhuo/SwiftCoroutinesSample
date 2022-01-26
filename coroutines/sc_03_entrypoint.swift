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
//
// Created by benny on 2022/1/21.
//

import Foundation

func sc04_01() async {
    let seg = 10
    let n = Int(arc4random_uniform(10000))
    print(n)

    let add = { (min: Int, max: Int) -> Int in
        var sum = 0
        for i in min..<max {
            sum += i
        }
        return sum
    }

    let result = await withTaskGroup(of: Int.self, returning: Int.self) { group -> Int in


        for i in 1...(n / seg) {
            group.addTask { add(seg * (i - 1), seg * i) }
        }

        if n % seg > 0 {
            group.addTask {
                add(n - n % seg, n + 1)
            }
        }

        var totalSum = 0
        for await result in group {
            totalSum += result
        }

//        totalSum = await group.reduce(0) { r, i in
//            result + i
//        }

        await group.waitForAll()

        return totalSum
    }
    print(result)
}

func sc04_02() async {
    var taskGroup: TaskGroup<Int>?
    _ = await withTaskGroup(of: Int.self) { (group) -> Int in
        taskGroup = group
        print("get group")
        group.addTask { 1 }
        return 0
    }

    print("use group")

    guard let group = taskGroup else {
        print("group is nil")
        return
    }

    // error
    for await i in group {
        print(i)
    }
}

func sc04_03() async {
//     await withTaskGroup(of: Void.self) { (group) -> Void in
//        group.addTask {
//            group.addTask { // error
//                print("inner task")
//            }
//        }
//    }
}

extension String : Error {

}

func sc04_04() async {
    _ = await withTaskGroup(of: Int.self) { group -> String in
        group.addTask { 1 }
        return "OK"
    }

    do {
        _ = try await withThrowingTaskGroup(of: Int.self) { group -> String in
            try await Task.sleep(nanoseconds: 1000000)
            return "OK"
        }
    } catch {

    }
}

func sc04_05() async {

}
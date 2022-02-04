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
            group.addTask {
                add(seg * (i - 1), seg * i)
            }
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
        group.addTask {
            1
        }
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

extension String: Error {

}

func sc04_04() async {
    _ = await withTaskGroup(of: Int.self) { group -> String in
        group.addTask {
            1
        }
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

func sc_04_05() async {
    let result = await withThrowingTaskGroup(of: Int.self) { group -> Int in
        group.addTask {
            await Task.sleep(1000_000_000)
            try await errorThrown()
            return 0
        }

        group.addTask {
            await Task.sleep(500_000_000)
            return -1
        }

        group.addTask {
            await Task.sleep(1500_000_000)
            return 1
        }

        while (!group.isEmpty) {
            do {
                print(try await group.next() ?? "Nil")
            } catch {
                print(error)
            }
        }

        return 100
    }

    print(result)
}

func getUserInfo(_ user: String) async -> String {
    "name: \(user), age: 10"
}

func getFollowers(_ user: String) async -> [String] {
    ["a@\(user)", "b@\(user)"]
}

func getProjects(_ user: String) async -> [String] {
    ["KotlinDeepCopy", "TryRun", "KotlinValueDef"]
}

struct User {
    let name: String
    let info: String
    let followers: [String]
    let projects: [String]
}

enum Result {
    case info(value: String)
    case followers(value: [String])
    case projects(value: [String])
}

func getUser(name: String) async -> User {
    await withTaskGroup(of: Result.self) { group in
        group.addTask {
            .info(value: await getUserInfo(name))
        }

        group.addTask {
            .followers(value: await getFollowers(name))
        }

        group.addTask {
            .projects(value: await getProjects(name))
        }

        var info: String? = nil
        var followers: [String]? = nil
        var projects: [String]? = nil
        for await r in group {
            switch r {
            case .info(value: let value):
                info = value
            case .followers(value: let value):
                followers = value
            case .projects(value: let value):
                projects = value
            }
        }

        return User(name: name, info: info ?? "", followers: followers ?? [], projects: projects ?? [])
    }
}

func getUserNew(name: String) async -> User {
    async let info = getUserInfo(name)
            async let followers = getFollowers(name)
            async let projects = getProjects(name)

    return User(name: name, info: await info, followers: await followers, projects: await projects)
}

func getUsers(names: [String]) async -> [User] {
    await withTaskGroup(of: User.self) { group in
        for name in names {
            group.addTask {
                await getUser(name: name)
            }
        }

        return await group.reduce(into: Array<User>()) { (partialResult, user) in
            partialResult.append(user)
        }
    }
}

func getUsersNew(names: [String]) async throws -> [User] {
    let tasks = names.map { name in
        Task { () -> User in
            print("0 get \(name)")
            try await Task.sleep(nanoseconds: 500_000_000)
            print("1 getting \(name), \(Task.isCancelled)")
            return await getUser(name: name)
        }
    }

    return try await withTaskCancellationHandler(operation: {
        var users = Array<User>()
        for task in tasks {
            users.append(try await task.value)
        }
        return users
    }, onCancel: {
        tasks.forEach { task in task.cancel() }
    })
}
//
// Created by benny on 2022/1/21.
//

import Foundation

@main
struct App {
    static func main() async throws {
        let userTask = Task {
            try await getUsersNew(names: ["a", "b", "c"])
        }

        await Task.sleep(100_000_000)
        userTask.cancel()
        do {
            print(try await userTask.value)
        } catch {
            print(error)
        }
    }
}
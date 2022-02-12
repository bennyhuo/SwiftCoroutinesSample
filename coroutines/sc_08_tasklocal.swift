//
// Created by benny on 2022/2/8.
//

import Foundation

class Logger {
//    @TaskLocal(wrappedValue: "default")
//    static var tag: String
    @TaskLocal
    static var tag: String = "default"
}

func logWithTag(_ message: Any) async {
    print("(\(Logger.tag)): \(message)")
}

func sc_08_01() async {
    await Logger.$tag.withValue("MyTask") {
        await logWithTag("in withValue")
    }

    await logWithTag("out of withValue")

    await Logger.$tag.withValue("MyTask") {
        await Task {
            await logWithTag("Task.init")
        }.value

        await Task.detached {
            await logWithTag("Task.detached")
        }.value
    }

    await Logger.$tag.withValue("Task1") {
        await logWithTag("1")
        await Logger.$tag.withValue("Task2") {
            await logWithTag("2")
            await Logger.$tag.withValue("Task3") {
                await logWithTag("3")
            }
            await logWithTag("22")
        }
        await logWithTag("11")
    }

}
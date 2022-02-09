//
// Created by benny on 2022/2/8.
//

import Foundation

class Logger {
    @TaskLocal
    static var tag: String = "null"
}

func logWithTag(_ message: Any) async {
    print("(\(Logger.tag)): \(message)")
}

func sc_07_01() async {
    await Logger.$tag.withValue("MyTask") {
        await logWithTag("in my task")
    }

    await logWithTag("out of my task")
}
//
// Created by benny on 2022/1/23.
//

import Foundation

func log(_ message: Any,
         function: String = #function,
         file: String = #file,
         line: Int = #line) {

    print("[\(Thread.current.description)] \(message)")
    // print("[\(Thread.current.description)] (\(URL(fileURLWithPath: file).lastPathComponent):\(line)) \(function): \(message)")
}
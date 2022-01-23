//
// Created by benny on 2022/1/21.
//

import Foundation

@main
struct App {

    static func throwable() async throws {

    }

    @inlinable static func rethrowable(body: @escaping () async throws -> Int) async rethrows {

    }

    static func main() async throws {
        await sc04_04()
    }
}
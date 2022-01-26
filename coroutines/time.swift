//
// Created by benny on 2022/1/23.
//

import Foundation

extension Task where Success == Never, Failure == Never{
    static func sleepMs(_ millisecond: UInt64) async {
        await sleep(millisecond * 1000_000)
    }

    static func sleepMsCancellable(_ millisecond: UInt64) async throws {
        try await sleep(nanoseconds: millisecond * 1000_000)
    }
}
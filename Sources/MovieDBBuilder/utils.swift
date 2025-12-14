//
//  utils.swift
//  MovieDBBuilder
//
//  Created by James Mark on 12/12/25.
//

extension Sequence where Element: Sendable {
    func concurrentMap<U: Sendable>(
        maxConcurrent: Int,
        _ transform: @Sendable @escaping (Element) async throws -> U
    ) async throws -> [U] {

        var results = Array<U?>(repeating: nil, count: self.underestimatedCount)

        try await withThrowingTaskGroup(of: (Int, U).self) { group in
            var index = 0
            var iterator = self.makeIterator()

            // Start initial tasks
            for _ in 0..<maxConcurrent {
                guard let element = iterator.next() else { break }
                let currentIndex = index
                index += 1

                group.addTask {
                    let value = try await transform(element)
                    return (currentIndex, value)
                }
            }

            // As tasks finish, enqueue new ones
            while let (finishedIndex, value) = try await group.next() {
                results[finishedIndex] = value

                if let nextElement = iterator.next() {
                    let currentIndex = index
                    index += 1

                    group.addTask {
                        let value = try await transform(nextElement)
                        return (currentIndex, value)
                    }
                }
            }
        }

        return results.compactMap { $0 }

    }
}

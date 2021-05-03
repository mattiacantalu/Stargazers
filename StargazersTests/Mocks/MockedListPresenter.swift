import Foundation
@testable import Stargazers

class MockedListPresenter: ListPresenterProtocol {
    var counterStargazersList: Int = 0
    var counterOnError: Int = 0
    var counterFetch: Int = 0
    var counterFetchNext: Int = 0

    var stargazersListHandler: (([MStargazer]) -> Void)?
    var onErrorHandler: ((Error) -> Void)?
    var fetchHandler: (() -> Void)?
    var fetchNextHandler: (() -> Void)?

    public init() {}

    func stagazers(list: [MStargazer]) {
        counterStargazersList += 1
        if let stargazersListHandler = stargazersListHandler {
            return stargazersListHandler(list)
        }
    }

    func on(error: Error) {
        counterOnError += 1
        if let onErrorHandler = onErrorHandler {
            return onErrorHandler(error)
        }
    }

    func fetch() {
        counterFetch += 1
        if let fetchHandler = fetchHandler {
            return fetchHandler()
        }
    }

    func fetchNext() {
        counterFetchNext += 1
        if let fetchNextHandler = fetchNextHandler {
            return fetchNextHandler()
        }
    }
}

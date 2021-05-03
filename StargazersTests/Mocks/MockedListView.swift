import Foundation
@testable import Stargazers

class MockedListView: ListViewProtocol {
    var counterShowError: Int = 0
    var counterLoadStargazers: Int = 0

    var showErrorHandler: ((Error?) -> Void)?
    var loadStargazersHandler: (([MStargazer]) -> Void)?

    public init() {}

    func show(error: Error?) {
        counterShowError += 1
        if let showErrorHandler = showErrorHandler {
            return showErrorHandler(error)
        }
    }

    func load(stargazers: [MStargazer]) {
        counterLoadStargazers += 1
        if let loadStargazersHandler = loadStargazersHandler {
            return loadStargazersHandler(stargazers)
        }
    }
}

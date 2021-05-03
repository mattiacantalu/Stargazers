import Foundation
@testable import Stargazers

class MockedStargazersInteractor: GetStargazersInteractorProtocol {
    var counterPerform: Int = 0
    var performrHandler: ((MUser, Int) -> Void)?

    public init() {}

    func perform(user: MUser, page: Int) {
        counterPerform += 1
        if let performrHandler = performrHandler {
            return performrHandler(user, page)
        }
    }
}

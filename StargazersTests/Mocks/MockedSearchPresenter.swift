import Foundation
@testable import Stargazers

class MockedSearchPresenter: SearchPresenterProtocol {
    var counterSearchUser: Int = 0
    var searchUserHandler: ((MUser) -> Void)?

    public init() {}

    func search(user: MUser) {
        counterSearchUser += 1
        if let searchUserHandler = searchUserHandler {
            return searchUserHandler(user)
        }
    }
}

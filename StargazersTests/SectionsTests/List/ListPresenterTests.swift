import XCTest
@testable import Stargazers

class ListPresenterTests: XCTestCase {
    private var sut: ListPresenter?
    private var view: MockedListView?
    private var interactor: MockedStargazersInteractor?
    private var user: MUser?

    override func setUp() {
        view = MockedListView()
        interactor = MockedStargazersInteractor()

        do {
            sut = ListPresenter(view: view,
                                stargazersInteractor: try XCTUnwrap(interactor),
                                user: try XCTUnwrap(MUser(name: "user1", repo: "myrepo")))
        } catch { XCTFail("Expected success. Got \(error)") }
    }

    func testFetchStargazers_shouldCallInteractorPerform() {
        interactor?.performrHandler = {
            XCTAssertEqual($0.name, "user1")
            XCTAssertEqual($0.repo, "myrepo")
            XCTAssertEqual($1, 1)
        }

        sut?.fetch()
        XCTAssertEqual(interactor?.counterPerform, 1)
    }

    func testFetchNextStargazers_shouldCallInteractorPerform() {
        interactor?.performrHandler = {
            XCTAssertEqual($0.name, "user1")
            XCTAssertEqual($0.repo, "myrepo")
            XCTAssertEqual($1, 2)
        }

        sut?.fetchNext()
        XCTAssertEqual(interactor?.counterPerform, 1)
    }

    func testOnStargazersList_shouldCallViewLoad() {
        view?.loadStargazersHandler = {
            XCTAssertEqual($0.count, 1)
            XCTAssertEqual($0.first?.user, "aaa")
            XCTAssertEqual($0.first?.avatar, "image")
        }

        sut?.stagazers(list: [MStargazer(user: "aaa", avatar: "image")])
        XCTAssertEqual(view?.counterLoadStargazers, 1)
    }

    func testOnError_shouldCallShowViewError() {
        view?.showErrorHandler = {
            XCTAssertEqual($0 as? MyError, MyError.fake)
        }

        sut?.on(error: MyError.fake)
        XCTAssertEqual(view?.counterShowError, 1)
    }
}

enum MyError: Error {
    case fake
}

extension MyError: Equatable {
    static func == (lhs: MyError, rhs: MyError) -> Bool {
        switch (lhs, rhs) {
        case (.fake, .fake):
            return true
        }
    }
}

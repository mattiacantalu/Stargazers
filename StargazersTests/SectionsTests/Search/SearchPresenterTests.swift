import XCTest
@testable import Stargazers

class SearchPresenterTests: XCTestCase {
    private var sut: SearchPresenter?
    private var view: MockedSearchView?
    private var wire: MockedWireframe?

    override func setUp() {
        view = MockedSearchView()
        wire = MockedWireframe()

        sut = SearchPresenter(view: view,
                              wire: wire)
    }

    func testSearchUser() {
        wire?.listControllerHandler = {
            XCTAssertEqual($0.name, "user1")
            XCTAssertEqual($0.repo, "myrepo")
            XCTAssertTrue($1 is SearchViewProtocol)
        }

        let user = MUser(name: "user1",
                         repo: "myrepo")
        sut?.search(user: user)
    
        XCTAssertEqual(wire?.counterListController, 1)
    }
}

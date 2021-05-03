import XCTest
@testable import Stargazers

class StargazersInteractorTests: XCTestCase {
    private var sut: GetStargazersInteractor?
    private var presenter: MockedListPresenter?

    override func setUp() {
        presenter = MockedListPresenter()
    }

    func testGetStargazers_shouldSuccess() {
        presenter?.stargazersListHandler = {
            XCTAssertEqual($0.count, 8)
            XCTAssertEqual($0.first?.user, "dcampogiani")
        }

        guard let data = JSONMock.loadJson(fromResource: "valid_stargazer") else {
            XCTFail("JSON data error!")
            return
        }

        let session = MockedSession(data: data, response: nil, error: nil) { _ in }
        create(session)

        sut?.perform(user: MUser(name: "user1", repo: "repo"), page: 1)
        XCTAssertEqual(presenter?.counterStargazersList, 1)
        XCTAssertEqual(presenter?.counterOnError, 0)
    }

    func testGetStargazers_shouldFail() {
        presenter?.onErrorHandler = {
            XCTAssertEqual($0.localizedDescription, "Not Found")
        }

        guard let data = JSONMock.loadJson(fromResource: "valid_error") else {
            XCTFail("JSON data error!")
            return
        }

        let url = URL(string: "https://sample.com")!
        let response = HTTPURLResponse(url: url,
                                       statusCode: 404,
                                       httpVersion: "1.0",
                                       headerFields: [:])

        let session = MockedSession.simulate(failure: response, data: data) { _ in }
        create(session)

        sut?.perform(user: MUser(name: "user1", repo: "repo"), page: 1)
        XCTAssertEqual(presenter?.counterStargazersList, 0)
        XCTAssertEqual(presenter?.counterOnError, 1)
    }

    func testGetStargazers_shouldReturnError() {
        presenter?.onErrorHandler = {
            let error = $0 as? MyError
            XCTAssertEqual(error, MyError.fake)
        }

        let session = MockedSession.simulate(failure: MyError.fake) { _ in }
        create(session)

        sut?.perform(user: MUser(name: "user1", repo: "repo"), page: 1)
        XCTAssertEqual(presenter?.counterStargazersList, 0)
        XCTAssertEqual(presenter?.counterOnError, 1)
    }
}

private extension StargazersInteractorTests {
    func create(_ session: MURLSessionProtocol) {
        let service = MURLService(session: session,
                                  dispatcher: SyncDispatcher())
        let config = MURLConfiguration(service: service,
                                       baseUrl: "https://sample.com")
        let facade = MServicePerformer(configuration: config)
        sut = GetStargazersInteractor(service: facade)
        sut?.presenter = presenter
    }
}

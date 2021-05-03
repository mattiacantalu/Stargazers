# Stargazers
Sample iOS application to understand how Github Stargazers list API works.

The project is oriented toward the following patterns: 

✅ VIPER Architecture

✅ Protocol Oriented

✅ Functional Programming

✅ Clean Code

✅ Dependency Injection

✅ Unit Tests

It's based on a `GET` API request and built over a `UIViewController` and `UITableView`.


## HOW IT WORKS

Each controller is built by 4 files
1. Router (routing layer)
2. Presenter (view logic)
3. Interactor (business logic for a use case)
4. View (display data)


### CONFIGURATION

The routing layer performs the injection:

🔸 Presenter

🔸 View

🔸 Interactor

```
        let view = UIStoryboard(name: "Main",
                            bundle: nil)
                   .instantiateViewController(withIdentifier: "listViewController") as? ListViewController

        let imageDownloader = MImageDownloader(service: configuration.service, cache: MCacheService())
        let service = MServicePerformer(configuration: configuration)
        let interactor = GetStargazersInteractor(service: service)
        let presenter = ListPresenter(view: view,
                                      stargazersInteractor: interactor,
                                      user: user)

        interactor.presenter = presenter
        view?.presenter = presenter
        view?.downloader = imageDownloader
```

... building the main services of the application:

🔸 Cache and Image services
```
        let imageDownloader = MImageDownloader(service: configuration.service, cache: MCacheService())
```

🔸 Network Service

```
        let service = MServicePerformer(configuration: configuration)
        let interactor = GetStargazersInteractor(service: service)
```

### VIPER FLOW

1. View calls Presenter:

    ```
    override func viewDidLoad() {
        [...]
        presenter?.fetch()
    }
    ```

2. Presenter performs Interactor call

    ```
    func fetch() {
        stargazersInteractor.perform(user: user, page: self.page)
    }
    ```

3. Interactor performs the "business logic" and notifies Presenter

    ```
    func perform(user: MUser, page: Int) {
        performTry({
            try service.stargazers(for: user,
                                   page: page) { result in
                switch result {
                case .success(let response):
                    self.presenter?.stagazers(list: response)
                case .failure(let error):
                    self.presenter?.on(error: error)
                }
            }
        }, fallback: { self.presenter?.on(error: $0) })
    }
    ```

4. Presenter revices data from Interactor and notifies the View

    ```
    func stagazers(list: [MStargazer]) {
        view?.load(stargazers: list)
    }
    ```

5. View updates the UI
    ```
    func load(stargazers: [MStargazer]) {
        self.stargazers = (self.stargazers ?? []) + stargazers
    }
    ```

### CORE SERVICES

1. `MServicePerformer` makes the requests
```
struct MServicePerformer {
    private let configuration: MURLConfiguration

    init(configuration: MURLConfiguration) {
        self.configuration = configuration
    }

    var baseUrl: URL? {
        URL(string: configuration.baseUrl)
    }

    func makeRequest<T: Decodable>(_ request: MURLRequest,
                                     map: T.Type,
                                     completion: @escaping ((Result<T, Error>) -> Void)) throws {
        
        let urlRequest = request
            .build()

        configuration
            .service
            .performTask(with: urlRequest) { responseData, urlResponse, responseError in
                completion(self.makeDecode(response: responseData,
                                           urlResponse: urlResponse,
                                           map: map,
                                           error: responseError))
            }
    }
    
    [...]
}
```

2. `MURLService` is a concrete implementation of `MURLServiceProtocol`: manages the `performTask` and dispatches the response
```
extension MURLService: MURLServiceProtocol {
    func performTask(with request: URLRequest,
                            completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        session.dataTask(with: request) { responseData, urlResponse, responseError in
            self.dispatcher.dispatch {
                completion(responseData, urlResponse, responseError)
            }
        }
    }

    func performTask(with url: URL,
                     completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        session.dataTask(with: url) { responseData, urlResponse, responseError in
            self.dispatcher.dispatch {
                completion(responseData, urlResponse, responseError)
            }
        }
    }
}
```

3. `MURLSession` implements the `MURLSessionProtocol`, creating network tasks
```
    func dataTask(with request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let task = session.dataTask(with: request) { responseData, urlResponse, responseError in
            completion(responseData, urlResponse, responseError)
        }
        task.resume()
    }

    func dataTask(with url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let task = session.dataTask(with: url) { responseData, urlResponse, responseError in
            completion(responseData, urlResponse, responseError)
        }
        task.resume()
    }
```

4. `MServicePerformer` also makes the deconding and mapping, based on generic `Decodable` objects
```
    private func makeDecode<T: Decodable>(response: Data?,
                                          urlResponse: URLResponse?,
                                          map: T.Type,
                                          error: Error?) -> (Result<T, Error>) {
        
        if let error = error { return (.failure(error)) }
        guard let jsonData = response else { return (.failure(MServiceError.noData)) }
        
        let statusCode = urlResponse?.httpResponse?.statusCode ?? MConstants.URL.statusCodeOk

        guard statusCode.inRange(MConstants.URL.statusCodeOk ..< MConstants.URL.statusCodemultipleChoice) else {
            return decode(response: jsonData,
                          map: MError.self)
                .mapError(code: statusCode)
        }

        return decode(response: jsonData, map: map)
    }
    
    private func decode<T: Decodable>(response: Data,
                                          map: T.Type) -> (Result<T, Error>) {
        do {
            let decoded = try JSONDecoder().decode(map, from: response)
            return (.success(decoded))
        } catch { return (.failure(error)) }
    }
```

5. Images are downloaded by `MImageDownloader`, using `MCacheable` to cache them
```
    func makeRequest(with url: URL,
                     completion: @escaping (_ image: UIImage?) -> Void) {
        (cache.object(for: url.absoluteString) as? UIImage)
            .fold(some: { cached(image: $0, completion: completion) },
                  none: { perform(url: url, completion: completion) })
    }
```

```
    func cached(image: UIImage,
                completion: @escaping (_ image: UIImage?) -> Void) {
        completion(image)
    }

    func perform(url: URL,
                 completion: @escaping (_ image: UIImage?) -> Void) {
        service.performTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == MConstants.URL.statusCodeOk,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            cache.set(obj: image, for: url.absoluteString)
            completion(image)
        }
    }
```

## Comands (get stargazers)

The _get stargazers_ request is implemented inside `MGithubComands` as an extension of `MServicePerformer`, conformed to `MServicePerformerProtocol`

```
    func stargazers(for user: MUser,
                    page: Int,
                    completion: @escaping ((Result<[MStargazer], Error>) -> Void)) throws {

        guard let url = baseUrl else {
            completion(.failure(MServiceError.couldNotCreate(url: baseUrl?.absoluteString)))
            return
        }

        let request = { () -> MURLRequest in
            MURLRequest
                .get(url: url)
                .with(component: MConstants.URL.Component.repos)
                .with(component: user.name)
                .with(component: user.repo)
                .with(component: MConstants.URL.Component.stargazers)
                .appendQuery(name: MConstants.URL.Query.perPage, value: "20")
                .appendQuery(name: MConstants.URL.Query.page, value: page.stringValue)
        }

        try makeRequest(request(),
                        map: [MStargazer].self,
                        completion: completion)
    }
```

### TESTS

Each module is unit tested (mocks oriented): decoding, mapping, services, presenter, interactor and view (and utilies for sure). 

1. Presenter sample test

```
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
```

```
class MockedWireframe: WireProtocol {
    var counterSearchController: Int = 0
    var counterListController: Int = 0

    var searchControllerHandler: (() -> UINavigationController)?
    var listControllerHandler: ((MUser, Any?) -> Void)?

    public init() {}

    func searchController() -> UINavigationController {
        counterSearchController += 1
        if let searchControllerHandler = searchControllerHandler {
            return searchControllerHandler()
        }
        return UINavigationController()
    }

    func listController(user: MUser, from sender: Any?) {
        counterListController += 1
        if let listControllerHandler = listControllerHandler {
            return listControllerHandler(user, sender)
        }
    }
}
```

2. Comand (decoding and mapping) test

```
    func testGetStargazersResponseShouldSuccess() {
        guard let data = JSONMock.loadJson(fromResource: "valid_stargazer") else {
            XCTFail("JSON data error!")
            return
        }
        let session = MockedSession(data: data, response: nil, error: nil) { _ in }

        do {
            try MServicePerformer(configuration: configure(session))
                .stargazers(for: MUser(name: "", repo: ""), page: 0) { result in
                    switch result {
                    case .success(let response):
                        XCTAssertEqual(response.count, 8)
                        XCTAssertEqual(response.first?.user, "dcampogiani")
                        XCTAssertEqual(response.first?.avatar, "https://avatars.githubusercontent.com/u/1054526?v=4")
                    case .failure(let error):
                        XCTFail("Should be success! Got: \(error)")
                    }
                }
        } catch { XCTFail("Unexpected error \(error)!") }
    }
```

3. API Request tests

```
    func testCreateRequest() {
        guard let url = URL(string: "https://api.github.com") else {
            XCTFail("URL error!")
            return
        }

        let request = MURLRequest
            .get(url: url)
            .with(component: "repos")
            .with(component: "user1")
            .appendQuery(name: "page", value: "1")
            .appendQuery(name: "per_page", value: "5")
        XCTAssertEqual(request.url.absoluteString, "https://api.github.com/repos/user1?page=1&per_page=5")
        XCTAssertEqual(request.method.rawValue, "GET")
    }
```

4. API Error tests

```
    func testMapError() {
        guard let data = JSONMock.loadJson(fromResource: "valid_error") else {
            XCTFail("JSON data error!")
            return
        }

        let url = URL(string: "https://api.github.com")!
        let response = HTTPURLResponse(url: url,
                                       statusCode: 401,
                                       httpVersion: "1.0",
                                       headerFields: [:])
        
        let session = MockedSession.simulate(failure: response, data: data) { _ in }

        let service = MURLService(session: session,
                                   dispatcher: SyncDispatcher())
        let config =  MURLConfiguration(service: service,
                                        baseUrl: "https://api.github.com")
        
        do {
            try MServicePerformer(configuration: config)
                .stargazers(for: MUser(name: "", repo: ""), page: 0) { result in
                    switch result {
                    case .success:
                        XCTFail("Should be fail! Got success.")
                    case .failure(let error):
                        XCTAssertEqual(error.localizedDescription, "Not Found")
                    }
                }
        } catch { XCTFail("Unexpected error \(error)!") }
    }
```

## CONTRIBUTORS
Any suggestions are welcome 👨🏻‍💻

## REQUIREMENTS
• Swift 5

• Xcode 12.5

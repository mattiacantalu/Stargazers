import Foundation

protocol GetStargazersInteractorProtocol {
    func perform(user: MUser, page: Int)
}

class GetStargazersInteractor: GetStargazersInteractorProtocol {
    private let service: MServicePerformerProtocol
    weak var presenter: ListPresenterProtocol?

    init(service: MServicePerformerProtocol) {
        self.service = service
    }

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
}

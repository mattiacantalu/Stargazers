import Foundation
import UIKit

struct ListRouter {
    private let wire: WireProtocol
    private let configuration: MURLConfiguration
    private let user: MUser

    init(wire: WireProtocol,
         configuration: MURLConfiguration,
         user: MUser) {
        self.wire = wire
        self.configuration = configuration
        self.user = user
    }
}

extension ListRouter: PresentationProtocol {
    func load() -> UIViewController {
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

        return view ?? UIViewController()
    }
}

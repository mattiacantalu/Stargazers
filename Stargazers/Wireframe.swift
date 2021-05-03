import Foundation
import UIKit

protocol PresentationProtocol {
    func load() -> UIViewController
}

protocol WireProtocol {
    func searchController() -> UINavigationController
    func listController(user: MUser, from sender: Any?)
}

struct Wireframe: WireProtocol {
    private let configuration: MURLConfiguration

    init(configuration: MURLConfiguration) {
        self.configuration = configuration
    }

    func searchController() -> UINavigationController {
        UINavigationController(rootViewController: SearchRouter(wire: self).load())
    }

    func listController(user: MUser, from sender: Any?) {
        let list = ListRouter(wire: self,
                   configuration: configuration,
                   user: user).load()
        (sender as? UIViewController)?
            .navigationController?
            .pushViewController(list, animated: true)
    }
}

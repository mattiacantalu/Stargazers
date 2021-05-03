import Foundation
import UIKit

struct SearchRouter {
    private let wire: WireProtocol

    init(wire: WireProtocol) {
        self.wire = wire
    }
}

extension SearchRouter: PresentationProtocol {
    func load() -> UIViewController {
        let view = UIStoryboard(name: "Main",
                            bundle: nil)
                   .instantiateViewController(withIdentifier: "searchViewController") as? SearchViewController

        let presenter = SearchPresenter(view: view,
                                        wire: wire)

        view?.presenter = presenter

        return view ?? UIViewController()
    }
}

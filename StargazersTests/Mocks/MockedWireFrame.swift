import Foundation
import UIKit
@testable import Stargazers

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

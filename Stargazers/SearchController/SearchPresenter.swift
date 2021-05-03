import Foundation
import UIKit

protocol SearchPresenterProtocol: AnyObject {
    func search(user: MUser)
}

class SearchPresenter {
    private let view: SearchViewProtocol?
    private let wire: WireProtocol?

    init(view: SearchViewProtocol?,
         wire: WireProtocol?) {
        self.view = view
        self.wire = wire
    }
}

extension SearchPresenter: SearchPresenterProtocol {
    func search(user: MUser) {
        wire?.listController(user: user,
                             from: view)
    }
}

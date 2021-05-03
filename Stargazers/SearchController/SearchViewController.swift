import Foundation
import UIKit

protocol SearchViewProtocol {}

final class SearchViewController: UIViewController {
    var presenter: SearchPresenterProtocol?

    @IBOutlet weak var userTxtField: UITextField?
    @IBOutlet weak var repoTxtField: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Search"
    }

    @IBAction func onSearch(_ sender: Any) {
        presenter?.search(user: MUser(name: userTxtField?.text ?? "",
                                      repo: repoTxtField?.text ?? ""))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}

extension SearchViewController: SearchViewProtocol {}

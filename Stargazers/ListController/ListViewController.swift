import Foundation
import UIKit

protocol ListViewProtocol {
    func show(error: Error?)
    func load(stargazers: [MStargazer])
}

final class ListViewController: UIViewController {
    var presenter: ListPresenterProtocol?
    @IBOutlet weak private var tableView: UITableView?
    var downloader: MImageProtocol?

    private var stargazers: [MStargazer]? {
        didSet {
            tableView?.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Stargazers"

        presenter?.fetch()
    }
}

extension ListViewController: ListViewProtocol {
    func load(stargazers: [MStargazer]) {
        self.stargazers = (self.stargazers ?? []) + stargazers
    }

    func show(error: Error?) {
        alert(title: "Error",
              message: error?.localizedDescription)
    }
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        stargazers?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as? ListCell

        (stargazers?[indexPath.row]).map { cell?.setup(star: $0, downloader: downloader) }

        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let star = stargazers ?? []
        if indexPath.row == star.count - 1 {
            presenter?.fetchNext()
        }
    }
}

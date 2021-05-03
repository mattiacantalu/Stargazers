import UIKit

class ListCell: UITableViewCell {
    @IBOutlet weak var usernameLabel: UILabel?
    @IBOutlet weak var userAvatar: UIImageView?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setup(star: MStargazer,
               downloader: MImageProtocol?) {
        usernameLabel?.text = star.user
        downloader?.downloadImage(from: star.avatar) { [weak self] in
            self?.userAvatar?.image = $0
        }
    }
}

import UIKit

class CommentCell: UITableViewCell {
    @IBOutlet weak var faceImageView: UIImageView!
    @IBOutlet weak var commentLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        commentLabel.font = UIFont.init(name: "LINE Seed JP App_OTF Regular", size: 15)
        commentLabel.textColor = .black
        commentLabel.numberOfLines = 0
        faceImageView.contentMode = .scaleAspectFit
        
    }

    func configure(with data: CommentData) {
        // アイコン設定
        switch data.rating {
        case 0:
            faceImageView.image = UIImage(named: "FaceIcon1")
        case 1:
            faceImageView.image = UIImage(named: "FaceIcon2")
        case 2:
            faceImageView.image = UIImage(named: "FaceIcon3")
        case 3:
            faceImageView.image = UIImage(named: "FaceIcon4")
        default:
            faceImageView.image = nil
        }

        // コメント設定
        commentLabel.text = data.comment
    }
}

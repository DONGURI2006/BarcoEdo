import UIKit


protocol CommentCellDelegate: AnyObject {
    func didTapExpandButton(in cell: CommentCell)
}

class CommentCell: UITableViewCell, UITextViewDelegate {
    @IBOutlet weak var faceImageView: UIImageView!

    @IBOutlet weak var ComentText: UITextView!
    
    @IBOutlet weak var expandButton: UIButton!
        
    weak var delegate: CommentCellDelegate?
        
    private var isExpanded = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        faceImageView.contentMode = .scaleAspectFit
        ComentText.delegate = self
        
        ComentText.isEditable = false
        ComentText.isSelectable = false
        ComentText.isScrollEnabled = false
        
        contentView.layer.borderColor = UIColor.systemGreen.cgColor
        contentView.layer.borderWidth = 2.0
        contentView.layer.cornerRadius = 10.0
        contentView.layer.masksToBounds = true
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let margin = UIEdgeInsets(top: 10, left: 30, bottom: 10, right: 30)
        contentView.frame = contentView.frame.inset(by: margin)
    }
    
    func configure(with data: CommentData/*, expanded: Bool*/) {
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

        ComentText.text = data.comment
    }
    
}

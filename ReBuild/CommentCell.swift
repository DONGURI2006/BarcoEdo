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
    
    
    
    func configure(with data: CommentData, expanded: Bool) {
            ComentText.text = data.comment
            isExpanded = expanded
            
            // アイコン
            switch data.rating {
            case 0: faceImageView.image = UIImage(named: "FaceIcon1")
            case 1: faceImageView.image = UIImage(named: "FaceIcon2")
            case 2: faceImageView.image = UIImage(named: "FaceIcon3")
            case 3: faceImageView.image = UIImage(named: "FaceIcon4")
            default: faceImageView.image = nil
            }
            
            // 最大行数を6行に制限（未展開時）
            if expanded {
                ComentText.textContainer.maximumNumberOfLines = 0
                ComentText.textContainer.lineBreakMode = .byWordWrapping
                expandButton.setTitle("", for: .normal)
            } else {
                ComentText.textContainer.maximumNumberOfLines = 6
                ComentText.textContainer.lineBreakMode = .byTruncatingTail
                expandButton.setTitle("…さらに表示", for: .normal)
            }
            
            // コメントが短い場合はボタン非表示
            expandButton.isHidden = needsExpandButton() == false
        }
        
        private func needsExpandButton() -> Bool {
            let textHeight = ComentText.sizeThatFits(CGSize(width: ComentText.frame.width, height: .greatestFiniteMagnitude)).height
            return textHeight > (20 * 6)
        }
        
        @IBAction func expandButtonTapped(_ sender: UIButton) {
            delegate?.didTapExpandButton(in: self)
        }
    
}

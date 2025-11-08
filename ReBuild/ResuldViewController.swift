import UIKit
import Alamofire
import SwiftyJSON 


class ResultViewController: UIViewController, UITableViewDelegate {
    
    
    @IBOutlet weak var AllBtn: UIButton!
    
    @IBOutlet weak var ValueBtn1: UIButton!
    @IBOutlet weak var ValueBtn2: UIButton!
    @IBOutlet weak var ValueBtn3: UIButton!
    @IBOutlet weak var ValueBtn4: UIButton!
    
    var codeNumber: String?
    var productName:String?
    var latitude: Double?
    var longitude: Double?

    var filteredComments: [CommentData] = []
    
    var expandedIndexPaths: Set<IndexPath> = []

    var selectedRating: Int? = nil
    
    var comments: [CommentData] = [] {
        didSet {
            filteredComments = comments.reversed()
            CommentView?.reloadData()
        }
    }
    
    @IBOutlet weak var CommentView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filteredComments = comments.reversed()
        let selectedColor = UIColor(red: 115/255, green: 173/255, blue: 57/255, alpha: 1.0)
        AllBtn.setTitleColor(selectedColor, for: .normal)
        AllBtn.backgroundColor = .white
        CommentView.reloadData()

        print("商品名：\(self.productName as Any)")
        
        CommentView.dataSource = self
        CommentView.delegate = self
        
        AllBtn.setTitleColor(.white, for: .normal)
        AllBtn.backgroundColor = selectedColor
        selectedRating = nil
        
        CommentView.rowHeight = UITableView.automaticDimension
        CommentView.estimatedRowHeight = 60
        
        filteredComments = comments.reversed()
        CommentView.reloadData()
    }
    
    @IBAction func ValueBtn(_ sender: UIButton)
        {
            
            selectedRating = sender.tag

            let selectedColor = UIColor(red: 115/255, green: 173/255, blue: 57/255, alpha: 1.0)
            let allButtons = [AllBtn,ValueBtn1, ValueBtn2, ValueBtn3, ValueBtn4]
            
            for (index, button) in allButtons.enumerated() {
                guard let button = button else { continue }

                let isSelected = (index == selectedRating)
                
                for button in allButtons {
                    button?.setTitleColor(selectedColor, for: .normal)
                    button?.backgroundColor = .white
                }
                
                switch sender {
                case AllBtn:
                    selectedRating = nil
                    filteredComments = comments.reversed()
                case ValueBtn1:
                    selectedRating = 0
                    filteredComments = comments.filter { $0.rating == 0 }.reversed()
                case ValueBtn2:
                    selectedRating = 1
                    filteredComments = comments.filter { $0.rating == 1 }.reversed()
                case ValueBtn3:
                    selectedRating = 2
                    filteredComments = comments.filter { $0.rating == 2 }.reversed()
                case ValueBtn4:
                    selectedRating = 3
                    filteredComments = comments.filter { $0.rating == 3 }.reversed()
                    
                default:
                    selectedRating = nil
                    filteredComments = comments.reversed()
                }
                
                sender.setTitleColor(.white, for: .normal)
                sender.backgroundColor = selectedColor
                
                CommentView.reloadData()
            }
        }
    
}

extension ResultViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filteredComments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentCell else {
            return UITableViewCell()
        }

        let data = filteredComments[indexPath.row]
        let expanded = expandedIndexPaths.contains(indexPath)
        cell.configure(with: data, expanded: expanded)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = filteredComments[indexPath.row]
        
        let commentText = data.comment
             
        //ラベルのフォント設定（CommentCell と同じものにする）
        let font = UIFont(name: "LINE Seed JP App_OTF Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)
             
        //コメントの行数を推定する
        let maxWidth = tableView.frame.width - 100
        let textHeight = commentText.boundingRect(
            with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        ).height
             
        //行数の計算
        let lineCount = ceil(textHeight / 26)
        //ベースの高さ
        let baseHeight: CGFloat = 120
        
        //コメント行数に応じて高さを調整
        let dynamicHeight = baseHeight + (lineCount * 26)
        
        return dynamicHeight
    }
    
}


extension ResultViewController: CommentCellDelegate {
    func didTapExpandButton(in cell: CommentCell) {
        if let indexPath = CommentView.indexPath(for: cell) {
            if expandedIndexPaths.contains(indexPath) {
                expandedIndexPaths.remove(indexPath)
            } else {
                expandedIndexPaths.insert(indexPath)
            }
            CommentView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

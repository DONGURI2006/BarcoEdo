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
    var comments: [CommentData] = []

    @IBOutlet weak var CommentView: UITableView!
    
    private let emptyLabel: UILabel = {
            let label = UILabel()
            label.text = "コメントがまだありません。\n最初のコメントを書き込もう！"
            label.textAlignment = .center
            label.numberOfLines = 0
            label.textColor = .black
            label.font = UIFont(name: "LINE Seed JP App_OTF Regular", size: 16)
            return label
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("商品名：\(self.productName as Any)")
        
        
        CommentView.dataSource = self
        CommentView.delegate = self
        
        CommentView.rowHeight = UITableView.automaticDimension
        CommentView.estimatedRowHeight = 60
        
        updateEmptyState()
        
    }
    var selectedRating: Int? = nil

        @IBAction func ValueBtn(_ sender: UIButton)
        {
            selectedRating = sender.tag

            let selectedColor = UIColor(red: 115/255, green: 173/255, blue: 57/255, alpha: 1.0)

            let allButtons = [AllBtn,ValueBtn1, ValueBtn2, ValueBtn3, ValueBtn4]
            for (index, button) in allButtons.enumerated() {
                guard let button = button else { continue }

                let isSelected = (index == selectedRating)

                UIView.animate(withDuration: 0.2) {
                    if isSelected {
                        button.backgroundColor = selectedColor
                    } else {
                        button.backgroundColor = .clear  // そのままにする
                    }

                }
            }
        }

    func updateEmptyState() {
        CommentView.backgroundView = comments.isEmpty ? emptyLabel : nil
    }
    
}

extension ResultViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        updateEmptyState()
        
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentCell else {
            return UITableViewCell()
        }

        let data = comments[indexPath.row]
        cell.configure(with: data)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = comments[indexPath.row]
        
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
        let baseHeight: CGFloat = 100
        
        //コメント行数に応じて高さを調整
        let dynamicHeight = baseHeight + (lineCount * 26)
        
        return dynamicHeight
    }
    
}

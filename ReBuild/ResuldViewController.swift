import UIKit
import Alamofire
import SwiftyJSON 


class ResultViewController: UIViewController, UITableViewDelegate {
    
    
    var codeNumber: String?
    var productName:String?
    var latitude: Double?
    var longitude: Double?
    var comments: [CommentData] = []

    @IBOutlet weak var NameLabel: UILabel!
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
        
        NameLabel.text = productName ?? "なし"
        
        CommentView.dataSource = self
        CommentView.delegate = self
        
        updateEmptyState()
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
        let data = comments[indexPath.row]
                
        //コメント
        cell.textLabel?.text = data.comment
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.textLabel?.textColor = .black
        cell.textLabel?.numberOfLines = 0
            
        //アイコン
        switch data.rating {
        case 0:
            cell.imageView?.image = UIImage(named: "FaceIcon1")
        case 1:
            cell.imageView?.image = UIImage(named: "FaceIcon2")
        case 2:
            cell.imageView?.image = UIImage(named: "FaceIcon3")
        case 3:
            cell.imageView?.image = UIImage(named: "FaceIcon4")
        default:
            cell.imageView?.image = nil
        }
        return cell
    }
}

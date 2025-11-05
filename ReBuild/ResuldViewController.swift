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
}

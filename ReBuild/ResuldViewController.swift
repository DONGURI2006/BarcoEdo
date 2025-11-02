import UIKit
import Alamofire
import SwiftyJSON 


struct CommentData: Codable {
    let comment: String
    let rating: Int
    let latitude: Double
    let longitude: Double
}

struct CheckResponse: Codable {
    let exists: Bool
    let product: String?
    let comments: [CommentData]?
}


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
            label.font = UIFont.systemFont(ofSize: 16)
            return label
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("商品名：\(self.productName as Any)")
        
        NameLabel.text = productName ?? "なし"
        
        CommentView.dataSource = self
        CommentView.delegate = self
        
        if let code = codeNumber {
            fetchCommentsFromServer(for: code)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "GoMap",
                let destination = segue.destination as? MapViewController {

            destination.codeNumber = codeNumber
            
            let locations = comments.map { ($0.latitude, $0.longitude, $0.rating , $0.comment) }
            
                
            destination.commentLocations = locations
            }
            else if segue.identifier == "GoComent",
                let commentVC = segue.destination as? ComentController {
                commentVC.delegate = self
            }
        }
    
    func fetchCommentsFromServer(for barcode: String) {
        
        let params: [String: Any] = ["barcode": barcode]
        
        AF.request("http://192.168.0.26:8080/check",
                   method: .post,
                   parameters: params,
                   encoding: JSONEncoding.default,
                   headers: nil)
        
        
        .responseJSON { res in
            
            if let data = res.data{
                let json = JSON(data)
                print("サーバー応答: \(json)")
                
                let exists = json["exists"].boolValue
                let product = json["product"].stringValue
                let commentArray = json["comments"].arrayValue
                
                DispatchQueue.main.async {
                    if exists {
                        self.productName = product
                        self.NameLabel.text = product
                        
                        self.comments = commentArray.map {
                            CommentData(
                                comment: $0["comment"].stringValue,
                                rating: $0["rating"].intValue,
                                latitude: $0["latitude"].doubleValue,
                                longitude: $0["longitude"].doubleValue
                            )
                        }
                        
                    } else {
                        self.productName = "未登録の商品"
                        self.comments = []
                        self.NameLabel.text = "未登録の商品"
                    }
                    
                    self.CommentView.reloadData()
                    self.updateEmptyState()
                }
            }
                
        }
    }
    func sendCommentToServer(barcode: String, commentData: CommentData) {
            guard let product = productName 
        
            else {
                print("商品名がない")
                return
            }
            
            let params: [String: Any] = [
                "barcode": barcode,
                "product": product,
                "comment": commentData.comment,
                "rating": commentData.rating,
                "latitude": commentData.latitude,
                "longitude": commentData.longitude
            ]
            
            AF.request("http://192.168.0.26:8080/add",
                       method: .post,
                       parameters: params,
                       encoding: JSONEncoding.default,
                       headers: nil)
        
            .responseJSON { res in
                if let data = res.data{
                    let json = JSON(data)
                    print("サーバー応答: \(json)")
                }
                        
            }
        }

    func updateEmptyState() {
            if comments.isEmpty {
                CommentView.backgroundView = emptyLabel
            } else {
                CommentView.backgroundView = nil
            }
        }
    
    @IBAction func BackBtn(_ sender: Any)
        {
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
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

extension ResultViewController: ComentControllerDelegate {
    func didAddComment(_ comment: String, rating: Int, latitude: Double?, longitude: Double?) {
        let newData = CommentData(
            comment: comment,
            rating: rating,
            latitude: latitude ?? 0.0,
            longitude: longitude ?? 0.0
        )
        comments.append(newData)
        CommentView.reloadData()
        
        if let barcode = codeNumber {
            sendCommentToServer(barcode: barcode, commentData: newData)
        }
    }
}

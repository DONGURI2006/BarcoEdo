import UIKit


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
        guard let url = URL(string: "http://192.168.0.84:8080/check?barcode=\(barcode)") else {
            print("URLエラー")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("通信エラー: \(error)")
                return
            }

            guard let data = data else {
                print("データがありません")
                return
            }

            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(CheckResponse.self, from: data)

                DispatchQueue.main.async {
                    if result.exists {
                        self.productName = result.product
                        self.comments = result.comments ?? []
                        self.NameLabel.text = self.productName ?? "不明"
                    } else {
                        self.comments = []
                        self.NameLabel.text = "未登録の商品"
                    }

                    self.CommentView.reloadData()
                    self.updateEmptyState()
                    print("コメント取得成功 (\(self.comments.count)件)")
                }
            } catch {
                print("JSON解析エラー: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("レスポンス内容:\n\(jsonString)")
                }
            }
        }
        task.resume()
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
        print("コメント: \(comment) (評価: \(rating))")
        print("緯度 \(latitude ?? 0)\n経度 \(longitude ?? 0)")
        
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
    
    func sendCommentToServer(barcode: String, commentData: CommentData) {
        guard let product = productName,
              let url = URL(string: "http://192.168.0.26:8080/add") else {
            print("URLエラー")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "barcode": barcode,
            "product": product,
            "comment": commentData.comment,
            "rating": commentData.rating,
            "latitude": commentData.latitude,
            "longitude": commentData.longitude
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("JSON作成エラー: \(error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("通信エラー: \(error)")
                return
            }
            
            guard let data = data else {
                print("データがありません")
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("サーバー応答: \(responseString)")
            }
        }
        task.resume()
    }
}

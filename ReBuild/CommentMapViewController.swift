import UIKit
import Alamofire
import SwiftyJSON 


struct CommentData: Codable {
    let barcode: String
    var productName:String
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

class CommentMapViewController: UIViewController {
    
    var newComment: (comment: String, rating: Int, latitude: Double?, longitude: Double?)?
    
    @IBOutlet weak var commentContainer: UIView!
    @IBOutlet weak var mapContainer: UIView!
    
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    
    @IBOutlet weak var NewProductName: UITextField!
    
    var codeNumber: String?
    var productName: String?
    var latitude: Double?
    var longitude: Double?
    
    var comments: [CommentData] = []
    
    
    weak var resultVC: ResultViewController?
    weak var mapVC: MapViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        if let code = codeNumber {
            fetchCommentsFromServer(for: code)
        }
        
        showCommentView()
        print(comments)
        NewProductName.text = productName
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    
    func fetchCommentsFromServer(for barcode: String) {
        
        let params: [String: Any] = ["barcode": barcode]
        
        AF.request("http://192.168.0.84:8080/check",
//            "https://bunri.yusk1450.com/app-pj/barcoedo/check.php,"
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
                        
                        self.comments = commentArray.map {
                            CommentData(
                                barcode: $0["barcode"].stringValue,
                                productName: $0["product"].stringValue,
                                comment: $0["comment"].stringValue,
                                rating: $0["rating"].intValue,
                                latitude: $0["latitude"].doubleValue,
                                longitude: $0["longitude"].doubleValue
                            )
                        }
                        
                    } else {
                        self.productName = "未登録の商品"
                        self.comments = []
                    }
                    self.updateEmbeddedControllers()
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
            
            
            AF.request("http://192.168.0.84:8080/add",
//                "https://bunri.yusk1450.com/app-pj/barcoedo/add.php",
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
    
    
    func updateEmbeddedControllers() {
            resultVC?.productName = productName
            resultVC?.comments = comments
            resultVC?.CommentView.reloadData()
            
            mapVC?.productName = productName
            mapVC?.codeNumber = codeNumber
            mapVC?.commentLocations = comments.map {
                ($0.latitude, $0.longitude, $0.rating, $0.comment)
            }
            mapVC?.updateMap()

        }
    @IBAction func CameraBackBtn(_ sender: Any)
        {
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    @IBAction func commentButtonTapped(_ sender: UIButton) {
        showCommentView()
    }
    
    @IBAction func mapButtonTapped(_ sender: UIButton) {
        showMapView()
    }
    
    func showCommentView() {
        commentContainer.isHidden = false
        mapContainer.isHidden = true
        commentButton.setTitleColor(.black, for: .normal)
        mapButton.setTitleColor(.lightGray, for: .normal)
    }
    
    func showMapView() {
        commentContainer.isHidden = true
        mapContainer.isHidden = false
        commentButton.setTitleColor(.lightGray, for: .normal)
        mapButton.setTitleColor(.black, for: .normal)
    }
    
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "EmbedComment",
               let result = segue.destination as? ResultViewController {
                
                resultVC = result
                
                result.codeNumber = codeNumber
                result.productName = productName
                result.comments = comments
                
                
                
            }else if segue.identifier == "EmbedMap",
                let mapv = segue.destination as? MapViewController {
                
                mapVC = mapv
                     
                mapVC?.productName = productName
                mapv.codeNumber = codeNumber
                mapv.commentLocations = comments.map  {
                    ($0.latitude, $0.longitude, $0.rating, $0.comment)
                }
            }

        }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

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
    
    @IBOutlet weak var NewProductName: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    
    private let commentUnderline = UIView()
    private let mapUnderline = UIView()

    
    var codeNumber: String?
    var productName: String?
    var latitude: Double?
    var longitude: Double?
    
    var comments: [CommentData] = []
    
    
    weak var resultVC: ResultViewController?
    weak var mapVC: MapViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(productName)
        
        
        if let code = codeNumber {
            fetchCommentsFromServer(for: code)
        }
        
        showCommentView()
        setupUnderlineViews()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    
    func fetchCommentsFromServer(for barcode: String) {
        
        let params: [String: Any] = ["barcode": barcode]
        
        AF.request("https://bunri.yusk1450.com/app-pj/barcoedo/check.php",
                   method: .get,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: nil)
        
        
        .responseJSON { res in
            
            if let data = res.data{
                let json = JSON(data)
                print("サーバー応答: \(json)")
                print("ok")
                
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
    func sendCommentToServer(barcode: String, product : String, commentData: CommentData) {
            
            let params: [String: Any] = [
                "barcode": barcode,
                "product": product,
                "comment": commentData.comment,
                "rating": commentData.rating,
                "latitude": commentData.latitude,
                "longitude": commentData.longitude
            ]
            
            print("送信パラメータ:", params)
            
            AF.request("https://bunri.yusk1450.com/app-pj/barcoedo/add.php",
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
        
            NewProductName.text = productName
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
    
    func setupUnderlineViews() {
        
            let selectedColor = UIColor(red: 115/255, green: 173/255, blue: 57/255, alpha: 1.0)

            [commentUnderline, mapUnderline].forEach {
                $0.backgroundColor = selectedColor
                $0.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview($0)
            }

            NSLayoutConstraint.activate([
                commentUnderline.heightAnchor.constraint(equalToConstant: 3),
                commentUnderline.bottomAnchor.constraint(equalTo: commentButton.bottomAnchor, constant: 0),
                commentUnderline.leadingAnchor.constraint(equalTo: commentButton.leadingAnchor),
                commentUnderline.trailingAnchor.constraint(equalTo: commentButton.trailingAnchor),

                mapUnderline.heightAnchor.constraint(equalToConstant: 3),
                mapUnderline.bottomAnchor.constraint(equalTo: mapButton.bottomAnchor, constant: 0),
                mapUnderline.leadingAnchor.constraint(equalTo: mapButton.leadingAnchor),
                mapUnderline.trailingAnchor.constraint(equalTo: mapButton.trailingAnchor),
            ])
        }

        func showCommentView() {
            let selectedColor = UIColor(red: 115/255, green: 173/255, blue: 57/255, alpha: 1.0)
            let graycolor = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1.0)
            commentContainer.isHidden = false
            mapContainer.isHidden = true

            commentButton.setTitleColor(selectedColor, for: .normal)
            mapButton.setTitleColor(graycolor, for: .normal)

            commentUnderline.isHidden = false
            mapUnderline.isHidden = true
        }

        func showMapView() {
            let selectedColor = UIColor(red: 115/255, green: 173/255, blue: 57/255, alpha: 1.0)
            let graycolor = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1.0)
            commentContainer.isHidden = true
            mapContainer.isHidden = false

            commentButton.setTitleColor(graycolor, for: .normal)
            mapButton.setTitleColor(selectedColor, for: .normal)

            commentUnderline.isHidden = true
            mapUnderline.isHidden = false
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

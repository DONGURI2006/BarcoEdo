//
//  ComentController.swift
//  ReBuild
//
//  Created by 平井　登惟 on 2025/10/28.
//
import UIKit
import CoreLocation

protocol ComentControllerDelegate: AnyObject {
    func didAddComment(comment: String, rating: Int, latitude: Double?, longitude: Double?)
}

class ComentController: UIViewController,UITextFieldDelegate, CLLocationManagerDelegate{
    @IBOutlet weak var valuBtn1: UIButton!
    @IBOutlet weak var valuBtn2: UIButton!
    @IBOutlet weak var valuBtn3: UIButton!
    @IBOutlet weak var valuBtn4: UIButton!
    
    var selectedRating: Int? = nil
    
    var codeNumber: String?
    var productName: String?
    
    
    //GPSの管理
    let locationManager = CLLocationManager()
    //現在地(緯度経度）の変数
    var currentLocation: CLLocationCoordinate2D?
    
    //位置情報のセットアップ
    func setupLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last?.coordinate
    }
    
    @IBOutlet weak var textField: UITextView!
    weak var delegate: ComentControllerDelegate?
    
    @IBAction func BackBtn(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func AddBtn(_ sender: Any)
    {
        guard let rating = selectedRating else {
            let alert = UIAlertController(title: "評価を選んでください", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // コメント内容と位置情報を取得
            let commentText = textField.text ?? ""
            let latitude = currentLocation?.latitude ?? 0.0
            let longitude = currentLocation?.longitude ?? 0.0
            let code = codeNumber ?? ""
            let product = productName ?? ""
            
            print(codeNumber)
            print(productName)
        
                let newComment = CommentData(
                    barcode: code,
                    productName: product,
                    comment: commentText,
                    rating: rating,
                    latitude: latitude,
                    longitude: longitude
                )
        
            // Storyboardから CommentMapViewController を生成
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let mapVC = storyboard.instantiateViewController(withIdentifier: "CommentMapViewController") as? CommentMapViewController {
                
                mapVC.codeNumber = code
                mapVC.productName = product
                mapVC.comments.append(newComment)          // 新しいコメントを配列に追加
                mapVC.sendCommentToServer(barcode: code, commentData: newComment) // サーバー送信

                if let nav = navigationController {
                nav.pushViewController(mapVC, animated: true)
                } else {
                    present(mapVC, animated: true)
                }
            }
    }
    
    
    @IBAction func valueBtn(_ sender: UIButton) {
            // 押されたボタンを識別（タグで設定する想定）
            selectedRating = sender.tag
            
            // すべてのボタンを配列化して不透明度を変更
            let allButtons = [valuBtn1, valuBtn2, valuBtn3, valuBtn4]
                for (index, button) in allButtons.enumerated() {
                    guard let button = button else { continue }
                        // 拡大するボタンかどうかを判定
                        let isSelected = (index == selectedRating)
                        UIView.animate(withDuration: 0.2) {
                            // 1.25倍に拡大する
                            button.transform = isSelected ? CGAffineTransform(scaleX: 1.25, y: 1.25) : .identity
                        }
                }
        }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 1.0
        textField.clipsToBounds = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
            
            setupLocation()
            print("barcode: \(codeNumber ?? "nil")")
            print("productName: \(productName ?? "nil")")
        }
    
    

        @objc func dismissKeyboard() {
            view.endEditing(true)
        }
        

    }


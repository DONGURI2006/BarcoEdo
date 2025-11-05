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

class ComentController: UIViewController,UITextFieldDelegate, CLLocationManagerDelegate, UITextViewDelegate{
    @IBOutlet weak var valuBtn1: UIButton!
    @IBOutlet weak var valuBtn2: UIButton!
    @IBOutlet weak var valuBtn3: UIButton!
    @IBOutlet weak var valuBtn4: UIButton!
    
    @IBOutlet weak var GoResult: UIButton!
    @IBOutlet weak var TextCountLabel: UILabel!
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
    func textViewDidChange(_ textView: UITextView) {
            // 現在の文字数を取得
            let inputLength = textView.text.count
            
            TextCountLabel.text = "\(MaxcomentCount - inputLength)/\(MaxcomentCount)"
            
        }
    
    @IBOutlet weak var textField: UITextView!
    
    var MaxcomentCount:Int = 220
    
    
    weak var delegate: ComentControllerDelegate?
    
    @IBAction func BackBtn(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func GoResultBtn(_ sender: Any) {
        // バーコードと商品名を取得
        let code = codeNumber ?? ""
        let product = productName ?? ""
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mapVC = storyboard.instantiateViewController(withIdentifier: "CommentMapViewController") as? CommentMapViewController {
            
            mapVC.codeNumber = code
            mapVC.productName = product
            
            if let nav = navigationController {
                nav.pushViewController(mapVC, animated: true)
            } else {
                present(mapVC, animated: true)
            }
        }
    }

    @IBAction func AddBtn(_ sender: Any)
    {
        if let textCount = textField.text {
            let inputLength: Int = textCount.count
            print(inputLength)
            if(inputLength > MaxcomentCount){
                let alert = UIAlertController(title: "文字数が多すぎます", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
                return
            }
        }
        
        if let textCount = textField.text {
            let inputLength: Int = textCount.count
            print(inputLength)
            if(inputLength == 0){
                let alert = UIAlertController(title: "コメントを入力してください", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
                return
            }
        }
        
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
                mapVC.comments.append(newComment)
                mapVC.sendCommentToServer(barcode: code, commentData: newComment)

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
            
            let buttonColors: [UIColor] = [
                UIColor(red: 64, green: 140, blue: 82, alpha: 0.5),// valuBtn1
                UIColor(red: 115, green: 173, blue: 57, alpha: 0.5),// valuBtn2
                UIColor(red: 209, green: 124, blue: 45, alpha: 0.5),// valuBtn3
                UIColor(red: 169, green: 44, blue: 25, alpha: 0.5),// valuBtn4
            ]

            // すべてのボタンを配列化して不透明度を変更
            let allButtons = [valuBtn1, valuBtn2, valuBtn3, valuBtn4]
                for (index, button) in allButtons.enumerated() {
                    guard let button = button else { continue }
                    // 拡大するボタンかどうかを判定
                    let isSelected = (index == selectedRating)
                    UIView.animate(withDuration: 0.2) {
                    // 1.25倍に拡大する
                button.transform = isSelected ? CGAffineTransform(scaleX: 1.25, y: 1.25) : .identity
                if isSelected {
                    button.tintColor = buttonColors[index]
                } else {
                    button.tintColor = .label  // そのままにする
                }
            }
            }

        }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let textCount = textField.text {
            let inputLength: Int = textCount.count
            TextCountLabel.text = "\(MaxcomentCount - inputLength)/\(MaxcomentCount)"
        }
        
        
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 1.0
        textField.clipsToBounds = true
        textField.delegate = self
        
        
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


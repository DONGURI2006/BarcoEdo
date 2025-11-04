import UIKit
import Alamofire
import SwiftyJSON

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var ProducttextCount: UILabel!
    @IBOutlet weak var productNameField: UITextField!

    var barcode: String?
    var MaxCountText:Int = 25

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let textCount = productNameField.text {
            let inputLength: Int = textCount.count
            ProducttextCount.text = "\(MaxCountText - inputLength)/\(MaxCountText)"
        }
        
        productNameField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        
        let code = barcode ?? "未設定バーコード"
        let name = productNameField.text?.isEmpty == false ? productNameField.text! : "不明な商品"

        print("保存: \(code) = \(name)")
        
        registerProductToServer(barcode: code, productName: name)
    }
    
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else
            { return true }
            let textCount = currentText.replacingCharacters(in: stringRange, with: string)
            
            let inputLength = textCount.count
            ProducttextCount.text = "\(MaxCountText - inputLength)/\(MaxCountText)"
            
            return inputLength <= MaxCountText
        }
    
    func registerProductToServer(barcode: String, productName: String) {
        
            let params: [String: Any] = [
                "barcode": barcode,
                "product": productName
            ]
            
            AF.request("https://bunri.yusk1450.com/app-pj/barcoedo/add.php",
                       method: .post,
                       parameters: params,
                       encoding: JSONEncoding.default,
                       headers: nil)
        
            .responseJSON { res in
                
                if let data = res.data
                {
                    let json = JSON(data)
                    print("サーバー応答: \(json)")
                    
                    DispatchQueue.main.async {
                        self.showResultView(barcode: barcode, productName: productName)
                    }
                }
                   
                    
            }
        }
    
    func showResultView(barcode: String, productName: String) {
        if let storyboard = storyboard,
               let commentVC = storyboard.instantiateViewController(withIdentifier: "ComentController") as? ComentController {
                
                commentVC.codeNumber = barcode
                commentVC.productName = productName
            
                
                if let nav = navigationController {
                    nav.pushViewController(commentVC, animated: true)
                } else {
                    present(commentVC, animated: true)
                }
            }
        }

    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "入力エラー", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @IBAction func BackBtn(_ sender: Any)
    {
        self.dismiss(animated: true , completion: nil)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true) // ← これでキーボード閉じる！
    }
    
}

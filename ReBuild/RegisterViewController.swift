import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var productNameField: UITextField!

    var barcode: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let code = barcode,
              let name = productNameField.text,
              !name.isEmpty 
        
        else {
            showAlert("商品名を入力してください。")
            return
        }

        print("保存: \(code) = \(name)")
        
        registerProductToServer(barcode: code, productName: name)
    }
    
    func registerProductToServer(barcode: String, productName: String) {
            guard let url = URL(string: "http://192.168.0.26:8080/add") else {
                print("URLエラー")
                return
            }
            let jsonData: [String: Any] = [
                "barcode": barcode,
                "product": productName,
                "comment": "",
                "rating": 0,
                "latitude": 0.0,
                "longitude": 0.0
            ]

            //JSONに変換
            guard let httpBody = try? JSONSerialization.data(withJSONObject: jsonData) else {
                print("JSON変換エラー")
                return
            }

            // POSTリクエスト設定
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = httpBody

            // サーバーへ送信
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("通信エラー: \(error)")
                    return
                }

                guard let data = data else {
                    print("データなし")
                    return
                }

                // サーバーのレスポンス確認
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("サーバー応答: \(json)")
                }

                // 登録完了後に画面を閉じる（メインスレッドで）
                DispatchQueue.main.async {
                    self.showResultView(barcode: barcode, productName: productName)
                }
            }
            task.resume()
        }
    func showResultView(barcode: String, productName: String) {
            if let storyboard = storyboard,
               let resultVC = storyboard.instantiateViewController(withIdentifier: "ResultViewController") as? ResultViewController {
                
                resultVC.codeNumber = barcode
                resultVC.productName = productName
                
                // 商品登録直後なのでコメントは空
                resultVC.comments = []
                
                // 画面遷移
                if let nav = navigationController {
                    nav.pushViewController(resultVC, animated: true)
                } else {
                    present(resultVC, animated: true)
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

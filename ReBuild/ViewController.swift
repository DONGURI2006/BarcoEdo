import UIKit
import AVFoundation
import CoreLocation
import Alamofire
import SwiftyJSON

struct postdata: Codable {
    let barcode:Int
    
}

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var previewView: UIView!
    
    //カメラ映像の取得とバーコード認識
    var captureSession: AVCaptureSession!
    //カメラ映像を画面に表示する
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var products: [String: String] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        //カメラ
        setupCamera()
    }

    func setupCamera() {
        captureSession = AVCaptureSession()

        //iPhoneのカメラデバイスを取得
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video)
        else {
            showErrorAlert("カメラが見つからない")
            print("カメラが見つからない")
            return
        }
        //カメラからの映像を「入力」としてセッションに追加する
        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice)
        else {
            showErrorAlert("カメラ入力を取得できない")
            print("カメラ入力を取得できない")
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            showErrorAlert("入力を追加できない。")
            print("入力を追加できない。")
            return
        }
        //出力の設定
        let Output = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(Output) {
            captureSession.addOutput(Output)
            Output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            //認識対象のバーコードタイプを登録する
            Output.metadataObjectTypes = [.ean8, .ean13]
        } else {
            showErrorAlert("出力を追加できない")
            print("出力を追加できない")
            return
        }
        //映像をpreviewViewの画面に出す
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = previewView.bounds
        previewView.layer.addSublayer(previewLayer)
        
        //撮影を開始する
        captureSession.startRunning()
    }
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {

        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let barcodeValue = metadataObject.stringValue else { return }

        captureSession.stopRunning()
        print("バーコード読み取り: \(barcodeValue)")

        checkBarcodeOnServer(barcodeValue)
    }

    func checkBarcodeOnServer(_ barcode: String) {
            let params: [String: Any] = ["barcode": String(barcode)]
            
            AF.request("http://192.168.0.84:8080/check",
//                "https://bunri.yusk1450.com/app-pj/barcoedo/check.php",
                       method: .post,
                       parameters: params,
                       encoding: JSONEncoding.default,
                       headers: nil)
        
            .responseJSON { res in
                
                if let data = res.data{
                    
                    let json = JSON(data)
                    print("サーバー応答: \(json)")
                    
                    let exists = json["exists"].boolValue
                    let productName = json["product"].stringValue
                    
                    DispatchQueue.main.async {
                        if exists {
                            
                            let dataToSend: [String: Any] = [
                                "code": barcode,
                                "productName": productName
                            ]
                            
                            print("登録済み: \(productName)")
                            self.performSegue(withIdentifier: "GoResult", sender: dataToSend)
                        } else {
                            print("未登録バーコード: \(barcode)")
                            self.NewBarcode(barcode)
                        }
                    }
                }
            }
        }
    
func NewBarcode(_ barcode: String) {
    let params: [String: Any] = [
        "barcode": barcode,
        "product": ""
    ]
    AF.request("http://192.168.0.84:8080/check",
//        "https://bunri.yusk1450.com/app-pj/barcoedo/add.php",
                method: .post,
                parameters: params,
                encoding: JSONEncoding.default,
                headers: nil)
        
        .responseJSON { res in
                
            if let data = res.data{
                    
                _ = JSON(data)
                    
                DispatchQueue.main.async {
                    
                    let dataToSend: [String: Any] = [
                        "code": barcode,
                        "productName": ""
                    ]
                    self.performSegue(withIdentifier: "GoResult", sender: dataToSend)
                }
            }
        }
    }
    
    //画面遷移
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoResult",
            let destination = segue.destination as? ComentController,
            let data = sender as? [String: Any] {
            destination.codeNumber = data["code"] as? String
            destination.productName = data["productName"] as? String
        }
    }

    //カメラが見つからないときはポップアップで表示
    func showErrorAlert(_ message: String) {
        let alert = UIAlertController(title: "エラー", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    //カメラが画面に戻ったり閉じたりするときに停止させる
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = previewView.bounds
    }
    //画面サイズが変わったら調整
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // カメラを再開
        if let session = captureSession, !session.isRunning {
            session.startRunning()
        }
    }

    
}

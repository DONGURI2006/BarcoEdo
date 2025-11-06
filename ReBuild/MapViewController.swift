import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate/*, UICollectionViewDataSource*/{
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        <#code#>
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        <#code#>
//    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var OnOffBtn: UIButton!
    
    var codeNumber: String?
    var productName: String?
    
    var commentLocations: [(latitude: Double, longitude: Double, rating:Int, text:String)] = []
    
    var isCircle: Bool = true {
            didSet {
                updateButtonTitle()
                updateMap()
            }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("こここ\(commentLocations)")
        mapView.delegate = self
        
        guard !commentLocations.isEmpty else { return }
        
        // 最初のコメント地点を中心にマップ表示
        let first = commentLocations[0]
        let center = CLLocationCoordinate2D(latitude: first.latitude, longitude: first.longitude)
        let region = MKCoordinateRegion(center: center, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
        
        // 各コメント地点に図形を描画
        for loc in commentLocations {
            //それぞれの緯度経度をcoordinateに
            let coordinate = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
            //追加するごとにMapOverlayを
            let overlay = MapOverlay(center: coordinate, rating: loc.rating)
            mapView.addOverlay(overlay)
        }
    }
    
    func updateButtonTitle() {
        //ボタンの設定
        var config = UIButton.Configuration.plain()
        config.imagePadding = 4//画像と文字の余白
        config.imagePlacement = .top//画像の位置
        
        //画像、名前の設定
        let title = isCircle ? "丸" : "四角"
        let imageName = isCircle ? "Ellipse1" : "Script1"
        config.image = UIImage(named: imageName)


        var attributedTitle = AttributedString(title)
        attributedTitle.font = UIFont(name: "LINE Seed JP App_OTF Regular", size: 8)
        config.attributedTitle = attributedTitle

        OnOffBtn.configuration = config
     }

    func updateMap() {
        guard !commentLocations.isEmpty else {
            return
        }
        
        mapView.removeOverlays(mapView.overlays)
        
        let first = commentLocations[0]
        let center = CLLocationCoordinate2D(latitude: first.latitude, longitude: first.longitude)
        let region = MKCoordinateRegion(center: center, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
        
        for loc in commentLocations {
            let coordinate = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
            let overlay = MapOverlay(center: coordinate, rating: loc.rating)
            mapView.addOverlay(overlay)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let heatmap = overlay as? MapOverlay {
                let renderer = MapOverlayRenderer(overlay: heatmap)
                renderer.isCircle = isCircle
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    
    @IBAction func OnOffBtnTapped(_ sender: UIButton) {
            isCircle.toggle()
        }
    
}

//どこに,どれくらいの範囲に図形を貼るのか
class MapOverlay: NSObject, MKOverlay {
    var coordinate: CLLocationCoordinate2D
    var boundingMapRect: MKMapRect
    var rating: Int
    
    init(center: CLLocationCoordinate2D, rating: Int) {
        self.coordinate = center
        self.rating = rating
        let mapPoint = MKMapPoint(center)
        let rectSize: Double = 3000
        self.boundingMapRect = MKMapRect(
            x: mapPoint.x - rectSize / 2,
            y: mapPoint.y - rectSize / 2,
            width: rectSize,
            height: rectSize
        )
    }
}

//どんな図形を描くか
class MapOverlayRenderer: MKOverlayRenderer {
    
    var isCircle: Bool = true
    
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        
        guard let overlay = overlay as? MapOverlay else { return }
        
        let mapPoint = MKMapPoint(overlay.coordinate)
        let point = self.point(for: mapPoint)
        
        let radius: CGFloat = 1000.0
        let circleRect = CGRect(
            x: point.x - radius,
            y: point.y - radius,
            width: radius * 2,
            height: radius * 2
        )
        
        //色分け
        let fillColor: UIColor
        switch overlay.rating {
        case 0:
            fillColor = UIColor.green.withAlphaComponent(0.5)
        case 1:
            fillColor = UIColor.systemGreen.withAlphaComponent(0.5)
        case 2:
            fillColor = UIColor.orange.withAlphaComponent(0.5)
        case 3:
            fillColor = UIColor.red.withAlphaComponent(0.5)
        default:
            fillColor = UIColor.gray.withAlphaComponent(0.5)
        }
        //描画領域内なら塗りつぶしをする
        let expandedRect = circleRect.insetBy(dx: -radius, dy: -radius)
        if context.boundingBoxOfClipPath.intersects(expandedRect) {
            context.setFillColor(fillColor.cgColor)
            
            if isCircle {
                //円
                context.fillEllipse(in: circleRect)
            } else {
                //四角
                context.fill(circleRect)
            }
            
        }

    }
}


import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var OnOffBtn: UIButton!
    @IBOutlet weak var ProductName: UILabel!
    
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
        ProductName.text = productName
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
        let title = isCircle ? "丸" : "四角"
        OnOffBtn.setTitle(title, for: .normal)
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
    
    @IBAction func CameraBackBtn(_ sender: Any)
        {
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
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


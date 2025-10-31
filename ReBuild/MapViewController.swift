import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    var codeNumber: String?
    
    var commentLocations: [(latitude: Double, longitude: Double, rating:Int, text:String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(commentLocations)
        mapView.delegate = self
        
        
        guard !commentLocations.isEmpty else { return }
        
        // 最初のコメント地点を中心にマップ表示
        let first = commentLocations[0]
        let center = CLLocationCoordinate2D(latitude: first.latitude, longitude: first.longitude)
        let region = MKCoordinateRegion(center: center, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
        
        // 各コメント地点にピンを立てる
        for loc in commentLocations {
            let coordinate = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
        let pin = RatingAnnotation(coordinate: coordinate, title: "コメント：\(loc.text)", rating: loc.rating)
            mapView.addAnnotation(pin)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let ratingAnnotation = annotation as? RatingAnnotation else {
                return nil
            }
            
            let identifier = "RatingPin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }
            
            switch ratingAnnotation.rating {
            case 0:
                annotationView?.image = UIImage(named: "FaceIcon2 1")
            case 1:
                annotationView?.image = UIImage(named: "FaceIcon2 2")
            case 2:
                annotationView?.image = UIImage(named: "FaceIcon2 3")
            case 3:
                annotationView?.image = UIImage(named: "FaceIcon2 4")
            default:
                annotationView?.image = UIImage(named: "pin_default")
            }
            
            return annotationView
        }
    
    @IBAction func BackBtn(_ sender: Any) {
        self.dismiss(animated: true , completion: nil)
    }
    
}

class RatingAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let rating: Int
    
    init(coordinate: CLLocationCoordinate2D, title: String?, rating: Int) {
        self.coordinate = coordinate
        self.title = title
        self.rating = rating
    }
}

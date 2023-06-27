//
//  BarCardCollectionViewCell.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/29.
//

import UIKit
import CoreLocation

class BarCardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var placeDistanceLabel: UILabel!
    @IBOutlet weak var placeAddressLabel: UILabel!
    @IBOutlet weak var placeRatingOpenHourLabel: UILabel!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var directionButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.masksToBounds = false
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 0.3)
        layer.shadowRadius = 4
        layer.cornerRadius = 5
        directionButton.layer.cornerRadius = 5
        saveButton.layer.cornerRadius = 5
        imageView.layer.cornerRadius = 5
    }
    
    func updateCell(user: User?, data: Place, userCoordinates: CLLocationCoordinate2D) {
        self.placeNameLabel.text = data.name
        self.placeAddressLabel.text = data.vicinity
        if let rating = data.rating {
            self.placeRatingOpenHourLabel.text = rating > 0 ? "\(rating) Stars" : "No ratings"
        }
        
        if let photoRef = data.photos?.first?.photoReference,
           let height = data.photos?.first?.height,
           let width = data.photos?.first?.width {
            let string = "https://maps.googleapis.com/maps/api/place/photo?photo_reference=\(photoRef)&maxwidth=\(width)&maxheight=\(height)&key=\(GMSPlacesAPIKey)"
            self.imageView.kf.setImage(with: URL(string: string))
        }
        
        if let barLatitude = data.geometry?.location.lat,
           let barLongitude = data.geometry?.location.lng {
            let distance = calculateDistance(
                lat1: userCoordinates.latitude,
                lon1: userCoordinates.longitude,
                lat2: barLatitude,
                lon2: barLongitude
            )
            self.placeDistanceLabel.text = "\(distance) km away"
        }
        
        if let placeId = data.placeID,
           let bool = user?.favoritePlaces.contains(where: { $0.placeID == placeId }) {
            self.saveButton.imageView?.image = bool ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        }
    }
    
    func calculateDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let coordinate1 = CLLocation(latitude: lat1, longitude: lon1)
        let coordinate2 = CLLocation(latitude: lat2, longitude: lon2)
        let distanceInMeters = coordinate1.distance(from: coordinate2)
        let distanceInKilometers = distanceInMeters / 1000.0
        let roundedDistance = (distanceInKilometers * 100).rounded() / 100
        return roundedDistance
    }
    
}

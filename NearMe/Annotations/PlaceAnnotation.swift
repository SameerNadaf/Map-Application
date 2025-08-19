//
//  PlaceAnnotation.swift
//  NearMe
//
//  Created by Sameer  on 19/08/25.
//

import Foundation
import MapKit

class PlaceAnnotation: MKPointAnnotation {
    
    let mapItem: MKMapItem
    let id = UUID()
    var isSelected: Bool = false
    
    init(mapItem: MKMapItem) {
        self.mapItem = mapItem
        super.init()
        self.coordinate = mapItem.placemark.coordinate
    }
    
    var name: String {
        mapItem.name ?? ""
    }
    
    var phone: String {
        mapItem.phoneNumber ?? ""
    }
    
    var address: String {
        let placemark = mapItem.placemark
        // More structured formatting
        var parts: [String] = []
        if let street = placemark.thoroughfare { parts.append(street) }
        if let city = placemark.locality { parts.append(city) }
        if let state = placemark.administrativeArea { parts.append(state) }
        if let postal = placemark.postalCode { parts.append(postal) }
        return parts.joined(separator: ", ")
    }
    
    var category: String {
        guard let poiCategory = mapItem.pointOfInterestCategory else {
            return "Other"
        }
        
        switch poiCategory {
        case .cafe:
            return "Cafe"
        case .restaurant:
            return "Restaurant"
        case .hotel:
            return "Hotel"
        case .bank:
            return "Bank"
        case .atm:
            return "ATM"
        case .hospital:
            return "Hospital"
        case .school:
            return "School"
        case .store:
            return "Store"
        case .university:
            return "University"
        case .park:
            return "Park"
        case .gasStation:
            return "Gas Station"
        // add more categories as needed...
        default:
            // fallback → nicely formatted rawValue
            let raw = poiCategory.rawValue
            if let last = raw.components(separatedBy: ".").last {
                return last.replacingOccurrences(of: "Mkpoi", with: "")
                            .replacingOccurrences(of: "Category", with: "")
                            .replacingOccurrences(of: "_", with: " ")
                            .capitalized
            }
            return raw
        }
    }

    
    // Placeholder for now — MapKit doesn’t expose business hours directly
    var openingHours: String {
        return "No hours available"
    }
    
    var location: CLLocation {
        mapItem.placemark.location ?? CLLocation(latitude: 0, longitude: 0)
    }
}

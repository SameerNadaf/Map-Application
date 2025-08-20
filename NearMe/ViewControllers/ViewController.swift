//
//  ViewController.swift
//  NearMe
//
//  Created by Sameer  on 19/08/25.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    var locationManager: CLLocationManager?
    private var places: [PlaceAnnotation] = []
    
    lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.delegate = self
        map.showsUserLocation = true
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 20
        textField.clipsToBounds = false
        textField.placeholder = "Search nearby places..."
        textField.delegate = self
        textField.backgroundColor = UIColor.white
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: 0))
        textField.leftViewMode = .always
        textField.clearButtonMode = .always
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowOpacity = 0.25
        textField.layer.shadowOffset = CGSize(width: 0, height: 4)
        textField.layer.shadowRadius = 6
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let recenterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "location.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 28
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let directionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.triangle.turn.up.right.diamond.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 28
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let mapModeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "map"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemPurple
        button.layer.cornerRadius = 28
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestLocation()
        
        setupUI()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)  // hides keyboard and cursor
    }

}

extension ViewController {
    
    private func setupUI() {
        setupMapView()
        searchFieldView()
        setupFloatingButtons()
    }
    
    private func setupMapView() {
        view.addSubview(mapView)
        mapView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        mapView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mapView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    private func searchFieldView() {
        view.addSubview(searchTextField)
        searchTextField.heightAnchor.constraint(equalToConstant: 55).isActive = true
        searchTextField.widthAnchor.constraint(equalToConstant: view.bounds.size.width/1.1).isActive = true
        searchTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        searchTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 65).isActive = true
        searchTextField.returnKeyType = .go
    }
    
    private func setupFloatingButtons() {
        view.addSubview(recenterButton)
        view.addSubview(directionsButton)
        view.addSubview(mapModeButton)
        
        NSLayoutConstraint.activate([
            // Recenter button
            recenterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            recenterButton.bottomAnchor.constraint(equalTo: view.topAnchor,
                                                           constant: view.bounds.height * 0.75),
            recenterButton.widthAnchor.constraint(equalToConstant: 56),
            recenterButton.heightAnchor.constraint(equalToConstant: 56),
            
            // Directions button BELOW recenter button
            directionsButton.trailingAnchor.constraint(equalTo: recenterButton.trailingAnchor),
            directionsButton.topAnchor.constraint(equalTo: recenterButton.bottomAnchor, constant: 30),
            directionsButton.widthAnchor.constraint(equalToConstant: 56),
            directionsButton.heightAnchor.constraint(equalToConstant: 56),
            
            // Map Mode button AT TOP TRAILING
            mapModeButton.trailingAnchor.constraint(equalTo: recenterButton.trailingAnchor),
            mapModeButton.bottomAnchor.constraint(equalTo: recenterButton.topAnchor, constant: -30),
            mapModeButton.widthAnchor.constraint(equalToConstant: 56),
            mapModeButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        // Actions
        recenterButton.addTarget(self, action: #selector(recenterMap), for: .touchUpInside)
        directionsButton.addTarget(self, action: #selector(openDirections), for: .touchUpInside)
        mapModeButton.addTarget(self, action: #selector(toggleMapMode), for: .touchUpInside)
    }
}

extension ViewController {
    private func checkLocationAuthorization() {
        guard let locationManager = locationManager,
              let location = locationManager.location else { return }
        
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways :
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 750, longitudinalMeters: 750)
            mapView.setRegion(region, animated: true)
        case .denied :
            print("Location services has been denied")
        case .notDetermined, .restricted :
            print("Cannot determine location or restricted")
        @unknown default:
            print("Unknown error occurred")
        }
    }
    
    private func presentPlacesSheet(places: [PlaceAnnotation]) {
        guard let locationManager = locationManager,
              let location = locationManager.location,
              let text = searchTextField.text else { return }
        
        let placesTableVC = PlacesTableViewController(userLocation: location, places: places, headerLabelText: text)
        placesTableVC.modalPresentationStyle = .pageSheet
        
        if let sheet = placesTableVC.sheetPresentationController {
            sheet.prefersGrabberVisible = true
            sheet.detents = [.medium(), .large()]
            present(placesTableVC, animated: true)
        }
    }
    
    private func findNearbyPlaces(by query: String) {
        mapView.removeAnnotations(mapView.annotations)
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start {[weak self] response, error in
            guard let response = response, error == nil else { return }
            print(response.mapItems)
            self?.places = response.mapItems.map(PlaceAnnotation.init)
            self?.places.forEach { place in
                self?.mapView.addAnnotation(place)
            }
            if let places = self?.places {
                self?.presentPlacesSheet(places: places)
            }
        }
    }
}

extension ViewController {
    @objc private func recenterMap() {
        guard let location = locationManager?.location else { return }
        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: 750,
                                        longitudinalMeters: 750)
        mapView.setRegion(region, animated: true)
    }
    
    @objc private func openDirections() {
        guard let coordinate = locationManager?.location?.coordinate
        else { return }
        guard let url = URL(string: "https://maps.apple.com/?daddr=\(coordinate.latitude),\(coordinate.longitude)") else { return }
        UIApplication.shared.open(url)
    }
    
    @objc private func toggleMapMode() {
        switch mapView.mapType {
        case .standard:
            mapView.mapType = .satellite
        case .satellite:
            mapView.mapType = .hybrid
        case .hybrid:
            mapView.mapType = .mutedStandard
        default:
            mapView.mapType = .standard
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}

extension ViewController: MKMapViewDelegate {
    
    private func clearAllSelections() {
        self.places = self.places.map { place in
            place.isSelected = false
            return place
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect annotation: any MKAnnotation) {
        // Clear all selected places befor selecting new one
        clearAllSelections()
        
        // Select place
        guard let selectedAnnotation = annotation as? PlaceAnnotation else { return }
        let placeAnnotation = self.places.first(where: { $0.id == selectedAnnotation.id })
        
        placeAnnotation?.isSelected = true
        presentPlacesSheet(places: self.places)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let text = textField.text ?? ""
        if !text.isEmpty {
            textField.resignFirstResponder()
            findNearbyPlaces(by: text)
        }
        return true
    }
}

#Preview {
    ViewController()
}

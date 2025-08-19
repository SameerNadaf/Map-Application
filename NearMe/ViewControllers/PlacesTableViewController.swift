//
//  PlacesTableViewController.swift
//  NearMe
//
//  Created by Sameer  on 19/08/25.
//

import UIKit
import MapKit

class PlacesTableViewController: UITableViewController {
    var userLocation: CLLocation
    var places: [PlaceAnnotation]
    var headerLabelText: String
    
    init(userLocation: CLLocation, places: [PlaceAnnotation], headerLabelText: String) {
        self.userLocation = userLocation
        self.places = places
        self.headerLabelText = headerLabelText
        super.init(nibName: nil, bundle: nil)
        tableView.register(PlaceTableViewCell.self, forCellReuseIdentifier: "PlaceCell")
        self.places.swapAt(indexOfSelectedPlace ?? 0, 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeaderView()
    }

    private func setupHeaderView() {
        let headerLabel = UILabel()
        headerLabel.text = headerLabelText
        headerLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        headerLabel.textAlignment = .left
        headerLabel.textColor = .label
        headerLabel.numberOfLines = 0
        
        // Wrap inside a container view
        let containerView = UIView()
        containerView.addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 22),
            headerLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            headerLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
        
        containerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 70)
        tableView.tableHeaderView = containerView
    }

    
    private var indexOfSelectedPlace: Int? {
        self.places.firstIndex(where: {$0.isSelected == true})
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        places.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as? PlaceTableViewCell else {
            return UITableViewCell()
        }
        let place = places[indexPath.row]
        cell.configure(with: place, userLocation: userLocation)
        cell.backgroundColor = place.isSelected ? .lightGray.withAlphaComponent(0.2) : .clear
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = places[indexPath.row]
        let placeDetailVC = PlaceDetailViewController(place: place)
        placeDetailVC.modalPresentationStyle = .fullScreen
        present(placeDetailVC, animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

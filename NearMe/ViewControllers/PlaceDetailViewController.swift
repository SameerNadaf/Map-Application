//
//  PlaceDetailViewController.swift
//  NearMe
//
//  Created by Sameer on 19/08/25.
//

import UIKit
import MapKit

class PlaceDetailViewController: UIViewController {
    
    let place: PlaceAnnotation
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIStackView()
    
    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        mapView.layer.cornerRadius = 12
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title1)
        label.numberOfLines = 0
        return label
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .systemBlue
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let hoursLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let directionButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: "car.fill")
        config.imagePadding = 8
        config.baseBackgroundColor = .systemBlue
        let button = UIButton(configuration: config)
        button.setTitle("Directions", for: .normal)
        return button
    }()
    
    private let callButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: "phone.fill")
        config.imagePadding = 8
        config.baseBackgroundColor = .systemGreen
        let button = UIButton(configuration: config)
        button.setTitle("Call", for: .normal)
        return button
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    init(place: PlaceAnnotation) {
        self.place = place
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigation()
        setupUI()
        configureData()
    }
    
    // MARK: - Setup UI
    private func setupNavigation() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(sharePlace)
        )
    }
    
    private func setupUI() {
        
        // Add close button first
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
        closeButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)

        // Now scrollView starts below button
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // StackView as content
        contentView.axis = .vertical
        contentView.spacing = 12
        contentView.isLayoutMarginsRelativeArrangement = true
        contentView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Add subviews
        contentView.addArrangedSubview(mapView)
        mapView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        
        contentView.addArrangedSubview(nameLabel)
        contentView.addArrangedSubview(categoryLabel)
        contentView.addArrangedSubview(distanceLabel)
        contentView.addArrangedSubview(addressLabel)
        contentView.addArrangedSubview(hoursLabel)
        
        // Buttons
        buttonStack.addArrangedSubview(directionButton)
        buttonStack.addArrangedSubview(callButton)
        contentView.addArrangedSubview(buttonStack)
        
        // Actions
        directionButton.addTarget(self, action: #selector(directionButtonTapped), for: .touchUpInside)
        callButton.addTarget(self, action: #selector(callButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Configure Data
    private func configureData() {
        // Map
        let region = MKCoordinateRegion(
            center: place.location.coordinate,
            latitudinalMeters: 500,
            longitudinalMeters: 500
        )
        mapView.setRegion(region, animated: false)
        let annotation = MKPointAnnotation()
        annotation.coordinate = place.location.coordinate
        annotation.title = place.name
        mapView.addAnnotation(annotation)
        
        // Labels
        nameLabel.text = place.name
        categoryLabel.text = place.category
        addressLabel.text = place.address
        hoursLabel.attributedText = makeIconText(systemName: "clock", text: place.openingHours)
        
        let distance = Measurement(value: place.location.distance(from: CLLocation(latitude: 12.9716, longitude: 77.5946)), unit: UnitLength.meters)
        distanceLabel.attributedText = makeIconText(systemName: "location.north", text: distance.formatted())
    }
    
    // Helper method for icon + text
    private func makeIconText(systemName: String, text: String) -> NSAttributedString {
        let attachment = NSTextAttachment()
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        attachment.image = UIImage(systemName: systemName, withConfiguration: config)?.withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal)
        
        let attributed = NSMutableAttributedString(attachment: attachment)
        attributed.append(NSAttributedString(string: " \(text)"))
        return attributed
    }
    
    // MARK: - Actions
    @objc private func directionButtonTapped() {
        let coordinate = place.location.coordinate
        guard let url = URL(string: "https://maps.apple.com/?daddr=\(coordinate.latitude),\(coordinate.longitude)") else { return }
        UIApplication.shared.open(url)
    }
    
    @objc private func callButtonTapped() {
        guard !place.phone.isEmpty,
              let url = URL(string: "tel://\(place.phone.formatPhoneForCall)") else { return }
        UIApplication.shared.open(url)
    }
    
    @objc private func sharePlace() {
        let items: [Any] = [
            place.name,
            place.address,
            place.mapItem.url ?? ""
        ]
        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(vc, animated: true)
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true)
    }
    
}


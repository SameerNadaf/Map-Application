//
//  PlaceTableViewCell.swift
//  NearMe
//
//  Created by Sameer on 19/08/25.
//

import UIKit
import CoreLocation

class PlaceTableViewCell: UITableViewCell {
    
    private let nameImageView = UIImageView()
    private let nameLabel = UILabel()
    
    private let categoryImageView = UIImageView()
    private let categoryLabel = UILabel()
    
    private let addressLabel = UILabel()
    private let phoneLabel = UILabel()
    private let distanceLabel = UILabel()
    
    private let vStack = UIStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        vStack.axis = .vertical
        vStack.spacing = 4
        vStack.alignment = .leading
        
        // Common config for icons
        [nameImageView, categoryImageView].forEach {
            $0.tintColor = .secondaryLabel
            $0.contentMode = .scaleAspectFit
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.widthAnchor.constraint(equalToConstant: 18),
                $0.heightAnchor.constraint(equalToConstant: 18)
            ])
        }
        
        // Labels styling
        nameLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        nameLabel.textColor = .label
        
        categoryLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        categoryLabel.textColor = .secondaryLabel
        
        addressLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        addressLabel.textColor = .secondaryLabel
        
        phoneLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        phoneLabel.textColor = .systemBlue
        
        distanceLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        distanceLabel.textColor = .label
        
        // HStacks for rows with icons
        let nameRow = UIStackView(arrangedSubviews: [nameImageView, nameLabel])
        nameRow.axis = .horizontal
        nameRow.spacing = 6
        nameRow.alignment = .center
        
        let categoryRow = UIStackView(arrangedSubviews: [categoryImageView, categoryLabel])
        categoryRow.axis = .horizontal
        categoryRow.spacing = 6
        categoryRow.alignment = .center
        
        // Add to main vStack
        [nameRow, categoryRow, addressLabel, phoneLabel, distanceLabel].forEach {
            vStack.addArrangedSubview($0)
        }
        
        contentView.addSubview(vStack)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            vStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            vStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            vStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with place: PlaceAnnotation, userLocation: CLLocation) {
        // Name with icon
        nameImageView.image = UIImage(systemName: "mappin.and.ellipse")?.withRenderingMode(.alwaysTemplate)
        nameImageView.tintColor = .systemRed
        nameLabel.text = place.name
        
        // Category with icon
        categoryImageView.image = UIImage(systemName: "tag.fill")?.withRenderingMode(.alwaysTemplate)
        categoryImageView.tintColor = .systemGreen
        categoryLabel.text = place.category
        
        // Address (no icon)
        addressLabel.text = place.address
        
        // Phone
        phoneLabel.text = place.phone.isEmpty ? nil : "Call: \(place.phone)"
        
        // Distance
        let distance = userLocation.distance(from: place.location)
        let distanceString = Measurement(value: distance, unit: UnitLength.meters).formatted()
        distanceLabel.text = "Distance: \(distanceString)"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//
//  CarouselCell.swift
//
//  Created by Bogdan Manshlin on 15.04.16.
//
//

import UIKit

class CarouselCell: UICollectionViewCell {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var descriptionContainer: UIView!
    
    static let poorDevices = ["iPad",
                              "iPad1,1",
                              "iPhone1,1",
                              "iPhone1,2",
                              "iPhone2,1",
                              "iPhone3,1",
                              "iPhone3,2",
                              "iPhone3,3",
                              "iPod1,1",
                              "iPod2,1",
                              "iPod2,2",
                              "iPod3,1",
                              "iPod4,1",
                              "iPad2,1",
                              "iPad2,2",
                              "iPad2,3",
                              "iPad2,4",
                              "iPad3,1",
                              "iPad3,2",
                              "iPad3,3"]
    
    var isBlurNotNeeded: Bool {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return CarouselCell.poorDevices.contains(identifier)
    }
    
    var blurView: UIView?
    var vibrancyView: UIVisualEffectView?
    var shouldShowBlur = true
    var placeholderColor: UIColor?
    var collectionTitleLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = false
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.numberOfLines = 1
        label.lineBreakMode = .byWordWrapping
        label.preferredMaxLayoutWidth = 300
        label.setContentHuggingPriority(UILayoutPriorityRequired, for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
        label.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont(name: "HelveticaNeue", size: 14)
        return label
    }()

    var dataSource: CarouselCellDataSource?
    
    func clearBlur() {
        blurView?.removeFromSuperview()
        blurView = nil
        vibrancyView = nil
    }
    
    func addBlur() {
        if isBlurNotNeeded {
            blurView = UIView()
            blurView?.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        } else {
            let blurEffect = UIBlurEffect(style: .light)
            blurView = UIVisualEffectView(effect: blurEffect)
            blurView!.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        }
        blurView!.translatesAutoresizingMaskIntoConstraints = false
        blurView!.addSubview(collectionTitleLabel)
        descriptionContainer.insertSubview(blurView!, at: 0)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: blurView!,
            attribute: .height, relatedBy: .equal, toItem: descriptionContainer,
            attribute: .height, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: blurView!,
            attribute: .width, relatedBy: .equal, toItem: descriptionContainer,
            attribute: .width, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: blurView!,
            attribute: .leading, relatedBy: .equal, toItem: descriptionContainer,
            attribute: .leading, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: blurView!,
            attribute: .top, relatedBy: .equal, toItem: descriptionContainer,
            attribute: .top, multiplier: 1, constant: 0))
        
        
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "|[title]|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["title" : collectionTitleLabel]
            ))
        
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|[title]|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["title" : collectionTitleLabel]
            ))
        
        descriptionContainer.addConstraints(constraints)
        descriptionContainer.layoutIfNeeded()
    }

    
    func configure() {
        setPlaceholder()
        dataSource?.setImage(forImageView: backgroundImage)
        if let title = dataSource?.itemTitle , title != "" && shouldShowBlur {
            collectionTitleLabel.text = title
            addBlur()
        }
    }
    
    func setPlaceholder() {
        if let color = placeholderColor {
            backgroundImage.image = UIImage.image(withColor: color)
        } else {
            backgroundImage.image = nil
        }
    }
    
        
    override func prepareForReuse() {
        super.prepareForReuse()
        clearBlur()
        setPlaceholder()
    }

}

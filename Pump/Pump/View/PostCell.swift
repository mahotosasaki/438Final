//
//  PostCell.swift
//  
//
//  Created by Mark Sigel on 12/11/20.
//

import UIKit

// Collection View for workout posts
// Used in Home page and User page
class PostCell: UICollectionViewCell {
    var titleLabel: UILabel!
    var imageView: UIImageView!
    var usernameLabel: UILabel!
    var likesLabel: UILabel!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        titleLabel = UILabel(frame: CGRect(x:0, y: 0, width: frame.size.width, height: 30))
        titleLabel.font = UIFont.boldSystemFont(ofSize: titleLabel.font.pointSize)
        contentView.addSubview(titleLabel)
        
        usernameLabel = UILabel(frame: CGRect(x:0, y: 30, width: frame.size.width, height: 20))
        usernameLabel.textColor = .systemTeal
        contentView.addSubview(usernameLabel)
        
        imageView = UIImageView(frame: CGRect(x:0, y:50, width: frame.size.width, height: 275))
        contentView.addSubview(imageView)
        
        likesLabel = UILabel(frame: CGRect(x:0, y: 325, width: frame.size.width, height: 25))
        contentView.addSubview(likesLabel)
        
    }
    required init?(coder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
}

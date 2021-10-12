//
//  GridCell.swift
//  iBook
//
//  Created by Jovins on 2021/10/8.
//

import UIKit

class GridCell: UICollectionViewCell, Reusable {
    
    override var isHighlighted: Bool {
        didSet {
            self.thumbImageView.alpha = isHighlighted ? 0.8 : 1
        }
    }
    
    var image: UIImage? {
        didSet {
            guard let img = self.image else { return }
            self.thumbImageView.image = img
        }
    }
    
    var pageNumber = 0 {
        didSet {
            pageLabel.text = String(pageNumber)
        }
    }
    
    var url: NSURL?
    
    private lazy var thumbImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var pageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = ""
        label.textColor = .gray
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .right
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        layer.cornerRadius = 8
        clipsToBounds = true
        self.neumorphism()
        
        let cellWidth: CGFloat = (UIScreen.main.bounds.width - 16 * 4)/3
        self.addSubview(self.thumbImageView)
        self.thumbImageView.frame = CGRect(x: 4, y: 4, width: cellWidth - 8, height: 132)
        self.addSubview(self.pageLabel)
        self.pageLabel.frame = CGRect(x: 16, y: 116, width: cellWidth - 24, height: 20)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.thumbImageView.image = nil
    }
}

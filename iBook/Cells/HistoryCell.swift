//
//  HistoryCell.swift
//  PDFDemo
//
//  Created by Jovins on 2021/10/7.
//

import UIKit

class HistoryCell: UITableViewCell, Reusable {
    
    var title: String? {
        didSet {
            guard let title = self.title else { return }
            self.titleLabel.text = title
        }
    }
    
    var author: String? {
        didSet {
            guard let author = self.author else { return }
            self.authorLabel.text = "作者: " + author
        }
    }
    
    var image: UIImage? {
        didSet {
            guard let img = self.image else { return }
            self.thumbImageView.image = img
        }
    }
    
    var url: NSURL?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = Device.bgColor
        selectionStyle = .none
        self.addSubview(cellBgView)
        cellBgView.frame = CGRect(x: 16, y: 8, width: UIScreen.main.bounds.width - 32, height: 120)
        cellBgView.neumorphism()
        self.cellBgView.addSubview(self.thumbImageView)
        self.thumbImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(8)
            make.size.equalTo(CGSize(width: 72, height: 120 - 16))
        }
        self.cellBgView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-26)
            make.left.equalTo(self.thumbImageView.snp.right).offset(16)
            make.width.equalTo(Device.kWidth - 160)
        }
        self.cellBgView.addSubview(self.authorLabel)
        self.authorLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(24)
            make.left.equalTo(self.thumbImageView.snp.right).offset(16)
            make.width.equalTo(Device.kWidth - 160)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.thumbImageView.image = nil
    }
    
    // MARK: - Lazy
    private lazy var thumbImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.text = ""
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .left
        return label
    }()
    
    private lazy var authorLabel: UILabel = {
        
        let label = UILabel()
        label.numberOfLines = 1
        label.text = ""
        label.textColor = .darkGray
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .left
        return label
    }()
    
    private lazy var cellBgView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
}

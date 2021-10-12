//
//  OutlineCell.swift
//  iBook
//
//  Created by Jovins on 2021/10/8.
//

import UIKit

class OutlineCell: UITableViewCell, Reusable {
    
    var titleString: String? = nil {
        didSet {
            self.titleLabel.text = titleString
        }
    }
    
    var pageString: String? = nil {
        didSet {
            self.pageLabel.text = pageString
            let width: CGFloat = pageString?.width(for: UIFont.systemFont(ofSize: 17)) ?? 36
            self.pageLabel.snp.updateConstraints { make in
                make.width.equalTo(width + 8)
            }
        }
    }
    
    override var indentationLevel: Int {
        didSet {
            self.titleLabel.snp.updateConstraints { make in
                make.left.equalToSuperview().offset(16 + 10 * indentationLevel)
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .white
        selectionStyle = .none
        
        self.addSubview(self.pageLabel)
        self.pageLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.equalTo(36)
        }
        
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(0)
            make.centerY.equalToSuperview()
            make.right.equalTo(self.pageLabel.snp.left).offset(-8)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        if indentationLevel == 0 {
            titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
            titleLabel.textColor = .black
        } else {
            titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
            titleLabel.textColor = .gray
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = ""
        label.textColor = .gray
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .left
        return label
    }()
    
    private lazy var pageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = ""
        label.textColor = .gray
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
}

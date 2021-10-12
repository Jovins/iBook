//
//  SearchCell.swift
//  iBook
//
//  Created by Jovins on 2021/10/11.
//

import UIKit

class SearchCell: UITableViewCell, Reusable {
    
    var sectionString: String? = nil {
        didSet {
            self.sectionLabel.text = sectionString
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
    
    var resultText: String? = nil
    var searchText: String? = nil
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .white
        selectionStyle = .none
        
        self.addSubview(self.pageLabel)
        self.pageLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(12)
            make.width.equalTo(36)
        }
        
        self.addSubview(self.sectionLabel)
        self.sectionLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(12)
            make.right.equalTo(self.pageLabel.snp.left).offset(-8)
        }
        
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(self.sectionLabel.snp.bottom).offset(8)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-12)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        if let result = self.resultText, let search = self.searchText {
            let highlightRange = (result as NSString).range(of: search, options: .caseInsensitive)
            let attributedString = NSMutableAttributedString(string: resultText!)
            attributedString.addAttributes([.font: UIFont.boldSystemFont(ofSize: 16), .foregroundColor: Device.tintColor], range: highlightRange)
            self.titleLabel.attributedText = attributedString
        }
    }
    
    private lazy var sectionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = ""
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .left
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.text = ""
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 16)
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

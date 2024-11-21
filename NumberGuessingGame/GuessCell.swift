import UIKit

class GuessCell: UICollectionViewCell {
    static let identifier = "GuessCell"
    
    private let digitLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        layer.cornerRadius = 8
        
        contentView.addSubview(digitLabel)
        NSLayoutConstraint.activate([
            digitLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            digitLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with digit: String, status: GuessStatus) {
        digitLabel.text = digit
        
        switch status {
        case .correct:
            backgroundColor = .systemGreen
        case .wrongPosition:
            backgroundColor = .systemYellow
        case .incorrect:
            backgroundColor = .systemRed
        }
    }
}

import UIKit

class ComputerGuessView: UIView {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Bilgisayarın tahmini"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var digitStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .systemGray
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var dismissHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(digitStackView)
        containerView.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 150),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            digitStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            digitStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            digitStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            digitStackView.heightAnchor.constraint(equalToConstant: 50),
            digitStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            
            closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func show(guess: String, result: [(digit: String, status: GuessStatus)], in view: UIView, dismissAfter seconds: TimeInterval = 5, onDismiss: @escaping () -> Void) {
        self.dismissHandler = onDismiss
        
        // Önceki digit view'ları temizle
        digitStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Her rakam için bir view oluştur
        for (digit, status) in result {
            let digitView = UIView()
            digitView.backgroundColor = status == .correct ? .systemGreen :
                                      status == .wrongPosition ? .systemYellow : .systemRed
            digitView.layer.cornerRadius = 8
            
            let label = UILabel()
            label.text = digit
            label.textColor = .white
            label.font = .systemFont(ofSize: 24, weight: .bold)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            
            digitView.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: digitView.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: digitView.centerYAnchor)
            ])
            
            digitStackView.addArrangedSubview(digitView)
        }
        
        view.addSubview(self)
        self.frame = view.bounds
        
        // Animasyonlu göster
        self.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
        
        // Belirtilen süre sonra otomatik kapat
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { [weak self] in
            self?.dismiss()
        }
    }
    
    @objc private func closeButtonTapped() {
        dismiss()
    }
    
    private func dismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
            self.dismissHandler?()
        }
    }
}

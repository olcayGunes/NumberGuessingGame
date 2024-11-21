import UIKit

class IntroViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sayı Tahmin Oyunu"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let rulesTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.font = .systemFont(ofSize: 16)
        textView.textAlignment = .left
        textView.backgroundColor = .systemGray6
        textView.layer.cornerRadius = 12
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        let rules = """
        📱 Oyun Kuralları:
        
        1️⃣ Önce siz 4 basamaklı bir sayı tutacaksınız:
           • Rakamlar farklı olmalı
           • İlk rakam 0 olamaz
        
        2️⃣ Sonra sırayla tahmin yapılacak:
           • Önce siz bilgisayarın tuttuğu sayıyı
           • Sonra bilgisayar sizin tuttuğunuz sayıyı tahmin edecek
        
        🎯 Tahmin Sonuçları:
        
        🟢 Yeşil: Doğru rakam, doğru yer
        🟡 Sarı: Doğru rakam, yanlış yer
        🔴 Kırmızı: Yanlış rakam
        
        ⚡️ İpuçları:
        • Her tahmininizden sonra renkli kutucuklarla ipucu alacaksınız
        • Bu ipuçlarını kullanarak sonraki tahminlerinizi daha akıllıca yapabilirsiniz
        • Bilgisayar da aynı şekilde sizin ipuçlarınıza göre tahmin yapacak
        
        🏆 Kazanma:
        • 4 rakamı da doğru tahmin eden (4 yeşil) oyunu kazanır!
        
        Hazırsanız başlayalım! 🎮
        """
        
        textView.text = rules
        return textView
    }()
    
    private lazy var startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Oyuna Başla", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        view.addSubview(rulesTextView)
        view.addSubview(startButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            rulesTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            rulesTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            rulesTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            startButton.topAnchor.constraint(equalTo: rulesTextView.bottomAnchor, constant: 20),
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            startButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func startButtonTapped() {
        let gameVC = ViewController()
        gameVC.modalPresentationStyle = .fullScreen
        present(gameVC, animated: true)
    }
}

import UIKit

class ViewController: UIViewController {
    
    // MARK: - UI Elements
    private lazy var playerNumberLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    private lazy var digitTextFields: [UITextField] = {
        var textFields: [UITextField] = []
        for i in 0..<4 {
            let textField = UITextField()
            textField.borderStyle = .roundedRect
            textField.textAlignment = .center
            textField.keyboardType = .numberPad
            textField.delegate = self
            textField.tag = i
            textField.backgroundColor = .systemGray6
            textField.layer.cornerRadius = 8
            textField.layer.borderWidth = 1
            textField.layer.borderColor = UIColor.systemGray.cgColor
            textField.font = .systemFont(ofSize: 24, weight: .bold)
            textField.translatesAutoresizingMaskIntoConstraints = false
            textFields.append(textField)
        }
        return textFields
    }()
    
    private lazy var digitsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Lütfen 4 haneli sayınızı girin"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Onayla", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var guessCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 8
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(GuessCell.self, forCellWithReuseIdentifier: GuessCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    // MARK: - Properties
    private var correctDigits: [Int: String] = [:] // index: digit
    private var wrongPositionDigits: Set<String> = []
    private var wrongDigits: Set<String> = []
    private var playerNumber: String = ""
    private var computerNumber: String = ""
    private var isGameStarted = false
    private var isPlayerTurn = true
    private var computerGuesses: [String] = []
    private var playerGuessHistory: [[(digit: String, status: GuessStatus)]] = [] // Bu satırı ekleyin
    private var possibleNumbers: Set<String> = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // İlk text field'ı aktif et
        DispatchQueue.main.async {
            self.digitTextFields[0].becomeFirstResponder()
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Stack view'a text field'ları ekle
        digitTextFields.forEach { digitsStackView.addArrangedSubview($0) }
        
        view.addSubview(playerNumberLabel)
        view.addSubview(messageLabel)
        view.addSubview(digitsStackView)
        view.addSubview(submitButton)
        view.addSubview(guessCollectionView)
        
        NSLayoutConstraint.activate([
            // Player Number Label - Yeni
            playerNumberLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            playerNumberLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            playerNumberLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                    
            // Message Label - top anchor'ı güncellendi
            messageLabel.topAnchor.constraint(equalTo: playerNumberLabel.bottomAnchor, constant: 20),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Digits Stack View
            digitsStackView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            digitsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            digitsStackView.widthAnchor.constraint(equalToConstant: 200),
            digitsStackView.heightAnchor.constraint(equalToConstant: 50),
            
            // Submit Button
            submitButton.topAnchor.constraint(equalTo: digitsStackView.bottomAnchor, constant: 20),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            submitButton.widthAnchor.constraint(equalToConstant: 120),
            submitButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Collection View
            guessCollectionView.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 20),
            guessCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            guessCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            guessCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Game Logic
    private func generateComputerNumber() -> String {
        var digits = Array(0...9)
        var result = ""
        
        // İlk rakam 0 olamaz
        digits.removeAll { $0 == 0 }
        if let firstDigit = digits.randomElement() {
            result.append(String(firstDigit))
            digits.removeAll { $0 == firstDigit }
        }
        
        // Diğer 3 rakamı seç
        while result.count < 4 {
            if let digit = digits.randomElement() {
                result.append(String(digit))
                digits.removeAll { $0 == digit }
            }
        }
        
        return result
    }
    
    private func initializePossibleNumbers() {
        possibleNumbers.removeAll()
        // 1000-9999 arası tüm geçerli sayıları oluştur
        for i in 1000...9999 {
            let numStr = String(i)
            if Set(numStr).count == 4 { // Tüm rakamlar farklı
                possibleNumbers.insert(numStr)
            }
        }
    }

    private func makeSmartComputerGuess() -> String {
        if computerGuesses.isEmpty {
            // İlk tahmin için rastgele bir sayı
            return generateComputerNumber()
        }
        
        // Son tahminin sonuçlarını analiz et
        let lastGuess = computerGuesses.last!
        let lastGuessResult = checkGuess(lastGuess, against: playerNumber)
        
        // Sonuçları kategorize et
        for (index, result) in lastGuessResult.enumerated() {
            let digit = String(lastGuess[lastGuess.index(lastGuess.startIndex, offsetBy: index)])
            
            switch result.status {
            case .correct:
                correctDigits[index] = digit
            case .wrongPosition:
                wrongPositionDigits.insert(digit)
            case .incorrect:
                wrongDigits.insert(digit)
            }
        }
        
        // Yeni tahmin oluştur
        var newGuess = Array(repeating: "", count: 4)
        var availablePositions = Set(0...3)
        
        // 1. Doğru yerdeki rakamları yerleştir
        for (index, digit) in correctDigits {
            newGuess[index] = digit
            availablePositions.remove(index)
        }
        
        // 2. Yanlış yerdeki rakamları farklı pozisyonlara yerleştir
        var remainingWrongPositionDigits = wrongPositionDigits
        for position in availablePositions {
            if let digit = remainingWrongPositionDigits.randomElement(),
               !newGuess.contains(digit) {
                newGuess[position] = digit
                remainingWrongPositionDigits.remove(digit)
            }
        }
        
        // 3. Boş kalan yerlere yeni rakamlar seç
        let usedDigits = Set(newGuess.filter { !$0.isEmpty })
        var availableDigits = Set("123456789".map { String($0) })
        availableDigits.subtract(usedDigits)
        availableDigits.subtract(wrongDigits)
        
        for position in 0..<4 where newGuess[position].isEmpty {
            if let digit = availableDigits.randomElement() {
                newGuess[position] = digit
                availableDigits.remove(digit)
            }
        }
        
        return newGuess.joined()
    }
    
    private func makeComputerGuess() {
        var guess: String
        repeat {
            guess = makeSmartComputerGuess()
        } while computerGuesses.contains(guess)
        
        computerGuesses.append(guess) // insert yerine append kullanıyoruz
        
        // Tahmin sonucunu kontrol et
        let guessResult = self.checkGuess(guess, against: self.playerNumber)
        
        // Bilgisayarın tahminini popup ile göster
        let guessView = ComputerGuessView()
        guessView.show(guess: guess, result: guessResult, in: view) { [weak self] in
            guard let self = self else { return }
            
            // Bilgisayar doğru tahmin ettiyse
            if guessResult.allSatisfy({ $0.status == .correct }) {
                self.showAlert(message: "Bilgisayar kazandı! Sayınızı buldu: \(guess)")
                self.resetGame()
                return
            }
            
            // Sırayı oyuncuya ver
            self.isPlayerTurn = true
            self.messageLabel.text = "Sizin sıranız. Tahmininizi girin:"
            self.digitTextFields[0].becomeFirstResponder()
        }
    }
    
    
    private func checkGuess(_ guess: String, against target: String) -> [(digit: String, status: GuessStatus)] {
        var result: [(digit: String, status: GuessStatus)] = []
        let guessDigits = Array(guess)
        let targetDigits = Array(target)
        
        for (index, digit) in guessDigits.enumerated() {
            if digit == targetDigits[index] {
                result.append((String(digit), .correct))
            } else if targetDigits.contains(digit) {
                result.append((String(digit), .wrongPosition))
            } else {
                result.append((String(digit), .incorrect))
            }
        }
        
        return result
    }
    
    // MARK: - Actions
    @objc private func submitButtonTapped() {
        let number = digitTextFields.map { $0.text ?? "" }.joined()
        guard isValidNumber(number) else {
            showAlert(message: "Geçersiz sayı! Lütfen her haneye bir rakam girin ve ilk rakam 0 olmasın.")
            return
        }
        
        if !isGameStarted {
            playerNumber = number
            playerNumberLabel.text = "Sizin sayınız: \(number)"
            computerNumber = generateComputerNumber()
            isGameStarted = true
            isPlayerTurn = true
            messageLabel.text = "Bilgisayarın sayısını tahmin edin"
            print("Bilgisayarın sayısı: \(computerNumber)") // Debug için
            clearDigitFields()
        } else if isPlayerTurn {
            // Oyuncunun tahmini
            let guessResult = checkGuess(number, against: computerNumber)
            playerGuessHistory.insert(guessResult, at: 0)
            guessCollectionView.reloadData()
            
            // Oyuncu kazandı mı?
            if guessResult.allSatisfy({ $0.status == .correct }) {
                showAlert(message: "Tebrikler! Bilgisayarın sayısını buldunuz!")
                resetGame()
                return
            }
            
            // Sırayı bilgisayara ver
            isPlayerTurn = false
            messageLabel.text = "Bilgisayar düşünüyor..."
            clearDigitFields()
            makeComputerGuess()
        }
    }
    
    private func isValidNumber(_ number: String) -> Bool {
        guard number.count == 4,
              let firstDigit = number.first,
              firstDigit != "0",
              Set(number).count == 4 else {
            return false
        }
        return true
    }
    
    private func clearDigitFields() {
        digitTextFields.forEach { $0.text = "" }
        digitTextFields[0].becomeFirstResponder()
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Uyarı", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
    
    private func resetGame() {
        playerNumber = ""
        computerNumber = ""
        isGameStarted = false
        isPlayerTurn = true
        computerGuesses.removeAll()
        possibleNumbers.removeAll()
        correctDigits.removeAll() // Yeni
        wrongPositionDigits.removeAll() // Yeni
        wrongDigits.removeAll() // Yeni
        playerGuessHistory.removeAll()
        playerNumberLabel.text = ""
        messageLabel.text = "Lütfen 4 haneli sayınızı girin"
        guessCollectionView.reloadData()
    }
}

// MARK: - UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Boş string (silme işlemi) ise izin ver
        if string.isEmpty {
            // Silme işleminde bir önceki text field'a geç
            if textField.tag > 0 {
                DispatchQueue.main.async {
                    self.digitTextFields[textField.tag - 1].becomeFirstResponder()
                }
            }
            return true
        }
        
        // Sadece rakam girişine izin ver
        guard string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil else {
            return false
        }
        
        // Mevcut metni güncelle
        textField.text = string
        
        // Bir sonraki text field'a geç
        if textField.tag < 3 {
            DispatchQueue.main.async {
                self.digitTextFields[textField.tag + 1].becomeFirstResponder()
            }
        } else {
            textField.resignFirstResponder() // Son text field ise klavyeyi kapat
        }
        
        return false // Varsayılan davranışı engelle
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Text field seçildiğinde içeriğini temizle
        textField.text = ""
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return playerGuessHistory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playerGuessHistory[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GuessCell.identifier, for: indexPath) as! GuessCell
        let guess = playerGuessHistory[indexPath.section]
        cell.configure(with: guess[indexPath.item].digit, status: guess[indexPath.item].status)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 12) / 4 // 4 hücre ve aralarında 4'er point boşluk
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
    }
}

private extension String {
    subscript(index: Int) -> String {
        String(self[self.index(startIndex, offsetBy: index)])
    }
}

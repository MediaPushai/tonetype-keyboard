import UIKit

/// Protocol for keyboard view delegate
protocol KeyboardViewDelegate: AnyObject {
    func didTapKey(_ key: String)
    func didTapBackspace()
    func didTapSpace()
    func didTapReturn()
    func didTapEnhance()
    func didTapDismissPreview()
    func didTapNextKeyboard()
}

/// The keyboard UI with QWERTY layout, enhance button, and preview bar
final class KeyboardView: UIView {

    // MARK: - Properties

    weak var delegate: KeyboardViewDelegate?

    private(set) var hasPreview: Bool = false

    private var isShifted = false
    private var isShowingNumbers = false
    private var isApplyMode = false

    // MARK: - UI Components

    private let previewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let previewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let toneLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 11)
        label.textColor = UIColor(red: 0.39, green: 0.4, blue: 0.95, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("✕", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemRed
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let keyboardContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var keyButtons: [[UIButton]] = []
    private var enhanceButton: UIButton!
    private var shiftButton: UIButton!
    private var deleteButton: UIButton!
    private var numberButton: UIButton!
    private var globeButton: UIButton!
    private var spaceButton: UIButton!
    private var returnButton: UIButton!

    // MARK: - Layout Constants

    private let keySpacing: CGFloat = 6
    private let rowSpacing: CGFloat = 10
    private let keyCornerRadius: CGFloat = 5
    private let previewHeight: CGFloat = 54
    private let keyHeight: CGFloat = 42
    private let padding: CGFloat = 3

    // MARK: - Key Layouts

    private let letterRows = [
        ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
        ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
        ["z", "x", "c", "v", "b", "n", "m"]
    ]

    private let numberRows = [
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
        ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""],
        [".", ",", "?", "!", "'"]
    ]

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Setup

    private func setupView() {
        backgroundColor = UIColor(red: 0.82, green: 0.84, blue: 0.86, alpha: 1.0)

        setupPreviewBar()
        setupKeyboard()
    }

    private func setupPreviewBar() {
        addSubview(previewContainer)
        previewContainer.addSubview(previewLabel)
        previewContainer.addSubview(toneLabel)
        previewContainer.addSubview(dismissButton)
        addSubview(errorLabel)

        dismissButton.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            previewContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            previewContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            previewContainer.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            previewContainer.heightAnchor.constraint(equalToConstant: previewHeight),

            previewLabel.leadingAnchor.constraint(equalTo: previewContainer.leadingAnchor, constant: 12),
            previewLabel.trailingAnchor.constraint(equalTo: dismissButton.leadingAnchor, constant: -8),
            previewLabel.topAnchor.constraint(equalTo: previewContainer.topAnchor, constant: 8),

            toneLabel.leadingAnchor.constraint(equalTo: previewContainer.leadingAnchor, constant: 12),
            toneLabel.bottomAnchor.constraint(equalTo: previewContainer.bottomAnchor, constant: -8),

            dismissButton.trailingAnchor.constraint(equalTo: previewContainer.trailingAnchor, constant: -8),
            dismissButton.centerYAnchor.constraint(equalTo: previewContainer.centerYAnchor),
            dismissButton.widthAnchor.constraint(equalToConstant: 32),

            errorLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            errorLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8)
        ])
    }

    private func setupKeyboard() {
        addSubview(keyboardContainer)

        NSLayoutConstraint.activate([
            keyboardContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            keyboardContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            keyboardContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            keyboardContainer.topAnchor.constraint(equalTo: topAnchor, constant: 8)
        ])

        buildKeyboard()
    }

    private func buildKeyboard() {
        // Clear existing
        keyboardContainer.subviews.forEach { $0.removeFromSuperview() }
        keyButtons = []

        let rows = isShowingNumbers ? numberRows : letterRows

        // Create key rows
        for row in rows {
            var rowButtons: [UIButton] = []
            for key in row {
                let displayKey = isShifted && !isShowingNumbers ? key.uppercased() : key
                let button = createKeyButton(title: displayKey)
                button.addTarget(self, action: #selector(keyTapped(_:)), for: .touchUpInside)
                keyboardContainer.addSubview(button)
                rowButtons.append(button)
            }
            keyButtons.append(rowButtons)
        }

        // Create special keys
        createSpecialKeys()

        setNeedsLayout()
    }

    private func createSpecialKeys() {
        // Shift/Symbols button
        shiftButton = createSpecialButton(title: isShowingNumbers ? "#+=": "⇧")
        shiftButton.addTarget(self, action: #selector(shiftTapped), for: .touchUpInside)
        shiftButton.backgroundColor = isShifted ? .white : UIColor(white: 0.68, alpha: 1)
        keyboardContainer.addSubview(shiftButton)

        // Delete button
        deleteButton = createSpecialButton(title: "⌫")
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        keyboardContainer.addSubview(deleteButton)

        // Number toggle
        numberButton = createSpecialButton(title: isShowingNumbers ? "ABC" : "123")
        numberButton.titleLabel?.font = .systemFont(ofSize: 16)
        numberButton.addTarget(self, action: #selector(numberTapped), for: .touchUpInside)
        keyboardContainer.addSubview(numberButton)

        // Globe (switch keyboard)
        globeButton = createSpecialButton(title: "🌐")
        globeButton.addTarget(self, action: #selector(globeTapped), for: .touchUpInside)
        keyboardContainer.addSubview(globeButton)

        // Enhance button
        enhanceButton = createSpecialButton(title: "✨")
        enhanceButton.backgroundColor = UIColor(red: 0.39, green: 0.4, blue: 0.95, alpha: 1.0)
        enhanceButton.setTitleColor(.white, for: .normal)
        enhanceButton.addTarget(self, action: #selector(enhanceTapped), for: .touchUpInside)
        keyboardContainer.addSubview(enhanceButton)

        // Space
        spaceButton = createKeyButton(title: "space")
        spaceButton.titleLabel?.font = .systemFont(ofSize: 16)
        spaceButton.addTarget(self, action: #selector(spaceTapped), for: .touchUpInside)
        keyboardContainer.addSubview(spaceButton)

        // Return
        returnButton = createSpecialButton(title: "return")
        returnButton.titleLabel?.font = .systemFont(ofSize: 16)
        returnButton.addTarget(self, action: #selector(returnTapped), for: .touchUpInside)
        keyboardContainer.addSubview(returnButton)
    }

    private func createKeyButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 23)
        button.backgroundColor = .white
        button.layer.cornerRadius = keyCornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.25
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowRadius = 0.5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func createSpecialButton(title: String) -> UIButton {
        let button = createKeyButton(title: title)
        button.backgroundColor = UIColor(white: 0.68, alpha: 1)
        return button
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutKeys()
    }

    private func layoutKeys() {
        let screenWidth = bounds.width
        let availableWidth = screenWidth - (padding * 2)

        // Calculate key width based on first row
        guard !keyButtons.isEmpty else { return }
        let row1Count = CGFloat(keyButtons[0].count)
        let keyWidth = (availableWidth - (keySpacing * (row1Count - 1))) / row1Count

        // Start Y position (account for preview if visible)
        var yOffset: CGFloat = hasPreview ? previewHeight + 12 : 8

        // Layout letter/number rows
        for (rowIndex, row) in keyButtons.enumerated() {
            let rowCount = CGFloat(row.count)
            let totalRowWidth = (keyWidth * rowCount) + (keySpacing * (rowCount - 1))
            var xOffset = (screenWidth - totalRowWidth) / 2

            for button in row {
                button.frame = CGRect(x: xOffset, y: yOffset, width: keyWidth, height: keyHeight)
                xOffset += keyWidth + keySpacing
            }

            yOffset += keyHeight + rowSpacing
        }

        // Layout third row with shift and delete
        let thirdRowY = yOffset - keyHeight - rowSpacing
        let wideKeyWidth = keyWidth * 1.4

        shiftButton.frame = CGRect(x: padding, y: thirdRowY, width: wideKeyWidth, height: keyHeight)
        deleteButton.frame = CGRect(x: screenWidth - padding - wideKeyWidth, y: thirdRowY, width: wideKeyWidth, height: keyHeight)

        // Layout bottom row
        let bottomRowY = yOffset
        let smallKeyWidth: CGFloat = 38
        let enhanceWidth: CGFloat = 50
        let spaceWidth = screenWidth - (smallKeyWidth * 4) - enhanceWidth - (padding * 2) - (keySpacing * 5)

        var xPos = padding

        numberButton.frame = CGRect(x: xPos, y: bottomRowY, width: smallKeyWidth, height: keyHeight)
        xPos += smallKeyWidth + keySpacing

        globeButton.frame = CGRect(x: xPos, y: bottomRowY, width: smallKeyWidth, height: keyHeight)
        xPos += smallKeyWidth + keySpacing

        enhanceButton.frame = CGRect(x: xPos, y: bottomRowY, width: enhanceWidth, height: keyHeight)
        xPos += enhanceWidth + keySpacing

        spaceButton.frame = CGRect(x: xPos, y: bottomRowY, width: spaceWidth, height: keyHeight)
        xPos += spaceWidth + keySpacing

        returnButton.frame = CGRect(x: xPos, y: bottomRowY, width: smallKeyWidth * 2, height: keyHeight)
    }

    // MARK: - Public Methods

    func showPreview(_ text: String, tone: String) {
        previewLabel.text = text
        toneLabel.text = "Tone: \(tone.capitalized)"
        previewContainer.isHidden = false
        hasPreview = true
        errorLabel.isHidden = true

        UIView.animate(withDuration: 0.2) {
            self.superview?.layoutIfNeeded()
        }
    }

    func hidePreview() {
        previewContainer.isHidden = true
        hasPreview = false

        UIView.animate(withDuration: 0.2) {
            self.superview?.layoutIfNeeded()
        }
    }

    func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.errorLabel.isHidden = true
        }
    }

    func setLoading(_ loading: Bool) {
        if loading {
            enhanceButton.setTitle("···", for: .normal)
            enhanceButton.isEnabled = false
        } else {
            enhanceButton.setTitle(isApplyMode ? "✓" : "✨", for: .normal)
            enhanceButton.isEnabled = true
        }
    }

    func setApplyMode(_ apply: Bool) {
        isApplyMode = apply
        enhanceButton.setTitle(apply ? "✓" : "✨", for: .normal)
        enhanceButton.backgroundColor = apply
            ? UIColor.systemGreen
            : UIColor(red: 0.39, green: 0.4, blue: 0.95, alpha: 1.0)
    }

    // MARK: - Actions

    @objc private func keyTapped(_ sender: UIButton) {
        guard let key = sender.title(for: .normal) else { return }
        delegate?.didTapKey(key)

        // Auto-unshift after typing
        if isShifted && !isShowingNumbers {
            isShifted = false
            buildKeyboard()
        }
    }

    @objc private func shiftTapped() {
        isShifted.toggle()
        shiftButton.backgroundColor = isShifted ? .white : UIColor(white: 0.68, alpha: 1)
        buildKeyboard()
    }

    @objc private func deleteTapped() {
        delegate?.didTapBackspace()
    }

    @objc private func numberTapped() {
        isShowingNumbers.toggle()
        isShifted = false
        buildKeyboard()
    }

    @objc private func globeTapped() {
        delegate?.didTapNextKeyboard()
    }

    @objc private func enhanceTapped() {
        delegate?.didTapEnhance()
    }

    @objc private func spaceTapped() {
        delegate?.didTapSpace()
    }

    @objc private func returnTapped() {
        delegate?.didTapReturn()
    }

    @objc private func dismissTapped() {
        delegate?.didTapDismissPreview()
    }
}

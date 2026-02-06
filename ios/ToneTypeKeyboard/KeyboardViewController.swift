import UIKit

/// Main keyboard view controller for ToneType keyboard extension
/// Handles all text input, enhancement, and keyboard management
final class KeyboardViewController: UIInputViewController {

    // MARK: - Properties

    private lazy var keyboardView: KeyboardView = {
        let view = KeyboardView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let enhancer = KeyboardTextEnhancer()
    private var settings = KeyboardSettings.load()

    private var pendingEnhancement: String?
    private var isEnhancing = false

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadSettings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reload settings in case they changed in the main app
        loadSettings()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // Set keyboard height
        let height: CGFloat = keyboardView.hasPreview ? 270 : 220
        view.frame.size.height = height
    }

    override func textWillChange(_ textInput: UITextInput?) {
        // Called before text changes
    }

    override func textDidChange(_ textInput: UITextInput?) {
        // Update preview if auto-preview is enabled
        if settings.showLivePreview {
            updateLivePreview()
        }
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.82, green: 0.84, blue: 0.86, alpha: 1.0)

        view.addSubview(keyboardView)

        NSLayoutConstraint.activate([
            keyboardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyboardView.topAnchor.constraint(equalTo: view.topAnchor),
            keyboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadSettings() {
        settings = KeyboardSettings.load()
        enhancer.configure(with: settings)
    }

    // MARK: - Text Management

    /// Get all text currently in the text field
    private func getCurrentText() -> String {
        let before = textDocumentProxy.documentContextBeforeInput ?? ""
        let after = textDocumentProxy.documentContextAfterInput ?? ""
        return before + after
    }

    /// Delete all text in the current field
    private func deleteAllText() {
        // Delete text before cursor
        if let before = textDocumentProxy.documentContextBeforeInput {
            for _ in 0..<before.count {
                textDocumentProxy.deleteBackward()
            }
        }

        // Move to end and delete text after cursor
        if let after = textDocumentProxy.documentContextAfterInput {
            textDocumentProxy.adjustTextPosition(byCharacterOffset: after.count)
            for _ in 0..<after.count {
                textDocumentProxy.deleteBackward()
            }
        }
    }

    // MARK: - Enhancement

    private func updateLivePreview() {
        let text = getCurrentText()
        guard !text.isEmpty else {
            keyboardView.hidePreview()
            return
        }

        // Use offline enhancement for live preview (faster)
        let result = enhancer.enhanceOffline(text)
        keyboardView.showPreview(result.enhanced, tone: result.toneName)
    }

    private func enhanceCurrentText() {
        let text = getCurrentText()

        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            keyboardView.showError("Type something first")
            return
        }

        guard !isEnhancing else { return }

        isEnhancing = true
        keyboardView.setLoading(true)

        enhancer.enhance(text) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                self.isEnhancing = false
                self.keyboardView.setLoading(false)

                self.pendingEnhancement = result.enhanced
                self.keyboardView.showPreview(result.enhanced, tone: result.toneName)
                self.keyboardView.setApplyMode(true)
            }
        }
    }

    private func applyEnhancement() {
        guard let enhanced = pendingEnhancement else { return }

        // Delete current text
        deleteAllText()

        // Insert enhanced text
        textDocumentProxy.insertText(enhanced)

        // Clear state
        pendingEnhancement = nil
        keyboardView.hidePreview()
        keyboardView.setApplyMode(false)
    }

    private func cancelEnhancement() {
        pendingEnhancement = nil
        keyboardView.hidePreview()
        keyboardView.setApplyMode(false)
    }
}

// MARK: - KeyboardViewDelegate

extension KeyboardViewController: KeyboardViewDelegate {

    func didTapKey(_ key: String) {
        // Cancel any pending enhancement when typing
        if pendingEnhancement != nil {
            cancelEnhancement()
        }

        textDocumentProxy.insertText(key)
    }

    func didTapBackspace() {
        if pendingEnhancement != nil {
            cancelEnhancement()
        }

        textDocumentProxy.deleteBackward()
    }

    func didTapSpace() {
        if pendingEnhancement != nil {
            cancelEnhancement()
        }

        textDocumentProxy.insertText(" ")
    }

    func didTapReturn() {
        if pendingEnhancement != nil {
            cancelEnhancement()
        }

        textDocumentProxy.insertText("\n")
    }

    func didTapEnhance() {
        if pendingEnhancement != nil {
            // Second tap applies the enhancement
            applyEnhancement()
        } else {
            // First tap triggers enhancement
            enhanceCurrentText()
        }
    }

    func didTapDismissPreview() {
        cancelEnhancement()
    }

    func didTapNextKeyboard() {
        advanceToNextInputMode()
    }
}

// MARK: - Keyboard Settings

struct KeyboardSettings {
    var apiKey: String = ""
    var enableEmojis: Bool = true
    var enableStyling: Bool = true
    var emojiIntensity: String = "medium"
    var showLivePreview: Bool = false

    private static let suiteName = "group.com.tonetype.keyboard"

    static func load() -> KeyboardSettings {
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            return KeyboardSettings()
        }

        var settings = KeyboardSettings()

        // API key is stored in Keychain (shared via App Group access group)
        settings.apiKey = KeychainHelper.shared.get(forKey: "apiKey") ?? ""

        settings.enableEmojis = defaults.object(forKey: "enableEmojis") as? Bool ?? true
        settings.enableStyling = defaults.object(forKey: "enableStyling") as? Bool ?? true
        settings.emojiIntensity = defaults.string(forKey: "emojiIntensity") ?? "medium"
        settings.showLivePreview = defaults.bool(forKey: "showLivePreview")

        return settings
    }
}

package com.tonetype.keyboard

import android.inputmethodservice.InputMethodService
import android.view.View
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputConnection
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.ProgressBar
import kotlinx.coroutines.*

/**
 * ToneType Input Method Editor (IME)
 *
 * Custom keyboard service that provides tone detection and enhancement.
 */
class ToneTypeIME : InputMethodService() {

    private lateinit var keyboardView: View
    private lateinit var previewText: TextView
    private lateinit var enhanceButton: Button
    private lateinit var loadingIndicator: ProgressBar

    private val coroutineScope = CoroutineScope(Dispatchers.Main + Job())
    private var isEnhancing = false

    private val toneService by lazy { ToneService(this) }
    private val settingsManager by lazy { SettingsManager(this) }

    // QWERTY keyboard layout
    private val keyboardRows = listOf(
        listOf("q", "w", "e", "r", "t", "y", "u", "i", "o", "p"),
        listOf("a", "s", "d", "f", "g", "h", "j", "k", "l"),
        listOf("⇧", "z", "x", "c", "v", "b", "n", "m", "⌫"),
        listOf("123", "🌐", "✨", " ", "↵")
    )

    private var isShifted = false
    private var isNumeric = false

    override fun onCreateInputView(): View {
        keyboardView = layoutInflater.inflate(R.layout.keyboard_view, null)
        setupKeyboard()
        return keyboardView
    }

    private fun setupKeyboard() {
        previewText = keyboardView.findViewById(R.id.preview_text)
        enhanceButton = keyboardView.findViewById(R.id.enhance_button)
        loadingIndicator = keyboardView.findViewById(R.id.loading_indicator)

        // Setup key buttons
        setupKeyRows()

        // Setup enhance button
        enhanceButton.setOnClickListener {
            if (!isEnhancing) {
                enhanceCurrentText()
            }
        }
    }

    private fun setupKeyRows() {
        val row1 = keyboardView.findViewById<LinearLayout>(R.id.keyboard_row_1)
        val row2 = keyboardView.findViewById<LinearLayout>(R.id.keyboard_row_2)
        val row3 = keyboardView.findViewById<LinearLayout>(R.id.keyboard_row_3)
        val row4 = keyboardView.findViewById<LinearLayout>(R.id.keyboard_row_4)

        setupRow(row1, keyboardRows[0])
        setupRow(row2, keyboardRows[1])
        setupRow(row3, keyboardRows[2])
        setupRow(row4, keyboardRows[3])
    }

    private fun setupRow(row: LinearLayout, keys: List<String>) {
        row.removeAllViews()
        for (key in keys) {
            val button = Button(this).apply {
                text = if (isShifted && key.length == 1 && key[0].isLetter()) {
                    key.uppercase()
                } else {
                    key
                }
                layoutParams = LinearLayout.LayoutParams(
                    0,
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    if (key == " ") 4f else 1f
                )
                setOnClickListener { onKeyPress(key) }
            }
            row.addView(button)
        }
    }

    private fun onKeyPress(key: String) {
        val inputConnection = currentInputConnection ?: return

        when (key) {
            "⇧" -> {
                isShifted = !isShifted
                setupKeyRows()
            }
            "⌫" -> {
                inputConnection.deleteSurroundingText(1, 0)
            }
            "↵" -> {
                inputConnection.performEditorAction(EditorInfo.IME_ACTION_DONE)
            }
            "123" -> {
                isNumeric = !isNumeric
                // TODO: Switch to numeric keyboard
            }
            "🌐" -> {
                switchToNextInputMethod(false)
            }
            "✨" -> {
                enhanceCurrentText()
            }
            " " -> {
                inputConnection.commitText(" ", 1)
            }
            else -> {
                val textToCommit = if (isShifted && key.length == 1 && key[0].isLetter()) {
                    key.uppercase()
                } else {
                    key
                }
                inputConnection.commitText(textToCommit, 1)
                if (isShifted) {
                    isShifted = false
                    setupKeyRows()
                }
            }
        }

        updatePreview()
    }

    private fun updatePreview() {
        val inputConnection = currentInputConnection ?: return
        val text = getInputText(inputConnection)
        previewText.text = if (text.isNotEmpty()) text else "Type a message..."
    }

    private fun getInputText(inputConnection: InputConnection): String {
        // Get text before and after cursor
        val before = inputConnection.getTextBeforeCursor(1000, 0) ?: ""
        val after = inputConnection.getTextAfterCursor(1000, 0) ?: ""
        return "$before$after"
    }

    private fun enhanceCurrentText() {
        val inputConnection = currentInputConnection ?: return
        val text = getInputText(inputConnection)

        if (text.isBlank()) return

        isEnhancing = true
        loadingIndicator.visibility = View.VISIBLE
        enhanceButton.isEnabled = false

        coroutineScope.launch {
            try {
                val settings = settingsManager.getSettings()
                val enhanced = toneService.enhanceMessage(
                    text = text,
                    apiKey = settings.apiKey,
                    enableEmojis = settings.enableEmojis,
                    enableStyling = settings.enableStyling,
                    emojiIntensity = settings.emojiIntensity
                )

                // Replace the text in the input field
                withContext(Dispatchers.Main) {
                    // Select all text
                    inputConnection.setSelection(0, 0)
                    inputConnection.deleteSurroundingText(0, text.length)
                    inputConnection.setSelection(0, 0)
                    val beforeText = inputConnection.getTextBeforeCursor(1000, 0) ?: ""
                    inputConnection.deleteSurroundingText(beforeText.length, 0)

                    // Commit enhanced text
                    inputConnection.commitText(enhanced.text, 1)

                    // Update preview
                    previewText.text = "✨ ${enhanced.tone}"
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    previewText.text = "Enhancement failed. Try again."
                }
            } finally {
                withContext(Dispatchers.Main) {
                    isEnhancing = false
                    loadingIndicator.visibility = View.GONE
                    enhanceButton.isEnabled = true
                }
            }
        }
    }

    override fun onStartInputView(info: EditorInfo?, restarting: Boolean) {
        super.onStartInputView(info, restarting)
        updatePreview()
    }

    override fun onDestroy() {
        super.onDestroy()
        coroutineScope.cancel()
    }
}

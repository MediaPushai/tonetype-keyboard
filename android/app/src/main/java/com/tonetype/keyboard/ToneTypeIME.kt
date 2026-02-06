package com.tonetype.keyboard

import android.inputmethodservice.InputMethodService
import android.graphics.Typeface
import android.view.Gravity
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
 * Supports QWERTY, numeric, and symbol layouts with the ToneType purple
 * gradient theme (#7C3AED to #4C1D95).
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

    // Current keyboard mode
    private var isShifted = false
    private var isNumeric = false
    private var isSymbols = false  // Second page of symbols

    // ── Layout Definitions ──────────────────────────────────────────────

    // QWERTY keyboard layout
    private val qwertyRows = listOf(
        listOf("q", "w", "e", "r", "t", "y", "u", "i", "o", "p"),
        listOf("a", "s", "d", "f", "g", "h", "j", "k", "l"),
        listOf("⇧", "z", "x", "c", "v", "b", "n", "m", "⌫"),
        listOf("123", "🌐", "✨", " ", ".", "↵")
    )

    // Numeric / punctuation layout (page 1)
    private val numericRows = listOf(
        listOf("1", "2", "3", "4", "5", "6", "7", "8", "9", "0"),
        listOf("@", "#", "$", "&", "*", "(", ")", "'", "\""),
        listOf("#+=", "%", "-", "+", "=", "/", ";", ":", "⌫"),
        listOf("ABC", "🌐", "✨", " ", ".", "↵")
    )

    // Extended symbols layout (page 2)
    private val symbolRows = listOf(
        listOf("[", "]", "{", "}", "#", "%", "^", "*", "+", "="),
        listOf("_", "\\", "|", "~", "<", ">", "!", "?", ","),
        listOf("123", "`", ".", ",", "?", "!", "'", "\"", "⌫"),
        listOf("ABC", "🌐", "✨", " ", ".", "↵")
    )

    // Keys that get the "special" background style
    private val specialKeys = setOf("⇧", "⌫", "123", "ABC", "#+=", "🌐", "↵")

    // ── Lifecycle ────────────────────────────────────────────────────────

    override fun onCreateInputView(): View {
        keyboardView = layoutInflater.inflate(R.layout.keyboard_view, null)
        setupKeyboard()
        return keyboardView
    }

    private fun setupKeyboard() {
        previewText = keyboardView.findViewById(R.id.preview_text)
        enhanceButton = keyboardView.findViewById(R.id.enhance_button)
        loadingIndicator = keyboardView.findViewById(R.id.loading_indicator)

        setupKeyRows()

        enhanceButton.setOnClickListener {
            if (!isEnhancing) {
                enhanceCurrentText()
            }
        }
    }

    // ── Key Row Setup ────────────────────────────────────────────────────

    private fun activeRows(): List<List<String>> = when {
        isSymbols -> symbolRows
        isNumeric -> numericRows
        else      -> qwertyRows
    }

    private fun setupKeyRows() {
        val rows = activeRows()
        val row1 = keyboardView.findViewById<LinearLayout>(R.id.keyboard_row_1)
        val row2 = keyboardView.findViewById<LinearLayout>(R.id.keyboard_row_2)
        val row3 = keyboardView.findViewById<LinearLayout>(R.id.keyboard_row_3)
        val row4 = keyboardView.findViewById<LinearLayout>(R.id.keyboard_row_4)

        setupRow(row1, rows[0])
        setupRow(row2, rows[1])
        setupRow(row3, rows[2])
        setupRow(row4, rows[3])
    }

    private fun setupRow(row: LinearLayout, keys: List<String>) {
        row.removeAllViews()
        for (key in keys) {
            val button = createKeyButton(key)
            row.addView(button)
        }
    }

    private fun createKeyButton(key: String): Button {
        val isSpecial = key in specialKeys
        val isSpace = key == " "
        val isEnhance = key == "✨"

        // Determine display text
        val displayText = when {
            key == " " -> ""
            key == "⇧" && isShifted -> "⇧"  // visual indicator handled by background
            !isNumeric && !isSymbols && key.length == 1 && key[0].isLetter() && isShifted -> key.uppercase()
            else -> key
        }

        // Determine weight: space bar gets extra room
        val weight = when {
            isSpace -> 4f
            key == "⇧" || key == "⌫" -> 1.3f
            key == "123" || key == "ABC" || key == "#+=" -> 1.3f
            else -> 1f
        }

        // Pick background drawable
        val bgRes = when {
            isEnhance -> R.drawable.key_special_bg
            isSpace   -> R.drawable.key_space_bg
            isSpecial -> R.drawable.key_special_bg
            else      -> R.drawable.key_bg
        }

        // Text color — enhance key gets gold, shifted shift key gets bright purple
        val textColor = when {
            isEnhance -> 0xFFEAB308.toInt()     // gold
            key == "⇧" && isShifted -> 0xFFC4B5FD.toInt()  // bright lavender when active
            isSpecial -> 0xFFC4B5FD.toInt()      // light purple
            else      -> 0xFFFFFFFF.toInt()       // white
        }

        return Button(this).apply {
            text = displayText
            setTextColor(textColor)
            textSize = when {
                isEnhance -> 18f
                key.length > 1 -> 12f
                else -> 16f
            }
            typeface = Typeface.create("sans-serif-medium", Typeface.NORMAL)
            isAllCaps = false
            gravity = Gravity.CENTER
            stateListAnimator = null  // remove default elevation animation
            setBackgroundResource(bgRes)
            setPadding(0, 0, 0, 0)
            minimumWidth = 0
            minimumHeight = 0

            layoutParams = LinearLayout.LayoutParams(
                0,
                LinearLayout.LayoutParams.MATCH_PARENT,
                weight
            ).apply {
                marginStart = 2
                marginEnd = 2
            }

            setOnClickListener { onKeyPress(key) }
        }
    }

    // ── Key Press Handler ────────────────────────────────────────────────

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
                // Switch to numeric layout (or back to page 1 from symbols)
                isNumeric = true
                isSymbols = false
                isShifted = false
                setupKeyRows()
            }
            "ABC" -> {
                // Switch back to QWERTY
                isNumeric = false
                isSymbols = false
                isShifted = false
                setupKeyRows()
            }
            "#+=" -> {
                // Switch to extended symbols page
                isSymbols = true
                isNumeric = false
                setupKeyRows()
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
                val textToCommit = if (!isNumeric && !isSymbols && isShifted && key.length == 1 && key[0].isLetter()) {
                    key.uppercase()
                } else {
                    key
                }
                inputConnection.commitText(textToCommit, 1)
                // Auto-unshift after typing a letter in QWERTY mode
                if (!isNumeric && !isSymbols && isShifted) {
                    isShifted = false
                    setupKeyRows()
                }
            }
        }

        updatePreview()
    }

    // ── Preview & Text Helpers ───────────────────────────────────────────

    private fun updatePreview() {
        val inputConnection = currentInputConnection ?: return
        val text = getInputText(inputConnection)
        previewText.text = if (text.isNotEmpty()) text else "Type a message..."
    }

    private fun getInputText(inputConnection: InputConnection): String {
        val before = inputConnection.getTextBeforeCursor(1000, 0) ?: ""
        val after = inputConnection.getTextAfterCursor(1000, 0) ?: ""
        return "$before$after"
    }

    // ── AI Enhancement ───────────────────────────────────────────────────

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
                    inputConnection.setSelection(0, 0)
                    inputConnection.deleteSurroundingText(0, text.length)
                    inputConnection.setSelection(0, 0)
                    val beforeText = inputConnection.getTextBeforeCursor(1000, 0) ?: ""
                    inputConnection.deleteSurroundingText(beforeText.length, 0)

                    inputConnection.commitText(enhanced.text, 1)
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

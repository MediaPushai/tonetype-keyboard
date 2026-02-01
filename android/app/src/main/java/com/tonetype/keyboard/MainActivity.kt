package com.tonetype.keyboard

import android.content.Intent
import android.os.Bundle
import android.provider.Settings
import android.view.inputmethod.InputMethodManager
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.tonetype.keyboard.ui.theme.ToneTypeTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            ToneTypeTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    OnboardingScreen(
                        onEnableKeyboard = { openKeyboardSettings() },
                        onOpenSettings = { openAppSettings() },
                        isKeyboardEnabled = { isKeyboardEnabled() }
                    )
                }
            }
        }
    }

    private fun openKeyboardSettings() {
        startActivity(Intent(Settings.ACTION_INPUT_METHOD_SETTINGS))
    }

    private fun openAppSettings() {
        startActivity(Intent(this, SettingsActivity::class.java))
    }

    private fun isKeyboardEnabled(): Boolean {
        val imm = getSystemService(INPUT_METHOD_SERVICE) as InputMethodManager
        val enabledMethods = imm.enabledInputMethodList
        return enabledMethods.any { it.packageName == packageName }
    }
}

@Composable
fun OnboardingScreen(
    onEnableKeyboard: () -> Unit,
    onOpenSettings: () -> Unit,
    isKeyboardEnabled: () -> Boolean
) {
    var currentStep by remember { mutableStateOf(0) }
    val keyboardEnabled by remember { mutableStateOf(isKeyboardEnabled()) }

    val purpleGradient = Brush.linearGradient(
        colors = listOf(Color(0xFF7C3AED), Color(0xFF4C1D95))
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.SpaceBetween
    ) {
        Spacer(modifier = Modifier.height(48.dp))

        // Logo and title
        Column(
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Box(
                modifier = Modifier
                    .size(100.dp)
                    .clip(RoundedCornerShape(24.dp))
                    .background(purpleGradient),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = "T",
                    fontSize = 48.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
            }

            Spacer(modifier = Modifier.height(24.dp))

            Text(
                text = "ToneType",
                fontSize = 32.sp,
                fontWeight = FontWeight.Bold,
                color = Color(0xFF1C1917)
            )

            Spacer(modifier = Modifier.height(8.dp))

            Text(
                text = "Say it like you mean it",
                fontSize = 18.sp,
                color = Color(0xFF78716C)
            )
        }

        // Steps
        Column(
            modifier = Modifier.padding(vertical = 48.dp),
            verticalArrangement = Arrangement.spacedBy(24.dp)
        ) {
            OnboardingStep(
                number = 1,
                title = "Type Your Message",
                description = "Use ToneType like any other keyboard",
                isActive = currentStep >= 0
            )
            OnboardingStep(
                number = 2,
                title = "Tap Enhance",
                description = "Press the ✨ button to analyze your tone",
                isActive = currentStep >= 1
            )
            OnboardingStep(
                number = 3,
                title = "Send with Clarity",
                description = "Your message now has perfect emojis and styling",
                isActive = currentStep >= 2
            )
        }

        // Buttons
        Column(
            modifier = Modifier.fillMaxWidth(),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Button(
                onClick = onEnableKeyboard,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(56.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color(0xFF7C3AED)
                ),
                shape = RoundedCornerShape(16.dp)
            ) {
                Text(
                    text = if (keyboardEnabled) "Keyboard Enabled ✓" else "Enable Keyboard",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.SemiBold
                )
            }

            OutlinedButton(
                onClick = onOpenSettings,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(56.dp),
                shape = RoundedCornerShape(16.dp)
            ) {
                Text(
                    text = "Settings",
                    fontSize = 18.sp,
                    color = Color(0xFF7C3AED)
                )
            }
        }

        Spacer(modifier = Modifier.height(24.dp))
    }
}

@Composable
fun OnboardingStep(
    number: Int,
    title: String,
    description: String,
    isActive: Boolean
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.Top
    ) {
        Box(
            modifier = Modifier
                .size(32.dp)
                .clip(RoundedCornerShape(16.dp))
                .background(
                    if (isActive) Color(0xFF7C3AED) else Color(0xFFE7E5E4)
                ),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = number.toString(),
                fontSize = 14.sp,
                fontWeight = FontWeight.Bold,
                color = if (isActive) Color.White else Color(0xFF78716C)
            )
        }

        Spacer(modifier = Modifier.width(16.dp))

        Column {
            Text(
                text = title,
                fontSize = 18.sp,
                fontWeight = FontWeight.SemiBold,
                color = Color(0xFF1C1917)
            )
            Text(
                text = description,
                fontSize = 14.sp,
                color = Color(0xFF78716C)
            )
        }
    }
}

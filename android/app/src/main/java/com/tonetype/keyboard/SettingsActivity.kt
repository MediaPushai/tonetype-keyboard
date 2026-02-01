package com.tonetype.keyboard

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.tonetype.keyboard.ui.theme.ToneTypeTheme
import kotlinx.coroutines.launch

class SettingsActivity : ComponentActivity() {

    private lateinit var settingsManager: SettingsManager

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        settingsManager = SettingsManager(this)

        setContent {
            ToneTypeTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    SettingsScreen(
                        settingsManager = settingsManager,
                        onBack = { finish() }
                    )
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(
    settingsManager: SettingsManager,
    onBack: () -> Unit
) {
    val scope = rememberCoroutineScope()
    val settings by settingsManager.settingsFlow.collectAsState(
        initial = SettingsManager.Settings(
            apiKey = null,
            enableEmojis = true,
            enableStyling = true,
            emojiIntensity = EmojiIntensity.MEDIUM
        )
    )

    var apiKeyInput by remember { mutableStateOf(settings.apiKey ?: "") }
    var showResetDialog by remember { mutableStateOf(false) }

    LaunchedEffect(settings.apiKey) {
        apiKeyInput = settings.apiKey ?: ""
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Settings") },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = Color(0xFF7C3AED),
                    titleContentColor = Color.White,
                    navigationIconContentColor = Color.White
                )
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .verticalScroll(rememberScrollState())
        ) {
            // AI Configuration Section
            SettingsSection(title = "AI Configuration") {
                OutlinedTextField(
                    value = apiKeyInput,
                    onValueChange = { newValue ->
                        apiKeyInput = newValue
                        scope.launch {
                            settingsManager.setApiKey(newValue.ifBlank { null })
                        }
                    },
                    label = { Text("OpenAI API Key") },
                    placeholder = { Text("sk-...") },
                    visualTransformation = PasswordVisualTransformation(),
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true
                )

                Spacer(modifier = Modifier.height(8.dp))

                Text(
                    text = "An API key enables AI-powered tone detection. Without it, basic offline detection is used.",
                    fontSize = 12.sp,
                    color = Color(0xFF78716C)
                )
            }

            // Enhancement Options Section
            SettingsSection(title = "Enhancement Options") {
                SettingsSwitch(
                    title = "Add Emojis",
                    subtitle = "Automatically add tone-appropriate emojis",
                    checked = settings.enableEmojis,
                    onCheckedChange = { enabled ->
                        scope.launch {
                            settingsManager.setEnableEmojis(enabled)
                        }
                    }
                )

                SettingsSwitch(
                    title = "Apply Text Styling",
                    subtitle = "Style emphasized words with Unicode formatting",
                    checked = settings.enableStyling,
                    onCheckedChange = { enabled ->
                        scope.launch {
                            settingsManager.setEnableStyling(enabled)
                        }
                    }
                )

                Spacer(modifier = Modifier.height(16.dp))

                Text(
                    text = "Emoji Intensity",
                    fontWeight = FontWeight.Medium,
                    fontSize = 16.sp
                )

                Spacer(modifier = Modifier.height(8.dp))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    EmojiIntensity.values().forEach { intensity ->
                        FilterChip(
                            selected = settings.emojiIntensity == intensity,
                            onClick = {
                                scope.launch {
                                    settingsManager.setEmojiIntensity(intensity)
                                }
                            },
                            label = {
                                Text(
                                    when (intensity) {
                                        EmojiIntensity.LOW -> "Low"
                                        EmojiIntensity.MEDIUM -> "Medium"
                                        EmojiIntensity.HIGH -> "High"
                                    }
                                )
                            }
                        )
                    }
                }
            }

            // About Section
            SettingsSection(title = "About") {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text("Version")
                    Text("1.0.0", color = Color(0xFF78716C))
                }

                Spacer(modifier = Modifier.height(16.dp))

                TextButton(
                    onClick = { showResetDialog = true },
                    colors = ButtonDefaults.textButtonColors(
                        contentColor = Color(0xFFDC2626)
                    )
                ) {
                    Text("Reset to Defaults")
                }
            }
        }

        // Reset Confirmation Dialog
        if (showResetDialog) {
            AlertDialog(
                onDismissRequest = { showResetDialog = false },
                title = { Text("Reset Settings?") },
                text = { Text("This will reset all settings to their default values. Your API key will also be removed.") },
                confirmButton = {
                    TextButton(
                        onClick = {
                            scope.launch {
                                settingsManager.resetToDefaults()
                                apiKeyInput = ""
                            }
                            showResetDialog = false
                        }
                    ) {
                        Text("Reset", color = Color(0xFFDC2626))
                    }
                },
                dismissButton = {
                    TextButton(onClick = { showResetDialog = false }) {
                        Text("Cancel")
                    }
                }
            )
        }
    }
}

@Composable
fun SettingsSection(
    title: String,
    content: @Composable ColumnScope.() -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp)
    ) {
        Text(
            text = title,
            fontSize = 14.sp,
            fontWeight = FontWeight.SemiBold,
            color = Color(0xFF7C3AED),
            modifier = Modifier.padding(bottom = 12.dp)
        )
        content()
    }
    HorizontalDivider(color = Color(0xFFE7E5E4))
}

@Composable
fun SettingsSwitch(
    title: String,
    subtitle: String,
    checked: Boolean,
    onCheckedChange: (Boolean) -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 8.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = title,
                fontWeight = FontWeight.Medium,
                fontSize = 16.sp
            )
            Text(
                text = subtitle,
                fontSize = 12.sp,
                color = Color(0xFF78716C)
            )
        }
        Switch(
            checked = checked,
            onCheckedChange = onCheckedChange,
            colors = SwitchDefaults.colors(
                checkedThumbColor = Color.White,
                checkedTrackColor = Color(0xFF7C3AED)
            )
        )
    }
}

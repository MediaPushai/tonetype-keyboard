package com.tonetype.keyboard.ui.theme

import android.app.Activity
import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat

// ToneType Brand Colors
val Purple500 = Color(0xFF7C3AED)
val Purple700 = Color(0xFF5B21B6)
val Purple900 = Color(0xFF4C1D95)

val Gray50 = Color(0xFFFAFAF9)
val Gray100 = Color(0xFFF5F5F4)
val Gray200 = Color(0xFFE7E5E4)
val Gray500 = Color(0xFF78716C)
val Gray700 = Color(0xFF44403C)
val Gray900 = Color(0xFF1C1917)

val Green500 = Color(0xFF10B981)
val Red500 = Color(0xFFEF4444)

private val LightColorScheme = lightColorScheme(
    primary = Purple500,
    onPrimary = Color.White,
    primaryContainer = Purple900,
    onPrimaryContainer = Color.White,
    secondary = Purple700,
    onSecondary = Color.White,
    background = Gray50,
    onBackground = Gray900,
    surface = Color.White,
    onSurface = Gray900,
    surfaceVariant = Gray100,
    onSurfaceVariant = Gray700,
    outline = Gray200,
    error = Red500,
    onError = Color.White
)

private val DarkColorScheme = darkColorScheme(
    primary = Purple500,
    onPrimary = Color.White,
    primaryContainer = Purple900,
    onPrimaryContainer = Color.White,
    secondary = Purple700,
    onSecondary = Color.White,
    background = Gray900,
    onBackground = Gray50,
    surface = Gray900,
    onSurface = Gray50,
    surfaceVariant = Gray700,
    onSurfaceVariant = Gray200,
    outline = Gray500,
    error = Red500,
    onError = Color.White
)

@Composable
fun ToneTypeTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    dynamicColor: Boolean = false,
    content: @Composable () -> Unit
) {
    val colorScheme = when {
        dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
            val context = LocalContext.current
            if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
        }
        darkTheme -> DarkColorScheme
        else -> LightColorScheme
    }

    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            window.statusBarColor = colorScheme.primary.toArgb()
            WindowCompat.getInsetsController(window, view).isAppearanceLightStatusBars = false
        }
    }

    MaterialTheme(
        colorScheme = colorScheme,
        content = content
    )
}

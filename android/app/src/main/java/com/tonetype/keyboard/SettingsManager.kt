package com.tonetype.keyboard

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.*
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.runBlocking

private val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "tonetype_settings")

/**
 * Manages app settings using DataStore
 */
class SettingsManager(private val context: Context) {

    companion object {
        private val API_KEY = stringPreferencesKey("api_key")
        private val ENABLE_EMOJIS = booleanPreferencesKey("enable_emojis")
        private val ENABLE_STYLING = booleanPreferencesKey("enable_styling")
        private val EMOJI_INTENSITY = stringPreferencesKey("emoji_intensity")
    }

    data class Settings(
        val apiKey: String?,
        val enableEmojis: Boolean,
        val enableStyling: Boolean,
        val emojiIntensity: EmojiIntensity
    )

    val settingsFlow: Flow<Settings> = context.dataStore.data.map { preferences ->
        Settings(
            apiKey = preferences[API_KEY],
            enableEmojis = preferences[ENABLE_EMOJIS] ?: true,
            enableStyling = preferences[ENABLE_STYLING] ?: true,
            emojiIntensity = EmojiIntensity.valueOf(
                preferences[EMOJI_INTENSITY] ?: EmojiIntensity.MEDIUM.name
            )
        )
    }

    fun getSettings(): Settings = runBlocking {
        settingsFlow.first()
    }

    suspend fun setApiKey(apiKey: String?) {
        context.dataStore.edit { preferences ->
            if (apiKey != null) {
                preferences[API_KEY] = apiKey
            } else {
                preferences.remove(API_KEY)
            }
        }
    }

    suspend fun setEnableEmojis(enabled: Boolean) {
        context.dataStore.edit { preferences ->
            preferences[ENABLE_EMOJIS] = enabled
        }
    }

    suspend fun setEnableStyling(enabled: Boolean) {
        context.dataStore.edit { preferences ->
            preferences[ENABLE_STYLING] = enabled
        }
    }

    suspend fun setEmojiIntensity(intensity: EmojiIntensity) {
        context.dataStore.edit { preferences ->
            preferences[EMOJI_INTENSITY] = intensity.name
        }
    }

    suspend fun resetToDefaults() {
        context.dataStore.edit { preferences ->
            preferences.clear()
        }
    }
}

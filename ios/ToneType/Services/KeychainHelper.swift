import Foundation
import Security

/// Minimal Keychain wrapper for storing, retrieving, and deleting string values.
/// Uses the shared App Group access group so both the main app and the keyboard
/// extension can read/write the same Keychain items.
final class KeychainHelper {

    // MARK: - Shared Instance

    static let shared = KeychainHelper()

    // MARK: - Configuration

    /// App Group shared between the main app and the keyboard extension.
    /// Using the `group.` prefix as `kSecAttrAccessGroup` allows Keychain
    /// sharing without a separate keychain-access-groups entitlement.
    private let accessGroup = "group.com.tonetype.keyboard"

    /// Service identifier scoped to ToneType to avoid collisions.
    private let service = "com.tonetype.app"

    private init() {}

    // MARK: - Public API

    /// Store a string value in the Keychain for the given key.
    /// Overwrites any existing value for that key.
    @discardableResult
    func set(_ value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        // Delete any existing item first to avoid errSecDuplicateItem
        delete(forKey: key)

        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrService as String:  service,
            kSecAttrAccount as String:  key,
            kSecAttrAccessGroup as String: accessGroup,
            kSecValueData as String:    data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    /// Retrieve a string value from the Keychain for the given key.
    /// Returns nil if the key doesn't exist or the data can't be decoded.
    func get(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrService as String:  service,
            kSecAttrAccount as String:  key,
            kSecAttrAccessGroup as String: accessGroup,
            kSecReturnData as String:   true,
            kSecMatchLimit as String:   kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    /// Delete the value for the given key from the Keychain.
    @discardableResult
    func delete(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrService as String:  service,
            kSecAttrAccount as String:  key,
            kSecAttrAccessGroup as String: accessGroup
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}

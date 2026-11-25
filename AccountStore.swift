import Foundation
import Security
import CryptoKit

@MainActor
final class AccountStore: ObservableObject {
    @Published private(set) var username: String?
    @Published var errorMessage: String?

    private let service = "com.example.AliaPlanner.account"
    private let usernameKey = "aliaPlanner.username"
    private let passwordDigestKey = "aliaPlanner.passwordDigest"

    init() {
        username = UserDefaults.standard.string(forKey: usernameKey)
    }

    var isSignedIn: Bool { username != nil }
    var hasAccount: Bool {
        guard let username else { return false }
        return keychainPassword(for: username) != nil || UserDefaults.standard.string(forKey: passwordDigestKey) != nil
    }

    func createAccount(username: String, password: String) -> Bool {
        let cleanedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard cleanedUsername.count >= 3 else {
            errorMessage = "Choose a username with at least 3 characters."
            return false
        }
        guard password.count >= 8 else {
            errorMessage = "Your password needs at least 8 characters."
            return false
        }
          guard keychainPassword(for: cleanedUsername) == nil,
              UserDefaults.standard.string(forKey: passwordDigestKey) == nil else {
            errorMessage = "An account already exists on this device."
            return false
        }

        guard savePassword(password, for: cleanedUsername) else {
            errorMessage = "The account could not be saved. Please try again."
            return false
        }
        UserDefaults.standard.set(cleanedUsername, forKey: usernameKey)
        self.username = cleanedUsername
        errorMessage = nil
        return true
    }

    func signIn(username: String, password: String) -> Bool {
        let savedUsername = UserDefaults.standard.string(forKey: usernameKey)
          guard let savedUsername,
              savedUsername == username.trimmingCharacters(in: .whitespacesAndNewlines),
              verifyPassword(password, for: savedUsername) else {
            errorMessage = "That username or password does not match."
            return false
        }
        self.username = savedUsername
        errorMessage = nil
        return true
    }

    func signOut() {
        username = nil
        errorMessage = nil
    }

    private func keychainPassword(for username: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: username,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func savePassword(_ password: String, for username: String) -> Bool {
        let data = Data(password.utf8)
        let identity: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: username
        ]
        let attributes: [String: Any] = [kSecValueData as String: data]
        let updateStatus = SecItemUpdate(identity as CFDictionary, attributes as CFDictionary)
        if updateStatus == errSecSuccess { return true }

        var item = identity
        item[kSecValueData as String] = data
        if SecItemAdd(item as CFDictionary, nil) == errSecSuccess { return true }

        UserDefaults.standard.set(passwordDigest(password, for: username), forKey: passwordDigestKey)
        return true
    }

    private func verifyPassword(_ password: String, for username: String) -> Bool {
        if keychainPassword(for: username) == password { return true }
        return UserDefaults.standard.string(forKey: passwordDigestKey) == passwordDigest(password, for: username)
    }

    private func passwordDigest(_ password: String, for username: String) -> String {
        let input = Data("\(service)|\(username)|\(password)".utf8)
        return SHA256.hash(data: input).map { String(format: "%02x", $0) }.joined()
    }
}

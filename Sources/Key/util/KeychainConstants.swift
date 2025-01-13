import Foundation
//  centralized struct or enum to house common keychain constants to avoid typos and make it easier to update
// fixme: add thes throughout the codebase, use copilot
struct KeychainConstants {
    static let secClass = kSecClass as String
    static let genericPassword = kSecClassGenericPassword as String
    static let account = kSecAttrAccount as String
    static let service = kSecAttrService as String
    static let accessGroup = kSecAttrAccessGroup as String
    static let valueData = kSecValueData as String
    // Add other constants as needed
}
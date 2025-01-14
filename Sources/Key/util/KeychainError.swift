import Foundation
// fixme: add this
enum KeychainError: LocalizedError {
   case itemNotFound
    case duplicateItem
    case unexpectedData
    case unhandledError(status: OSStatus)
    
    public var errorDescription: String? {
        switch self {
        case .itemNotFound:
            return "The specified item could not be found in the keychain."
        case .duplicateItem:
            return "An item with the same key already exists."
        case .unexpectedData:
            return "The data retrieved from the keychain is in an unexpected format."
        case .unhandledError(let status):
            return "Unhandled keychain error with status: \(status)."
        }
    }
}

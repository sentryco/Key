import Foundation
// fixme: add this
enum KeychainError: Error {
    case itemNotFound
    case unexpectedData
    case unhandledError(status: OSStatus)
}

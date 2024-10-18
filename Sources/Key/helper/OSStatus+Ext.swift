import Foundation
/**
 * Getter
 */
extension OSStatus {
   /**
    * Creates readable error
    * - Description: Converts an OSStatus error code into a human-readable string.
    * - Remark: Since OSStatus could be cryptic to understand, Apple provides
    *           an additional API called SecCopyErrorMessageString(_:_:) to obtain a
    *           human-readable string corresponding to these status codes.
    * - Note: More info: https://developer.apple.com/documentation/security/1542001-security_framework_result_codes
    * - Fixme: ⚠️️ Make better error etc, see github issues
    * - Fixme: ⚠️️ We could return KeyError if KeyError was enum etc?
    * - Parameter status: The status returned by keychain when interacting with it
    * ## Examples:
    * let status = errSecAuthFailed // Simulate a failed authentication status
    * let error = status.readableError // Get the readable error message using the `readableError` method
    * print(error) // Output: Operation failed: The user name or passphrase you entered is not correct.
    */
   public var readableError: String {
      if self != errSecSuccess { // Check if the status code is not equal to `errSecSuccess`
         if #available(iOS 11.3, *), // Check if the device is running iOS 11.3 or later
            let err = SecCopyErrorMessageString(self, nil) { // Get the error message string using the `SecCopyErrorMessageString` function
            return "Operation failed: \(err)" // Return the error message string
         } else { // If the device is running an earlier version of iOS or the error message string cannot be retrieved
            return "Operation failed: \(self). Check the error message through https://osstatus.com." // Return a generic error message with a link to https://osstatus.com
         }
      } else { // If the status code is equal to `errSecSuccess`
         return "No error" // Return a message indicating that there is no error
      }
   }
}

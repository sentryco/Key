import Foundation
/**
 * - Remark: Use: `status.readableError` on status
 * - Description: An enumeration representing keychain-related errors, with an associated OSStatus value.
 */
public enum KeyError: Error {
   case error(_ status: OSStatus) // An error case with an associated value of the OSStatus type
}
extension KeyError {
   /**
    * - Description: This computed property provides a localized description of the KeyError. 
    *   If the error case contains an OSStatus, it returns a human-readable error message for the status code.
    *   Otherwise, it returns a generic error message indicating a KeyError failure.
    * - Remark: You have to cast the instance to get access to status
    * ## Examples:
    * (error as? KeyError)?.localizedDescription // We must cast as KeyError or localizedDesc doesn't work?
    */
   public var localizedDescription: String {
      if case .error(let status) = self { // Check if the enum case is .error and extract the status code
         return status.readableError // Return the readable error message for the status code
      } else { // If the enum case is not .error
         return "⚠️️ KeyError fail" // Return a generic error message
      }
   }
}

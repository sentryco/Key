import Foundation
import LocalAuthentication
/**
 * KeyReader
 */
public final class KeyReader {
   /**
    * Read data for key and variouse optional params
    * - Description: Reads the data associated with a given key from the keychain and returns it. If the data is not found or an error occurs, this method throws an error.
    * - Parameters:
    *   - key: Key to read data from
    *   - service: `Application-identifier` to associate with
    *   - accessGroup: A way to differentiate access between different applications
    *   - access: Defines the access restrictions for the key-chain items (Biometric authentication etc)
    *   - secClass: SecClass = `.genericPassword` (see SecClass class for more info)
    *   - context: Avoids having to authenticate more than once, reuse the biometric authentication context etc
    */
   public static func read(key: String, service: String? = nil, accessGroup: String? = nil, access: KeyAccess? = nil, secClass: SecClass = .genericPassword, context: LAContext? = nil) throws -> AnyObject {
      // Create a query dictionary for reading a keychain item
      let readQuery: QueryDict = .readQuery(
         key: key, // The key to check for. (also called account)
         service: service, // The service name to match. If nil, all services are matched.
         accessGroup: accessGroup, // The access group to match. If nil, all access groups are matched.
         access: access, // The accessibility level to match. If nil, all accessibility levels are matched.
         secClass: secClass, // The security class to match. If nil, all security classes are matched.
         context: context // The context to match. If nil, all contexts are matched.
      )
      var result: AnyObject? // Temporary result variable
      // Fetch items from the keychain using the query dictionary
      let status: OSStatus = withUnsafeMutablePointer(to: &result) {
         SecItemCopyMatching(readQuery as CFDictionary, UnsafeMutablePointer($0))
      }
      // Check if the fetch was successful and return the query result
      guard status == noErr, let queryResult: AnyObject = result else {
         throw KeyError.error(status) // Throw an error if the fetch was unsuccessful
      }
      return queryResult // Return the query result
   }
   /**
    * Find first item that matches the matchClause
    * - Description: This method searches for the first keychain item that matches the provided matchClause. It returns a tuple containing the key and value of the first matching item. If no matching item is found, it throws an error.
    * - Parameters:
    *   - secClass: Of a particular keychain class such as: `kSecClassGenericPassword` (regular password type)
    *   - service: Application identifier to associate with
    *   - accessGroup: A way to differentiate access between different applications
    *   - access: Defines the access restrictions for the keychain items (Biometric authentication etc)
    *   - matchClause: A closure to match with
    *   - context: Avoids having to authenticate more than once, reuse the biometric authentication context etc
    * ## Examples:
    * let item = KeyParser.firstItem(.genericPassword, matchClause: { $0.to(String.self) == "John" })
    * item.data.to(String.self) // John
    * item.key = // 232934913439481394813944
    */
   public static func first(_ secClass: SecClass = .genericPassword, service: String? = nil, accessGroup: String? = nil, access: KeyAccess? = nil, context: LAContext? = nil, matchClause: MatchClause) throws -> KeyAndValue {
      // Create a query dictionary for fetching all keychain items that match the specified parameters
      let query: QueryDict = .allItemsQuery(
         service: service, // The service name to match. If nil, all services are matched.
         accessGroup: accessGroup, // The access group to match. If nil, all access groups are matched.
         access: access, // The accessibility level to match. If nil, all accessibility levels are matched.
         secClass: secClass, // The security class to match. If nil, all security classes are matched.
         context: context // The context to match. If nil, all contexts are matched.
      )
      var result: AnyObject? // Temporary result variable
      // Fetch items from the keychain using the query dictionary
      let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &result)
      // Check if the fetch was successful and throw an error if it was not
      guard status == noErr else { throw KeySearchError.noMatch(status) }
      let array: [[String: Any]]? = result as? [[String: Any]] // Cast the query result to an array of dictionaries
      // Find the first keychain item that matches the specified criteria
      let firstMatch: [String: Any]? = array?.first {
         guard let value: Data = $0[kSecValueData as String] as? Data else { return false }
         return matchClause(value)
      }
      // Check if a matching keychain item was found and throw an error if it was not
      guard let item: [String: Any] = firstMatch else { throw KeySearchError.noFirst }
      // Extract the key and value data from the matching keychain item
      guard let key: String = item[kSecAttrAccount as String] as? String else {
         throw KeySearchError.noKey
      }
      guard let data: Data = item[kSecValueData as String] as? Data else {
         throw KeySearchError.noValue
      }
      return (key, data) // Return the key and value data as a tuple
   }
}
/**
 * Bulk
 */
extension KeyReader {
   /**
    * Returns all keychain items of a particular combination of params
    * - Description: Retrieves all keychain items that match the specified parameters and returns them as a dictionary of key-value pairs.
    * - Include value to the key parsing method: https://stackoverflow.com/a/57095200
    * - Fixme: ⚠️️ Add accessControl`?`
    * - Parameters:
    *   - secClass: Of a particular KeyChain class such as: `.genericPassword` (regular password type)
    *   - service: Application identifier to associate with
    *   - accessGroup: A way to differentiate access between different applications.
    *   - access: Defines the access restrictions for the keychain items (Biometric authentication etc)
    *   - context: Avoids having to authenticate more than once, reuse the biometric authentication context etc
    * - Returns: [String: Data]
    * ## Examples:
    * let allItems: [String: Data] = KeyChainParser.allItems(.genericPassword) // dictionary
    * allItems.forEach { Swift.print("$0.value: \($0.value.to(type: String.self))") } // prints list of values
    * - Throws: KeyError
    */
   public static func readAll(_ secClass: SecClass = .genericPassword, service: String? = nil, accessGroup: String? = nil, access: KeyAccess? = nil, context: LAContext? = nil) throws -> KeyValueDict {
      let query: QueryDict = .allItemsQuery(
         service: service, // The service name to match. If nil, all services are matched.
         accessGroup: accessGroup, // The access group to match. If nil, all access groups are matched.
         access: access, // The accessibility level to match. If nil, all accessibility levels are matched.
         secClass: secClass, // The security class to match. If nil, all security classes are matched.
         context: context // The context to match. If nil, all contexts are matched.
      )
      var result: AnyObject? // Temporary result variable
      let status: OSStatus = withUnsafeMutablePointer(to: &result) { // Fetch items from keychain
         SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
      }
      guard status == noErr else { throw KeyError.error(status) } // Check if the fetch was successful and throw an error if it was not
      guard let array: [[String: Any]] = result as? [[String: Any]] else {
         throw NSError(domain: "⚠️️ Can't happen", code: 0)
      } // Cast the query result to an array of dictionaries
      var values: KeyValueDict = [String: Data]() // Create an empty dictionary to store the key-value pairs
      array.forEach { // Loop through the array of dictionaries
         // Extract the key from the dictionary
         guard let key: String = $0[kSecAttrAccount as String] as? String else { return }
         // Extract the value from the dictionary
         guard let value: Data = $0[kSecValueData as String] as? Data else { return }
         values[key] = value // Add the key-value pair to the dictionary
      }
      return values
   }
   /**
    * Returns number of keychain-items for this service for instance: bundleIdentifier
    * - Description: Counts the number of keychain items that match the given parameters. This method is useful for determining the quantity of keychain entries for a specific service, access group, accessibility level, or security class without needing to retrieve the actual data.
    * - Fixme: ⚠️️ Add accessControl`?`
    * - Remark: this call doesn't need authentication
    * - Parameters:
    *   - service: The keychain access service to use for records
    *   - accessGroup: The keychain access group to use - ignored on the iOS simulator
    *   - access: The accessibility class to use for records (same as key)
    *   - secClass: security class, default is .genericPassword
    *   - context: Avoids having to authenticate more than once, reuse the biometric authentication context etc
    * - Throws: KeyError
    * - Returns: Count of items matching requirments
    * ## Examples:
    * guard let service: String = Bundle.main.bundleIdentifier else { fatalError("Unable to get bundle id") }
    * let count: Int = KeyParser.count(service: service)
    */
   public static func getCount(service: String? = nil, accessGroup: String? = nil, access: KeyAccess? = nil, secClass: SecClass = .genericPassword, context: LAContext? = nil) throws -> Int {
      try KeyReader.readAll(
         secClass, // The security class of the keychain items to read
         service: service, // The service name to match. If nil, all services are matched.
         accessGroup: accessGroup, // The access group to match. If nil, all access groups are matched.
         access: access, // The accessibility level to match. If nil, all accessibility levels are matched.
         context: context // The context to match. If nil, all contexts are matched.
      ).count // Return the number of keychain items that match the specified parameters
   }
   /**
    * Get the keys of all keychain entries matching params
    * - Description: Retrieves all keys of the keychain entries that match the given parameters. This method is useful when you need to get a list of all keys associated with a particular service, access group, accessibility level, or security class.
    * - Remark: Use `status.readableError` to read status etc
    * - Parameters:
    *   - service: Application identifier to associate with
    *   - accessGroup: A way to differentiate access between different applications
    *   - access: Defines the access restrictions for the keychain items (Biometric authentication etc)
    * - Returns: [String]
    */
   public static func readAllKeys(service: String? = nil, accessGroup: String? = nil, access: KeyAccess? = nil, secClass: SecClass = .genericPassword, context: LAContext? = nil) throws -> [String] {
      let query: QueryDict = .allKeysQuery(
         service: service, // The service name to match. If nil, all services are matched.
         accessGroup: accessGroup, // The access group to match. If nil, all access groups are matched.
         access: access, // The accessibility level to match. If nil, all accessibility levels are matched.
         secClass: secClass, // The security class to match. If nil, all security classes are matched.
         context: context // The context to match. If nil, all contexts are matched.
      )
      var result: AnyObject? // Temporary result variable
      let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &result) // Fetch items from the keychain using the query dictionary
      guard status == errSecSuccess else {
         throw KeyError.error(status)
      } // Check if the fetch was successful and throw an error if it was not
      guard let array: [[AnyHashable: Any?]] = result as? [[AnyHashable: Any?]] else {
         throw KeyError.error(status)
      } // Cast the query result to an array of dictionaries
      return array.compactMap { $0[kSecAttrAccount as String] as? String } // Extract the account names from the dictionaries and return them as an array
   }
}
/**
 * KeySearchError
 */
extension KeyReader {
   /**
    * Used in the .first method
    * - Description: This enumeration is used to define specific error cases that can occur during the key search process in the .first method. These errors include scenarios where the first keychain item is not found, the key is not found, the value is not found, or there is no match in the keychain.
    */
   enum KeySearchError: Error {
      /**
       * An error case for when the first keychain item is not found
       */
      case noFirst
      /**
       * An error case for when the key is not found
       */
      case noKey
      /**
       * An error case for when the value is not found
       */
      case noValue
      /**
       * An error case with an associated value of the OSStatus type for when there is no match in the keychain
       */
      case noMatch(_ status: OSStatus)
   }
}


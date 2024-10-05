import Foundation
import LocalAuthentication
/**
 * This typealias makes code more readable
 * - Description: A `QueryDict` is a typealias for a dictionary that maps `CFString` keys to `Any` values, used for constructing queries to interact with the keychain.
 * - Fixme: ⚠️️ We could possibly use `CFDictionary` directly, find out more about this class
 */
public typealias QueryDict = [CFString: Any]
/**
 * Parsing
 */
extension QueryDict {
   /**
    * Constructs the read query
    * - Abstract: For retreiving Data, does not include meta-data about the item
    * - Description: This method constructs a query dictionary for reading a specific keychain item's data. It does not include metadata about the item, focusing solely on the data content.
    * - Fixme: ⚠️️ Maybe make `QueryParser`? `QueryMaker`? `QueryDict`?
    * - Parameters:
    *   - key: Key to read data from
    *   - service: Application identifier to associate with
    *   - accessGroup: A way to differentiate access between different applications.
    *   - access: Defines the access restrictions for the keychain items (Biometric authentication etc)
    *   - secClass: Of a particular `KeyChain` class such as: `kSecClassGenericPassword` (regular password type)
    *   - context: Avoids having to authenticate more than once, reuse the biometric authentication context etc
    * - Returns: `QueryDict`
    */
   internal static func readQuery(key: String, service: String?, accessGroup: String?, access: KeyAccess?, secClass: SecClass = .genericPassword, context: LAContext? = nil) -> QueryDict {
      let query: QueryDict = [ // Construct a dictionary of query attributes
               kSecAttrAccount: key, // The key name
               kSecClass: secClass.rawValue, // The class of the keychain item
               kSecReturnData: kCFBooleanTrue!, // Return the data of the keychain item (not to be confused with `kSecReturnAttributes`)
               kSecMatchLimit: kSecMatchLimitOne // Find only one item
      ]
      return optionalAttributes(
         query: query, // The query dictionary
         service: service, // The service name
         accessGroup: accessGroup, // The access group
         access: access, // The access level
         context: context // The keychain query context
      ) // Return the optional attributes of the keychain item using the `optionalAttributes` function with the `query`, `service`, `accessGroup`, `access`, and `context` parameters
   }
   /**
    * Constructs a dictionary of query attributes for retrieving all keychain items that match the specified parameters
    * - Description: This method constructs a query dictionary for retrieving all keychain items that match the specified parameters, including service, access group, access restrictions, and keychain class. It is used when you need to obtain a list of all items without their data content, only their attributes.
    * - Parameters:
    *   - service: Application identifier to associate with
    *   - accessGroup: A way to differentiate access between different applications.
    *   - access: Defines the access restrictions for the keychain items (Biometric authentication etc)
    *   - secClass: Of a particular keychain class such as: kSecClassGenericPassword (regular password type)
    *   - context: Avoids having to authenticate more than once, reuse the biometric authentication context etc
    */
   internal static func allKeysQuery(service: String?, accessGroup: String?, access: KeyAccess?, secClass: SecClass, context: LAContext? = nil) -> QueryDict {
      let query: QueryDict = [ // Construct a dictionary of query attributes
               kSecClass: secClass.rawValue, // The class of the keychain item
               kSecReturnAttributes: kCFBooleanTrue!, // Return the attributes of the keychain item (not to be confused with `kSecReturnData`)
               kSecMatchLimitAll: kSecMatchLimit // Find all matching items
      ]
      return optionalAttributes(
         query: query, // The query dictionary
         service: service, // The service name
         accessGroup: accessGroup, // The access group
         access: access, // The access level
         context: context // The keychain query context
      ) // Return the optional attributes of the keychain item using the `optionalAttributes` function with the `query`, `service`, `accessGroup`, `access`, and `context` parameters
   }
   /**
    * Constructs a dictionary of query attributes for retrieving all keychain items of the specified class.
    * - Description: Constructs a dictionary of query attributes for retrieving all keychain items of the specified class.
    * - Remark: Used for `.allItemsQuery` and `.firstItemQuery`
    * - Parameters:
    *   - service: Application identifier to associate with
    *   - accessGroup: A way to differentiate access between different applications.
    *   - access: Defines the access restrictions for the keychain items (Biometric authentication etc)
    *   - secClass: Of a particular keychain class such as: kSecClassGenericPassword (regular password type)
    *   - context: Avoids having to authenticate more than once, reuse the biometric authentication context etc
    */
   internal static func allItemsQuery(service: String?, accessGroup: String?, access: KeyAccess?, secClass: SecClass, context: LAContext? = nil) -> QueryDict {
      optionalAttributes(
         query: secClass.allItemsQuery, // The query for all keychain items of the specified class
         service: service, // The name of the service
         accessGroup: accessGroup, // The access group (not used in this code)
         access: access, // The access control object for the keychain item
         context: context // The context (not used in this code)
      )
   }
}
/**
 * Modifying
 */
extension QueryDict {
   /**
    * Creates modifier query
    * - Description: Constructs a dictionary of query attributes for modifying keychain items, including data, key, service, access group, access restrictions, keychain class, access control, and context.
    * - Remark: This makes the modifier methods cleaner (update, write, delete)
    * - Parameters:
    *   - data: Data to be written
    *   - key: Key to read data from
    *   - service: Application identifier to associate with
    *   - accessGroup: A way to differentiate access between different applications.
    *   - access: Defines the access restrictions for the keychain items (Biometric authentication etc)
    *   - secClass: Of a particular key-chain class such as: kSecClassGenericPassword (regular password type)
    *   - accessControl: Level of access
    *   - context: Avoids having to authenticate more than once, reuse the biometric authentication context etc
    */
   internal static func modifierQuery(data: Data? = nil, key: String, service: String?, accessGroup: String?, access: KeyAccess?, secClass: SecClass = .genericPassword, accessControl: SecAccessControl?, context: LAContext?) -> QueryDict {
      var queryDict: QueryDict = [
         kSecClass: secClass.rawValue, // The class of the keychain item
         kSecAttrAccount: key // The key name
      ]
      if let service: String = service {
         queryDict[kSecAttrService] = service // Add Service if applicable
      }
      if let accessGroup: String = accessGroup {
         queryDict[kSecAttrAccessGroup] = accessGroup // Add the access group if applicable
      }
      if let access: KeyAccess = access {
         queryDict[kSecAttrAccessible] = access.rawValue // Add accessibility if applicable (A value that indicates when your app needs access to the data in a keychain item. The default value is AccessibleWhenUnlocked. For a list of possible values, see KeychainSwiftAccessOptions.)
      }
      if let accessControl: SecAccessControl = accessControl {
         queryDict[kSecAttrAccessControl] = accessControl // Add the access control object if applicable
      }
      if let context: LAContext = context {
         queryDict[kSecUseAuthenticationContext] = context // An LAContext on which `evaluatePolicy` has succeeded
      }
      if let data: Data = data {
         queryDict[kSecValueData] = data // Add data if applicable
      }
      return queryDict
   }
   /**
     * Clear all query
     * - Abstract: Clears all keychain items matching the specified criteria
     * - Description: Constructs a dictionary of query attributes for clearing keychain items, including service, access group, access restrictions, and keychain class.
     * - Remark: This method is useful for removing all keychain items that match the given criteria.
     * - Parameters:
     *   - service: Application identifier to associate with
     *   - accessGroup: A way to differentiate access between different applications.
     *   - access: Defines the access restrictions for the keychain items (Biometric authentication etc)
     *   - secClass: Of a particular key-chain class such as: kSecClassGenericPassword (regular password type)
     */
   internal static func clearAllQuery(service: String?, accessGroup: String?, access: KeyAccess?, secClass: SecClass) -> QueryDict {
      var query: QueryDict = [
         kSecClass: secClass.rawValue // Uniquely identify this keychain accessor
      ]
      if let service: String = service {
         query[kSecAttrService] = service // Add Service if applicable
      }
      if let accessGroup: String = accessGroup {
         query[kSecAttrAccessGroup] = accessGroup // Add the access group if applicable
      }
      if let access: KeyAccess = access {
         query[kSecAttrAccessible] = access.rawValue // Add accessibility if applicable (A value that indicates when your app needs access to the data in a keychain item. The default value is AccessibleWhenUnlocked. For a list of possible values, see KeychainSwiftAccessOptions.)
      }
      return query
   }
}
/**
 * Helper
 */
extension QueryDict {
   /**
    * Add optional attributes
    * - Description: Adds optional attributes to the query dictionary for keychain operations.
    * - Parameters:
    *   - query: Existing query-dict
    *   - service: Application identifier to associate with
    *   - accessGroup: A way to differentiate access between different applications.
    *   - access: Defines the access restrictions for the keychain items (Biometric authentication etc)
    *   - context: Avoids having to authenticate more than once, re-use the biometric authentication context etc
    * - Returns: QueryDict
    */
   fileprivate static func optionalAttributes(query: QueryDict, service: String?, accessGroup: String?, access: KeyAccess?, context: LAContext? = nil) -> QueryDict {
      var query: QueryDict = query // Temp store the variable to modify it below
      if let service: String = service {
         query[kSecAttrService] = service // Add Service if applicable
      }
      if let accessGroup: String = accessGroup {
         query[kSecAttrAccessGroup] = accessGroup // Add the access group if applicable
      }
      if let access: KeyAccess = access {
         query[kSecAttrAccessible] = access.rawValue // Add accessibility if applicable (A value that indicates when your app needs access to the data in a keychain item. The default value is AccessibleWhenUnlocked. For a list of possible values, see KeychainSwiftAccessOptions.)
      }
      if let context: LAContext = context {
         query[kSecUseAuthenticationContext] = context // An LAContext on which `evaluatePolicy` has succeeded
      }
      return query
   }
}

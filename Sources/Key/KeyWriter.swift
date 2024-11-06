import Foundation
import LocalAuthentication
/**
 * KeyWriter
 */
public final class KeyWriter {
   /**
    * Write data to `KeyChain`
    * - Description: This method securely stores or updates data in the
    *                Keychain. If the key already exists, the associated data is
    *                updated. If the key does not exist, a new keychain item is
    *                created with the given key and data.
    * - Remark: Checks if key exists, if it does it updates the item, if it doesn't it creates the item
    * - Parameters:
    *   - key: Key to store data at
    *   - data: Data to store in KeyChain
    *   - service: Application-identifier to associate with (Bundle.main.bundleIdentifier)
    *   - accessGroup: A way to differentiate access between different applications.
    *   - access: Defines the access restrictions for the keychain items (Biometric authentication etc)
    *   - secClass: Of a particular keychain class such as: kSecClassGenericPassword (regular password type)
    *   - accessControl: Access restriction
    *   - context: Avoids having to authenticate more than once, reuse the biometric authentication context etc
    * - Returns: True if write was successful
    * - Throws: Human readable status regarding the action performed
    */
   @discardableResult public static func insert(data: Data, key: String, service: String? = nil, accessGroup: String? = nil, access: KeyAccess? = nil, secClass: SecClass = .genericPassword, accessControl: SecAccessControl?, context: LAContext?) throws -> Bool {
      let value: AnyObject? = try? KeyReader.read(
         key: key, // The key to read from the keychain
         service: service, // The service name to match. If nil, all services are matched.
         accessGroup: accessGroup, // The access group to match. If nil, all access groups are matched.
         access: access, // The accessibility level to match. If nil, all accessibility levels are matched.
         context: context // The context to match. If nil, all contexts are matched.
      )
      guard value == nil else { // if data exists, then just over-write
         return try KeyWriter.update(
            data: data, // The data to be written to the keychain
            key: key, // The key to be used for the keychain item
            service: service, // The service name
            accessGroup: accessGroup, // The access group
            access: access, // The access level
            context: context // The keychain query context
         ) // Data already exists, we're updating not writing.
      }
      let queryDict: QueryDict = .modifierQuery(
         data: data, // The data to write to the keychain
         key: key, // The key to write to the keychain
         service: service, // The service name to match. If nil, all services are matched.
         accessGroup: accessGroup, // The access group to match. If nil, all access groups are matched.
         access: access, // The accessibility level to match. If nil, all accessibility levels are matched.
         secClass: secClass, // The security class to match. If nil, all security classes are matched.
         accessControl: accessControl, // The access control to apply to the keychain item. If nil, no access control is applied.
         context: context // The context to match. If nil, all contexts are matched.
      ) // Build a query
      SecItemDelete(queryDict as CFDictionary) // Make sure you delete first, might not be, needed?
      let status: OSStatus = SecItemAdd(queryDict as CFDictionary, nil) // Use this function to add one or more items to a keychain
      if status != noErr { throw KeyError.error(status) } // Assert that query succeded // let lastResultCode: OSStatus = SecItemCopyMatching(query as CFDictionary, &result)
      else { return true } // Write was a success at this point
   }
   /**
    * Update data for key in KeyChain
    * - Description: This method updates the data associated with a given key in
    *                the Keychain. If the key exists, the associated data is
    *                updated with the new data provided. If the key does not
    *                exist, an error is thrown.
    * - Note: More info: https://stackoverflow.com/a/50661280
    * - Parameters:
    *   - key: Key to store data at
    *   - data: Data to store
    *   - service: Application-identifier to associate with (Bundle.main.bundleIdentifier)
    *   - accessGroup: A way to differentiate access between different applications.
    *   - access: Defines the access restrictions for the keychain items (Biometric authentication etc)
    *   - secClass: Of a particular keychain class such as: kSecClassGenericPassword (regular password type)
    *   - context: Avoids having to authenticate more than once, reuse the biometric authentication context etc
    * - Returns: True if update was success
    * - Throws: Status regarding the action performed
    */
   @discardableResult public static func update(data: Data, key: String, service: String? = nil, accessGroup: String? = nil, access: KeyAccess? = nil, secClass: SecClass = .genericPassword, context: LAContext?) throws -> Bool {
      let queryDict: QueryDict = .modifierQuery(
         key: key, // The key to modify in the keychain
         service: service, // The service name to match. If nil, all services are matched.
         accessGroup: accessGroup, // The access group to match. If nil, all access groups are matched.
         access: access, // The accessibility level to match. If nil, all accessibility levels are matched.
         secClass: secClass, // The security class to match. If nil, all security classes are matched.
         accessControl: nil, // The access control to apply to the keychain item. If nil, no access control is applied.
         context: context // The context to match. If nil, all contexts are matched.
      ) // Build the query
      let attributes: CFDictionary = [kSecValueData: data] as CFDictionary // Compile format for data to store
      let status: OSStatus = SecItemUpdate(queryDict as CFDictionary, attributes) // This function allows you to modify items that match a search query.
      if status != noErr { throw KeyError.error(status) } // Assert that query succeded
      else { return true } // Update was a success at this point
   }
   /**
    * Delete an existing item from the keychain
    * - Description: Deletes a keychain item associated with the given key. If the
    *                item is successfully deleted, the method returns true. If the
    *                item does not exist or an error occurs during deletion, the
    *                method throws a KeyError with the corresponding status.
    * - Note: More similar code: https://github.com/jrendel/SwiftKeychainWrapper/blob/91a7801307f4d0ff29f51a90dc7ee9e0b4250825/SwiftKeychainWrapper/KeychainWrapper.swift#L347
    * - Parameters:
    *   - key: Key to store data at
    *   - data: Data to store
    *   - service: "Application-identifier" to associate with (Bundle.main.bundleIdentifier)
    *   - accessGroup: A way to differentiate access between different applications.
    *   - access: Defines the access restrictions for the keychain items (Biometric authentication etc)
    *   - secClass: Of a particular keychain class such as: kSecClassGenericPassword (regular password type)
    *   - context: Avoids having to authenticate more than once, reuse the biometric authentication context etc
    * - Returns: True if operation was successfull
    * - Throws: Status regarding the action performed
    */
   @discardableResult public static func delete(key: String, service: String? = nil, accessGroup: String? = nil, access: KeyAccess? = nil, secClass: SecClass = .genericPassword, context: LAContext?) throws -> Bool {
      let queryDict: QueryDict = .modifierQuery(
         key: key, // The key to modify in the keychain
         service: service, // The service name to match. If nil, all services are matched.
         accessGroup: accessGroup, // The access group to match. If nil, all access groups are matched.
         access: access, // The accessibility level to match. If nil, all accessibility levels are matched.
         secClass: secClass, // The security class to match. If nil, all security classes are matched.
         accessControl: nil, // The access control to apply to the keychain item. If nil, no access control is applied.
         context: context // The context to match. If nil, all contexts are matched.
      ) // Build the query
      let status: OSStatus = SecItemDelete(queryDict as CFDictionary) // This function removes items that match a search query.
      if status != noErr { throw KeyError.error(status) } // Check for error
      else { return true } // Delete was a success
   }
   /**
    * Clear all keys
    * - Description: This method deletes all keychain items that match the given
    *                parameters such as service, accessGroup, access, and secClass.
    *                It's useful when you need to clear out all keychain items
    *                associated with a particular service, access group, or other
    *                specified attributes.
    * - Remark: Delete items matching the current `ServiceName` and `AccessGroup` if one is set
    * - Remark: Use this over `Key.clearAll`, when faced ith stuborn items that doesn't want to be cleared
    * - Remark: Other types include: `kSecClassGenericPassword`, `kSecClassInternetPassword`, `kSecClassCertificate`, `kSecClassKey`, `kSecClassIdentity`
    * - Note: More similar code: https://github.com/jrendel/SwiftKeychainWrapper/blob/91a7801307f4d0ff29f51a90dc7ee9e0b4250825/SwiftKeychainWrapper/KeychainWrapper.swift#L372
    * - Note: This was recently changed, see https://developer.apple.com/documentation/security/1395547-secitemdelete for more info
    * - Parameters:
    *   - secClass: Of a particular keychain class such as: `kSecClassGenericPassword` (regular password type)
    *   - service: Application identifier to associate with (Bundle.main.bundleIdentifier)
    *   - accessGroup: A way to differentiate access between different applications.
    *   - access: Defines the access restrictions for the keychain items (Biometric authentication etc)
    * - Returns: Returns true or false depending if the action was executed correctly
    * - Throws: status regarding the action performed
    */
   /*@discardableResult */public static func deleteAll(secClass: SecClass = .genericPassword, service: String? = nil, accessGroup: String? = nil, access: KeyAccess? = nil, onComplete: ((_ error: KeyError?) -> Void)? = nil) /*throws -> Bool*/ {
      let queryDict: QueryDict = .clearAllQuery(
         service: service, // The service name to match. If nil, all services are matched.
         accessGroup: accessGroup, // The access group to match. If nil, all access groups are matched.
         access: access, // The accessibility level to match. If nil, all accessibility levels are matched.
         secClass: secClass // The security class to match. If nil, all security classes are matched.
      ) // Build the query
      // Quick fix: This should be called on background thread? 👉 This method should not be called on the main thread as it may lead to UI unresponsiveness. (Warning in recent OS update)
      // var status: OSStatus?
      // let semaphore = DispatchSemaphore(value: 0)
      DispatchQueue.global(qos: .background).async { // We need to put this on the main thread or else transition becomes glitchy
         let status: OSStatus = SecItemDelete(queryDict as CFDictionary) // Execute the deletion
         // semaphore.signal()
         let err: KeyError = .error(status)
         onComplete?(err)
      }
      // _ = semaphore.wait(timeout: .now() + 1)
      // guard let status = status else { throw NSError.init(domain: "sec del did not respond", code: 0) }
      // if status != noErr { throw KeyError.error(status) } // Check for error
      // else { return true } // Clear was a success
   }
}

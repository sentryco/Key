import Foundation
/**
 * KeychainWrapper 
 * - Abstract: This class provides methods for interacting with the keychain, including saving, retrieving, updating, and deleting keychain items.
 * - Description: KeychainWrapper is a class that provides a simple and secure
 *                way to save, retrieve, update, and delete keychain items. It uses
 *                a struct KeychainError to handle error cases and an optional
 *                access group to share keychain data across apps.
 * - Note: This implementation uses a struct KeychainError to handle error cases and an optional access group to share keychain data across apps.
 * - Note: From https://github.com/onmyway133/blog/issues/934
 * - Note: There are a few keychain wrappers around but for simple needs, you can write it yourself
 * - Note: Here is a basic implementation. I use actor to go with async/await, and a struct KeychainError to contain status code in case we want to deal with error cases.
 * - Note: `accessGroup` is to define [kSecAttrAccessGroup](https://developer.apple.com/documentation/security/ksecattraccessgroup) to share keychain across your apps
 * - Note: there is also a keuchainwrapper in the telemetry package
 * - Fixme: ⚠️️ Figure out how to use actor etc 👈 do research how it fits in etc
 */
/*actor*/ 
class KeychainWrapper {
   /**
    * This struct represents an error that occurs during keychain operations.
    * - Description: KeychainError is a struct that encapsulates the status of a
    *                keychain operation. It conforms to the Error protocol,
    *                allowing it to be thrown as an error in Swift. The 'status'
    *                property holds the OSStatus returned by a keychain operation,
    *                providing detailed information about the success or failure
    *                of the operation.
    */
   struct KeychainError: Error {
      let status: OSStatus
   }
   /**
    * This property represents the service name to use for keychain operations.
    * - Description: The 'service' property is a string that represents the
    *                service name for keychain operations. This is typically the
    *                bundle identifier of your app. It is used to distinguish
    *                between different keychain items and is required when
    *                saving, retrieving, updating, or deleting keychain items.
    */
   let service: String
   /**
    * Represents the access group for the keychain. This is used to define [kSecAttrAccessGroup](https://developer.apple.com/documentation/security/ksecattraccessgroup) to share keychain across your apps.
    * - Description: The 'accessGroup' property is an optional string that
    *                specifies an access group for the keychain items. When set,
    *                it allows multiple applications from the same development
    *                team to access the keychain items. If nil, the keychain
    *                items are accessible only to the current application.
    */
   let accessGroup: String?
   /**
    * Initializes a KeychainWrapper instance with a service name and an optional access group.
    * - Description: The initializer sets up the KeychainWrapper with a specific
    *                service name and an optional access group. The service name
    *                is used to identify which items to access in the keychain,
    *                and the access group allows sharing of keychain items among
    *                different apps from the same development team.
    * - Parameters:
    *   - service: The service name to use for keychain operations. This is typically the bundle identifier of your app.
    *   - accessGroup: An optional access group to use for keychain operations. This allows sharing keychain data across apps from the same developer.
    */
   init(service: String, accessGroup: String? = nil) {
      self.service = service
      self.accessGroup = accessGroup
   }
}
/**
 * CRUD
 * - Note: Since we need some common query parameters across few methods,
 *         I usually use helper method. We use kSecClassGenericPassword class
 *         so we set key to kSecAttrAccount
 * ## Examples:
 * ```swift
 * let keychain = KeychainWrapper(service: "com.example.myapp")
 * 
 * // Adding data to the keychain
 * let dataToAdd = "password123".data(using: .utf8)!
 * try? keychain.add(key: "userPassword", data: dataToAdd)
 * 
 * // Updating data in the keychain
 * let updatedData = "newPassword456".data(using: .utf8)!
 * try? keychain.update(key: "userPassword", data: updatedData)
 * 
 * // Deleting data from the keychain
 * try? keychain.delete(key: "userPassword")
 * ```
 */
extension KeychainWrapper {
   /**
    * Deletes a keychain item with the specified key.
    * - Description: Deletes a keychain item with the specified key. If the
    *                deletion fails, it throws a KeychainError with the status
    *                code.
    * - Parameter key: The key of the keychain item to delete.
    */
   func delete(key: String) throws {
      let query: [CFString: Any] = baseQuery(key: key) // Prepare the query dictionary for the keychain item to delete
      let status: OSStatus = SecItemDelete(query as CFDictionary) // Attempt to delete the keychain item using the query dictionary
      if status != errSecSuccess { // Check if the deletion was not successful
         throw KeychainError(status: status) // Throw a KeychainError with the status code if deletion failed
      }
   }
   /**
    * Updates a keychain item with the specified key and data.
    * - Description: This method updates an existing keychain item with the
    *                specified key and new data. If the keychain item does not
    *                exist, the update will fail. If the update operation fails,
    *                it throws a KeychainError with the status code.
    * - Parameters:
    *   - key: The key of the keychain item to update.
    *   - data: The data to update the keychain item with.
    */
   private func update(key: String, data: Data) throws {
      let query: [CFString: Any] = baseQuery(key: key) // Prepare the query dictionary for the keychain item to update
      let updates: [CFString: Any] = [ // Prepare the updates dictionary with the new data
         kSecValueData: data // Set the new data for the keychain item
      ]
      let status: OSStatus = SecItemUpdate(query as CFDictionary, updates as CFDictionary) // Attempt to update the keychain item using the query and updates dictionaries
      if status != errSecSuccess { // Check if the update was not successful
         throw KeychainError(status: status) // Throw a KeychainError with the status code if update failed
      }
   }
   /**
    * Adds a new keychain item with the specified key and data.
    * - Description: This method adds a new keychain item with the specified
    *                key and data. If the keychain item already exists, the
    *                addition will fail. If the addition operation fails, it
    *                throws a KeychainError with the status code.
    * - Parameters:
    *   - key: The key of the keychain item to add.
    *   - data: The data to add to the keychain item.
    */
   private func add(key: String, data: Data) throws {
      var query: [CFString: Any] = baseQuery(key: key) // Prepare the query dictionary for the keychain item to add
      query[kSecValueData] = data // Add the data to the query dictionary
      let status: OSStatus = SecItemAdd(query as CFDictionary, nil) // Attempt to add the keychain item using the query dictionary
      if status != errSecSuccess { // Check if the addition was not successful
         throw KeychainError(status: status) // Throw a KeychainError with the status code if addition failed
      }
   }
}
/**
 * baseQuery
 */
extension KeychainWrapper {
   /**
    * Prepares a base query dictionary for Keychain operations.
    * - Description: This method generates a base query dictionary that is used
    *                for various Keychain operations such as adding, updating,
    *                and deleting keychain items. The dictionary includes the
    *                class of the keychain item, the service attribute, the
    *                account attribute, and the access group attribute if it is
    *                provided.
    * - Parameter key: The key to use for the Keychain query.
    * - Returns: A dictionary containing the base query parameters for Keychain operations.
    */
   fileprivate func baseQuery(key: String) -> [CFString: Any] {
      var query: [CFString: Any] = [:] // Initialize an empty dictionary to hold the query parameters
      query[kSecClass] = kSecClassGenericPassword // Set the class of the keychain item to generic password
      query[kSecAttrService] = service // Set the service attribute to the provided service
      query[kSecAttrAccount] = key // Set the account attribute to the provided key
      if let accessGroup: String { // Check if accessGroup is not nil
         query[kSecAttrAccessGroup] = accessGroup // Set the access group attribute to the provided access group
      }
      return query // Return the prepared query dictionary
   }
}
/**
 * get / set
 */
extension KeychainWrapper {
   /**
    * Retrieves data associated with a given key from the Keychain.
    * - Description: Retrieves the data associated with the specified key from
    *                the Keychain. If the data is found, it is returned as a Data
    *                object. If no data is found or an error occurs, a KeychainError
    *                is thrown detailing the issue.
    * - Parameter key: The key to use for retrieving data from the Keychain.
    * - Returns: The data associated with the given key, or throws an error if retrieval fails.
    */
   func get(key: String) throws -> Data {
      var query: [CFString: Any] = baseQuery(key: key) // Prepare the query dictionary for the keychain item to retrieve
      query[kSecMatchLimit] = kSecMatchLimitOne // Set the match limit to one to ensure only one item is returned
      query[kSecReturnAttributes] = kCFBooleanTrue // Request the attributes of the keychain item to be returned
      query[kSecReturnData] = kCFBooleanTrue // Request the data of the keychain item to be returned
      var obj: AnyObject? // Declare a variable to hold the result of the query
      let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &obj) // Attempt to copy the matching keychain item using the query dictionary
      if status == errSecSuccess, // Check if the query was successful
         let json: [CFString: AnyObject] = obj as? [CFString: AnyObject], // Attempt to cast the result to a dictionary
         let data: Data = json[kSecValueData] as? Data { // Attempt to extract the data from the dictionary
         return data // Return the retrieved data
      } else { // If the query was not successful
         throw KeychainError(status: status) // Throw a KeychainError with the status code
      }
   }
   /**
    * Stores data associated with a given key in the Keychain.
    * - Description: This method securely stores the provided data associated
    *                with the specified key in the Keychain. If an item with the
    *                same key already exists, it updates the existing item with
    *                the new data. If no item exists, it creates a new keychain
    *                item with the given key and data.
    * - asbtract: This method attempts to store the provided data under the specified key in the Keychain. If the data is successfully stored, it returns without throwing an error. If the operation fails, it throws a KeychainError.
    * - Parameters:
    *   - key: The key under which the data will be stored in the Keychain.
    *   - data: The data to be stored in the Keychain.
    */
   func set(key: String, data: Data) throws {
      do { // Start a do-catch block to handle potential errors
         _ = try get(key: key) // Attempt to retrieve the data associated with the given key from the Keychain
         try update(key: key, data: data) // If the data exists, attempt to update it with the new data
      } catch let error as KeychainError { // Catch any KeychainError that occurs during the get or update operations
         if error.status == errSecItemNotFound { // Check if the error status indicates that the item was not found
            try add(key: key, data: data) // If the item was not found, attempt to add the new data to the Keychain
         }
      }
   }
}
// Fixme: remove the bellow or move somewhere else? 

// If there is no error, then OSStatus will be errSecSuccess which has value 0

// There are some other query attributes like

// [kSecAttrAccessible](https://developer.apple.com/documentation/security/ksecattraccessible) to set security attribute, like [kSecAttrAccessibleWhenUnlocked](https://developer.apple.com/documentation/security/ksecattraccessiblewhenunlocked)

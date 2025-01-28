import Foundation
/**
 * High-level `KeyChain` wrapper (Simplifies working with the KeyChain API)
 * - Description: `Key` is a high-level Keychain wrapper that simplifies
 *                interactions with the iOS Keychain API, providing methods
 *                for securely storing, retrieving, and managing data.
 * - Remark: Example code and tests are in the `KeyExample` xcode project
 *           (KeyChain doesn't work well outside xcode projects, it can be done
 *           but requires attaching a target etc, maybe add that later etc?)
 * - Remark: This framework enables writing and reading raw data into keychain.
 *           Storing structs or other objects that are serializable to Data.
 *           Keychain should not be used to store vast amounts of data. So use
 *           this functionality with some caution.
 * - Remark: There is a lot of subtle documentation for different cases
 *           throughout this framework that can be useful for expert usage etc
 * - Note: More unit tests: https://www.raywenderlich.com/9240-keychain-services-api-tutorial-for-passwords-in-swift
 * - Note: More unit tests: https://gist.github.com/s-aska/e7ad24175fb7b04f78e7#file-keychaintests-swift
 * - Fixme: ⚠️️ Add has(query) assert method
 */
public final class Key {}

extension Key {
   /**
    * A serial dispatch queue to ensure thread-safe access to keychain operations.
    *
    * Keychain operations are performed synchronously on this queue to prevent data races
    * and ensure consistency across concurrent accesses.
    */
   private static let keychainQueue = DispatchQueue(label: "key.keychainQueue")
   /**
    * Get result for `KeyQuery` Returns Data & throws Error msg
    * - Description: Retrieves the data associated with a given `KeyQuery` from
    *                the keychain and returns it. If the data is not found or an
    *                error occurs, this method throws an error.
    * - Parameter query: The "address" for the keychain
    * ## Examples:
    * Key.get(query: .init(key: "1234")).string // Reads data (you might have to cast as Data and init utf8 string from data now)
    */
   public static func read(_ query: KeyQuery) throws -> AnyObject {
      try keychainQueue.sync {
         try KeyReader.read(
            key: query.key, // The key to read from the keychain
            service: query.service, // The service name to match. If nil, all services are matched.
            accessGroup: query.accessGroup, // The access group to match. If nil, all access groups are matched.
            access: query.access, // The accessibility level to match. If nil, all accessibility levels are matched.
            secClass: query.secClass, // The security class to match. If nil, all security classes are matched.
            context: query.context // The context to match. If nil, all contexts are matched.
         )
      }
   }
   /**
    * Set data for keyQuery (returns error msg)
    * - Description: Inserts or updates a keychain item with the specified data and query parameters.
    * - Remark: Setting bio-auth locked items doesn't require context, only reading does
    * - Remark: Insert is also used as an update method, as the write call
    *           creates new or alters pre-existing item etc
    * ## Examples:
    * Key.set(data: .init(from: "Hello world"), query: .init(key: "1234")) // stores data
    * - Parameters:
    *   - data: The date to store in the "keychain-database"
    *   - query: The address in the "keychain-address"
    * - Throws: Status error
    */
   public static func insert(data: Data, query: KeyQuery) throws {
      _ = try keychainQueue.sync {
         try KeyWriter.insert(
            data: data, // The data to write to the keychain
            key: query.key, // The key to write to the keychain
            service: query.service, // The service name to match. If nil, all services are matched.
            accessGroup: query.accessGroup, // The access group to match. If nil, all access groups are matched.
            access: query.access, // The accessibility level to match. If nil, all accessibility levels are matched.
            secClass: query.secClass, // The security class to match. If nil, all security classes are matched.
            accessControl: query.accessControl, // The access control to apply to the keychain item. If nil, no access control is applied.
            context: query.context // The context to match. If nil, all contexts are matched.
         )
      }
   }
   /**
    * Clear one item for a query
    * - Description: Deletes a keychain item that matches the specified query parameters.
    * - Parameter query: The address in the keychain address
    * - Throws: Status error
    * - Example: Delete the keychain item with key "MyKey" and service name "MyService" and accessibility level .accessibleWhenUnlocked:
    * ```
    * let query = QueryDict(
    *     key: "MyKey", // The key to match
    *     service: "MyService", // The service name to match. If nil, all services are matched.
    *     accessGroup: nil, // The access group to match. If nil, all access groups are matched.
    *     access: .accessibleWhenUnlocked, // The accessibility level to match. If nil, all accessibility levels are matched.
    *     secClass: .genericPassword, // The security class to match. If nil, all security classes are matched.
    *     context: nil // The context to match. If nil, all contexts are matched.
    * )
    *
    * do {
    *     try KeyWriter.delete(query: query)
    *     print("Keychain item deleted")
    * } catch {
    *     print("Error deleting keychain item: \(error)")
    * }
    * ```
    */
   public static func delete(_ query: KeyQuery) throws {
      _ = try keychainQueue.sync {
         try KeyWriter.delete(
            key: query.key, // The key to delete from the keychain
            service: query.service, // The service name to match. If nil, all services are matched.
            accessGroup: query.accessGroup, // The access group to match. If nil, all access groups are matched.
            access: query.access, // The accessibility level to match. If nil, all accessibility levels are matched.
            secClass: query.secClass, // The security class to match. If nil, all security classes are matched.
            context: query.context // The context to match. If nil, all contexts are matched.
         )
      }
   }
   /**
    * Clears all items in `KeyChain` that matches the `KeyQuery` (returns delete count)
    * - Description: Removes all keychain items that match the given query
    *                parameters. This method is useful when you need to reset or
    *                clear out all keychain items associated with a particular
    *                service, access group, or other specified attributes.
    * - Remark: We can set key in query to "", since it has no relevance calling this method etc
    * - Remark: This won't remove other `KeyChain` entries you did not add via the current app
    * - Parameter query: The query construct
    * - Throws: Status error
    * - Example: Delete all keychain items with service name "MyService" and accessibility level .accessibleWhenUnlocked:
    * ```
    * let query = QueryDict.clearAllQuery(
    *     service: "MyService", // The service name to match. If nil, all services are matched.
    *     accessGroup: nil, // The access group to match. If nil, all access groups are matched.
    *     access: .accessibleWhenUnlocked, // The accessibility level to match. If nil, all accessibility levels are matched.
    *     secClass: .genericPassword // The security class to match. If nil, all security classes are matched.
    * )
    *
    * do {
    *     let count = try KeyWriter.delete(query: query)
    *     print("Deleted \(count) keychain items")
    * } catch {
    *     print("Error deleting keychain items: \(error)")
    * }
    * ```
    * - Fixme: ⚠️️ make this async later
    */
   public static func deleteAll(_ query: KeyQuery? = nil) throws {
      let queryDict: QueryDict = .clearAllQuery(
         service: query?.service, // The service name to match. If nil, all services are matched.
         accessGroup: query?.accessGroup, // The access group to match. If nil, all access groups are matched.
         access: query?.access, // The accessibility level to match. If nil, all accessibility levels are matched.
         secClass: query?.secClass ?? .genericPassword // The security class to match. If nil, the generic password class is matched.
      )
      let semaphore = DispatchSemaphore(value: 0)
      var deletionResult: Result<Void, KeyError>?
      keychainQueue.sync {
         KeyWriter.deleteAllItems(queryDict: queryDict) { result in
            deletionResult = result
            semaphore.signal()
         }
      }
      semaphore.wait()
      switch deletionResult {
      case .success:
         return
      case .failure(let error):
         throw error
      case .none:
         // Should not happen
         throw KeyError.error(errSecInternalComponent)
      }
   }
   /**
    * Count (convenient)
    * - Description: Returns the count of keychain items that match the given
    *                query parameters. This method is useful for verifying the
    *                number of items that meet specific criteria such as service
    *                name, access group, accessibility level, and security class.
    * - Example: Count the number of keychain items with service name "MyService" and accessibility level .accessibleWhenUnlocked:
    * ```
    * let count = try? KeyReader.getCount(
    *     service: "MyService", // The service name to match. If nil, all services are matched.
    *     accessGroup: nil, // The access group to match. If nil, all access groups are matched.
    *     access: .accessibleWhenUnlocked, // The accessibility level to match. If nil, all accessibility levels are matched.
    *     secClass: .genericPassword, // The security class to match. If nil, all security classes are matched.
    *     context: nil // The context to match. If nil, all contexts are matched.
    * )
    *
    * if let count = count {
    *     print("Number of keychain items: \(count)")
    * } else {
    *     print("Error counting keychain items")
    * }
    * ```
    * - Parameter query: The query object that specifies the parameters
    *                    to match. If nil, all parameters are matched.
    * - Throws: An error if the delete operation fails.
    */
   public static func getCount(_ query: KeyQuery? = nil) throws -> Int {
      try keychainQueue.sync {
       try KeyReader.getCount(
         service: query?.service, // The service name to match. If nil, all services are matched.
         accessGroup: query?.accessGroup, // The access group to match. If nil, all access groups are matched.
         access: query?.access, // The accessibility level to match. If nil, all accessibility levels are matched.
         secClass: query?.secClass ?? .genericPassword, // The security class to match. If nil, the generic password class is matched.
         context: query?.context // The context to match. If nil, all contexts are matched.
      )
    }
      
   }
}
/**
 * Convenient
 */
extension Key {
   /**
    * Inserts a UTF-8 encoded string into the keychain.
    *
    * This method converts the provided string into `Data` using UTF-8 encoding and inserts it into the keychain
    * based on the specified `KeyQuery`. If the string cannot be encoded, it throws a `KeychainError.unexpectedData` error.
    *
    * - Parameters:
    *   - string: The string to be stored in the keychain.
    *   - query: The `KeyQuery` object specifying the parameters for storing the data in the keychain.
    *
    * ## Examples:
    * ```
    * do {
    *     try Key.insert(string: "SecurePassword123!", query: KeyQuery(key: "userPassword"))
    *     print("String successfully inserted into the keychain.")
    * } catch {
    *     print("Failed to insert string into the keychain: \(error)")
    * }
    * ```
    *
    * - Throws: `KeychainError.unexpectedData` if the string cannot be converted to `Data`.
    *           Propagates errors thrown by the underlying `insert(data:query:)` method.
    */
   public static func insert(
      string: String,
      query: KeyQuery
   ) throws {
      guard let data = string.data(using: .utf8) else {
         throw KeychainError.unexpectedData
      }
      try insert(data: data, query: query)
   }
   
   /**
    * Reads a UTF-8 encoded string from the keychain based on the specified query.
    *
    * This method retrieves the data associated with the provided `KeyQuery`, attempts to decode it as a UTF-8 string,
    * and returns the resulting string. If the data cannot be decoded, it throws a `KeychainError.unexpectedData` error.
    *
    * - Parameter query: The `KeyQuery` object specifying the parameters for retrieving the data from the keychain.
    *
    * ## Examples:
    * ```
    * do {
    *     let retrievedString = try Key.readString(KeyQuery(key: "userPassword"))
    *     print("Retrieved string from keychain: \(retrievedString)")
    * } catch {
    *     print("Failed to read string from keychain: \(error)")
    * }
    * ```
    *
    * - Returns: The decoded string retrieved from the keychain.
    *
    * - Throws: `KeychainError.unexpectedData` if the data cannot be decoded as a UTF-8 string.
    *           Propagates errors thrown by the underlying `read(_:)` method.
    */
   public static func readString(_ query: KeyQuery) throws -> String {
      guard let data = try read(query) as? Data,
            let string = String(data: data, encoding: .utf8) else {
         throw KeychainError.unexpectedData
      }
      return string
   }
   
   /**
    * Inserts a `Codable` object into the keychain by encoding it to JSON.
    *
    * This generic method encodes the provided `Codable` object into `Data` using `JSONEncoder` and inserts it into the keychain
    * based on the specified `KeyQuery`. If encoding fails, it propagates the thrown error.
    *
    * - Parameters:
    *   - codable: The `Codable` object to be stored in the keychain.
    *   - query: The `KeyQuery` object specifying the parameters for storing the data in the keychain.
    *
    * ## Examples:
    * ```
    * struct User: Codable {
    *     let username: String
    *     let email: String
    * }
    *
    * let user = User(username: "john_doe", email: "john@example.com")
    *
    * do {
    *     try Key.insert(codable: user, query: KeyQuery(key: "currentUser"))
    *     print("User successfully inserted into the keychain.")
    * } catch {
    *     print("Failed to insert user into the keychain: \(error)")
    * }
    * ```
    *
    * - Throws: Propagates errors thrown by `JSONEncoder` or the underlying `insert(data:query:)` method.
    */
   public static func insert<T: Codable>(
      codable: T,
      query: KeyQuery
   ) throws {
      let data = try JSONEncoder().encode(codable)
      try insert(data: data, query: query)
   }
   
   /**
    * Reads and decodes a `Codable` object from the keychain based on the specified query.
    *
    * This generic method retrieves the data associated with the provided `KeyQuery`, decodes it into the specified `Codable` type
    * using `JSONDecoder`, and returns the resulting object. If decoding fails, it propagates the thrown error.
    *
    * - Parameters:
    *   - query: The `KeyQuery` object specifying the parameters for retrieving the data from the keychain.
    *   - type: The type of the `Codable` object to decode.
    *
    * ## Examples:
    * ```
    * struct User: Codable {
    *     let username: String
    *     let email: String
    * }
    *
    * do {
    *     let user: User = try Key.readCodable(KeyQuery(key: "currentUser"), type: User.self)
    *     print("Retrieved user from keychain: \(user)")
    * } catch {
    *     print("Failed to read user from the keychain: \(error)")
    * }
    * ```
    *
    * - Returns: The decoded `Codable` object retrieved from the keychain.
    *
    * - Throws: `KeychainError.unexpectedData` if the data cannot be cast to `Data`.
    *           Propagates errors thrown by `JSONDecoder` or the underlying `read(_:)` method.
    */
   public static func readCodable<T: Codable>(_ query: KeyQuery, type: T.Type) throws -> T {
      guard let data = try read(query) as? Data else {
         throw KeychainError.unexpectedData
      }
      return try JSONDecoder().decode(T.self, from: data)
   }
}

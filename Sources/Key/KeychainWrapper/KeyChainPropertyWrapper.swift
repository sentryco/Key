import SwiftUI
 /**
  * KeyChainPropertyWrapper
  * - Note: Can be used to test things out quick etc, but lacks propegating error etc, sometimes we don't need to propegate errors ? or?
  * - Note: Used in CryptoDB
  * - Description: This property wrapper simplifies the process of interacting
  *                with the keychain by providing a Swift property syntax for
  *                storing and retrieving secure data. It abstracts away the
  *                complexity of keychain services and provides a more Swifty API.
  * - Fixme: ⚠️️ add support for shared access group etc, so we can support af extension etc
  * - Fixme: ⚠️️ Maybe deprecate? out of scope? not useful enough?
  * - Abstract: A property wrapper that provides a convenient interface for storing and retrieving data from the keychain.
  * - Note: This property wrapper uses a KeychainWrapper instance to perform keychain operations.
  * - Parameters:
  *   - key: The key used to identify the data in the keychain
  *   - service: The service identifier for the keychain
  * ## Examples
  * @KeyChainPropertyWrapper(key: "password", service: "com.domain.app") var textData: Data?
  * let textData = inputText.data(using: .utf8)
  * self.textData = textData
  * if let textData = textData {
  *    Text(String(data: textData, encoding: .utf8) ?? "no saved text")
  * }
  */
@propertyWrapper // lets us interact with an underlaying structure in a simpler way
public struct KeyChainPropertyWrapper: DynamicProperty {
   /**
    * State variable to hold the data
    * - Description: Holds the current value of the keychain item's data,
    *                which can be read or written by the SwiftUI view.
    */
   @State var data: Data?
   /**
    * The key used to identify the data in the keychain
    * - Description: The unique string that represents the name of the keychain
    *                item for storing and retrieving the data.
    */
   var key: String
   /**
    * The KeychainWrapper instance for keychain operations
    * - Description: An instance of `KeychainWrapper` that handles the low-level
    *                interactions with the keychain services for storing and
    *                retrieving the data associated with the `key`.
    */
   let keychain: KeychainWrapper
   /**
    * The property wrapper's wrapped value
    * - Description: This property represents the data that is stored in the
    *                keychain. It provides a getter and a setter for reading and
    *                writing data to the keychain. The getter returns the current
    *                data stored in the keychain. The setter updates the data in
    *                the keychain and also updates the local state variable.
    */
   public var wrappedValue: Data? {
      get {
         data // Getter for the data
      }
      nonmutating set { // Setter for the wrapped value, marked as nonmutating to allow mutation of the state variable (indirect setter)
         guard let newValue: Data = newValue else { // Check if newValue is not nil
            data = nil // Set data to nil if newValue is nil
            try? keychain.delete(key: key) // Attempt to delete the key from the keychain
            return // Exit the setter early
         }
         do {
            try keychain.set( // Attempt to set the key with the new value in the keychain
               key: key, // Specifies the key to use for storing the data in the keychain
               data: newValue // The data to be stored in the keychain
            )
         } catch {
            Swift.print("⚠️️ no data - err: \(error.localizedDescription)") // Log an error if setting the key fails
         }
         data = newValue // Set the data to the new value
      }
   }
   /**
    * Initializes a `KeyChainPropertyWrapper` instance with a specified key and service.
    * - Description: This initializer creates a new instance of 
    *                `KeyChainPropertyWrapper` using a specified key and service.
    *                It assigns the provided key to the property wrapper's key 
    *                and initializes a `KeychainWrapper` instance with the 
    *                provided service and no access group. It then attempts to 
    *                retrieve data from the keychain using the provided key and 
    *                initializes the `_data` state with the result.
    * - Parameters:
    *   - key: The key used to identify the data in the keychain.
    *   - service: The service identifier for the keychain.
    */
   public init(key: String, service: String) {
      self.key = key // Assigns the provided key to the property wrapper's key
      self.keychain = KeychainWrapper(
         service: service, // The service identifier for the keychain
         accessGroup: nil // The access group for the keychain, set to nil for the default access group
      ) // Initializes a KeychainWrapper instance with the provided service and no access group
      do {
         _data = State(wrappedValue: try keychain.get(key: key)) // Attempts to retrieve data from the keychain using the provided key and initializes the _data state with the result
      } catch {
         Swift.print("⚠️️ unable to set keychain - err: \(error.localizedDescription)") // Logs an error message if retrieving data from the keychain fails
      }
   }
}

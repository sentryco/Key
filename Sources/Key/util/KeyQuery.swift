import Foundation
import LocalAuthentication
/**
 * - Description: A structure representing a query to interact with the Keychain. It encapsulates various parameters required to perform keychain operations such as storing, retrieving, and deleting keychain items.
 * - Remark: Ignore the access-group if running on the iPhone simulator. (Because simulator doesn't support access group etc)
 * - Remark: Apps that are built for the simulator aren't signed, so there's no keychain access group for the simulator to check.
 * - Remark: If a `SecItem` contains an access group attribute, `SecItemAdd` and `SecItemUpdate` on the simulator will return -25243 (errSecNoAccessForItem).
 */
public struct KeyQuery {
   public let key: String // The key to check for. (also called account)
   public let service: String? // ServiceName: The ServiceName for this instance. Used to uniquely identify all keys stored using this keychain wrapper instance.
   public let accessGroup: String? // AccessGroup is used for the kSecAttrAccessGroup property to identify which Keychain Access Group this entry belongs to. This allows you to use the KeychainWrapper with shared keychain access between different applications.
   public let access: KeyAccess? // Accessibility: A value that indicates when your app needs access to the data in a keychain item. The default value is AccessibleWhenUnlocked. For a list of possible values, see KeychainSwiftAccessOptions.
   public let secClass: SecClass // Security class: The class of the keychain item.
   public let accessControl: SecAccessControl? // Access restrictions: A value that indicates the access control settings for a keychain item.
   public let context: LAContext? // Used for biometric-auth: An LAContext on which `evaluatePolicy` has succeeded.
   /**
    * This is the query to interact with KeyChain (You query the keychain database etc)
    * - Description: This property represents the query dictionary used to interact with the Keychain. It contains various attributes such as the key, service, access group, access control, and context, which are used to configure the keychain operations.
    * - Fixme: ⚠️️ Maybe make key optional as well, as clearAll doesn't use key etc
    * - Parameters:
    *   - key: Dictionary key to store data at
    *   - service: The keychain access service to use for records
    *   - accessGroup: The keychain access group to use - ignored on the iOS simulator
    *   - access: The accessibility class to use for records (same as key)
    *   - secClass: Security class, default is `.genericPassword`
    *   - accessControl: - Fixme: ⚠️️ Write doc?
    *   - context: Avoids having to authenticate more than once, reuse the biometric authentication context etc
    */
   public init(key: String = "", service: String? = nil, accessGroup: String? = nil, access: KeyAccess? = nil, secClass: SecClass = .genericPassword, accessControl: SecAccessControl? = nil, context: LAContext? = nil) {
      self.key = key
      self.service = service
      self.access = access
      self.secClass = secClass
      self.accessGroup = accessGroup
      // #if TARGET_OS_IOS || TARGET_OS_MAC && !TARGET_OS_SIMULATOR
      // // - Fixme: ⚠️️ test if this works
      // self.accessGroup = accessGroup
      // #endif
      self.accessControl = accessControl
      self.context = context
   }
}

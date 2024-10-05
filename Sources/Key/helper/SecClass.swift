import Foundation
/**
 * SecurityClass - Different types of item-types that keychain support
 * - Description: Enum representing different types of item classes that the keychain supports.
 */
public enum SecClass: String {
   /**
    * The class for internet password items
    * - Description: Represents keychain items that store internet passwords.
    */
   case internetPassword
   /**
    * The class for generic password items
    * - Description: Represents keychain items that store generic passwords.
    */
   case genericPassword
   /**
    * The class for certificate items
    * - Description: Represents keychain items that store certificates.
    */
   case certificate
   /**
    * The class for key items
    * - Description: Represents keychain items that store cryptographic keys.
    */
   case keys
   /**
    * The class for identity items
    * - Description: Represents keychain items that store identities, which are combinations of certificates and private keys.
    */
   case identity
}
/**
 * Getter
 */
extension SecClass {
    /**
     * Converts the SecClass enum case to its corresponding string value used in keychain queries.
     * - Description: This computed property returns the raw string value associated with each SecClass enum case. 
     *   These string values are used to specify the class of keychain items in keychain queries.
     * - Remark: We have to write set the string in-directly like this, direct reference won't work
     */
   public var rawValue: String {
      switch self {
         case .genericPassword:
            return kSecClassGenericPassword as String // The class for generic password items ("genp")
         case .internetPassword:
            return kSecClassInternetPassword as String // The class for internet password items ("inet")
         case .certificate:
            return kSecClassCertificate as String // The class for certificate items ("cert")
         case .keys:
            return kSecClassKey as String // The class for key items ("keys" - An item class key used to construct a Keychain search dictionary.)
         case .identity:
            return kSecClassIdentity as String // The class for identity items ("idnt")
      }
   }
    /**
     * Query to get all items in keychain
     * - Abstract: Constructs a query dictionary to retrieve all items in the keychain.
     * - Description: This property generates a dictionary that can be used to query the keychain for all items of the specified class.
     * - Remark: The query dictionary includes options to return the data, attributes, and references of the keychain items, and to match an unlimited number of items.
     */
   internal var allItemsQuery: QueryDict {
      [
         kSecClass: self.rawValue, // The class of the keychain item
         kSecReturnData: kCFBooleanTrue!, // Return the data of the keychain item (not to be confused with `kSecReturnAttributes`)
         kSecReturnAttributes: kCFBooleanTrue!, // A key whose value is a Boolean indicating whether or not to return item attributes
         kSecReturnRef: kCFBooleanTrue!, // A key whose value is a Boolean indicating whether or not to return a reference to the keychain item
         kSecMatchLimit: kSecMatchLimitAll // A value that corresponds to matching an unlimited number of items
      ]
   }
}

import Foundation
/**
 * Defines the access restrictions for the underlying keychain items
 * - Description: Enumerates the various accessibility options for keychain
 *                items, corresponding to when and how the data can be accessed
 *                and whether it can be transferred to a new device or backup.
 * - Remark: It maps 1:1 with `kSecAttrAccessible` values
 * - Remark: This is not the same as: `kSecAttrAccessControl`
 * - Fixme: ⚠️️ More similar code: https://github.com/jrendel/SwiftKeychainWrapper/blob/develop/SwiftKeychainWrapper/KeychainItemAccessibility.swift
 */
public enum KeyAccess: RawRepresentable {
   /**
    * Data can only be accessed while the device is unlocked
    * - Description: Specifies that the keychain item is accessible only when
    *                the device is unlocked. If the device is locked, the item
    *                cannot be accessed.
    * - Remark: This is recommended for items that only need to be accessible while the application is in the foreground.
    * - Remark: Data with this attribute will migrate to a new device when using encrypted backups.
    */
   case whenUnlocked
   /**
    * Data can only be accessed once the device has been unlocked after a restart
    * - Description: Specifies that the keychain item is accessible after the
    *                device has been unlocked once. If the device is restarted,
    *                the item is not accessible until the device has been
    *                unlocked again.
    * - Remark: This is recommended for items that need to be accessible by background applications.
    * - Remark: Data with this attribute will migrate to a new device when using encrypted backups.
    * - Fixme: ⚠️️ duplicate description? same as afterFirstUnlockThisDeviceOnly etc?
    */
   case afterFirstUnlock
   /**
    * Data can only be accessed while the device is unlocked
    * - Description: Specifies that the keychain item is accessible only when
    *                the device is unlocked. This keychain item cannot migrate
    *                to a new device. This means that the item will not be
    *                included in backups and will not be present if the user
    *                restores the device from a backup or migrates to a new
    *                device.
    * - Remark: This is recommended for items that only need be accessible while the application is in the foreground.
    * - Remark: Items with this attribute will never migrate to a new device, so after a backup is restored to a new device, these items will be missing.
    */
   case whenUnlockedThisDeviceOnly
   /**
    * Data can only be accessed once the device has been unlocked after a restart
    * - Description: Specifies that the keychain item is accessible after the
    *                device has been unlocked once. If the device is restarted,
    *                the item is not accessible until the device has been
    *                unlocked again. This keychain item cannot migrate to a new
    *                device. This means that the item will not be included in
    *                backups and will not be present if the user restores the
    *                device from a backup or migrates to a new device.
    * - Remark: This is recommended for items that need to be accessible by background applications
    * - Remark: Items with this attribute will never migrate to a new device, so after a backup is restored to a new device these items will be missing.
    * - Fixme: ⚠️️ duplicate description? same as whenUnlocked etc?
    */
   case afterFirstUnlockThisDeviceOnly
}
/**
 * Init
 */
extension KeyAccess {
   /**
    * Returns a new `KeyAccess` value using a `kSecAttrAccessible` value
    * - Description: Initializes a `KeyAccess` instance from a `CFString` representing a `kSecAttrAccessible` value.
    * - Parameter rawValue: A `CFString` representing a kSecAttrAccessible value
    */
   public init?(rawValue: CFString) {
      switch rawValue {
      case kSecAttrAccessibleWhenUnlocked:
         self = .whenUnlocked // The data in the keychain item can be accessed only while the device is unlocked by the user.
      case kSecAttrAccessibleAfterFirstUnlock:
         self = .afterFirstUnlock // The data in the keychain item can be accessed only while the device is unlocked by the user. After the first unlock, the data remains accessible until the device is restarted.
      case kSecAttrAccessibleWhenUnlockedThisDeviceOnly:
         self = .whenUnlockedThisDeviceOnly // The data in the keychain item can be accessed only while the device is unlocked by the user. This keychain item cannot migrate to a new device.
      case kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly:
         self = .afterFirstUnlockThisDeviceOnly // The data in the keychain item can be accessed only while the device is unlocked by the user. After the first unlock, the data remains accessible until the device is restarted. This keychain item cannot migrate to a new device.
      default: return nil
      }
   }
   /**
    * Get the `rawValue` of the current enum type. Will be a `kSecAttrAccessible` value
    * - Description: This computed property returns the corresponding
    *                `kSecAttrAccessible` value for each `KeyAccess` case.
    * - Remark: These options are used to determine when a keychain item
    *           should be readable. The default value is AccessibleWhenUnlocked.
    */
   public var rawValue: CFString {
      switch self {
      /**
       * The data in the keychain item can be accessed only while the device is unlocked by the user.
       * - Note: This is recommended for items that need to be accessible
       *         only while the application is in the foreground. Items with
       *         this attribute migrate to a new device when using encrypted
       *         backups.
       * - Note: This is the default value for keychain items added without
       *         explicitly setting an accessibility constant.
       * - Description: The `whenUnlocked` accessibility level ensures that
       *                the keychain item is secure and only accessible while
       *                the device is unlocked, providing a balance between
       *                security and accessibility.
       */
      case .whenUnlocked: return kSecAttrAccessibleWhenUnlocked
      /**
       * - Abstract: The data in the keychain item cannot be accessed after a
       *            restart until the device has been unlocked once by the user.
       * - Note: After the first unlock, the data remains accessible until the
       *         next restart. This is recommended for items that need to be
       *         accessed by background applications. Items with this attribute
       *         migrate to a new device when using encrypted backups.
       * - Description: This accessibility level ensures that the keychain item
       *                is secure and only accessible after the device has been
       *                unlocked once after a restart, providing a balance
       *                between security and accessibility. This is especially
       *                useful for items that need to be accessed by background
       *                applications. Items with this attribute migrate to a new
       *                device when using encrypted backups.
       */
      case .afterFirstUnlock: return kSecAttrAccessibleAfterFirstUnlock
      /**
       * - Abstract: The data in the keychain item can be accessed only while
       *             the device is unlocked by the user.
       * - Note: This is recommended for items that need to be accessible only
       *         while the application is in the foreground. Items with this
       *         attribute do not migrate to a new device. Thus, after restoring
       *         from a backup of a different device, these items will not be
       *         present.
       * - Description: This accessibility level ensures that the keychain item
       *                is secure and only accessible while the device is
       *                unlocked, providing a balance between security and
       *                accessibility. This is especially useful for items that
       *                need to be accessed by foreground applications. Items
       *                with this attribute do not migrate to a new device. Thus,
       *                after restoring from a backup of a different device,
       *                these items will not be present.
       */
      case .whenUnlockedThisDeviceOnly: return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
      /**
       * - Abstract: The data in the keychain item cannot be accessed after a
       *             restart until the device has been unlocked once by the user.
       * - Note: After the first unlock, the data remains accessible until the
       *         next restart. This is recommended for items that need to be
       *         accessed by background applications. Items with this attribute
       *         do not migrate to a new device. Thus, after restoring from a
       *         backup of a different device, these items will not be present.
       * - Description: The data in the keychain item cannot be accessed after a
       *                restart until the device has been unlocked once by the user.
       * - Remark: After the first unlock, the data remains accessible until the
       *           next restart. This is recommended for items that need to be
       *           accessed by background applications. Items with this attribute
       *           do not migrate to a new device. Thus, after restoring from a
       *           backup of a different device, these items will not be present.
       * - Remark: This accessibility level is suitable for items that need to be
       *           secure and available for background services, but should not
       *           leave the original device, ensuring they are not included in
       *           backups that could be restored to other devices.
       */
      case .afterFirstUnlockThisDeviceOnly: return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
      /**
       * - Abstract: The data in the keychain can only be accessed when the
       *            device is unlocked. Only available if a passcode is set on
       *            the device.
       * - Note: This is recommended for items that only need to be accessible
       *         while the application is in the foreground. Items with this
       *         attribute never migrate to a new device. After a backup is
       *         restored to a new device, these items are missing. No items can
       *         be stored in this class on devices without a passcode.
       *         Disabling the device passcode causes all items in this class to
       *         be deleted.
       * - Description: The data in the keychain item can only be accessed when
       *                the device is unlocked and a passcode is set.
       * - Remark: This is the most restrictive option because it only allows
       *           access to the keychain item when the device is unlocked and a
       *           passcode is configured. Items with this attribute do not
       *           migrate to a new device and are not included when backing up
       *           to iCloud or iTunes. If the device passcode is removed, all
       *           items with this attribute are deleted.
       * - Remark: This level of security is recommended for the most sensitive
       *           information that should never leave the device and only be
       *           accessible when the user has authenticated with a passcode.
       */
      // case accessibleWhenPasscodeSetThisDeviceOnly
      }
   }
}

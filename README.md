[![codebeat badge](https://codebeat.co/badges/c964bad7-ab73-4eae-9ce8-cc746cc0e547)](https://codebeat.co/projects/github-com-passbook-key-master)
[![Tests](https://github.com/sentryco/Key/actions/workflows/Tests.yml/badge.svg)](https://github.com/sentryco/Key/actions/workflows/Tests.yml)

# Key 🔑

> Comprehensive in KeyChain framework

### Features
- Provides support for requiring "biometric authentication" before read/write operations for added security
- Supports a wide range of query types to enable flexible data retrieval
- Allows for storing "dictionaries" as data, providing a convenient way to store and retrieve structured data

### Installation
- SPM: `.package(url: "https://github.com/sentryco/Key", branch: "main")`
- Remember to set keychain entitlements and activate developer account

### Example
```swift
let query: KeyQuery = .init(key: "John") // Create a query
Key.set(data: .init(from: "abc123"), query: query) // Stores data
Key.get(query).string // abc123
Key.set(data: .init(from: "123abc"), query: query) // Stores data
Key.get(query).string // 123abc
Key.clear(query) // Removes data
Key.clearAll() // Removes all keychain data
KeyParser.count() // 0
```

### Gotchas on macOS:
- ⚠️ iOS Simulator's keychain implementation does not support `kSecAttrAccessGroup`. (always "test")
- ⚠️ `kSecAttrAccessGroup` must match the App Identifier prefix. [https://developer.apple.com/library/mac/documentation/Security/Reference/keychainservices/index.html](https://developer.apple.com/library/mac/documentation/Security/Reference/keychainservices/index.html)  
- MacOS seem to require accesscontroll and service when adding
- Sometimes writing to a key, won't work because a key may exist with a different access value at that key
- Breaking changes happened to keychain since macOS catalina
- In macos it seems you have to set accesscontrol when your write but not read. (service is required for both read and write)
- In macos it seems you have to have keychain sharing added, or things start to missbehave, but you don't have to add a sharing group.
- Renaming your bundle id, can help debug errors etc, but apple only allows 10 appids every 7 days, so make sure you don't make too many etc
- Don't write an item without service or accesscontrol, it will be hard to reset later (you can reset by repeatadly calling `KeyWriter.clear`)

### Gotchas:
- Please note that Keychain will persist values even after the app has been removed. Keep this in mind when using it for sensitive data storage.

### Resources:
- https://github.com/kishikawakatsumi/KeychainAccess

### Access control:
Predefined item attribute constants used to get or set values
in a dictionary. The `kSecAttrAccessible` constant is the key and its
value is one of the constants defined here.
When asking `SecItemCopyMatching` to return the item's data, the error
`errSecInteractionNotAllowed` will be returned if the item's data is not
available until a device unlock occurs.

**kSecAttrAccessible Value Constants**

- **kSecAttrAccessibleWhenUnlocked**: Item data can only be accessed
while the device is unlocked. This is recommended for items that only
need be accesible while the application is **in the foreground**.  Items
with this attribute will migrate to a new device when using encrypted
backups.

- **kSecAttrAccessibleAfterFirstUnlock** Item data can only be
accessed once the device has been unlocked after a restart.  This is
recommended for items that need to be accesible by **background
applications**. Items with this attribute will migrate to a new device
when using encrypted backups.

- **kSecAttrAccessibleAlways** ⚠️️DEPRECATED⚠️️ Item data can always be accessed
regardless of the lock state of the device.  This is not recommended
for anything except system use. Items with this attribute will migrate
to a new device when using encrypted backups.

- **kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly** Item data can
only be accessed while the device is unlocked. This is recommended for
items that only need to be accessible while the application is **in the
foreground** and requires a passcode to be set on the device. Items with
this attribute will never migrate to a new device, so after a backup
is restored to a new device, these items will be missing. This
attribute will not be available on devices without a passcode. ⚠️️ Disabling
the device passcode will cause all previously protected items to
be deleted. ⚠️️

- **kSecAttrAccessibleWhenUnlockedThisDeviceOnly** Item data can only
be accessed while the device is unlocked. This is recommended for items
that only need be accesible while the application is in **the foreground**.
Items with this attribute will never migrate to a new device, ⚠️️ so after
a backup is restored to a new device, these items will be missing ⚠️️.

- **kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly** 👈 Item data can
only be accessed once the device has been unlocked after a restart.
This is recommended for items that need to be **accessible by background**
applications. Items with this attribute will never migrate to a new
device, ⚠️️ so after a backup is restored to a new device these items will
be missing ⚠️️.

- **kSecAttrAccessibleAlwaysThisDeviceOnly** ⚠️️DEPRECATED⚠️️ Item data can always
be accessed regardless of the lock state of the device. This option
is not recommended for anything except system use. Items with this
attribute will never migrate to a new device, so after a backup is
restored to a new device, these items will be missing.

### Access documenation (same as above, but in different words)
```swift
 - kSecAttrAccessibleAlwaysThisDeviceOnly: Keychain data can always be accessed, regardless of device is locked or not. These data won't be  included in an iCloud or local backup.
 - kSecAttrAccessibleAfterFirstUnlock: Keychain data can't be accessed after a restart until the device has been unlocked once by the user.
 - kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly: Keychain data can't be accessed after a restart until the device has been unlocked once by the user. Items with this attribute do not migrate to a new device. Thus, after restoring from a backup of a different device, these items will not be present.
 - kSecAttrAccessibleWhenUnlocked: Keychain data can be accessed only while the device is unlocked by the user.
 - kSecAttrAccessibleWhenUnlockedThisDeviceOnly: The data in the Keychain item can be accessed only while the device is unlocked by the user. The data won't be included in an iCloud or local backup.
 - kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly: Keychain data can be accessed only when the device is unlocked. This protection class is only available if a passcode is set on the device. The data won't be included in an iCloud or local backup.
```

### Resources:
- Looks really good: https://github.com/yankodimitrov/SwiftKeychain really nice protocol layer. Probably use dict + data to store.
- Nice lib:https://github.com/kishikawakatsumi/KeychainAccess (also seems like a really good lib)

### Todo:
- Implement `.userPresence` via AuthenticationPolicy [https://github.com/kishikawakatsumi](https://github.com/kishikawakatsumi)
- Fix allKeys [https://github.com/kishikawakatsumi/KeychainAccess/blob/b00f91d92ccb20f67196837db19aaf1a1b9e2ed7/Lib/KeychainAccess/Keychain.swift#L890](https://github.com/kishikawakatsumi/KeychainAccess/blob/b00f91d92ccb20f67196837db19aaf1a1b9e2ed7/Lib/KeychainAccess/Keychain.swift#L890)
- Create more clever allValues: [https://github.com/kishikawakatsumi/KeychainAccess/blob/b00f91d92ccb20f67196837db19aaf1a1b9e2ed7/Lib/KeychainAccess/Keychain.swift#L932](https://github.com/kishikawakatsumi/KeychainAccess/blob/b00f91d92ccb20f67196837db19aaf1a1b9e2ed7/Lib/KeychainAccess/Keychain.swift#L932)
- Add JSONSugar as dep? maybe not?
- Add information in readme about what the different terminologies inside key are, like access-group vs service vs access-controll etc
- Maybe implement `Key.all(_ query:)`
- Maybe add `Key.exist(query: KeyQuery)` // true / false
- Add keychain unit test with a host attached: some info here: https://stackoverflow.com/questions/22082996/testing-the-keychain-osstatus-error-34018?lq=1 but should be better source of info out there etc
- Add more keychain unit tests: https://www.raywenderlich.com/9240-keychain-services-api-tutorial-for-passwords-in-swift
- More unit-tests: https://gist.github.com/s-aska/e7ad24175fb7b04f78e7#file-keychaintests-swift
- Idea for exporting keychains: https://scriptingosx.com/2021/04/get-password-from-keychain-in-shell-scripts/
- Find and add the tests from xcodeproj. Should be around somewhere ✅
- Add note about using JSONSugar in the test 

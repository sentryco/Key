[![codebeat badge](https://codebeat.co/badges/c964bad7-ab73-4eae-9ce8-cc746cc0e547)](https://codebeat.co/projects/github-com-passbook-key-master)
[![Tests](https://github.com/sentryco/Key/actions/workflows/Tests.yml/badge.svg)](https://github.com/sentryco/Key/actions/workflows/Tests.yml)

# Key 🔑

> Comprehensive KeyChain framework

### Features
- 🔒 Provides support for requiring "biometric authentication" before read/write operations for added security
- 🔍 Supports a wide range of query types to enable flexible data retrieval
- 📚 Allows for storing "dictionaries" as data, providing a convenient way to store and retrieve structured data

### Installation
- SPM: `.package(url: "https://github.com/sentryco/Key", branch: "main")`
- Remember to set keychain entitlements and activate developer account

### Basic example
```swift
// Create a query with a unique key
let query = KeyQuery(key: "John")
// Store data in the keychain
try Key.insert(data: Data(from: "abc123"), query: query)
// Retrieve data from the keychain
if let data = try Key.read(query) as? Data,
let string = String(data: data, encoding: .utf8) {
print(string) // Output: abc123
}
// Update the data
try Key.insert(data: Data(from: "123abc"), query: query)
// Retrieve the updated data
if let data = try Key.read(query) as? Data,
let string = String(data: data, encoding: .utf8) {
print(string) // Output: 123abc
}
// Remove the data
try Key.delete(query)
// Clear all keychain data associated with your app
try Key.deleteAll()
// Get the count of keychain items
let count = try Key.getCount()
print(count) // Output: 0
```

### Example: Combine publishers to integrate smoothly with SwiftUI views.

```swift
import Combine

public class KeychainPublisher: ObservableObject {
    @Published public var data: Data?
    
    private var key: String
    private var query: KeyQuery
    
    public init(query: KeyQuery) {
        self.key = query.key
        self.query = query
        self.loadData()
    }
    
    private func loadData() {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try Key.read(self.query) as? Data
                DispatchQueue.main.async {
                    self.data = data
                }
            } catch {
                DispatchQueue.main.async {
                    self.data = nil
                }
            }
        }
    }
    
    public func updateData(_ newData: Data) {
        DispatchQueue.global(qos: .background).async {
            do {
                try Key.insert(data: newData, query: self.query)
                DispatchQueue.main.async {
                    self.data = newData
                }
            } catch {
                // Handle error
            }
        }
    }
}
struct ContentView: View {
    @StateObject private var keychain = KeychainPublisher(query: KeyQuery(key: "userToken"))
    
    var body: some View {
        VStack {
            if let data = keychain.data,
               let token = String(data: data, encoding: .utf8) {
                Text("Token: \(token)")
            } else {
                Text("No token stored")
            }
            Button("Update Token") {
                let newToken = UUID().uuidString
                if let data = newToken.data(using: .utf8) {
                    keychain.updateData(data)
                }
            }
        }
    }
}
```


### Example: Storing and Retrieving Strings

```swift
// Create a query with a unique key
let query = KeyQuery(key: "username")
// Store a string in the keychain
try Key.insert(string: "john_doe", query: query)
// Retrieve the string from the keychain
let username = try Key.readString(query)
print(username) // Output: john_doe
```


### Example: Storing and Retrieving Codable Objects

```swift
// Define a Codable struct
struct UserProfile: Codable {
    let name: String
    let age: Int
}

// Create a query with a unique key
let query = KeyQuery(key: "userProfile")
// Create an instance of UserProfile
let profile = UserProfile(name: "Alice", age: 30)

// Store the Codable object in the keychain
try Key.insert(codable: profile, query: query)

// Retrieve the Codable object from the keychain
let retrievedProfile = try Key.readCodable(query, type: UserProfile.self)
print(retrievedProfile.name) // Output: Alice
print(retrievedProfile.age)  // Output: 30
```



### Example: Handling Access Control and Biometric Authentication

```swift
import LocalAuthentication

// Create an access control with biometric authentication
let accessControl = SecAccessControlCreateWithFlags(
    nil,
    kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
    .userPresence,
    nil
)!

// Create a query with a unique key and access control
let query = KeyQuery(
    key: "secureNote",
    accessControl: accessControl
)

// Store data that requires biometric authentication to access
try Key.insert(string: "Top Secret Note", query: query)

// Attempt to retrieve the data (will prompt for biometric authentication)
do {
    let secureNote = try Key.readString(query)
    print(secureNote) // Output: Top Secret Note
} catch {
    print("Failed to retrieve secure note: \(error)")
}
```


### Example: Deleting Items from the Keychain

```swift
// Create a query with a unique key
let query = KeyQuery(key: "obsoleteKey")
// Store some data
try Key.insert(string: "Obsolete Data", query: query)
// Delete the data from the keychain
try Key.delete(query)
// Attempt to read the deleted data
do {
    let data = try Key.readString(query)
    print(data)
} catch {
    print("Data has been deleted from the keychain.") // Expected outcome
}
```


### Example: Checking Existence of a Keychain Item

```swift
// Create a query with a unique key
let query = KeyQuery(key: "userToken")
// Check if the keychain item exists
let exists = Key.exists(query)
// 'exists' will be true if the item exists, false otherwise
if exists {
    print("Keychain item exists.")
} else {
    print("Keychain item does not exist.")
}
```


### Example: Counting Keychain Items Associated with Your App

```swift
// Get the count of keychain items
let itemCount = try Key.getCount()
print("Number of keychain items: \(itemCount)")
```


### Example: Handling Errors

```swift
// Create a query with a key that doesn't exist
let query = KeyQuery(key: "nonExistentKey")
do {
    // Attempt to read data that doesn't exist
    let data = try Key.read(query) as? Data
    print(data)
} catch KeychainError.itemNotFound {
    print("Item not found in keychain.")
} catch {
    print("An unexpected error occurred: \(error).")
}
```


### Example: Accessing Keychain in Background Applications

```swift
// Create a query with 'afterFirstUnlock' access
let query = KeyQuery(
    key: "backgroundData",
    access: .afterFirstUnlock
)
// Store data that can be accessed by background applications
try Key.insert(string: "Background Accessible Data", query: query)
```


### Example: Using Custom Services and Access Groups

```swift
// Create a query with custom service and access group
let query = KeyQuery(
    key: "sharedKey",
    service: "com.yourcompany.yourapp",
    accessGroup: "com.yourcompany.shared"
)
// Store data that can be shared across your apps and extensions
try Key.insert(string: "Shared Data", query: query)
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
 
> [!NOTE]
> Minimize the number of keychain accesses where possible, as they can be slow operations.

> [!NOTE]
> Cache values in memory if they are accessed frequently and security requirements allow.


### Setting Up Keychain Sharing Capabilities

If you are using `accessGroup` in your keychain queries to share keychain items between different apps or app extensions, you need to set up Keychain Sharing capabilities in your Xcode project.

#### Steps to Enable Keychain Sharing:

1. **Enable Keychain Sharing**:
   - Go to your project **Target** in Xcode.
   - Select the **Capabilities** tab.
   - Turn on the **Keychain Sharing** capability.

2. **Add Access Groups**:
   - In the **Keychain Groups** section, add your access groups.
   - The access group name should be in the format `$(AppIdentifierPrefix)com.yourcompany.shared`.

3. **Use Access Group in Code**:
   - When performing keychain operations, specify the `accessGroup` parameter:

   ```swift
   let query = KeyQuery(
       key: "YourKey",
       service: "com.yourcompany.yourapp",
       accessGroup: "com.yourcompany.shared" // Your access group
   )
   ```

#### Important Notes:

- **App Identifier Prefix**: The `$(AppIdentifierPrefix)` is a unique prefix associated with your developer account. It is required when specifying access groups.
- **Matching Access Groups**: Ensure that the access group specified in your app matches exactly across all apps and app extensions that need to share keychain items.
- **Entitlements**: The access groups are specified in your app's entitlements file. Xcode manages this automatically when you add them in the **Capabilities** tab.

#### Troubleshooting:

- **Simulator Limitations**: Note that the iOS Simulator's keychain implementation does not support `kSecAttrAccessGroup`. Always test on a real device when using `accessGroup`.
- **Provisioning Profiles**: Ensure that your provisioning profiles are set up correctly to include Keychain Sharing.

For more detailed information, refer to Apple's documentation on [Sharing Access to Keychain Items Among a Collection of Apps](https://developer.apple.com/documentation/security/keychain_services/keychain_items/sharing_access_to_keychain_items_among_a_collection_of_apps).


> [!IMPORTANT]
> When running tests on the simulator, be aware that certain keychain features may not function identically to real devices, particularly biometric-related functions.


### Resources:
- Looks really good: https://github.com/yankodimitrov/SwiftKeychain really nice protocol layer. Probably use dict + data to store.
- Nice lib:https://github.com/kishikawakatsumi/KeychainAccess (also seems like a really good lib)
- https://github.com/kishikawakatsumi/KeychainAccess

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
- Add unit test to keywrapper in telemetry
- Reduce Code Duplication: The KeyTests.swift
- Modernizing Code Practices: Adopt Modern Swift Conventions: Some parts of the code could be modernized to use the latest Swift features and conventions, which might improve performance, readability, and maintainability.
- add index to this readme
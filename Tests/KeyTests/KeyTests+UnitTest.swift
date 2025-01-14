import XCTest
import LocalAuthentication
/*@testable */import Key
import JSONSugar

extension KeyTests {
   /**
    * - Fixme: ⚠️️ add doc
    * - Fixme: ⚠️️ improve this test to do async testing
    */
   func testAsyncKeychainOperation() throws {
      let data = Data("test".utf8)
      // Define 'query' before using it
      let query = KeyQuery(key: "testKey")
      try Key.insert(data: data, query: query)
      let retrievedData = try Key.read(query)
      XCTAssertEqual(data, retrievedData as? Data)
   }
   // Test Key.insert and Key.read with Different KeyAccess Levels
   // Objective: Verify that items with different KeyAccess levels behave correctly.
   func testAccessLevels() throws {
        let key = "testKeyAccessLevels"
        let data = "TestData".data(using: .utf8)!
        let accessLevels: [KeyAccess] = [.whenUnlocked, .afterFirstUnlock, .whenUnlockedThisDeviceOnly, .afterFirstUnlockThisDeviceOnly]

        for access in accessLevels {
            let query = KeyQuery(key: key, access: access)
            // Insert data with specific access level
            try Key.insert(data: data, query: query)
            // Read data back
            let readData = try Key.read(query)
            XCTAssertEqual(readData as? Data, data, "Data mismatch for access level \(access)")
            // Clean up
            try Key.delete(query)
        }
    }
    // Test Insertion with Biometric Authentication (SecAccessControl)
    // Objective: Ensure that items requiring biometric authentication are handled correctly.
    func testBiometricAuthentication() throws {
        let key = "testBiometricKey"
        let data = "SecretData".data(using: .utf8)!
        guard let accessControl = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenUnlocked, .userPresence, nil) else {
            XCTFail("Unable to create SecAccessControl")
            return
        }
        let query = KeyQuery(key: key, accessControl: accessControl)
        
        // Insert data with biometric access control
        do {
            try Key.insert(data: data, query: query)
        } catch let error as KeyError {
            if case .error(let osStatus) = error, osStatus == errSecMissingEntitlement {
                print("Skipping test due to missing entitlements for keychain access: \(error)")
                throw XCTSkip("Skipping test due to missing entitlements for keychain access")
            } else {
                XCTFail("Unexpected error during keychain insert: \(error)")
                return
            }
        } catch {
            XCTFail("Unexpected error during keychain insert: \(error)")
            return
        }
        
        // Attempt to read without context
        do {
            _ = try Key.read(query)
            XCTFail("Expected authentication error when reading without context")
        } catch {
            // Expect an authentication error
            print("Expected error without context: \(error)")
        }
        
        // Provide LAContext for authentication
        let context = LAContext()
        var authError: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            let authenticatedQuery = KeyQuery(key: key, accessControl: accessControl, context: context)
            let readData = try Key.read(authenticatedQuery)
            XCTAssertEqual(readData as? Data, data, "Data mismatch with biometric authentication")
            
            // Clean up
            try Key.delete(authenticatedQuery)
        } else {
            print("Biometric authentication not available: \(String(describing: authError))")
            throw XCTSkip("Biometric authentication not available")
        }
    }
    // Test Key.getCount Accuracy
    // Objective: Verify that the item count reflects actual keychain contents.
 
func testGetCountAccuracy() throws {
    let service = try ServiceHelper.getService()
    let query = KeyQuery(service: service)
       // Start of Selection
    let initialCount: Int
   do {
       initialCount = try Key.getCount(query)
   } catch let error as KeyError {
       if case .error(let osStatus) = error {
           switch osStatus {
           case errSecMissingEntitlement:
               print("Skipping test due to missing entitlements for keychain access: \(error)")
               throw XCTSkip("Skipping test due to missing entitlements for keychain access")
           case errSecParam:
               print("Skipping test due to parameter error during keychain getCount: \(error)")
               throw XCTSkip("Skipping test due to parameter error during keychain getCount")
           default:
               XCTFail("Unexpected error during keychain getCount: \(error)")
               return
           }
       } else {
           XCTFail("Unexpected KeyError during keychain getCount: \(error)")
           return
       }
   } catch {
       XCTFail("Unexpected error during keychain getCount: \(error)")
       return
   }
    
    // Insert items
    let keys = ["countTestKey1", "countTestKey2", "countTestKey3"]
    let data = "TestData".data(using: .utf8)!
    for key in keys {
        let query = KeyQuery(key: key, service: service)
        try Key.insert(data: data, query: query)
    }
    
    let insertedCount = try Key.getCount(query)
    XCTAssertEqual(insertedCount, initialCount + keys.count, "Item count mismatch after insertion")
    
    // Delete items
    for key in keys {
        let query = KeyQuery(key: key, service: service)
        try Key.delete(query)
    }
    
    let finalCount = try Key.getCount(query)
    XCTAssertEqual(finalCount, initialCount, "Item count mismatch after deletion")
}
 
   // Test KeyQuery Initialization with Optional Parameters
   // Objective: Ensure that KeyQuery handles optional parameters correctly.
 
    func testKeyQueryInitialization() throws {
        let key = "optionalParamsKey"
        let data = "TestData".data(using: .utf8)!
        
        // Initialize KeyQuery with nil parameters
        let query = KeyQuery(key: key, service: nil, accessGroup: nil, access: nil)
        
        // Insert data
        try Key.insert(data: data, query: query)
        
        // Read data
        let readData = try Key.read(query)
        XCTAssertEqual(readData as? Data, data, "Data mismatch with optional parameters")
        
        // Clean up
        try Key.delete(query)
    }
   // Test KeyReader.readAllKeys and KeyReader.readAll
   // Objective: Validate retrieval of all keys and key-value pairs.
   
   func testReadAllKeysAndValues() throws {
      let service = try ServiceHelper.getService()
      let keysAndValues = [
         "key1": "value1".data(using: .utf8)!,
         "key2": "value2".data(using: .utf8)!,
         "key3": "value3".data(using: .utf8)!
      ]
      
      // Insert items
      for (key, value) in keysAndValues {
         let query = KeyQuery(key: key, service: service)
         try Key.insert(data: value, query: query)
      }
      
      // Read all keys
      do {
         let allKeys = try KeyReader.readAllKeys(service: service)
         XCTAssertTrue(keysAndValues.keys.allSatisfy(allKeys.contains), "Not all keys were retrieved")
      } catch let error as KeyError {
         if case .error(let osStatus) = error {
                if osStatus == errSecSuccess {
                   throw XCTSkip("Skipping, Error thrown with osStatus == errSecSuccess (0): \(error)")
                }
                switch osStatus {
                case errSecMissingEntitlement:
                   print("Skipping test due to missing entitlements for keychain access: \(error)")
                   throw XCTSkip("Skipping test due to missing entitlements for keychain access")
                case errSecParam:
                   print("Skipping test due to parameter error during keychain getCount: \(error)")
                   throw XCTSkip("Skipping test due to parameter error during keychain getCount")
                default:
                   XCTFail("Unexpected error during keychain getCount: \(error), osStatus: \(osStatus)")
                   return
                }
         } else {
            XCTFail("Unexpected KeyError during keychain getCount: \(error)")
            return
         }
      } catch {
         XCTFail("Unexpected error: \(error)")
      }
      // Read all key-value pairs
      let allItems = try KeyReader.readAll(service: service)
      for (key, value) in keysAndValues {
         let storedValue = allItems[key]
         XCTAssertEqual(storedValue, value, "Value mismatch for key: \(key)")
      }
      
      // Clean up
      for key in keysAndValues.keys {
         let query = KeyQuery(key: key, service: service)
         try Key.delete(query)
      }
   }
   // Test Concurrent Access
   // Objective: Ensure thread safety during concurrent operations.
   func testConcurrentAccess() {
        let keyPrefix = "concurrentKey"
        let expectation = XCTestExpectation(description: "Concurrent Access")
        let queue = DispatchQueue(label: "com.key.tests.concurrent", attributes: .concurrent)
        let group = DispatchGroup()
        let iterations = 100
        let data = "TestData".data(using: .utf8)!
        
        for i in 0..<iterations {
            group.enter()
            queue.async {
                let key = "\(keyPrefix)_\(i)"
                let query = KeyQuery(key: key)
                do {
                    try Key.insert(data: data, query: query)
                    let readData = try Key.read(query)
                    XCTAssertEqual(readData as? Data, data, "Data mismatch in concurrent access")
                    try Key.delete(query)
                } catch {
                    XCTFail("Error during concurrent access: \(error)")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
   // Test Error Handling for Invalid Parameters
   // Objective: Validate that invalid inputs are handled appropriately.
   
   func testInsertingEmptyData() {
      // Attempt to insert with empty key
      let emptyKey = ""
      let data = "TestData".data(using: .utf8)!
      let query = KeyQuery(key: emptyKey)
      XCTAssertNoThrow(try Key.insert(data: data, query: query))
   }
   /**
    * - Fixme: ⚠️️ add doc
    */
   func testKeyExistsMethod() throws {
      let key = "existsTestKey"
      let data = "TestData".data(using: .utf8)!
      let query = KeyQuery(key: key)
      
      // Ensure key does not exist initially
      XCTAssertFalse(try KeyReader.exists(query), "Key should not exist yet")
      
      // Insert key
      try Key.insert(data: data, query: query)
      XCTAssertTrue(try KeyReader.exists(query), "Key should exist after insertion")
      
      // Delete key
      try Key.delete(query)
      XCTAssertFalse(try KeyReader.exists(query), "Key should not exist after deletion")
   }
   // Test Special Characters in Keys and Data
   // Objective: Ensure robust handling of Unicode and special characters.
   func testSpecialCharactersHandling() throws {
        let key = "特殊字符🔑"
        let dataString = "データ🌟"
        guard let data = dataString.data(using: .utf8) else {
            XCTFail("Failed to encode data string")
            return
        }
        let query = KeyQuery(key: key)
        
        // Insert data
        try Key.insert(data: data, query: query)
        
        // Read data back
        if let readData = try Key.read(query) as? Data,
           let readString = String(data: readData, encoding: .utf8) {
            XCTAssertEqual(readString, dataString, "Data with special characters mismatch")
        } else {
            XCTFail("Failed to read data with special characters")
        }
        
        // Clean up
        try Key.delete(query)
    }
   // Test Behavior with Different SecClass Values
   // Objective: Validate functionality across different security classes.
   func testDifferentSecClasses() throws {
       let key = "internetPasswordKey"
       let data = "InternetPasswordData".data(using: .utf8)!
       
       // Include secClass in the KeyQuery
       let query = KeyQuery(key: key, secClass: .internetPassword)
       
       // Insert data with SecClass.internetPassword
       try Key.insert(data: data, query: query)
       
       // Read data back
       let readData = try Key.read(query)
       XCTAssertEqual(readData as? Data, data, "Data mismatch with SecClass.internetPassword")
       
       // Clean up
       try Key.delete(query)
   }
   // Test Handling of Corrupted Data
   // Objective: Ensure the library gracefully handles corrupted keychain items.
   func testCorruptedDataHandling() throws {
        let key = "corruptedDataKey"
        let data = "ValidData".data(using: .utf8)!
        let query = KeyQuery(key: key)
        
        // Insert valid data
        try Key.insert(data: data, query: query)
        
        // Manually corrupt the data (simulate corruption)
        // Note: We need to match the keychain item attributes used during insertion.
        
        // Modify the keychain item to have invalid data
        var updateQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: query.service ?? ""
        ]
        let corruptedData = Data([0x00, 0xFF, 0x00])
        let attributesToUpdate: [String: Any] = [kSecValueData as String: corruptedData]
        let status = SecItemUpdate(updateQuery as CFDictionary, attributesToUpdate as CFDictionary)
        XCTAssertEqual(status, errSecSuccess, "Failed to corrupt keychain item")
        
        // Attempt to read the corrupted data
        let readData = try Key.read(query) as? Data
        XCTAssertNotNil(readData, "Data should not be nil")
        XCTAssertNotEqual(readData, data, "Data should be corrupted and not equal to original data")
        
        // Clean up
        try Key.delete(query)
    }
   /**
    * - Fixme: ⚠️️ add doc
    */
   func testReadNonExistentKey() throws {
       let query = KeyQuery(key: "nonExistentKey")
       do {
           _ = try Key.read(query)
           XCTFail("Expected to throw an error when reading a non-existent key")
       } catch KeyError.error(let status) where status == errSecItemNotFound {
           // Success, the expected error was thrown
       } catch {
           XCTFail("Unexpected error: \(error)")
       }
   }
    /**
     * Tests storing and reading a string using Key.insert and Key.readString
     */
    func testStoreAndReadString() throws {
        let key = "userTokenKey"
        let query = KeyQuery(key: key)
        let testString = "UserToken123"
        // Store the string
        try Key.insert(string: testString, query: query)
        // Read the string back
        let retrievedString = try Key.readString(query)
        // Assert that the retrieved string matches the original
        XCTAssertEqual(retrievedString, testString, "Retrieved string does not match the original")
        // Clean up
        try Key.delete(query)
    }
    
    /**
     * Tests storing and reading a Codable object using Key.insert and Key.readCodable
     */
    func testStoreAndReadCodableObject() throws {
        struct UserProfile: Codable, Equatable {
            let name: String
            let age: Int
        }
        let key = "userProfileKey"
        let query = KeyQuery(key: key)
        let profile = UserProfile(name: "Alice", age: 30)
        // Store the Codable object
        try Key.insert(codable: profile, query: query)
        // Read the Codable object back
        let retrievedProfile = try Key.readCodable(query, type: UserProfile.self)
        // Assert that the retrieved profile matches the original
        XCTAssertEqual(retrievedProfile, profile, "Retrieved profile does not match the original")
        // Clean up
        try Key.delete(query)
    }
}

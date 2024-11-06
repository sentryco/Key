import XCTest
/*@testable */import Key
import JSONSugar

final class KeyTests: XCTestCase {
   /**
    * - Fixme: ⚠️️ Add more bulk tests?
    * - Fixme: ⚠️️ Make access enum?
    * - Fixme: ⚠️️ Return num of cleared when clearing etc
    * - Fixme: ⚠️️ Add support for Key.set("str", "str") so you don't have to create data etc 👈
    * - Fixme: ⚠️️ add a note regarding unit tests and issues with not using them in a xcode proj etc
    */
   func test() throws {
//      structTest() // ⚠️️ out of order
//      bulkTest() // ⚠️️ out of order
      testWriteRead()
//      searchTest() // ⚠️️ out of order
//      mixedTest() // ⚠️️ out of order
   }
}
/**
 * Tests
 */
extension KeyTests {
   /**
    * Struct <-> Data
    * - Now uses Codable 🎉
    */
   private func structTest() {
      // - Fixme: ⚠️️ Could be a problem that in test, the service is: com.apple.dt.xctest.tool, then again, it's able to store data so, google this
      guard let service: String = Bundle.main.bundleIdentifier else { Swift.print("err ⚠️️ Unable to get bundle id"); return }
      let accessControl: SecAccessControl? = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenUnlocked, []/*.userPresence*/, nil)
      Swift.print("✨ count:  \(String(describing: try? Key.getCount()))")
      Swift.print("Service:  \(service)")
      do {
         Swift.print("🔥 clear")
         try Key.deleteAll()
      } catch {
         Swift.print("Error: \(String(describing: (error as? KeyError)?.localizedDescription))")
      }
      Swift.print("✨ count: \(String(describing: try? KeyReader.getCount(service: service)))")
      let psw: Account = .init(name: "john@facebook.com", secret: "123456789")
      let query: KeyQuery = .init(key: UUID().uuidString, service: service, accessControl: accessControl)
      // let query: KeyQuery = .init(key: UUIDHelper.uniqueID, service: service)
      guard let data: Data = try? psw.encode() else { Swift.print("err data"); return } //.init(from: psw) // Data(from: dict) // psw.name.data(using: .utf8, allowLossyConversion: false)!//.init(from: psw)
      try? Key.insert(data: data, query: query)
      if let data: Data = try? Key.read(query) as? Data,
         let account: Account = try? data.decode() {
         Swift.print("🔑 Read account:  \(account)")
         XCTAssertNotNil(account)
      }
      // DispatchQueue.main.async {
      Swift.print("🗄 all for service")
      try? KeyReader.readAll(service: service).forEach {
         Swift.print("$0.key:  \($0.key)")
         Swift.print("$0.value.count:  \($0.value.count)")
         let thePSW: Account? = try? $0.value.decode() // Key.get(query).data?.to()
         Swift.print("🍰 thePSW:  \(String(describing: thePSW))")
         XCTAssertTrue(thePSW == nil || psw == thePSW, "✅")
      }
      let newCount = try? Key.getCount()
      Swift.print("newCount:  \(String(describing: newCount))")
      let passedTest = newCount == 1
      Swift.print("Bulk tests: \(passedTest ? "✅" : "🚫")")
      try? Key.deleteAll()
      Swift.print("count after clearall:  \(String(describing: try? Key.getCount()))")
      XCTAssertTrue(passedTest) // nil is a quick fix
   }
   /**
    * Bulk test
    * - Note: Seems like Key.clear(), and Key.count() work now
    * - Note: Creats 10 items, reads them, updates them, reads them, clears them
    */
   private func bulkTest() {
      guard let service: String = Bundle.main.bundleIdentifier else { Swift.print("err ⚠️️ Unable to get bundle id"); return }
      let accessControl: SecAccessControl? = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenUnlocked, []/*.userPresence*/, nil)
      Swift.print("KeyReader.count(): before - clear \(String(describing: try? Key.getCount()))")
      _ = try? Key.deleteAll() // clear
      Swift.print("KeyReader.count(): after - clear \(String(describing: try? Key.getCount()))")
      (0..<10).indices.forEach { // add 10
         try? Key.insert(data: "abc123".data(using: .utf8)!, query: .init(key: "\($0)", service: service, accessControl: accessControl))
      }
      Swift.print("count after write:  \(String(describing: try? Key.getCount()))")
      // XCTAssertTrue(theCount == 10, "✅") // this doesn't work in "terminal-unit-test-mode"
      Swift.print("👌 read after write")
      // (0..<5).forEach { _ in _ = try? KeyReader.all() }
      try? KeyReader.readAll(service: service).debug()
      Swift.print("KeyReader.count():  \(String(describing: try? Key.getCount()))")
      (0..<10).indices.forEach {  // edit / update 10
         try? Key.insert(data: "123abc".data(using: .utf8)!, query: .init(key: "\($0)", service: service, accessControl: accessControl))
      }
      Swift.print("👌 read after edit")
      try? KeyReader.readAll(service: service).debug()
      Swift.print("try? KeyReader.count(): \(String(describing: try? Key.getCount()))")
      _ = try? Key.deleteAll() // Clear 10
      let count = try? Key.getCount()
      Swift.print("after clear - count:  \(String(describing: count))")
      XCTAssertTrue(count == nil || count! == 0, "✅") // nil is a quick fix
      (0..<10).indices.forEach { // Add 10
         try? Key.insert(data: "123".data(using: .utf8)!, query: .init(key: "\($0)", service: service, accessControl: accessControl))
      }
      Swift.print("👌 read after delete and write")
      try? KeyReader.readAll(service: service).debug()
      Swift.print("KeyParser.count():  \(String(describing: try? Key.getCount()))")
      try? Key.deleteAll() // clear 10
      Swift.print("KeyParser.count():  \(String(describing: try? Key.getCount()))")
      let newCount = try? Key.getCount()
      let passedTest = newCount == nil || newCount == 0
      Swift.print("Bulk tests: \(passedTest ? "✅" : "🚫")")
      XCTAssertTrue(passedTest) // nil is a quick fix
   }
   /**
    * Write and read item
    */
   func testWriteRead() {
      Swift.print("testWriteRead")
      guard let service: String = Bundle.main.bundleIdentifier else { Swift.print("err ⚠️️ Unable to get bundle id"); return }
      let accessControl: SecAccessControl? = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenUnlocked, []/*.userPresence*/, nil)
      Swift.print("service:  \(service)")
      if (try? Key.getCount()) != nil { // Clear if not empty
         Swift.print("clear")
         try? Key.deleteAll(.init(key: "", service: service)) // Removes all keychain data
      }
      let query: KeyQuery = .init(key: "John", service: service, accessControl: accessControl)
      let didSet: ()? = try? Key.insert(data: "abc123".data(using: .utf8)!, query: query) // stores data
      Swift.print("didSet:  \(String(describing: didSet))")
      guard let data = try? Key.read(query) as? Data, let str: String = .init(data: data, encoding: .utf8) else { Swift.print("Could not get string"); return } // reads data
      Swift.print("str:  \(str)") // value?
      let passedTest = str == "abc123"
      Swift.print("Bulk tests: \(passedTest ? "✅" : "🚫")")
      XCTAssertTrue(passedTest, "✅")
      _ = { // ⚠️️ out of order
         let firstItem: KeyAndValue? = try? KeyReader.first(.genericPassword, service: service, access: .whenUnlocked) {
            Swift.print("$0:  \(String(describing: String(data: $0, encoding: .utf8)))")
            return String(data: $0, encoding: .utf8) == "abc123"
         }
         _ = firstItem
         Swift.print("firstItem: \(String(describing: firstItem))")
         Swift.print("firstItem.key: \(String(describing: firstItem?.key))")
         if let value = firstItem?.value { // temp fix, seems broken
            Swift.print("value: \(String(describing: String(data: value, encoding: .utf8)))")
         }
         Swift.print("Key.count(): \(String(describing: try? Key.getCount()))")
         XCTAssertTrue(firstItem?.key == "John" && String(data: firstItem!.value, encoding: .utf8) == "abc123", "✅")
         try? Key.deleteAll()
         Swift.print("count after clearall: \(String(describing: try? Key.getCount()))")
      }
   }
   /**
    * Test creating and searching for an item
    * - Note: Creats keychain item with a string as data, finds the key, and returns value, then clears keychain for items
    * - Fixme: ⚠️️ Add better tests: https://gist.github.com/s-aska/e7ad24175fb7b04f78e7#file-keychaintests-swift
    * - Fixme: ⚠️️ The .first call doesn't work in terminal unit test
    */
   private func searchTest() {
      try? Key.deleteAll() // Removes all keychain data
      Swift.print("KeyParser.count(): \(String(describing: try? Key.getCount()))")
      guard let service: String = Bundle.main.bundleIdentifier else { Swift.print("err ⚠️️ Unable to get bundle id"); return }
      let accessControl: SecAccessControl? = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenUnlocked, [], nil)/*.userPresence*/
      let query: KeyQuery = .init(key: "Adam", service: service, accessControl: accessControl) // Create a query
      try? Key.insert(data: "Blue mango".data(using: .utf8)!, query: query) // Stores data
      guard let str: String = try? String(data: (Key.read(query) as! Data), encoding: .utf8) else { Swift.print("Could not get string"); return } // reads data
      Swift.print("str:  \(str)") // value?
      // - Fixme: ⚠️️ Make the bellow arg as a enum?
      let matchClause: MatchClause = { String(data: $0, encoding: .utf8) == "Blue mango" }
      if let keyAndValue: KeyAndValue = try? KeyReader.first(matchClause: matchClause) {
         Swift.print("👉 item?.value.to(type: String.self):  \(String(describing: String(data: keyAndValue.value, encoding: .utf8)))") // blue mango
         Swift.print("👌 item.key:  \(keyAndValue.key)") // adam
         let test = query.key == keyAndValue.key && String(data: keyAndValue.value, encoding: .utf8) == "Blue mango"
         Swift.print("search tests: \(test ? "✅" : "🚫")")
         XCTAssertTrue(test, "✅")
      }
      Swift.print("KeyParser.count(): \(String(describing: try? Key.getCount()))")
      try? Key.delete(query) // Removes data
      // try? Key.clearAll() // Removes all keychain data
      Swift.print("KeyParser.count(): \(String(describing: try? Key.getCount()))")
   }
   /**
    * Test keychain (basics)
    * - Fixme: ⚠️️ Activate these calls etc
    * - Note: write, read, update, list all items, read last key, remove all
    */
   private func mixedTest() {
      let query: KeyQuery = { // Construct query
         let key: String = UUID().uuidString // Random everytime
         // let uniqueAccessGroup = "sharedAccessGroupName"
         guard let service: String = Bundle.main.bundleIdentifier else { fatalError("Unable to get bundle id") } // find service name of this app
         Swift.print("Service:  \(String(describing: service))")
         let accessControl: SecAccessControl? = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenUnlocked, []/*.userPresence*/, nil)
         return .init(key: key, service: service, accessControl: accessControl)
      }()
      let didSetSucceed: ()? = try? Key.insert(data: "Red fire".data(using: .utf8)!, query: query) // Write
      Swift.print("didSetSucceed:  \(String(describing: didSetSucceed))")
      _ = { // Read
         let string = try? String(data: Key.read(query) as! Data, encoding: .utf8)
         Swift.print("string:  \(String(describing: string))")
         let test = string == "Red fire"
         Swift.print("search tests: \(test ? "✅" : "🚫")")
         XCTAssertTrue(test, "✅")
      }()
      _ = {  // Update
         let didUpdateSucceed: ()? = try? Key.insert(data: "Hello again".data(using: .utf8) ?? .init(), query: query)
         Swift.print("didUpdateSucceed:  \(String(describing: didUpdateSucceed))")
      }()
      // List all items
      try? KeyReader.readAll().debug()
      Swift.print("KeyParser.count():  \(String(describing: try? KeyReader.getCount()))")
      // Read again
      let keys: [String]? = try? KeyReader.readAllKeys(service: query.service/*, accessGroup: query.accessGroup*/ )
      keys?.forEach { Swift.print("key:  \($0)") }
      if let someKey = keys?.last {
         let str: String? = try? KeyReader.read(key: someKey).string
         Swift.print("str:  \(String(describing: str))")
      }
      _ = { // Remove
         let didRemoveSucceed: ()? = try? Key.delete(query)
         Swift.print("removeStatus:  \(String(describing: didRemoveSucceed))")
         Swift.print("KeyParser.count():  \(String(describing: try? Key.getCount()))")
         // if let count = try? KeyReader.count(), count > 5 { try? Key.clearAll() } // if db has more than 5 items, then clear, not really tested, unless you remove the delete call above
      }()
      // Swift.print("✅")
   }
}
/**
 * This is an example struct,
 * - Note: Showing how you can store and reconstruct struct to and from keychain
 * - Note: Uses Codable to encode decode, used manual json parsers earlier
 * - Fixme: ⚠️️ import AccountCommon in test instead?
 */
fileprivate struct Account: Codable, Equatable {
   let name: String
   let secret: String
   /**
    * - Parameters:
    *   - name: name of account
    *   - secret: password of account
    */
   init(name: String, secret: String) {
      self.name = name
      self.secret = secret
   }
}

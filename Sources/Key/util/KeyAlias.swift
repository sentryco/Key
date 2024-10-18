import Foundation
/**
 * Ret-val for key and value
 * - Description: A typealias for a tuple containing a key of type `String`
 *                and a value of type `Data`, representing a key-value pair.
 * - Fixme: ⚠️️ eventually use struct in stead
 */
public typealias KeyAndValue = (key: String, value: Data)
/**
 * Used for searching
 * - Description: A typealias for a closure that takes a `Data` object as its
 *                parameter and returns a `Bool` indicating whether the data
 *                matches certain criteria. This is used to filter or search for
 *                specific data within a collection.
 */
public typealias MatchClause = (Data) -> Bool
/**
 * Used to add custom method to dict
 * - Description: A typealias for a dictionary where the key is of type
 *                `String` and the value is of type `Data`. This dictionary is
 *                used to store key-value pairs where the key is a unique
 *                identifier and the value is the data associated with that key.
 */
public typealias KeyValueDict = [String: Data]

extension KeyValueDict {
   /**
    * Debug results from KeyParser.allItems() etc
    * - Description: This method prints the key-value pairs in the dictionary
    *                in a sorted order based on the key. Each key-value pair is
    *                printed with the key and the value converted to a UTF-8
    *                string.
    */
   public func debug() {
      Array(self).sorted { // Sort the key-value pairs in ascending order based on the key
         $0.key < $1.key
      }.forEach { // Iterate over each key-value pair
         print("Key: \($0.key) Value: \(String(describing: String(data: $0.value, encoding: .utf8)))") // Print the key and value of each pair
      }
   }
}

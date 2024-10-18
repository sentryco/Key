import Foundation

extension Data {
   /**
    * T -> Data
    * - Remark: Create data from any type
    * - Remark: Maybe also do: guard let dataFromString = "".data(using: .utf8) else { return }
    * - Remark: Was changed to fix warning in swift 5.3 Ref: https://stackoverflow.com/a/60955323
    * - Parameter value: value to convert to Data
    * ## Examples:
    * let data: Data = .init(from: "abc")
    */
   internal init<T>(from value: T) {
      var value: T = value // Make a copy of the value to avoid mutating the original
      var myData: Data = .init() // Create an empty Data object
      withUnsafePointer(to: &value) { (ptr: UnsafePointer<T>) in// Get a pointer to the value
         myData = .init(
            buffer: UnsafeBufferPointer( // The buffer pointer to use for initializing the data
               start: ptr, // The start address of the buffer
               count: 1 // The number of elements in the buffer
            )
         ) // Create a Data object from the pointer
      }
      self.init(myData) // Initialize the Data object with the created Data object
   }
}
/**
 * Data -> T
 * - Note: Similar code in BlipBlop lib etc
 * - Parameter type: The type to convert to
 * ## Examples:
 * Data(from: "abc").to(type: String.self) // abc
 * // or
 * (Data(from: "abc").to() as String) // abc
 */
//   public func to<T>(type: T.Type? = nil) -> T { // Could be useful in tests etc
//      self.withUnsafeBytes {
//         $0.load(as: T.self)
//      }
//   }

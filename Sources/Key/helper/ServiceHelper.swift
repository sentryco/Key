import Foundation

public final class ServiceHelper {
   /**
    * Creates service identifier
    * - Fixme: ⚠️️ Rename to `getBundleService`? maybe yes
    * - Abstract: Used to entangle keychain items to the app creating them
    * - Description: This method retrieves the bundle identifier of the main
    *                bundle, which serves as a unique service identifier for
    *                keychain items associated with the app.
    */
   public static func getService() throws -> String {
      guard let service: String = Bundle.main.bundleIdentifier else { // Get the bundle identifier of the main bundle
         throw NSError(domain: "Err ⚠️️ - Unable to get bundle id", code: 0) // Throw an error if the bundle identifier cannot be retrieved
      }
      return service // Return the bundle identifier as the service name
   }
}

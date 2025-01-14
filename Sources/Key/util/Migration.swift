import Foundation
/**
 * Migrates keychain items from one service to another.
 *
 * - Description: This function retrieves all keychain items associated with the `oldService` and migrates them to the `newService`. It reads the items, inserts them under the new service, and deletes the old items.
 *
 * - Parameters:
 *   - oldService: The service identifier of the existing keychain items to migrate.
 *   - newService: The new service identifier to which the keychain items will be migrated.
 *
 * - Throws: `KeyError` if a keychain operation fails.
 * fixme: making unit tests for this is not easy, thread forward with caution. Maybe making unit-test in xcode scope would work better?
 */
public func migrateKeychainItems(
    from oldService: String,
    to newService: String
) throws {
    let items = try KeyReader.readAll(service: oldService)
    for (key, data) in items {
        let oldQuery = KeyQuery(key: key, service: oldService)
        let newQuery = KeyQuery(key: key, service: newService)
        try Key.insert(data: data, query: newQuery)
        try Key.delete(oldQuery)
    }
}
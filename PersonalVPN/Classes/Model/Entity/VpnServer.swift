import Foundation

enum VpnServerResponseCreationError: Error {
    case missingValue
}

struct VpnServer {
    let id: Int
    let location: String

    init(dict: [String: Any]) throws {
        guard let id = dict["id"] as? Int, let location = dict["location"] as? String else {
            throw VpnServerResponseCreationError.missingValue
        }
        self.id = id
        self.location = location
    }
}

extension VpnServer {
    var dict: [String: Any] { ["id": id, "location": location] }
}

import Foundation

enum APIKeys {
    static let BasePath = "API_BASE_URL"
    static let Key = "API_KEY"
}

extension Bundle {
    static func getAPIBasePath() -> String? {
        main.object(forInfoDictionaryKey: APIKeys.BasePath) as? String
    }

    static func getAPIKey() -> String? {
        main.object(forInfoDictionaryKey: APIKeys.Key) as? String
    }
}

enum NetworkConfiguration {
    enum Error: String, Swift.Error {
        case missingAPIPath
        case missingAPIKey
    }

    enum Key {
        static let UserToken = "app.yourpersonalvpn.storage.userToken"
    }

    static var userToken: String? {
        get {
            UserDefaultsStorage.shared.userToken
        }
        set(newValue) {
            UserDefaultsStorage.shared.userToken = newValue
        }
    }

    static func basePath() throws -> URL {
        guard let path = Bundle.getAPIBasePath() else { throw Error.missingAPIPath }
        return URL(string: "https://" + path)!
    }

    static func apiKey() throws -> String {
        guard let key = Bundle.getAPIKey() else { throw Error.missingAPIKey }
        return key
    }

    static let defaultTimeoutInterval: TimeInterval = 5
}

import Foundation

enum App {
    static let bundleId = "app.yourpersonalvpn"
    static let groupId = "group.app.lingviny.yourpersonalvpn"
    static let extensionId = "app.yourpersonalvpn.PVPNNE"
    static let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1.0"
    static let locale = Locale(identifier: Locale.preferredLanguages.first!).languageCode ?? "en"
    static let timezone = TimeZone.current
    static let currency = Locale.current.currencyCode ?? "USD"
    enum Amplitude {
        static let ApiKey = Bundle.main.amplitudeApiKey
        static let AppName = "VPN Master"
        static let AppParamName = "app"
        static let EventParams = [AppParamName: AppName]
        static let FirstLaunchEvent = "First Launch"
        static let IDFA = "IDFA"
        static let AdTracking = "ad_tracking"
        static let AdTrackingEnabled = "idfa enabled"
        static let AdTrackingDisabled = "idfa disabled"
        static let SearchAdsInstall = "Search Ads Install"
        static let UserIDSynced = "UserIDSynced"

        static func firstLaunchParams(for idfa: String) -> [String: String] {
            var params = [String: String]()
            let isEmpty = idfa == "00000000-0000-0000-0000-000000000000"
            params[AppParamName] = AppName
            params[IDFA] = idfa
            params[AdTracking] = isEmpty ? AdTrackingDisabled : AdTrackingEnabled
            return params
        }

        static func userId(for serverUserId: String) -> String {
            AppName + "_" + serverUserId
        }
    }
}

enum BuildSetting {
    case debug
    case release
    case testing

    static var currentBuild: Self {
        if let buildSetting = Bundle.main.infoDictionary?["BUILD_SETTING"] as? String {
            switch buildSetting {
            case "DEBUG":
                return .debug
            case "RELEASE":
                return .release
            case "TESTING":
                return .testing
            default:
                return .debug
            }
        } else {
            return .debug
        }
    }
}

extension Bundle {
    var amplitudeApiKey: String {
        switch BuildSetting.currentBuild {
        case .debug:
            return "dde6c038a32c3082b6debe249fad5d34"
        case .release:
            return "b503251969f4b1d7901d2f7d1388d476"
        case .testing:
            return "dde6c038a32c3082b6debe249fad5d34"
        }
    }
}

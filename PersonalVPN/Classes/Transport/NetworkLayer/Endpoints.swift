import Foundation

protocol Endpoint: Hashable {
    var baseURL: URL { get }
    var endpoint: String { get }
    var path: URL { get }
    var httpMethod: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
    var params: HTTPParams? { get }
}

extension Endpoint {
    var baseURL: URL {
        // TODO: handle this
        try! NetworkConfiguration.basePath()
    }

    var params: HTTPParams? {
        HTTPParams.defaultParams
    }

    var path: URL {
        baseURL.appendingPathComponent(endpoint)
    }

    var httpMethod: HTTPMethod {
        .get
    }

    var headers: HTTPHeaders? {
        httpMethod == .post ? ["Content-Type": "application/json"] : nil
    }

    var hashValue: Int {
        path.path.reduce(into: 0) { (hash, char) in hash ^= char.hashValue }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(path.hashValue)
    }

    static func ==(lhs: Self, rhs: Self) -> Bool {
        fatalError("== has not been implemented")
    }
}

enum CheckEndpoints {
    case apiKey
    case userToken(token: String)
}

extension CheckEndpoints: Endpoint {
    var endpoint: String {
        switch self {
        case .apiKey: return "check/api_key"
        case .userToken(_): return "check/user_token"
        }
    }
}

enum PaymentEndpoints {
    case paygate(version: String)
    case validate(receipt: String, version: String?)
}

extension PaymentEndpoints: Endpoint {
    var endpoint: String {
        switch self {
        case .paygate(_): return "payments/paygate"
        case .validate(_, _): return "payments/validate"
        }
    }

    var params: HTTPParams? {
        var header = HTTPParams.defaultParams
        switch self {
        case .paygate(let version):
            header["version"] = version
            break
        case .validate(let receipt, let version):
            header["version"] = version
            header["receipt"] = receipt
            break
        }
        return header
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .paygate:
             return .get
        case .validate:
            return .post
        }
    }
}

enum VpnEndpoints {
    case list
    case configuration(vpnId: String)
}

extension VpnEndpoints: Endpoint {
    var endpoint: String {
        switch self {
        case .list: return "vpn/list"
        case .configuration(_): return "vpn/configuration"
        }
    }

    var params: HTTPParams? {
        var header = HTTPParams.defaultParams
        switch self {
        case .configuration(let vpnId):
            header["vpn_id"] = vpnId
            break
        default: break
        }
        return header
    }
}

enum UserEndpoints {
    case anonymous(user: User)
    case clone(pushKey: String)
    case set(idfa: String?, randomString: String?, version: String, locale: String, timezone: String, storeCountry: String)
    case addAdsInfo(attrs: [String: String])
}

extension UserEndpoints: Endpoint {
    var endpoint: String {
        switch self {
        case .anonymous(_): return "users/anonymous"
        case .clone(_): return "users/clone"
        case .set(_, _, _, _, _, _): return "users/set"
        case .addAdsInfo(_): return "users/add_search_ads_info"
        }
    }

    var params: HTTPParams? {
        var header = HTTPParams.defaultParams
        switch self {
        case .set(let idfa, let rstr, let version, let locale, let timezone, let storeCountry):
            if let idfa = idfa { header["idfa"] = idfa }
            if let rstr = rstr { header["random_string"] = rstr }
            header["version"] = version
            header["locale"] = locale
            header["timezone"] = timezone
            header["store_country"] = storeCountry
            break
        case .addAdsInfo(let attrs):
            attrs.forEach { (h: (key: String, value: String)) in header[h.key] = h.value }
            break
        default:
            break
        }
        return header
    }
}

enum AppInstallsEndpoint {
    case register(idfa: String, randomString: String, version: String, attributes: [String: String])
}

extension AppInstallsEndpoint: Endpoint {
    var endpoint: String {
        switch self {
        case .register(_, _, _, _): return "app_installs/register"
        }
    }

    var params: HTTPParams? {
        var header = HTTPParams.defaultParams
        switch self {
        case .register(let idfa, let randomString, let version, let attributes):
            header["idfa"] = idfa
            header["version"] = version
            header["random_string"] = randomString
            attributes.forEach { (h: (key: String, value: String)) in header[h.key] = h.value }
            break
        }
        return header
    }
}

import Foundation

struct BaseResponse: ResponseProtocol {
    let needPayment: Bool
    init(rawResponse: Dictionary<String, AnyObject>) throws {
        let _needPayment: Bool? = rawResponse["_need_payment"] as? Bool

        guard let np = _needPayment else {
            throw CheckTokenResponseCreationError.missingValue
        }

        self.needPayment = np
    }
}
import Foundation

struct PaygateResponse: ResponseProtocol {
    let needPayment: Bool
    let caption: String
    let button: String
    let productId: String
    let heading: String

    init(rawResponse: Dictionary<String, AnyObject>) throws {
        let _caption: String? = rawResponse["pre_button"] as? String
        let _button: String? = rawResponse["button"] as? String
        let _needPayment: Bool? = rawResponse["_need_payment"] as? Bool
        let _productId: String? = rawResponse["product_id"] as? String
        let _heading: String = rawResponse["heading"] as? String ?? ""

        guard let ct = _caption, let btn = _button, let np = _needPayment, let pi = _productId else {
            throw CheckTokenResponseCreationError.missingValue
        }

        self.caption = ct
        self.button = btn
        self.productId = pi
        self.needPayment = np
        self.heading = _heading
    }
}

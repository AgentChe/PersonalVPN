import Foundation

enum ApiClientError: Error {
    case httpError(error: Error)
    case missingDataInResponse
    case unexpectedResponseDataType
    case criticalError(code: Int, msg: String)
    case tokenInvalid(code: Int, msg: String)
    case internalError(code: Int, msg: String)
    case needPayment
    case sameRequestInQueue
}
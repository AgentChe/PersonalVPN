import Foundation

struct ClientResponse {
    let needPayment: Bool
    let data: AnyObject?
    let error: ApiClientError?
}

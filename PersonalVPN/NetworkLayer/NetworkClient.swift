import Foundation

protocol Networking {
    func request<E: Endpoint>(_ endpoint: E, completion: @escaping ([String: AnyObject]?, Error?) -> ())
}

class NetworkClient: Networking {
    func request<E: Endpoint>(_ endpoint: E, completion: @escaping ([String: AnyObject]?, Error?) -> ()) {
        let router = NetworkRouter<E>()
        router.request(endpoint) { (data: Data?, response: URLResponse?, error: Error?) -> () in
            guard let data = data else { return }
            do {
                let object = try JSONSerialization.jsonObject(with: data)
                completion(object as? [String : AnyObject], nil)
            } catch {
                completion(nil, error)
            }
        }
    }
}
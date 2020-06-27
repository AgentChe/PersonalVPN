import Foundation

typealias NetworkRequestCompletion = (_ data: Data?, _ response: URLResponse?, _ error:Error?) -> ()

protocol NetworkRouting {
    associatedtype NetworkEndpoint: Endpoint

    func request(_ endpoint: NetworkEndpoint, completion: @escaping NetworkRequestCompletion)
    func cancel()
}

class NetworkRouter<E: Endpoint>: NetworkRouting {
    typealias NetworkEndpoint = E

    func request(_ endpoint: E, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        let session = URLSession.shared
        var request: URLRequest
        do {
            request = try makeRequest(for: endpoint)
        } catch {
            completion(nil, nil, error)
            return
        }
        self.dataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            completion(data, response, error)
        }
        self.dataTask?.resume()
    }

    private func makeRequest(for endpoint: NetworkEndpoint) throws -> URLRequest {
        let url: URL = makePath(for: endpoint).url!
        var request = URLRequest(url: url, timeoutInterval: NetworkConfiguration.defaultTimeoutInterval)
        request.allHTTPHeaderFields = endpoint.headers
        if endpoint.httpMethod != .get {
            request.httpBody = try JSONSerialization.data(withJSONObject: endpoint.params ?? [])
        }
        request.httpMethod = endpoint.httpMethod.rawValue
        return request
    }

    private func makePath(for endpoint: NetworkEndpoint) -> URLComponents {
        var url = URLComponents(string: endpoint.path.absoluteString)!
        if endpoint.httpMethod != .get {
            return url
        }
        guard let params = endpoint.params else { return url }
        url.queryItems = params.map { (key: String, value: String) -> URLQueryItem in URLQueryItem(name: key, value: value) }
        url.percentEncodedQuery = url.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        return url
    }

    func cancel() {
        self.dataTask?.cancel()
    }

    private var dataTask: URLSessionDataTask?
}

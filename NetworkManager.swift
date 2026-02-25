import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    private let session = URLSession.shared
    
    enum NetworkError: Error {
        case invalidURL
        case invalidResponse
        case decodingError
        case networkError(Error)
    }
    
    func fetch<T: Decodable>(from urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(T.self, from: data)
            return decodedData
        } catch is DecodingError {
            throw NetworkError.decodingError
        } catch {
            throw NetworkError.networkError(error)
        }
    }
    
    func post<T: Decodable>(to urlString: String, body: Data) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}
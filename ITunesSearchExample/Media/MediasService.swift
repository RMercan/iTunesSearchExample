//
//  MediasService.swift
//  ITunesSearchExample
//
//  Created by RabiaMercan on 4.03.2024.

import UIKit


final class MediasService {
    
    static let shared = MediasService()
    
    var filteredMedia: [Media] = []
    var allMedia: [Media] = []
    var playlist: [Media] = []

    
    enum MediasServiceError: Error {
        case invalidJSON
        case decoding
    }
    
    enum MediasResult {
        case success([Media])
        case failure(Error)
    }
    
    struct SearchResponse: Codable {
        let results: [Media]
    }
    
    func fetch(urlParameters: [String: String], _ completion: @escaping (_ result: MediasResult) -> Void) {
        // API çağrısı
        let baseURL = URL(string: "https://itunes.apple.com/search")!
        let newURL = baseURL.appending(urlParameters)
        print("API URL:", newURL.absoluteString)
        
        URLSession.shared.dataTask(with: newURL) { [weak self] data, _, error  in
            if let error = error {
                print("Error:", error.localizedDescription)
                completion(.failure(error))
                return
            }

            guard let data = data else {
                let error = MediasServiceError.invalidJSON
                completion(.failure(error))
                return
            }
            
            // API'dan gelen verileri işle
            do {
                let decoder = JSONDecoder()
                //print(data.base64EncodedString())
                
                let response = try decoder.decode(MediaServiceBaseResponse.self, from: data)
                print("resultCount: ", response.resultCount)
                
                let mediaArray = response.results
                completion(.success(mediaArray))
            } catch {
                print("Error decoding response:", error.localizedDescription)
                completion(.failure(error))
            }
        }.resume()
    }
}


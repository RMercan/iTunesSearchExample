//
//  URLExtensions.swift
//  ITunesSearchExample
//
//  Created by RabiaMercan on 4.03.2024.
//

import Foundation

public extension URL {
    
    func appending(_ parameters: [String: String]) -> URL {
        guard var urlComponents = URLComponents(string: absoluteString) else { return absoluteURL }

        var queryItems: [URLQueryItem] = urlComponents.queryItems ?? []

        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: value)
            queryItems.append(queryItem)
        }

        urlComponents.queryItems = queryItems
        return urlComponents.url!
    }
}

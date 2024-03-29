//
//  MediaServiceBaseResponse.swift
//  ITunesSearchExample
//
//  Created by RabiaMercan on 4.03.2024.
//

import Foundation

struct MediaServiceBaseResponse: Codable {
    
    var resultCount: Int
    var results: [Media]
    
}

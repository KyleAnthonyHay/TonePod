//
//  RandomWordAPI.swift
//  TonePod
//
//  Created by Kyle-Anthony Hay on 10/24/23.
//

import Foundation

struct RandomWordsAPI {

    static let shared = RandomWordsAPI()

    private let urlSession: URLSession

    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    // MARK: API Request With <Letter>
    func randomWordStartsWith(startingLetter letter: String) async throws -> RandomWord {
        let url = URL(string: "https://random-word-api.p.rapidapi.com/S/\(letter)")!
        let urlRequest = NSMutableURLRequest(url: url,
                                             cachePolicy: .useProtocolCachePolicy,
                                             timeoutInterval: 10.0)
        urlRequest.httpMethod = "GET"
        
        // Set the headers
        let headers = [
            "X-RapidAPI-Key": "f44a8d70a6msh7a391d404e30cabp1e76a1jsnf638d3bd5e40",
            "X-RapidAPI-Host": "random-word-api.p.rapidapi.com"
        ]
        urlRequest.allHTTPHeaderFields = headers

        let (data, response) = try await urlSession.data(for: urlRequest as URLRequest) // .data returns tuple
        
        //Error Handling
        guard let response = response as? HTTPURLResponse else {
            throw RandomWordsAPIError.requestFailed(message: "Response is not HTTPURLResponse.")
        }

        guard 200...299 ~= response.statusCode else {
            throw RandomWordsAPIError.requestFailed(message: "Status Code should be 2xx, but is \(response.statusCode).")
        }

        // assign random word
        let randomWordStartsWith = try JSONDecoder().decode(RandomWord.self, from: data)
        print("From RandomWordsAPI: \(randomWordStartsWith)") // <-- this prints
        
        return randomWordStartsWith
    }

}

struct RandomWord : Decodable {
    let word: String
}

enum RandomWordsAPIError : Error {
    case requestFailed(message: String)
}



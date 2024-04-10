//
//  RestUtility.swift
//  MadLibz
//
//  Created by Rohit Bagda on 4/7/24.
//

import Foundation

func get<T: Codable>(from url: URL, completion: @escaping (Result<T, Error>) -> Void) {
    URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            completion(.failure(error ?? URLError(.unknown)))
            return
        }
        decode(data: data, completion: completion)
    }.resume()
}

func post<T: Codable, R:Codable>(data: T, to url: URL, completion: @escaping (Result<R, Error>) -> Void) {
    var done = false
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    do {
        let requestJson = try JSONEncoder().encode(data)
        request.httpBody = requestJson
    } catch {
        completion(.failure(error))
        return
    }
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            completion(.failure(error ?? URLError(.unknown)))
            return
        }
        decode(data: data, completion: completion)
        done = true
    }.resume()
    
    // Wait for post request to complete before returning;
    repeat { RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1)) } while !done
}

fileprivate func decode<T: Codable>(data: Data, completion: @escaping (Result<T, Error>) -> Void) {
    // If the expected Response is String don't try decoding as JSON
    if T.Type.self == String.Type.self {
        let decodedData = String(data: data,  encoding:String.Encoding.utf8)
        DispatchQueue.main.async { completion(.success(decodedData as! T)) }
    } else {
        do {
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            DispatchQueue.main.async { completion(.success(decodedData)) }
        } catch {
            completion(.failure(error))
        }
    }
}

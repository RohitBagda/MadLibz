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
        
        do {
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            DispatchQueue.main.async { completion(.success(decodedData)) }
        } catch {
            completion(.failure(error))
        }
    }.resume()
}

func post<T: Codable, R:Codable>(data: T, to url: URL, completion: @escaping (Result<R, Error>) -> Void) {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    var done = false

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
        
        // If the expected Response is String don't try decoding as JSON
        if R.Type.self == String.Type.self {
            let decodedData = String(data: data,  encoding:String.Encoding.utf8)
            DispatchQueue.main.async { completion(.success(decodedData as! R)) }
        } else {
            // Expected Response Type is a Struct, try decoding as JSON
            do {
                let decodedData = try JSONDecoder().decode(R.self, from: data)
                DispatchQueue.main.async { completion(.success(decodedData)) }
            } catch {
                completion(.failure(error))
            }
        }
        done = true
    }.resume()
    
    // Wait for post request to complete before returning;
    repeat { RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1)) } while !done
}

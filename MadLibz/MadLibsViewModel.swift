//
//  MadLibsViewModel.swift
//  MadLibz
//
//  Created by Rohit Bagda on 4/5/24.
//

import Foundation

class MadLibsViewModel: ObservableObject {
    @Published var madLibs: [MadLib] = []
    @Published var madLibQuestions: [Int: MadLibQuestions] = [:]
    @Published var madLibsSubmissions: [Int: MadLibSubmission] = [:]
    @Published var madLibSubmissionResponse: [Int: String] = [:]
    
    var baseUrl: String = "https://seng5199madlib.azurewebsites.net/api"
    
    func getMadLibs() {
        guard let url = URL(string: "\(baseUrl)/MadLib") else { return }
        get(from: url) { (result: Result<[MadLib], Error>) in
            switch result {
                case .success(let madLibs): self.madLibs = madLibs
                case .failure(let error): print("Error fetching MadLib questions: \(error)")
            }
        }
    }
    
    func getMadLib(id: Int) {
        guard let url = URL(string: "\(baseUrl)/MadLib/\(id)") else { return }
        get(from: url) { (result: Result<MadLibQuestions, Error>) in
            switch result {
                case .success(let madLibQuestions): self.madLibQuestions.updateValue(madLibQuestions, forKey: id)
                case .failure(let error): print("Error fetching MadLib questions: \(error)")
            }
        }
    }
    
    func postMadLibSubmission(submission: MadLibSubmission) {
        guard let url = URL(string: "\(baseUrl)/PostMadLib)") else { return }
        post(data: submission, to: url) { (result: Result<String, Error>) in
            switch result {
                case .success(let response):
                    self.madLibsSubmissions[submission.id] = submission
                    self.madLibSubmissionResponse[submission.id] = response
                    print("\(response)")
                case .failure(let error):
                    print("Error posting MadLib: \(error)")
            }
        }
    }

    
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
        
        do {
            let jsonData = try JSONEncoder().encode(data)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let responseData = data, error == nil else {
                completion(.failure(error ?? URLError(.unknown)))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(R.self, from: responseData)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

struct MadLib: Codable {
    let id: Int
    let storyTitle: String
}

struct MadLibQuestions: Codable {
    let id: Int
    let storyTitle: String
    let story: String
    let questions: [MadLibQuestion]
}

struct MadLibQuestion: Codable {
    let id: Int
    let position: Int
    let description: String
}

struct MadLibSubmission: Codable {
    let id: Int
    let madLibId: Int
    let username: String
    let timestamp: String
    let answers: [MadLibAnswer]
}

struct MadLibAnswer: Codable {
    let id: Int
    let questionId: Int
    let answerValue: String
}

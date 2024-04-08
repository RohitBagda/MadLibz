//
//  MadLibzViewModel.swift
//  MadLibz
//
//  Created by Rohit Bagda on 4/5/24.
//

import Foundation

class MadLibzViewModel: ObservableObject {
    @Published var madLibz: [MadLib] = []
    @Published var madLibQuestions: [Int: MadLibQuestions] = [:]
    @Published var madLibSubmissions: [Int: MadLibSubmission] = [:]
    @Published var madLibSubmissionResponse: [Int: String] = [:]
    
    var baseUrl: String = "https://seng5199madlib.azurewebsites.net/api"
    
    func getMadLibs() {
        guard let url = URL(string: "\(baseUrl)/MadLib") else { return }
        get(from: url) { (result: Result<[MadLib], Error>) in
            switch result {
                case .success(let madLibs): self.madLibz = madLibs
                case .failure(let error): print("Error fetching MadLibs: \(error)")
            }
        }
    }
    
    func getMadLib(id: Int) {
        guard let url = URL(string: "\(baseUrl)/MadLib/\(id)") else { return }
        get(from: url) { (result: Result<MadLibQuestions, Error>) in
            switch result {
                case .success(let madLibQuestions): self.madLibQuestions.updateValue(madLibQuestions, forKey: id)
                case .failure(let error): print("Error fetching MadLib:\(id) questions: \(error)")
            }
        }
    }
    
    func postMadLibSubmission(submission: MadLibSubmission) {
        guard let url = URL(string: "\(baseUrl)/PostMadLib") else { return }
        post(data: submission, to: url) { (result: Result<String, Error>) in
            switch result {
                case .success(let response):
                    self.madLibSubmissions[submission.madLibId] = submission
                    self.madLibSubmissionResponse[submission.madLibId] = response
                case .failure(let error):
                    print("Error posting MadLib: \(error)")
            }
        }
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
    let madLibId: Int
    let username: String
    let timestamp: String
    let answers: [MadLibAnswer]
}

struct MadLibAnswer: Codable {
    let questionId: Int
    let answerValue: String
}

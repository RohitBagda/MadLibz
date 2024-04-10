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
    @Published var filledOutMadLibz: [FilledOutMadLib] = []
    @Published var filledOutMadLibzStories: [Int: String] = [:]
    @Published var username = "bagda008"
    private var baseUrl: String = "https://seng5199madlib.azurewebsites.net/api"
    
    func getMadLibs() {
        guard let url = URL(string: "\(baseUrl)/MadLib") else { return }
        get(from: url) { (result: Result<[MadLib], Error>) in
            switch result {
                case .success(let madLibz): self.madLibz = madLibz
                case .failure(let error): print("Error fetching MadLibs: \(error)")
            }
        }
    }
    
    func getMadLibQuestions(id: Int) {
        guard let url = URL(string: "\(baseUrl)/MadLib/\(id)") else { return }
        get(from: url) { (result: Result<MadLibQuestions, Error>) in
            switch result {
                case .success(let madLibQuestions): self.madLibQuestions.updateValue(madLibQuestions, forKey: id)
                case .failure(let error): print("Error fetching MadLib:\(id) questions: \(error)")
            }
        }
    }
    
    func getFilledOutMadLibz(username: String) {
        guard let url = URL(string: "\(baseUrl)/PostMadLib?username=\(username)") else { return }
        get(from: url) { (result: Result<[FilledOutMadLib], Error>) in
            switch result {
                case .success(let filledOutMadLibz): self.filledOutMadLibz = filledOutMadLibz
                case .failure(let error): print("Error fetching FilledOutMadLibz: \(error)")
            }
        }
    }
    
    func getMadLibStory(id: Int) {
        guard let url = URL(string: "\(baseUrl)/PostMadLib/\(id)") else { return }
        get(from: url) { (result: Result<String, Error>) in
            switch result {
                case .success(let story): 
                    self.filledOutMadLibzStories.updateValue(story, forKey: id)
                case .failure(let error): print("Error fetching FilledOutMadLib:\(id) story: \(error)")
            }
        }
    }
    
    func postMadLibSubmission(submission: MadLibSubmission) -> String? {
        var madLibResult: String? = nil
        guard let url = URL(string: "\(baseUrl)/PostMadLib") else { return madLibResult }
        post(data: submission, to: url) { (result: Result<String, Error>) in
            switch result {
                case .success(let response):
                    madLibResult = response
                case .failure(let error):
                    print("Error posting MadLib: \(error)")
            }
        }
        return madLibResult
    }
}

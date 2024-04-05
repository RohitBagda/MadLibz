//
//  ContentView.swift
//  MadLibz
//
//  Created by Rohit Bagda on 4/4/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = MadLibsViewModel()
    @State private var isShowingMadLibs = false
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: MadLibsListView(viewModel: viewModel)) {
                    Text("Show Madlibs")
                }.onAppear {
                    viewModel.getMadLibs()
                }
            }
            .navigationTitle("Let's Play MadLibs!")
        }
    }
}

struct MadLibsListView: View {
    @ObservedObject var viewModel: MadLibsViewModel

    var body: some View {
        List(viewModel.madLibs, id: \.id) { madLib in
            
            NavigationLink(destination: MadLibView(viewModel: viewModel, madLibId: madLib.id)) {
                Text(madLib.storyTitle)
            }.onAppear {
                viewModel.getMadLib(id: madLib.id)
            }
            
        }
        .navigationTitle("MadLibs List")
    }
}

struct MadLibView: View {
    @ObservedObject var viewModel: MadLibsViewModel
    var madLibId: Int
     
    @State private var answers: [Int: String] = [:]

    var body: some View {
            VStack {
                let questions = viewModel.madLibQuestions[madLibId]?.questions ?? []
                ForEach(questions, id: \.id) { question in
                    TextField(question.description, text: Binding(
                        get: { return answers[question.id] ?? "" },
                        set: { newValue in answers[question.id] = newValue }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .scenePadding()
                }

                Button("Submit") {
                    // Handle submission of answers
                    print(answers)
                }
                .padding()
            }
            .navigationTitle(viewModel.madLibQuestions[madLibId]?.storyTitle ?? "madLib storyTitle")
            .onAppear {
                // Initialize answers array with empty strings
                let questions = viewModel.madLibQuestions[madLibId]?.questions ?? []
                questions.forEach({ question in
                    answers.updateValue("", forKey: question.id)
                })
            }
        }
}

class MadLibsViewModel: ObservableObject {
    @Published var madLibs: [MadLib] = []
    @Published var madLibQuestions: [Int: MadLibQuestions] = [:]
    var baseUrl: String = "https://seng5199madlib.azurewebsites.net/api"
    
    func getMadLibs() {
        guard let url = URL(string: "\(baseUrl)/MadLib") else { return }
        get(from: url) { (result: Result<[MadLib], Error>) in
            switch result {
            case .success(let madLibs):
                DispatchQueue.main.async { self.madLibs = madLibs }
            case .failure(let error):
                print("Error fetching MadLib questions: \(error)")
            }
        }
    }
    
    func getMadLib(id: Int) {
        guard let url = URL(string: "\(baseUrl)/MadLib/\(id)") else { return }
        get(from: url) { (result: Result<MadLibQuestions, Error>) in
            switch result {
            case .success(let madLibQuestions):
                DispatchQueue.main.async { self.madLibQuestions.updateValue(madLibQuestions, forKey: id) }
            case .failure(let error):
                print("Error fetching MadLib questions: \(error)")
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

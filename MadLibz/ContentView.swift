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
                    Capsule()
                        .fill()
                        .frame(width: 150, height: 50)
                        .overlay(
                            Text("Play MadLibs")
                                .foregroundStyle(Color.primary)
                        )
                        
                }.onAppear {
                    viewModel.getMadLibs()
                }
            }
            .navigationBarTitle("Are you Mad?", displayMode: .large)
        }
    }
}

struct MadLibsListView: View {
    @ObservedObject var viewModel: MadLibsViewModel

    var body: some View {
        VStack {
            List(viewModel.madLibs, id: \.id) { madLib in
                
                NavigationLink(destination: MadLibView(viewModel: viewModel, madLibId: madLib.id)) {
                    Text(madLib.storyTitle)
                }.onAppear {
                    viewModel.getMadLib(id: madLib.id)
                }
            }
        }.navigationBarTitle("MadLibs List", displayMode: .large)
    }
}

struct MadLibView: View {
    @ObservedObject var viewModel: MadLibsViewModel
    var madLibId: Int
     
    @State private var answers: [Int: String] = [:]

    fileprivate func getMadLibQuestions() -> [MadLibQuestion] {
        return viewModel.madLibQuestions[madLibId]?.questions ?? []
    }
    
    var body: some View {
        ScrollView{
            VStack {
                Text("Provide answers to the following questions!")
                let questions = getMadLibQuestions()
                ForEach(questions, id: \.id) { question in
                    VStack(alignment: .leading) {
                        if (answers[question.id] != "") {
                            Text(question.description)
                        }
                        TextField(question.description, text: Binding(
                            get: { return answers[question.id] ?? "" },
                            set: { newValue in answers[question.id] = newValue }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    }.padding(10)
                }

                if (answers.values.allSatisfy({ answer in answer != ""})) {
                    Button("Submit") {
                        // Handle submission of answers
                        let submission = createMadLibSubmission(answers: answers, madLibId: madLibId)
                        print(submission)
                        viewModel.postMadLibSubmission(submission: submission)
                    }.buttonStyle(CapsuleGrowingButton())
                    .padding()
                }
                
            }
            .navigationTitle(viewModel.madLibQuestions[madLibId]?.storyTitle ?? "madLib storyTitle")
            .onAppear {
                // Initialize answers array with empty strings
                let questions = getMadLibQuestions()
                questions.forEach({ answers.updateValue("", forKey: $0.id) })
            }
        }
    }
    
    func createMadLibSubmission(answers: [Int: String], madLibId: Int) -> MadLibSubmission {
        let date = Date()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.insert(.withFractionalSeconds)
        let dateString = formatter.string(from: date)
        let submission = MadLibSubmission(
            id: 1000,
            madLibId: madLibId,
            username: "rocket",
            timestamp: dateString,
            answers: answers.map { MadLibAnswer(id: 100, questionId: $0, answerValue: $1) }
        )
        return submission
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct CapsuleGrowingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(.blue)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10.0))
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

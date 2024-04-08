//
//  MadLibView.swift
//  MadLibz
//
//  Created by Rohit Bagda on 4/7/24.
//

import SwiftUI

struct MadLibView: View {
    @ObservedObject var viewModel: MadLibzViewModel
    var madLibId: Int
     
    @State private var answers: [Int: String] = [:]
    @State private var madLibResult: String = "Loading..."
    @State private var showResult: Bool = false
    
    fileprivate func getMadLibQuestions() -> [MadLibQuestion] {
        return viewModel.madLibQuestions[madLibId]?.questions ?? []
    }
    
    var body: some View {
        
        ScrollView {
            VStack {
                Text("Provide answers to the following questions!")
                let questions = getMadLibQuestions()
                ForEach(questions, id: \.id) { question in
                    VStack(alignment: .leading) {
                        LabeledContent {
                            TextField("type here", text: Binding(
                                get: { return answers[question.id] ?? "" },
                                set: { newValue in answers[question.id] = newValue }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        } label: {
                            Text(question.description)
                        }
                    }.padding(.horizontal)
                }
                if (answers.values.allSatisfy({ answer in answer != ""})) {
                    Button(action: {
                        viewModel.postMadLibSubmission(
                            submission: createMadLibSubmission(answers: answers, madLibId: madLibId)
                        )
                        madLibResult = viewModel.madLibSubmissionResponse[madLibId] ?? "Loading...."
                        showResult = true
                    }, label: {
                        Text("Submit")
                    })
                }
                
                if (showResult) {
                    VStack{
                        Text("Here's your composed MadLib:")
                        Text(madLibResult).padding(.top)
                    }.padding()
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
            madLibId: madLibId,
            username: "rocket",
            timestamp: dateString,
            answers: answers.map { MadLibAnswer(questionId: $0, answerValue: $1) }
        )
        return submission
    }
}

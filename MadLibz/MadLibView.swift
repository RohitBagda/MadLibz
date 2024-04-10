//
//  MadLibView.swift
//  MadLibz
//
//  Created by Rohit Bagda on 4/7/24.
//

import SwiftUI

struct MadLibView: View {
    @ObservedObject var viewModel: MadLibzViewModel
    var storyTitle: String
    var madLibId: Int
     
    @State private var answers: [Int: String] = [:]
    @State private var madLibResult: String = "Loading..."
    @State private var madLibResultIsFetched: Bool = false
    
    var body: some View {
        ScrollView {
            VStack {
                Text(storyTitle).padding()
                Text("Provide answers to the following questions:")
                displayMadLibQuestionLabels()
                if (questionsAreAnswered()) { displaySubmitButton() }
                if (madLibResultIsFetched) { displayResult() }
            }
            .onAppear {
                initializeAnswers()
            }
        }
    }
    
    fileprivate func getMadLibQuestions() -> [MadLibQuestion] {
        return viewModel.madLibQuestions[madLibId]?.questions ?? []
    }
    
    fileprivate func displayMadLibQuestionLabels() -> ForEach<[MadLibQuestion], Int, some View> {
        let questions = getMadLibQuestions()
        return ForEach(questions, id: \.id) { question in
            VStack(alignment: .leading) {
                createMadLibQuestionLabel(question: question)
            }.padding(.horizontal)
        }
    }
    
    fileprivate func createMadLibQuestionLabel(question: MadLibQuestion) -> LabeledContent<Text, some View> {
        return LabeledContent {
            TextField("Type here...", text: Binding(
                get: { return answers[question.id] ?? "" },
                set: { newValue in answers[question.id] = newValue }
            ))
            .textFieldStyle(RoundedBorderTextFieldStyle())
        } label: {
            Text(question.description)
        }
    }
    
    fileprivate func initializeAnswers() {
        getMadLibQuestions().forEach({ answers.updateValue("", forKey: $0.id) })
    }
    
    fileprivate func questionsAreAnswered() -> Bool {
        return answers.values.allSatisfy({ answer in answer != ""})
    }
    
    fileprivate func displaySubmitButton() -> Button<Text> {
        return Button(action: { submitAnswers() }, label: { Text("Submit") })
    }
    
    fileprivate func submitAnswers() {
        // Post Answers and fetch MadLib Result
        let submission = MadLibSubmission(
            madLibId: madLibId,
            username: viewModel.username,
            timestamp: getDate(),
            answers: answers.map { MadLibAnswer(questionId: $0, answerValue: $1) }
        )
        madLibResult = viewModel.postMadLibSubmission(submission: submission) ?? "An Error Occurred"
        madLibResultIsFetched = true
    }
    
    fileprivate func getDate() -> String {
        let date = Date()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.insert(.withFractionalSeconds)
        return formatter.string(from: date)
    }
    
    fileprivate func displayResult() -> some View {
        return VStack{
            Text("Here's your composed MadLib:")
            Text(madLibResult).padding(.top)
        }.padding()
    }
}

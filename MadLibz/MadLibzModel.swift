//
//  MadLibzModel.swift
//  MadLibz
//
//  Created by Rohit Bagda on 4/9/24.
//

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

struct FilledOutMadLib: Codable {
    let filledOutMadLibId: Int
    let madLibId: Int
    let timestamp: String
    let storyTitle: String
}

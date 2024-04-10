//
//  FilledOutMadLibView.swift
//  MadLibz
//
//  Created by Rohit Bagda on 4/9/24.
//

import SwiftUI

struct FilledOutMadLibView: View {
    @ObservedObject var viewModel: MadLibzViewModel
    var storyTitle: String
    var filledOutMadLibId: Int
    @State private var completedStory: String = "Loading..."
    
    var body: some View {
        ScrollView {
            Text(storyTitle).padding()
            Text(completedStory).padding()
        }.onAppear {
            completedStory = viewModel.filledOutMadLibzStories[filledOutMadLibId] ?? "completed story"
        }
    }
}

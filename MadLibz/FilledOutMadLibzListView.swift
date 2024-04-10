//
//  FilledOutMadLibzListView.swift
//  MadLibz
//
//  Created by Rohit Bagda on 4/9/24.
//

import SwiftUI

struct FilledOutMadLibzListView: View {
    @ObservedObject var viewModel: MadLibzViewModel
    var body: some View {
        VStack {
            List(viewModel.filledOutMadLibz, id: \.filledOutMadLibId) { filledOutMadLib in
                NavigationLink(destination: FilledOutMadLibView(
                    viewModel: viewModel,
                    storyTitle: filledOutMadLib.storyTitle,
                    filledOutMadLibId: filledOutMadLib.filledOutMadLibId
                )) {
                    VStack(alignment: .leading){
                        Section {
                            Text(filledOutMadLib.storyTitle)
                        } footer: {
                            Text(getFormattedDateTime(timestamp: filledOutMadLib.timestamp))
                        }
                    }
                }.onAppear {
                    if (viewModel.filledOutMadLibzStories[filledOutMadLib.filledOutMadLibId] == nil) {
                        viewModel.getMadLibStory(id: filledOutMadLib.filledOutMadLibId)
                    }
                }
            }
        }.navigationBarTitle("Completed MadLibz", displayMode: .inline)
    }
    
    fileprivate func getFormattedDateTime(timestamp: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.insert(.withFractionalSeconds)
        // API has a bug where timestamp returned does not follow ISO8601 timestamp
        // in that it is missing a trailing Z.
        if let date = formatter.date(from: "\(timestamp)Z")?.formatted(date: .numeric, time: .shortened) {
            return date
        }
        return ""
    }
}

//
//  MadLibzListView.swift
//  MadLibz
//
//  Created by Rohit Bagda on 4/7/24.
//

import SwiftUI

struct MadLibzListView: View {
    @ObservedObject var viewModel: MadLibzViewModel
    var body: some View {
        VStack {
            List(viewModel.madLibz, id: \.id) { madLib in
                NavigationLink(destination: MadLibView(
                    viewModel: viewModel,
                    storyTitle: madLib.storyTitle,
                    madLibId: madLib.id
                )) {
                    Text(madLib.storyTitle)
                }.onAppear {
                    if (viewModel.madLibQuestions[madLib.id] == nil) {
                        viewModel.getMadLibQuestions(id: madLib.id)
                    }
                }
            }
        }.navigationBarTitle("MadLibs List", displayMode: .inline)
    }
}

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
                
                NavigationLink(destination: MadLibView(viewModel: viewModel, madLibId: madLib.id)) {
                    Text(madLib.storyTitle)
                }.onAppear {
                    viewModel.getMadLib(id: madLib.id)
                }
            }
        }.navigationBarTitle("MadLibs List", displayMode: .large)
    }
}

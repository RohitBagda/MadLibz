//
//  ContentView.swift
//  MadLibz
//
//  Created by Rohit Bagda on 4/4/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = MadLibzViewModel()
    @State private var isShowingMadLibs = false
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: MadLibzListView(viewModel: viewModel)) {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


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
                    CapsuleView(text: "Play MadLibz")
                }.onAppear {
                    viewModel.getMadLibs()
                }
                
                NavigationLink(destination: FilledOutMadLibzListView(viewModel: viewModel)) {
                    CapsuleView(text: "View Completed MadLibz")
                }.onAppear {
                    viewModel.getFilledOutMadLibz(username: viewModel.username)
                }
            }
            .navigationBarTitle("Are you Mad?", displayMode: .inline)
        }
    }
}

struct CapsuleView: View {
    var text: String
    var body: some View {
        Capsule()
            .fill()
            .frame(width: 250, height: 75)
            .overlay(
                Text(text)
                    .foregroundStyle(Color.primary)
            )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  ContentView.swift
//  MacAppFocusable
//
//  Created by nhatle on 6/9/20.
//  Copyright © 2020 VNG. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var flag = false

    var body: some View {
        Group {
            if !flag {
                Color.clear.onAppear { self.flag = true }
            } else {
                MainView()
            }
        }
    }
}

struct MainView: View {
    @State private var selectedFocusIdx = 2
    var body: some View {
        VStack {
            HStack {
                Circle().fill(Color.yellow)
                    .focusableWithClick(focusIndex: 1)
                
                VStack {
                    Circle().fill(Color.orange)
                    
                    HStack {
                        Circle().fill(Color.orange)
                        
                        Circle().fill(Color.orange)
                    }
                }
                .focusableWithClick(focusIndex: 2)
                
                Circle().fill(Color.red)
                    .focusableWithClick(focusIndex: 3)
                
            }.padding(.bottom, 40.0)
            
            HStack {
                Button("Deselect All")  { self.selectedFocusIdx = 0 }
                Button("1") { self.selectedFocusIdx = 1 }
                Button("2") { self.selectedFocusIdx = 2 }
                Button("3") { self.selectedFocusIdx = 3 }
            }
            
            Text("Idx = \(self.selectedFocusIdx)").font(.headline)

        }
        .environment(\.selectedFocusIndex, $selectedFocusIdx)
        .padding(20)
        .frame(width: 500, height: 300)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

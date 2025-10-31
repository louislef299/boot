//
//  ContentView.swift
//  Boot
//
//  Created by Lefebvre, Louis on 10/31/25.
//

import SwiftUI

struct ContentView: View {
    @State private var objects: [Object] = []
    @State private var count = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Boot🥾")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom)
            }
            .padding(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack {
                Button("Boot!") {
                    objects.append(Object(name: "boot\(count)"))
                    count = count + 1
                }
                .buttonStyle(.borderedProminent)
                .font(.title2)
                .padding()
                
                Spacer()
                
                // this will be where we will put all the boot files
                Text("Files currently in Boot:")
                    .font(.title2)
                    .padding(.bottom)
                ScrollView {
                    VStack {
                        ForEach(objects) {
                            Text($0.name)
                        }
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}

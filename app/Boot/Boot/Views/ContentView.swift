//
//  ContentView.swift
//  Boot
//
//  Created by Lefebvre, Louis on 10/31/25.
//

import SwiftUI
internal import UniformTypeIdentifiers

struct ContentView: View {
    @State private var objects: [Object] = []
    @State private var count = 0
    @State private var showFileImporter = false
    
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
                    showFileImporter = true
                }
                .buttonStyle(.borderedProminent)
                .font(.title2)
                .padding()
                .fileImporter(
                   isPresented: $showFileImporter,
                   allowedContentTypes: [.pdf],
                   allowsMultipleSelection: true
               ) { result in
                   switch result {
                   case .success(let files):
                       files.forEach { file in
                           // gain access to the directory
                           let gotAccess = file.startAccessingSecurityScopedResource()
                           if !gotAccess { return }
                           // access the directory URL
                           // (read templates in the directory, make a bookmark, etc.)
                           objects.append(Object(name: file.absoluteString))
                           // release access
                           file.stopAccessingSecurityScopedResource()
                       }
                   case .failure(let error):
                       // handle error
                       print(error)
                   }
               }
                
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

//
//  ContentView.swift
//  UITestingSampleApp
//
//  Created by José Echagüe on 8/14/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#if swift(>=5.9) // Xcode 15
#Preview {
	ContentView()
}
#else
struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
#endif // Xcode 15

//
//  ContentView.swift
//  LearningSwiftUI
//
//  Created by Gulsher Khan on 25/09/23.
//

import SwiftUI



struct HomePage: View {
  

    @ObservedObject private var locationViewModel = LocationViewModel()

    
    
    var body: some View {
        VStack {
                    Text("Latitude: \(locationViewModel.latitude ?? 0.0)")
                    Text("Longitude: \(locationViewModel.longitude ?? 0.0)")
            Text("Longitude: \(locationViewModel.num ?? 0)")
            Text("make build with xCloude")
            Button(action: {
                locationViewModel.startLocation()
            }){
                Text("Start tracking")
            }
            
            Button(action: {
                locationViewModel.stopLocation()
            }){
                Text("Stop tracking")
            }
            
                }
       
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HomePage()
        }
       
    }
}

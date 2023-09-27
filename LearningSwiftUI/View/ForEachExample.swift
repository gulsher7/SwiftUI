//
//  ForEachExample.swift
//  LearningSwiftUI
//
//  Created by Gulsher Khan on 27/09/23.
//

import SwiftUI

struct ForEachExample: View {
    let data: [Int] = [1,2,3,4,5,6,7,8]
    
    var body: some View {
        VStack {
            ForEach(data.indices) { index in
                Text("\(data[index])")
            }
        }
    }
}

struct ForEachExample_Previews: PreviewProvider {
    static var previews: some View {
        ForEachExample()
    }
}

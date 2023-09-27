import SwiftUI

enum AppColor: String {
    case ThemeColor
    
    var colors: Color {
        return Color(self.rawValue)
    }
}

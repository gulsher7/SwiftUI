//
//  SafeArea.swift
//  LearningSwiftUI
//
//  Created by Gulsher Khan on 27/09/23.
//

import SwiftUI
import CoreLocation

struct selectedCountry {
    var name: String
}

var locationManager: CLLocationManager?

var selectKeeper: String? = nil // << default, no selection




struct SheetView: View {
    @Environment(\.dismiss) var dismiss
    
    var someObjects =  NSLocale.isoCountryCodes

    var body: some View {
        
        List(
            someObjects,
            id: \.self
        ) { countryCode in

            HStack {
                Text(countryFlag(countryCode))
                Text(Locale.current.localizedString(forRegionCode: countryCode) ?? "").foregroundColor(Color.black)
                Text(countryCode).foregroundColor(Color.black)
            }.onTapGesture {
                print("pressed onTapGesture")
            }
        }
           
        Button("Press to dismiss") {
            dismiss()
        }
        .font(.title)
        .padding()
        .background(.black)
    }
}

struct SafeArea: View {
    
    @State private var text = ""
    @State private var password: String = ""
    @State private var isPasswordVisible = false
    @State private var showingSheet = false
    
    @ObservedObject private var locationViewModel = LocationViewModel()
      
 


    var body: some View {


            VStack(alignment: .leading) {
                Text("Welcome back!")
                    .padding(.top, 60)
                
                Text("Latitude: \(locationViewModel.latitude ?? 0.0)")
                           Text("Longitude: \(locationViewModel.longitude ?? 0.0)")
                
                Text("We are happy to see. You can login to continue.")
                    .foregroundColor(Color(hue: 0.061, saturation: 0.058, brightness: 0.567))
                
                HStack{
                    Button("\(countryFlag("IN"))") {
                                showingSheet.toggle()
                    }.modifier(CustomTextFieldStyle())
                            .sheet(isPresented: $showingSheet) {
                                SheetView()
                            }
                    TextField("Enter text", text: $text)
                                .modifier(CustomTextFieldStyle())
                }
                
                SecureField("Enter text", text: $password)
                    .modifier(CustomTextFieldStyle())
                
                HStack(){
                    Text("Use OTP")
                                .modifier(OtpStyle())
                    Text("Forgot password?")
                                .modifier(ForgetPasswordStyle())
                }
                
             
            

                Spacer()
                
                Button(action: {
                    print("pressed save button")
                  
                }){
                    Text("Save")
                }.modifier(ButtonStyle())

            }
            .modifier(Container())
        
    }
}

struct SafeArea_Previews: PreviewProvider {
    static var previews: some View {
        SafeArea()

    }
}

func countryFlag(_ countryCode: String) -> String {
  String(String.UnicodeScalarView(countryCode.unicodeScalars.compactMap {
    UnicodeScalar(127397 + $0.value)
  }))
}


struct ModalView: View {


    var body: some View {
        VStack {
            Text("This is a Modal View")
                .font(.title)

         
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}



func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == .authorizedAlways {
        print("New location is")
        // you're good to go!
    }
}

func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.last {
        print("New location is \(location)")
    }
}

struct Container: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 16)
            .background(Color(hue: 1.0, saturation: 0.055, brightness: 0.143))
            .edgesIgnoringSafeArea(.all)
            .foregroundColor(Color.white)
    }
}

struct CustomTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(10)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
            .foregroundColor(.white)
        
    }
}

struct ButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(AppColor.ThemeColor.colors)
            .cornerRadius(8)
            .padding(.bottom, 20)
           
    }
}

struct OtpStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color.white)
            .font(.system(size: 14))
            .frame(maxWidth: .infinity, alignment: .leading)

           
    }
}

struct ForgetPasswordStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color.white)
            .font(.system(size: 14))
            .frame(maxWidth: .infinity, alignment: .trailing)
        
    }
}

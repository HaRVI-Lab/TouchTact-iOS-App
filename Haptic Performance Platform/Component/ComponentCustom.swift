//
//  ComponentCustom.swift
//  Haptic Performance Platform
//
//  Created by iseungheon on 1/25/23.
//
// This file contains the custom components used in the app.

import Foundation
import SwiftUI
import WebKit

// WebView component as UIViewRepresentable to be used in SwiftUI
struct WebView: UIViewRepresentable {
    let url: URL?  // URL to be loaded in the web view
    let surveyCompleted: () -> Void  // callback function when survey is completed

    // Creates and returns an instance of WKWebView
    func makeUIView(context: Context) -> WKWebView  {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    // Updates the provided WKWebView instance with new data when a state or binding changes
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = url {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }

    // Coordinator for handling navigation events in the WKWebView
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Coordinator class for handling navigation
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        var timer: Timer?

        init(_ parent: WebView) {
            self.parent = parent
        }

        // This function is triggered when a web page navigation is completed
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Setting a timer to periodically evaluate the web page's content
            timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
                webView.evaluateJavaScript("document.body.innerHTML") { (result, error) in
                    if let html = result as? String {
                        // Check if the survey is completed
                        if html.contains("We thank you for your time spent taking this survey.") {
                            DispatchQueue.main.async {
                                self.parent.surveyCompleted() // Call the surveyCompleted() function on the parent WebView
                                self.timer?.invalidate()      // Stop the timer
                            }
                        }
                    }
                }
            }
        }
    }
}

// A SwiftUI View for displaying an icon image 
struct Icon: View {
    var image : Image       // Image object to be displayed as an icon
    
    var body: some View {
        ZStack {
            image
                .resizable()    // resizable cannot be set by modifier
                .scaledToFit()  
                .modifier(UIScreen.fitParent())
        }
    }
}

// A SwiftUI View for a scrollable list with a margin inbetween each child view
struct ScrollList<Content: View>: View {
    var margin: CGFloat     // Margin for the list
    var child: Content      // Child view(s) for the list
    
    // Init function with a ViewBuilder for child content
    init(margin: CGFloat, @ViewBuilder child: () -> Content) {
        self.margin = margin * UIScreen.height_ratio
        self.child = child()
    }
    
    var body: some View {
        ZStack {
            // Wrap child views within a ScrollView
            ScrollView {
                child
                    .padding(.bottom,margin)
            }
        }
    }
}

// A SwiftUI View for a checkbox
struct Checkbox: View {
    @Binding var isSelected: Bool   // Binding for the checkbox selection state
    var label: () -> Text           // Label for the checkbox
    
    var body: some View {
        Button(action: {
            self.isSelected.toggle()    // Toggle the selection state when the checkbox is tapped
        }) {
            HStack {
                Image(systemName: self.isSelected ? "checkmark.square" : "square")  // Display the checkbox image based on the selection state
                    .modifier(UIScreen.CheckBoxIconStyle())
                label()                                                             // Display the label text
                    .modifier(UIScreen.CheckBoxLableStyle())
            }
        }
    }
}

// A SwiftUI View for a num pad
struct NumPad: View {
    @ObservedObject var case_manager : CaseManager
    let order_array : [Int]
    let custom_text_array : [String]?
    
    init(case_manager: CaseManager) {
        self.case_manager = case_manager
        self.order_array = case_manager.order_array
        self.custom_text_array = case_manager.custom_text_array
    }
    
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ForEach(0 ..< 3, id: \.self) { row in
                    HStack(spacing: 0 ){
                        ForEach(0 ..< 3, id: \.self) {col in
                            Button(action: {
                                
                            }) {
                                Text(custom_text_array == nil ? "\(order_array[row * 3 + col])" : custom_text_array![row * 3 + col])
                                    .opacity((case_manager.interactionEnabled[row * 3 + col]) ? 1.0 : 0.5)
                                    .modifier(UIScreen.fitParent())
                                    .foregroundStyle(order_array[row * 3 + col] == case_manager.highlightOrder ? .blue : .black)
                            }
                            .modifier(UIScreen.NumPadButtonStyle{
                                case_manager.numPadButtonTap(value: order_array[row * 3 + col],button_index: row * 3 + col)
                            })
                            .padding(.trailing, col < 3 ? UIScreen.screen_gutter_width : 0)
                        }
                    }
                    .padding(.bottom, row < 3 ? UIScreen.screen_gutter_height : 0)
                }
            }
        }
        .modifier(UIScreen.NumPadTouchAreaStyle())
    }
}

// A SwiftUI View for a touch pad
struct TouchPad: View {
    @ObservedObject var case_manager : CaseManager
    let order_array : [Int]
    let custom_text_array: [String]?
    let location_array : [Position]
    let interaction_type : InteractionType
    
    init(case_manager: CaseManager) {
        self.case_manager = case_manager
        self.order_array = case_manager.order_array
        self.custom_text_array = case_manager.custom_text_array
        self.location_array = case_manager.location_array!
        self.interaction_type = case_manager.interaction_type
    }
    
    var body: some View {
        ZStack{
            ZStack {
            }
            .modifier(UIScreen.TouchPadLabelAreaStyle())
            ForEach(0 ..< 9, id: \.self) { index in
                Text(custom_text_array == nil ? "\(order_array[index])" : custom_text_array![index])
                    .opacity(case_manager.interactionEnabled[index] ? 1.0 : 0.5)
                    .modifier(UIScreen.TouchPadTextStyle(x_p: location_array[index].x, y_p: location_array[index].y))
                    .foregroundStyle(order_array[index] == case_manager.highlightOrder ? .blue : .black)
            }
        }.modifier(UIScreen.TouchPadInteraction(case_manager: case_manager))
    }
}

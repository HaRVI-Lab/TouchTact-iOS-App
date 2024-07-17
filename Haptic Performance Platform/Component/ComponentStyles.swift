//
//  ComponentStyles.swift
//  Haptic Performance Platform
//
//  Created by iseungheon on 1/25/23.
//
//  This file contains the colors and styles used in the app.
import Foundation
import SwiftUI

extension Color {
    public init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            var hexColor = String(hex[start...])
            
            if hexColor.count == 6 {
                hexColor.append("FF") // Append 'FF' for full opacity if alpha is not specified.
            }
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, opacity: a)
                    return
                }
            }
        }

        return nil
    }
    
    // Defining new colors
    static let darkGrey = Color(hex: "#ADADAE")!
    static let denseGrey = Color(hex: "#D3D3D3")!
    static let lightGrey = Color(hex: "#DFDFDF")!
    static let brightGrey = Color(hex: "#F2F2F2")!
    static let goldenOrange = Color(hex: "#FFCC00")!
    static let darkBlue = Color(hex: "#176D81")!
    static let lightBlue = Color(hex: "#E9F7F2")!
    static let brightBlue = Color(hex: "#F2F6F5")!
    static let darkRed = Color(hex: "#BD4A47")!
    static let denseBlue = Color(hex: "#3B8C90")!
    static let lightGreen = Color(hex: "#FAFFF6")!
    static let denseRed = Color(hex: "#DC5350")!
    static let lightYellow = Color(hex: "#FEFFF6")!
    // Creating ColorPalette
    static func ColorPalette(index: Int) -> Color {
        switch(index) {
        case 0:
            return Color.black
        case 1:
            return Color.darkGrey
        case 2:
            return Color.denseGrey
        case 3:
            return Color.lightGrey
        case 4:
            return Color.brightGrey
        case 5:
            return Color.white
        case 6:
            return Color.goldenOrange
        case 7:
            return Color.darkBlue
        case 8:
            return Color.lightBlue
        case 9:
            return Color.darkRed
        case 10:
            return Color.brightBlue
        case 11:
            return Color.denseBlue
        case 12:
            return Color.lightGreen
        case 13:
            return Color.denseRed
        case 14:
            return Color.lightYellow
        default:
            return Color.black
        }
    }
}


extension UIScreen {
    // Component Color Assignment using Color.ColorPalette
    struct ColorPalette {
        static let border           = Color.ColorPalette(index: 0)
        
        struct background {
            static let main_button      = Color.ColorPalette(index: 0)
            static let text_field       = Color.ColorPalette(index: 1)
            static let scroll_view      = Color.ColorPalette(index: 2)
            static let image_frame      = Color.ColorPalette(index: 2)
            static let screen           = Color.ColorPalette(index: 3)
            static let pad              = Color.ColorPalette(index: 4)
            static let checkbox         = Color.ColorPalette(index: 5)
            static let ranking          = Color.ColorPalette(index: 5)
            static let tap              = Color.ColorPalette(index: 7)
            static let swipe_through    = Color.ColorPalette(index: 9)
            static let resume           = Color.ColorPalette(index: 11)
            static let restart          = Color.ColorPalette(index: 13)
        }
        
        struct foreground {
            static let common           = Color.ColorPalette(index: 0)
            static let main_button      = Color.ColorPalette(index: 5)
            static let checkbox         = Color.ColorPalette(index: 5)
            static let ranking_symbol   = Color.ColorPalette(index: 6)
            static let tap              = Color.ColorPalette(index: 8)
            static let swipe_through    = Color.ColorPalette(index: 10)
            static let resume           = Color.ColorPalette(index: 10)
            static let restart          = Color.ColorPalette(index: 12)
        }
    }
    
    
    static let screen_width  = UIScreen.main.bounds.size.width
    static let screen_height = UIScreen.main.bounds.size.height

     
    static let width_ratio : CGFloat = screen_width  / 414
    static let height_ratio: CGFloat = screen_height / 896
    static let screen_gutter_width = 15 * width_ratio
    static let screen_gutter_height = 15 * height_ratio
    
    struct fitParent: ViewModifier {
        func body(content: Content) -> some View {
            GeometryReader { geometry in
                content
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            }
        }
    }

    struct titleStyle: ViewModifier { //resizeable need to be set seaperately
        var x : CGFloat
        var y : CGFloat
        
        let width  = 334 * width_ratio
        let height = 68 * height_ratio
        
        let frame_alignment : Alignment = .center
        let font_size = 30 * width_ratio
        var font_weight: Font.Weight = .regular
        
        let foreground = ColorPalette.foreground.common
        
        func body(content: Content) -> some View {
            content
                .frame(width: width, height: height, alignment: frame_alignment)
                .font(.system(size: font_size, weight: font_weight))
                .foregroundColor(foreground)
                .position(x:x*width_ratio+width/2,y:y*height_ratio+height/2)
                .ignoresSafeArea()
        }
    }
    
    
    struct iconStyle: ViewModifier {
        var x : CGFloat
        var y : CGFloat
        
        let width  = 218 * width_ratio
        let height = 234 * height_ratio
        
        let frame_alignment : Alignment = .center
        
        let foreground = ColorPalette.foreground.common
        
        func body(content: Content) -> some View {
            content
                .frame(width: width, height: height, alignment: frame_alignment)
                .foregroundColor(foreground)
                .position(x:x*width_ratio+width/2,y:y*height_ratio+height/2)
                .ignoresSafeArea()
        }
    }
    
    struct tutorialImageConstraint {
        static let width  = 334 * width_ratio
        static let height = 482 * height_ratio
    }
    
    struct tutorialImageFrameStyle: ViewModifier {
        var x : CGFloat
        var y : CGFloat
        
        let width  = tutorialImageConstraint.width
        let height = tutorialImageConstraint.height
        let corner_radius = 20 * width_ratio
        
        let frame_alignment : Alignment = .center
        let background = ColorPalette.background.image_frame
        
        
        func body(content: Content) -> some View {
            content
                .frame(width: width, height: height, alignment: frame_alignment)
                .background(background) // need to come after frame
                .cornerRadius(corner_radius)
//                .foregroundColor(foreground)
                .position(x:x*width_ratio+width/2,y:y*height_ratio+height/2)
                .ignoresSafeArea()
        }
    }
    
    struct tutorialImageStyle: ViewModifier {
        let width  = tutorialImageConstraint.width
        let height = tutorialImageConstraint.height
        let corner_radius = tutorialImageFrameStyle(x: 0, y: 0).corner_radius
        
        let border_color = ColorPalette.border
        let border = 5 * width_ratio
        
        func body(content: Content) -> some View {
            content
                .frame(width: width, height: height, alignment: .center)
                .cornerRadius(corner_radius)
                .overlay(RoundedRectangle(cornerRadius: corner_radius).strokeBorder(border_color, lineWidth: border))
        }
    }
    
    struct tutorialTextFrameConstraint {
        static let width  = 334 * width_ratio
        static let height = 150 * height_ratio
        static let vertical_padding = 10 * height_ratio
    }
    
    
    struct tutorialTextFrameStyle : ViewModifier { //resizeable need to be set seaperately
        var x : CGFloat
        var y : CGFloat
        
        let width  = tutorialTextFrameConstraint.width
        let height = tutorialTextFrameConstraint.height
        
        let frame_alignment : Alignment = .topLeading
        func body(content: Content) -> some View {
            content
                .frame(width: width, height: height, alignment: frame_alignment)
                .position(x:x*width_ratio+width/2,y:y*height_ratio+height/2)
                .ignoresSafeArea()
        }
    }
    
    struct tutorialTextStyle: ViewModifier {
        let width  = tutorialTextFrameConstraint.width
        let height = tutorialTextFrameConstraint.height / 3 - tutorialTextFrameConstraint.vertical_padding / 3 * 2
        let frame_alignment : Alignment = .leading
        
        let text_alignment : TextAlignment = .leading
        let font_size = 20 * width_ratio
        let font_weight: Font.Weight = .semibold
        
        let foreground = ColorPalette.foreground.common

        let vertical_padding = tutorialTextFrameConstraint.vertical_padding
        
        func body(content: Content) -> some View {
            content
                .frame(width: width, alignment: frame_alignment)
                .minimumScaleFactor(0.1)
                .multilineTextAlignment(text_alignment)
                .font(.system(size: font_size, weight: font_weight))
                .foregroundColor(foreground)
                .padding(.bottom,vertical_padding)
        }
        
    }
    
    
    struct CheckBoxConstraint {
        static let width  = 334 * width_ratio
        static let height = 150 * height_ratio
    }
    
    struct CheckBoxStyle: ViewModifier {
        let width  = CheckBoxConstraint.width
        let height = CheckBoxConstraint.height
        
        let frame_alignment : Alignment = .center
        let border = 5 * width_ratio
        let corner_radius = 20 * width_ratio
        
        let border_color = ColorPalette.border
        let background = ColorPalette.foreground.checkbox
        
        func body(content: Content) -> some View {
            content
                .frame(width: width, height: height, alignment: frame_alignment)
                .background(background) // need to come after frame
                .cornerRadius(corner_radius)
                .overlay(RoundedRectangle(cornerRadius: corner_radius).strokeBorder(border_color, lineWidth: border))
                
        }
    }
    struct CheckBoxIconStyle: ViewModifier {
        let width  = 55 * width_ratio
        let height = CheckBoxConstraint.height
        
        let frame_alignment : Alignment = .trailing
        let font_size = 30 * width_ratio
        let font_weight: Font.Weight = .regular
        
        let foreground = ColorPalette.foreground.common
        
        func body(content: Content) -> some View {
            content
                .frame(width: width, height: height, alignment: frame_alignment)
                .foregroundColor(foreground)
                .font(.system(size: font_size, weight: font_weight))
                .multilineTextAlignment(.center)
        }
    }
    struct CheckBoxLableStyle: ViewModifier {
        let width  = CheckBoxConstraint.width - CheckBoxIconStyle().width
        let height = CheckBoxConstraint.height
        
        let frame_alignment : Alignment = .leading
        let font_size = 24 * width_ratio
        let font_weight: Font.Weight = .regular
        let text_alignment : TextAlignment = .leading
        
        let foreground = ColorPalette.foreground.common
        
        func body(content: Content) -> some View {
            content
                .padding()
                .frame(width: width, height: height, alignment: frame_alignment)
                .multilineTextAlignment(text_alignment)
                .foregroundColor(foreground)
                .font(.system(size: font_size, weight: font_weight))
        }
    }
    
    
    struct textFieldStyle: TextFieldStyle { //fixed
        var x : CGFloat
        var y : CGFloat
        
        let width   = 334 * width_ratio
        let height  = 68  * height_ratio
        
        let frame_alignment : Alignment = .center
        let padding = 15  * width_ratio
        let radius =  20  * width_ratio
        
        
        let background = ColorPalette.background.text_field
        let foreground = ColorPalette.foreground.common
        
        func _body(configuration: TextField<Self._Label>) -> some View {
            configuration
                .padding(padding)
                .frame(width: width, height: height, alignment: frame_alignment)
                .background(background)
                .foregroundColor(foreground)
                .cornerRadius(radius)
                .position(x:x*width_ratio+width/2,y:y*height_ratio+height/2)
                .ignoresSafeArea()
        }
    }
    
    struct submitButtonSytle: ButtonStyle { //fixed
        var x : CGFloat
        var y : CGFloat
        
        let width  = 194 * width_ratio
        let height = 68  * height_ratio
        
        let frame_alignment : Alignment = .center
        let radius = 30  * width_ratio
        
        let background = ColorPalette.background.main_button
        let foreground = ColorPalette.foreground.main_button
        
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .frame(width: width, height: height, alignment: frame_alignment)
                .background(background)
                .foregroundColor(foreground)
                .cornerRadius(radius)
                .position(x:x*width_ratio+width/2,y:y*height_ratio+height/2)
                .ignoresSafeArea()
        }
    }
    
    struct scrollListStyle: ViewModifier {
        var x : CGFloat
        var y : CGFloat
        
        let width  = 334 * width_ratio
        let height = 647 * height_ratio
        
        let frame_alignment : Alignment = .center
        
        let background = ColorPalette.background.scroll_view
        
        func body(content: Content) -> some View {
            content
                .frame(width: width, height: height, alignment: frame_alignment)
                .background(background)
                .cornerRadius(CheckBoxStyle().corner_radius)
                .position(x:x*width_ratio+width/2,y:y*height_ratio+height/2)
                .ignoresSafeArea()
        }
    }
    
    
    struct GameLabelStyle: ViewModifier {
        var x : CGFloat
        var y : CGFloat
        
        let width  = 101 * width_ratio
        let height = 26 * height_ratio
        
        let frame_alignment : Alignment = .trailing
        let font_size = 23 * width_ratio
        var font_weight: Font.Weight = .semibold
        
        let foreground = ColorPalette.foreground.common
        
        func body(content: Content) -> some View {
            content
                .frame(width: width, height: height, alignment: frame_alignment)
                .font(.system(size: font_size, weight: font_weight, design: .monospaced))
                .foregroundColor(foreground)
                .position(x:x*width_ratio+width/2,y:y*height_ratio+height/2)
                .ignoresSafeArea()
        }
    }
    
    struct GameValueStyle: ViewModifier {
        var x : CGFloat
        var y : CGFloat
        
        let width  = 218 * width_ratio
        let height = 26 * height_ratio
        
        let frame_alignment : Alignment = .leading
        let font_size = 23 * width_ratio
        var font_weight: Font.Weight = .semibold
        
        let foreground = ColorPalette.foreground.common
        
        func body(content: Content) -> some View {
            content
                .frame(width: width, height: height, alignment: frame_alignment)
                .font(.system(size: font_size, weight: font_weight, design: .monospaced))
                .foregroundColor(foreground)
                .position(x:x*width_ratio+width/2,y:y*height_ratio+height/2)
                .ignoresSafeArea()
        }
    }
    
    struct InteractionTypeStyle: ViewModifier {
        var x : CGFloat
        var y : CGFloat
        var interaction: InteractionType
        
        let width  = 160 * width_ratio
        let height = 26 * height_ratio
        
        let frame_alignment : Alignment = .center
        var font_weight: Font.Weight = .bold
        let font_size = 19 * height_ratio
        
        let corner_radius = 5 * width_ratio
        
        let border_color = ColorPalette.border
        let border = 1 * width_ratio
        
        func body(content: Content) -> some View {
            content
                .frame(width: width, height: height, alignment: frame_alignment)
                .minimumScaleFactor(0.5)
                .font(.system(size: font_size, weight: font_weight, design: .monospaced))
                .foregroundColor(interaction == InteractionType.tap ? ColorPalette.foreground.tap : ColorPalette.foreground.swipe_through)
                .background(interaction == InteractionType.tap ? ColorPalette.background.tap : ColorPalette.background.swipe_through)
                .cornerRadius(corner_radius)
                .overlay(RoundedRectangle(cornerRadius: corner_radius).strokeBorder(border_color, lineWidth: border))
                .position(x:x*width_ratio+width/2,y:y*height_ratio+height/2)
                .ignoresSafeArea()
        }
    }
    
    struct GameModeStyle: ViewModifier {
        var x : CGFloat
        var y : CGFloat
        var gamemode: GameMode
        
        let width  = 160 * width_ratio
        let height = 26 * height_ratio
        
        let frame_alignment : Alignment = .center
        let font_weight: Font.Weight = .bold
        let font_size = 19 * height_ratio
        
        let corner_radius = 5 * width_ratio
        
        let border_color = ColorPalette.border
        let border = 1 * width_ratio
        
        func body(content: Content) -> some View {
            content
                .frame(width: width, height: height, alignment: frame_alignment)
                .minimumScaleFactor(0.5)
                .font(.system(size: font_size, weight: font_weight, design: .monospaced))
                .foregroundColor(gamemode == GameMode.resume ? ColorPalette.foreground.resume : ColorPalette.foreground.restart)
                .background(gamemode == GameMode.resume  ? ColorPalette.background.resume : ColorPalette.background.restart)
                .cornerRadius(corner_radius)
                .overlay(RoundedRectangle(cornerRadius: corner_radius).strokeBorder(border_color, lineWidth: border))
                .position(x:x*width_ratio+width/2,y:y*height_ratio+height/2)
                .ignoresSafeArea()
        }
    }
    
    struct RankingFrameStyle: ViewModifier {
        var x: CGFloat
        var y: CGFloat
        
        let width = 334 * width_ratio
        let height = 68 * height_ratio
        
        let corner_radius = 20 * width_ratio
        
        let frame_alignment : Alignment = .center
        let background = ColorPalette.background.ranking
        
        func body(content: Content) -> some View {
            content
                .frame(width: width, height: height, alignment: frame_alignment)
                .background(background)
                .cornerRadius(corner_radius)
                .position(x:x*width_ratio+width/2,y:y*height_ratio+height/2)
                .ignoresSafeArea()
        }
    }
    
    struct RankingTextConstraint {
        static let font_size = 16 * width_ratio
    }
    
    struct RankingSymbolStyle: ViewModifier {
        let foreground = ColorPalette.foreground.ranking_symbol
        let font_size = RankingTextConstraint.font_size
        let font_weight : Font.Weight = .regular
        
        func body(content: Content) -> some View {
            content
                .foregroundColor(foreground)
                .font(.system(size: font_size, weight: font_weight))
        }
    }
    struct RankingLabelStyle: ViewModifier {
        let foreground = ColorPalette.foreground.common
        let font_size = RankingTextConstraint.font_size
        let font_weight : Font.Weight = .bold
        
        func body(content: Content) -> some View {
            content
                .foregroundColor(foreground)
                .font(.system(size: font_size, weight: font_weight))
        }
    }
    
    struct PadConstraint {
        static let width  = 334 * width_ratio
        static let height = 523 * height_ratio
    }
    
    struct NumPadStyle: ViewModifier {
        var x : CGFloat
        var y : CGFloat
        
        let width  = PadConstraint.width
        let height = PadConstraint.height
        
        let frame_alignment : Alignment = .center
        
        func body(content: Content) -> some View {
            content
                .frame(width: width, height: height, alignment: frame_alignment)
                .position(x:x*width_ratio+width/2,y:y*height_ratio+height/2)
                .ignoresSafeArea()
        }
    }
    
    struct NumPadTouchAreaStyle: ViewModifier {
        let width = PadConstraint.width
        let height = PadConstraint.width
        
        let frame_alignment : Alignment = .center
        
        func body(content: Content) -> some View {
            content
                .frame(width: width, height: height, alignment: frame_alignment)
                .ignoresSafeArea()
        }
    }
    
    struct NumPadButtonStyle : ViewModifier {
        let width : CGFloat = (PadConstraint.width - screen_gutter_width*2) / 3
        let height : CGFloat = (PadConstraint.width - screen_gutter_height*2) / 3
        
        let frame_alignment : Alignment = .center
        let radius = 30  * width_ratio
        
        let font_size = 40 * width_ratio
        let font_weight: Font.Weight = .semibold
        
        let background = ColorPalette.background.pad
        let foreground = ColorPalette.foreground.common
        
        let action: () -> Void
        @State private var hasBeenPressed = false
        
        func body(content: Content) -> some View {
            content
                .frame(width: width, height: height, alignment: frame_alignment)
                .font(.system(size: font_size, weight: font_weight))
                .minimumScaleFactor(0.1)
                .background(background)
                .foregroundColor(foreground)
                .cornerRadius(radius)
                .ignoresSafeArea()
                .simultaneousGesture(DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !self.hasBeenPressed {
                            self.hasBeenPressed = true
                            self.action()
                        }
                    }
                    .onEnded { _ in
                        self.hasBeenPressed = false
                    })
        }
    }
    
    struct TouchPadStyle: ViewModifier {
        var x : CGFloat
        var y : CGFloat
        
        let width = PadConstraint.width
        let height = PadConstraint.height
        
        let background = ColorPalette.background.pad
        let foreground = ColorPalette.foreground.common
        
        static let radius = 16.7  * width_ratio
        
        func body(content: Content) -> some View {
            content
                .frame(width: width, height: height)
                .background(background)
                .foregroundColor(foreground)
                .cornerRadius(UIScreen.TouchPadStyle.radius)
                .position(x:x*width_ratio+width/2,y:y*height_ratio+height/2)
                .ignoresSafeArea()
        }
    }
    
    struct TouchPadButtonConstrain {
        static var width_percentage : Int = 15
        static var height_percentage : Int = 10
    }
    
    struct TouchPadInteraction : ViewModifier {

        let case_manager: CaseManager
        
        @State private var hasBeenPressed = false
        @State private var hasEnterNumber = false
        @State private var lastButtonIndex = -1
        
        func body(content: Content) -> some View {
            
            let tap = DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged { value in
                    if !self.hasBeenPressed {
                        self.hasBeenPressed = true
                        let xp : CGFloat = (value.location.x - TouchPadStyle.radius) / (PadConstraint.width - 2 * TouchPadStyle.radius) * 100
                        let yp : CGFloat = (value.location.y - TouchPadStyle.radius) / (PadConstraint.height - 2 * TouchPadStyle.radius) * 100
                        for (index, location) in case_manager.location_array!.enumerated() {
                            if (xp > CGFloat(location.x) && xp < CGFloat(location.x + TouchPadButtonConstrain.width_percentage) && yp > CGFloat(location.y) && yp < CGFloat(location.y + TouchPadButtonConstrain.height_percentage)) {
                                case_manager.numPadButtonTap(value: case_manager.order_array[index],button_index: index)
                            }
                        }
                    }
                }
                .onEnded { _ in
                    self.hasBeenPressed = false
                }
            
            let swipe_through = DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged { value in
                    if !self.hasBeenPressed {
                        case_manager.numPadButtonTap(value: 0,button_index: -1)
                        self.hasBeenPressed = true
                    }
                    if self.hasBeenPressed {
                        let xp : CGFloat = (value.location.x - TouchPadStyle.radius) / (PadConstraint.width - 2 * TouchPadStyle.radius) * 100
                        let yp : CGFloat = (value.location.y - TouchPadStyle.radius) / (PadConstraint.height - 2 * TouchPadStyle.radius) * 100
                        var inside = false
                        for (index, location) in case_manager.location_array!.enumerated() {
                            if (xp > CGFloat(location.x) && xp < CGFloat(location.x + TouchPadButtonConstrain.width_percentage) && yp > CGFloat(location.y) && yp < CGFloat(location.y + TouchPadButtonConstrain.height_percentage)) {
                                if !hasEnterNumber && case_manager.order_array[index] == case_manager.getCurrentValue() {
                                    case_manager.numPadButtonTap(value: case_manager.order_array[index],button_index: index)
                                    hasEnterNumber = true
                                    lastButtonIndex = index
                                }
                                inside = true
                            }
                        }
                        if !inside {
                            hasEnterNumber = false
                        }
                    }
                    
                }
                .onEnded { _ in
                    self.hasBeenPressed = false
                    self.hasEnterNumber = false
                    case_manager.numPadButtonTap(value: -1,button_index: lastButtonIndex)
                }
            
            
            content
                .modifier(fitParent())
                .ignoresSafeArea()
                .simultaneousGesture(case_manager.interaction_type==InteractionType.tap ? tap : swipe_through)
        }
    }
    
    struct TouchPadLabelAreaStyle : ViewModifier {
        static let width = PadConstraint.width - TouchPadStyle.radius * 2
        static let height = PadConstraint.height -  TouchPadStyle.radius * 2
        
        func body(content: Content) -> some View {
            content
                .frame(width: TouchPadLabelAreaStyle.width, height: TouchPadLabelAreaStyle.height)
                .position(x:TouchPadStyle.radius+TouchPadLabelAreaStyle.width/2,y:TouchPadStyle.radius+TouchPadLabelAreaStyle.height/2)
                .ignoresSafeArea()
                .allowsTightening(false)
        }
    }
    
    struct TouchPadTextStyle: ViewModifier {
        let x : CGFloat
        let y : CGFloat
        
        init(x_p: Int, y_p: Int) {
            self.x = CGFloat(x_p) / 100.0 * (PadConstraint.width - TouchPadStyle.radius * 2) + TouchPadStyle.radius
            self.y = CGFloat(y_p) / 100.0 * (PadConstraint.height - TouchPadStyle.radius * 2) + TouchPadStyle.radius
        }
        
        let font_size = 40 * width_ratio
        let font_weight: Font.Weight = .semibold
        
        let width = TouchPadLabelAreaStyle.width * CGFloat(TouchPadButtonConstrain.width_percentage) / 100.0
        let height = TouchPadLabelAreaStyle.height * CGFloat(TouchPadButtonConstrain.height_percentage) / 100.0
        
        func body(content: Content) -> some View {
            content
                .frame(width: width,height: height)
                .font(.system(size: font_size, weight: font_weight))
                .minimumScaleFactor(0.1)
                .position(x:x+width/2,y:y+height/2)
                .ignoresSafeArea()
                .allowsTightening(false)
        }
    }
}


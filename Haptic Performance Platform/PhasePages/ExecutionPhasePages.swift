//
//  ExecutionPhasePages.swift
//  Haptic Performance Platform
//
//  Created by iseungheon on 1/26/23.
//
// This file contains the views for the execution phase of the experiment.

import SwiftUI
import SafariServices

// This view is shown when the user needs to agree to the user agreements.
struct UserAgreementsPage: View {
    @ObservedObject var experiment_manager : ExperimentManager
    @State private var selectedAgreements: [Bool]
    @State private var requirement_alert: Bool = false
    init(experiment_manager: ExperimentManager) {
        self.experiment_manager = experiment_manager
        self.selectedAgreements = [Bool](repeating: false, count: experiment_manager.experiment_pack!.user_agreements.count)
    }
    
    var body: some View {
        ZStack {
            ScrollList(margin:15) {
                ForEach(0 ..< self.experiment_manager.experiment_pack!.user_agreements.count, id: \.self) { index in
                    Checkbox(isSelected: self.$selectedAgreements[index]) {
                        Text(self.experiment_manager.experiment_pack!.user_agreements[index])
                    }
                    .modifier(UIScreen.CheckBoxStyle())
                }
            }.modifier(UIScreen.scrollListStyle(x: 40, y: 82))
            Button(action: {
                if !self.selectedAgreements.contains(false) {
                    // all agreements are selected, allow submission
                    self.experiment_manager.prepareNextCaseSync()
                } else {
                    // not all agreements are selected, show error message
                    self.requirement_alert.toggle()
                }
            }) {
                Text("Submit")
            }.buttonStyle(UIScreen.submitButtonSytle(x: 110, y: 745))
        }
        .modifier(UIScreen.fitParent())
        .alert("All checkbox need to selected before participation", isPresented: $requirement_alert) {
            Button("OK", role: .cancel) {}
        }
    }
}


// This view for displaying the instructions for the current case.
struct TutorialPage: View {
    @ObservedObject var experiment_manager : ExperimentManager
    var body: some View  {
        ZStack {
            ZStack{
                Icon(image: Image(uiImage: experiment_manager.getPreparedImage())).modifier(UIScreen.tutorialImageStyle())
//                Icon(image: Image(uiImage: UIImage(named: experiment_manager.getCaseManager().location_array==nil ? "layout0" : "layout1")!)).modifier(UIScreen.tutorialImageStyle())
            }.modifier(UIScreen.tutorialImageFrameStyle(x: 40, y: 83))
            VStack(spacing:0) { // Adjust this to control the spacing between newline characters
                ForEach(experiment_manager.getTutorialText().components(separatedBy: "\n"), id: \.self) { line in
                    Text(line).modifier(UIScreen.tutorialTextStyle())
                }
            }.modifier(UIScreen.tutorialTextFrameStyle(x: 40, y: 580))
            Button(action: {
                experiment_manager.startGame()
            }) {
                Text("Confirm")
            }.buttonStyle(UIScreen.submitButtonSytle(x: 110, y: 745))
        }
        .modifier(UIScreen.fitParent())
    }
}

// This view is where the user interacts with the game.
struct GamePage: View {
    @ObservedObject var experiment_manager : ExperimentManager
    private var case_manager: CaseManager
    private let location_array: [Position]?
    private let timer : CasePack.TimerSettings?
    private let score_board : CasePack.ScoreBoardSettings?
    
    private let clock = Timer.publish(every: 0.023, on: .main, in: .common).autoconnect()
    
    init(experiment_manager: ExperimentManager) {
        self.experiment_manager = experiment_manager
        self.case_manager = experiment_manager.getCaseManager()
        self.location_array = case_manager.location_array
        self.timer = case_manager.timer_settings
        self.score_board = case_manager.score_board_settings
    }
    
    @State var count: Int = 0
    @State var duration = 0.0
    var body: some View {
        ZStack {
            Text(case_manager.interaction_type==InteractionType.tap ? "Tap" : "Swipe Through").modifier(UIScreen.InteractionTypeStyle(x:40,y:83,interaction: case_manager.interaction_type))
            Text(case_manager.game_mode==GameMode.resume ? "Continue" : "Restart").modifier(UIScreen.GameModeStyle(x:215,y:83,gamemode: case_manager.game_mode))
            
            if timer != nil {
                Text("Time:").modifier(UIScreen.GameLabelStyle(x: 40, y: 124))
                Text("\(experiment_manager.case_timer_display)").modifier(UIScreen.GameValueStyle(x: 156, y: 124))
            }
            if score_board != nil {
                Text("Score:").modifier(UIScreen.GameLabelStyle(x: 40, y: 165))
                Text("\(experiment_manager.case_score_display)").modifier(UIScreen.GameValueStyle(x: 156, y: 165))
            }
            if timer?.fake_ranking != nil || score_board?.fake_ranking != nil {
                VStack(spacing: 0 * UIScreen.width_ratio){
                    Text("\(Image(systemName: "crown"))").modifier(UIScreen.RankingSymbolStyle())
                    if timer?.fake_ranking != nil  {
                        Text("Time: \(case_manager.timer_ranking)").modifier(UIScreen.RankingLabelStyle())
                    }
                    if score_board?.fake_ranking != nil {
                        Text("Score: \(case_manager.score_ranking)").modifier(UIScreen.RankingLabelStyle())
                    }
                }.modifier(UIScreen.RankingFrameStyle(x: 40, y: 206))
            }
            
            if location_array == nil {
                NumPad(case_manager: case_manager).modifier(UIScreen.NumPadStyle(x: 40, y: 290))
            }
            else {
                TouchPad(case_manager: case_manager).modifier(UIScreen.TouchPadStyle(x: 40, y: 290))
            }
        }
        .modifier(UIScreen.fitParent())
        .onReceive(clock) { _ in
            case_manager.update()
        }
        .alert(case_manager.game_over_text, isPresented: $experiment_manager.game_finished) {
            Button("OK", role: .cancel) {
                experiment_manager.endGame()
            }
        }
    }
}

// This view is where the survey is displayed.
struct SurveyPage: View {
    @ObservedObject var experiment_manager : ExperimentManager
    
    var body: some View {
        ZStack {
            WebView(url: experiment_manager.getSurveyURL(), surveyCompleted:  experiment_manager.prepareNextCaseSync)
        }
    }
}

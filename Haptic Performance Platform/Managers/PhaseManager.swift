//
//  PhaseManager.swift
//  Haptic Performance Platform
//
//  Created by iseungheon on 1/17/23.
//

import SwiftUI


/**
* Purpose: This struct manages the initialization of the experiment.
*
* Properties:
* - experiment_manager: The manager of the whole experiment             (ExperimentManager)
*
* Pages:
* - LoadingPage: This page inform user that the initialization is in progress.
* - LoginPage: This page collects user and experiment information required for the experiment initialization.
*
* Transition Destination (triggered by experiment_manager):
* - ExecutionPhase: This struct manages the core execution of the experiment.
*
*/
struct EntrancePhase: View {
    @ObservedObject var experiment_manager : ExperimentManager = ExperimentManager()
    var body: some View {
        NavigationView {
            ZStack {
                UIScreen.ColorPalette.background.screen.ignoresSafeArea()
                if experiment_manager.is_loading {
                    LoadingPage()
                } else {
                    LoginPage(experiment_manager: experiment_manager)
                }
            }
        }
        .fullScreenCover(isPresented: $experiment_manager.experiment_loaded) {
            ExecutionPhase(experiment_manager: experiment_manager)
        }
    }
}

/**
* Purpose: This struct manages the core execution of the experiment.
*
* Properties:
* - experiment_manager: The manager of the whole experiment             (ExperimentManager)
*
* Pages:
* - UserAgreementPage: This page explains the rights and data collection, and make sure the user is accepting the consent.
* - TutorialPage: This page explains the essential rules of the game to the user.
* - GamePage: This page provide interaction screen with the real time game data display.
*
* Transition Destination (triggered by experiment_manager):
* - EnterancePhase: This struct manages the initialization of the experiment.
*
*/
struct ExecutionPhase: View {
    @ObservedObject var experiment_manager : ExperimentManager
    var body: some View {
        ZStack {
            UIScreen.ColorPalette.background.screen.ignoresSafeArea()
            if experiment_manager.survey_ready {
                SurveyPage(experiment_manager: experiment_manager)
            }
            else if experiment_manager.tutorial_ready {
                TutorialPage(experiment_manager: experiment_manager)
            }
            else if experiment_manager.game_ready {
                GamePage(experiment_manager: experiment_manager)
            }
            else {
                UserAgreementsPage(experiment_manager: experiment_manager)
            }
        } // ZStack End
        .onDisappear {
            self.experiment_manager.resetExperiment()
        }
    }
}

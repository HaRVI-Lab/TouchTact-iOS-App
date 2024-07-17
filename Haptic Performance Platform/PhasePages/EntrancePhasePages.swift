//
//  EntrancePhasePages.swift
//  Haptic Performance Platform
//
//  Created by iseungheon on 1/26/23.
//
//  This file contains the views for the entrance phase of the experiment.

import SwiftUI



//  This view is shown while the app is loading.
struct LoadingPage: View {
    var body: some View {
        ZStack {
            Icon(image: Image(systemName: "arrow.triangle.2.circlepath"))
                .modifier(UIScreen.iconStyle(x: 110, y: 331))
        } // VStack End
        .modifier(UIScreen.fitParent())
    }
}

// This view is shown when the user needs to enter their experiment and participant IDs.
struct LoginPage: View {
    @ObservedObject var experiment_manager : ExperimentManager
    @State private var navigate = false
    @State private var requirement_alert = false
    @State private var showServerURLEditor = false
    @State private var serverURL: String = ""
    
    var body: some View {
        ZStack {
            Icon(image: Image("HaRVI_Circle")).modifier(UIScreen.iconStyle(x: 110, y: 82))
            
            Text("Performance Platform").modifier(UIScreen.titleStyle(x: 41, y: 331, font_weight: .bold))
            TextField("Experiment ID", text: $experiment_manager.experiment_id)
                .textFieldStyle(UIScreen.textFieldStyle(x: 41, y: 497))
            TextField("Participant ID", text: $experiment_manager.participant_id)
                .textFieldStyle(UIScreen.textFieldStyle(x: 41, y: 580))
            Button("Submit", action: {
                if experiment_manager.participant_id.isEmpty {
                    requirement_alert = true
                    return
                }
                experiment_manager.requestExperimentSync()
            })
            .buttonStyle(UIScreen.submitButtonSytle(x: 110, y: 745))
            
            Button(action: {
                serverURL = experiment_manager.server_url
                showServerURLEditor = true
            }) {
                Image(systemName: "gear")
                    .foregroundColor(.blue)
                    .font(.system(size: 24))
            }
            .position(x: UIScreen.main.bounds.width - 40, y: 40)
            
        } // VStack End
        .modifier(UIScreen.fitParent())
        .alert("\(experiment_manager.warning_message)", isPresented: $experiment_manager.has_warning) {
            Button("OK", role: .cancel) {}
        }
        .alert("Participant ID cannot be empty", isPresented: $requirement_alert) {
            Button("OK", role: .cancel) {}
        }
        .alert("Edit Server URL", isPresented: $showServerURLEditor, actions: {
            TextField("Server URL", text: $serverURL)
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                experiment_manager.server_url = serverURL
            }
        }, message: {
            Text("Enter the new server URL below:")
        })
    }
}

//
//  ExperimentManager.swift
//  Haptic Performance Platform
//
//  Created by iseungheon on 1/17/23.
//

import Foundation
import UIKit
import CoreHaptics

/**
* Purpose: This class manages an experiment.
*
* Properties:
* - experiment_id: The id of the experiment                                             (String)
* - participant_id:  The id of the experiment participant                               (String)
* - is_loading: If main thread is blocked by the class                                  (Bool)
* - has_warning: If experiment has warning to display at the reset                      (Bool)
* - warning_message: Warning message to display at the reset                            (String)
* - experiment_loaded: If experiment is loaded                                          (Bool)
* - experiment_pack: Parased experiment data                                            (Bool)
* - tutorial_ready: If tutorial is ready                                                (Bool)
* - game_ready: If game is ready                                                        (Bool)
* - game_finished: If case is terminated and alert should be displayed                  (Bool)

* Methods:
* - resetExperiment(): This method resets the experiment progress.
* - requestExperimentSync(): This method request experiment data from the server.
* - prepareNextCaseSync(): This method wait and validates data required for the current case.
* - getPreparedCase(): This method provide current case data
* - getPreparedImage(): This method provide current intrustion image.
* - getTutorialText(): This method provide current instruction text.
* - startGame(): This method trigger transition between TutorialPage and GamePage, and initiates the case manager.
* - endGame(): This function terminates game process, stores result, and request for preparenextCaseSync().
*
* Initialization:
* - ExperimentManager(): Initializes a new manager for the experiment progress.
*
* Example:
* let experiment_manager = ExperimentManager()
*
* Notes: None.
*/

class ExperimentManager : ObservableObject {
    @Published var server_url: String {
        didSet {
            UserDefaults.standard.set(server_url, forKey: "serverURL")
        }
    }
    private let decoder = JSONDecoder()                 // general json decoder for parsing
    
    // Binding Variables:
    // Login Screen Textfield Input
    @Published var experiment_id     : String = ""         // LoginPage Experiment ID TextField State Binding
    @Published var participant_id    : String = ""     // LoginPage Participant ID TextField State Binding
    
    // Entrance Phase Management
    @Published var is_loading        : Bool = false             // LoadingPage/LoginPage toggle State
    @Published var has_warning       : Bool = false             // LoginPage Alert State Binding
    
    // Entrance to Execution Phase Change Trigger
    @Published var experiment_loaded : Bool = false             // Experiment Loaded Status Binding
    
    private var experiment_finished = false
    
    // Execution Phase Management
    @Published var survey_ready      : Bool = false             // Survey Ready Status Binding
    @Published var tutorial_ready    : Bool = false             // Tutorial Ready Status Binding
    @Published var game_ready        : Bool = false             // Game Ready Status Binding

    // Case Management
    @Published var game_finished      : Bool   = false             // GamePage Alert State Binding
    @Published var case_timer_display : String = ""
    @Published var case_score_display : String = ""
    
    // Get Only Variables:
    private (set) var warning_message   : String = ""           // LoginPage Alert Message
    private (set) var experiment_pack: ExperimentPack? = nil    // Experiment Data from JSON
    
    // Private Variables:
    private var experiment_group = DispatchGroup()              // Mutex Lock for Experiment Request Call
    
    private var case_index = 0                                  // Current Case Index
    
    private var image_tasks = [ImageKey: URLSessionDataTask]()  // Asynchronous Tasks for Parsing Image Data
    private var image_packs = [ImageKey: UIImage]()             // Parse UIImage from String in ExperimentPack
    private var image_groups = [ImageKey: DispatchGroup]()      // Mutex Locks for Each UIImage Parsing
    
    private var case_tasks = [Int: URLSessionDataTask]()        // Asynchronous Tasks for Parsing Case Data
    private var case_packs = [Int: CasePack]()                  // Cases Data from JSONs
    private var case_groups = [Int: DispatchGroup]()            // Mutex Locks for Each Case Request Call
    private var case_records = [(time_record:[Double], value_record: [Int])]()
    
    private var case_manager : CaseManager? = nil
    
    private var hapticEngine: CHHapticEngine?
    private let initialIntensity: Float = 1.0
    private let initialSharpness: Float = 0.5
    private var continuousPlayer: CHHapticAdvancedPatternPlayer!
    
    init() { 
        // Retrieve the saved server URL or use the default if not found
        self.server_url = UserDefaults.standard.string(forKey: "serverURL") ?? "https://harvi-lab.github.io/TouchTact-Experiment-Generation-GUI"

        // Clear all URL Cache
        URLCache.shared.removeAllCachedResponses()
        
        // initialize audio & haptic engine if hardware requirement is satisfied
        if CHHapticEngine.capabilitiesForHardware().supportsHaptics {
            hapticEngine = try? CHHapticEngine()
            hapticEngine?.playsHapticsOnly = true
            
            // The stopped handler alerts you of engine stoppage.
            hapticEngine?.stoppedHandler = { reason in
                print("Stop Handler: The engine stopped for reason: \(reason.rawValue)")
                switch reason {
                case .audioSessionInterrupt:
                    print("Audio session interrupt")
                case .applicationSuspended:
                    print("Application suspended")
                case .idleTimeout:
                    print("Idle timeout")
                case .systemError:
                    print("System error")
                case .notifyWhenFinished:
                    print("Playback finished")
                case .gameControllerDisconnect:
                    print("Controller disconnected.")
                case .engineDestroyed:
                    print("Engine destroyed.")
                @unknown default:
                    print("Unknown error")
                }
            }
            
            // The reset handler provides an opportunity to restart the engine.
            hapticEngine?.resetHandler = {
                
                print("Reset Handler: Restarting the engine.")
                
                do {
                    // Try restarting the engine.
                    try self.hapticEngine?.start()
                    
                    // Recreate the continuous player.
                } catch {
                    print("Failed to start the engine")
                }
            }
            
            // Start the haptic engine for the first time.
            do {
                try self.hapticEngine?.start()
            } catch {
                print("Failed to start the engine: \(error)")
            }
        } else {
            hapticEngine = nil
        }
        
        addObservers()
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil)
        { _ in
            
            // Stop the haptic engine.
            self.hapticEngine?.stop()
        }
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil)
        { _ in
            
            // Restart the haptic engine.
            do {
                try self.hapticEngine?.start()
            } catch let error {
                print(error)
            }
            
        }
    }
    
    /**
     * Purpose: This function resets experiment dependent variables.
     *
     * Parameters: None
     *
     * Return: None
     *
     * Example: resetExperiment() return Void
     *
     * Notes: None.
     */
    func resetExperiment() -> Void {
        experiment_id = ""
        //        participant_id = ""
        
        for (_, task) in image_tasks {
            task.cancel()
        }
        for (_, task) in case_tasks {
            task.cancel()
        }
        
        case_manager = nil
        
        experiment_loaded = false               // Experiment Loaded Status
        experiment_finished = false
        survey_ready = false
        tutorial_ready = false                  // Tutorial Ready Status
        game_ready = false                      // Game Ready Status
        game_finished = false
        
        experiment_pack = nil                   // Experiment Data from JSON
        experiment_group = DispatchGroup()      // Mutex Lock for Experiment Request Call
        
        image_tasks = [ImageKey: URLSessionDataTask]()
        image_packs = [ImageKey: UIImage]()          // Parse UIImage from String in ExperimentPack
        image_groups = [ImageKey: DispatchGroup]()   // Mutex Locks for Each UIImage Parsing
        
        case_tasks = [Int: URLSessionDataTask]()
        case_packs = [Int: CasePack]()          // Cases Data from JSONs
        case_groups = [Int: DispatchGroup]()    // Mutex Locks for Each Case Request Call
        
        case_index = 0
        
        print("Experiment Resetting\n\tProvided Warning Message: \(warning_message)")
        has_warning = !warning_message.isEmpty
        is_loading = false                         // LoadingPage/LoginPage toggle State
        
    }
    
    
    /**
     * Purpose:
     *   This function use pre-defined server_url and experiment_id from LoginPage/Experiment_ID_TextInput to request JSON file from the server.
     *   Parse that JSON file into pre-defined swift struct ExperimentPack
     *
     * Parameters: None
     *
     * Return: None
     *
     * Example: requestExperiment() return Void
     *
     * Notes:
     *   This will switch LoginPage to LoadingPage by toggling loading, block the main thread until request and parsing is done, and markdown the success status.
     *   This will also trigger request and parsing calls for each cases asynchonously, does not wait for it to finish.
     */
    func requestExperimentSync() { // return success status
        self.is_loading = true
//        let experiment_url = server_url + "/Experiments/" + experiment_id + ".json"
        let experiment_url = server_url + "/Files/Experiment/" + experiment_id + ".json"
        // Retriving and parsing experiment JSON data from the server
        self.experiment_group.enter()
        URLSession.shared.dataTask(with: URL(string: experiment_url)!) { (data, response, error) in
            if let data = data {
                self.experiment_pack = try? self.decoder.decode(ExperimentPack.self, from: data)
            } else {
                print("No response back from server")
            }
            self.experiment_group.leave()
        }.resume()
        
        // Waiting until experiment data parsing is completed
        experiment_group.notify(queue: .main) {
            // Data retrival or parsing failed
            self.experiment_loaded = self.experiment_pack != nil // turn on navigation from LoginPage when experiment_pack is successfully parsed
            
            if self.experiment_loaded {
                self.requestImagesAsync()
                self.requestCasesAsync()        // request and parsing calls for each cases asynchonously
                self.is_loading = false
            } else {
                DispatchQueue.main.async {
                    self.is_loading = false
                    self.warning_message = "Experiment \(self.experiment_id) Cannot be Loaded"
                    self.experiment_id = ""
                    self.has_warning = true
                }
            }
            
        }
    }
    
    /**
     * Purpose:
     *   This function use the loaded experiment data to request JSON file from the server.
     *   Parse that JSON file into pre-defined swift struct ImagePack
     *
     * Parameters: None
     *
     * Return: None
     *
     * Example: requestImagesAsync() return Void
     *
     * Notes:
     *   This function needs to be called only after experiment is loaded due to the dependency
     *   This function will be executed in seaperated thread and only join the main thread at the completion or error
     *   This function will cancel the experiment when parsing cannot be completed
     */
    private func requestImagesAsync() {
        self.experiment_pack!.tutorial_image_urls.forEach { (key: ImageKey, image_url: URL) in
            let group = DispatchGroup()
            group.enter()
            let task = URLSession.shared.dataTask(with: image_url) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
//                    print(key,image)
                    DispatchQueue.main.async {
                        self.image_packs[key] = image
                    }
                } else {
                    DispatchQueue.main.async {
                        self.warning_message = "Instruction Image For\n(location \(key.location_array_available ? "" : "not") available, \(key.interaction_type))\nCannot be Loaded"
                        self.experiment_loaded = false
                    }
                }
                group.leave()
            }
            self.image_tasks[key] = task
            self.image_groups[key] = group
            task.resume()
        }
    }
    
    /**
     * Purpose:
     *   This function use the loaded experiment data to request JSON file from the server.
     *   Parse that JSON file into pre-defined swift struct CasePack
     *
     * Parameters: None
     *
     * Return: None
     *
     * Example: requestCasesAsync() return Void
     *
     * Notes:
     *   This needs to be called only after experiment is loaded due to the dependency
     *   This function will be executed in seaperated thread and only join the main thread at the completion or error
     *   This will cancel the experiment when parsing cannot be completed
     */
    private func requestCasesAsync() {
        // Initializing variables for asynchronous case data parsing
        self.case_packs = [Int: CasePack]()
        self.case_groups = [Int: DispatchGroup]()
        
        // For each case retrive and parse JSON data asynchronously
        for (index, case_id) in self.experiment_pack!.case_id_array.enumerated() {
            let group = DispatchGroup()
            group.enter()
            let case_url = self.server_url + "/Files/Case/" + case_id + ".json"
            let task = URLSession.shared.dataTask(with: URL(string: case_url)!) { (data, response, error) in
                if let data = data {
                    let case_pack = try? self.decoder.decode(CasePack.self, from: data)
                    print("case_pack \(case_id) loaded: \(case_pack.debugDescription)")
                    if case_pack != nil {
                        DispatchQueue.main.async {
                            self.case_packs[index] = case_pack
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.warning_message = "Parsing for case \(case_id) failed"
                            self.experiment_loaded = false
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.warning_message =  "Request for case \(case_id) failed"
                        self.experiment_loaded = false
                        
                    }
                }
                group.leave()
            }
            self.case_tasks[index] = task
            self.case_groups[index] = group
            task.resume()
        }
    }
    
    /**
     * Purpose:
     *  This function validates the data before starting the instruction.
     *
     * Parameters: None
     *
     * Return: None
     *
     * Example: prepareNextCaseSync() return Void
     *
     * Notes:
     *   This needs to be called only after requestExperimentSync() is executed due to the dependency.
     *   This function will block the main thread until the asynchronous parsing is completed for the required data.
     *   This will cancel the experiment when required data is not valid.
     */
    func prepareNextCaseSync(){
        survey_ready = false
//        print("AAAAAAAAAAAAAAAAAAA")
        if (self.case_index >= self.experiment_pack!.case_id_array.count) {
//            print("BBBBBBBBBBBBBBBB:\(experiment_finished)")
            if experiment_finished || experiment_pack?.survey_url == nil {
                experiment_loaded = false
            }
            experiment_finished = true
            survey_ready = true
            return
        }
        let case_id = self.experiment_pack!.case_id_array[self.case_index]
        if let case_group = case_groups[case_index] {
            case_group.notify(queue: .main) {
                if let case_pack = self.case_packs[self.case_index] {
                    self.case_manager = CaseManager(case_pack: case_pack, haptic_engine: self.hapticEngine, score_display: self._case_score_display, timer_display: self._case_timer_display, game_finished: self._game_finished)
                    let image_key = self.case_manager!.getImageKey()
                    if let image_group = self.image_groups[image_key] {
                        image_group.notify(queue: .main) {
                            self.tutorial_ready = true
                        }
                    } else {
                        self.warning_message = "Impossible combination of image key (location \(image_key.location_array_available ? "" : "not") available, \(image_key.interaction_type)) is provided by case \(case_id)"
                        self.experiment_loaded = false
                    }
                } else {
                    self.warning_message = "Case pack not found for \(case_id)"
                    self.experiment_loaded = false
                }
            }
        } else {
            self.warning_message = "Case group not found for \(case_id)!"
            self.experiment_loaded = false
        }
    }
    
    /**
     * Purpose:
     *  This function provide access to the current case manager
     *
     * Parameters: None
     *
     * Return: None
     *
     * Example: getCaseManager() return CaseManager
     *
     * Notes:
     *   This needs to be called only after prepareNextCaseSync() is executed due to the dependency.
     *   This function will block the main thread until the asynchronous parsing is completed for the required data.
     *   This will cancel the experiment when required data is not valid.
     */
    func getCaseManager() -> CaseManager {
        return case_manager!
    }
    
    /**
     * Purpose:
     *  This function provide access to the current instruction image data
     *
     * Parameters: None
     *
     * Return: None
     *
     * Example: getPreparedImage() return Void
     *
     * Notes:
     *   This needs to be called only after prepareNextCaseSync() is executed due to the dependency.
     *   This function will block the main thread until the asynchronous parsing is completed for the required data.
     *   This will cancel the experiment when required data is not valid.
     */
    func getPreparedImage() -> UIImage {
        let image_key = case_manager!.getImageKey()
        return image_packs[image_key]!
    }
    
    /**
     * Purpose:
     *  This function generates bullet points of tutorial instruction for current case requirement
     *
     * Parameters: None
     *
     * Return: None
     *
     * Example: getTutorialText() return String
     *
     * Notes:
     *   This needs to be called only after prepareNextCaseSync() is executed due to the dependency.
     */
    func getTutorialText() -> String {
        return "• \(case_manager!.tutorial_text.interaction_type)\n• \(case_manager!.tutorial_text.game_mode)\n• \(case_manager!.tutorial_text.penalty)"
    }
    
    /**
     * Purpose:
     *  This function triggers the transition between tutorialPage to gamePage,
     *  and initiate the manager for the game.
     *
     * Parameters: None
     *
     * Return: None
     *
     * Example: startGame() return Void
     *
     * Notes:
     *   This needs to be called only after prepareNextCaseSync() is executed due to the dependency.
     */
    func startGame() {
        game_ready = true                               // push gameScreen to Navigation Stack
        tutorial_ready = false                          // pop tutorialScreen from Navigation Stack
        case_manager?.start()                           // initialize game process
    }
    
    /**
     * Purpose:
     *  This function terminates game process, stores result,
     *  and request for preparenextCaseSync().
     *
     * Parameters: None
     *
     * Return: None
     *
     * Example: endGame() return Void
     *
     * Notes:
     *   This needs to be called only after case_manager.start() is executed due to the dependency.
     */
    func endGame() {
        case_records.append(case_manager!.getFinalRecord()) // store last executed case record
        game_ready = false                                  // terminates game screen
        survey_ready = case_manager!.getSurveyURL() != nil  // load survey screen if needed
        case_index += 1;                                    // increment current case index
        if !survey_ready {
            prepareNextCaseSync()                               // request next case
        }
    }
    
    func getSurveyURL() -> URL? {
        if experiment_finished {
            return experiment_pack?.survey_url?.appending(queryItems: [URLQueryItem(name: "participant_id", value: participant_id), URLQueryItem(name:"experiment_id",value:"\(experiment_id)"), URLQueryItem(name:"records",value:"\(case_records)"),URLQueryItem(name: "case_ids", value: "\(experiment_pack!.case_id_array)")])
        } else {
            return case_manager?.getSurveyURL()?.appending(queryItems: [URLQueryItem(name:"participant_id",value: participant_id), URLQueryItem(name:"record",value:"\(case_manager!.getFinalRecord())"),URLQueryItem(name:"game_mode",value:"\(case_manager!.game_mode)"),
                                                                        URLQueryItem(name:"case_id",value:"\(experiment_pack!.case_id_array[case_index-1])")])
        }
    }
}

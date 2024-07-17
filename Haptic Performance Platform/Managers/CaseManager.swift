//
//  CaseManager.swift
//  Haptic Performance Platform
//
//  Created by iseungheon on 2/23/23.
//

import Foundation
import AVFoundation
import CoreHaptics
import SwiftUI

enum CaseManagerError: Error {
    case initError(String)
}

/**
* Purpose: This class manages an case (game).
*
* Properties:
* - case_pack: The data retrived from the server to construct gaming screen                                 (String)
* - haptic_engine: The haptic engine used for tactile feedback in the game                                  (CHHapticEngine?)
* - correct_haptic_player: The player used to play the haptic feedback when a correct action is performed   (CHHapticPatternPlayer?)
* - wrong_haptic_player: The player used to play the haptic feedback when a wrong action is performed       (CHHapticPatternPlayer?)
* - correct_audio_id: The system sound id for correct audio feedback                                        (SystemSoundID?)
* - wrong_audio_id: The system sound id for wrong audio feedback                                            (SystemSoundID?)
* - current_value: The current value or state in the game                                                   (Int)
* - max_reached_value: The maximum value or state reached in the game                                       (Int)
* - score: The current score in the game                                                                    (Double)
* - start_time: The time when the game started                                                              (Date)
* - time_record: A record of times at which actions were taken during the game                              ([Double])
* - value_record: A record of values corresponding to actions taken during the game                         ([Int])
* - score_display: The score to be displayed on the UI, published to the SwiftUI view                       (@Published String)
* - timer_display: The timer to be displayed on the UI, published to the SwiftUI view                       (@Published String)
* - game_finished: A flag to indicate if the game has finished, published to the SwiftUI view               (@Published Bool)
* - ghostID: The system sound ID for a silent sound that's used to keep the audio engine active             (SystemSoundID)
*
* Getters:
* - timer_settings : (CasePack.TimerSettings?)
* - score_board_settings : (CasePack.ScoreBoardSettings?)
* - interaction_type : (InteractionType)
* - game_mode : (GameMode)
* - order_array : ([Int])
* - location_array : ([Position]?)
* - game_over_text : (String)
* - tutorial_text: (CasePack.TutorialText)
* - timer_ranking : (String)
* - score_ranking : (String)
*
* Methods:
* - start(): This method is used to start the game.
* - numPadButtonTap(value: Int): This method processes a button tap on the number pad.
* - updateScoreBoard (): This method updates the score board display.
* - update(): This method updates the state of the game.
* - updateTimer(): This method updates the timer display.
* - getSurveyURL() -> URL?: This method retrieves the URL for the survey.
* - getCurrentValue() -> Int: This method retrieves the current value of the game state.
* - getImageKey() -> ImageKey: This method retrieves the key for the image to be displayed.
* - playCorrectAudio(): This method plays the audio for the correct action.
* - playWrongAudio(): This method plays the audio for the incorrect action.
* - playCorrectHaptic(): This method plays the haptic feedback for the correct action.
* - playWrongHaptic(): This method plays the haptic feedback for the incorrect action.
* - getFinalRecord() -> (time_record:[Double], value_record: [Int]): This method retrieves the record of the game progression.
* - formatTime(sec: Double, format: String, roundingMode: NumberFormatter.RoundingMode) -> String: This method formats the given time value into a string.
*
* Initialization:
* - CaseManager(case_pack: CasePack, haptic_engine: CHHapticEngine?, score_display: Published<String>, timer_display: Published<String>, game_finished: Published<Bool>): Initializes a new manager for the case progress.
*
* Example:
* let case_manager = CaseManager(case_pack: case_pack, haptic_engine: hapticEngine, score_display: self._case_score_display, timer_display: self._case_timer_display, game_finished: self._game_finished)
*
* Notes: None.
*/
class CaseManager : ObservableObject{
    private let case_pack: CasePack                             // The data received from the server which is needed to build the game screen
    private let haptic_engine: CHHapticEngine?                  // Haptic engine for generating haptic feedback
    private var correct_haptic_player: [CHHapticPatternPlayer] = []   // Player for playing the correct haptic feedback pattern
    private var wrong_haptic_player: [CHHapticPatternPlayer] = []     // Player for playing the incorrect haptic feedback pattern
    private var correct_audio_id: [SystemSoundID] = []                // The ID of the audio to be played when the correct action is performed
    private var wrong_audio_id: [SystemSoundID] = []                  // The ID of the audio to be played when the incorrect action is performed
    
    private var current_value : Int = 1                         // The current value of the game state
    private var max_reached_value : Int = 0                     // The highest value that the game state has reached
    private var score : Double = 0                              // The current score of the game
    
    private var start_time: Date = Date()                       // The time when the game started
    private var delay_time: Date = Date()                       // The time when the delay started after previous interaction
    
    private var time_record: [Double] = []                      // A record of the time at each step of the game
    private var value_record: [Int] = []                        // A record of the game state at each step of the game
    
    @Published private var score_display: String                // The score as displayed to the user
    @Published private var timer_display: String                // The time as displayed to the user
    @Published private var game_finished: Bool                  // Indicates whether the game has finished
    @Published var interactionEnabled: [Bool] = []      // Indicates whether the button can be interacted
    @Published var highlightOrder: Int = -1
    
    private var ghostID: SystemSoundID                          // System sound ID for a silent sound used to keep the audio engine alive
    
    // Initialize a new manager for the game progression
    init(case_pack: CasePack, haptic_engine: CHHapticEngine?, score_display: Published<String>, timer_display: Published<String>, game_finished: Published<Bool>) {
        self.case_pack = case_pack
        self.haptic_engine = haptic_engine
        
        if let engine = haptic_engine,
           let patterns = case_pack.linked_files?.correctHaptic {
            print(patterns)
            for i in 0...8 {
                do {
                    let player = try engine.makePlayer(with: patterns[i])
                    self.correct_haptic_player.append(player)
                } catch {
                    print("Failed to initialize correct haptic player")
                }
            }
        } else {
            print("Failed to get haptic engine or correct haptic file")
        }
        
        if let engine = haptic_engine,
           let patterns = case_pack.linked_files?.wrongHaptic {
            for i in 0...8 {
                do {
                    let player = try engine.makePlayer(with: patterns[i])
                    self.wrong_haptic_player.append(player)
                } catch {
                    print("Failed to initialize incorrect haptic player")
                }
            }
        } else {
            print("Failed to get haptic engine or incorrect haptic file")
        }
        
        
        if let local_urls = case_pack.linked_files?.correctAudio {
            let sid = 30
            for i in 0...8 {
                var sound_id : SystemSoundID = SystemSoundID(sid+i)
                AudioServicesCreateSystemSoundID(local_urls[i] as CFURL, &sound_id)
                self.correct_audio_id.append(sound_id)
            }
        }
        
        if let local_urls = case_pack.linked_files?.wrongAudio {
            let sid = 40
            for i in 0...8 {
                var sound_id : SystemSoundID = SystemSoundID(sid+i)
                AudioServicesCreateSystemSoundID(local_urls[i] as CFURL, &sound_id)
                self.wrong_audio_id.append(sound_id)
            }
        }
        self._score_display = score_display
        self._timer_display = timer_display
        self._game_finished = game_finished
        
        self.interactionEnabled = [Bool](repeating: case_pack.interaction_delay.allSatisfy({ $0 == 0 }), count: 9)
        
        self.ghostID = 2
        let ghostURL = Bundle.main.url(forResource: "silent_quarter-second", withExtension: "wav")!
        AudioServicesCreateSystemSoundID(ghostURL as CFURL, &self.ghostID)
    }

    // Start the game and reset the state
    func start() {
        self.score_display = "0"
        self.timer_display = ""
        self.game_finished = false
        start_time = Date()
    }
    
    
    // Process a button tap on the interaction pads
    func numPadButtonTap(value: Int, button_index: Int) {
        if (game_finished) {return}
        time_record.append(Date().timeIntervalSince(start_time))
        value_record.append(value)
        if value == 0 {return}  // swipe start at 0 end at -1
        if current_value == value && interactionEnabled[button_index] {
            if current_value > max_reached_value {
                if score_board_settings != nil {
                    score += score_board_settings!.reward_score
                    if case_pack.score_board != nil { updateScoreBoard()}
                }
                max_reached_value += 1
            }
            current_value += 1
            delay_time = Date()
            DispatchQueue.main.async {
                self.playCorrectAudio(order_index: button_index+1)
                self.playCorrectHaptic(order_index: button_index+1)
            }
            if (current_value > order_array.count) {
                game_finished = true
                return
            }
        } else {
            DispatchQueue.main.async {
                if (button_index >= 0) {
                    self.playWrongAudio(order_index: button_index+1)
                    self.playWrongHaptic(order_index: button_index+1)
                }
            }
            if let score_board = case_pack.score_board {
                score -= Double(score_board.penalty_percentage) / 100.0 * score_board.reward_score * Double(case_pack.order_array.count)
                if case_pack.score_board != nil { updateScoreBoard()}
            }
            if case_pack.interaction.game_mode == GameMode.restart {
                current_value = 1
                delay_time = Date()
                self.interactionEnabled = [Bool](repeating: case_pack.interaction_delay.allSatisfy({ $0 == 0 }), count: 9)
            }
        }
        
    }
    
    // Update the score board display
    private func updateScoreBoard () {
        let formatter = NumberFormatter()
        if let scoreboard = case_pack.score_board {
            formatter.maximumFractionDigits = scoreboard.decimal_places
            formatter.roundingMode = .down
            score_display = formatter.string(from: (score < 0 && !scoreboard.display_negative) ? 0 : score as NSNumber) ?? ""
        }
    }
    
    // Update the state of the game
    func update() {
        if (!game_finished) {
            if (highlight_array != nil) {
                highlightOrder = highlight_array![current_value - 1]
                self.objectWillChange.send()
            }
            if let index = order_array.firstIndex(of: current_value) {
                let sec = Date().timeIntervalSince(delay_time)
                if (sec > Double(case_pack.interaction_delay[index]) / 1000) {
                    interactionEnabled[index] = true
                    self.objectWillChange.send()
                }
            }
            AudioServicesPlaySystemSound(ghostID)
            updateTimer()
        }
    }
    
    // Update the timer display
    private func updateTimer() {
        if let timer = case_pack.timer {
            var sec = Date().timeIntervalSince(start_time)
            if (sec > Double(timer.max_time) / 1000) {
                timer_display = formatTime(sec: timer.direction == Direction.down ? 0.0 : Double(timer.max_time) / 1000, format: timer.format, roundingMode: timer.direction == Direction.up ? .down : .up)
                game_finished = true
                return
            }
            if timer.direction == Direction.down {
                sec = Double(timer.max_time) / 1000 - sec // convert max time to sec and subtract sec form it
            }
            timer_display = formatTime(sec: sec, format: timer.format, roundingMode: timer.direction == Direction.up ? .down : .up)
        }
    }
    
    // Get the URL for the survey
    func getSurveyURL() -> URL? {
        return case_pack.survey_url
    }
    
    // Get the current value of the game state
    func getCurrentValue() -> Int {
        return current_value
    }
    
    // Get the key for the image to be displayed
    func getImageKey() -> ImageKey {
        return ImageKey(location_array_available: case_pack.location_array != nil, interaction_type: case_pack.interaction.interaction_type)
    }
    
    // This computed property retrieves the timer settings from the case pack.
    public var timer_settings : CasePack.TimerSettings? {
        return case_pack.timer
    }
    
    // This computed property retrieves the score board settings from the case pack.
    public var score_board_settings : CasePack.ScoreBoardSettings? {
        return case_pack.score_board
    }
    
    // This computed property retrieves the interaction type of the game from the case pack.
    public var interaction_type : InteractionType {
        return case_pack.interaction.interaction_type
    }
    
    // This computed property retrieves the game mode of the game from the case pack.
    public var game_mode : GameMode {
        return case_pack.interaction.game_mode
    }
    
    // This computed property retrieves the order array from the case pack, which indicates the sequence of tasks or steps in the game.
    public var order_array : [Int] {
        return case_pack.order_array
    }
    
    public var custom_text_array: [String]? {
        return case_pack.custom_text_array
    }
    
    public var highlight_array: [Int]? {
        return case_pack.highlight_array
    }
    
    // This computed property retrieves the location array from the case pack, which indicates the spatial positions of objects in the game.
    public var location_array : [Position]? {
        return case_pack.location_array
    }
    
    // This computed property retrieves the text to be displayed when the game is over.
    public var game_over_text : String {
        return case_pack.game_over_text
    }
    
    // This computed property retrieves the tutorial text from the case pack, which gives instructions or hints to the player.
    public var tutorial_text: CasePack.TutorialText {
        return case_pack.tutorial_text
    }
    
    // This computed property retrieves the fake time ranking.
    public var timer_ranking : String {
        if let timer = case_pack.timer {
            return formatTime(sec: timer.fake_ranking ?? 3600000, format: timer.format, roundingMode: timer.direction == Direction.up ? .down : .up)
        }
        return ""
    }

    // This computed property retrieves the fake score ranking.
    public var score_ranking : String {
        let formatter = NumberFormatter()
        if let scoreboard = case_pack.score_board {
            formatter.maximumFractionDigits = scoreboard.decimal_places
            formatter.roundingMode = .down
            if (scoreboard.fake_ranking ?? 0 < 0 && !(scoreboard.display_negative)) {
                return formatter.string(from: 0 as NSNumber) ?? ""
            } else {
                return formatter.string(from: (scoreboard.fake_ranking ?? 0) as NSNumber) ?? ""
            }
        }
        return ""
    }
    
    // Play the audio for the correct action
    private func playCorrectAudio(order_index: Int) {
        if correct_audio_id.count > 0 {
            AudioServicesPlaySystemSound(correct_audio_id[order_index-1])
        }
        
    }
    
    // Play the audio for the incorrect action
    private func playWrongAudio(order_index: Int) {
        if wrong_audio_id.count > 0 {
            AudioServicesPlaySystemSound(wrong_audio_id[order_index-1])
        }
    }
    
    // Play the haptic feedback for the correct action
    private func playCorrectHaptic(order_index: Int) {
        if let _ = self.haptic_engine, order_index > 0, order_index <= self.correct_haptic_player.count {
            let player = self.correct_haptic_player[order_index-1]
            do {
                try player.start(atTime: CHHapticTimeImmediate)
            } catch {
                print("correct_haptic_player failed to start")
            }
        }
    }
    
    // Play the haptic feedback for the incorrect action
    private func playWrongHaptic(order_index: Int) {
        if let _ = self.haptic_engine, order_index > 0, order_index <= self.wrong_haptic_player.count {
            let player = self.wrong_haptic_player[order_index-1]
            do {
                try player.start(atTime: CHHapticTimeImmediate)
            } catch {
                print("wrong_haptic_player failed to start")
            }
        }
    }
    
    // Get the record of the game progression
    func getFinalRecord() -> (time_record:[Double], value_record: [Int]){
        return (time_record, value_record)
    }
    
    // Format the given time value into a string
    private func formatTime(sec: Double, format: String, roundingMode: NumberFormatter.RoundingMode) -> String {
        let formatter = NumberFormatter()
        switch format {
        case "s":
            formatter.maximumFractionDigits = 0
            formatter.roundingMode = roundingMode
            return formatter.string(from: sec as NSNumber) ?? ""
        case "m":
            formatter.maximumFractionDigits = 0
            formatter.roundingMode = roundingMode
            return formatter.string(from: sec / 60 as NSNumber) ?? ""
        case "s.SSS":
            formatter.maximumFractionDigits = 3
            formatter.roundingMode = roundingMode
            return formatter.string(from: sec as NSNumber) ?? ""
        case "mm:ss":
            formatter.minimumIntegerDigits = 2
            formatter.maximumFractionDigits = 0
            formatter.roundingMode = .down
            var result = formatter.string(from: sec / 60 as NSNumber) ?? ""
            result += ":"
            formatter.roundingMode = roundingMode
            result += formatter.string(from: sec.truncatingRemainder(dividingBy: 60) as NSNumber) ?? ""
            return result
        case "mm:ss.SSS":
            formatter.minimumIntegerDigits = 2
            formatter.maximumFractionDigits = 0
            formatter.roundingMode = .down
            var result = formatter.string(from: sec / 60 as NSNumber) ?? ""
            result += ":"
            formatter.maximumFractionDigits = 3
            formatter.roundingMode = roundingMode
            result += formatter.string(from: sec.truncatingRemainder(dividingBy: 60) as NSNumber) ?? ""
            return result
        default: // "S"
            formatter.maximumFractionDigits = 0
            formatter.roundingMode = roundingMode
            return formatter.string(from: sec * 1000 as NSNumber) ?? ""
        }
    }
}

//
//  DecodableManager.swift
//  Haptic Performance Platform
//
//  Created by iseungheon on 1/31/23.
//
// This file contains definitions for enums and structs used throughout the Haptic Performance Platform.

import Foundation
import AVFoundation
import CoreHaptics

// Enum for defining interaction types used in the game. Each case also provides a hash function for easier comparison.
enum InteractionType: String, Hashable, Decodable {
    case tap = "tap"
    case swipe_through = "swipe_through"

    func hash(into hasher: inout Hasher) {
        switch self {
            case .tap: hasher.combine(0)
            case .swipe_through: hasher.combine(1)
        }
    }
}

// Enum for defining game modes used in the game. Each case also provides a hash function for easier comparison.
enum GameMode: String, Hashable, Decodable {
    case restart = "restart"
    case resume = "continue"

    func hash(into hasher: inout Hasher) {
        switch self {
            case .restart: hasher.combine(0)
            case .resume: hasher.combine(1)
        }
    }
    
}

// Enum for defining the direction used for timer settings.
enum Direction: String, Hashable, Decodable {
    case up = "up"
    case down = "down"
    
    func hash(into hasher: inout Hasher) {
        switch self {
            case .up: hasher.combine(0)
            case .down: hasher.combine(1)
        }
    }
}

// Struct for storing image identifyer, hashable for use in dictionary as key.
struct ImageKey: Hashable {
    let location_array_available: Bool
    let interaction_type: InteractionType
    
    init(location_array_available: Bool, interaction_type: InteractionType) {
        self.location_array_available = location_array_available
        self.interaction_type = interaction_type
    }
}

// Struct to represent a position in a 2D space.
struct Position: Decodable, Hashable {
    let x: Int
    let y: Int
}

// Struct for decoding experiment data from JSON. This includes user agreements, layout descriptions, tutorial images, case IDs and survey URL.
struct ExperimentPack: Decodable {
    let user_agreements: [String]
    let layout_descriptions : [LayoutDescriptions]
    let tutorial_image_urls: [ImageKey : URL]
    let case_id_array: [String]
    let survey_url: URL?

    // JSON decoding keys.
    private enum CodingKeys: String, CodingKey {
        case user_agreements
        case layout_descriptions
        case case_id_array
        case survey_url
    }
    
    // Nested struct for decoding layout descriptions from JSON.
    struct LayoutDescriptions: Decodable, Hashable {
        let image_url : URL
        let location_array_available : Bool
        let interaction_type: InteractionType
        
        // JSON decoding keys.
        private enum CodingKeys: String, CodingKey {
            case image = "image"
            case location_array_available = "location_array_available"
            case interaction_type = "interaction_type"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let image_string = try? container.decode(String.self, forKey: .image),
               let url = URL(string: image_string){
                image_url = url
            } else {
                throw DecodingError.dataCorruptedError(forKey: .interaction_type, in: container, debugDescription: "Cannot decode image_url")
            }
            
            location_array_available = try container.decode(Bool.self, forKey: .location_array_available)
            
            let interaction_type_string = try container.decode(String.self, forKey: .interaction_type)
            switch interaction_type_string {
                case "tap":
                    interaction_type = InteractionType.tap
                    break
                case "swipe_through":
                    interaction_type = InteractionType.swipe_through
                    break
                default:
                    throw DecodingError.dataCorruptedError(forKey: .interaction_type, in: container, debugDescription: "Cannot decode interaction_type")
            }
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        user_agreements = try container.decode([String].self, forKey: .user_agreements)
        var image_urls = [ImageKey: URL]()
        do {
            layout_descriptions = try container.decode([LayoutDescriptions].self, forKey: .layout_descriptions)
            for layout_description in layout_descriptions {
                image_urls[ImageKey(location_array_available: layout_description.location_array_available, interaction_type: layout_description.interaction_type)] = layout_description.image_url
            }
            tutorial_image_urls = image_urls
        } catch let error as DecodingError {
            switch error {
                case .dataCorrupted(let key):
                        print(key.debugDescription)
                default:
                       print(error)
             }
            throw DecodingError.dataCorruptedError(forKey: .layout_descriptions, in: container, debugDescription: "Cannot decode layout_descriptions")
        }
        case_id_array = try container.decode([String].self, forKey: .case_id_array)
        survey_url = try? container.decode(URL.self, forKey: .survey_url)
    }
}

// Struct for decoding case pack data from JSON. This includes the order array, location array, interaction settings, timer settings, score board settings, linked files, tutorial text, game over text, and survey URL. 
struct CasePack: Decodable {
    let order_array: [Int]
    let custom_text_array: [String]?
    let highlight_array: [Int]?
    let interaction_delay: [Int]
    let location_array: [Position]?
    let interaction: Interaction
    let timer: TimerSettings?
    let score_board: ScoreBoardSettings?
    let linked_files: LinkedFiles?
    let tutorial_text: TutorialText
    let game_over_text: String
    let survey_url: URL?
    
    var interaction_record_button: [Int]  // Button clicked during case execution
    var interaction_record_duration: [Double] // Time Interval from the beginning of case execution
    var final_score: Double
    var final_duration: Double
    
    // Nested struct for decoding interaction settings from JSON.
    struct Interaction: Decodable {
        let interaction_type: InteractionType
        let game_mode: GameMode
        
        // JSON decoding keys.
        private enum CodingKeys: String, CodingKey {
            case interaction_type = "interaction_type"
            case game_mode = "game_mode"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            interaction_type = try container.decode(InteractionType.self, forKey: .interaction_type)
            game_mode = try container.decode(GameMode.self, forKey: .game_mode)
        }
        
    }
    
    // Nested struct for decoding timer settings from JSON.
    struct TimerSettings: Decodable {
        let direction: Direction    // not implemented
        let max_time: Int           // not implemented
        let format: String          // not implemented
        let fake_ranking: Double?    // implemented
        
        // JSON decoding keys.
        private enum CodingKeys: String, CodingKey {
            case direction = "direction"
            case format = "format"
            case fake_ranking = "fake_ranking"
            case max_time = "max_time"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            direction = try container.decode(Direction.self, forKey: .direction)
            format = try container.decode(String.self, forKey: .format)
            fake_ranking = try? container.decode(Double.self, forKey: .fake_ranking)
            max_time = try container.decode(Int.self, forKey: .max_time)
        }
    }
    
    // Nested struct for decoding score board settings from JSON.
    struct ScoreBoardSettings: Decodable {
        let reward_score: Double
        let penalty_percentage: Int
        let decimal_places: Int
        let display_negative: Bool
        let fake_ranking: Double?       
    }

    // Nested struct for decoding linked file data from JSON.    
    struct LinkedFiles: Decodable {
        let correctHaptic: [CHHapticPattern]?
        let correctAudio: [URL]?
        let wrongHaptic: [CHHapticPattern]?
        let wrongAudio: [URL]?
        
        // JSON decoding keys.
        private enum CodingKeys: String, CodingKey {
            case correctHaptic = "correct_haptic"
            case correctAudio = "correct_audio"
            case wrongHaptic = "wrong_haptic"
            case wrongAudio = "wrong_audio"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
                
            if let strings = try? container.decode([String].self, forKey: .correctHaptic) {
                let empty_pattern = try CHHapticPattern(events: [], parameters: [])
                var patterns = [CHHapticPattern](repeating: empty_pattern, count: strings.count)
                for (index, string) in strings.enumerated() {
                    if let remote_url = URL(string: string),
                    let data = try? Data(contentsOf: remote_url) {
                        do {
                            let local_url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(UUID().uuidString).ahap")
                            try data.write(to: local_url)
                            let pattern = try CHHapticPattern(contentsOf: local_url)
                            patterns[index] = pattern
                        } catch {
                            // Handle error if needed
                        }
                    }
                }
                correctHaptic = patterns.isEmpty ? nil : patterns
            } else {
                correctHaptic = nil
            }
            
            if let strings = try? container.decode([String].self, forKey: .correctAudio) {
                let ghostURL = Bundle.main.url(forResource: "silent_quarter-second", withExtension: "wav")!
                var urls = [URL](repeating: ghostURL, count: strings.count)
                for (index, string) in strings.enumerated() {
                    if let remote_url = URL(string: string),
                    let data = try? Data(contentsOf: remote_url) {
                        print(remote_url)
                        let local_url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(UUID().uuidString).wav")
                        do {
                            try data.write(to: local_url)
                            urls[index] = local_url
                        } catch {
                            // Handle error if needed
                        }
                    }
                }
                correctAudio = urls.isEmpty ? nil : urls
            } else {
                correctAudio = nil
            }
            
            if let strings = try? container.decode([String].self, forKey: .wrongHaptic) {
                let empty_pattern = try CHHapticPattern(events: [], parameters: [])
                var patterns = [CHHapticPattern](repeating: empty_pattern, count: strings.count)
                for (index, string) in strings.enumerated() {
                    if let remote_url = URL(string: string),
                    let data = try? Data(contentsOf: remote_url) {
                        do {
                            let local_url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(UUID().uuidString).ahap")
                            try data.write(to: local_url)
                            let pattern = try CHHapticPattern(contentsOf: local_url)
                            patterns[index] = pattern
                        } catch {
                            // Handle error if needed
                        }
                    }
                }
                wrongHaptic = patterns.isEmpty ? nil : patterns
            } else {
                wrongHaptic = nil
            }
            
            if let strings = try? container.decode([String].self, forKey: .wrongAudio) {
                let ghostURL = Bundle.main.url(forResource: "silent_quarter-second", withExtension: "wav")!
                var urls = [URL](repeating: ghostURL, count: strings.count)
                for (index, string) in strings.enumerated() {
                    if let remote_url = URL(string: string),
                    let data = try? Data(contentsOf: remote_url) {
                        let local_url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(UUID().uuidString).wav")
                        do {
                            try data.write(to: local_url)
                            urls[index] = local_url
                        } catch {
                            // Handle error if needed
                        }
                    }
                }
                wrongAudio = urls.isEmpty ? nil : urls
            } else {
                wrongAudio = nil
            }
        }
    }
    
    // Nested struct for decoding tutorial text data from JSON.
    struct TutorialText: Decodable {
        let interaction_type: String
        let penalty: String
        let game_mode: String
    }

    // JSON decoding keys.
    private enum CodingKeys: String, CodingKey {
        case order_array
        case custom_text_array
        case highlight_array
        case interaction_delay
        case location_array
        case interaction
        case timer
        case score
        case linked_files
        case tutorial_text
        case game_over_text
        case survey_url
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        order_array = try container.decode([Int].self, forKey: .order_array)
        custom_text_array = try? container.decode([String].self, forKey: .custom_text_array)
        highlight_array = try? container.decode([Int].self, forKey: .highlight_array)
        interaction_delay = try container.decode([Int].self, forKey: .interaction_delay)
        location_array = try? container.decode([Position].self, forKey: .location_array)
        interaction = try container.decode(Interaction.self, forKey: .interaction)
        timer = try? container.decode(TimerSettings.self, forKey: .timer)
        score_board = try? container.decode(ScoreBoardSettings.self, forKey: .score)
        linked_files = try? container.decode(LinkedFiles.self, forKey: .linked_files)
        tutorial_text = try container.decode(TutorialText.self, forKey: .tutorial_text)
        survey_url = try? container.decode(URL.self, forKey: .survey_url)
        
        let game_over_text = try? container.decode(String.self, forKey: .game_over_text)
        self.game_over_text = game_over_text != nil ? game_over_text! : "Game Over!"
        
        interaction_record_button = [Int]()  // Button clicked during case execution
        interaction_record_duration = [Double]() // Time Interval from the beginning of case execution
        final_score = 0.0
        final_duration = 0.0
    }
}

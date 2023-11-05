//
//  AudioRecordingManager.swift
//  TonePod
//
//  Created by Kyle-Anthony Hay on 11/2/23.
//

import AVFoundation
import UIKit

class AudioRecordingManager {
    
    weak var viewController: UIViewController?
    
    // Constructor to initialize with the ViewController reference
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    
    // MARK: Utilities
    func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Error setting up audio session: \(error)")
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { allowed in
            DispatchQueue.main.async {
                completion(allowed)
            }
        }
    }
    
    func promptForFileName(completion: @escaping (String?) -> Void) {
        guard let viewController = viewController else {
            completion(nil)
            return
        }

        // Create an alert to ask the user for the filename
        let alertController = UIAlertController(title: "What letter should the name start with?", message: " ", preferredStyle: .alert)
        
        // Add a text field to the alert for the filename input
        alertController.addTextField { (textField) in
            textField.placeholder = "first letter.."
        }
        
        // Add a "Confirm" action to the alert
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { [weak alertController] _ in
            if let textField = alertController?.textFields?.first, let userInput = textField.text {
                completion(userInput)
            } else {
                completion(nil)
            }
        }
        alertController.addAction(confirmAction)
        
        // Add a "Cancel" action to the alert
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
}

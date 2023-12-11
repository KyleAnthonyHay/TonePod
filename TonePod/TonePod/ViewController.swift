//
//  ViewController.swift
//  TonePod
//
//  Created by Kyle-Anthony Hay on 10/21/23.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    // MARK: Variable Declaration
    var audioRecorder: AVAudioRecorder?
    var recordButton: UIButton!
    var audioFileNumber: Int = 0
    var apiProvidedFileName: String = "r"// optionally Provided by User
    var apiProvidedFileName2: RandomWord?
    
    // Declare an instance of AudioRecordingManager
    var audioManager: AudioRecordingManager!
    
    // MARK: Render
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the audio manager
        audioManager = AudioRecordingManager(viewController: self)
        
        // Set the background color and title
        self.view.backgroundColor = UIColor(red: 253/255.0, green: 253/255.0, blue: 253/255.0, alpha: 1.0)
        self.title = "Record"
        navigationController?.tabBarItem.image = UIImage(systemName: "record.circle")
        navigationController?.tabBarItem.title = "Record"
        
        // Create and configure the button
        recordButton = UIButton(type: .system)
        recordButton.setTitle("Start", for: .normal) //initial title
        recordButton.addTarget(self, action: #selector(onRecordButtonTapped), for: .touchUpInside)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the button to the view
        self.view.addSubview(recordButton)
        
        // Center the button in the view
        NSLayoutConstraint.activate([
            recordButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            recordButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }

    // MARK: Handle Recording
    var isRecording = false

    @objc func startRecording(filename: String) {
        // Recording Stopped
        if isRecording {
            
            // Stop recording
            audioRecorder?.stop()
            isRecording = false
            recordButton.setTitle("Start", for: .normal) // set title from "stop to Start"
            print("Stopped recording.\n\n")
            // Notify Listerners that new recording has been added
            NotificationCenter.default.post(name: .didFinishRecording, object: nil)
        
        } else { // Recording Started
            audioManager.requestMicrophonePermission { [weak self] allowed in
                guard allowed else {
                    // Handle the case where the user denied microphone access
                    print("Microphone access denied")
                    return
                }
                
                self?.audioManager.configureAudioSession()
                self?.audioFileNumber += 1
                let audioFilename = self?.audioManager.getDocumentsDirectory().appendingPathComponent("\(filename).m4a")
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 12000,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ]
                
                do {
                    self?.audioRecorder = try AVAudioRecorder(url: audioFilename!, settings: settings)
                    self?.audioRecorder?.record()
                    self?.isRecording = true
                    print("Recording started.")
                    self?.recordButton.setTitle("Stop", for: .normal)
                    print("File Path: \(audioFilename?.path ?? "Failed")")
                    
                // if unable to start recording
                } catch {
                    print("Error starting audio recording: \(error)")
                }
            }
        }
    }

    func promptForFileName() {
        let alertController = UIAlertController(title: "What letter should the name start with?", message: " ", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "first letter.."
        }
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { [weak self, weak alertController] _ in
            if let textField = alertController?.textFields?.first, let userInput = textField.text {
                
                if userInput.count > 1 || !userInput.allSatisfy({ $0.isLetter }) {
                    self?.showInvalidResponsePopup()
                    return
                }
                
                // MARK: API Call
                Task {
                    do {
                        let response = try await RandomWordsAPI.shared.randomWordStartsWith(startingLetter: userInput)
                        self?.apiProvidedFileName2 = response
                        print("From API: \(self?.apiProvidedFileName2?.word ?? "No word returned")")
                        
                        // Start recording after API responds
                        if let filename = self?.apiProvidedFileName2?.word {
                            self?.startRecording(filename: filename)
                        }
                    } catch {
                        print(error)
                    }
                }
            }
        }
        alertController.addAction(confirmAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func showInvalidResponsePopup() {
        let alert = UIAlertController(title: "Error", message: "Invalid Response.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    @objc func onRecordButtonTapped() {
        if isRecording {
            startRecording(filename: "0")  // Provide a default filename here
        } else {
            promptForFileName()
        }
    }


}

// MARK: Extentions
extension Notification.Name {
    static let didFinishRecording = Notification.Name("didFinishRecording")
}

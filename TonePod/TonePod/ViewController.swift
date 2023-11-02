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
        self.title = "AudioPod"
        
        // Create and configure the button
        recordButton = UIButton(type: .system)
        recordButton.setTitle("Record", for: .normal)
        recordButton.addTarget(self, action: #selector(startRecording), for: .touchUpInside)
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

    @objc func startRecording() {
        // Recording Stopped
        if isRecording {
            // Stop recording
            audioRecorder?.stop()
            isRecording = false
            recordButton.setTitle("Record", for: .normal)
            print("Stopped recording.\n\n")
            
            // After Stopping Recording, Pompt User to Name File
            self.promptForFileName()
            // MARK: API Call
            // API CALL TEST
            Task{
                do {
                    let response = try await RandomWordsAPI.shared.randomWordStartsWith(startingLetter: self.apiProvidedFileName)
                    self.apiProvidedFileName2 = response
                    print("From Start Recording Func: \(self.apiProvidedFileName2?.word ?? "No word returned")")
                } catch {
                    print(error)
                }
            }
            
            
        
        // Recording Started
        } else {
            audioManager.requestMicrophonePermission { [weak self] allowed in
                guard allowed else {
                    // Handle the case where the user denied microphone access
                    print("Microphone access denied")
                    return
                }
                
                self?.audioManager.configureAudioSession()
                self?.audioFileNumber += 1
                let audioFilename = self?.audioManager.getDocumentsDirectory().appendingPathComponent("recording\(self?.audioFileNumber ?? 0).m4a")
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
        // Create an alert to ask the user for the filename
        let alertController = UIAlertController(title: "What letter should the name start with?", message: " ", preferredStyle: .alert)
        
        // Add a text field to the alert for the filename input
        alertController.addTextField { (textField) in
            textField.placeholder = "first letter.."
        }
        
        // Add a "Confirm" action to the alert
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { [weak self, weak alertController] _ in
            if let textField = alertController?.textFields?.first, let userInput = textField.text {
                // Here, 'userInput' contains the text entered by the user
                // You can store it in a property or use it as needed
                self?.apiProvidedFileName = userInput
                self?.apiProvidedFileName2 = RandomWord(word: userInput)
                print("User Input: \(self?.apiProvidedFileName2?.word ?? "No Input")")

            }
        }
        alertController.addAction(confirmAction)
        
        // Add a "Cancel" action to the alert
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }


}



//
//  ViewController.swift
//  TonePod
//
//  Created by Kyle-Anthony Hay on 10/21/23.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var audioRecorder: AVAudioRecorder?
    var audioFileName: Int = 0
    var recordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

    func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Error setting up audio session: \(error)")
        }
    }

    var isRecording = false

    @objc func startRecording() {
        if isRecording {
            // Stop recording
            audioRecorder?.stop()
            isRecording = false
            recordButton.setTitle("Record", for: .normal)
            print("Stopped recording.")
            
        } else {
            requestMicrophonePermission { [weak self] allowed in
                guard allowed else {
                    // Handle the case where the user denied microphone access
                    print("Microphone access denied")
                    return
                }
                
                self?.configureAudioSession()
                
                self?.audioFileName += 1
                let audioFilename = self?.getDocumentsDirectory().appendingPathComponent("recording\(self?.audioFileName ?? 0).m4a")
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
                    print(audioFilename?.path ?? "Failed")
                    

                } catch {
                    print("Error starting audio recording: \(error)")
                }
            }
        }
    }

    
    
    // MARK: Utilities
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

}



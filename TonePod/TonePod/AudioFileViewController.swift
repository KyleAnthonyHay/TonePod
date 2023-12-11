//
//  AudioFileViewController.swift
//  TonePod
//
//  Created by Kyle-Anthony Hay on 11/16/23.
//

import UIKit
import AVFoundation

//!!AudioFile_TableViewCell_Delegate
class AudioFileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate, AudioFile_TableViewCell_Delegate {
    
  
    
    
    //variables
    var groupedAudioFiles: [String] = []
    var audioPlayer: AVAudioPlayer?
    weak var currentPlayingCell: AudioFile_TableViewCell?
    let fileManager = FileManager.default
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let letterClass: String //provided by Group Controller
    var apiProvidedFileName2: RandomWord?
    
    
    init(startswith: String){
        self.letterClass = startswith
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(AudioFile_TableViewCell.self, forCellReuseIdentifier: "AudioFile")

        // Do any additional setup after loading the view.
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        filterAudioFiles(starts_with: letterClass)
    }
    
    func filterAudioFiles(starts_with letter: String) {
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            // Filter the URLs based on the first letter of the last path component
            groupedAudioFiles = fileURLs.filter { url in
                guard let firstLetter = url.lastPathComponent.first?.lowercased() else { return false }
                return firstLetter == letter.lowercased()
            }.map { $0.lastPathComponent }
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
        print("Grouped Audio Files:", groupedAudioFiles)
    }
    
    // MARK: Delegate and Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedAudioFiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AudioFile", for: indexPath) as? AudioFile_TableViewCell else {
            fatalError("The dequeued cell is not an instance of AudioFile_TableViewCell.")
        }
        cell.delegate = self // Set the view controller as the delegate
        cell.textLabel?.text = groupedAudioFiles[indexPath.row]
        return cell
    }

    //MARK: other functions
    
    func playAudioFile(named fileName: String) {
            let fileURL = documentsURL.appendingPathComponent(fileName)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
                audioPlayer?.delegate = self
                audioPlayer?.play()
                audioPlayerDidFinishPlaying(audioPlayer!, successfully: true)
            } catch {
                print("Failed to play audio file: \(error)")
            }
        }
    
    func playButtonTapped(cell: AudioFile_TableViewCell) {
        print("Inside playButtonTapped() Function!")
        if let indexPath = tableView.indexPath(for: cell) {
            let fileName = groupedAudioFiles[indexPath.row]
            playAudioFile(named: fileName)
            currentPlayingCell = cell
        }
    }
    
    // Implement AVAudioPlayerDelegate methods if needed
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // Check if the audio player finished successfully
        if flag {
            // Check if there is a current playing cell
            if let cell = currentPlayingCell {
                // Toggle the button's image back to "play"
                DispatchQueue.main.async {
                    cell.playButton.isSelected = false
                }
            }
        }
        currentPlayingCell = nil // Reset the current playing cell
    }
    
    func trashButtonTapped(cell: AudioFile_TableViewCell) {
           if let indexPath = tableView.indexPath(for: cell) {
               let fileName = groupedAudioFiles[indexPath.row]
               deleteAudioFile(named: fileName, at: indexPath)
               //Notify GroupView to Update
           }
       }

    
    private func deleteAudioFile(named fileName: String, at indexPath: IndexPath) {
           let fileURL = documentsURL.appendingPathComponent(fileName)

           do {
               try fileManager.removeItem(at: fileURL)
               groupedAudioFiles.remove(at: indexPath.row) // Update your data model
               tableView.deleteRows(at: [indexPath], with: .fade) // Refresh the table view
               NotificationCenter.default.post(name: .audioFileDeleted, object: nil)
           } catch {
               print("Error deleting file: \(error.localizedDescription)")
               // Handle the error, perhaps show an alert to the user
           }
    }
    
    func editButtonTapped(cell: AudioFile_TableViewCell) {
        print("editButtonTapped")
        
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let oldFileName = groupedAudioFiles[indexPath.row]
        
        Task {
            if let newWord = await promptForFileName() {
                renameAudioFile(oldFileName: oldFileName, newFileName: newWord)
                // Refresh the UI (reload table view)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }

    
    func promptForFileName() async -> String? {
        let alertController = UIAlertController(title: "What letter should the name start with?", message: " ", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "first letter.."
        }
        
        // Create a promise
        return await withCheckedContinuation { continuation in
            let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
                if let textField = alertController.textFields?.first, let userInput = textField.text {
                    // Async API Call
                    Task {
                        do {
                            let response = try await RandomWordsAPI.shared.randomWordStartsWith(startingLetter: userInput)
                            continuation.resume(returning: response.word)
                        } catch {
                            print(error)
                            continuation.resume(returning: nil)
                        }
                    }
                } else {
                    continuation.resume(returning: nil)
                }
            }
            alertController.addAction(confirmAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
            
        }
    }

    func renameAudioFile(oldFileName: String, newFileName: String) {
        let oldFileURL = documentsURL.appendingPathComponent(oldFileName)
        let newFileURL = documentsURL.appendingPathComponent(newFileName).appendingPathExtension(oldFileURL.pathExtension)

        do {
            // Rename the file in the filesystem
            try fileManager.moveItem(at: oldFileURL, to: newFileURL)

            // Update your data model
            if let index = groupedAudioFiles.firstIndex(of: oldFileName) {
                groupedAudioFiles[index] = newFileURL.lastPathComponent
            }

        } catch {
            print("Error renaming file: \(error.localizedDescription)")
            // Handle the error, perhaps show an alert to the user
        }
    }

}

// MARK: Extentions
extension Notification.Name {
    static let audioFileDeleted = Notification.Name("audioFileDeleted")
}


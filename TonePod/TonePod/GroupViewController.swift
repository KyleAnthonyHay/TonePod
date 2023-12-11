//
//  GroupViewController.swift
//  TonePod
//
//  Created by Kyle-Anthony Hay on 11/15/23.
//

import UIKit

class GroupViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
 
    let fileManager = FileManager.default
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    var audioFiles: [String] = []
    var firstLetters: Set<Character> = []
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LetterCell")
        self.title = "Groups"
        navigationController?.tabBarItem.image = UIImage(systemName: "folder.fill")
        navigationController?.tabBarItem.title = "Groups"
        // Set the title color for this navigation bar
        navigationController?.navigationBar.tintColor = UIColor.black

        // Do any additional setup after loading the view.
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        loadAudioFiles() // into array
        updateFirstLetters() // for groups
        // Listen for new recording to update
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTableData), name: .didFinishRecording, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTableData), name: .audioFileDeleted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTableData), name: .audioFileEdited, object: nil)
    }
    // Function for reloading the data
    @objc func refreshTableData() {
        loadAudioFiles()
        updateFirstLetters()
        tableView.reloadData()
    }

    // MARK: - Load Audio Files
     func loadAudioFiles() {
         do {
             let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
             let sortedURLs = fileURLs.filter { $0.pathExtension == "m4a" || $0.pathExtension == "mp3" }
                                              .sorted { $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedAscending }
             audioFiles = sortedURLs.map { $0.lastPathComponent }
             //print("Sorted audio files: \(audioFiles)")
//             tableView.reloadData()
         } catch {
             print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
         }
     }
    
    func updateFirstLetters() {
//        audioFiles.sort() // doesnt work
        firstLetters = Set(audioFiles.map { $0.first ?? "#" })
    }
    
    // MARK: Delegate & DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return firstLetters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LetterCell", for: indexPath)
        let letter = Array(firstLetters)[indexPath.row]
        cell.textLabel?.text = String(letter)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let letter = Array(firstLetters)[indexPath.row]
        let AudioFileViewController = AudioFileViewController(startswith: String(letter) )
        navigationController?.pushViewController(AudioFileViewController, animated: true)
    }

}

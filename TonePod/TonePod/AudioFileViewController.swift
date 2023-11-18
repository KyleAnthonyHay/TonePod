//
//  AudioFileViewController.swift
//  TonePod
//
//  Created by Kyle-Anthony Hay on 11/16/23.
//

import UIKit

class AudioFileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //variables
    var groupedAudioFiles: [String] = []
    let fileManager = FileManager.default
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let letterClass: String //provided by Group Controller
   
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
        
        print(groupedAudioFiles)
    }
    
    @objc func handlePlayButton(_ sender: UIButton) {
        if let cell = sender.superview as? AudioFile_TableViewCell,
           let indexPath = tableView.indexPath(for: cell) {
            // Handle play action for the item at indexPath
        }
    }

    
    // MARK: Delegate and Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedAudioFiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioFile", for: indexPath)
        cell.textLabel?.text = groupedAudioFiles[indexPath.row]
        // Configure the play button if needed
        // cell.playButton.addTarget(self, action: #selector(handlePlayButton(_:)), for: .touchUpInside)
        return cell
    }
}


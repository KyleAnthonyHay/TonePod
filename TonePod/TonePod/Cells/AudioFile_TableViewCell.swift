//
//  AudioFile_TableViewCell.swift
//  TonePod
//
//  Created by Kyle-Anthony Hay on 11/18/23.
//

import UIKit

protocol AudioFile_TableViewCell_Delegate: AnyObject {
    func playButtonTapped(cell: AudioFile_TableViewCell)
    func trashButtonTapped(cell: AudioFile_TableViewCell) // Delegate method for trash button
    func editButtonTapped(cell: AudioFile_TableViewCell) // Delegate method for edit button
}

class AudioFile_TableViewCell: UITableViewCell {
    
    var playButton: UIButton!
    var trashButton: UIButton! // New trash button
    var editButton: UIButton! // New edit button
    weak var delegate: AudioFile_TableViewCell_Delegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupPlayButton()
        setupTrashButton() // Setup the trash button
        setupEditButton() // Setup the edit button
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupPlayButton()
        setupTrashButton() // Setup the trash button
        setupEditButton() // Setup the edit button
    }

    private func setupPlayButton() {
           playButton = UIButton(type: .system)
           playButton.setImage(UIImage(systemName: "play"), for: .normal)
           playButton.setImage(UIImage(systemName: "play.fill"), for: .selected)
           contentView.addSubview(playButton)
           playButton.translatesAutoresizingMaskIntoConstraints = false
           NSLayoutConstraint.activate([
               playButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
               playButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
               playButton.heightAnchor.constraint(equalToConstant: 40),
               playButton.widthAnchor.constraint(equalToConstant: 40)
           ])
           // Add target and action for button if needed
           
           playButton.addAction(UIAction(title: "Button Title", handler: { _ in
               print("Button tapped!")
               self.playButtonTapped()
           }), for: .touchUpInside)
           
       }

    private func setupTrashButton() {
        trashButton = UIButton(type: .system)
        trashButton.setImage(UIImage(systemName: "trash"), for: .normal)
        contentView.addSubview(trashButton)
        trashButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            trashButton.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -20),
            trashButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            trashButton.heightAnchor.constraint(equalToConstant: 40),
            trashButton.widthAnchor.constraint(equalToConstant: 40)
        ])
        trashButton.addAction(UIAction(title: "Trash Button", handler: { _ in
            print("Trash button tapped!")
            self.trashButtonTapped()
        }), for: .touchUpInside)
    }

    private func setupEditButton() {
        editButton = UIButton(type: .system)
        editButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        contentView.addSubview(editButton)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            editButton.trailingAnchor.constraint(equalTo: trashButton.leadingAnchor, constant: -20),
            editButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            editButton.heightAnchor.constraint(equalToConstant: 40),
            editButton.widthAnchor.constraint(equalToConstant: 40)
        ])
        editButton.addAction(UIAction(title: "Edit Button", handler: { _ in
            print("Edit button tapped!")
            self.editButtonTapped()
        }), for: .touchUpInside)
    }

    func playButtonTapped() {
        playButton.isSelected = !playButton.isSelected
        delegate?.playButtonTapped(cell: self)
    }

    func trashButtonTapped() {
        delegate?.trashButtonTapped(cell: self) // Notify the delegate about the tap
    }

    func editButtonTapped() {
        delegate?.editButtonTapped(cell: self) // Notify the delegate about the tap
    }
}




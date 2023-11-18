//
//  AudioFile_TableViewCell.swift
//  TonePod
//
//  Created by Kyle-Anthony Hay on 11/18/23.
//

import UIKit

class AudioFile_TableViewCell: UITableViewCell {
    
    var playButton: UIButton!

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setupPlayButton()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setupPlayButton()
        }

        private func setupPlayButton() {
            playButton = UIButton(type: .system)
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal) 
            addSubview(playButton)
            playButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                playButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
                playButton.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            ])
            // Add target and action for button if needed
            // playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        }

}

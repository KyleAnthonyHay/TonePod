//
//  AudioFile_TableViewCell.swift
//  TonePod
//
//  Created by Kyle-Anthony Hay on 11/18/23.
//

import UIKit

protocol AudioFile_TableViewCell_Delegate: AnyObject {
    func playButtonTapped(cell: AudioFile_TableViewCell)
}


class AudioFile_TableViewCell: UITableViewCell {
    
    var playButton: UIButton!
    weak var delegate: AudioFile_TableViewCell_Delegate?//!!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupPlayButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupPlayButton()
    }
    
    func playButtonTapped() {
        playButton.isSelected = !playButton.isSelected 
        delegate?.playButtonTapped(cell: self)
    }
    
    // private functions
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
    
    

}

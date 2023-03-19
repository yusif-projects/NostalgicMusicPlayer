//
//  MusicPlayerCell.swift
//  Nostalgic Music Player
//
//  Created by Yusif Aliyev on 24.05.22.
//

import UIKit

class SongCell: UITableViewCell {
    
    @IBOutlet weak var labelSongTitle: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    
}

class AlbumCell: UITableViewCell {
    
    @IBOutlet weak var imageViewAlbumArtwork: UIImageView!
    @IBOutlet weak var labelAlbumTitle: UILabel!
    @IBOutlet weak var labelAlbumArtist: UILabel!
    
}

class AlbumItemCell: UICollectionViewCell {
    
    @IBOutlet weak var imageViewAlbumArtwork: UIImageView!
    
}

class ArtistCell: UITableViewCell {
    
    @IBOutlet weak var labelArtist: UILabel!
    
}

class AlbumSongCell: UITableViewCell {
    
    @IBOutlet weak var trackNumber: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
}

class AlbumMainCell: UITableViewCell {
    
    @IBOutlet weak var artworkView: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
}

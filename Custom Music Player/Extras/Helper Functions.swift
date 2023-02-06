//
//  Helper Functions.swift
//  Custom Music Player
//
//  Created by Yusif Aliyev on 25.05.22.
//

import UIKit
import MediaPlayer
import AVFoundation
import Haptico

extension UIViewController {
    
    func showAlert(_ message: String) {
        let controller = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        controller.addAction(action)
        self.present(controller, animated: true, completion: nil)
    }
    
}

extension MPMediaItem {
    
    func convertToSongItem() -> SongItem {
        let albumTitle = self.value(forProperty: MPMediaItemPropertyAlbumTitle) as? String ?? ""
        let artist = self.value(forProperty: MPMediaItemPropertyArtist) as? String ?? ""
        let songTitle = self.value(forProperty: MPMediaItemPropertyTitle) as? String ?? ""
        let songID = self.value(forProperty: MPMediaItemPropertyPersistentID) as! NSNumber
        let composer = self.value(forProperty: MPMediaItemPropertyComposer) as? String ?? ""
        let genre = self.value(forProperty: MPMediaItemPropertyGenre) as? String ?? ""
        let lyrics = self.value(forProperty: MPMediaItemPropertyLyrics) as? String ?? ""
        let rating = self.value(forProperty: MPMediaItemPropertyRating) as! NSNumber
        let comments = self.value(forProperty: MPMediaItemPropertyComments) as? String ?? ""
        let playCount = self.value(forProperty: MPMediaItemPropertyPlayCount) as! NSNumber
        let discCount = self.value(forProperty: MPMediaItemPropertyDiscCount) as! NSNumber
        let discNumber = self.value(forProperty: MPMediaItemPropertyDiscNumber) as! NSNumber
        let skipCount = self.value(forProperty: MPMediaItemPropertySkipCount) as! NSNumber
        let albumArtist = self.value(forProperty: MPMediaItemPropertyAlbumArtist) as? String ?? ""
        let grouping = self.value(forProperty: MPMediaItemPropertyUserGrouping) as? String ?? ""
        let isCompilation = self.value(forProperty: MPMediaItemPropertyIsCompilation) as! Bool
        let trackCount = self.value(forProperty: MPMediaItemPropertyAlbumTrackCount) as! NSNumber
        let trackNumber = self.value(forProperty: MPMediaItemPropertyAlbumTrackNumber) as! NSNumber
        let lastPlayed = self.value(forProperty: MPMediaItemPropertyLastPlayedDate) as? String ?? ""
        let bpm = self.value(forProperty: MPMediaItemPropertyBeatsPerMinute) as! NSNumber
        let duration = self.value(forProperty: MPMediaItemPropertyPlaybackDuration) as! NSNumber
        let artwork = self.value(forProperty: MPMediaItemPropertyArtwork) as? String ?? ""
        let albumID = self.value(forProperty: MPMediaItemPropertyAlbumPersistentID) as! NSNumber
        let genreID = self.value(forProperty: MPMediaItemPropertyGenrePersistentID) as! NSNumber
        let artistID = self.value(forProperty: MPMediaItemPropertyArtistPersistentID) as! NSNumber
        let composerID = self.value(forProperty: MPMediaItemPropertyComposerPersistentID) as! NSNumber
        let albumArtistID = self.value(forProperty: MPMediaItemPropertyAlbumArtistPersistentID) as! NSNumber
        let dateAdded = self.value(forProperty: MPMediaItemPropertyDateAdded) as! Date
        let url = self.value(forProperty: MPMediaItemPropertyAssetURL) as! URL
        
        let songItem: SongItem = SongItem(songID: songID, artistID: artistID, albumID: albumID, albumArtistID: albumArtistID, composerID: composerID, genreID: genreID, songTitle: songTitle, artist: artist, composer: composer, genre: genre, trackNumber: trackNumber, trackCount: trackCount, albumTitle: albumTitle, albumArtist: albumArtist, artwork: artwork, discNumber: discNumber, discCount: discCount, duration: duration, playCount: playCount, skipCount: skipCount, rating: rating, bpm: bpm, lastPlayed: lastPlayed, dateAdded: dateAdded, isCompilation: isCompilation, lyrics: lyrics, grouping: grouping, comments: comments, url: url)
        
        return songItem
    }
    
}

extension String {
    
    func isLetter() -> Bool {
        let alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
        
        if alphabet.contains(self) {
            return true
        }
        
        return false
    }
    
}

func generateHapticFeedback() {
    Haptico.shared().generate(.medium)
}

func getDuration(value: Double) -> String {
    var result = ""
    
    let d = value
    
    let hours = Int(d / 3600)
    let minutes = Int(d / 60) - hours * 60
    let seconds = Int((d - Double(minutes * 60) - Double(hours * 3600)).rounded())
    
    if hours == 0 {
        result = "\(addZeroPadding(value: minutes)):\(addZeroPadding(value: seconds))"
    } else {
        result = "\(addZeroPadding(value: hours)):\(addZeroPadding(value: minutes)):\(addZeroPadding(value: seconds))"
    }
    
    return result
}

func addZeroPadding(value: Int) -> String {
    if value < 10 {
        return "0\(value)"
    } else {
        return "\(value)"
    }
}

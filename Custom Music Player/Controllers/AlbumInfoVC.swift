//
//  AlbumInfoVC.swift
//  Custom Music Player
//
//  Created by Yusif Aliyev on 28.05.22.
//

import UIKit
import MediaPlayer

class AlbumInfoVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nowPlayingButtonView: UIStackView!
    @IBOutlet weak var nowPlayingButton: UIButton!
    
    var songsVC: SongsVC!
    var albumsVC: AlbumsVC!
    var items = [[MPMediaItem]]()
    var discCount: Int = 0
    var songCount: Int = 0
    var thisAlbumId: MPMediaEntityPersistentID!
    var totalDuration: TimeInterval = 0
    var selectedRow = 0
    var selectedSection = 0
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        
        appDelegate.activeVC = self
        
        tableView.sectionHeaderTopPadding = 0
        
        getSongs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkNowPlayingButton()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if appDelegate.audioPlayer?.isPlaying == false {
            appDelegate.activeAlbum = ([], (0,0))
        }
    }
    
    func getSongs() {
        items.removeAll()
        let allSongs = MPMediaQuery.songs().items ?? []
        
        var songs = [MPMediaItem]()
        
        for song in allSongs {
            if song.albumPersistentID == thisAlbumId {
                songs.append(song)
                totalDuration = totalDuration + song.playbackDuration
                songCount = songCount + 1
            }
        }
        
        for _ in 0 ..< songs.first!.discCount {
            items.append([])
        }
        
        for song in songs {
            items[song.discNumber - 1].append(song)
        }
        
        for i in 0 ..< items.count {
            items[i].sort { a, b in
                return a.albumTrackNumber < b.albumTrackNumber
            }
        }
        
        discCount = items.count
        
        tableView.reloadData()
    }
    
    @IBAction func nowPlayingButtonPressed(_ sender: Any) {
        generateHapticFeedback()
        performSegue(withIdentifier: "to_PlaybackVC", sender: self)
    }
    
}

extension AlbumInfoVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return discCount + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return items[section - 1].count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumMainCell") as! AlbumMainCell
            let song = items.first?.first
            cell.artworkView.image = song?.artwork?.image(at: CGSize(width: 300, height: 300))
            cell.titleLabel.text = song?.albumTitle
            cell.artistLabel.text = song?.albumArtist
            cell.genreLabel.text = song?.genre
            let duration = getDuration(value: totalDuration)
            if duration.split(separator: ":").count == 3 {
                cell.durationLabel.text = "\(songCount) songs, \(duration) hours"
            } else {
                cell.durationLabel.text = "\(songCount) songs, \(duration) minutes"
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumSongCell") as! AlbumSongCell
            let song = items[indexPath.section-1][indexPath.row]
            cell.durationLabel.text = song.convertToSongItem().getDuration()
            cell.titleLabel.text = song.title
            cell.trackNumber.text = "\(song.albumTrackNumber)"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") as! CategoryCell
            cell.labelTitle.text = "Disc \(section)"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section > 0 {
            selectedSection = indexPath.section-1
            selectedRow = indexPath.row
            
            playSong()
        }
    }
    
    func playSong() {
        generateHapticFeedback()
        appDelegate.activeItem = items[selectedSection][selectedRow]
        appDelegate.audioPlayer?.stop()
        appDelegate.audioPlayer = try! AVAudioPlayer(contentsOf: appDelegate.activeItem.assetURL!)
        appDelegate.audioPlayer.prepareToPlay()
        appDelegate.audioPlayer.numberOfLoops = -1
        appDelegate.audioPlayer.play()
        checkNowPlayingButton()
        
        appDelegate.activeAlbum = (items, (selectedRow, selectedSection))
        
        songsVC.checkNowPlayingButton()
        
        if albumsVC != nil {
            albumsVC.checkNowPlayingButton()
        }
        
        checkNowPlayingButton()
        
        performSegue(withIdentifier: "to_PlaybackVC", sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 150
        }
        
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return 32
        }
    }
    
    func checkNowPlayingButton() {
        if appDelegate.activeItem != nil {
            nowPlayingButtonView.isHidden = false
            nowPlayingButton.isEnabled = true
        } else {
            nowPlayingButtonView.isHidden = true
            nowPlayingButton.isEnabled = false
        }
    }
}

//
//  CustomTabBarVC.swift
//  Custom Music Player
//
//  Created by Yusif Aliyev on 25.05.22.
//

import UIKit
import MediaPlayer

class CustomTabBarVC: UIViewController {
    
    var embeddedController: UIViewController!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var playlistBG: UIView!
    @IBOutlet weak var artistsBG: UIView!
    @IBOutlet weak var songsBG: UIView!
    @IBOutlet weak var albumsBG: UIView!
    @IBOutlet weak var moreBG: UIView!
    
    @IBOutlet weak var playlistIcon: UIImageView!
    @IBOutlet weak var artistsIcon: UIImageView!
    @IBOutlet weak var songsIcon: UIImageView!
    @IBOutlet weak var albumsIcon: UIImageView!
    @IBOutlet weak var moreIcon: UIImageView!
    
    var playlistIsSelected: Bool = false
    var artistsIsSelected: Bool = false
    var songsIsSelected: Bool = true
    var albumsIsSelected: Bool = false
    var moreIsSelected: Bool = false
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var songsVC: SongsVC!
    
    var selectedTab: Int = 2
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        
        songsVC = (appDelegate.activeVC as! SongsVC)
        songsVC.tabVC = self
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowAirPlay])
            print("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            print("Session is Active")
        } catch {
            print(error)
        }
        
        selectTab(tag: selectedTab)
    }
    
    @IBAction func tabPressed(_ sender: UIButton) {
        if sender.tag != selectedTab {
            generateHapticFeedback()
            selectTab(tag: sender.tag)
            selectedTab = sender.tag
        }
    }
    
    func selectTab(tag: Int) {
        switch tag {
        case 1:
            playlistIsSelected = true
            artistsIsSelected = false
            songsIsSelected = false
            albumsIsSelected = false
            moreIsSelected = false
            
            playlistBG.backgroundColor = playlistBG.backgroundColor?.withAlphaComponent(0.15)
            artistsBG.backgroundColor = artistsBG.backgroundColor?.withAlphaComponent(0)
            songsBG.backgroundColor = songsBG.backgroundColor?.withAlphaComponent(0)
            albumsBG.backgroundColor = albumsBG.backgroundColor?.withAlphaComponent(0)
            moreBG.backgroundColor = moreBG.backgroundColor?.withAlphaComponent(0)
            
        case 2:
            playlistIsSelected = false
            artistsIsSelected = true
            songsIsSelected = false
            albumsIsSelected = false
            moreIsSelected = false
            
            playlistBG.backgroundColor = playlistBG.backgroundColor?.withAlphaComponent(0)
            artistsBG.backgroundColor = artistsBG.backgroundColor?.withAlphaComponent(0.15)
            songsBG.backgroundColor = songsBG.backgroundColor?.withAlphaComponent(0)
            albumsBG.backgroundColor = albumsBG.backgroundColor?.withAlphaComponent(0)
            moreBG.backgroundColor = moreBG.backgroundColor?.withAlphaComponent(0)
        case 3:
            playlistIsSelected = false
            artistsIsSelected = false
            songsIsSelected = true
            albumsIsSelected = false
            moreIsSelected = false
            
            playlistBG.backgroundColor = playlistBG.backgroundColor?.withAlphaComponent(0)
            artistsBG.backgroundColor = artistsBG.backgroundColor?.withAlphaComponent(0)
            songsBG.backgroundColor = songsBG.backgroundColor?.withAlphaComponent(0.15)
            albumsBG.backgroundColor = albumsBG.backgroundColor?.withAlphaComponent(0)
            moreBG.backgroundColor = moreBG.backgroundColor?.withAlphaComponent(0)
        case 4:
            playlistIsSelected = false
            artistsIsSelected = false
            songsIsSelected = false
            albumsIsSelected = true
            moreIsSelected = false
            
            playlistBG.backgroundColor = playlistBG.backgroundColor?.withAlphaComponent(0)
            artistsBG.backgroundColor = artistsBG.backgroundColor?.withAlphaComponent(0)
            songsBG.backgroundColor = songsBG.backgroundColor?.withAlphaComponent(0)
            albumsBG.backgroundColor = albumsBG.backgroundColor?.withAlphaComponent(0.15)
            moreBG.backgroundColor = moreBG.backgroundColor?.withAlphaComponent(0)
        case 5:
            playlistIsSelected = false
            artistsIsSelected = false
            songsIsSelected = false
            albumsIsSelected = false
            moreIsSelected = true
            
            playlistBG.backgroundColor = playlistBG.backgroundColor?.withAlphaComponent(0)
            artistsBG.backgroundColor = artistsBG.backgroundColor?.withAlphaComponent(0)
            songsBG.backgroundColor = songsBG.backgroundColor?.withAlphaComponent(0)
            albumsBG.backgroundColor = albumsBG.backgroundColor?.withAlphaComponent(0)
            moreBG.backgroundColor = moreBG.backgroundColor?.withAlphaComponent(0.15)
        default:
            break
        }
        
        checkTabIcons()
    }
    
    func checkTabIcons() {
        if playlistIsSelected {
            playlistIcon.image = UIImage(named: "playlists-selected")!
            songsVC.tabNumber = 1
            songsVC.topLabel.text = "Playlists"
        } else {
            playlistIcon.image = UIImage(named: "playlists-deselected")!
        }
        
        if artistsIsSelected {
            artistsIcon.image = UIImage(named: "artists-selected")!
            songsVC.tabNumber = 2
            songsVC.topLabel.text = "Artists"
        } else {
            artistsIcon.image = UIImage(named: "artists-deselected")!
        }
        
        if songsIsSelected {
            songsIcon.image = UIImage(named: "songs-selected")!
            songsVC.tabNumber = 3
            songsVC.topLabel.text = "Songs"
        } else {
            songsIcon.image = UIImage(named: "songs-deselected")!
        }
        
        if albumsIsSelected {
            albumsIcon.image = UIImage(named: "albums-selected")!
            songsVC.tabNumber = 4
            songsVC.topLabel.text = "Albums"
        } else {
            albumsIcon.image = UIImage(named: "albums-deselected")!
        }
        
        if moreIsSelected {
            moreIcon.image = UIImage(named: "more-selected")!
            songsVC.tabNumber = 5
            songsVC.topLabel.text = "More"
        } else {
            moreIcon.image = UIImage(named: "more-deselected")!
        }
        
        DispatchQueue.main.async {
            self.songsVC.tableView.reloadData()
        }
    }
    
    func goToPlayback() {
        generateHapticFeedback()
        performSegue(withIdentifier: "to_PlaybackVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "to_PlaybackVC" {
            if let destination = segue.destination as? PlaybackVC {
                destination.tabVC = self
            }
        }
    }
    
}

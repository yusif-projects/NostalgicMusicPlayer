//
//  PlaybackVC.swift
//  Custom Music Player
//
//  Created by Yusif Aliyev on 27.05.22.
//

import UIKit
import MediaPlayer
import AVFoundation
import Haptico

class PlaybackVC: UIViewController {
    
    @IBOutlet weak var albumCoverView: UIImageView!
    @IBOutlet weak var playButtonImageView: UIImageView!
    @IBOutlet weak var songProgressSlider: UISlider!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var albumTitleLabel: UILabel!
    @IBOutlet weak var songProgressLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var lyricsView: UIVisualEffectView!
    @IBOutlet weak var lyricsTextView: UITextView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var tabVC: CustomTabBarVC!
    var duration: Double!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        
        songProgressSlider.minimumValue = 0
        songProgressSlider.isUserInteractionEnabled = false
        songProgressSlider.minimumTrackTintColor = .white
        
        lyricsTextView.textContainerInset = UIEdgeInsets(top: 25, left: 0, bottom: 25, right: 0)
        
        songProgressSlider.setThumbImage(UIImage(named: "slider-thumb-image"), for: .normal)
        
        updateUI()
    }
    
    @IBAction func toggleLyrics(_ sender: Any) {
        generateHapticFeedback()
        lyricsView.isHidden.toggle()
    }
    
    @IBAction func toggleInfo(_ sender: Any) {
        generateHapticFeedback()
        
        if let customAlert = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "CustomAlert") as? CustomAlert {
            customAlert.songItem = appDelegate.activeItem!.convertToSongItem()
            self.present(customAlert, animated: false)
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
            if motion == .motionShake {
                Haptico.shared().generate(.success)
                if appDelegate.activeAlbum.0.isEmpty {
                    tabVC.songsVC.shuffle()
                    updateUI()
                } else {
                    self.shuffle()
                    updateUI()
                }
            }
        }
    
    func shuffle() {
        let selectedSection = Int.random(in: 0 ... sectionAmmount() - 1)
        let selectedRow = Int.random(in: 0 ... songAmmount(in: selectedSection) - 1)
        
        appDelegate.activeAlbum.1.0 = selectedRow
        appDelegate.activeAlbum.1.1 = selectedSection
        
        playSong()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { timer in
            self.songProgressSlider.value = Float(self.appDelegate.audioPlayer.currentTime)
            self.songProgressLabel.text = getDuration(value: self.appDelegate.audioPlayer.currentTime)
            self.durationLabel.text = getDuration(value: self.duration - self.appDelegate.audioPlayer.currentTime)
        }
    }
    
    func updateUI() {
        let item = appDelegate.activeItem!
        checkPlayButton()
        lyricsTextView.text = item.lyrics ?? ""
        songTitleLabel.text = item.title ?? ""
        albumTitleLabel.text = item.albumTitle ?? ""
        artistLabel.text = item.artist ?? ""
        durationLabel.text = item.convertToSongItem().getDuration()
        albumCoverView.image = item.artwork?.image(at: CGSize(width: 500, height: 500))
        songProgressSlider.value = Float(appDelegate.audioPlayer.currentTime)
        songProgressLabel.text = getDuration(value: appDelegate.audioPlayer.currentTime)
        duration = item.playbackDuration
        durationLabel.text = getDuration(value: duration - appDelegate.audioPlayer.currentTime)
        songProgressSlider.maximumValue = Float(duration)
    }
    
    func checkPlayButton() {
        if appDelegate.audioPlayer.isPlaying {
            playButtonImageView.image = UIImage(named: "pause")!
        } else {
            playButtonImageView.image = UIImage(named: "play")!
        }
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        generateHapticFeedback()
        if appDelegate.audioPlayer.isPlaying {
            appDelegate.audioPlayer.pause()
        } else {
            appDelegate.audioPlayer.play()
        }
        
        checkPlayButton()
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        generateHapticFeedback()
        if appDelegate.activeAlbum.0.isEmpty {
            tabVC.songsVC.selectNextSong()
            updateUI()
        } else {
            selectNextSong()
            updateUI()
        }
    }
    
    @IBAction func previousButtonPressed(_ sender: Any) {
        generateHapticFeedback()
        if appDelegate.activeAlbum.0.isEmpty {
            tabVC.songsVC.selectPreviousSong()
            updateUI()
        } else {
            selectPreviousSong()
            updateUI()
        }
    }
    
    @IBAction func songProgressSliderChangedValue(_ sender: Any) {
        
    }
    
    func songAmmount(in section: Int) -> Int {
        return appDelegate.activeAlbum.0[section].count
    }
    
    func sectionAmmount() -> Int {
        return appDelegate.activeAlbum.0.count
    }
    
    func selectNextSong() {
        var selectedSection = appDelegate.activeAlbum.1.1
        var selectedRow = appDelegate.activeAlbum.1.0
        
        if selectedRow == songAmmount(in: selectedSection) - 1 {
            selectedRow = 0
            
            if selectedSection == sectionAmmount() - 1 {
                selectedSection = 0
            } else {
                selectedSection = selectedSection + 1
            }
        } else {
            selectedRow = selectedRow + 1
        }
        
        appDelegate.activeAlbum.1.0 = selectedRow
        appDelegate.activeAlbum.1.1 = selectedSection
        
        playSong()
    }
    
    func selectPreviousSong() {
        var selectedSection = appDelegate.activeAlbum.1.1
        var selectedRow = appDelegate.activeAlbum.1.0
        
        if selectedSection == 0 {
            if selectedRow == 0 {
                selectedSection = sectionAmmount() - 1
                selectedRow = songAmmount(in: selectedSection) - 1
            } else {
                selectedRow = selectedRow - 1
            }
        } else {
            if selectedRow == 0 {
                selectedSection = selectedSection - 1
                selectedRow = songAmmount(in: selectedSection) - 1
            } else {
                selectedRow = selectedRow - 1
            }
        }
        
        appDelegate.activeAlbum.1.0 = selectedRow
        appDelegate.activeAlbum.1.1 = selectedSection
        
        playSong()
    }
    
    func playSong() {
        generateHapticFeedback()
        appDelegate.activeItem = appDelegate.activeAlbum.0[appDelegate.activeAlbum.1.1][appDelegate.activeAlbum.1.0]
        appDelegate.audioPlayer?.stop()
        appDelegate.audioPlayer = try! AVAudioPlayer(contentsOf: appDelegate.activeItem.assetURL!)
        appDelegate.audioPlayer.prepareToPlay()
        appDelegate.audioPlayer.numberOfLoops = -1
        appDelegate.audioPlayer.play()
    }
    
}

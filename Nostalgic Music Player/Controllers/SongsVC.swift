import UIKit
import MediaPlayer
import AVFoundation
import Haptico

class SongsVC: PrototypeVC {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var nowPlayingButton: UIButton!
    @IBOutlet weak var nowPlayingStackView: UIStackView!
    
    var mediaProvider: MediaProvider = MediaProvider()
    
    var songs = [[String : [MPMediaItem]]]()
    var albums = [[String : [MPMediaItemCollection]]]()
    var albumArtists = [[String : [String]]]()
    
    var tabNumber: Int!
    var tabVC: CustomTabBarVC!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var selectedRow: Int!
    var selectedSection: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate.activeVC = self
        
        tableView.sectionHeaderTopPadding = 0
        tableView.sectionIndexColor = UIColor(red:0.42, green:0.45, blue:0.49, alpha:1.00)
        
        requestLibraryAuth()
    }
    
    func requestLibraryAuth() {
        MPMediaLibrary.requestAuthorization { (status) in
            if status == .authorized {
                self.reloadData()
            } else {
                self.displayMediaLibraryError()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkNowPlayingButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkNowPlayingButton()
    }
    
    func displayMediaLibraryError() {}
    
    func resetData() {
        self.albumArtists.removeAll()
        self.albums.removeAll()
        self.songs.removeAll()
    }
    
    func reloadData() {
        if self.albumArtists.isEmpty { self.albumArtists = self.mediaProvider.getAlbumArtists() }
        if self.songs.isEmpty { self.songs = self.mediaProvider.getSongs() }
        if self.albums.isEmpty { self.albums = self.mediaProvider.getAlbums() }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
        }
    }
    
    @IBAction func nowPlayingButtonPressed(_ sender: Any) {
        tabVC.goToPlayback()
    }
    
    func checkNowPlayingButton() {
        if appDelegate.activeItem != nil {
            nowPlayingStackView.isHidden = false
            nowPlayingButton.isEnabled = true
        } else {
            nowPlayingStackView.isHidden = true
            nowPlayingButton.isEnabled = false
        }
    }
    
    func shuffle() {
        selectedSection = Int.random(in: 0 ... sectionAmmount() - 1)
        selectedRow = Int.random(in: 0 ... songAmmount(in: selectedSection) - 1)
        
        appDelegate.activeItem = songs[selectedSection].values.first![selectedRow]
        appDelegate.audioPlayer = try! AVAudioPlayer(contentsOf: appDelegate.activeItem.assetURL!)
        appDelegate.audioPlayer.prepareToPlay()
        appDelegate.audioPlayer.numberOfLoops = -1
        appDelegate.audioPlayer.stop()
        appDelegate.audioPlayer.play()
        checkNowPlayingButton()
    }
    
    func songAmmount(in section: Int) -> Int {
        return songs[section].values.first!.count
    }
    
    func sectionAmmount() -> Int {
        return songs.count
    }
    
    func selectNextSong() {
        switch tabNumber {
        case 3:
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
            
            appDelegate.activeItem = songs[selectedSection].values.first![selectedRow]
            appDelegate.audioPlayer.stop()
            appDelegate.audioPlayer = try! AVAudioPlayer(contentsOf: appDelegate.activeItem.assetURL!)
            appDelegate.audioPlayer.prepareToPlay()
            appDelegate.audioPlayer.numberOfLoops = -1
            appDelegate.audioPlayer.play()
        default:
            break
        }
    }
    
    func selectPreviousSong() {
        switch tabNumber {
        case 3:
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
            
            appDelegate.activeItem = songs[selectedSection].values.first![selectedRow]
            appDelegate.audioPlayer.stop()
            appDelegate.audioPlayer = try! AVAudioPlayer(contentsOf: appDelegate.activeItem.assetURL!)
            appDelegate.audioPlayer.prepareToPlay()
            appDelegate.audioPlayer.numberOfLoops = -1
            appDelegate.audioPlayer.play()
        default:
            break
        }
    }
}

extension SongsVC: UITableViewDelegate, UITableViewDataSource {
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var titles = [String]()

        switch tabNumber {
        case 2:
            let data = albumArtists
            for group in data {
                titles.append(group.keys.first!)
            }
        case 4:
            let data = albums
            for group in data {
                titles.append(group.keys.first!)
            }
        default:
            let data = songs
            for group in data {
                titles.append(group.keys.first!)
            }
        }

        return titles
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch tabNumber {
        case 3:
            return songs.count
        case 4:
            return albums.count
        case 2:
            return albumArtists.count
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int  {
        switch tabNumber {
        case 3:
            return self.songs[section].values.first!.count
        case 4:
            return self.albums[section].values.first!.count
        case 2:
            return self.albumArtists[section].values.first!.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell {
        switch tabNumber {
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistCell", for: indexPath) as! ArtistCell
            let mediaItemCollection = albumArtists[indexPath.section].values.first![indexPath.row]
            cell.labelArtist.text = mediaItemCollection
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell", for: indexPath) as! AlbumCell
            let mediaItemCollection = albums[indexPath.section].values.first![indexPath.row]
            cell.labelAlbumTitle.text = mediaItemCollection.items.first?.albumTitle ?? ""
            cell.labelAlbumArtist?.text = mediaItemCollection.items.first?.albumArtist ?? ""
            cell.imageViewAlbumArtwork.image = mediaItemCollection.items.first?.artwork?.image(at: CGSize(width: 100, height: 100))
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongCell
            let mediaItem = songs[indexPath.section].values.first![indexPath.row]
            cell.labelSongTitle.text = mediaItem.title ?? ""
            cell.labelDescription.text = "\(mediaItem.albumTitle ?? "") – \(mediaItem.artist ?? "")"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch tabNumber {
        case 2:
            let view = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") as! CategoryCell
            view.labelTitle.text = albumArtists[section].keys.first!
            return view
        case 4:
            let view = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") as! CategoryCell
            view.labelTitle.text = albums[section].keys.first!
            return view
        default:
            let view = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") as! CategoryCell
            view.labelTitle.text = songs[section].keys.first!
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        selectedSection = indexPath.section
        
        switch tabNumber {
        case 2:
            generateHapticFeedback()
            
            let albumArtist = albumArtists[selectedSection].values.first![selectedRow]
            
            performSegue(withIdentifier: "to_AlbumsVC", sender: albumArtist)
        case 4:
            generateHapticFeedback()
            performSegue(withIdentifier: "to_AlbumInfoVC", sender: self)
        case 3:
            generateHapticFeedback()
            appDelegate.activeItem = songs[selectedSection].values.first![selectedRow]
            appDelegate.audioPlayer = try! AVAudioPlayer(contentsOf: appDelegate.activeItem.assetURL!)
            appDelegate.audioPlayer.prepareToPlay()
            appDelegate.audioPlayer.numberOfLoops = -1
            appDelegate.audioPlayer.stop()
            appDelegate.audioPlayer.play()
            checkNowPlayingButton()
            
            appDelegate.activeAlbum = ([], (0,0))
            
            tabVC.goToPlayback()
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "to_AlbumInfoVC" {
            if let destination = segue.destination as? AlbumInfoVC {
                destination.songsVC = self
                destination.thisAlbumId = albums[selectedSection].values.first![selectedRow].items.first!.albumPersistentID
            }
        } else if segue.identifier == "to_AlbumsVC" {
            if let destination = segue.destination as? AlbumsVC {
                destination.songsVC = self
                destination.tabVC = self.tabVC
                
                if let albumArtist = sender as? String {
                    destination.albumArtist = albumArtist
                }
            }
        }
    }
    
}

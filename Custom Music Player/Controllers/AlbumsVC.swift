import UIKit
import MediaPlayer
import AVFoundation

class AlbumsVC: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var nowPlayingButton: UIButton!
    @IBOutlet weak var nowPlayingStackView: UIStackView!
    
    var mediaProvider: MediaProvider = MediaProvider()
    
    var albums = [MPMediaItemCollection]()
    
    var albumArtist: String!
    
    var songsVC: SongsVC!
    var tabVC: CustomTabBarVC!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var selectedRow: Int!
    var selectedSection: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        
        appDelegate.activeVC = self
        
        setupCollectionView()
        
        reloadData()
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
    
    func reloadData() {
        if self.albums.isEmpty { self.albums = self.mediaProvider.getAlbums(albumArtist: albumArtist) }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
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
    
    func setupCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        
        let padding: CGFloat = 16
        
        flowLayout.itemSize.width = (view.frame.size.width - padding * 3) / 2
        flowLayout.itemSize.height = flowLayout.itemSize.width
        
        flowLayout.minimumLineSpacing = padding
        flowLayout.minimumInteritemSpacing = padding
        
        flowLayout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        
        collectionView.collectionViewLayout = flowLayout
    }
}

extension AlbumsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "albumItemCell", for: indexPath) as! AlbumItemCell
        let mediaItemCollection = albums[indexPath.item]
        cell.imageViewAlbumArtwork.image = mediaItemCollection.items.first?.artwork?.image(at: CGSize(width: 100, height: 100))
        
        cell.imageViewAlbumArtwork.layer.shadowColor = UIColor.black.cgColor
        cell.imageViewAlbumArtwork.layer.shadowRadius = 4
        cell.imageViewAlbumArtwork.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.imageViewAlbumArtwork.layer.shadowOpacity = 0.4
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedRow = indexPath.item
        
        DispatchQueue.main.async {
            generateHapticFeedback()
            self.performSegue(withIdentifier: "to_AlbumInfoVC", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "to_AlbumInfoVC" {
            if let destination = segue.destination as? AlbumInfoVC {
                destination.songsVC = self.songsVC
                destination.albumsVC = self
                destination.thisAlbumId = albums[selectedRow].items.first!.albumPersistentID
            }
        }
    }
    
}

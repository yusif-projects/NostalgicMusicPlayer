import Foundation
import MediaPlayer

struct SongItem {
    var songID: NSNumber
    var artistID: NSNumber
    var albumID: NSNumber
    var albumArtistID: NSNumber
    var composerID: NSNumber
    var genreID: NSNumber
    
    var songTitle: String
    var artist: String
    
    var composer: String
    var genre: String
    
    var trackNumber: NSNumber
    var trackCount: NSNumber
    
    var albumTitle: String
    var albumArtist: String
    var artwork: String
    
    var discNumber: NSNumber
    var discCount: NSNumber
    
    var duration: NSNumber
    var playCount: NSNumber
    var skipCount: NSNumber
    var rating: NSNumber
    var bpm: NSNumber
    var lastPlayed: String
    var dateAdded: Date
    
    var isCompilation: Bool
    
    var lyrics: String
    var grouping: String
    var comments: String
    
    var url: URL
    
    func info() -> String {
        var info = ""
        
        info.append("Disc \(discNumber) of \(discCount)\n")
        info.append("Track \(trackNumber) of \(trackCount)\n\n")
        
        info.append("From the \(genre) album \"\(albumTitle)\" by \(albumArtist)\n\n")
        
        info.append("Performed by \(artist)\n")
        info.append("Written by \(getComposers().1)\n\n")
        info.append("\(comments)")
        
        return info
    }
    
    func getDuration() -> String {
        return Nostalgic_Music_Player.getDuration(value: duration.doubleValue)
    }
    
    func getComposers() -> ([Substring.SubSequence], String) {
        if composer.contains("Arranged by") {
            let a = composer.replacingOccurrences(of: "Arranged by", with: "*")
            let b = a.split(separator: "*")[0]
            
            var composers = b.split(separator: "•")
            
            for i in 0 ..< composers.count {
                if composers[i].last == " " {
                    composers[i].removeLast()
                }
                
                if composers[i].first == " " {
                    composers[i].removeFirst()
                }
            }
            
            var string = ""
            
            for i in 0 ..< composers.count {
                switch i {
                case 0:
                    string = "\(composers[i])"
                case composers.count - 1:
                    string = "\(string) & \(composers[i])"
                default:
                    string = "\(string), \(composers[i])"
                }
            }
            
            return (composers, string)
        } else {
            var composers = composer.split(separator: "•")
            
            for i in 0 ..< composers.count {
                if composers[i].last == " " {
                    composers[i].removeLast()
                }
                
                if composers[i].first == " " {
                    composers[i].removeFirst()
                }
            }
            
            var string = ""
            
            for i in 0 ..< composers.count {
                switch i {
                case 0:
                    string = "\(composers[i])"
                case composers.count - 1:
                    string = "\(string) & \(composers[i])"
                default:
                    string = "\(string), \(composers[i])"
                }
            }
            
            return (composers, string)
        }
    }
}

struct SongGroup {
    var title: String
    var songs: [MPMediaItem]
}

enum SongGrouping {
    case artist, album, letters
}

class MediaProvider {
    
    func getSongs() -> [[String : [MPMediaItem]]] {
        var group = [[String : [MPMediaItem]]]()
        let songs: [MPMediaItem] = MPMediaQuery.songs().items ?? []
        
        var firstLetters: [String] = []
        
        for song in songs {
            let firstLetter = "\((song.title ?? "").first!)".uppercased()
            
            if firstLetters.contains(where: { letter in return letter.uppercased() == firstLetter }) == false {
                firstLetters.append(firstLetter)
            }
        }
        
        firstLetters.sort { a, b in
            return a < b
        }
        
        var specialSongArray = [MPMediaItem]()
        
        for letter in firstLetters {
            var songArray = [MPMediaItem]()
            
            for song in songs {
                if "\((song.title ?? "").first!)".uppercased() == letter {
                    if letter.isLetter() {
                        songArray.append(song)
                    } else {
                        specialSongArray.append(song)
                    }
                }
            }
            
            if letter.isLetter() {
                group.append([letter : songArray])
            }
        }
        
        if specialSongArray.count > 0 {
            group.append(["#" : specialSongArray])
        }
        
        return group
    }
    
    func getAlbums() -> [[String : [MPMediaItemCollection]]] {
        var group = [[String : [MPMediaItemCollection]]]()
        let albums: [MPMediaItemCollection] = MPMediaQuery.albums().collections ?? []
        
        var firstLetters: [String] = []
        
        for album in albums {
            let firstLetter = "\((album.items.first!.albumTitle ?? "").first!)".uppercased()
            
            if firstLetters.contains(where: { letter in return letter.uppercased() == firstLetter }) == false {
                firstLetters.append(firstLetter)
            }
        }
        
        firstLetters.sort { a, b in
            return a < b
        }
        
        var specialAlbumArray = [MPMediaItemCollection]()
        
        for letter in firstLetters {
            var albumArray = [MPMediaItemCollection]()
            
            for album in albums {
                if "\((album.items.first!.albumTitle ?? "").first!)".uppercased() == letter {
                    if letter.isLetter() {
                        albumArray.append(album)
                    } else {
                        specialAlbumArray.append(album)
                    }
                }
            }
            
            if letter.isLetter() {
                group.append([letter : albumArray])
            }
        }
        
        if specialAlbumArray.count > 0 {
            group.append(["#" : specialAlbumArray])
        }
        
        return group
    }
    
    func getAlbums(albumArtist: String) -> [MPMediaItemCollection] {
        var albums: [MPMediaItemCollection] = MPMediaQuery.albums().collections ?? []
        
        albums = albums.filter { a in
            return a.items.first?.albumArtist ?? "" == albumArtist
        }
        
        return albums
    }
    
    func getItem(songId: NSNumber) -> MPMediaItem {
        let property: MPMediaPropertyPredicate = MPMediaPropertyPredicate(value: songId, forProperty: MPMediaItemPropertyPersistentID)
        let query: MPMediaQuery = MPMediaQuery()
        query.addFilterPredicate(property)
        
        let items: [MPMediaItem] = query.items! as [MPMediaItem]
        return items.last!
    }
    
    func getAlbumArtists() -> [[String : [String]]] {
        var group = [[String : [String]]]()
        let albumCollections: [MPMediaItemCollection] = MPMediaQuery.albums().collections ?? []
        var albumArtists: [String] = []
        
        for albumCollection in albumCollections {
            if let albumArtist = albumCollection.items.first?.albumArtist {
                if albumArtists.contains(where: { temp in
                    return temp == albumArtist
                }) == false {
                    albumArtists.append(albumArtist)
                }
            }
        }
        
        albumArtists.sort { a, b in
            return a < b
        }
        
        var firstLetters: [String] = []
        
        for albumArtist in albumArtists {
            if albumArtist != "" {
                let firstLetter = albumArtist.first!.uppercased()
                
                if firstLetters.contains(where: { letter in return letter.uppercased() == firstLetter }) == false {
                    firstLetters.append(firstLetter)
                }
            }
        }
        
        firstLetters.sort { a, b in
            return a < b
        }
        
        var specialAlbumArtistArray = [String]()
        
        for letter in firstLetters {
            var albumArtistArray = [String]()
            
            for albumArtist in albumArtists {
                if albumArtist.first!.uppercased() == letter.uppercased() {
                    if letter.isLetter() {
                        if albumArtistArray.contains(where: { a in
                            return a == albumArtist
                        }) == false {
                            albumArtistArray.append(albumArtist)
                        }
                    } else {
                        if specialAlbumArtistArray.contains(where: { a in
                            return a == albumArtist
                        }) == false {
                            specialAlbumArtistArray.append(albumArtist)
                        }
                    }
                }
            }
            
            if letter.isLetter() {
                group.append([letter : albumArtistArray])
            }
        }
        
        if specialAlbumArtistArray.count > 0 {
            group.append(["#" : specialAlbumArtistArray])
        }
        
        return group
    }

    
}

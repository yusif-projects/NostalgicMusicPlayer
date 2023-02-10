//
//  CustomAlert.swift
//  Custom Music Player
//
//  Created by Yusif Aliyev on 09.02.23.
//

import UIKit

class CustomAlert: PrototypeVC {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    
    var songItem: SongItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundView.layer.cornerRadius = 8
        
        backgroundView.layer.borderColor = UIColor(red: 174/255, green: 180/255, blue: 193/255, alpha: 1).cgColor
        backgroundView.layer.borderWidth = 2
        
        backgroundView.clipsToBounds = true
        
        topLabel.text = songItem.songTitle
        bottomLabel.text = songItem.info()
        
        view.alpha = 0
        backgroundView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideSelf))
        self.view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.2, delay: 0) { [weak self] in
            if let strongSelf = self {
                strongSelf.view.alpha = 1
                strongSelf.backgroundView.transform = .identity
            }
        }
        
    }
    
    @objc func hideSelf() {
        UIView.animate(withDuration: 0.2, delay: 0) { [weak self] in
            if let strongSelf = self {
                strongSelf.view.alpha = 0
                strongSelf.backgroundView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            }
        } completion: { [weak self] _ in
            if let strongSelf = self {
                strongSelf.dismiss(animated: false)
            }
        }
    }
    
}

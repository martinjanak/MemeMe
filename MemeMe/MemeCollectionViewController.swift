//
//  MemeCollectionViewController.swift
//  MemeMe
//
//  Created by Martin Janák on 07/05/2017.
//  Copyright © 2017 Martin Janák. All rights reserved.
//

import UIKit

class MemeCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Sent Memes"
        
        let space:CGFloat = 3.0
        let isLandscape = UIDevice.current.orientation.isLandscape
        let frameSize = isLandscape ? view.frame.size.height : view.frame.size.width
        let dimension = (frameSize - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let memes = getMemes()
        
        if memes.count > 0 {
            collectionView.isHidden = false
            return memes.count
        } else {
            collectionView.isHidden = true
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let memes = getMemes()
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemeCollectionViewCell", for: indexPath) as! MemeCollectionViewCell
        let meme = memes[(indexPath as NSIndexPath).row]

        cell.imageView?.image = meme.memedImage
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        
        let memes = getMemes()
        
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
        detailController.meme = memes[(indexPath as NSIndexPath).row]
        self.navigationController!.pushViewController(detailController, animated: true)
    }
    
    @IBAction func addMeme(_ sender: Any) {
        addANewMeme()
    }
    
    @IBAction func noMemeAddMeme(_ sender: Any) {
        addANewMeme()
    }
    
    func addANewMeme() {
        let editorController = self.storyboard!.instantiateViewController(withIdentifier: "MemeEditorViewController") as! MemeEditorViewController
        self.navigationController!.present(editorController, animated: true, completion: nil)
    }
    
    func getMemes() -> [Meme] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.memes
    }

}

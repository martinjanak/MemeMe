//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by Martin Janák on 07/05/2017.
//  Copyright © 2017 Martin Janák. All rights reserved.
//

import UIKit

class MemeTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var memes: [Meme] = [Meme]()
    
    @IBOutlet weak var memeTableView: UITableView!
    @IBOutlet weak var noMemesView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Sent Memes"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadMemes()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.memes.count > 0 {
            memeTableView.isHidden = false
            return self.memes.count
        } else {
            memeTableView.isHidden = true
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemeTableViewCell") as! MemeTableViewCell
        let meme = self.memes[(indexPath as NSIndexPath).row]
        
        cell.tableLabel?.text = meme.topText+"... "+meme.bottomText
        cell.tableImageView?.image = meme.memedImage
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
        detailController.meme = self.memes[(indexPath as NSIndexPath).row]
        self.navigationController!.pushViewController(detailController, animated: true)
    }
    
    @IBAction func noMemeAddMeme(_ sender: Any) {
        addANewMeme()
    }
    @IBAction func addMeme(_ sender: Any) {
        addANewMeme()
    }
    
    func addANewMeme() {
        let editorController = self.storyboard!.instantiateViewController(withIdentifier: "MemeEditorViewController") as! MemeEditorViewController
        self.navigationController!.present(editorController, animated: true, completion: nil)
    }
    
    func loadMemes() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        memes = appDelegate.memes
        memeTableView.reloadData()
    }
    
}

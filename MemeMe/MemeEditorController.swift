//
//  ViewController.swift
//  MemeMe
//
//  Created by Martin Janák on 03/05/2017.
//  Copyright © 2017 Martin Janák. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var memeTextAttributes:[String:Any] = [
        NSStrokeColorAttributeName: UIColor.black,
        NSForegroundColorAttributeName: UIColor.white,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName: -3.6
    ]
    
    let topTextFieldDelegate = MemeTextFieldDelegate(defaultText: "TOP")
    let bottomTextFieldDelegate = MemeTextFieldDelegate(defaultText: "BOTTOM")
    
    @IBOutlet weak var imagePickerView: UIImageView!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDefaultValues()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        memeTextAttributes[NSParagraphStyleAttributeName] = paragraphStyle
        
        configureTextField(textField: topTextField, delegate: topTextFieldDelegate)
        configureTextField(textField: bottomTextField, delegate: bottomTextFieldDelegate)
    }
    
    func configureTextField(textField: UITextField, delegate: UITextFieldDelegate) {
        textField.defaultTextAttributes = memeTextAttributes
        textField.delegate = delegate
    }
    
    func setDefaultValues() {
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        imagePickerView.image = nil
        shareButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        shareButton.isEnabled = imagePickerView.image != nil
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        pickAnImage(.photoLibrary)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        pickAnImage(.camera)
    }
    
    func pickAnImage(_ sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter
            .default
            .addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter
            .default
            .addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter
            .default
            .removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter
            .default
            .removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func generateMemedImage() -> UIImage {
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let imageRatio = imagePickerView.image!.size.width/imagePickerView.image!.size.height
        let frameRatio = imagePickerView.frame.size.width/imagePickerView.frame.size.height
        
        if frameRatio > imageRatio {
            return cutLeftAndRightOf(image: memedImage)
        } else {
            return cutTopAndBottomOf(image: memedImage)
        }
    }
    
    @IBAction func share(_ sender: Any) {
        let memedImage = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        controller.completionWithItemsHandler = {(activityType, completed, returnedItems, error) in
            if completed {
                self.save(memedImage)
                self.dismiss(animated: true, completion: nil)
            }
        }
        self.present(controller, animated: true, completion: nil)
    }
    
    func save(_ memedImage:UIImage) {
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: memedImage)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memes.append(meme)
    }
    
    @IBAction func cancel(_ sender: Any) {
        setDefaultValues()
        self.dismiss(animated: true, completion: nil)
    }
    
    func cutTopAndBottomOf(image: UIImage) -> UIImage {
        let topFrameGap = imagePickerView.frame.origin.y
        let imageSizeX = imagePickerView.image!.size.width
        let imageSizeY = imagePickerView.image!.size.height
        let frameSizeX = imagePickerView.frame.size.width
        let frameSizeY = imagePickerView.frame.size.height
        let scale = frameSizeX/imageSizeX
        let scaledImageSizeX = scale * imageSizeX
        let scaledImageSizeY = scale * imageSizeY
        let imageGap = (frameSizeY - scaledImageSizeY)/2
        let topGap = CGFloat(topFrameGap + imageGap)
        let rect = CGRect(x: 0, y: topGap, width: scaledImageSizeX, height: scaledImageSizeY)
        return cropImage(image: image, toRect: rect)
    }
    
    func cutLeftAndRightOf(image: UIImage) -> UIImage {
        let leftFrameGap = imagePickerView.frame.origin.x
        let topFrameGap = imagePickerView.frame.origin.y
        let imageSizeX = imagePickerView.image!.size.width
        let imageSizeY = imagePickerView.image!.size.height
        let frameSizeX = imagePickerView.frame.size.width
        let frameSizeY = imagePickerView.frame.size.height
        let scale = frameSizeY/imageSizeY
        let scaledImageSizeX = scale * imageSizeX
        let scaledImageSizeY = scale * imageSizeY
        let imageGap = (frameSizeX - scaledImageSizeX)/2
        let leftGap = CGFloat(leftFrameGap + imageGap)
        let rect = CGRect(x: leftGap, y: topFrameGap, width: scaledImageSizeX, height: scaledImageSizeY)
        return cropImage(image: image, toRect: rect)
    }
    
    func cropImage(image:UIImage, toRect rect:CGRect) -> UIImage{
        let imageRef:CGImage = image.cgImage!.cropping(to: rect)!
        let croppedImage:UIImage = UIImage(cgImage:imageRef)
        return croppedImage
    }
    
}


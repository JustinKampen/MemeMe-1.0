//
//  MemeViewController.swift
//  MemeMe 1.0
//
//  Created by Justin Kampen on 12/29/18.
//  Copyright © 2018 Justin Kampen. All rights reserved.
//

import UIKit

// MARK: - MemeViewController: UIViewController

class MemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // MARK: Outlets and Properties
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var clearButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth: -3.0]
    
    // MARK: Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotications()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        imageView.image != nil ? navigationBarButtons(enabled: true) : navigationBarButtons(enabled: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMeme(textField: topTextField, withText: "TOP")
        setupMeme(textField: bottomTextField, withText: "BOTTOM")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: Helper Methods
    
    func setupMeme(textField: UITextField, withText: String) {
        textField.defaultTextAttributes = memeTextAttributes
        textField.backgroundColor = .clear
        textField.textAlignment = .center
        textField.text = withText
        textField.delegate = self
    }
    
    func navigationAndToolBar(isHidden: Bool) {
        navigationBar.isHidden = isHidden
        toolBar.isHidden = isHidden
    }
    
    func navigationBarButtons(enabled: Bool) {
        shareButton.isEnabled = enabled
        clearButton.isEnabled = enabled
    }
    
    func pickImage(from sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickImageFromCamera(_ sender: Any) {
        pickImage(from: .camera)
    }
    
    @IBAction func pickImageFromAlbums(_ sender: Any) {
        pickImage(from: .photoLibrary)
    }
    
    // MARK: Clear Button Funcionality
    
    @IBAction func clearImageAndText(_ sender: Any) {
        let alert = UIAlertController(title: "Are You Sure?", message: "You will lose any unsaved information.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            self.setupMeme(textField: self.topTextField, withText: "TOP")
            self.setupMeme(textField: self.bottomTextField, withText: "BOTTOM")
            self.imageView.image = nil
            self.navigationBarButtons(enabled: false)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    // MARK: ImagePicker Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Text Field Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if topTextField.text == "" {
            topTextField.text = "TOP"
            navigationBarButtons(enabled: false)
        } else if bottomTextField.text == "" {
            bottomTextField.text = "BOTTOM"
            navigationBarButtons(enabled: false)
        } else {
            navigationBarButtons(enabled: true)
        }
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Showing & Hiding Keyboard
    
    func subscribeToKeyboardNotications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(subscribeToKeyboardNotications(), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(subscribeToKeyboardNotications(), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if bottomTextField.isEditing {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    // MARK: Create Memed Image & Save/Share
    
    func save() {
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: generateMemedImage())
        print(meme)
        let alert = UIAlertController(title: "Meme Saved", message: "Your Meme has successfully been saved", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    func generateMemedImage() -> UIImage {
        navigationAndToolBar(isHidden: true)
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        navigationAndToolBar(isHidden: false)
        return memedImage
    }
    
    @IBAction func shareImage(_ sender: Any) {
        let memedImage = generateMemedImage()
        let activityView = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityView.completionWithItemsHandler = { (activity, completed, items, error) in
            if completed {
                self.save()
            }
        }
        present(activityView, animated: true, completion: nil)
    }
}

//
//  VC_Meme.swift
//  MemeMe
//
//  Created by Jeff on 8/28/17.
//  Copyright © 2017 JeffDeagostino. All rights reserved.
//

import UIKit
import Foundation

class VC_Meme: UIViewController, UINavigationControllerDelegate{
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var activityView: UIBarButtonItem!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    let memeTextAttributes:[String:Any] = [
        NSStrokeColorAttributeName: UIColor.black,
        NSForegroundColorAttributeName: UIColor.white,
        NSStrokeWidthAttributeName : -2.0,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 35)!
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedImageView.center = view.center
        activityView.isEnabled = false
        
        configTextField(textField: topTextField)
        configTextField(textField: bottomTextField)
    }
    
    func configTextField(textField: UITextField){
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        print("Device did rotate")
        coordinator.animate(alongsideTransition: { (_) in self.selectedImageView.center = self.view.center}, completion: nil)
    }
    
    
    /////////////    Cancel     /////////////
    @IBAction func cancelButton(_ sender: Any) {
        topTextField.text = "Type here . . ."
        bottomTextField.text = "Type here . . ."
        selectedImageView.image = nil
        activityView.isEnabled = false
    }
    
    //////////////     Notifications    /////////////
    func keyboardWillShow(_ notification:Notification) {
        
        if bottomTextField.isEditing{
            view.frame.origin.y = 0 - getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(_ notification:Notification) {
        
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }

    @IBAction func activityView(_ sender: Any) {
        let image = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        self.present(controller, animated: true, completion: nil)
        
        controller.completionWithItemsHandler = {
            (activity, success, items, error) in
            if(success && error == nil){
                //Do Work
                self.dismiss(animated: true, completion: nil);
                self.save()
            }
            else if (error != nil){
                //log the error
                print("Error completing activity view")
            }
        }
    }
    
    //////////////     create and save meme object    /////////////
    @IBAction func createNSave(_ sender: Any) {
        save()
    }
    struct Meme {
        let topText: String
        let bottomText: String
        let originalImage: UIImage
        let memedImage: UIImage
    }
    func save() {
        
        // Create the meme
        _ = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: selectedImageView.image!, memedImage: generateMemedImage())
        
        // Should I be doing something with this meme object?
        // How does it know to be saved in the album?
    }
    func generateMemedImage() -> UIImage {
        
        // hide toolbar and navbar
        hideBars(hide: true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // hide toolbar and navbar
        hideBars(hide: false)
        
        return memedImage
    }
    func hideBars(hide: Bool){
        navBar.isHidden = hide
        toolBar.isHidden = hide
    }
}

/////////////    ImagePicker Delegate     /////////////
extension VC_Meme:UIImagePickerControllerDelegate {
    
    // Tells the delegate that the user cancelled the pick operation
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        
    }
    @IBAction func pickFromAlbum(_ sender: Any) {
        
        configImagePicker(sourceType: .photoLibrary)
    
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        configImagePicker(sourceType: .camera)
        
    }
    
    func configImagePicker(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
        
        activityView.isEnabled = true
    }
    
    // Tells the delegate that the user picked a still image or movie.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImageView.image = image
            selectedImageView.contentMode = .scaleAspectFill
        }
        
        dismiss(animated: true, completion: nil)
    }
}

//////////////     TextField Delegate     //////////////
extension VC_Meme: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "Type here . . ." {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        //dismiss(animated: true, completion: nil)
        
        return true;
        
    }
    
    
}


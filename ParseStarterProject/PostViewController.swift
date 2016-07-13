//
//  PostViewController.swift
//  Instagram Final
//
//  Created by Darwing Medina on 13/4/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class PostViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate
{
    
    var photoSelected:Bool = false
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var imageToPost: UIImageView!
    
    @IBAction func chooseImage(sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        picker.allowsEditing = false
        picker.delegate = self
        
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        self.imageToPost.image = image
        picker.dismissViewControllerAnimated(true, completion: nil)
        photoSelected = true
        
        
    }
    
    @IBOutlet weak var shareText: UITextField!
    
    
    @IBAction func postImage(sender: AnyObject) {
        
        var error = ""
        
        if !photoSelected {
            error = "Por favor elige una imagen"
        }
        else if shareText == "" {
            error = "Por favor escribe algo de texto"
        }
        
        if error != "" {
            self.displayAlert("Error No se puede publicar", message: error)
        }
        else {
            
            let post = PFObject(className: "Post")
            post["title"] = self.shareText.text
            post["username"] = (PFUser.currentUser()?.username)!
            
            //Para guardar la imagen en Parse
            
            let smallSize = CGSizeMake(400, 400)
            
            UIGraphicsBeginImageContext(smallSize)
            
            // hacemos la imagen mas pequeña
            
            self.imageToPost.image?.drawInRect(CGRectMake(0, 0, smallSize.width, smallSize.height))
            
            let smallerImage = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();
            
            let imageData = UIImagePNGRepresentation(smallerImage!) // la convertimos a data
            // print(imageData?.length)
            let imageFile = PFFile(name: "image.png", data: imageData!) // creamos un archico PFFile
            post["imageFile"] = imageFile // guardamos el fichero en el servidor
            
            self.activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            self.shareText.enabled = false
            
            post.saveInBackgroundWithBlock({ (succes, error) -> Void in
                
                if succes {
                    self.displayAlert("Publicación completada", message: "Tu foto ha sido publicada con éxito")
                }
                else {
                    self.displayAlert("No se pudo publicar", message: String(error))
                }
                
                self.shareText.enabled = true

                
                self.photoSelected = false
                self.shareText.text = ""
                self.imageToPost.image = UIImage(named: "default-image.png")
                
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
            })
        }
        
    }
    
    
    func displayAlert(title:String, message:String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func logOut(sender: AnyObject) {
        PFUser.logOut()
        self.performSegueWithIdentifier("logOut", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator.stopAnimating()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

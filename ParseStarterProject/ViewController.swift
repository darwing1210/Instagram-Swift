/**
 * Copyright (c) 2015-present, Parse, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

import UIKit
import Parse

class ViewController: UIViewController,UINavigationControllerDelegate {
    
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var signToggleButton: UIButton!
    
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var instructionLabel: UILabel!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    var signUpActive = true
    
    
    let loading = UIActivityIndicatorView() // creamos el indicador de carga

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if PFUser.currentUser() != nil { // si ya hay un usuario logueado
            print("Usuario Logueado: " + (PFUser.currentUser()?.username)!)
            self.performSegueWithIdentifier("jumpToUsersTable", sender: self) // pasamos al view de tablas
        }
    }
    
    
    @IBAction func signUp(sender: AnyObject) {
        
        var error = ""
        
        if username.text == "" || password.text == ""{
            error = "Por Favor, introduce un usuario y contraseña"
        }
        else {
            
            loading.center = self.view.center // le decimos que la ponga al centro
            loading.hidesWhenStopped = true // que se oculte cuando se para
            loading.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray // definimos estilo
            loading.startAnimating() // que empieze la animacion
            
            self.view.addSubview(loading)  // lo agregamos a la vista principal
            
            UIApplication.sharedApplication().beginIgnoringInteractionEvents() // para que se bloquee la pantalla cuando cargamos
            
            if signUpActive {
            
                let user = PFUser()
                user.username = username.text
                user.password = password.text
                
                user.signUpInBackgroundWithBlock {
                    (succeeded: Bool, signUpError: NSError?) -> Void in
                    
                    self.loading.stopAnimating()
                    
                    UIApplication.sharedApplication().endIgnoringInteractionEvents() // para que vuelva a permitir la interaccion
                    
                    if signUpError == nil {
                        print("Usuario registrado")
                        self.performSegueWithIdentifier("jumpToUsersTable", sender: self) // pasamos al view de tablas

                        
                    } else {
                        if let errorString = signUpError!.userInfo["error"] as? NSString {
                            print("HUbo un error")
                            self.displayAlert("Error al registrar", message: String(errorString))
                        }
                    }
                }
            }
            else {
                PFUser.logInWithUsernameInBackground(self.username.text!, password: self.password.text!) {
                    (user: PFUser?, loginError: NSError?) -> Void in
                    
                     self.loading.stopAnimating()
                    
                    UIApplication.sharedApplication().endIgnoringInteractionEvents() // para que vuelva a permitir la interaccion

                    
                    if user != nil {
                        // Do stuff after successful login.
                        print("usuario ha podido acceder!")
                        self.performSegueWithIdentifier("jumpToUsersTable", sender: self) // pasamos al view de tablas

                        
                    } else {
                        // The login failed. Check error to see why.
                        if let errorString = loginError!.userInfo["error"] as? NSString {
                            self.displayAlert("Error al acceder", message: String(errorString))
                        }
                        else {
                            self.displayAlert("Error al acceder", message: "Por favor reintentalo")
                        }
                    }
                }
            }
            
        }
        
        if error != "" {
            displayAlert("Error en el formulario", message: error)
        }
        
    }
    
    
    @IBAction func signUpToggle(sender: AnyObject) { // metodo que cambia las etiquetas
        
        if signUpActive {
            // estoy en modo registro, voy a modo acceso
            signToggleButton.setTitle("Registrarse", forState: UIControlState.Normal)
            questionLabel.text = "No registrado?"
            signUpButton.setTitle("Acceder", forState: UIControlState.Normal)
            instructionLabel.text = "Usa el formulario para acceder"
            signUpActive = false
            
        }
        else {
            // estoy en modo acceso, voy a modo registro
            signToggleButton.setTitle("Acceder", forState: UIControlState.Normal)
            questionLabel.text = "Ya registrado?"
            signUpButton.setTitle("Registrar nuevo usuario", forState: UIControlState.Normal)
            instructionLabel.text = "Usa el formulario para registrarse"
            signUpActive = true

        }
        
    }
    
    
    func displayAlert (title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert) // alerta
        self.presentViewController(alert, animated: true, completion: nil) // la mostramos en el view
        alert.addAction(UIAlertAction(title: "Aceptar", style: .Default, handler: { (action) -> Void in // agregamos una accion
            self.dismissViewControllerAnimated(true, completion: nil) // que cierre luego
        }))
        
    }
    
    @IBAction func didLogOut (segue:UIStoryboardSegue) {
        print("logout")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

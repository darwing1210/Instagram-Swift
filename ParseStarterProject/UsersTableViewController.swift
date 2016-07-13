//
//  UsersTableViewController.swift
//  Instagram Final
//
//  Created by Darwing Medina on 13/4/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class UsersTableViewController: UITableViewController {
    
    var users = [String]()
    var following = [Bool] ()
    
    var refresher: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // para agregar el refresher
        
        self.refresher = UIRefreshControl()
        self.refresher.attributedTitle = NSAttributedString(string: "Arrastra para recargar")
        self.refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refresher)
        
        self.updateUsers()
        
    }
    
    func updateUsers() {
        // consulta para saber quienes son los seguidores
        
        let followingQuery = PFQuery(className:"followers")
        followingQuery.whereKey("follower", equalTo:(PFUser.currentUser()?.username)!)
        
        followingQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                // Do something with the found objects
                if let followingPeople = objects{
                    
                    // Consulta para saber los usuarios registrados
                    
                    let query = PFUser.query() // consulta de usuarios
                    query?.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in // metodo de busqueda de usuarios
                        
                        self.users.removeAll(keepCapacity: true) // vaciamos el arreglo de usuarios
                        self.following.removeAll(keepCapacity: true) // vaciamos el arreglo de seguidores

                        
                        for object in objects! { // si encontramos usuarios en nuestra consulta
                            let user:PFUser = object as! PFUser // usuario es el resultado de esa consulta
                            
                            if user.username != PFUser.currentUser()?.username {  // si el usuario obtenido no es el usuario logueado
                                self.users.append(user.username!) // agregamos el resultado a nuestro arreglo
                                
                                var isFollowing:Bool = false
                                
                                for followingPerson in followingPeople {
                                    if (followingPerson["following"] as? String) == user.username {
                                        isFollowing = true
                                    }
                                }
                                
                                self.following.append(isFollowing)
                                
                            }
                            
                        }
                        
                        self.tableView.reloadData()
                        self.refresher.endRefreshing()
                    })
                    
                    
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
                self.refresher.endRefreshing()

            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.users.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        // Configure the cell...
        
        cell.textLabel?.text = self.users[indexPath.row]
        
        if following[indexPath.row] { // si ya es un seguidor
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark // agregamos el checkmark
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryType.None // desmarcamos
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)! // cual es la celda seleccionada
        
        if cell.accessoryType == UITableViewCellAccessoryType.Checkmark { // si ya estaba marcado
            cell.accessoryType = UITableViewCellAccessoryType.None // desmarcamos
            
            let query = PFQuery(className:"followers")
            query.whereKey("follower", equalTo:(PFUser.currentUser()?.username)!)
            query.whereKey("following", equalTo: (cell.textLabel?.text)!)
            
            query.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    // The find succeeded.
                    // Do something with the found objects
                    if let delObject = objects{
                        for object in delObject {
                            print("Yo no eres seguidor de " + (cell.textLabel?.text)!)
                            object.deleteInBackgroundWithBlock(nil)
                        }
                    }
                } else {
                    // Log details of the failure
                    print("Error: \(error!) \(error!.userInfo)")
                }
            }
            
            
            
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark // agregamos el checkmark
            
            let following = PFObject(className: "followers")
            following["following"] = cell.textLabel?.text
            following["follower"] = PFUser.currentUser()?.username
            
            following.saveInBackgroundWithBlock(nil)
            
        }
    }
    
    func refresh() {
        self.updateUsers()
    }
    
}

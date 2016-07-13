//
//  UsersPostsTableViewController.swift
//  Instagram Final
//
//  Created by Darwing Medina on 14/4/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class UsersPostsTableViewController: UITableViewController {
    
    
    var titles = [String] ()
    var usernames = [String] ()
    var images = [PFFile] ()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // primera consulta - Obtener a los followers
        let getFollowerdQuery = PFQuery(className:"followers")
        getFollowerdQuery.whereKey("follower", equalTo:(PFUser.currentUser()?.username)!)

        getFollowerdQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                // Do something with the found objects
                if let objects = objects {
                    
                    var followedUser = ""
                    for object in objects {
                        followedUser = object["following"] as! String
                        
                        //segunda consulta
                        let query = PFQuery(className:"Post")
                        query.whereKey("username", equalTo: followedUser)
                        query.findObjectsInBackgroundWithBlock {
                            (postObjects: [PFObject]?, error: NSError?) -> Void in
                            
                            if error == nil {
                                
                                // Do something with the found objects
                                if let postObjects = postObjects {
                                    for findObjects in postObjects {
                                        self.titles.append(findObjects["title"] as! String)
                                        self.usernames.append(findObjects["username"] as! String)
                                        self.images.append(findObjects["imageFile"] as! PFFile)
                                        
                                        self.tableView.reloadData()
                                    }
                                }
                            } else {
                                print("Error: \(error!) \(error!.userInfo)")
                            }
                        }
                        
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
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
        return titles.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as! PostsCell // importante decirle que tipo de celda es
 
        cell.titleLabel.text = self.titles[indexPath.row]
        cell.userName.text = self.usernames[indexPath.row]
        
        self.images[indexPath.row].getDataInBackgroundWithBlock { (imageData:NSData?, error:NSError?) -> Void in
            
            if error == nil {
                let image = UIImage(data: imageData!)
                cell.postImage.image = image
                
            }
            else {
                print("Error al cargar la imagen en \(indexPath.row)")
            }
            
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 280
    }

}

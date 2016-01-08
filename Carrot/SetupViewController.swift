//
//  SetupViewController.swift
//  Carrot
//
//  Created by Kevin Kim on 1/7/16.
//  Copyright © 2016 Kevin Kim. All rights reserved.
//

import UIKit
import Parse

class SetupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var items : Item = Item()
    var index: Int = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hard coded account and customer id
        let accountId = "56241a14de4bf40b17112f02"
        let customerId = "56241a13de4bf40b1711224d"
        PFUser.currentUser()?.setObject(accountId, forKey: "account_id")
        PFUser.currentUser()?.setObject(customerId, forKey: "customer_id")
        PFUser.currentUser()!.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                print("success posting account and customer id")
                
                
                let currentUserID = PFUser.currentUser()?.objectId!
                print("Objectid: \(currentUserID)")
                
                
                PFCloud.callFunctionInBackground("processPurchases", withParameters: ["object_id" : currentUserID!]) { (returnData: AnyObject?, error: NSError?) -> Void in
                    if (error == nil) {
                        if let data = returnData {
                            self.items = Item()
                            let results = Utilities.convertStringToDictionary(data as! String)
                            
                            for (key,value) in results! {
                                var item_name: String = key
                                item_name = item_name.capitalizedString
                                let item_price: Double = value as! Double
                                
                                self.items.itemName.append(item_name)
                                self.items.price.append(item_price)
                            }
                            
                            self.tableView.reloadData()
                            
                        }
                    } else {
                        print("Totals Error = \(error)")
                    }
                }
                
                
                
                
                
            } else {
                print("failed posting account and customer id")
            }
        }
        
        
            }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Table View
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.itemName.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("topThreeCell", forIndexPath: indexPath) as! topThreeTableViewCell
        cell.descripLabel.text = items.itemName[indexPath.row]
        cell.priceLabel.text = Utilities.getCurrencyValue(items.price[indexPath.row])
        return cell
    }
    
    @IBAction func seeProfilePushed(sender: UIButton) {
        if let indexPath = tableView.indexPathForSelectedRow {
            index = indexPath.row
            performSegueWithIdentifier("seeProfile", sender: self)
        }
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "seeProfile") {
            let destVC = segue.destinationViewController as! MainViewController
            destVC.carrotName = items.itemName[index]
            destVC.carrotPrice = items.price[index]
        }
    }
    
}

struct Item {
    var itemName: [String] = []
    var price: [Double] = []
}

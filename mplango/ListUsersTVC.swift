//
//  ListUsersTVC.swift
//  mplango
//
//  Created by Carlos Wagner Pereira de Morais on 28/06/15.
//  Copyright (c) 2015 unb.br. All rights reserved.
//
import UIKit
import CoreData


class ListUsersTVC: UITableViewController {
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    let moContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var users = [MUser]()
    
    override func viewDidLoad() {
    super.viewDidLoad()
    //self.ttableView = delegate
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        tableView.estimatedRowHeight = 60
    }
    
    override func viewDidAppear(animated: Bool) {
       var error: NSError?
       let request = NSFetchRequest(entityName:"User")
       users = moContext?.executeFetchRequest(request, error: &error) as! [MUser]
       self.tableView.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // #warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete method implementation.
    // Return the number of rows in the section.
    return users.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
    
    // Configure the cell...
    
    let user = users[indexPath.row]
    
    //var imageView = UIImageView(frame: CGRect(x: 100,y: 150,width: 150,height: 150))
    var image:UIImage = UIImage(data: user.image)!
        
    let newImage = resizeImage(image, toTheSize: CGSizeMake(70, 70))
    var cellImageLayer: CALayer?  = cell.imageView!.layer
    cellImageLayer!.cornerRadius = 35
    cellImageLayer!.masksToBounds = true
    //cell?.imageView.image = newImage
        
    //imageView.image = image
        
    cell.textLabel?.text = user.name
    cell.imageView?.image = newImage
        
        // UIImage(data: user.image)
        
    return cell
        
    }
    func resizeImage(image:UIImage, toTheSize size:CGSize)->UIImage{
        var scale = CGFloat(max(size.width/image.size.width,
            size.height/image.size.height))
        var width:CGFloat  = image.size.width * scale
        var height:CGFloat = image.size.height * scale;
        
        var rr:CGRect = CGRectMake( 0, 0, width, height);
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        image.drawInRect(rr)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return newImage
    }
    
    /*
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        println("TESTE");
        
        if self.segmentControl == 0 {
            println("Apprenants");
        } else if self.segmentControl == 1{
            println("Médiateurs");
        } else {
            println("All")
        }
        
        /*
        println(sender.selectedSegmentIndex)
        switch segmentControl.selectedSegmentIndex {
        case 0:
            println("aprendente");
        case 1:
            println("mediador");
        default:
            break
        }*/
    }*/
    
    
    
    @IBAction func indexSegment(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            println("Apprenants");
            self.tableView.reloadData()
        } else if sender.selectedSegmentIndex == 1{
            println("Médiateurs");
        } else {
            println("All")
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
}


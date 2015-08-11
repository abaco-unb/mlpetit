//
//  CarnetTVC.swift
//  mplango
//
//  Created by Thomas Petit on 08/08/2015.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import UIKit

class CarnetTVC: UITableViewController {
    
    //MARK: Properties
    
    var words = [Word] ()
    var word = Word?()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the sample data.
        loadSampleWords()

        navigationItem.leftBarButtonItem = editButtonItem()
        
        
        
    }
    
    func loadSampleWords() {
        let word1 = Word(name: "MapLango", desc: "MapLango est une appli pour l'apprentissage nomade des langues", photo: nil)!
        let word2 = Word(name: "Exemple", desc: "Exemple de note que tu peux ajouter au carnet", photo: nil)!
    words += [word1, word2]
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return words.count
    }
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "CarnetTVCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! CarnetTVCell
        
        // Fetches the appropriate word for the data source layout.
        
        let word = words[indexPath.row]
        
        
        cell.WordItemList.text = word.name
        
        
        return cell
    }
    
    @IBAction func unwindToWordList(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.sourceViewController as?
            CarnetAddVC, word = sourceViewController.word {
        
        // Add a new meal.
                let newIndexPath = NSIndexPath(forRow: words.count, inSection: 0)
                words.append(word)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
            
                }
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowWord" {
            let wordDetailViewController = segue.destinationViewController as! CarnetViewController
            
            // Get the cell that generated this segue.
            if let selectedWordCell = sender as? CarnetTVCell {
                let indexPath = tableView.indexPathForCell(selectedWordCell)!
                let selectedWord = words[indexPath.row]
                wordDetailViewController.word = selectedWord
            }
        }
        else if segue.identifier == "AddWord" {
            print("Adding new Word.")
        }
    }
    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            words.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return true
    }


    
 
   
  
    
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
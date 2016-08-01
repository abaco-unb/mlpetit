//
//  LocationSearchTable.swift
//  mplango
//
//  Created by Thomas Petit on 01/08/2016.
//  Copyright © 2016 unb.br. All rights reserved.
//

import UIKit
import MapKit


class LocationSearchTable : UITableViewController {
    
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
    
    var posts = [PostAnnotation]()
    var filteredPosts = [PostAnnotation]()
    
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        
        filteredPosts = posts.filter { posts in
            return posts.title!.lowercaseString.containsString(searchText.lowercaseString)
        }
        tableView.reloadData()
    }
}





//extension LocationSearchTable: UISearchResultsUpdating {
//    func updateSearchResultsForSearchController(searchController: UISearchController) {
//        filterContentForSearchText(searchController.searchBar.text!)
//    }
//}

//
//extension LocationSearchTable {
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return filteredPosts.count
//    }
//    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        
//        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ContactCell
//        
//        let post: PostAnnotation
//        post = self.filteredPosts[indexPath.row]
//        
//        cell.contactName.text = post.ownername
//        
//        cell.contactPicture.image = post.getOwnerImage()
//        cell.contactPicture.layer.masksToBounds = true
//        cell.contactPicture.layer.cornerRadius = 30
//        
//        cell.contactCategory.text = post.title
//        
//        return cell
//
//    }
//}


extension LocationSearchTable : UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {

            guard let mapView = mapView,
                let searchBarText = searchController.searchBar.text else { return }
        
            let request = MKLocalSearchRequest()
            request.naturalLanguageQuery = searchBarText
            request.region = mapView.region
        
            let search = MKLocalSearch(request: request)
            search.startWithCompletionHandler { response, _ in
                guard let response = response else {
                    return
                }
                self.matchingItems = response.mapItems
                
                
                self.tableView.reloadData()
            }
    }
}

extension LocationSearchTable {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ContactCell
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.contactName.text = selectedItem.name
        cell.contactCategory.text = ""
        return cell

    }
}
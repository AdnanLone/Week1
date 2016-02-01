//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Adnan Ali Lone on 1/24/16.
//  Copyright © 2016 Adnan Ali Lone. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD





class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    var movies: [NSDictionary]?
    var searchedMovies: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: .ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        //Start loading icon
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.searchedMovies = self.movies
                            self.tableView.reloadData()
                            self.errorLabel.hidden = true
                            
                    }
                }
                else {
                    self.errorLabel.hidden = false
                }
                
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                
                
        });
        task.resume()
        
        
        // Do any additional setup after loading the view.
        //using the search bar to find movies
        
        searchBar.text = ""
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        findMovie("")

    }
    
    
    func findMovie(searchText: String) {
        
        if let movies = movies {
            
            searchedMovies = searchText.isEmpty ? movies : movies.filter(
                {
                    (movie: NSDictionary) -> Bool in
                    let title = movie["title"] as! String
                    return title.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
            })
        }
        else {
            searchedMovies = nil
        }
        tableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        findMovie(searchText)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        findMovie("")
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    
    
    
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            
                            self.tableView.reloadData()
                            self.errorLabel.hidden = true
                    }
                }
                else {
                    self.errorLabel.hidden = false
                }
                
                refreshControl.endRefreshing()
        });
        task.resume()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if let searchedMovies = searchedMovies {
            return searchedMovies.count
        } else {
            return 0
        }
        
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = searchedMovies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        let posterPath = movie["poster_path"] as! String
        
        let imageUrl = NSURL(string: baseUrl + posterPath)
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        cell.posterView.setImageWithURL(imageUrl!)
        
        
        print ("row\(indexPath.row)")
        return cell
    }


    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

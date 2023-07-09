//
//  MoviesViewController.swift
//  IOS Flix
//
//  Created by Ibrahim  Allahbuksh on 9/13/22.
//

import UIKit
import AlamofireImage
import CoreData

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
   
    @IBOutlet weak var tableView: UITableView!
    
    
    
    var movies = [[String:Any]]()
    var managedObjectContext: NSManagedObjectContext!
    var hasFetchedMovies = false



    override func viewDidLoad() {
            super.viewDidLoad()
            

            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            managedObjectContext = appDelegate.persistentContainer.viewContext

            view.backgroundColor = .black
            tableView.backgroundColor = .black
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
            tableView.dataSource = self
            tableView.delegate = self
            
            let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")!
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
            let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
            let task = session.dataTask(with: request) { (data, response, error) in
                if let error = error {
                     self.tableView.reloadData()
                } else if let data = data {
                    do {
                        if let dataDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            self.movies = dataDictionary["results"] as? [[String:Any]] ?? []
                            for movie in self.movies {
                                self.saveMovieToLocalDatabase(movie: movie)
                            }
                            self.hasFetchedMovies = true  // Set the flag here
                            self.tableView.reloadData()
                        }
                    } catch {
                        print("Error during JSON serialization: \(error.localizedDescription)")
                    }
                }
            }
            task.resume()
            
        }
    
    func saveMovieToLocalDatabase(movie: [String: Any]) {
        let entity = NSEntityDescription.entity(forEntityName: "MovieEntity", in: managedObjectContext!)
        let newMovie = NSManagedObject(entity: entity!, insertInto: managedObjectContext)

        newMovie.setValue(movie["id"], forKey: "id")
        newMovie.setValue(movie["title"], forKey: "title")
        newMovie.setValue(movie["overview"], forKey: "overview")
        newMovie.setValue(movie["poster_path"], forKey: "poster_path")

        do {
            try managedObjectContext.save()
        } catch {
            print("Failed saving")
        }
    }
    
    func fetchMoviesFromLocalDatabase() -> [[String: Any]] {
        var movies = [[String: Any]]()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MovieEntity")

        do {
            let fetchedMovies = try managedObjectContext.fetch(fetchRequest)
            for movie in fetchedMovies {
                var movieDict = [String: Any]()
                movieDict["id"] = movie.value(forKey: "id")
                movieDict["title"] = movie.value(forKey: "title")
                movieDict["overview"] = movie.value(forKey: "overview")
                movieDict["poster_path"] = movie.value(forKey: "poster_path")
                movies.append(movieDict)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

        return movies
    }


    
    
    
    
    
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath)
        
        if let movieCell = cell as? MovieCell {
            let movie = movies[indexPath.row]
            let title = movie["title"] as! String
            let synopsis = movie["overview"] as! String

            movieCell.titleLabel.text = title
            movieCell.titleLabel.numberOfLines = 0
            movieCell.titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
            movieCell.synopsisLabel.text = synopsis
            movieCell.synopsisLabel.numberOfLines = 0
            movieCell.synopsisLabel.setContentCompressionResistancePriority(.required, for: .vertical)


            let baseURL = "https://image.tmdb.org/t/p/w185"
            let posterPath = movie["poster_path"] as! String
            let posterUrl = URL(string: baseURL + posterPath)

            movieCell.posterView.af.setImage(withURL: posterUrl!)
        }

        return cell
    }

    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            print("Loading up the details screen")
            
            // Find the selected movie
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)!
            var movie = movies[indexPath.row]
            
            // If we're offline, fetch the movie details from the local database instead
            if !hasFetchedMovies {
                let id = movie["id"] as? Int64 ?? 0
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MovieEntity")
                fetchRequest.predicate = NSPredicate(format: "id == %@", id)
                
                do {
                    let fetchedMovies = try managedObjectContext.fetch(fetchRequest)
                    if let fetchedMovie = fetchedMovies.first {
                        movie["overview"] = fetchedMovie.value(forKey: "overview")
                        movie["poster_path"] = fetchedMovie.value(forKey: "poster_path")
                        // add any other details you're storing in the database
                    }
                } catch let error as NSError {
                    print("Could not fetch. \(error), \(error.userInfo)")
                }
            }
            
            // Pass the selected movie to the details view controller
            let detailsViewController = segue.destination as! MovieDetailsViewController
            detailsViewController.movie = movie
            
            tableView.deselectRow(at: indexPath, animated: true)
        }

        
    }

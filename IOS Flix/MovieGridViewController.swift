//
//  MovieGridViewController.swift
//  IOS Flix
//
//  Created by Ibrahim  Allahbuksh on 9/20/22.
//

import UIKit
import AlamofireImage
import Foundation



class MovieGridViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {

    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!  // Connect this to your search bar in the storyboard.

    var movies = [[String:Any]]()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        
        self.view.backgroundColor = UIColor.black
        self.collectionView.backgroundColor = UIColor.black
        
        searchBar.barStyle = .black
        searchBar.barTintColor = UIColor.black
        searchBar.isTranslucent = true
        searchBar.tintColor = UIColor.white
        
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white
        textFieldInsideSearchBar?.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        if let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField,
           let glassIconView = textFieldInsideSearchBar.leftView as? UIImageView {
            // This would change the magnifying glass color
            glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
            glassIconView.tintColor = UIColor.white
        }

        
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.view.backgroundColor = UIColor.black
        self.collectionView.backgroundColor = UIColor.black
        
        collectionView.delegate = self
        collectionView.dataSource = self
        searchBar.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        // Adjust these to reduce the margins
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2

        // Determine the number of cells you want in each row
        let cellsPerRow: CGFloat = 2

        // Calculate the width of a single cell, considering the desired spacing between cells
        let spacing = layout.minimumInteritemSpacing * (cellsPerRow - 1)
        let cellWidth = (view.frame.size.width - spacing) / cellsPerRow
        let cellHeight = cellWidth * 1.5  // or whatever ratio is appropriate for your posters

        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        collectionView.collectionViewLayout = layout
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()

        guard let title = searchBar.text, !title.isEmpty else { return }

        // Fetch movies that match the search query.
        let query = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: "https://api.themoviedb.org/3/search/movie?api_key=9d5b3ed1ae81443dcb0e64b61fd576b9&query=\(query)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]

                self.movies = dataDictionary["results"] as! [[String:Any]]

                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
        task.resume()
    }

    func fetchSimilarMovies(byId id: Int) {
        // Clear the previous search results.
        self.movies.removeAll()

        let url = URL(string: "https://api.themoviedb.org/3/movie/\(id)/similar?api_key=9d5b3ed1ae81443dcb0e64b61fd576b9")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]

                self.movies = dataDictionary["results"] as! [[String:Any]]
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
        task.resume()
    }



    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieGridCell", for: indexPath) as! MovieGridCell
        let movie = movies[indexPath.item]
        
        if let posterPath = movie["poster_path"] as? String {
            let baseURL = "https://image.tmdb.org/t/p/w185"
            let posterUrl = URL(string: baseURL + posterPath)
            cell.posterView.af.setImage(withURL: posterUrl!)
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MovieGridToDetailsSegue" {
            let cell = sender as! UICollectionViewCell
            if let indexPath = collectionView.indexPath(for: cell) {
                let movie = movies[indexPath.item]
                let detailsViewController = segue.destination as! MovieDetailsViewController
                detailsViewController.movie = movie
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "MovieGridToDetailsSegue", sender: collectionView.cellForItem(at: indexPath))
    }


}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */



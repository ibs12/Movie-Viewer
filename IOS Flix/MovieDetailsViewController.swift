//
//  MovieDetailsViewController.swift
//  IOS Flix
//
//  Created by Ibrahim  Allahbuksh on 9/19/22.
//

import UIKit
import AlamofireImage

class MovieDetailsViewController: UIViewController {
    
    
    @IBOutlet weak var backdropView: UIImageView!
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var synopsisLabel: UILabel!
    
    var movie: [String: Any]?
       
       override func viewDidLoad() {
           super.viewDidLoad()
           
           titleLabel.lineBreakMode = .byWordWrapping
           
           if let movie = movie {
               titleLabel.text = movie["title"] as? String
               titleLabel.sizeToFit()
               synopsisLabel.text = movie["overview"] as? String
               synopsisLabel.sizeToFit()
               
               let baseURL = "https://image.tmdb.org/t/p/w185"
               if let posterPath = movie["poster_path"] as? String,
                  let posterURL = URL(string: baseURL + posterPath) {
                   posterView.af.setImage(withURL: posterURL)
               }
               
               if let backdropPath = movie["backdrop_path"] as? String,
                  let backdropURL = URL(string: "https://image.tmdb.org/t/p/w780" + backdropPath) {
                   backdropView.af.setImage(withURL: backdropURL)
               }
           }
       }
       
       // ...
   }

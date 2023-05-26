//
//  PostsViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/24.
//

import UIKit
import MJRefresh

class PostsViewController: UIViewController {

    var dataSource: [Post] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func openCamera(_ sender: Any) {
        performSegue(withIdentifier: "openCameraSegue", sender: sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        updateDataSource()
        
        collectionView.mj_header = MJRefreshNormalHeader()
        collectionView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(refreshData))
    }
    
    @objc func refreshData() {
        updateDataSource()
        collectionView.mj_header?.endRefreshing()
    }
    
    private func updateDataSource() {
        FFSManager.shared.readPosts { [weak self] documents in
            
            self?.dataSource = documents.compactMap { document in
                guard let post = Post(data: document.data()) else {
                    print("Failed to convert document to A Post: \(document)") // print any documents that can't be converted
                    return nil
                }
                return post
            }
            
            // Sort the array by time here (latest on top)
            self?.dataSource = self?.dataSource.sorted { $0.time > $1.time } ?? []
        }
    }
}

extension PostsViewController: UICollectionViewDataSource,
                               UICollectionViewDelegate,
                               UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PostCollectionViewCell", for: indexPath) as? PostCollectionViewCell
        else { fatalError("Unable to generate Post  Collection View Cell") }
        
        return cell
    }
}

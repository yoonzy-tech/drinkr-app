//
//  PostsViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/24.
//

import UIKit
import Firebase
import MJRefresh
import Kingfisher

enum Liked {
    case yes
    case no
}

enum Role {
    case author
    case visitor
}

protocol PostCaptionDelegate: AnyObject {
    func didViewComments ()
}

class PostsViewController: UIViewController {
    
    var role: Role = .author

    var postData: Post?
    
    var liked: Liked = .no
    
    var likeCount: Int = 33
    
    var dataSource: [Post] = [] {
        didSet {
            self.dataSource.sort { ($0.createdTime ?? .init()).compare($1.createdTime ?? .init()) == .orderedDescending }
            collectionView.reloadData()
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func openCamera(_ sender: Any) {
        performSegue(withIdentifier: "openCameraSegue", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openComments",
           let destinationVC = segue.destination as? CommentsViewController,
           let shouldActivateTextField = sender as? Bool {
            destinationVC.shouldActivateTextField = shouldActivateTextField
            destinationVC.postDataSource = self.postData
        }
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
        FirestoreManager.shared.fetchAll(in: .posts) { (posts: [Post]) in
            self.dataSource = posts
            self.dataSource.sort { ($0.createdTime ?? .init()).compare($1.createdTime ?? .init()) == .orderedDescending }
            self.collectionView.reloadData()
        }
    }
}

// MARK: - Collection View
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
        
        cell.updateCell(post: dataSource[indexPath.row])
        
        cell.likeButton.tag = indexPath.row
        cell.likeButton.addTarget(self, action: #selector(likes), for: .touchUpInside)
        
        cell.commentButton.tag = indexPath.row
        cell.commentButton.addTarget(self, action: #selector(makeComment), for: .touchUpInside)
        
        cell.viewMoreCommentsButton.tag = indexPath.row
        cell.viewMoreCommentsButton.addTarget(self, action: #selector(viewComments), for: .touchUpInside)
        
        cell.moreOptionsButton.tag = indexPath.row
        cell.moreOptionsButton.addTarget(self, action: #selector(seeMoreOptions), for: .touchUpInside)
        
        return cell
    }
}

// MARK: - Cell Button Action
extension PostsViewController {
    @objc func likes(_ sender: UIButton) {
        let index = sender.tag
        liked = liked == .yes ? .no : .yes
        sender.setImage(liked == .yes ? UIImage(named: "cheers.fill") : UIImage(named: "cheers"), for: .normal)
        likeCount = liked == .yes ? likeCount + 1 : likeCount - 1
        sender.setTitle(likeCount == 0 || liked == .no ? "" : " \(likeCount)", for: .normal)
        dataSource[index].likes = likeCount
        FirestoreManager.shared.update(in: .posts, docId: dataSource[index].id ?? "Unknown Doc Id", data: dataSource[index])
    }
    
    @objc func makeComment(_ sender: UIButton) {
        postData = dataSource[sender.tag]
        performSegue(withIdentifier: "openComments", sender: true)
    }
    
    @objc func viewComments(_ sender: UIButton) {
        postData = dataSource[sender.tag]
        performSegue(withIdentifier: "openComments", sender: false)
    }
    
    @objc func seeMoreOptions(_ sender: UIButton) {
        
        let selectedIndex = sender.tag
        
        let actionSheetController: UIAlertController = UIAlertController(
            title: nil, message: nil, preferredStyle: .actionSheet)
        
        if  role == .author {
            // User Own Post: Edit, Delete
            let editAction: UIAlertAction = UIAlertAction(
                title: "Edit this post",
                style: .default) { _ in
                    print("Edit a post")
                }

            let deleteAction: UIAlertAction = UIAlertAction(
                title: "Delete this post",
                style: .destructive) { [weak self] _ in
                    print("Delete a post")
                    FirestoreManager.shared.delete(in: .posts, docId: self?.dataSource[selectedIndex].id ?? "Unknown Doc Id") {
                        self?.updateDataSource()
                    }
                }
            
            actionSheetController.addAction(editAction)
            actionSheetController.addAction(deleteAction)
           
        } else {
            // Others Post: Report, Share
            let shareAction: UIAlertAction = UIAlertAction(
                title: "Share this post",
                style: .default) { _ in
                    print("Share a post")
                }
            let reportAction: UIAlertAction = UIAlertAction(
                title: "Report this post",
                style: .destructive) { _ in
                    print("Report a post")
                }
            
            actionSheetController.addAction(shareAction)
            actionSheetController.addAction(reportAction)
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(
            title: "Cancel",
            style: .cancel)
        actionSheetController.addAction(cancelAction)
        
         actionSheetController.popoverPresentationController?.sourceView = self.view
        self.present(actionSheetController, animated: true) {
            print("option menu presented")
        }
    }
}

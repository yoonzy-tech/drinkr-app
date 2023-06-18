//
//  PostsViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/24.
//

import UIKit
import AVFoundation
import Firebase
import MJRefresh
import Kingfisher
import IQKeyboardManagerSwift
import Lottie
import ProgressHUD

enum Liked {
    case yes
    case none
}

enum Role {
    case author
    case visitor
}

protocol PostCaptionDelegate: AnyObject {
    func didViewComments ()
}

class PostsViewController: UIViewController {
    
    var currentUserUid = Auth.auth().currentUser?.uid
    
    var postData: Post?
    
    var dataSource: [Post] = []
    
    var tapGesture: UITapGestureRecognizer?
    
    var captionEditTextField = UITextField()
    
    var editView: UIView?
    
    var doneButton = UIButton()
    
    var audioPlayer: AVAudioPlayer?
    
    var animationView: LottieAnimationView?
    
    var postIndex: Int?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func openCamera(_ sender: Any) {
        performSegue(withIdentifier: "openCameraSegue", sender: sender)
    }
    
    func startAnimation() {
        playBeerPouringSound()
        // Lottie Animation
        animationView = .init(name: "beer filling")
        animationView!.frame = view.frame
        animationView?.backgroundColor = UIColor(hexString: AppColor.blue2.rawValue)
        animationView!.contentMode = .scaleAspectFit
        animationView!.loopMode = .loop
        animationView!.animationSpeed = 1
        view.addSubview(animationView!)
        animationView!.play()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
            self.animationView?.stop()
            self.audioPlayer?.stop()
            self.animationView?.removeFromSuperview()
        }
    }
    
    private func playBeerPouringSound() {
        let urlString = Bundle.main.path(forResource: "pouring", ofType: "mp3")
        
        do {
            try AVAudioSession.sharedInstance().setMode(.default)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            guard let url = urlString else {
                return
            }
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: url))
            
            guard let audioPlayer = audioPlayer else {
                return
            }
            audioPlayer.play()
        } catch {
            print("Cannot play audio effect")
        }
    }
    
    @IBAction func unwindToPosts(segue: UIStoryboardSegue) {
        startAnimation()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openComments",
           let destinationVC = segue.destination as? CommentsViewController,
           let shouldActivateTextField = sender as? Bool {
            destinationVC.shouldActivateTextField = shouldActivateTextField
            destinationVC.postDataSource = self.postData
        }
        
        if segue.identifier == "editCaptionSegue", let destinationVC = segue.destination as? EditCaptionViewController {
            destinationVC.postData = self.postData
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.reloadData()
        collectionView.mj_header = MJRefreshNormalHeader()
        collectionView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(refreshData))
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap))
        tapGesture?.numberOfTouchesRequired = 2
        
        if postIndex != nil {
            self.collectionView.reloadData()
        } else {
            FirebaseManager.shared.listen(in: .users) {
                self.updateDataSource()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if postIndex != nil {
            self.collectionView.reloadData()
        } else {
            updateDataSource()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let index = postIndex {
            collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .top, animated: true)
        } else {
            updateDataSource()
        }
    }
    
    @objc func didDoubleTap(_ gesture: UITapGestureRecognizer) {
        print("Double tapped!!")
        guard let gestureView = gesture.view else { return }
        
        let size = gestureView.frame.size.width / 4
        
        let cheers = UIImageView(image: UIImage(named: "cheers"))
        cheers.frame = CGRect(
            x: (gestureView.frame.size.width - size) / 2,
            y: (gestureView.frame.size.height - size) / 2,
            width: size,
            height: size
        )
        cheers.center = gestureView.center
        gestureView.addSubview(cheers)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            UIView.animate(withDuration: 1, animations: {
                cheers.alpha = 0.5
            }, completion: { done in
                if done {
                    cheers.removeFromSuperview()
                }
            })
        })
    }
    
    @objc func refreshData() {
        if let index = navigationController?.viewControllers.count, index >= 1 {
            self.collectionView.reloadData()
        } else {
            updateDataSource()
        }
        collectionView.mj_header?.endRefreshing()
    }
    
    private func updateDataSource() {
        FirebaseManager.shared.fetchAccountInfo(uid: currentUserUid ?? "Unknown User Uid") { currentUserData in
            
            var followingList = currentUserData.following
            followingList.append(currentUserData.uid)
            
            FirebaseManager.shared.fetchAll(in: .posts) { [weak self] (posts: [Post]) in
                let filteredPosts = posts.filter { followingList.contains($0.userUid) }
                self?.dataSource = filteredPosts
                self?.dataSource.sort { ($0.createdTime ?? .init())
                    .compare($1.createdTime ?? .init()) == .orderedDescending }
                self?.collectionView.reloadData()
            }
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
        cell.postImageView.clipsToBounds = true
        cell.postImageView.isUserInteractionEnabled = true
        if let tapGesture = tapGesture {
            cell.postImageView.addGestureRecognizer(tapGesture)
        } else {
            print("Failed to add tap gesture")
        }
        
        cell.likeButton.tag = indexPath.row
        cell.likeButton.addTarget(self, action: #selector(likes), for: .touchUpInside)
        
        if let userUid = Auth.auth().currentUser?.uid {
            let bool = dataSource[indexPath.row].likes.contains(userUid)
            cell.likeButton.setImage(bool ? UIImage(named: "cheers.fill") : UIImage(named: "cheers"), for: .normal)
        }
        
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
        // Get user uid (current user)
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        // Get this post data
        let index = sender.tag
        var post = dataSource[index]
        // Get the bool of the like status
        var hasLiked = post.likes.contains(currentUserUid) // default is false, the user has liked this post
        hasLiked = !hasLiked
        sender.setImage(hasLiked ? UIImage(named: "cheers") : UIImage(named: "cheers.fill"), for: .normal)
        hasLiked ? (post.likes.append(currentUserUid)) : (post.likes.removeAll { $0 == currentUserUid })
        // Lastly update post data in DB
        guard let postDocId = post.id else {
            print("Cannot find the data of this post to update likes")
            return
        }
        dataSource[index] = post
        collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        FirebaseManager.shared.update(in: .posts, docId: postDocId, data: post)
        
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
        postData = dataSource[sender.tag]
        let actionSheetController: UIAlertController = UIAlertController(
            title: nil, message: nil, preferredStyle: .actionSheet)
        
        let isAuthor = Auth.auth().currentUser?.uid == postData?.userUid
        
        if  isAuthor {
            let editAction: UIAlertAction = UIAlertAction(
                title: "Edit", style: .default) { [weak self] _ in
                    self?.performSegue(withIdentifier: "editCaptionSegue", sender: sender) }
            let deleteAction: UIAlertAction = UIAlertAction(
                title: "Delete", style: .destructive) { [weak self] _ in
                    FirebaseManager.shared.delete(
                        in: .posts, docId: self?.dataSource[sender.tag].id ?? "Unknown Doc Id") {
                        self?.updateDataSource()
                        }
                    FirebaseManager.shared.deleteFile(
                        to: .posts, imageRef: self?.dataSource[sender.tag].imageRef ?? "Unknown Image Ref"
                    )
                }
            actionSheetController.addAction(editAction)
            actionSheetController.addAction(deleteAction)
        } else {
            let reportAction: UIAlertAction = UIAlertAction(
                title: "Report post", style: .destructive) { _ in
                    let report = Report(
                        fromUserUid: Auth.auth().currentUser?.uid ?? "User UID Not Found to report",
                        postId: self.postData?.id ?? "Unknown Post ID to report")
                    FirebaseManager.shared.create(in: .reportRequests, data: report)
                    self.showProgressHud(text: "Reported Successfully")
                }
            let blockUserAction: UIAlertAction = UIAlertAction(
                title: "Block user", style: .destructive) { _ in
                    guard let currentUserUid = self.currentUserUid,
                          let blockUid = self.postData?.userUid else {
                        return
                    }
                    FirebaseManager.shared.fetchAccountInfo(uid: currentUserUid) { currentUserData in
                        var newCurrentUserData = currentUserData
                        newCurrentUserData.block.append(blockUid)
                        newCurrentUserData.follower.removeAll { $0 == blockUid}
                        newCurrentUserData.following.removeAll { $0 == blockUid}
                        FirebaseManager.shared.update(in: .users,
                                                      docId: currentUserData.id ?? "Unknown User Doc Id",
                                                      data: newCurrentUserData)
                        self.updateDataSource()
                        self.showProgressHud(text: "Blocked Successfully")
                        
                        // B: Add A to BlockBy
                        FirebaseManager.shared.fetchAccountInfo(uid: blockUid) { otherUserData in
                            var newOtherUserData = otherUserData
                            newOtherUserData.blockedBy.append(currentUserUid)
                            newOtherUserData.follower.removeAll { $0 == currentUserUid }
                            newOtherUserData.following.removeAll { $0 == currentUserUid }
                            FirebaseManager.shared.update(in: .users,
                                                          docId: otherUserData.id ?? "Unknown User Doc Id",
                                                          data: newOtherUserData)
                        }
                    }
                }
            actionSheetController.addAction(reportAction)
            actionSheetController.addAction(blockUserAction)
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
        actionSheetController.addAction(cancelAction)
        actionSheetController.popoverPresentationController?.sourceView = self.view
        self.present(actionSheetController, animated: true) {
            print("option menu presented")
        }
    }
    
    func showProgressHud(text: String) {
        ProgressHUD.colorAnimation = UIColor(hexString: AppColor.blue.rawValue)
        ProgressHUD.showSucceed(text, delay: 1.5)
    }
}

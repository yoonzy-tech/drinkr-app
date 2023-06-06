//
//  PostsViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/24.
//
// TODO: Fix Posts Data Source Query (Now just fetch all in DB)
import UIKit
import AVFoundation
import Firebase
import MJRefresh
import Kingfisher
import IQKeyboardManagerSwift
import Lottie

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
    
    var dataSource: [Post] = []
    
    var tapGesture: UITapGestureRecognizer?
    
    var captionEditTextField = UITextField()
    
    var editView: UIView?
    
    var doneButton = UIButton()
    
    var audioPlayer: AVAudioPlayer?
    
    var animationView: LottieAnimationView?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func openCamera(_ sender: Any) {
        performSegue(withIdentifier: "openCameraSegue", sender: sender)
    }
    
    func startAnimation() {
        playBeerPouringSound()
        // Lottie Animation
        animationView = .init(name: "beer filling")
        animationView!.frame = view.frame
        animationView?.backgroundColor = .white
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
    
    func playBeerPouringSound() {
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
    
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
        print("This is the First View Controller")
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
        
        collectionView.mj_header = MJRefreshNormalHeader()
        collectionView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(refreshData))
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap))
        tapGesture?.numberOfTouchesRequired = 2
        
        FirebaseManager.shared.listen(in: .posts) {
            self.updateDataSource()
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
        updateDataSource()
        collectionView.mj_header?.endRefreshing()
    }
    
    private func updateDataSource() {
        FirebaseManager.shared.fetchAll(in: .posts) { [weak self] (posts: [Post]) in
            self?.dataSource = posts
            self?.dataSource.sort { ($0.createdTime ?? .init())
                .compare($1.createdTime ?? .init()) == .orderedDescending }
            self?.collectionView.reloadData()
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
        likeCount = liked == .yes ? likeCount + 1 : likeCount - 1
        sender.setImage(liked == .yes ? UIImage(named: "cheers.fill") : UIImage(named: "cheers"), for: .normal)
        sender.setTitle(liked == .no ? "" : " \(likeCount)", for: .normal)
        dataSource[index].likes = likeCount
        FirebaseManager.shared.update(
            in: .posts,
            docId: dataSource[index].id ?? "Unknown Doc Id",
            data: dataSource[index]
        )
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
        postData = dataSource[selectedIndex]
        
        let actionSheetController: UIAlertController = UIAlertController(
            title: nil, message: nil, preferredStyle: .actionSheet)
        
        if  role == .author {
            // User Own Post: Edit, Delete
            let editAction: UIAlertAction = UIAlertAction(
                title: "Edit this post",
                style: .default) { [weak self] _ in
                    print("Edit a post")
                    
                    self?.performSegue(withIdentifier: "editCaptionSegue", sender: sender)
                    
                }
            let deleteAction: UIAlertAction = UIAlertAction(
                title: "Delete this post",
                style: .destructive) { [weak self] _ in
                    print("Delete a post")
                    FirebaseManager.shared.delete(
                        in: .posts,
                        docId: self?.dataSource[selectedIndex].id ?? "Unknown Doc Id") {
                            self?.updateDataSource()
                        }
                    FirebaseManager.shared.deleteFile(
                        to: .posts,
                        imageRef: self?.dataSource[selectedIndex].imageRef ?? "Unknown Image Ref"
                    )
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

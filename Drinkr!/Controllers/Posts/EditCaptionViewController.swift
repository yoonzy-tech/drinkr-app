//
//  EditCaptionViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/6/2.
//

import UIKit
import Kingfisher
import IQKeyboardManagerSwift

class EditCaptionViewController: UIViewController {

    var postData: Post?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        if let postData = postData {
            imageView.kf.setImage(with: URL(string: postData.imageUrl))
            textView.text = postData.caption
        }
        textView.becomeFirstResponder()
    }
}

extension EditCaptionViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        
        print("Keyboard dismiss")
        
        if let newCaption = textView.text {
            
            postData?.caption = newCaption
            
            FirestoreManager.shared.update(in: .posts, docId: postData?.id ?? "Unknown Doc Id", data: postData)
        }
        
        navigationController?.popViewController(animated: true)
    }
}

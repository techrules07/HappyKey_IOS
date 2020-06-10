//
//  AddSampleProperty.swift
//  Diffus
//
//  Created by IRPL on 23/03/20.
//  Copyright © 2020 IRPL. All rights reserved.
//

import UIKit

class AddSampleProperty: UIViewController {

    @IBOutlet weak var uiview: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addView()
        
    }
    
    func addView() {
        
        let textView = UITextView()
        textView.text = "Dynamic text view"
        textView.font = UIFont.boldSystemFont(ofSize: 18)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textAlignment = .center
        textView.isEditable = false
        textView.isScrollEnabled = false
        
        
        self.uiview.addSubview(textView)
        
        textView.topAnchor.constraint(equalTo: self.uiview.topAnchor, constant: 0).isActive = true
        textView.leftAnchor.constraint(equalTo: self.uiview.leftAnchor, constant: 0).isActive = true
        textView.rightAnchor.constraint(equalTo: self.uiview.rightAnchor, constant: 0).isActive = true
        
        self.uiview.layoutIfNeeded()
    }

}

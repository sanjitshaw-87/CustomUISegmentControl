//
//  ViewController.swift
//  CustomSegmentControl
//
//  Created by Sanjit Shaw on 25/02/19.
//  Copyright © 2019 Sanjit Shaw. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var segmentSelectionIndex = 0
    var segmentControl: CustomSegmentedUIControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        addSegmentControl()
    }
    
    
    func addSegmentControl()
    {
        segmentControl = CustomSegmentedUIControl(items: ["Segment 1", "Segment 2"])
        segmentControl.setTitleAttributes(attributes: [NSAttributedString.Key.foregroundColor as NSAttributedString.Key : UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8), NSAttributedString.Key.font as NSAttributedString.Key : UIFont.boldSystemFont(ofSize: 18.0), NSAttributedString.Key.underlineColor : UIColor.black, NSAttributedString.Key.underlineStyle : 1], controlState: .selected)
        segmentControl.setTitleAttributes(attributes: [NSAttributedString.Key.foregroundColor as NSAttributedString.Key : UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3), NSAttributedString.Key.font as NSAttributedString.Key : UIFont.systemFont(ofSize: 14.0)], controlState: .normal)
        segmentControl.selectedSegmentIndex = segmentSelectionIndex
        segmentControl.frame = CGRect(x: 0.0, y: 100.0, width: self.view.frame.size.width, height: 48.0)
        segmentControl.addTarget(self, action: #selector(selectedCustomSegment(sender:)), for: .valueChanged)
        segmentControl.backgroundColor = UIColor.gray
        
        segmentControl.tintColor = UIColor.clear
        self.view.addSubview(segmentControl)
        
        segmentControl.addUnderLineLayer(withColor: UIColor.white)
        
        segmentControl.layer.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.24).cgColor
        segmentControl.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        segmentControl.layer.shadowOpacity = 1.0
        segmentControl.layer.masksToBounds = false
    }
    
    @objc func selectedCustomSegment(sender: CustomSegmentedUIControl) {
        
        print(sender.selectedSegmentIndex)
        print(sender)
    }


}


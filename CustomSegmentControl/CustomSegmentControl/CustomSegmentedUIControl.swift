//
//  CustomSegmentedUIControl.swift
//  UICustomisation
//
//  Created by SANJIT SHAW on 09/07/18.
//  Copyright © 2018 Sample. All rights reserved.
//

import UIKit

fileprivate let defaultSegmentHeight : CGFloat = 30.0

private class CustomUISegment : UIControl
{
    let titleLabel : UILabel = UILabel()
    let counterLabel : UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.frame = CGRect(x: 2.0, y: 2.0, width: frame.size.width - 4.0, height: frame.size.height - 4.0)
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        self.clipsToBounds = true
        titleLabel.backgroundColor = UIColor.clear
        self.addSubview(titleLabel)
        
        counterLabel.textAlignment = NSTextAlignment.center
        counterLabel.clipsToBounds = true
        self.addSubview(counterLabel)
        
        self.backgroundColor = UIColor.clear
        self.addObserver(self, forKeyPath: "frame", options: .new, context: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        var customFrame = titleLabel.frame
        customFrame.size.width = self.frame.size.width - 4.0
        customFrame.size.height = self.frame.size.height - 4.0
        titleLabel.frame = customFrame
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: "frame")
    }
}

//==================== Parent Control==========
class CustomSegmentedUIControl: UIControl {
    
    private let defaultFont = UIFont.systemFont(ofSize: 17.0)
    
    private var isRequiredFrameRealign : Bool = false
    private var tarGetforAcrtion : Any? = nil
    private var targetSelector : Selector? = nil
    private var controlEvent : UIControl.Event? = nil
    private let defaultColor : UIColor = UIColor.clear
    private var selectedStateColor : UIColor = UIColor.blue
    private var highlightedStateColor : UIColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
    private var segmentItems : [String?] = []
    private var segmentMetaData : [UInt : Any?] = [:]
    private let underLineLayer = CALayer()
    
    private var lastSelectedSegmentIndex : Int = 0
    private var tempSelectedSegmentIndex : Int = 0
    var selectedSegmentIndex : Int = 0
    {
        didSet
        {
            setColorsForUI()
        }
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.addObserver(self, forKeyPath: "frame", options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        if keyPath == "frame"
        {
            if isRequiredFrameRealign
            {
                reAlignUI()
            }
        }
    }
    
    convenience init(items : [String?])
    {
        self.init(frame: CGRect(x: 0.0, y: 200.0, width: 0.0, height: defaultSegmentHeight))
        segmentItems = items
        
        layOutUI()
    }
    
    func addUnderLineLayer(withColor : UIColor)
    {
        let childSegment = self.subviews[selectedSegmentIndex] as! CustomUISegment
        
        underLineLayer.frame = CGRect(x: childSegment.frame.origin.x, y: childSegment.frame.size.height - 2.0, width: childSegment.frame.size.width, height: 3.0)
        underLineLayer.backgroundColor = UIColor.white.cgColor
        self.layer.addSublayer(underLineLayer)
    }
    
    private func translateUnderlineLayer()
    {
        var customframe = self.underLineLayer.frame
        let childSegment = self.subviews[selectedSegmentIndex] as! CustomUISegment
        customframe.origin.x = childSegment.frame.origin.x
        self.underLineLayer.frame = customframe
    }
    
    override var tintColor: UIColor!
    {
        didSet
        {
            selectedStateColor = tintColor
            highlightedStateColor = tintColor
            setColorsForUI()
        }
    }
    
    override var isEnabled: Bool
    {
        didSet
        {
            for subControl in self.subviews
            {
                let control = subControl as! CustomUISegment
                control.isEnabled = isEnabled
            }
            configureUIonEnableStatus()
        }
    }
    
    func setColorsForUI()
    {
        let lastSelectedSegment = self.subviews[lastSelectedSegmentIndex] as! CustomUISegment
        if let attributes = segmentMetaData[UIControl.State.normal.rawValue] as? [NSAttributedString.Key : Any]
        {
            lastSelectedSegment.titleLabel.attributedText = NSAttributedString(string: segmentItems[lastSelectedSegmentIndex]!, attributes: attributes as [NSAttributedString.Key : Any])
        }
        else
        {
            lastSelectedSegment.titleLabel.attributedText = nil
            lastSelectedSegment.titleLabel.text = segmentItems[lastSelectedSegmentIndex]
            lastSelectedSegment.titleLabel.textColor = selectedStateColor
        }
        lastSelectedSegment.backgroundColor = defaultColor
        
        let currentSelectedSegment = self.subviews[selectedSegmentIndex] as! CustomUISegment
        if let attributes = segmentMetaData[UIControl.State.selected.rawValue] as? [NSAttributedString.Key : Any]
        {
            currentSelectedSegment.titleLabel.attributedText = NSAttributedString(string: segmentItems[selectedSegmentIndex]!, attributes: attributes as [NSAttributedString.Key : Any])
        }
        else
        {
            currentSelectedSegment.titleLabel.attributedText = nil
            currentSelectedSegment.titleLabel.text = segmentItems[selectedSegmentIndex]
            currentSelectedSegment.titleLabel.textColor = defaultColor
        }
        currentSelectedSegment.backgroundColor = selectedStateColor
    }
    
    func setDefaultColorsForUI()
    {
        if let attributes = segmentMetaData[UIControl.State.normal.rawValue] as? [NSAttributedString.Key : Any]
        {
            var index : Int = 0
            for subControls in self.subviews
            {
                let control = subControls as! CustomUISegment
                control.titleLabel.attributedText = NSAttributedString(string: segmentItems[index]!, attributes: attributes as [NSAttributedString.Key : Any])
                index += 1
            }
        }
        else
        {
            var index : Int = 0
            for subControls in self.subviews
            {
                let control = subControls as! CustomUISegment
                control.titleLabel.attributedText = nil
                control.titleLabel.text = segmentItems[index]
                control.titleLabel.textColor = defaultColor
                
                index += 1
            }
        }
    }
    
    func setColorsForUIonHighlightedState()
    {
        let tempSelectedSegment = self.subviews[tempSelectedSegmentIndex] as! CustomUISegment
        if let attributes = segmentMetaData[UIControl.State.highlighted.rawValue] as? [NSAttributedString.Key : Any]
        {
            tempSelectedSegment.titleLabel.attributedText = NSAttributedString(string: segmentItems[tempSelectedSegmentIndex]!, attributes: attributes as [NSAttributedString.Key : Any])
        }
        else
        {
            tempSelectedSegment.titleLabel.attributedText = nil
            tempSelectedSegment.titleLabel.text = segmentItems[tempSelectedSegmentIndex]
            tempSelectedSegment.titleLabel.textColor = defaultColor
        }
        tempSelectedSegment.backgroundColor = highlightedStateColor
        
    }
    
    func layOutUI()
    {
        var xPos : CGFloat = 0.0
        var index : Int = 0
        for eachItem in segmentItems
        {
            var textWidth : CGFloat = 0.0
            if let attributes = segmentMetaData[UIControl.State.normal.rawValue] as? [NSAttributedString.Key : Any]
            {
                if let userDefinedFont = attributes[NSAttributedString.Key.font] as? UIFont
                {
                    textWidth = eachItem!.size(withAttributes: [NSAttributedString.Key.font : userDefinedFont]).width + 6.0
                }
            }
            else
            {
                textWidth = eachItem!.size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17.0)]).width + 6.0
            }
            
            let eachControl = CustomUISegment(frame: CGRect(x: xPos, y: 0.0, width: textWidth, height: self.frame.size.height))
            eachControl.titleLabel.text = eachItem
            //eachControl.layer.borderWidth = 1.0
            //eachControl.layer.borderColor = UIColor.black.cgColor
            eachControl.tag = index
            if index == selectedSegmentIndex
            {
                eachControl.isSelected = true
            }
            else
            {
                eachControl.isSelected = false
            }
            eachControl.addTarget(self, action: #selector(selectedCustomSubSegment(sender:)), for: .touchUpInside)
            eachControl.addTarget(self, action: #selector(pressAndHoldSubSegment(sender:)), for: .touchDown)
            self.addSubview(eachControl)
            
            xPos = xPos + textWidth
            index = index + 1
        }
        var customFrame = self.frame
        customFrame.size.width = xPos
        self.frame = customFrame
        //setColorsForUI()
        
        isRequiredFrameRealign = true
    }
    
    func reAlignUI()
    {
        let eachSectionMaxPossibleWidth = self.frame.size.width / CGFloat(segmentItems.count)
        var xPos : CGFloat = 0.0
        for subControls in self.subviews
        {
            var customFrame = subControls.frame
            customFrame.origin.x = xPos
            customFrame.size.width = eachSectionMaxPossibleWidth
            customFrame.size.height = self.frame.size.height
            subControls.frame = customFrame
            
            xPos = xPos + eachSectionMaxPossibleWidth
        }
    }
    
    
    func insertSegment(withTitle : String?, atIndex : Int)
    {
        segmentItems.insert(withTitle, at: atIndex)
        for subControl in self.subviews
        {
            subControl.removeFromSuperview()
        }
        layOutUI()
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func selectedCustomSubSegment(sender : CustomUISegment)
    {
        lastSelectedSegmentIndex = selectedSegmentIndex
        selectedSegmentIndex = sender.tag
        translateUnderlineLayer()
        setColorsForUI()
        (tarGetforAcrtion as! NSObject).perform(targetSelector, with: self)
    }
    
    @objc private func pressAndHoldSubSegment(sender : CustomUISegment)
    {
        tempSelectedSegmentIndex = sender.tag
        setColorsForUIonHighlightedState()
    }
    
    override func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        
        tarGetforAcrtion = target
        targetSelector = action
        controlEvent = controlEvents
    }
    
    func setTitleAttributes(attributes : [NSAttributedString.Key : Any], controlState : UIControl.State)
    {
        segmentMetaData[controlState.rawValue] = attributes
    }
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        setDefaultColorsForUI()
        if self.isEnabled == true
        {
            configureUIasperUserRequirement()
        }
        else
        {
            configureUIonEnableStatus()
        }
    }
    
    func configureUIasperUserRequirement()
    {
        let selectedSegment = self.subviews[selectedSegmentIndex] as! CustomUISegment
        if let attributes = segmentMetaData[UIControl.State.selected.rawValue] as? [NSAttributedString.Key : Any]
        {
            selectedSegment.titleLabel.attributedText = NSAttributedString(string: segmentItems[selectedSegmentIndex]!, attributes: attributes as [NSAttributedString.Key : Any])
        }
    }
    
    func configureUIonEnableStatus()
    {
        var index : Int = 0
        if self.isEnabled
        {
            for subControl in self.subviews
            {
                subControl.removeFromSuperview()
            }
            layOutUI()
        }
        else
        {
            if let attributes = segmentMetaData[UIControl.State.disabled.rawValue] as? [NSAttributedString.Key : Any]
            {
                for subControl in self.subviews
                {
                    let control = subControl as! CustomUISegment
                    control.titleLabel.attributedText = NSAttributedString(string: segmentItems[index]!, attributes: attributes as [NSAttributedString.Key : Any])
                    index = index + 1
                }
            }
        }
    }
    
    func setCount(count : Int, forIndex : Int, textColor : UIColor, textBgColor : UIColor, font : UIFont)
    {
        if count > 0
        {
            let customSegment = self.subviews[forIndex] as! CustomUISegment
            
            let titleRect : CGRect = customSegment.titleLabel.textRect(forBounds: customSegment.titleLabel.bounds, limitedToNumberOfLines: 1)
            var xpos = 0.0
            if (titleRect.size.width + titleRect.origin.x) < customSegment.frame.size.width - 30.0
            {
                xpos = Double(titleRect.size.width + titleRect.origin.x + 10.0)
            }
            else
            {
                xpos = Double(customSegment.frame.size.width - 30.0)
            }
            
            customSegment.counterLabel.frame = CGRect(x: xpos, y: Double(customSegment.titleLabel.center.y - 10.0), width: 20.0, height: 20.0)
            customSegment.counterLabel.text = String(count)
            customSegment.counterLabel.font = font
            customSegment.counterLabel.backgroundColor = textBgColor
            customSegment.counterLabel.textColor = textColor
            
            customSegment.counterLabel.layer.cornerRadius = customSegment.counterLabel.frame.size.width/2.0
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    deinit {
        self.removeObserver(self, forKeyPath: "frame")
    }

}

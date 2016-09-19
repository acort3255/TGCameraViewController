//
//  TGCameraAuthorizationViewController.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/22/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import UIKit

open class TGCameraAuthorizationViewController: UIViewController
{
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var step1Label: UILabel!
    @IBOutlet var step2Label: UILabel!
    @IBOutlet var step3Label: UILabel!
    @IBOutlet var step4Label: UILabel!
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = TGCameraFunctions.TGLocalizedString("TGCameraViewController-Title")
        self.subtitleLabel.text = TGCameraFunctions.TGLocalizedString("TGCameraViewController-Subtitle")
        self.step1Label.text = TGCameraFunctions.TGLocalizedString("TGCameraViewController-Step1")
        self.step2Label.text = TGCameraFunctions.TGLocalizedString("TGCameraViewController-Step2")
        self.step3Label.text = TGCameraFunctions.TGLocalizedString("TGCameraViewController-Step3")
        self.step4Label.text = TGCameraFunctions.TGLocalizedString("TGCameraViewController-Step4")
    }
    
    override open var prefersStatusBarHidden : Bool {
        return true
    }
    
    // MARK: -
    
    
    // MARK: - Actions
    
    
    @IBAction func closeTapped() {
        self.dismiss(animated: true, completion: { _ in })
    }
}

//
//  GeneticMutationViewController.swift
//  CancerSN
//
//  Created by lily on 11/12/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

protocol GeneticMutationVCDelegate{
    func updateGeneticMutation(geneticMutation: String)
}

class GeneticMutationViewController: UIViewController {

    var publicService = PublicService()
    @IBOutlet weak var krasBtn: UIButton!
    @IBOutlet weak var egfrBtn: UIButton!
    @IBOutlet weak var alkBtn: UIButton!
    @IBOutlet weak var otherMutationBtn: UIButton!
    @IBOutlet weak var noMutationBtn: UIButton!
    let profileSet = NSUserDefaults.standardUserDefaults()

    var selectGeneticMutationStr = String()
    var isUpdate = false
    var geneticMutationVCDelegate: GeneticMutationVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        publicService.unselectBtnFormat(krasBtn)
        publicService.unselectBtnFormat(egfrBtn)
        publicService.unselectBtnFormat(alkBtn)
        publicService.unselectBtnFormat(otherMutationBtn)
        publicService.unselectBtnFormat(noMutationBtn)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    @IBAction func selectGenetic(sender: UIButton) {
        selectGeneticMutationStr = geneticMutationMapping.objectForKey((sender.titleLabel?.text)!) as! String
        switch sender{
        case krasBtn:
            publicService.selectedBtnFormat(krasBtn)
            publicService.unselectBtnFormat(egfrBtn)
            publicService.unselectBtnFormat(alkBtn)
            publicService.unselectBtnFormat(otherMutationBtn)
            publicService.unselectBtnFormat(noMutationBtn)
        case egfrBtn:
            publicService.selectedBtnFormat(egfrBtn)
            publicService.unselectBtnFormat(krasBtn)
            publicService.unselectBtnFormat(alkBtn)
            publicService.unselectBtnFormat(otherMutationBtn)
            publicService.unselectBtnFormat(noMutationBtn)
        case alkBtn:
            publicService.selectedBtnFormat(alkBtn)
            publicService.unselectBtnFormat(krasBtn)
            publicService.unselectBtnFormat(egfrBtn)
            publicService.unselectBtnFormat(otherMutationBtn)
            publicService.unselectBtnFormat(noMutationBtn)
        case otherMutationBtn:
            publicService.selectedBtnFormat(otherMutationBtn)
            publicService.unselectBtnFormat(krasBtn)
            publicService.unselectBtnFormat(egfrBtn)
            publicService.unselectBtnFormat(alkBtn)
            publicService.unselectBtnFormat(noMutationBtn)
        case noMutationBtn:
            publicService.selectedBtnFormat(noMutationBtn)
            publicService.unselectBtnFormat(krasBtn)
            publicService.unselectBtnFormat(egfrBtn)
            publicService.unselectBtnFormat(otherMutationBtn)
            publicService.unselectBtnFormat(alkBtn)
        default:
            break
        }
        
    }
    
    @IBAction func confirm(sender: UIButton) {
        if isUpdate{
            geneticMutationVCDelegate?.updateGeneticMutation(selectGeneticMutationStr)
            self.dismissViewControllerAnimated(true, completion: nil)
        }else{
            profileSet.setObject(selectGeneticMutationStr, forKey: geneticMutationNSUserData)
            self.performSegueWithIdentifier("stageAndMetastasisSegue", sender: self)
        }
    }
}

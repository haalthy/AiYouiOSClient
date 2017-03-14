//
//  UpdateNickTableViewController.swift
//  CancerSN
//
//  Created by lily on 2/10/16.
//  Copyright © 2016 lily. All rights reserved.
//

import UIKit

protocol SettingNickVCDelegate{
    func updateDisplayname(_ displayname: String)
}

class UpdateNickTableViewController: UITableViewController, UITextFieldDelegate {
    
    var settingNickVCDelegate: SettingNickVCDelegate?

    let cellTextColor = UIColor.init(red: 151 / 255, green: 151 / 255, blue: 151 / 255, alpha: 1)
    let cellInputColor = UIColor.init(red: 102 / 255, green: 102 / 255, blue: 102 / 255, alpha: 1)
    let heightForRow = CGFloat(44)
    let textInputLeftSpace = CGFloat(85)
    let textInput = UITextField()
    
    let cellTextFont = UIFont.systemFont(ofSize: 13)
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func submit(){
        if (textInput.text != nil) && (textInput.text != "") {
            settingNickVCDelegate?.updateDisplayname(textInput.text!)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForRow
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...
        cell.textLabel?.textColor = cellTextColor
        cell.textLabel?.text = "昵称编辑："
        cell.textLabel?.font = cellTextFont
        textInput.frame = CGRect(x: textInputLeftSpace, y: 0, width: cell.frame.width - textInputLeftSpace, height: heightForRow)
        textInput.textColor = cellInputColor
        textInput.placeholder = "请在此输入新昵称"
        textInput.font = cellTextFont
        textInput.delegate = self
        cell.addSubview(textInput)
        return cell
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

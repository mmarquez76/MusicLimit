//
//  SourcePickerViewController.swift
//  MusicLimit
//
//  Created by Bryan Mazariegos on 10/2/17.
//  Copyright © 2017 ICBM. All rights reserved.
//

import UIKit

class SourcePickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet var playlistPicker:UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonPressed() {
        selectedPlaylist = playlistPicker.selectedRow(inComponent: 0) - 1
        self.dismiss(animated: true, completion: {
            VCref.updateSourceTitle()
        })
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var title = "All Playlists"
        if row > 0 {
            title = choiceNames[row - 1]
        }
        
        let attTitle = NSAttributedString.init(string: title, attributes: [NSAttributedStringKey.foregroundColor:UIColor.white])
        
        return attTitle
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return choiceNames.count + 1
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

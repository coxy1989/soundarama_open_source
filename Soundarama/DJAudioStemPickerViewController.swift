//
//  DJAudioStemPickerViewController.swift
//  Soundarama
//
//  Created by Jamie Cox on 14/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

class DJAudioStemPickerViewController: UIViewController, DJAudioStemPickerUserInterface {
    
    weak var delegate: DJAudioStemPickerUserInterfaceDelegate!
    
    var keys: [String]!
    
    var colors: [String : UIColor]!
    
    var stemsIndex: [String : Set<UIAudioStem>]!
    
    var identifier: String!
}

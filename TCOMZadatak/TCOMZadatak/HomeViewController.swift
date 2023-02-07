//
//  HomeViewController.swift
//  TCOMZadatak
//
//  Created by Danica Rabasovic on 7.2.23..
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet private weak var previewButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        previewButton.layer.cornerRadius = 10
    }

}

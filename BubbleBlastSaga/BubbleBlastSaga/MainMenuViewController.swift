//
//  MainMenuViewController.swift
//  BubbleBlastSaga
//
//  Created by Edmund Mok on 18/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
}

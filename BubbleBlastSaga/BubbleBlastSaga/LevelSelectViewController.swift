//
//  LevelSelectViewController.swift
//  BubbleBlastSaga
//
//  Created by Edmund Mok on 18/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit

class LevelSelectViewController: UIViewController {

    fileprivate var levelsModel: SavedLevelsModel = SavedLevelsModelManager()
    @IBOutlet weak var levelSelect: UICollectionView!
    
    private var levelSelectDataSource: LevelSelectDataSource?
    private var levelSelectDelegate: LevelSelectDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.levelSelectDataSource = LevelSelectDataSource(savedLevels: levelSelect, savedLevelsModel: levelsModel)
        self.levelSelectDelegate = LevelSelectDelegate(savedLevels: levelSelect, savedLevelsModel: levelsModel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handleBack(_ sender: UIButton) {
        let _ = self.navigationController?.popViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

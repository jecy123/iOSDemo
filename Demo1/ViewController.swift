//
//  ViewController.swift
//  Demo1
//
//  Created by CBH_Mac on 2017/3/8.
//  Copyright © 2017年 CBH_Mac. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var buttonJump:UIButton!
    
    func initView()
    {
        buttonJump.layer.borderWidth = 1
        buttonJump.layer.borderColor = UIColor.gray.cgColor
        buttonJump.layer.cornerRadius = 5
        
        buttonJump.layer.masksToBounds = true
        buttonJump.addTarget(self, action: #selector(OnClick(_:)), for:.touchUpInside)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.tgc_makeToast(message: "你好", duration: 1, position: .bottom)
        initView()
    }
    
    func OnClick(_ sender: UIButton)
    {
        print("OnClick")
        self.performSegue(withIdentifier: "ToFirst", sender: self)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


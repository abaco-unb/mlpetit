//
//  StartTestVC.swift
//  mplango
//
//  Created by Thomas Petit on 05/06/2016.
//  Copyright © 2016 unb.br. All rights reserved.
//

import UIKit

class StartTestVC: UIViewController {
    
    //MARK: Properties

    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var okImage: UIImageView!
    @IBOutlet weak var okMessage: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // inicialmente o botão Start serve para fazer o teste, e o resultado "ok, aprovado" é escondido
        okImage.hidden = true
        okMessage.hidden = true
        
        // mas se tiver pelo menos 6 atividades aprovadas, o teste é obtido, então o botão start será escondido e desativado
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

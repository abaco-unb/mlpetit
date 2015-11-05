//
//  tuto1VC.swift
//  mplango
//
//  Created by Thomas Petit on 25/10/2015.
//  Copyright © 2015 unb.br. All rights reserved.
//

import UIKit

class tuto1VC: UIViewController, UIScrollViewDelegate {
    
@IBOutlet weak var scroll: UIScrollView!
@IBOutlet weak var text: UILabel!
@IBOutlet weak var pageControl: UIPageControl!
@IBOutlet weak var startBtn: UIButton!
@IBOutlet weak var figure: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        //1
        self.scroll.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        let scrollWidth:CGFloat = self.scroll.frame.width
        let scrollHeight:CGFloat = self.scroll.frame.height
        
        
        
        let fundo1 = UIImageView(frame: CGRectMake(0, 0,scrollWidth, scrollHeight))
        fundo1.image = UIImage(named: "fundo_3")
        let fundo2 = UIImageView(frame: CGRectMake(scrollWidth, 0,scrollWidth, scrollHeight))
        fundo2.image = UIImage(named: "fundo_2")
        let fundo3 = UIImageView(frame: CGRectMake(scrollWidth*2, 0,scrollWidth, scrollHeight))
        fundo3.image = UIImage(named: "fundo_1")
        let fundo4 = UIImageView(frame: CGRectMake(scrollWidth*3, 0,scrollWidth, scrollHeight))
        fundo4.image = UIImage(named: "fundo_4")
        
        self.scroll.addSubview(fundo1)
        self.scroll.addSubview(fundo2)
        self.scroll.addSubview(fundo3)
        self.scroll.addSubview(fundo4)
        
        
        //4
        self.scroll.contentSize = CGSizeMake(self.scroll.frame.width * 4, self.scroll.frame.height)
        self.scroll.delegate = self
        self.pageControl.currentPage = 0
        
        
        // Do any additional setup after loading the view.
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView){
        // Test the offset and calculate the current page after scrolling ends
        let pageWidth:CGFloat = CGRectGetWidth(scroll.frame)
        let currentPage:CGFloat = floor((scroll.contentOffset.x-pageWidth/2)/pageWidth)+1
        // Change the indicator
        self.pageControl.currentPage = Int(currentPage);
        
        // Change the text accordingly
        if Int(currentPage) == 0{
            text.text = "Bienvenue dans la communauté MapLango !"
            figure.image = UIImage(named: "marca")
            
        }else if Int(currentPage) == 1{
            text.text = "Envie de poster un défi, une activité, un doute, une astuce dans votre propre environnement ? Réinventez l'immmersion avec MapLango !"
            figure.image = UIImage(named: "tutorial_funcionalidades")

        }
        
        else if Int(currentPage) == 2{
            text.text = "La communauté est composée de 4 niveaux de pratique et de médiateurs francophones. Passez les tests pour connaitre votre niveau !"
            figure.image = UIImage(named: "tutorial_niveis")

        
        }else{
            text.text = "5 badges débloquent 5 fonctionnalités dans l'app. Comment les obtenir ? Rien de plus simple : participez et collaborez avec la communauté !"
            figure.image = UIImage(named: "tutorial_badges")

            // Show the "Let's Start" button in the last slide (with a fade in animation)
            UIView.animateWithDuration(1.0, animations: { () -> Void in
                self.startBtn.alpha = 1.0
            })
            
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

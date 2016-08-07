//
//  CommentCell.swift
//  mplango
//
//  Created by Thomas Petit on 10/12/2015.
//  Copyright © 2015 unb.br. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    
    var comment: Post? = nil
    var user: User!
    
    
    // MARK: Properties
    
    // para todas as cells

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var checkPointsLabel: UILabel!

    // para a BasicCell 
    @IBOutlet weak var comTxtView: UILabel!
    @IBOutlet weak var comPicture: UIImageView!
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var bgPlayerAudioInPhoto: UIView!


    
    override func layoutSubviews() {

        //userName.text = user.name
        
        profilePicture.layer.cornerRadius = 15
        profilePicture.layer.masksToBounds = true
        
        //Como vai aparecer a AudioView
        
        /*
        audioView.layer.borderWidth = 1
        audioView.layer.borderColor = UIColor(hex: 0x2C98D4).CGColor
        audioView.layer.cornerRadius = 10
        audioView.layer.masksToBounds = true
        */
        
    }
//    
//    func textViewDidChange(textView: UITextView) {
//        
//        let contentSize = self.sizeThatFits(self.comTxtView.bounds.size)
//        var frame = self.comTxtView.frame
//        frame.size.height = contentSize.height
//        self.comTxtView.frame = frame
//        
//        let aspectRatioTextViewConstraint = NSLayoutConstraint(item: self.comTxtView, attribute: .Height, relatedBy: .Equal, toItem: self.comTxtView, attribute: .Width, multiplier: comTxtView.bounds.height/comTxtView.bounds.width, constant: 1)
//        self.comTxtView.addConstraint(aspectRatioTextViewConstraint)
//        
//    }
    
    
    
    // MARK: Actions
    
    @IBAction func like(sender: AnyObject) {
        
        // quando o botão like é clicado, ele é bloqueado e no lugar dele aparece uma image view com a mesma imagem, em vermelho
        
        likeBtn.enabled = false
        
        likeBtn.setImage(UIImage(named: "like_btn"), forState: UIControlState.Normal)
        
        
        
        //aqui deve atualizar o label dos números de likes (likeNberLabel)
        
        //aqui deve tirar 1 ponto de participação do usuário que usa o botão
        
        //aqui o usuário do post deve ganhar 5 pontos de colaboração
        
        //aqui desativar o botão like quando o usuário é o autor do post
        
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  DonutView.swift
//  Chompers
//
//  Created by Alex Hartwell on 10/14/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation
import UIKit

class DonutView: UIView {
    
    static var donutSize: CGFloat = UIScreen.main.bounds.width * 0.2
    
    var donuts: [SingleDonut] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.didLoad()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.didLoad()
    }
    
    func didLoad() {
        self.backgroundColor = UIColor.psych5
        self.clipsToBounds = true
        var row: Int = 0
        var startingX: CGFloat = 0
        var startingY: CGFloat = 0
        while startingY < UIScreen.main.bounds.height {
            let donut = SingleDonut()
            self.donuts.append(donut)
            self.addSubview(donut)
            donut.frame = CGRect(x: startingX, y: startingY, width: DonutView.donutSize, height: DonutView.donutSize)
            startingX += DonutView.donutSize * (CGFloat(arc4random_uniform(1)) * 0.5 + 1.25)
            if startingX > UIScreen.main.bounds.width {
                row += 1
                if (row % 2 == 0) {
                    startingX = 0
                } else {
                    startingX = -DonutView.donutSize / 2
                }
                startingY += DonutView.donutSize * (CGFloat(arc4random_uniform(1)) * 0.5 + 0.75)
            }
        }
    }
    
    func startAnimations() {
        for donut in donuts {
            donut.startAnimation()
        }
    }
    
}

class SingleDonut: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.didLoad()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.didLoad()
    }
    
    func didLoad() {
        self.alpha = 0
        self.layer.borderColor = UIColor.psych4.cgColor
        self.layer.cornerRadius = DonutView.donutSize / 2
        self.layer.borderWidth = DonutView.donutSize / 5
    }
    
    
    func startAnimation() {
        self.setStartingTransform()
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 1
        })
        self.animate()
    }
    
    func setStartingTransform() {
        self.transform = self.getRandomTransform()
    }
    
    private func getRandomTransform() -> CGAffineTransform {
        let transform = CGFloat(arc4random_uniform(2)) * 0.2 + 0.2
        return CGAffineTransform.init(scaleX: transform, y: transform)
    }
    
    func animate() {
        UIView.animate(withDuration: Double(arc4random_uniform(3)) * 0.3 + 2, animations: {
            self.transform = self.getRandomTransform()
        }, completion: { done in
            if done {
                self.animate()
            }
        })
    }
    
    
}

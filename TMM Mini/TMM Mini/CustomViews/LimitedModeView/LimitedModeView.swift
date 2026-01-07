//
//  LimitedModeView.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 05/01/26.
//

import QuartzCore
import UIKit

class LimitedModeView: UIView {

    @IBOutlet weak var viewRings: FitnessRingsView!
    @IBOutlet weak var iconWalk: UIImageView!
    @IBOutlet weak var iconChart: UIImageView!

    var closureAction: ((_ enable: Bool, _ cancel: Bool) -> Void)?

    func setUpUI() {
        
        self.viewRings.configure(outerRingSize: 128)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.viewRings.setProgress(move: 1.15, exercise: 0.8)
        }
        
        self.iconWalk.image = UIImage(systemName: "figure.walk.circle")?.withRenderingMode(.alwaysTemplate)
        self.iconWalk.tintColor = .icnWalk
        
        self.iconChart.image = UIImage(systemName: "chart.line.uptrend.xyaxis")?.withRenderingMode(.alwaysTemplate)
        self.iconChart.tintColor = .icnStep
    }

    @IBAction func enableAction(_ sender: UIButton) {
        self.closureAction?(true, false)
    }

    @IBAction func continueAction(_ sender: UIButton) {
        self.closureAction?(false, true)
    }

}

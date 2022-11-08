//
//  MCTTapButton.swift
//  MotorControl
//

#if os(iOS)

import Foundation
import UIKit
import Research
import ResearchUI

@IBDesignable public final class MCTTapButton : UIButton, RSDViewDesignable {

    /// Override layout subviews to draw a rounded button with a white border around it.
    override public func layoutSubviews() {
        super.layoutSubviews()
        layer.borderWidth = 4
        layer.borderColor = UIColor.white.cgColor
        layer.cornerRadius = self.bounds.height / 2.0
    }
    
    /// Override initializer to set the title to the localized button title.
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    /// Override initializer to set the title to the localized button title.
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    /// Performs the operations common to all initializers of this class.
    /// Default localizes the button's title.
    private func commonInit() {
        let title = Localization.localizedString("TAP_BUTTON_TITLE")
        self.setTitle(title, for: UIControl.State.normal)
        updateColors()
    }
    
    public private(set) var backgroundColorTile: RSDColorTile?
    
    public private(set) var designSystem: RSDDesignSystem?
    
    public func setDesignSystem(_ designSystem: RSDDesignSystem, with background: RSDColorTile) {
        self.designSystem = designSystem
        self.backgroundColorTile = background
        updateColors()
    }
    
    func updateColors() {
        let designSystem = self.designSystem ?? RSDDesignSystem()
        let colorTile = designSystem.colorRules.palette.secondary.normal
        self.backgroundColor = colorTile.color
        
        // Set the title color for each of the states used by this button
        let states: [RSDControlState] = [.normal, .highlighted, .disabled]
        states.forEach {
            let titleColor = designSystem.colorRules.roundedButtonText(on: colorTile, with: .primary, forState: $0)
            setTitleColor(titleColor, for: $0.controlState)
        }
        
        // Set the title font to the font for a rounded button.
        titleLabel?.font = designSystem.fontRules.buttonFont(for: .primary, state: .normal)
    }
}

#endif

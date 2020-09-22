/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import UIKit

class NSStatsticsModuleHeader: UIView {
    private let arrowImage = UIImageView(image: UIImage(named: "ic-verified-user-badge"))
    private let counterLabel = NSLabel(.statsCounter,
                                       textColor: UIColor.setColorsForTheme(lightColor: .ns_darkBlueBackground, darkColor: .white),
                                       textAlignment: .center)
    private let subtitle = NSLabel(.textLight, textColor: .ns_blue, textAlignment: .center)
    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesSignificantDigits = false
        formatter.maximumFractionDigits = 2
        formatter.roundingMode = .halfEven
        return formatter
    }()

    init() {
        super.init(frame: .zero)

        addSubview(arrowImage)
        addSubview(counterLabel)
        addSubview(subtitle)

        arrowImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(-(arrowImage.image?.size.height ?? 0) / 2 - 5)
        }

        counterLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(arrowImage.snp.bottom).inset(12)
        }

        subtitle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(counterLabel.snp.bottom).inset(-NSPadding.small)
            make.bottom.equalToSuperview()
        }

        counterLabel.text = "stats_counter".ub_localized.replacingOccurrences(of: "{COUNT}", with: "--")
        subtitle.text = "stats_title".ub_localized

        counterLabel.alpha = 0
        subtitle.alpha = 0
    }

    fileprivate struct AnimationValues {
        var displayLink: CADisplayLink
        var startTime: CFTimeInterval
        var duration: CFTimeInterval
        var startCount: Int
        var targetCount: Int
    }

    fileprivate var animationValues: AnimationValues?

    private var currentNumber: Int = 0

    func setCounter(number: Int?) {
        guard let number = number else {
            self.counterLabel.alpha = 0
            self.subtitle.alpha = 0
            return
        }

        UIView.animate(withDuration: 0.1) {
            self.counterLabel.alpha = 1
            self.subtitle.alpha = 1
        }
        
        guard currentNumber != number else { return }

        let displayLink = CADisplayLink(target: self, selector: #selector(updateDisplayLink))
        displayLink.add(to: .main, forMode: .default)

        animationValues = .init(displayLink: displayLink,
                                startTime: CACurrentMediaTime(),
                                duration: 0.6,
                                startCount: currentNumber,
                                targetCount: number)


        self.currentNumber = number
    }

    @objc func updateDisplayLink() {
        guard let animationValues = animationValues else {
            return
        }
        let elapsed = CACurrentMediaTime() - animationValues.startTime
        let progress = min(elapsed / animationValues.duration, 1.0)
        // easeOut function
        let newNumber = animationValues.startCount + Int(Double(animationValues.targetCount - animationValues.startCount) * sin(progress * Double.pi / 2.0) + 0.01)

        if progress == 1.0 {
            self.animationValues?.displayLink.invalidate()
            self.animationValues = nil
        }

        let numberInMillions = Double(newNumber) / 1_000_000
        if let formattedNumber = formatter.string(from: numberInMillions as NSNumber) {
            counterLabel.text = "stats_counter".ub_localized.replacingOccurrences(of: "{COUNT}", with: formattedNumber)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  FitnessRingsView.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 05/01/26.
//

import MKRingProgressView
import UIKit

final class FitnessRingsView: UIView {

    // MARK: - Ring Views
    private let outerRing = RingProgressView()
    private let middleRing = RingProgressView()

    // MARK: - Layout Config (defaults for XIB)
    private(set) var outerSize: CGFloat = 140
    private var ringWidth: CGFloat = 18
    private var ringGap: CGFloat = 3

    private var middleSize: CGFloat {
        outerSize - (ringWidth * 2) - (ringGap * 2)
    }

    private var innerSize: CGFloat {
        middleSize - (ringWidth * 2) - (ringGap * 2)
    }

    private var didSetup = false

    // MARK: - Init (Programmatic)
    init(
        outerRingSize: CGFloat,
        ringWidth: CGFloat = 18,
        ringGap: CGFloat = 3
    ) {
        self.outerSize = outerRingSize
        self.ringWidth = ringWidth
        self.ringGap = ringGap
        super.init(frame: .zero)

        commonInit()
    }

    // MARK: - Init (XIB)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
    }

    func configure(outerRingSize: CGFloat) {
        self.outerSize = outerRingSize
        invalidateIntrinsicContentSize()
        setNeedsLayout()
        layoutIfNeeded()
    }

    // MARK: - Layout (runs after XIB loads)
    override func layoutSubviews() {
        super.layoutSubviews()

        guard !didSetup else { return }
        didSetup = true

        setupRings()
        layoutRings()
    }

    // MARK: - Setup
    private func setupRings() {
        configure(
            ring: outerRing,
            startColor: .systemRed,
            endColor: .systemPink
        )
        configure(
            ring: middleRing,
            startColor: .systemGreen,
            endColor: .systemMint
        )
    }

    private func configure(
        ring: RingProgressView,
        startColor: UIColor,
        endColor: UIColor
    ) {
        ring.translatesAutoresizingMaskIntoConstraints = false
        ring.startColor = startColor
        ring.endColor = endColor
        ring.ringWidth = ringWidth
        ring.progress = 0
        ring.backgroundColor = .clear
        addSubview(ring)
    }

    // MARK: - Layout
    private func layoutRings() {
        NSLayoutConstraint.activate([
            outerRing.centerXAnchor.constraint(equalTo: centerXAnchor),
            outerRing.centerYAnchor.constraint(equalTo: centerYAnchor),
            outerRing.widthAnchor.constraint(equalToConstant: outerSize),
            outerRing.heightAnchor.constraint(equalToConstant: outerSize),

            middleRing.centerXAnchor.constraint(equalTo: centerXAnchor),
            middleRing.centerYAnchor.constraint(equalTo: centerYAnchor),
            middleRing.widthAnchor.constraint(equalToConstant: middleSize),
            middleRing.heightAnchor.constraint(equalToConstant: middleSize),
        ])
    }

    // MARK: - Public API (Animation)
    func setProgress(
        move: CGFloat,
        exercise: CGFloat,
        animated: Bool = true
    ) {
        let updates = {
            self.outerRing.progress = move
            self.middleRing.progress = exercise
        }

        if animated {
            UIView.animate(
                withDuration: 0.9,
                delay: 0.4,
                options: .curveEaseOut,
                animations: updates
            )
        } else {
            updates()
        }
    }

    func reset() {
        setProgress(move: 0, exercise: 0, animated: false)
    }
}

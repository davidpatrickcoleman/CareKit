/*
 Copyright (c) 2019, Apple Inc. All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.

 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.

 3. Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import UIKit

/// A card that displays a header, multi-line label, and a completion button. In CareKit, this view is
/// intended to display a particular event for a task. The state of the completion button indicates
/// the completion state of the event.
///
/// To insert custom views vertically the view, see `contentStack`
///
///     +-------------------------------------------------------+
///     |                                                       |
///     | [title]                                [detail        |
///     | [detail]                               disclosure]    |
///     |                                                       |
///     |                                                       |
///     |  --------------------------------------------------   |
///     |                                                       |
///     |   [instructions]                                      |
///     |                                                       |
///     |  +-------------------------------------------------+  |
///     |  |                    [title]                      |  |
///     |  +-------------------------------------------------+  |
///     |                                                       |
///     +-------------------------------------------------------+
///
open class OCKInstructionsTaskView: OCKView, OCKEventDisplayable {
    // MARK: Properties

    let contentView = OCKView()

    private lazy var cardAssembler = OCKCardAssembler(cardView: self, contentView: contentView)

    /// A vertical stack view that holds the main content for the view.
    public let contentStackView: OCKStackView = {
        let stack = OCKStackView()
        stack.axis = .vertical
        return stack
    }()

    /// Handles events related to an `OCKEventDisplayable` object.
    public weak var delegate: OCKEventViewDelegate?

    /// The button on the bottom of the view. The background color is the `tintColor` when in a normal state. and gray when
    /// in a selected state. Also supports a `titleLabel`.
    public let completionButton: OCKButton = OCKLabeledButton()

    /// Multi-line label over the `completionButton`.
    public let instructionsLabel: OCKLabel = {
        let label = OCKLabel(textStyle: .subheadline, weight: .medium)
        label.numberOfLines = 0
        return label
    }()

    /// A header view that tshows a separator and a `detailDisclosureImage`.
    public let headerView = OCKHeaderView {
        $0.showsSeparator = true
        $0.showsDetailDisclosure = true
    }

    // MARK: Methods

    override func setup() {
        super.setup()
        addSubviews()
        styleSubviews()
        constrainSubviews()
        setupGestures()
    }

    private func setupGestures() {
        let tappedViewGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        headerView.addGestureRecognizer(tappedViewGesture)

        completionButton.addTarget(self, action: #selector(completionButtonTapped(_:)), for: .touchUpInside)
    }

    private func styleSubviews() {
        contentStackView.setCustomSpacing(0, after: completionButton)
    }

    private func addSubviews() {
        addSubview(contentView)
        contentView.addSubview(contentStackView)
        [headerView, instructionsLabel, completionButton].forEach { contentStackView.addArrangedSubview($0) }
    }

    private func constrainSubviews() {
        [contentView, contentStackView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        NSLayoutConstraint.activate(
            contentStackView.constraints(equalTo: contentView) +
            contentView.constraints(equalTo: layoutMarginsGuide))
    }

    @objc
    private func didTapView() {
        delegate?.didSelectEventView(self)
    }

    @objc
    private func completionButtonTapped(_ sender: OCKButton) {
        delegate?.eventView(self, didCompleteEvent: sender.isSelected, sender: sender)
    }

    override open func styleDidChange() {
        super.styleDidChange()
        let cachedStyle = style()
        cardAssembler.enableCardStyling(true, style: cachedStyle)
        instructionsLabel.textColor = cachedStyle.color.label
        contentStackView.spacing = cachedStyle.dimension.directionalInsets1.top
        directionalLayoutMargins = cachedStyle.dimension.directionalInsets1
    }
}

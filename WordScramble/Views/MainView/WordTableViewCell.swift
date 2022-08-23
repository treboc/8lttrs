//
//  WordTableViewCell.swift
//  WordScramble
//
//  Created by Marvin Lee Kobert on 11.08.22.
//

import UIKit

class WordTableViewCell: UITableViewCell {
  static var identifier: String {
    String(describing: self)
  }

  private let pointsImage = UIImageView()
  private let wordLabel = UILabel()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.selectionStyle = .none
    setupViews()
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func updateLabels(with data: (word: String, points: Int)) {
    pointsImage.image = UIImage(systemName: "\(data.points).circle.fill")
    wordLabel.text = data.word
  }

  private func setupViews() {
    pointsImage.contentMode = .scaleAspectFit
    wordLabel.font = .preferredFont(forTextStyle: .headline)
  }

  private func setupLayout() {
    self.addSubview(pointsImage)
    self.addSubview(wordLabel)

    pointsImage.translatesAutoresizingMaskIntoConstraints = false
    wordLabel.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      pointsImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.widthPadding),
      pointsImage.topAnchor.constraint(equalTo: topAnchor, constant: Constants.widthPadding),
      pointsImage.widthAnchor.constraint(greaterThanOrEqualToConstant: Constants.widthPadding * 2),
      pointsImage.heightAnchor.constraint(equalTo: pointsImage.widthAnchor),
      pointsImage.centerYAnchor.constraint(equalTo: centerYAnchor),

      wordLabel.leadingAnchor.constraint(equalTo: pointsImage.trailingAnchor, constant: Constants.widthPadding),
      wordLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.widthPadding),
      wordLabel.widthAnchor.constraint(equalTo: widthAnchor, constant: -(2*Constants.widthPadding) + pointsImage.frame.width),
      wordLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.widthPadding),
      wordLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
    ])
  }
}
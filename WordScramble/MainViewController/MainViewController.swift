//
//  MainViewController.swift
//  WordScramble
//
//  Created by Marvin Lee Kobert on 11.08.22.
//

import Combine
import UIKit

class MainViewController: UIViewController, UITextFieldDelegate, MenuViewControllerDelegate {
  var gameService: GameServiceProtocol

  var mainView: MainView {
    view as! MainView
  }

  init(gameService: GameServiceProtocol = GameService(scoreService: ScoreService())) {
    self.gameService = gameService
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - loadView()
  override func loadView() {
    view = MainView()
  }

  // MARK: - viewDidLoad()
  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavigationController()
    setupActions()
    startGame()
    mainView.tableView.dataSource = self
    mainView.tableView.delegate = self
    mainView.wordTextField.delegate = self
  }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return gameService.usedWords.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: WordTableViewCell.identifier, for: indexPath) as! WordTableViewCell
    cell.word = gameService.usedWords[indexPath.row]
    cell.selectionStyle = .none
    return cell
  }
}

extension MainViewController {
  func setupNavigationController() {
    self.navigationItem.largeTitleDisplayMode = .always
    self.navigationController?.navigationBar.prefersLargeTitles = true
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.circle"), style: .plain, target: self, action: #selector(showMenu))
  }

  func setupActions() {
    mainView.wordTextField.addTarget(self, action: #selector(submit), for: .primaryActionTriggered)
    mainView.submitButton.addTarget(self, action: #selector(submit), for: .touchUpInside)
    self.hideKeyboardOnTap()
  }

  @objc
  private func showMenu() {
    let menuVC = MenuViewController()
    menuVC.delegate = self
    let menuNavVC = UINavigationController(rootViewController: menuVC)
    present(menuNavVC, animated: true)
  }

  @objc
  func startGame() {
    gameService.startGame { [weak self] currentWord in
      self?.title = currentWord
      mainView.scorePointsLabel.text = "\(gameService.currentScore)"
      mainView.tableView.reloadData()
    }
  }

  @objc
  func resetGame() {
    if gameService.usedWords.isEmpty {
      startGame()
    } else {
      let ac = UIAlertController(title: "Are you sure?", message: "When you reset the game, all words and your score will be reset.", preferredStyle: .alert)
      let resetAction = UIAlertAction(title: "Yes, I'm sure!", style: .destructive) { [weak self] _ in
        self?.startGame()
      }
      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
      ac.addAction(resetAction)
      ac.addAction(cancelAction)
      present(ac, animated: true)
    }
  }

  @objc
  func endGame() {
    let ac = UIAlertController(title: "Ending game..", message: "To save your highscore, we need your name!", preferredStyle: .alert)
    ac.addTextField()
    let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
      guard let name = ac.textFields?[0].text else { return }
      self?.gameService.endGame(playerName: name)
      self?.startGame()
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    ac.addAction(saveAction)
    ac.addAction(cancelAction)
    present(ac, animated: true)
  }

  @objc
  func submit() {
    guard
      let answer = mainView.wordTextField.text,
      !answer.isEmpty
    else { return }
    do {
      try gameService.submitAnswerWith(answer, onCompletion: updateUIAfterSumbission)
    } catch let error as WordError {
      presentAlertControllert(with: error.alert)
    } catch {
      fatalError(error.localizedDescription)
    }
  }

  func presentAlertControllert(with alert: Alert) {
    let ac = UIAlertController(title: alert.title, message: alert.message, preferredStyle: .alert)
    let defaultAction = UIAlertAction(title: "OK", style: .default)
    ac.addAction(defaultAction)
    present(ac, animated: true)
  }

  private func updateUIAfterSumbission() {
    let indexPath = IndexPath(row: 0, section: 0)
    mainView.tableView.insertRows(at: [indexPath], with: .left)
    mainView.scorePointsLabel.text = "\(gameService.currentScore)"
    mainView.wordTextField.text?.removeAll()
  }
}

// MARK: - Handle dismiss keyboard on tap
extension MainViewController {
  fileprivate func hideKeyboardOnTap() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)
  }

  @objc
  fileprivate func hideKeyboard() {
    view.endEditing(true)
  }
}
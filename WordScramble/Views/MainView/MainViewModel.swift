//
//  MainViewModel.swift
//  WordScramble
//
//  Created by Marvin Lee Kobert on 06.09.22.
//

import Combine
import Foundation
import AVFAudio

final class MainViewModel {
  var audioPlayer: AVAudioPlayer?
  let gameAPI: GameAPI
  var session: Session

  var input = CurrentValueSubject<String, Never>("")
  var error = CurrentValueSubject<WordError?, Never>(nil)
  var resetCallback: (() -> Void)? = nil

  private var subscriptions = Set<AnyCancellable>()

  init(gameType: GameType = .continueLastSession) {
    self.gameAPI = GameAPI()
    self.session = gameAPI.continueLastSession()

    switch gameType {
    case .random:
      self.session = gameAPI.startGame(.random)
    case .shared(let word):
      self.session = gameAPI.startGame(.shared(word))
    case .continueLastSession:
      self.session = gameAPI.startGame(.continueLastSession)
    }
  }

  func submit(onCompletion: () -> Void) {
    do {
      try gameAPI.submit(input.value, session: session)
      onCompletion()
      HapticManager.shared.success()
      playSound(.success)
    } catch let error as WordError {
      HapticManager.shared.error()
      playSound(.error)
      self.error.send(error)
    } catch {
      fatalError(error.localizedDescription)
    }
  }

  func startNewSession() {
    self.session = gameAPI.randomWordSession()
    resetCallback?()
  }
}

// MARK: - Calculation of Scores
extension MainViewModel {
  private func playSound(_ type: SoundType) {
    if UserDefaults.standard.bool(forKey: UserDefaultsKeys.enabledSound) {
      DispatchQueue.global(qos: .userInteractive).async { [weak self] in
        do {
          self?.audioPlayer = try AVAudioPlayer(contentsOf: type.fileURL)
          self?.audioPlayer?.play()
        } catch {
          print(error.localizedDescription)
        }
      }
    }
  }
}

//
//  MenuView.swift
//  WordScramble
//

import UIKit
import SwiftUI

struct MenuView: View {
  @State var showModal: Bool = true
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject private var mainViewModel: MainViewModel

  @AppStorage(UserDefaultsKeys.enabledVibration) private var enabledVibration = true
  @AppStorage(UserDefaultsKeys.enabledSound) private var enabledSound = true
  @AppStorage(UserDefaultsKeys.enabledFiltering) private var enabledFiltering = true
  @AppStorage(UserDefaultsKeys.regionCode) private var chosenBasewordLocale: WSLocale = .DE

  @State private var alertModel: AlertToPresent? = nil
  @State private var endGameViewIsShown: Bool = false

  var body: some View {
    NavigationView {
      Form {
        Section {
          restartSessionButton
          endSessionButton
          ShareSessionButton(session: mainViewModel.session)
          showHighscoreNavLink
        }

        Section {
          basewordLanguagePicker
          enableVibrationToggle
          enableSoundToggle
          enableFilteringToggle
        } header: {
          Text(L10n.MenuView.settings)
        } footer: {
          Text(L10n.MenuView.filterDescription)
        }
        .tint(.accentColor)

        Section("Contact Me") {
          twitterLink
          NavigationLink(L10n.LegalNoticeView.title, destination: LegalNoticeView.init)
        }

#if DEBUG
        Section("Development") {
          Button("Reset Onboarding") {
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.isFirstStart)
          }
        }
        allPossibleWordsSection_DEV
#endif
      }
      .sheet(isPresented: $endGameViewIsShown, onDismiss: endGameViewDismissed) {
        EndSessionView(session: mainViewModel.session)
      }
      .toolbar {
        ToolbarItem {
          Button(action: dismiss.callAsFunction) {
            Label(L10n.ButtonTitle.close, systemImage: "x.circle.fill")
              .foregroundColor(.accentColor)
          }
        }
      }
      .presentAlert(with: $alertModel)
      .navigationTitle(L10n.MenuView.title)
      .roundedNavigationTitle()
      .environmentObject(mainViewModel)
    }
    .navigationViewStyle(.stack)
    .environment(\.modalMode, self.$showModal)
    .onChange(of: showModal, perform: dismissModal)
  }

}

#if DEBUG
// MARK: - Views
extension MenuView {
  private var allPossibleWordsSection_DEV: some View {
    Section("Possible words for *\(mainViewModel.session.unwrappedBaseword)*") {
      List {
        ForEach(Array(mainViewModel.session.possibleWords).sorted(), id: \.self) { word in
          HStack {
            Text(word)
              .strikethrough(mainViewModel.session.usedWords.contains(word), color: .accentColor)

            Spacer()
            
            if mainViewModel.session.usedWords.contains(word) {
              Image(systemName: "checkmark.circle")
                .symbolRenderingMode(.palette)
                .foregroundStyle(.green, .quaternary)
            } else {
              Image(systemName: "circle")
                .foregroundStyle(.quaternary)
            }
          }
        }
      }
    }
  }
}
#endif

// MARK: - Methods
extension MenuView {
  private func didReceiveWSLocaleChange(_ locale: WSLocale) {
    alertModel = AlertToPresent(simpleAlert: true,
                                title: L10n.MenuView.ChangedLanguage.title,
                                message: L10n.MenuView.ChangedLanguage.message,
                                primaryAction: {})
  }

  private func restartSessionTapped() {
    if !mainViewModel.session.usedWords.isEmpty {
      self.alertModel = AlertToPresent(title: L10n.ResetGameAlert.title,
                                       message: L10n.ResetGameAlert.message) {
        mainViewModel.startNewSession()
        showModal = false
      }
    } else {
      mainViewModel.startNewSession()
      showModal = false
    }
  }

  private func endSessionTapped() {
    self.alertModel = AlertToPresent(title: L10n.EndGameAlert.title,
                                     message: L10n.EndGameAlert.message) {
      endGameViewIsShown.toggle()
    }
  }

  private func endGameViewDismissed() {
    showModal = false
    mainViewModel.startNewSession()
  }

  private func dismissModal(_ showModal: Bool) {
    if showModal == false {
      dismiss()
    }
  }
}

extension MenuView {
  private var restartSessionButton: some View {
    Button(action: restartSessionTapped) {
      HStack {
        Image(systemName: "arrow.counterclockwise.circle.fill")
          .font(.system(.title2, design: .rounded, weight: .bold))
        Text(L10n.MenuView.restartSession)
      }
    }
  }

  private var endSessionButton: some View {
    Button(action: endSessionTapped) {
      HStack {
        Image(systemName: "stop.circle.fill")
          .font(.system(.title2, design: .rounded, weight: .bold))
        Text(L10n.MenuView.endSession)
      }
    }
    .disabled(mainViewModel.session.usedWords.isEmpty)
    .accessibilityIdentifier("endSessionBtn")
  }

  private var showHighscoreNavLink: some View {
    NavigationLink(L10n.MenuView.showHighscore) {
      HighscoreListView()
        .environment(\.managedObjectContext, PersistenceController.shared.context)
    }
    .accessibilityIdentifier("showHighscoreNavLink")
  }

  private var twitterLink: some View {
    Link(destination: Constants.twitterURL) {
      HStack {
        Text("@treb0c")
        Spacer()
        Image(systemName: "arrow.up.right")
      }
    }
    .accessibilityLabel("Twitterhandle treboc")
  }

  private var basewordLanguagePicker: some View {
    Picker(selection: $chosenBasewordLocale) {
      ForEach(WSLocale.availableLanguages()) { locale in
        Text(locale.description)
          .tag(locale)
      }
    } label: {
      HStack {
        Image(systemName: "book.circle.fill")
          .font(.system(.title2, design: .rounded, weight: .bold))
          .foregroundColor(.accentColor)
        Text(L10n.MenuView.baseword)
      }
    }
    .onChange(of: chosenBasewordLocale, perform: didReceiveWSLocaleChange)
  }

  private var enableVibrationToggle: some View {
    Toggle(isOn: $enabledVibration) {
      HStack {
        Image(systemName: enabledVibration ? "iphone.radiowaves.left.and.right.circle.fill" : "iphone.slash.circle.fill")
          .font(.system(.title2, design: .rounded, weight: .bold))
          .foregroundColor(.accentColor)
        Text(L10n.MenuView.hapticFeedback)
      }
    }
  }

  private var enableSoundToggle: some View {
    Toggle(isOn: $enabledSound) {
      HStack {
        Image(systemName: enabledSound ? "speaker.circle.fill" : "speaker.slash.circle.fill")
          .font(.system(.title2, design: .rounded, weight: .bold))
          .foregroundColor(.accentColor)
        Text(L10n.MenuView.sound)
      }
    }
  }

  private var enableFilteringToggle: some View {
    Toggle(isOn: $enabledFiltering) {
      HStack {
        Image(systemName: "magnifyingglass.circle.fill")
          .font(.system(.title2, design: .rounded, weight: .bold))
          .foregroundColor(.accentColor)
        Text(L10n.MenuView.filter)
      }
    }
  }
}

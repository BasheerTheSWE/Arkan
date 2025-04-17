//
//  SettingsView.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import SwiftUI
import MessageUI
import WidgetKit

struct SettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var isAttemptingToDeleteRecordings = false
    @State private var didDeleteRecordings = false
    
    @State private var contactSubject: ContactSubject?
    @State private var userCanNotSendMail = false
    
    @State private var isPresentingRateUs = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    PrayerTimeFormatPicker()
                } header: {
                    Text("General")
                        .font(.system(size: 12))
                }
                
                Section {
                    UpdateLocationButton()
                } header: {
                    Text("Location")
                        .font(.system(size: 12))
                } footer: {
                    Text("Location updates automatically. If you’re experiencing issues, you can update it manually.")
                        .font(.system(size: 10))
                }
                
                Section {
                    AdhanSoundPicker()
                } header: {
                    Text("Notifications")
                        .font(.system(size: 12))
                }
                
                Section {
                    SettingsRowCell(title: "Rate Us", systemImage: "heart.fill") {
                        isPresentingRateUs = true
                    }
                    .sheet(isPresented: $isPresentingRateUs) {
                        RatingRequestView()
                    }
                    
                    if let url = URL(string: "https://apps.apple.com/us/app/transcribe-speech-to-text/id6743344111") {
                        ShareLink(item: url) {
                            HStack {
                                Image(systemName: "sharedwithyou")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 14, height: 14)
                                    .padding(.trailing, 8)
                                
                                Text("Share The App with Others")
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundStyle(Color(.label))
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 8, height: 8)
                            }
                        }
                    }
                } header: {
                    Text("About")
                        .font(.system(size: 12))
                }
                
                Section {
                    SettingsRowCell(title: "Contact Us", systemImage: "paperplane.fill") {
                        contact(about: .contactUs)
                    }
                    
                    SettingsRowCell(title: "Request a Feature", systemImage: "hands.sparkles.fill") {
                        contact(about: .featureRequest)
                    }
                    
                    SettingsRowCell(title: "Report a Bug", systemImage: "ladybug.fill") {
                        contact(about: .bugReport)
                    }
                } header: {
                    Text("Contact")
                        .font(.system(size: 12))
                }
                
                if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                   let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                    Section {
                        HStack {
                            Text("Version")
                            
                            Spacer()
                            
                            Text(version + " (\(build))")
                                .foregroundStyle(.secondary)
                        }
                        .font(.system(size: 14, design: .rounded))
                    }
                }
                
                Section {
                    (
                        Text("App By ")
                        + Text("[Basheer Abdulmalik](https://www.x.com/BasheerTheSWE)").underline()
                    )
                    .font(.caption)
                    .fontDesign(.rounded)
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    PlainIconButton(systemImage: "xmark", size: 12) {
                        dismiss()
                    }
                }
            }
            .alert("Recordings Deleted", isPresented: $didDeleteRecordings, actions: {}) {
                Text("All your recordings have been successfully deleted.")
            }
            .sheet(item: $contactSubject) { subject in
                MailComposeView(subject: subject.rawValue)
            }
            .alert("Unable to Send Mail", isPresented: $userCanNotSendMail, actions: {}) {
                Text("It seems like your device isn’t set up to send emails. Please check your email account settings and try again.\n\nAlternatively you can reach us on\nx.com - @BasheerTheSWE")
            }
        }
    }
    
    private func contact(about subject: ContactSubject) {
        if MFMailComposeViewController.canSendMail() {
            contactSubject = subject
        } else {
            userCanNotSendMail = true
        }
    }
}

// MARK: - SETTINGS REUSABLE VIEWS
private struct SettingsPlainRowCell: View {
    
    let title: String
    let tint: Color
    let action: () -> ()
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(tint)
        }
    }
}

private struct SettingsRowCell: View {
    
    let title: String
    let systemImage: String
    let action: () -> ()
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Image(systemName: systemImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 14, height: 14)
                    .padding(.trailing, 8)
                
                Text(title)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(Color(.label))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 8, height: 8)
            }
        }
    }
}

// MARK: - PRAYER TIME PICKER
private struct PrayerTimeFormatPicker: View {
    
    @AppStorage(UDKey.prefers24HourTimeFormat.rawValue) private var prefers24HourTimeFormat = false
    
    @State private var prefers24HourTimeFormatState = UserDefaults.shared.bool(forKey: UDKey.prefers24HourTimeFormat.rawValue)
    
    var body: some View {
        HStack {
            Image(systemName: "clock")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 14, height: 14)
                .padding(.trailing, 8)
            
            Text("Prayer Time Format")
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(Color(.label))
            
            Spacer()
            
            Button {
                withAnimation {
                    prefers24HourTimeFormatState.toggle()
                }
            } label: {
                Text(prefers24HourTimeFormatState ? "24 hrs" : "12 hrs")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 75, height: 30)
                    .background(Color(.secondarySystemFill))
                    .clipShape(.rect(cornerRadius: 4))
                    .contentTransition(.numericText())
            }
            .buttonStyle(.borderless)
            .onChange(of: prefers24HourTimeFormatState) { _, _ in
                prefers24HourTimeFormat = prefers24HourTimeFormatState
            }
        }
    }
}

// MARK: - LOCATION
private struct UpdateLocationButton: View {
    
    @AppStorage(UDKey.city.rawValue) private var city = ""
    @AppStorage(UDKey.country.rawValue) private var country = ""
    
    @AppStorage(UDKey.latitude.rawValue) private var latitude = 0.0
    @AppStorage(UDKey.longitude.rawValue) private var longitude = 0.0
    
    @State private var locationFetcher = LocationFetcher()
    @State private var isUpdatingLocation = false
    @State private var didSucceedToUpdateLocation = false
    @State private var didFailToUpdateLocation = false
    
    var body: some View {
        Button {
            updateLocation()
        } label: {
            HStack {
                Image(systemName: "location.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 14, height: 14)
                    .padding(.trailing, 8)
                
                Text("Manually Update Location")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(Color(.label))
                
                Spacer()
                
                if isUpdatingLocation {
                    ProgressView()
                        .controlSize(.small)
                        .transition(.blurReplace)
                }
                
                Image(systemName: "chevron.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 8, height: 8)
            }
        }
        .disabled(isUpdatingLocation)
        .alert("Failed to Update Location", isPresented: $didFailToUpdateLocation) {} message: {
            Text("An error occurred while updating you location.\n\nThis might be due to a network issue, so make sure you have a stable connection or try again later.")
        }
        .alert("Location Updated", isPresented: $didSucceedToUpdateLocation) {} message: {
            Text("Your location was updated successfully." + (!city.isEmpty && !country.isEmpty ? "\n\n\(city), \(country)" : "") + (latitude != 0.0 && longitude != 0.0 ? "\n\(latitude)\n\(longitude)" : ""))
        }
    }
    
    private func updateLocation() {
        withAnimation { isUpdatingLocation = true }
        
        Task {
            do {
                try await locationFetcher.updateUserLocation()
                didSucceedToUpdateLocation = true
            } catch {
                print(error.localizedDescription)
                didFailToUpdateLocation = true
            }
            
            withAnimation { isUpdatingLocation = false }
        }
    }
}

// MARK: - ADHAN SOUND PICKER
private struct AdhanSoundPicker: View {
    
    @AppStorage(UDKey.selectedNotificationsSound.rawValue) private var selectedNotificationsSound = 0
    
    @State private var selectedNotificationsSoundState = UserDefaults.shared.integer(forKey: UDKey.selectedNotificationsSound.rawValue)
    @State private var isPresentingSounds = false
    
    var body: some View {
        HStack {
            Image(systemName: "bell.badge.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 14, height: 14)
                .padding(.trailing, 8)
            
            Text("Preferred Adhan Sound")
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(Color(.label))
            
            Spacer()
            
            Button {
                isPresentingSounds = true
            } label: {
                Text(String(selectedNotificationsSoundState + 1))
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 75, height: 30)
                    .background(Color(.secondarySystemFill))
                    .clipShape(.rect(cornerRadius: 4))
                    .contentTransition(.numericText())
            }
            .buttonStyle(.borderless)
            .popover(isPresented: $isPresentingSounds) {
                AvailableAdhanSoundsView(selection: $selectedNotificationsSoundState)
                    .presentationCompactAdaptation(.popover)
            }
            .onChange(of: selectedNotificationsSoundState) { _, _ in
                selectedNotificationsSound = selectedNotificationsSoundState
            }
            .animation(.default, value: selectedNotificationsSoundState)
        }
    }
}

private struct AvailableAdhanSoundsView: View {
    
    @Binding var selection: Int
    
    var body: some View {
        VStack {
            ForEach(AvailableNotificationsSound.allCases) { availableSound in
                AvailableNotificationsSoundCell(sound: availableSound, selection: $selection)
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}

private enum AvailableNotificationsSound: String, CaseIterable, Identifiable {
    case systemDefault = "System Default"
    case test1 = "Test Sound 1"
    case test2 = "Test Sound 2"
    case test3 = "Test Sound 3"
    case test4 = "Test Sound 4"
    
    var id: Int {
        AvailableNotificationsSound.allCases.firstIndex(of: self) ?? 0
    }
}

private struct AvailableNotificationsSoundCell: View {
        
    let sound: AvailableNotificationsSound
    @Binding var selection: Int
    
    var body: some View {
        Button {
            withAnimation { selection = sound.id }
        } label: {
            HStack {
                Image(systemName: sound.id == selection ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 12, height: 12)
                
                Text(sound.rawValue)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                
                Spacer()
                
                Button {
                    
                } label: {
                    Image(systemName: "play.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 12, height: 12)
                }
            }
            .padding()
            .frame(width: 250)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 8))
        }
    }
}

#Preview {
    SettingsView()
        .tint(Color(.label))
        .defaultAppStorage(UserDefaults(suiteName: "group.BasheerTheSWE.Arkan.PrayerTime")!)
}

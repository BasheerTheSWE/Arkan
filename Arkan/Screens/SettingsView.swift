//
//  SettingsView.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import SwiftUI
import MessageUI

struct SettingsView: View {
    
    private enum ContactSubject: String, Identifiable {
        case contactUs = "Feedback Regarding Arkan"
        case featureRequest = "Arkan - Feature Request"
        case bugReport = "Arkan - Bug Report"
        
        var id: String { self.rawValue }
    }
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var isAttemptingToDeleteRecordings = false
    @State private var didDeleteRecordings = false
    
    @State private var contactSubject: ContactSubject?
    @State private var userCanNotSendMail = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    PrayerTimeFormatPicker()
                    
                    SettingsRowCell(title: "Update Location", systemImage: "location.north.fill") {
                        
                    }
                } header: {
                    Text("General")
                        .font(.system(size: 12))
                } footer: {
                    Text("Location updates automatically. If you’re experiencing issues, you can update it manually.")
                        .font(.system(size: 10))
                }
                
                Section {
                    SettingsRowCell(title: "Rate Us", systemImage: "heart.fill") {
                        leaveReview()
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
    
    private func leaveReview() {
        if let url = URL(string: "https://apps.apple.com/us/app/transcribe-speech-to-text/id6743344111?action=write-review") {
            UIApplication.shared.open(url)
        }
    }
}

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

private struct PrayerTimeFormatPicker: View {
    
    @AppStorage(UDKey.prefers24HourTimeFormat.rawValue) private var prefers24HourTimeFormat = false
    
    @State private var prefers24HourTimeFormatState = UserDefaults.standard.bool(forKey: UDKey.prefers24HourTimeFormat.rawValue)
    
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

#Preview {
    SettingsView()
        .tint(Color(.label))
}

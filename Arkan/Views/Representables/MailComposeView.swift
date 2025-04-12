//
//  MailComposeView.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 12/04/2025.
//

import SwiftUI
import MessageUI

struct MailComposeView: UIViewControllerRepresentable {
    
    let subject: String
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailComposeVC = MFMailComposeViewController()
        
        mailComposeVC.mailComposeDelegate = context.coordinator
        mailComposeVC.setToRecipients(["basheertheswe@gmail.com"])
        mailComposeVC.setSubject(subject)
        
        return mailComposeVC
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: (any Error)?) {
            controller.dismiss(animated: true)
        }
    }
}

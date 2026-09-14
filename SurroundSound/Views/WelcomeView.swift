//
//  WelcomeView.swift
//  SurroundSound
//
//  Shown once per app launch, on top of the live screen, and dismissed
//  by a tap anywhere. It reappears every cold launch by design.

import SwiftUI

struct WelcomeView: View {
    // Called when the user taps anywhere to proceed.
    var onContinue: () -> Void

    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Color(red: 0 / 255, green: 151 / 255, blue: 178 / 255)
                .ignoresSafeArea()

            VStack(spacing: 10) {

                // Replace "AppLogo" with whatever you name the image set
                // you add to Assets.xcassets for your logo.
                Image("SurroundSound_Full_Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .scaleEffect(appeared ? 1 : 0.85)
                    .opacity(appeared ? 1 : 0)
                                
                VStack(spacing: 6) {
                    Text(introStr.0)
                        .font(.largeTitle.bold())
                    Text(introStr.1)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 8)

                Text("Tap anywhere to continue")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                    .opacity(appeared ? (reduceMotion ? 1 : 0.9) : 0)
                    .animation(
                        reduceMotion ? nil :
                            .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                        value: appeared
                    )
                    .padding(.bottom, 40)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onContinue)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                appeared = true
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Welcome to SurroundSound")
        .accessibilityHint("Double tap to continue")
        .accessibilityAddTraits(.isButton)
    }
    
    private var introStr: (String, String) {
        let introPicker = introPicker()
        let myIntro = introPicker.getIntro()
        return myIntro
    }
}

#Preview {
    WelcomeView(onContinue: {})
}

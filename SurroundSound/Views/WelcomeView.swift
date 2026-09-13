//
//  WelcomeView.swift
//  SurroundSound
//
//  Shown once per app launch, on top of the live screen, and dismissed
//  by a tap anywhere. It's plain @State-driven in RootView, so it
//  reappears every cold launch by design.
//
//  Want it to show only on the very first-ever launch instead? Swap
//  RootView's `@State private var showWelcome = true` for:
//
//      @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
//
//  and flip `hasSeenWelcome = true` in the onContinue closure — same
//  WelcomeView, no changes needed here.
//

import SwiftUI

struct WelcomeView: View {
    // Called when the user taps anywhere to proceed.
    var onContinue: () -> Void

    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 20) {

                // Replace "AppLogo" with whatever you name the image set
                // you add to Assets.xcassets for your logo.
                Image("SurroundSound_Full_Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 240, height: 240)
                    .scaleEffect(appeared ? 1 : 0.85)
                    .opacity(appeared ? 1 : 0)
                
                Spacer()
                
                VStack(spacing: 6) {
                    Text("Welcome")
                        .font(.largeTitle.bold())
                    Text("SurroundSound listens to the world around you.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 8)

                Spacer()

                Text("Tap anywhere to continue")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                    .opacity(appeared ? (reduceMotion ? 1 : 0.4) : 0)
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
}

#Preview {
    WelcomeView(onContinue: {})
}

//
//  introPicker.swift
//  SurroundSound
//
//  Created by Mustafa Mian on 2026-09-13.
//

class introPicker {
    let welcomePhrases: [String] = ["Welcome!", "Hello!", "Hi!", "Hey!", "Hey there!", "Greetings!"]
    let captions: [String] = ["Let's have a productive day.", "What's disrupting your focus?", "Ready to begin?", "Time to study smart.", "Let's tackle that big goal.", "Time to clear distractions.", "Let's take it one step at a time.", "Let's read the room"]
    
    func getIntro() -> (String, String) {
        guard let welcomePhrase = welcomePhrases.randomElement() else { return ("Welcome!", "Let's have a productive day") }
        guard let caption = captions.randomElement() else { return ("Welcome!", "Let's have a productive day") }
        return (welcomePhrase, caption)
    }
    
}

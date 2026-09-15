SurroundSound
---

**BETA TEST HERE:** https://testflight.apple.com/join/NCsH9jBY
(Requires download of Testflight, Apple's Official Beta Testing App)
This app is currently in the process of being deployed to the iOS App Store!

No matter where I study, it feels like there are constant distractions. People talking, music, and even general outdoor ambience can get loud and prevent me from getting work done. I wondered if I could somehow keep track of all the distractions - Like listing which ones are more common, how many times they show up, and judging if an area is good for studying in general. SurroundSound is my solution to this.

SurroundSound helps you understand your study spaces and figure out where you learn best.

The iOS app is built using Swift, SwiftUI, and the SwiftData model. The Audio classification is performed by an Apple Core ML audio classification model. The model itself was trained on hand labeled data in the Audio Dataset repo: https://github.com/Mustafa-Mian/AudioDataset

Users to record their study sessions with their device microphone. The machine learning classification model classifies incoming sounds and saves them. Once a session is complete users can view an overall study score, as well as more granular breakdowns on Environment quality, distractions, and model confidence.

The app is built for privacy. User data never leaves the App. Audio clips are only used in device memory and instantly discarded.

Please give SurroundSound a try! Start studying smarter and discover what is blocking your productivity.

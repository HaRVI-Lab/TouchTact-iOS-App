# TouchTact iOS App

## Table of Contents
- [Description](#description)
- [Features](#features)
- [Requirements](#requirements)
- [Project Structure](#project-structure)
- [Setup for Development](#setup-for-development)
- [Usage](#usage)
- [Key Components](#key-components)
- [License and Citation](#license-and-citation)
- [Contributors and Contact](#contributors-and-contact)

## Description
The TouchTact iOS app is an integral part of the TouchTact system for conducting touch interaction and haptic feedback experiments. This SwiftUI-based app allows participants to access and perform experiments designed by researchers using the TouchTact Experiment Generation GUI.
The TouchTact system consists of two main components:

The Experiment Generation GUI for researchers: TouchTact Experiment Generation GUI
https://github.com/HaRVI-Lab/TouchTact-Experiment-Generation-GUI
This iOS app for experiment participants (current repository)

Researchers design experiments using the GUI, which are then accessed and performed by participants using this iOS app.

## Features
- Seamless experiment access using researcher's GitHub credentials and experiment details
- Support for various touch interaction types (tap, swipe)
- Custom UI components for experiment interaction (NumPad, TouchPad)
- Integrated timer and scoreboard functionality
- Haptic feedback and audio playback capabilities
- Web-based survey integration
- Robust experiment and case management system

## Requirements
- iOS device running iOS 14.0 or later
- Xcode 12.0 or later for development

## Project Structure
- `Haptic_Performance_PlatformApp.swift`: Main app entry point
- `Component/`:
  - `ComponentCustom.swift`: Custom SwiftUI components (WebView, Icon, ScrollList, Checkbox, NumPad, TouchPad)
  - `ComponentStyles.swift`: UI styles and color definitions
- `Managers/`:
  - `CaseManager.swift`: Logic for individual experiment cases
  - `DecodableManager.swift`: JSON decoding structures for experiments and cases
  - `ExperimentManager.swift`: Overall experiment flow management
  - `PhaseManager.swift`: App phase management (Entrance and Execution phases)
- `PhasePages/`:
  - `EntrancePhasePages.swift`: Initial app views (Loading, Login)
  - `ExecutionPhasePages.swift`: Main experiment views (User Agreements, Tutorial, Game, Survey)
- `Assets.xcassets/`: Image assets and app icons

## Setup for Development
1. Clone the repository
2. Open the project in Xcode
3. Ensure you have Xcode 12.0 or later and the iOS 14.0 SDK or later
4. Build and run the project on a simulator or physical iOS device

## Usage
1. Launch the app
2. On the login page, enter:
   - Researcher's GitHub published server url (typically https://your-github-username.github.io/TouchTact-Experiment-Generation-GUI)
   - Experiment ID
   - Assigned Participant ID
3. Progress through user agreements and tutorial pages
4. Perform the experiment tasks as instructed
5. Complete any post-experiment surveys if provided

<div style="display: flex; justify-content: space-between;">
  <img src="/Haptic%20Performance%20Platform/Reference/Login.png" alt="Login" width="48%"/>
  <img src="/Haptic%20Performance%20Platform/Reference/ServerURL.png" alt="GitHub Server URL Input" width="48%"/>
</div>

## Key Components
- `ExperimentManager`: Handles experiment data loading, case preparation, and phase transitions
- `CaseManager`: Manages individual case logic, timing, scoring, and feedback
- `NumPad` and `TouchPad`: Custom input interfaces for different experiment types
- `WebView`: Enables integration of web-based surveys

## License and Citation

### License
[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](http://creativecommons.org/licenses/by/4.0/)

TouchTact Experiment Generation GUI © 2023 by University of Southern California HaRVI Research Lab is licensed under CC BY 4.0. 

This license requires that reusers give credit to the creator. It allows reusers to distribute, remix, adapt, and build upon the material in any medium or format, even for commercial purposes.

To view a copy of this license, visit http://creativecommons.org/licenses/by/4.0/

### Attribution and Citation

If you use TouchTact in your research or project, please provide attribution by citing our paper and linking to our project:

```
Lee, S. H., Kollannur, & Culbertson H. (2025). 
TouchTact: A Performance-Centric Audio-Haptic Toolkit for Task-Oriented Mobile Interactions. [Paper DOI URL]

Project URL: [Project's GitHub URL]
```
## Contributors and Contact
This project was developed by the University of Southern California HaRVI Research Lab.

### Core Team
- Seung Heon Lee - Lead Engineer
- Sandeep Kollannur - Project Manager (sandeep.kollannur@usc.edu)
- Dr. Heather Culbertson - Research Advisor

### Contact
For questions or support regarding this project, please contact:
Sandeep Kollannur at sandeep.kollannur@usc.edu (University of Southern California, HaRVI Lab)
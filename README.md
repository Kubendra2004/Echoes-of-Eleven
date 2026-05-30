# Echoes of Eleven

A narrative-driven detective thriller built in Godot 4.3.

**Current Status: Prototype (Chapters 1 & 2 Playable)**

## Features Implemented
- **Full UI Overhaul**: "Midnight Noir" design system applied to Main Menu, Pause Menu, and Evidence Board.
- **Chapter 1 (Crime Scene)**: 
  - Investigate Arjun's apartment
  - Interactive clues with 3D floating labels
  - Interactive evidence board for deductions
  - Neighbor testimony and branching dialogue
  - Action sequence (QTE chase scene)
- **Chapter 2 (Sullivan's Office)**:
  - Interrogation phase with multiple approaches (Aggressive, Empathetic, Evidence-based)
  - 5 new clues to collect in a detailed 3D environment
- **Systems**:
  - Global save/load mechanics (persistence across sessions)
  - Dynamic achievement system
  - Custom Dialogue parser (JSON-based)
  - Clue connection and automatic deductions

## Controls
- **WASD**: Move
- **Mouse**: Look
- **E**: Interact / Examine Clues
- **I**: Open Evidence Board
- **ESC / SHIFT+ENTER**: Pause Menu (view objectives, exit game)

## Running the Game
Requires Godot 4.3.
1. Open the project folder in Godot.
2. Run the main scene (`F5`).
3. (Optional) Run headless validation using the included `build.sh` or `Dockerfile`.

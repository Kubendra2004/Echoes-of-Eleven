# 🔍 Echoes of Eleven: The Burari Case

A psychological thriller detective game based on India's most disturbing unsolved crime: the Burari Deaths of 2007.

## About the Game

**Genre:** Story-Driven Detective Thriller  
**Platform:** Windows, macOS, Linux  
**Engine:** Godot 4.3 (Forward+)  
**Status:** In Development  

### Story

On July 31, 2007, investigators discovered eleven members of the Burari family hanging by cloth in their upstairs room in New Delhi. The scene was ritualistic, deliberate, and utterly unexplainable. As Detective Chen, you arrive at the crime scene to uncover the truth.

---

## Features & Recent Updates

### 🗂️ Interactive Evidence Deduction Board *(New!)*
- **Sticky-note clue cards** appear on a corkboard as you collect evidence — each with a category colour dot (🔴 Physical, 🔵 Document, 🟢 Testimony, 🟣 Digital).
- **Drag & rearrange** clues freely across the board; positions are saved between sessions.
- **Click any two clues** to draw a red string between them, forming connections and unlocking deductions.
- **Live-updating strings** — red threads follow clues in real time as you drag them.
- **Fully automatic** — any clue added to any future chapter appears on the board with zero extra code.

### 🕵️ Modern Investigation Mechanics
- **Dynamic Flashlight:** Press `F` to toggle your flashlight and explore the atmospheric, dark environment.
- **Fluid Movement:** Smooth camera interpolation and procedural head-bobbing for full immersion.
- **Smooth UI:** "Examine" prompts gracefully fade in and out as you look at evidence.

### 🧩 Deduction & Dialogue
- Examine 15+ pieces of evidence across the crime scene.
- Branching dialogue with 50+ paths affecting your Reputation and Stress levels.
- Connect clues on the Evidence Board to unlock new deductions and story branches.

### 💾 Persistent Save System
- Board layout (positions + connections) persists across saves.
- Save your game directly from the **Pause Menu**.
- Save files are compressed JSON for minimal disk usage.

### ⚡ Performance & Resources
- **Optimized for Low VRAM:** Heavy post-processing (SDFGI) disabled to prioritize FPS.
- **Procedural PBR Textures:** All surfaces use Godot Noise mapping — zero external texture assets, minimal game size.

---

## Controls

| Action | Key |
|--------|-----|
| **Move** | WASD |
| **Look** | Mouse |
| **Sprint** | Shift |
| **Flashlight** | F |
| **Interact** | E / Left Click |
| **Evidence Board** | I |
| **Pause Menu** | Shift + Enter |

### Evidence Board Controls
| Action | How |
|--------|-----|
| **Open / Close board** | `I` |
| **Drag a clue** | Click & hold, then move |
| **Connect two clues** | Click clue 1 → click clue 2 |
| **Deselect** | Click same clue again |
| **Close board** | `I` again or the ✕ button |

---

## Project Structure

```
Game IG/
├── scenes/
│   ├── chapter1/          # Crime scene environment
│   └── investigation/     # Deduction board, clue nodes
├── scripts/
│   ├── autoload/          # GameState, ClueManager, SaveManager, SceneManager…
│   ├── systems/           # FPS interaction, flashlight
│   └── ui/                # Deduction board, pause overlay, HUD
├── dialogue_data/
│   └── clue_database.json # All clue definitions + logical connections
└── assets/
```

---

## Installation & Running

Ensure you have **Godot 4.3** installed.

1. Clone the repository:
   ```bash
   git clone https://github.com/Kubendra2004/Echoes-of-Eleven.git
   ```
2. Open the project in Godot 4.3.
3. Press `F5` to run the game.

<div align="center">
  <h1>Echoes of Eleven</h1>
  <p><i>A story-driven detective thriller with branching narratives and 3D investigation mechanics, built in Godot 4.3.</i></p>

  [![Godot Engine](https://img.shields.io/badge/Godot_Engine-4.3-blue?style=for-the-badge&logo=godotengine)](https://godotengine.org/)
  [![Status](https://img.shields.io/badge/Status-Paused-orange?style=for-the-badge)](#project-status)
  [![Docker](https://img.shields.io/badge/Docker-Supported-2496ED?style=for-the-badge&logo=docker)](#docker-environment)
</div>

---

## 📌 Project Status: Paused

> [!WARNING]  
> **Development is currently on hold.**  
> *Echoes of Eleven* serves as a fully functional proof-of-concept for a modern, narrative-driven detective game. While the first two chapters are completely playable with all core mechanics intact (3D environments, branching dialogues, dynamic UI), development is currently paused. The repository remains public to showcase the robust architecture and systems built.

## 📖 The Story
**New Delhi, 2007.** Eleven bodies were found hanging in a courtyard. No signs of struggle. No suicide notes. The case went cold. 

Now, the lead investigator on the original case, Arjun Mehta, has been murdered in his own apartment. You step into the shoes of Detective Chen to pick up where Arjun left off. Was it a robbery gone wrong, or was Arjun getting too close to the truth behind the eleven bodies? 

Your prime suspect is **Marcus Sullivan**, Arjun's former business partner. He has the motive, his alibi is full of holes, and CCTV footage places him at the scene. But what is he hiding in Locker 47 at the New Delhi Railway Station?

---

## ✨ Features Implemented (Chapters 1 & 2)

### 🕵️ Investigation Mechanics
*   **3D Interactive Crime Scenes:** Fully explorable 3D environments (Arjun's Apartment & Sullivan's Office).
*   **Clue System:** Interactive clues with 3D floating labels that update your notebook and inventory upon discovery.
*   **Deduction Board:** An interactive UI to physically string clues together and unlock automated deductions.

### 💬 Dynamic Narrative
*   **Custom Dialogue Engine:** JSON-driven dialogue parser supporting deep branching trees.
*   **Branching Interrogations:** Approach suspects dynamically. For example, pressure Marcus Sullivan using Aggressive, Empathetic, or Evidence-based tactics that permanently alter your reputation and stress levels.
*   **Action Sequences:** Integrated Quick-Time Events (QTE) for high-stakes moments like alleyway chases.

### 🎨 UI & Engine Architecture
*   **"Midnight Noir" UI Overhaul:** A bespoke, cinematic UI design system applied globally (Main Menu, Pause Overlay, HUD, Evidence Board).
*   **State Persistence:** Global Save/Load mechanics preserving inventory, choices, and world flags.
*   **Decoupled Architecture:** Heavy reliance on Autoloads (`GameState`, `ClueManager`, `DialogueManager`) for clean scene-to-scene transitions.

---

## 🎮 How to Run (Local Native)

1. Ensure you have **Godot Engine 4.3** installed.
2. Clone this repository to your local machine.
3. Open Godot and click **Import**, then select the `project.godot` file in the root directory.
4. Press `F5` to run the main scene (`scenes/main_menu/main_menu.tscn`).

**Controls:**
*   **WASD:** Move
*   **Mouse:** Look
*   **E / Left Click:** Interact / Examine / Progress Dialogue
*   **I:** Open Evidence Board
*   **SHIFT + ENTER:** Toggle Pause Menu

---

## 🐳 Docker Environment

This project includes a complete Docker containerization setup for headless CI/CD testing, build generation, and isolated execution, eliminating the need to install Godot locally on your build servers.

### 1. Build the Image
To build the standard Docker environment, run the included script:
```bash
./build.sh
```
*Alternatively, you can build manually using the `Dockerfile` or `Dockerfile.lowend` for optimized builds.*

### 2. Run via Docker Compose
To spin up the environment with volume mapping (syncing your local workspace with the container):
```bash
docker-compose up -d
```
You can read more about advanced Docker usage, CI/CD integration, and low-end PC optimizations in the dedicated [DOCKER_GUIDE.md](./DOCKER_GUIDE.md).

---

## 📁 Repository Structure
| Directory | Purpose |
| :--- | :--- |
| `scenes/` | Contains all `.tscn` files organized by domain (UI, chapters, entities). |
| `scripts/` | The core logic (GDScript), heavily modularized into `autoloads`, `systems`, and `ui`. |
| `dialogue_data/` | JSON files containing all branching dialogue trees and clue metadata. |
| `assets/` | Raw models, textures, audio, and materials. |

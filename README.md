# 🔍 Echoes of Eleven: The Burari Deaths

A psychological thriller detective game based on India's most disturbing unsolved crime: the Burari Deaths of 2007.

## About the Game

**Genre:** Story-Driven Detective Thriller  
**Platform:** Windows, macOS, Linux  
**Engine:** Godot 4.3  
**Release:** Early Access  
**Price:** Free / Pay-What-You-Want

### Story

On July 31, 2007, investigators discovered eleven members of the Burari family hanging by cloth in their upstairs room in New Delhi. The scene was ritualistic, deliberate, and utterly unexplainable.

As Detective Chen, you arrive at the crime scene. The evidence is fragmented. The motives are hidden. The answers demand investigation.

**Your choices will determine the truth.**

- Did mental illness orchestrate mass suicide?
- Was outside manipulation at play?
- Is there a hidden handler orchestrating from the shadows?

## Gameplay Features

### 🕵️ First-Person Investigation
- Explore the crime scene in full 3D
- Examine evidence with close attention to detail
- Interact with NPCs and gather witness testimony
- Uncover 15+ pieces of evidence

### 📋 Dynamic Dialogue System
- 50+ branching dialogue paths
- Your choices directly impact reputation and stress
- Conditional responses based on collected evidence
- Multiple endings based on your deductions

### 🧩 Deduction Mechanics  
- Connect clues to unlock theories
- Evidence board allows clue relationship mapping
- Build your own narrative from fragmented facts
- Challenge your assumptions repeatedly

### 📊 Reputation & Stress System
- Reputation: Build credibility with NPCs (0-100)
- Stress: Psychological pressure of investigating trauma (0-100)
- Both stats affect available choices and ending paths

### 🏆 Achievement System
- 10 unlockable achievements
- Detective's Eye, Evidence Master, Truth Seeker
- Track your investigation prowess

### 📱 Detective Notebook
- Auto-log all clues and deductions
- Review case progression anytime
- Export case summary

### ⚡ Quick-Time Events
- Chase sequence with physical stakes
- Tense moments reflecting detective's adrenaline
- Failure carries consequences

## Controls

### What to say in gameplay
| Action | Key |
|--------|-----|
| **Move** | WASD |
| **Look Around** | Mouse |
| **Sprint** | Shift |
| **Interact/Examine** | E or LMB |
| **Open Inventory** | I |
| **Open Detective Notebook** | N |
| **Pause** | ESC |

### Recommended Settings
- Resolution: 1280x720 or higher
- Refresh Rate: 60Hz minimum (144Hz+ for combat QTE)
- Audio: Headphones recommended for immersion

## System Requirements

### Minimum
- **OS:** Windows 7+ / macOS 10.12+ / Ubuntu 16.04+
- **Processor:** Intel i5 or equivalent
- **RAM:** 4GB
- **Graphics:** Integrated graphics (OpenGL 4.0+)
- **Storage:** 2GB SSD
- **Internet:** None required (fully offline)

### Recommended
- **OS:** Windows 10+ / macOS 11+ / Ubuntu 20.04+
- **Processor:** Intel i7 / AMD Ryzen 5
- **RAM:** 8GB
- **Graphics:** Dedicated GPU (GTX 960 / RX 570)
- **Storage:** 2GB SSD
- **Display:** 144Hz for optimal QTE performance

## Installation & Running

### From GitHub Release
1. Download the appropriate release for your OS:
   - `echoes_of_eleven` (Linux)
   - `echoes_of_eleven.exe` (Windows)
   - `echoes_of_eleven.dmg` (macOS)
2. Make executable: `chmod +x echoes_of_eleven` (Linux/macOS)
3. Run: `./echoes_of_eleven` (Linux/macOS) or double-click (Windows/macOS)

### Building from Source

#### Requirements
- Godot Engine 4.3.0+
- Git

#### Build Steps
```bash
# Clone repository
git clone https://github.com/yourusername/echoes-of-eleven.git
cd echoes-of-eleven

# Make build script executable
chmod +x build.sh

# Run build (requires Godot in PATH)
./build.sh

# Outputs to ./dist/
# Test Linux build
./dist/linux/echoes_of_eleven

# Test Windows build (if in Wine/Proton)
wine ./dist/windows/echoes_of_eleven.exe
```

#### Manual Godot Export
1. Open Godot 4.3
2. Import `project.godot`
3. Project → Export → Select platform → Export Project
4. Choose output location and confirm

## Gameplay Guide

### Act 1: The Silent Witness (45-60 minutes)
- Arrive at the Burari family apartment
- Examine 15+ pieces of evidence
- Conduct initial interviews
- Chase down fleeing suspect (QTE sequence)
- Make first theory decision

### Acts 2-5: Escalation
- Ashram investigation
- Hidden connections exposed
- Final confrontation
- Determine the truth

### Tips for First Playthrough
- **Take your time:** Examine EVERYTHING. Evidence connects in non-obvious ways
- **Track stress:** Before 80+ stress, seek relief through dialogue choices
- **Compare evidence:** Use Evidence Board (Press I) to connect clues
- **Read dialogue carefully:** Names, dates, inconsistencies matter
- **Save frequently:** Use Save UI before major choices

### Endings
The game has **3 major endings** based on your final theory choice:
1. **Close Case:** Declare it mass murder-suicide (fast but risky)
2. **Dig Deeper:** Continue investigation into deeper conspiracy
3. **Hunt Handler:** Pursue mysterious orchestrator theory

Each ending unlocks different Acts 2-5 content.

## Features

### Writing & Narrative
- 15,000+ words of original dialogue
- Multiple perspective scenes
- Environmental storytelling
- Psychological depth from real crime case

### Audio
- Original atmospheric soundtrack (20+ tracks)
- Immersive sound design
- NPCs with distinct voices
- Environmental audio layers

### Visual Design
- 3D first-person perspective
- Detailed crime scene environment
- Evidence indicators
- UI with investigator journal aesthetic
- Blood/gore details for psychological impact

### Technical
- Fully offline (no internet required)
- Cross-platform support (Windows/macOS/Linux)
- Save/load system (3 slots)
- 60+ FPS on recommended specs
- Optimized for integrated graphics

## Troubleshooting

### Game Won't Start
- Ensure you have OpenGL 4.0+ capable GPU
- Try running from terminal: `./echoes_of_eleven`
- Check system logs for error messages

### Low FPS / Stuttering
- Reduce resolution to 1920x1080
- Close background applications
- Update GPU drivers
- Check storage space (needs 1GB free)

### Dialogue Not Appearing
- Ensure `res://dialogue_data/` directory exists with JSON files
- Check file permissions are readable
- Restart game completely

### Save Files Corrupted
- Corrupted saves in `user://saves/` can be deleted
- Game will create fresh save slot
- Earlier saves should still load

## Credits

### Development
- **Design & Programming:** [Your Name]
- **Writing & Dialogue:** [Your Name]
- **Audio Design:** [Contributors]
- **QA Testing:** [Contributors]

### Technology
- **Engine:** Godot Engine (MIT License)
- **Contributors:** Godot community

### Inspiration
- Real Burari Deaths case (July 2007, New Delhi)
- Rajesh Masrani investigation by Harinder Baweja
- Freedom of Information request documents

## Support & Feedback

### Report Issues
- GitHub Issues: [Link]
- Email: [email@example.com]
- Discord: [Link]

### Send Feedback
- What theories did you develop?
- Which ending did you choose?
- What should we improve?

## License

Echoes of Eleven © 2024. 

Game content (story, dialogue, characters) is owned and copyrighted.  
Source code available under MIT License for educational purposes.  
Godot Engine usage under MIT License.

## Disclaimer

**This game is inspired by real events** but is a fictional interpretation for entertainment purposes. The Burari Deaths remain an unsolved mystery. This game is not endorsed by, affiliated with, or officially connected to any government agencies or real persons involved in the case.

Some content includes:
- Depictions of suicide
- Blood and gore imagery
- Psychological horror elements
- Disturbing family dynamics

Player discretion advised. Age Rating: M (Mature 17+)

## Roadmap

- ✅ Act 1: Crime Scene Investigation
- 🔄 Acts 2-5: Narrative Expansion
- 🔄 Voice-over narration system
- 🔄 Enhanced particle effects
- 🔄 Mobile port (iOS/Android)
- 🔄 VR support
- 🔄 Community case editor
- 🔄 Multiplayer deduction mode

---

**Play Detective. Uncover Truth. Make Choices That Matter.**

[Download Latest Release](https://github.com/yourusername/echoes-of-eleven/releases)  
[Join Discord Community](https://discord.gg/yourdiscord)  
[Support Development](https://patreon.com/yourusername)

*Echoes of Eleven: The Burari Deaths — Coming Soon*

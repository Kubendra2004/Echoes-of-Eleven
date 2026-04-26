#!/bin/bash
# Git Initialization Script for Echoes of Eleven
# Sets up repository with proper configuration and first commit

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔧 Initializing Git Repository"
echo "=============================="
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed. Install with:"
    echo "   sudo apt-get install git  (Ubuntu/Debian)"
    echo "   brew install git          (macOS)"
    exit 1
fi

cd "$PROJECT_DIR"

# Check if already initialized
if [ -d ".git" ]; then
    echo "⚠️  Repository already initialized"
    echo ""
    echo "Current config:"
    git config --local --list | head -10
    echo ""
    read -p "Continue with reinitialization? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
    rm -rf .git
fi

# Initialize repository
echo "📝 Initializing Git repository..."
git init

# Set local configuration
echo "⚙️  Configuring Git..."
git config user.name "Echoes of Eleven Development"
git config user.email "dev@echoes-of-eleven.local"

# Set helpful defaults
git config core.autocrlf false
git config core.safecrlf true
git config pull.rebase false
git config rerere.enabled true

echo "✅ Git configured:"
echo "   User: $(git config user.name)"
echo "   Email: $(git config user.email)"
echo ""

# Create .gitignore if not exists (already exists, but verify)
if [ ! -f ".gitignore" ]; then
    echo "⚠️  .gitignore not found"
fi

# Create .gitattributes if not exists (already exists, but verify)
if [ ! -f ".gitattributes" ]; then
    echo "⚠️  .gitattributes not found"
fi

# Add all files
echo "📦 Adding files to staging..."
git add -A

# Show what will be committed
echo ""
echo "📊 Files to commit:"
git status --short | head -20
COUNT=$(git status --short | wc -l)
if [ "$COUNT" -gt 20 ]; then
    echo "   ... and $((COUNT - 20)) more files"
fi

echo ""
read -p "Create initial commit? (Y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    git commit -m "🎮 Initial Commit: Echoes of Eleven v1.0.0

Core Features:
- Complete Act 1 investigation (45-60 min gameplay)
- First-person 3D crime scene exploration
- 50+ branching dialogue paths
- Achievement system (10 unlockables)
- Save/load system (3 slots)
- Detective notebook & evidence board
- Quick-Time Event action sequences
- Professional UI with enhanced visuals

Technical:
- 8 Autoload systems (GameState, DialogueManager, etc.)
- 6 UI controllers
- 5 game systems
- 15,000+ lines of GDScript
- Cross-platform (Windows/macOS/Linux)
- 100% offline operation
- Optimized for low-end PCs

Documentation:
- README: Game guide & controls
- QUICKSTART: Play in 30 seconds
- DEPLOYMENT: Publishing instructions
- TESTING: QA procedures
- LOW_END_PC_GUIDE: Performance optimization
- DOCKER_GUIDE: Container deployment

Deployment:
- Build automation (build.sh)
- GitHub Actions CI/CD
- itch.io configuration
- Docker support
- Multi-platform builds

Ready for beta testing and deployment."
fi

echo ""
echo "✅ Repository initialized!"
echo ""
echo "📚 Next Steps:"
echo "   1. View commit history:    git log"
echo "   2. Add remote:             git remote add origin https://github.com/user/repo"
echo "   3. Push to GitHub:         git push -u origin main"
echo "   4. Create branch:          git checkout -b feature/act2"
echo ""
echo "📖 Useful Git Commands:"
echo "   git status              - View changes"
echo "   git diff                - See what changed"
echo "   git commit -m 'msg'     - Commit changes"
echo "   git log --oneline       - View history"
echo "   git branch              - List branches"
echo "   git tag v1.0.0          - Create release tag"
echo ""

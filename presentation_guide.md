# 🎮 Unscramble Challenge — Complete Project Presentation Guide

---

## 📌 SLIDE 1: Project Title & Overview

**Project Name:** Unscramble Challenge
**Type:** Advanced Interactive Terminal-Based Word Game
**Technology:** Unix Shell Scripting (Bash)
**Run Command:** `bash unscramble.sh`
**Team Purpose:** To demonstrate real-world application of Unix Shell Scripting concepts including file I/O, arrays, functions, control flow, string manipulation, and terminal UI design.

---

## 📌 SLIDE 2: What Is This Project?

Unscramble Challenge is a **fully interactive word puzzle game** that runs inside a Linux/Git Bash terminal. The player is shown a **scrambled version of a word**, and must correctly identify the original word.

It is NOT a simple script — it is designed like a **mini software application** with:
- A **main menu navigation system**
- **Three different game modes**
- A **hint system**
- A **dynamic scoring engine**
- **Persistent file storage** for leaderboards and game logs
- **Colored terminal UI** with ASCII art banners

---

## 📌 SLIDE 3: Files Used In The Project

| File | Purpose |
|---|---|
| `unscramble.sh` | The entire game — 800 lines of Bash code |
| `highscore.txt` | Auto-created file that saves all player scores permanently |
| `game_log.txt` | Auto-created file that logs every game session with timestamps |

> All 3 files live inside the same folder: `Desktop/unix/`

The game **automatically creates** `highscore.txt` and `game_log.txt` the first time a player completes a game. The developer does not need to create them manually.

---

## 📌 SLIDE 4: Technologies & Concepts Used

| Concept | Where It Is Used |
|---|---|
| **Bash Arrays** | Word database (60 words stored in a single array) |
| **Functions** | Each feature is its own reusable function |
| **File I/O** | Reading/writing highscore.txt and game_log.txt |
| **String Manipulation** | Scrambling words, converting to uppercase, trimming input |
| **Loops (for/while)** | Game rounds loop, menu loop, scramble engine |
| **Conditionals (if/case)** | Menu navigation, game mode logic, scoring rules |
| **ANSI Escape Codes** | Colored text (red, green, yellow, blue, cyan, magenta) |
| **Built-in `$SECONDS`** | Countdown timer in Timed Mode |
| **`read -t`** | Input timeout enforcement for Timed Mode |
| **`sort` utility** | Sorting leaderboard scores from highest to lowest |
| **`date` utility** | Generating timestamps for game logs |
| **`shuf` utility** | Randomizing/scrambling word characters |
| **Fisher-Yates Algorithm** | Pure Bash fallback scrambler (no external tools needed) |
| **Regex with `=~`** | Parsing structured game log entries in history viewer |

---

## 📌 SLIDE 5: Word Database Design

The game stores **60 words** inside a single Bash array called `WORDS`.

Each word is stored as a **single colon-separated string** with 4 fields:

```
"word:category:difficulty:hint_clue"
```

**Example entries:**
```bash
"lion:Animals:Easy:The legendary king of the jungle"
"dolphin:Animals:Medium:Highly intelligent marine mammal"
"algorithm:Technology:Hard:Step-by-step mathematical logic"
"strawberry:Fruits:Hard:Sweet red heart-shaped fruit"
```

**Word Distribution:**

| Category | Easy | Medium | Hard | Total |
|---|---|---|---|---|
| Animals | 8 | 8 | 4 | 20 |
| Fruits & Foods | 6 | 8 | 6 | 20 |
| Technology | 7 | 8 | 7 | 22 |
| **Total** | **21** | **24** | **17** | **62** |

**Why colon-separated?**
Bash can split a string using `IFS=':'` (Internal Field Separator), making it very easy to extract individual fields:
```bash
IFS=':' read -r word category difficulty hint <<< "lion:Animals:Easy:King of jungle"
# word="lion", category="Animals", difficulty="Easy", hint="King of jungle"
```

---

## 📌 SLIDE 6: Main Menu System

When the game starts, it immediately shows the **Main Menu**. This is controlled by the `main_menu()` function which runs inside a `while true` infinite loop.

```
[1] Play Game 🎮
[2] View Leaderboard 🏆
[3] View Game History 📊
[4] How to Play / Rules ℹ️
[5] Exit Game ❌
```

**How it works:**
1. The menu screen is displayed using `echo -e` with ANSI color codes.
2. `read -p` captures the user's typed number.
3. A `case` statement routes to the correct function based on the number typed.
4. If the user types something invalid, it shows an error and loops again.
5. Only option `5` exits the game using `exit 0`.

```bash
case "$opt_clean" in
    1) play_game ;;
    2) show_leaderboard ;;
    3) show_history ;;
    4) show_rules ;;
    5) exit 0 ;;
    *) echo "Invalid selection" ;;
esac
```

---

## 📌 SLIDE 7: Game Setup — 3-Step Configuration

Before a game starts, the player goes through **3 selection screens** handled by the `select_setup()` function.

### Step 1: Choose Category
```
[1] Animals 🦁
[2] Fruits & Foods 🍎
[3] Technology 💻
[4] Mixed Pool 🌀
```

### Step 2: Choose Difficulty
```
[1] Easy   — Words with 3 to 5 letters (lion, bear, code)
[2] Medium — Words with 6 to 8 letters (dolphin, banana)
[3] Hard   — Words with 9+ letters (algorithm, strawberry)
[4] Mixed  — All difficulties combined
```

### Step 3: Choose Game Mode
```
[1] Classic Mode   — Unlimited attempts, no timer
[2] Timed Mode     — Must guess within 30 seconds
[3] Challenge Mode — Only 3 attempts allowed per word
```

**After selection**, the game filters the 60-word database and picks only the words matching the chosen category and difficulty. It then randomly shuffles those words and picks the first 5 for a 5-round game.

---

## 📌 SLIDE 8: How The Scramble Engine Works

The `scramble_word()` function takes a word and returns a scrambled version.

**It uses two methods:**

### Method 1 — Using `shuf` (Primary)
```bash
scrambled=$(echo "$word" | fold -w1 | shuf | tr -d '\n')
```
- `fold -w1` → splits each character onto its own line
- `shuf` → randomly reorders the lines (characters)
- `tr -d '\n'` → joins them back without newlines

Example: `"lion"` → split → `l`, `i`, `o`, `n` → shuffle → `n`, `l`, `o`, `i` → join → `"nloi"`

### Method 2 — Fisher-Yates Pure Bash (Fallback)
If `shuf` is not available on the system, a pure Bash implementation of the **Fisher-Yates shuffle algorithm** is used:
```bash
for ((i=len-1; i>0; i--)); do
    j=$((RANDOM % (i + 1)))   # Pick a random index from 0 to i
    temp="${chars[i]}"
    chars[i]="${chars[j]}"    # Swap current with random
    chars[j]="$temp"
done
```
This guarantees a truly random arrangement of characters every time.

**Anti-repeat protection:** After scrambling, the script checks if the scrambled word accidentally equals the original. If it does, it swaps the first two characters to force a difference.

---

## 📌 SLIDE 9: The 3 Game Modes In Detail

### 🟢 Mode 1 — Classic Mode
- The player gets **unlimited attempts** per word.
- No time pressure at all.
- Perfect for beginners or practice.
- After every wrong guess, it shows `Try again ❌` and lets the player try again immediately.

### ⏱️ Mode 2 — Timed Mode (30 Seconds)
- When a word appears on screen, a **30-second countdown begins**.
- The countdown uses Bash's **built-in `$SECONDS` variable** which counts seconds since the script started.
- The timer is calculated as: `time_left = 30 - (SECONDS - start_word_time)`
- The `read -t $remaining_timeout` command enforces the timeout — if the player doesn't press Enter within the remaining time, `read` automatically exits with a status code > 128.
- When that happens, the game instantly prints `⏱️ TIME'S UP! Game Over!`
- The displayed timer only updates when the player submits a guess (it refreshes the screen each time).

### 🔥 Mode 3 — Challenge Mode
- The player gets exactly **3 attempts per word**.
- A counter tracks how many wrong guesses have been made.
- After the 3rd wrong guess, the game displays the correct answer and ends immediately.
- Shows `Attempts Remaining: 3/2/1` on screen in red.

---

## 📌 SLIDE 10: The Hint System

During any round, the player can type `hint` instead of guessing. This opens a **hint selection sub-menu**:

```
[1] Reveal First Letter  (e.g. "First letter is: 'S'")
[2] Reveal Category Clue (e.g. "Clue: Highly intelligent marine mammal")
```

**Rules:**
- Only **one hint is allowed per word**. Trying again shows: `You have already used a hint!`
- Selecting a hint deducts **-20 points** from the current word's score.
- The hint text is displayed inside the game panel on every subsequent screen refresh until the word is solved.

**How it is stored:**
The hint text is stored in a global variable `$HINT_TEXT` and a boolean flag `hint_used=true` is set to prevent a second hint.

---

## 📌 SLIDE 11: The Scoring System

Each word starts with a **base score of 100 points**.

| Event | Points Change |
|---|---|
| Base score per word | +100 |
| Solved on FIRST attempt with NO hints | +50 bonus (Perfect Bonus!) |
| Each wrong guess | -10 |
| Hint used | -20 |
| Minimum score (floor) per solved word | 10 (never goes below) |

**Score Examples:**

| Scenario | Calculation | Final Score |
|---|---|---|
| Solved on 1st attempt, no hint | 100 + 50 | **150 pts** |
| Solved on 2nd attempt, no hint | 100 - 10 | **90 pts** |
| Solved on 1st attempt, hint used | 100 - 20 + 0 | **80 pts** |
| Solved on 4th attempt, hint used | 100 - 30 - 20 | **50 pts** |
| 9 wrong attempts, hint used | 100 - 90 - 20 = -10 → floor | **10 pts** |

**Cumulative Score:** All round scores add up to the final score displayed at the end of the game.

---

## 📌 SLIDE 12: File Handling — Leaderboard & Game History

### highscore.txt — Leaderboard Storage
Every time a player finishes a game (without quitting), their score is **appended** to `highscore.txt`:

```
Alice|450|Classic|Animals|Easy|2026-05-28
Bob|600|Timed|Technology|Hard|2026-05-28
```

Format: `Name | Score | Mode | Category | Difficulty | Date`

**How scores are written:**
```bash
echo "$name|$score|$mode|$cat|$diff|$today" >> highscore.txt
```
The `>>` operator **appends** (adds to the end) without overwriting existing data.

**How the leaderboard is displayed (sorted):**
```bash
sort -t '|' -k2 -rn highscore.txt | head -n 10
```
- `-t '|'` → tells sort to use `|` as the delimiter
- `-k2` → sort by column 2 (the score column)
- `-rn` → reverse order, numerically (highest score first)
- `head -n 10` → show only the top 10 entries

---

### game_log.txt — Session History
Every completed game session is also logged with a full timestamp:

```
[2026-05-28 22:50:12] Player: Alice | Mode: Classic | Category: Animals | Difficulty: Easy | Score: 450 | Words Solved: 5/5
```

**How it is written:**
```bash
timestamp=$(date "+%Y-%m-%d %H:%M:%S")
echo "[$timestamp] Player: $name | Mode: $mode | ..." >> game_log.txt
```

**How history is displayed:**
The script reads the last 15 lines of `game_log.txt` using `tail -n 15` and parses each line using Bash **regex matching** (`=~`) to extract each field and display it in a clean, color-coded format.

---

## 📌 SLIDE 13: ANSI Color System — How Colors Work In Terminal

The game uses **ANSI Escape Codes** to display colored text. These are special character sequences that terminals interpret as color instructions.

```bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'    # Resets all formatting back to normal
```

**How they are used:**
```bash
echo -e "${GREEN}Correct! Well done 🎉${RESET}"
echo -e "${RED}Try again ❌${RESET}"
```

The `-e` flag in `echo -e` is what enables interpretation of `\033` escape sequences.

**Color Meanings in the game:**
| Color | Used For |
|---|---|
| 🟢 Green | Correct answers, success screens, main menu play option |
| 🔴 Red | Wrong answers, errors, low time warning (under 10s) |
| 🟡 Yellow | Warnings, leaderboard menu, hint system, Gold rank (1st) |
| 🔵 Blue | Round panels and borders |
| 🩵 Cyan | Game banners, Silver rank (2nd), history display |
| 🟣 Magenta | Game over screen, Bronze rank (3rd), category headers |

---

## 📌 SLIDE 14: ASCII Art Banner

When the game starts (or the screen refreshes), a large ASCII art banner is printed:

```
==========================================================================
  _   _ _   _ ____   ____ ____   _    __  __ ____  _     _____          
 | | | | \ | / ___| / ___|  _ \ / \  |  \/  | __ )| |   | ____|         
 | | | |  \| \___ \| |   | |_) / _ \ | |\/| |  _ \| |   |  _|           
 | |_| | |\  |___) | |___|  _ / ___ \| |  | | |_) | |___| |___          
  \___/|_| \_|____/ \____|_| /_/   \_\_|  |_|____/|_____|_____|         
                       C H A L L E N G E                                
==========================================================================
```

This is drawn using the `draw_banner()` function which simply uses `echo` statements to print each row of the ASCII art. The text `UNSCRAMBLE` is styled in the large format.

---

## 📌 SLIDE 15: Complete Game Flow — Step By Step

```
1. bash unscramble.sh is executed
        ↓
2. draw_banner() — ASCII art header is shown
        ↓
3. main_menu() — Player sees the main menu
        ↓
4. Player types 1 (Play Game)
        ↓
5. play_game() is called
        ↓
6. Player enters their name
        ↓
7. select_setup() — Player picks Category → Difficulty → Mode
        ↓
8. 60-word database is filtered based on choices
        ↓
9. Filtered words are shuffled randomly (Fisher-Yates)
        ↓
10. ROUND LOOP STARTS (5 rounds total)
        ↓
11. A word is picked → scramble_word() scrambles it
        ↓
12. Scrambled word is displayed in UPPERCASE inside the game panel
        ↓
13. ATTEMPT LOOP STARTS
        ↓
14. Player types their guess (or 'hint' or 'quit')
         ├── 'hint' → hint sub-menu shown → -20 pts deducted
         ├── 'quit' → game aborted, returns to main menu
         ├── correct answer → score calculated, SUCCESS screen shown
         └── wrong answer
              ├── Classic → try again (unlimited)
              ├── Timed   → check if 30s has passed
              │              ├── Yes → GAME OVER (Time's Up)
              │              └── No  → try again with less time
              └── Challenge → increment attempt counter
                              └── if 3 attempts used → GAME OVER
        ↓
15. Next round starts (up to 5 rounds)
        ↓
16. GAME OVER screen shows:
        - Player Name
        - Category, Difficulty, Mode
        - Words Solved (e.g. 4/5)
        - Final Score
        ↓
17. Score is saved to highscore.txt
    Session is logged to game_log.txt
        ↓
18. "Play again? (y/n)" → y returns to setup, n returns to main menu
```

---

## 📌 SLIDE 16: All Features Summary

| Feature | Description |
|---|---|
| 🎮 Word Bank | 60 hand-picked words across 3 categories and 3 difficulty levels |
| 🔀 Scramble Engine | Dual-method scrambler (shuf + Fisher-Yates Bash fallback) |
| 📂 Category Selection | Animals, Fruits & Foods, Technology, or Mixed |
| ⚡ Difficulty Selection | Easy (3-5 letters), Medium (6-8), Hard (9+), or Mixed |
| 🕹️ Classic Mode | Unlimited attempts, no time restriction |
| ⏱️ Timed Mode | Strict 30-second countdown per word using $SECONDS |
| 🔥 Challenge Mode | Max 3 attempts per word |
| 💡 Hint System | First letter reveal OR category clue, costs -20 pts |
| 🏆 Scoring System | Base 100pts + perfect bonus + penalties + floor guarantee |
| 📋 Leaderboard | Top 10 scores sorted descending, saved to highscore.txt |
| 📊 Game History | Last 15 sessions with timestamps, saved to game_log.txt |
| 🎨 Colored UI | Full ANSI color coding for all text elements |
| 🅰️ ASCII Art Banner | Large styled header on every screen refresh |
| 🎲 Encouragement Messages | Random celebration messages on correct guesses |
| 🔄 Replay Option | Option to play again after every game session |
| 🛡️ Input Validation | Handles empty input, invalid menu choices, special characters |
| 💾 Auto File Creation | highscore.txt and game_log.txt are created automatically |
| 🖥️ Cross-Platform | Works on Linux, macOS, and Windows Git Bash |

---

## 📌 SLIDE 17: Key Functions & What They Do

| Function Name | What It Does |
|---|---|
| `main_menu()` | Shows the main navigation menu, routes to other functions |
| `draw_banner()` | Prints the ASCII art header at the top of every screen |
| `refresh_terminal()` | Clears the screen and redraws the banner |
| `print_box()` | Draws a styled bordered box with a title and content |
| `scramble_word()` | Scrambles a word's letters randomly |
| `select_setup()` | Handles the 3-step category/difficulty/mode selection |
| `play_game()` | Main game engine — manages all rounds and attempts |
| `show_leaderboard()` | Reads highscore.txt, sorts, and displays top 10 players |
| `show_history()` | Reads game_log.txt and displays last 15 sessions |
| `show_rules()` | Displays all game rules and instructions |
| `record_highscore()` | Appends a new score entry to highscore.txt |
| `record_log()` | Appends a new session log entry to game_log.txt |
| `get_encouragement()` | Returns a random celebration message from a list |

---

## 📌 SLIDE 18: Possible Viva Questions & Answers

**Q1: What is the purpose of `#!/usr/bin/env bash` at the top?**
> This is called a **shebang line**. It tells the operating system which program to use to execute this file. `/usr/bin/env bash` finds the Bash shell wherever it is installed on the system, making the script portable across different machines.

**Q2: What is an ANSI escape code?**
> ANSI escape codes are special character sequences that terminals interpret as formatting instructions — like changing text color, making text bold, or clearing the screen. They start with `\033[` followed by a number code (e.g. `31` for red, `32` for green).

**Q3: What is the Fisher-Yates shuffle?**
> It is a well-known algorithm for randomly shuffling an array in-place. It works by iterating from the last element backwards and swapping each element with a randomly chosen element from the unvisited portion of the array. It guarantees a perfectly uniform random shuffle.

**Q4: Why does the timer not visually tick down?**
> Because the `read` command in Bash blocks the terminal, waiting for the user to press Enter. The countdown is still active in the background using the `$SECONDS` variable and enforced by `read -t`, which automatically exits after the time limit expires. The timer updates visually each time the player submits a guess.

**Q5: What is `read -t` used for?**
> `read -t SECONDS` waits for user input but automatically stops waiting after the specified number of seconds. It returns an exit status greater than 128 if it times out, which the script checks to trigger the Game Over event.

**Q6: Why use `>>` and not `>` for file writing?**
> `>` overwrites the entire file every time. `>>` appends a new line to the end of the file. We use `>>` so that each new score/log entry is added below all previous entries, preserving the full history.

**Q7: How is the leaderboard sorted?**
> Using the Unix `sort` command with flags: `sort -t '|' -k2 -rn`. This sorts by column 2 (score) using `|` as a delimiter, in reverse numerical order (highest first).

**Q8: What happens if the player selects a category/difficulty with no matching words?**
> The script checks if the filtered word pool is empty. If it is, it automatically falls back to using all 60 words (Mixed category, Mixed difficulty) so the game never crashes or gets stuck.

**Q9: How does the hint system prevent a player from using it twice?**
> A boolean variable `hint_used` is set to `false` at the start of each round. When a hint is used, it is set to `true`. At the start of the hint block, the script checks `if $hint_used` and if true, it prints a message and skips the hint menu using `continue`.

**Q10: What is the purpose of the `SCRIPT_DIR` variable?**
> It stores the absolute path of the folder where `unscramble.sh` is located. This ensures that `highscore.txt` and `game_log.txt` are always created in the same folder as the script, regardless of where the user runs the script from.

---

## 📌 SLIDE 19: Why This Project Is Impressive

| Aspect | How This Project Demonstrates It |
|---|---|
| **File Handling** | Auto-creation, appending, reading, and sorting persistent data files |
| **Data Structures** | Array of structured colon-delimited strings acting as a word database |
| **Algorithm Implementation** | Fisher-Yates shuffle coded in pure Bash |
| **UI Design** | ANSI colors, ASCII art, structured bordered panels, color-coded ranks |
| **Multiple Game Modes** | Three distinct gameplay experiences in a single script |
| **Error Handling** | Invalid inputs, empty guesses, empty file checks, fallback word pool |
| **Modular Code Design** | 13 separate functions, each handling one specific responsibility |
| **Cross-Platform Portability** | Dual-method scrambler ensures it works even without `shuf` |
| **Real-Time Logic** | Timed Mode using `$SECONDS` and `read -t` timeout handling |
| **Complete Software Feel** | Menu → Setup → Gameplay → Results → Replay, like a real application |

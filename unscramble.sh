#!/usr/bin/env bash

# ==============================================================================
# 🎮 UNSCRAMBLE CHALLENGE - UNIX BASH WORD GAME
# ==============================================================================
# Description: An advanced, fully interactive terminal-based word scramble game 
#              featuring multiple game modes, category selections, difficulty levels,
#              dynamic scoring, hint options, a local leaderboard, and session logs.
#
# Requirements: Any Unix/Linux shell or Git Bash on Windows.
#               Uses standard Bash builtins for highest compatibility.
# ==============================================================================

# Ensure script directory context for file reads/writes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HIGHSCORE_FILE="$SCRIPT_DIR/highscore.txt"
LOG_FILE="$SCRIPT_DIR/game_log.txt"

# ------------------------------------------------------------------------------
# 🎨 COLOR CODES (ANSI ESCAPE SEQUENCES)
# ------------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
RESET='\033[0m'

# Clear screen command helper
CLEAR_CMD="clear"
# Check if clear is available; if not, fall back to blank lines
if ! command -v clear >/dev/null 2>&1; then
    CLEAR_CMD="printf '\n%.0s' {1..50}"
fi

# ------------------------------------------------------------------------------
# 📊 PREDEFINED WORD DATABASE
# ------------------------------------------------------------------------------
# Structure: "word:category:difficulty:hint_clue"
# Total: 60 balanced words across Animals, Fruits, and Technology categories.
# Difficulties: Easy (3-5 letters), Medium (6-8 letters), Hard (9+ letters)
# ------------------------------------------------------------------------------
WORDS=(
    # --- ANIMALS (20 Words) ---
    "lion:Animals:Easy:The legendary king of the jungle"
    "tiger:Animals:Easy:Large striped wild cat of Asia"
    "bear:Animals:Easy:Heavy omnivorous mammal with thick fur"
    "frog:Animals:Easy:Amphibian known for hopping and croaking near water"
    "deer:Animals:Easy:Hoofed wild animal where males grow antlers annually"
    "wolf:Animals:Easy:Wild social canine that hunts in packs and howls"
    "panda:Animals:Easy:Charming black-and-white bear native to China"
    "koala:Animals:Easy:Australian marsupial that eats eucalyptus leaves"
    "monkey:Animals:Medium:Lively primate famous for climbing trees and eating bananas"
    "rabbit:Animals:Medium:Long-eared burrowing mammal that loves garden vegetables"
    "giraffe:Animals:Medium:The tallest living terrestrial animal, boasting a long neck"
    "dolphin:Animals:Medium:Highly intelligent and friendly marine mammal"
    "leopard:Animals:Medium:Large spotted wild cat famous for climbing and hunting"
    "cheetah:Animals:Medium:The fastest land animal on Earth over short distances"
    "penguin:Animals:Medium:Flightless marine bird dressed in a natural tuxedo"
    "squirrel:Animals:Medium:Bushy-tailed rodent known for gathering and caching nuts"
    "crocodile:Animals:Hard:Large predatory semi-aquatic reptile with powerful jaws"
    "chimpanzee:Animals:Hard:Highly intelligent primate that is our closest living relative"
    "hippopotamus:Animals:Hard:Massive, heavy African mammal spending days in rivers"
    "orangutan:Animals:Hard:Solitary red-haired great ape inhabiting rainforests"

    # --- FRUITS & FOODS (20 Words) ---
    "apple:Fruits:Easy:Crisp round fruit that keeps the doctor away"
    "grape:Fruits:Easy:Small sweet berry growing in clusters, used for wine"
    "peach:Fruits:Easy:Fuzzy-skinned juicy stone fruit"
    "mango:Fruits:Easy:Tropical stone fruit, widely regarded as the king of fruits"
    "lemon:Fruits:Easy:Highly sour yellow citrus fruit used for seasoning"
    "onion:Fruits:Easy:Sharp pungent bulb vegetable that makes cooks cry"
    "banana:Fruits:Medium:Curved yellow tropical fruit favored by primates"
    "orange:Fruits:Medium:Sweet citrus fruit named after its vibrant color"
    "cherry:Fruits:Medium:Small round red stone fruit often topping desserts"
    "avocado:Fruits:Medium:Green pear-shaped fruit, base ingredient of guacamole"
    "coconut:Fruits:Medium:Large seed with a woody shell, white meat, and sweet water"
    "tomato:Fruits:Medium:Vibrant red fruit commonly treated as a salad vegetable"
    "garlic:Fruits:Medium:Strongly aromatic bulb used to season food and deter vampires"
    "broccoli:Fruits:Medium:Green vegetable resembling structural miniature trees"
    "strawberry:Fruits:Hard:Sweet red heart-shaped fruit with seeds on its exterior"
    "pineapple:Fruits:Hard:Large spiky tropical fruit with sweet fibrous yellow flesh"
    "watermelon:Fruits:Hard:Large green striped summer fruit with sweet red watery flesh"
    "pomegranate:Fruits:Hard:Leathery red fruit filled with ruby-like juicy edible seeds"
    "marshmallow:Fruits:Hard:Spongy sweet confection roasted over standard campfires"
    "spaghetti:Fruits:Hard:Long, thin cylindrical pasta of Italian origin"

    # --- TECHNOLOGY (20 Words) ---
    "byte:Technology:Easy:A unit of digital data storage consisting of eight bits"
    "code:Technology:Easy:Program instructions written according to computer language rules"
    "data:Technology:Easy:Quantities, characters, or operations stored by computers"
    "host:Technology:Easy:A computer connected to a network that provides resources"
    "cyber:Technology:Easy:Relating to computers, information technology, and virtual reality"
    "cloud:Technology:Easy:On-demand computer services hosted over the internet"
    "mouse:Technology:Easy:Hand-operated pointing device for navigating a display"
    "laptop:Technology:Medium:Highly portable personal computer complete with a screen"
    "server:Technology:Medium:Central computer providing files and services to other devices"
    "network:Technology:Medium:Interconnected system of computers exchanging data"
    "monitor:Technology:Medium:Visual display terminal hosting the user interface output"
    "printer:Technology:Medium:Peripheral machine rendering digital text or images to paper"
    "keyboard:Technology:Medium:Standard panel of keys used to input text into computers"
    "software:Technology:Medium:Programs and data operations powering operating systems"
    "database:Technology:Medium:Structured reservoir of digital data accessed via queries"
    "algorithm:Technology:Hard:Step-by-step mathematical logic for solving digital problems"
    "cryptography:Technology:Hard:Science of secure communication and encryption of data"
    "programming:Technology:Hard:Process of writing instruction sets to create software applications"
    "motherboard:Technology:Hard:The main printed circuit board containing central system chips"
    "cybersecurity:Technology:Hard:The practice of defending servers and networks from malicious attacks"
    "interface:Technology:Hard:The boundary across which two independent systems interact"
    "processor:Technology:Hard:The central integrated electronic circuit that executes instructions"
)

# ------------------------------------------------------------------------------
# 🎨 UI UTILITY FUNCTIONS
# ------------------------------------------------------------------------------

# Render game banner
draw_banner() {
    echo -e "${BOLD}${CYAN}"
    echo "=========================================================================="
    echo "  _   _ _   _ ____   ____ ____   _    __  __ ____  _     _____          "
    echo " | | | | \ | / ___| / ___|  _ \ / \  |  \/  | __ )| |   | ____|         "
    echo " | | | |  \| \___ \| |   | |_) / _ \ | |\/| |  _ \| |   |  _|           "
    echo " | |_| | |\  |___) | |___|  _ / ___ \| |  | | |_) | |___| |___          "
    echo "  \___/|_| \_|____/ \____|_| /_/   \_\_|  |_|____/|_____|_____|         "
    echo "                       C H A L L E N G E                                "
    echo "=========================================================================="
    echo -e "${RESET}"
}

# Display a stylized message box
print_box() {
    local color="$1"
    local title="$2"
    local content="$3"
    
    echo -e "${color}┌────────────────────────────────────────────────────────────────────────┐${RESET}"
    if [ -n "$title" ]; then
        printf "${color}│${BOLD} %-70s ${RESET}${color}│${RESET}\n" "$title"
        echo -e "${color}├────────────────────────────────────────────────────────────────────────┤${RESET}"
    fi
    IFS=$'\n' read -rd '' -a lines <<< "$content" || true
    for line in "${lines[@]}"; do
        printf "${color}│${WHITE} %-70s ${RESET}${color}│${RESET}\n" "$line"
    done
    echo -e "${color}└────────────────────────────────────────────────────────────────────────┘${RESET}"
}

# Clear terminal screen and show standard header
refresh_terminal() {
    eval "$CLEAR_CMD"
    draw_banner
}

# Generate random success comments
get_encouragement() {
    local msgs=(
        "Correct! Well done 🎉"
        "Outstanding! 🌟"
        "Spot on! 🎯"
        "Sensational guess! 🧠"
        "You nailed it! 🚀"
        "Brilliant solve! 💎"
        "Perfect guess! 🌈"
    )
    echo "${msgs[RANDOM % ${#msgs[@]}]}"
}

# ------------------------------------------------------------------------------
# 🧩 SCRAMBLE ENGINE
# ------------------------------------------------------------------------------
# Scrambles a word randomly. Employs shuf if available; otherwise uses a native
# Bash Fisher-Yates shuffle fallback.
# ------------------------------------------------------------------------------
scramble_word() {
    local word="$1"
    local scrambled=""
    
    # 1. Primary method: shuf utility
    if command -v shuf >/dev/null 2>&1; then
        # Use fold to split characters, shuf to randomize, tr to join
        scrambled=$(echo "$word" | fold -w1 | shuf | tr -d '\n')
        # If shuffled back to original and length is greater than 3, shuffle one more time
        if [ "$scrambled" = "$word" ] && [ ${#word} -gt 3 ]; then
            scrambled=$(echo "$word" | fold -w1 | shuf | tr -d '\n')
        fi
        echo "$scrambled"
        return
    fi
    
    # 2. Fallback method: Fisher-Yates pure Bash shuffle
    local len=${#word}
    local -a chars
    for ((i=0; i<len; i++)); do
        chars[i]="${word:i:1}"
    done
    
    for ((i=len-1; i>0; i--)); do
        local j=$((RANDOM % (i + 1)))
        local temp="${chars[i]}"
        chars[i]="${chars[j]}"
        chars[j]="$temp"
    done
    
    scrambled=""
    for char in "${chars[@]}"; do
        scrambled+="$char"
    done
    
    # If pure Bash shuffled to exact same word, swap first two indices to force difference
    if [ "$scrambled" = "$word" ] && [ $len -gt 3 ]; then
        local first="${scrambled:0:1}"
        local second="${scrambled:1:1}"
        scrambled="${second}${first}${scrambled:2}"
    fi
    
    echo "$scrambled"
}

# ------------------------------------------------------------------------------
# 💾 PERSISTENCE & DATA MANAGEMENT
# ------------------------------------------------------------------------------

# Append score entry to highscore file
record_highscore() {
    local name="$1"
    local score="$2"
    local mode="$3"
    local cat="$4"
    local diff="$5"
    local today
    today=$(date +%Y-%m-%d)
    
    # Write details to highscore file
    echo "$name|$score|$mode|$cat|$diff|$today" >> "$HIGHSCORE_FILE"
}

# Append descriptive log entry to game_log file
record_log() {
    local name="$1"
    local score="$2"
    local mode="$3"
    local cat="$4"
    local diff="$5"
    local solved="$6"
    local total="$7"
    local timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    echo "[$timestamp] Player: $name | Mode: $mode | Category: $cat | Difficulty: $diff | Score: $score | Words Solved: $solved/$total" >> "$LOG_FILE"
}

# Display top high scores (Leaderboard) sorted by score descending
show_leaderboard() {
    refresh_terminal
    
    if [ ! -f "$HIGHSCORE_FILE" ] || [ ! -s "$HIGHSCORE_FILE" ]; then
        print_box "$YELLOW" "LEADERBOARD STATUS" "No high scores registered yet.\nBe the first to secure a spot!"
        echo -e "\nPress [ENTER] to return to the Main Menu..."
        read -r _
        return
    fi
    
    echo -e "${BOLD}${BLUE}================================================================================${RESET}"
    echo -e "${BOLD}${CYAN}                            🏆 TOP 10 LEADERBOARD 🏆                            ${RESET}"
    echo -e "${BOLD}${BLUE}================================================================================${RESET}"
    printf "${BOLD}%-5s | %-16s | %-7s | %-12s | %-12s | %-10s | %-10s${RESET}\n" "Rank" "Player" "Score" "Mode" "Category" "Difficulty" "Date"
    echo -e "--------------------------------------------------------------------------------"
    
    local rank=1
    # Sort numerically (-n) by column 2 (-k2) using pipe delimiter (-t '|') in descending (-r) order
    sort -t '|' -k2 -rn "$HIGHSCORE_FILE" | head -n 10 | while IFS='|' read -r p_name p_score p_mode p_cat p_diff p_date; do
        local col=$RESET
        # Highlight top 3 spots elegantly
        if [ $rank -eq 1 ]; then
            col=$YELLOW # Gold
        elif [ $rank -eq 2 ]; then
            col=$CYAN   # Silver
        elif [ $rank -eq 3 ]; then
            col=$MAGENTA # Bronze
        fi
        
        printf "${col}%-5d${RESET} | ${col}%-16s${RESET} | %-7s | %-12s | %-12s | %-10s | %-10s\n" \
            "$rank" "$p_name" "$p_score" "$p_mode" "$p_cat" "$p_diff" "$p_date"
        rank=$((rank + 1))
    done
    echo -e "--------------------------------------------------------------------------------"
    
    echo -e "\nPress [ENTER] to return to the Main Menu..."
    read -r _
}

# Display recent game history logs
show_history() {
    refresh_terminal
    
    if [ ! -f "$LOG_FILE" ] || [ ! -s "$LOG_FILE" ]; then
        print_box "$YELLOW" "GAME HISTORY STATUS" "No gameplay sessions recorded yet.\nStart playing to generate game logs!"
        echo -e "\nPress [ENTER] to return to the Main Menu..."
        read -r _
        return
    fi
    
    echo -e "${BOLD}${BLUE}================================================================================${RESET}"
    echo -e "${BOLD}${CYAN}                            📊 RECENT GAME HISTORY 📊                           ${RESET}"
    echo -e "${BOLD}${BLUE}================================================================================${RESET}"
    
    # Read and print the last 15 log entries
    tail -n 15 "$LOG_FILE" | while read -r line; do
        # Extract components for clean rendering if formatted standardly
        if [[ "$line" =~ ^\[(.*)\]\ Player:\ (.*)\ \|\ Mode:\ (.*)\ \|\ Category:\ (.*)\ \|\ Difficulty:\ (.*)\ \|\ Score:\ (.*)\ \|\ Words\ Solved:\ (.*)$ ]]; then
            local ts="${BASH_REMATCH[1]}"
            local pl="${BASH_REMATCH[2]}"
            local md="${BASH_REMATCH[3]}"
            local ct="${BASH_REMATCH[4]}"
            local df="${BASH_REMATCH[5]}"
            local sc="${BASH_REMATCH[6]}"
            local sl="${BASH_REMATCH[7]}"
            
            echo -e "${CYAN}[$ts]${RESET} ${BOLD}$pl${RESET} - Mode: ${YELLOW}$md${RESET} | Cat: $ct | Diff: $df | Score: ${GREEN}$sc${RESET} | Solved: ${MAGENTA}$sl${RESET}"
        else
            # Fallback prints raw line
            echo -e "$line"
        fi
    done
    echo -e "--------------------------------------------------------------------------------"
    echo -e "${WHITE}Showing up to the 15 most recent sessions.${RESET}"
    echo -e "\nPress [ENTER] to return to the Main Menu..."
    read -r _
}

# ------------------------------------------------------------------------------
# ℹ️ INFORMATION SCREEN
# ------------------------------------------------------------------------------
show_rules() {
    refresh_terminal
    
    local rules_text
    rules_text="Welcome to Unscramble Challenge! Decode scrambled words to gain score.

🧠 GAME MODES:
1. Classic Mode  : Take all the time you need. Guess until you find it.
2. Timed Mode    : ⏱️ You have exactly 30 seconds per word. Multiple attempts allowed
                   within the limit. Timeout triggers immediate Game Over!
3. Challenge Mode: 🔥 Only exactly 3 attempts allowed per word. Lose all 3, it is Game Over!

💡 HINT SYSTEM:
* Type 'hint' during guessing to open the hint selector.
* Options: Reveal First Letter OR Show Category Clue.
* Hint penalty: -20 points from the current word's score.

🏆 SCORING FORMULA:
* Base Score: 100 points per word.
* Wrong attempts: Deducts 10 points per incorrect attempt.
* Hints used: Deducts 20 points.
* Speed/Perfect Bonus: +50 points if solved on the first attempt with no hints!
* Floor guarantee: Min score of 10 points per solved word."

    print_box "$GREEN" "📖 GAME RULES & GUIDELINES" "$rules_text"
    
    echo -e "\nPress [ENTER] to return to the Main Menu..."
    read -r _
}

# ------------------------------------------------------------------------------
# ⚙️ CONFIGURATION & MENU SELECTION
# ------------------------------------------------------------------------------
select_setup() {
    refresh_terminal
    
    # 1. CATEGORY SELECTION
    while true; do
        refresh_terminal
        echo -e "${BOLD}${MAGENTA}─── STEP 1: SELECT CATEGORY ──────────────────────────────────────────${RESET}\n"
        echo -e "  [1] Animals 🦁"
        echo -e "  [2] Fruits & Foods 🍎"
        echo -e "  [3] Technology 💻"
        echo -e "  [4] Mixed Pool 🌀\n"
        read -p "Select Category (1-4): " cat_choice
        
        case "$cat_choice" in
            1) SELECTED_CATEGORY="Animals"; break ;;
            2) SELECTED_CATEGORY="Fruits"; break ;;
            3) SELECTED_CATEGORY="Technology"; break ;;
            4) SELECTED_CATEGORY="Mixed"; break ;;
            *) echo -e "${RED}Invalid selection. Press [ENTER] to try again...${RESET}"; read -r _ ;;
        esac
    done
    
    # 2. DIFFICULTY SELECTION
    while true; do
        refresh_terminal
        echo -e "${BOLD}${MAGENTA}─── STEP 2: SELECT DIFFICULTY ────────────────────────────────────────${RESET}\n"
        echo -e "  Category selected: ${CYAN}${SELECTED_CATEGORY}${RESET}\n"
        echo -e "  [1] Easy (3-5 letters)   🟢"
        echo -e "  [2] Medium (6-8 letters) 🟡"
        echo -e "  [3] Hard (9+ letters)    🔴"
        echo -e "  [4] Mixed Difficulty     🌈\n"
        read -p "Select Difficulty (1-4): " diff_choice
        
        case "$diff_choice" in
            1) SELECTED_DIFFICULTY="Easy"; break ;;
            2) SELECTED_DIFFICULTY="Medium"; break ;;
            3) SELECTED_DIFFICULTY="Hard"; break ;;
            4) SELECTED_DIFFICULTY="Mixed"; break ;;
            *) echo -e "${RED}Invalid selection. Press [ENTER] to try again...${RESET}"; read -r _ ;;
        esac
    done
    
    # 3. GAME MODE SELECTION
    while true; do
        refresh_terminal
        echo -e "${BOLD}${MAGENTA}─── STEP 3: SELECT GAME MODE ─────────────────────────────────────────${RESET}\n"
        echo -e "  Category  : ${CYAN}${SELECTED_CATEGORY}${RESET}"
        echo -e "  Difficulty: ${CYAN}${SELECTED_DIFFICULTY}${RESET}\n"
        echo -e "  [1] Classic Mode (Unlimited attempts, relaxed) ⏱️✖️"
        echo -e "  [2] Timed Mode (30 seconds per word limit!) ⏱️"
        echo -e "  [3] Challenge Mode (Maximum of 3 attempts per word!) 🔥\n"
        read -p "Select Game Mode (1-3): " mode_choice
        
        case "$mode_choice" in
            1) SELECTED_MODE="Classic"; break ;;
            2) SELECTED_MODE="Timed"; break ;;
            3) SELECTED_MODE="Challenge"; break ;;
            *) echo -e "${RED}Invalid selection. Press [ENTER] to try again...${RESET}"; read -r _ ;;
        esac
    done
}

# ------------------------------------------------------------------------------
# 🎮 CORE GAMEPLAY ENGINE
# ------------------------------------------------------------------------------
play_game() {
    # Ensure player name is set
    if [ -z "$PLAYER_NAME" ]; then
        refresh_terminal
        echo -e "${BOLD}${CYAN}────────────────────────────────────────────────────────────────────────${RESET}"
        echo -e "               👋 WELCOME TO THE UNSCRAMBLE CHALLENGE!                  "
        echo -e "${BOLD}${CYAN}────────────────────────────────────────────────────────────────────────${RESET}\n"
        read -p "Enter your name to register score: " name_input
        # Remove whitespace or pipe symbols which break parsing
        PLAYER_NAME=$(echo "$name_input" | tr -d '|' | xargs)
        if [ -z "$PLAYER_NAME" ]; then
            PLAYER_NAME="Player"
        fi
    fi
    
    # Run setup configurations
    select_setup
    
    # Filter words based on parameters
    local -a filtered_pool=()
    for item in "${WORDS[@]}"; do
        IFS=':' read -r w c d h <<< "$item"
        local match_cat=false
        local match_diff=false
        
        if [ "$SELECTED_CATEGORY" = "Mixed" ] || [ "$c" = "$SELECTED_CATEGORY" ]; then
            match_cat=true
        fi
        
        if [ "$SELECTED_DIFFICULTY" = "Mixed" ] || [ "$d" = "$SELECTED_DIFFICULTY" ]; then
            match_diff=true
        fi
        
        if $match_cat && $match_diff; then
            filtered_pool+=("$item")
        fi
    done
    
    # Fallback to mixed pool if filter yielded no words
    if [ ${#filtered_pool[@]} -eq 0 ]; then
        filtered_pool=("${WORDS[@]}")
        SELECTED_CATEGORY="Mixed"
        SELECTED_DIFFICULTY="Mixed"
    fi
    
    # Shuffle words using Fisher-Yates algorithm
    local pool_size=${#filtered_pool[@]}
    for ((i=pool_size-1; i>0; i--)); do
        local j=$((RANDOM % (i + 1)))
        local temp="${filtered_pool[i]}"
        filtered_pool[i]="${filtered_pool[j]}"
        filtered_pool[j]="$temp"
    done
    
    # Standard length: 5 rounds
    local total_rounds=5
    if [ $pool_size -lt 5 ]; then
        total_rounds=$pool_size
    fi
    
    # Gameplay registers
    local cumulative_score=0
    local words_solved=0
    local game_aborted=false
    
    # Round Loop
    for ((round=1; round<=total_rounds; round++)); do
        local current_item="${filtered_pool[round-1]}"
        IFS=':' read -r original_word word_category word_difficulty word_hint <<< "$current_item"
        
        # Scramble word
        local scrambled
        scrambled=$(scramble_word "$original_word")
        
        local word_solved=false
        local wrong_attempts=0
        local hint_used=false
        local round_score=100
        
        # Timed mode start reference using Bash built-in SECONDS for fast, zero-spawn timing
        local start_word_time=$SECONDS
        local time_limit=30
        
        # Attempt Loop for current word
        while true; do
            refresh_terminal
            
            # Print round interface
            echo -e "${BOLD}${BLUE}┌─── ROUND $round / $total_rounds ────────────────────────────────────────────────────────┐${RESET}"
            printf "${BLUE}│${RESET} Player: %-15s | Mode: %-10s | Total Score: %-15d ${BLUE}│${RESET}\n" \
                "${BOLD}$PLAYER_NAME${RESET}" "$SELECTED_MODE" "$cumulative_score"
            printf "${BLUE}│${RESET} Category: %-13s | Difficulty: %-10s                          ${BLUE}│${RESET}\n" \
                "$word_category" "$word_difficulty"
            echo -e "${BLUE}├────────────────────────────────────────────────────────────────────────┤${RESET}"
            
            # Scrambled display
            local scrambled_upper
            scrambled_upper=$(echo "$scrambled" | tr 'a-z' 'A-Z')
            printf "${BLUE}│${RESET} Scrambled Word: ${BOLD}${YELLOW}%-53s${RESET} ${BLUE}│${RESET}\n" "$scrambled_upper"
            
            # Game Mode specific displays
            if [ "$SELECTED_MODE" = "Challenge" ]; then
                local attempts_left=$((3 - wrong_attempts))
                printf "${BLUE}│${RESET} Attempts Remaining: ${BOLD}${RED}%-50s${RESET} ${BLUE}│${RESET}\n" "$attempts_left"
            elif [ "$SELECTED_MODE" = "Timed" ]; then
                local elapsed=$((SECONDS - start_word_time))
                local time_left=$((time_limit - elapsed))
                
                if [ $time_left -le 0 ]; then
                    printf "${BLUE}│${RESET} Time Left: ${BOLD}${RED}%-60s${RESET} ${BLUE}│${RESET}\n" "0s - TIME'S UP!"
                else
                    local time_col=$GREEN
                    if [ $time_left -le 10 ]; then
                        time_col=$RED
                    elif [ $time_left -le 20 ]; then
                        time_col=$YELLOW
                    fi
                    printf "${BLUE}│${RESET} Time Left: ${BOLD}${time_col}%-60s${RESET} ${BLUE}│${RESET}\n" "${time_left}s"
                fi
            else
                printf "${BLUE}│${RESET} Attempts: %-60s ${BLUE}│${RESET}\n" "$wrong_attempts"
            fi
            
            # Hint feedback display
            if $hint_used; then
                echo -e "${BLUE}├────────────────────────────── HINT DISPLAY ────────────────────────────┤${RESET}"
                printf "${BLUE}│${RESET} ${MAGENTA}Hint Used (-20 pts)${RESET}                                                 ${BLUE}│${RESET}\n"
                printf "${BLUE}│${RESET} %-70s ${BLUE}│${RESET}\n" "$HINT_TEXT"
            fi
            echo -e "${BLUE}└────────────────────────────────────────────────────────────────────────┘${RESET}"
            
            # Check Time Limit expiration (Timed Mode)
            if [ "$SELECTED_MODE" = "Timed" ]; then
                local current_elapsed=$((SECONDS - start_word_time))
                if [ $current_elapsed -ge $time_limit ]; then
                    echo -e "\n${RED}${BOLD}⏱️ TIME'S UP! Game Over!${RESET}"
                    echo -e "The correct word was: ${GREEN}${BOLD}$(echo "$original_word" | tr 'a-z' 'A-Z')${RESET}"
                    echo -e "\nPress [ENTER] to continue to the results summary..."
                    read -r _
                    break 2 # Break both loops (ends game session)
                fi
                
                # Dynamic timeout deduction for reading input
                local remaining_timeout=$((time_limit - current_elapsed))
                read -t $remaining_timeout -p "Enter guess (or 'hint' / 'quit'): " player_guess
                local read_status=$?
                
                if [ $read_status -gt 128 ]; then
                    echo -e "\n${RED}${BOLD}⏱️ TIME'S UP! Game Over!${RESET}"
                    echo -e "The correct word was: ${GREEN}${BOLD}$(echo "$original_word" | tr 'a-z' 'A-Z')${RESET}"
                    echo -e "\nPress [ENTER] to continue to the results summary..."
                    read -r _
                    break 2
                fi
            else
                read -p "Enter guess (or 'hint' / 'quit'): " player_guess
            fi
            
            # Convert guess to lowercase and trim spaces
            local guess_clean
            guess_clean=$(echo "$player_guess" | tr 'A-Z' 'a-z' | xargs)
            
            # Check for empty guesses
            if [ -z "$guess_clean" ]; then
                echo -e "${YELLOW}Please enter a valid word guess or command.${RESET}"
                sleep 1.2
                continue
            fi
            
            # Handle user typing 'quit'
            if [ "$guess_clean" = "quit" ]; then
                game_aborted=true
                break 2
            fi
            
            # Handle user typing 'hint'
            if [ "$guess_clean" = "hint" ]; then
                if $hint_used; then
                    echo -e "${YELLOW}You have already used a hint for this word!${RESET}"
                    sleep 1.5
                    continue
                fi
                
                # Show hint menu
                echo -e "\n${BOLD}${CYAN}💡 HINT SYSTEM (-20 Points Penalty) ───────────────────────────────────${RESET}"
                echo -e "  [1] Reveal First Letter (e.g. Starts with 'S')"
                echo -e "  [2] Reveal Category Clue (Word description)\n"
                read -p "Choose hint option (1-2): " hint_opt
                
                case "$hint_opt" in
                    1)
                        local first_char
                        first_char=$(echo "${original_word:0:1}" | tr 'a-z' 'A-Z')
                        HINT_TEXT="First letter of the word is: '${first_char}'"
                        hint_used=true
                        round_score=$((round_score - 20))
                        ;;
                    2)
                        HINT_TEXT="Clue: ${word_hint}"
                        hint_used=true
                        round_score=$((round_score - 20))
                        ;;
                    *)
                        echo -e "${RED}Invalid choice. Hint cancelled.${RESET}"
                        sleep 1.2
                        ;;
                esac
                continue
            fi
            
            # Validate core guess
            if [ "$guess_clean" = "$original_word" ]; then
                # Correct Guess!
                word_solved=true
                words_solved=$((words_solved + 1))
                
                # Score Calculation
                # Deduct points for wrong guesses
                round_score=$((round_score - (wrong_attempts * 10)))
                
                # Perfect Solve Bonus (+50 pts for first attempt without hints)
                if [ $wrong_attempts -eq 0 ] && [ "$hint_used" = false ]; then
                    round_score=$((round_score + 50))
                    local perfect_text="🌟 PERFECT SPEED BONUS +50 PTS! 🌟"
                else
                    local perfect_text=""
                fi
                
                # Floor score at 10 points to avoid negative scores
                if [ $round_score -lt 10 ]; then
                    round_score=10
                fi
                
                cumulative_score=$((cumulative_score + round_score))
                
                # Display Success Screen
                refresh_terminal
                echo -e "${GREEN}${BOLD}"
                echo "=========================================================================="
                echo "               🎯 CORRECT GUESS! YOU SOLVED IT!                           "
                echo "=========================================================================="
                echo -e "${RESET}"
                
                local enc_msg
                enc_msg=$(get_encouragement)
                
                local success_box
                success_box="Word         : $(echo "$original_word" | tr 'a-z' 'A-Z')\n"
                success_box+="Message      : $enc_msg\n"
                success_box+="Attempts     : $((wrong_attempts + 1))\n"
                success_box+="Points Gained: +$round_score pts\n"
                if [ -n "$perfect_text" ]; then
                    success_box+="\n$perfect_text"
                fi
                
                print_box "$GREEN" "🏆 ROUND $round COMPLETE" "$success_box"
                
                echo -e "\nPress [ENTER] to move to the next round..."
                read -r _
                break
            else
                # Incorrect Guess!
                wrong_attempts=$((wrong_attempts + 1))
                
                # Validate Challenge mode limits
                if [ "$SELECTED_MODE" = "Challenge" ] && [ $wrong_attempts -ge 3 ]; then
                    echo -e "\n${RED}${BOLD}❌ ATTEMPTS EXCEEDED! Game Over!${RESET}"
                    echo -e "The correct word was: ${GREEN}${BOLD}$(echo "$original_word" | tr 'a-z' 'A-Z')${RESET}"
                    echo -e "\nPress [ENTER] to continue to the results summary..."
                    read -r _
                    break 2
                fi
                
                echo -e "${RED}Try again ❌ (Incorrect guess)${RESET}"
                sleep 1.2
            fi
        done
    done
    
    # --------------------------------------------------------------------------
    # 🏁 GAME OVER SUMMARY SCREEN
    # --------------------------------------------------------------------------
    refresh_terminal
    echo -e "${BOLD}${MAGENTA}==========================================================================${RESET}"
    echo -e "${BOLD}${MAGENTA}                            🎮 GAME OVER 🎮                               ${RESET}"
    echo -e "${BOLD}${MAGENTA}==========================================================================${RESET}\n"
    
    if $game_aborted; then
        print_box "$YELLOW" "SESSION STATUS: ABORTED" "You exited the gameplay session midway.\nNo scores will be recorded on the leaderboard."
    else
        local summary_txt
        summary_txt="Player Registered : $PLAYER_NAME\n"
        summary_txt+="Selected Category : $SELECTED_CATEGORY\n"
        summary_txt+="Difficulty Level  : $SELECTED_DIFFICULTY\n"
        summary_txt+="Gameplay Mode     : $SELECTED_MODE\n"
        summary_txt+="Words Solved      : $words_solved/$total_rounds\n\n"
        summary_txt+="FINAL SCORE       : $cumulative_score points"
        
        print_box "$CYAN" "📝 PERFORMANCE SUMMARY" "$summary_txt"
        
        # Save scores to persistent files
        record_highscore "$PLAYER_NAME" "$cumulative_score" "$SELECTED_MODE" "$SELECTED_CATEGORY" "$SELECTED_DIFFICULTY"
        record_log "$PLAYER_NAME" "$cumulative_score" "$SELECTED_MODE" "$SELECTED_CATEGORY" "$SELECTED_DIFFICULTY" "$words_solved" "$total_rounds"
        
        echo -e "${GREEN}${BOLD}Score saved to leaderboard!${RESET}"
    fi
    
    # Prompt for replay option
    echo -e "\nWould you like to play again? (y/n)"
    read -p "Selection: " replay_choice
    local replay_clean
    replay_clean=$(echo "$replay_choice" | tr 'A-Z' 'a-z' | xargs)
    if [ "$replay_clean" = "y" ] || [ "$replay_clean" = "yes" ]; then
        play_game
    fi
}

# ------------------------------------------------------------------------------
# 🏠 MAIN MENU SYSTEM
# ------------------------------------------------------------------------------
main_menu() {
    while true; do
        refresh_terminal
        
        echo -e "Welcome to Unscramble Challenge! Pick an option from the menu:\n"
        echo -e "  ${BOLD}${GREEN}[1] Play Game 🎮${RESET}"
        echo -e "  ${BOLD}${YELLOW}[2] View Leaderboard 🏆${RESET}"
        echo -e "  ${BOLD}${CYAN}[3] View Game History 📊${RESET}"
        echo -e "  ${BOLD}${BLUE}[4] How to Play / Rules ℹ️${RESET}"
        echo -e "  ${BOLD}${RED}[5] Exit Game ❌${RESET}\n"
        
        read -p "Select Option (1-5): " menu_option
        local opt_clean
        opt_clean=$(echo "$menu_option" | tr -d ' ' | xargs)
        
        case "$opt_clean" in
            1) play_game ;;
            2) show_leaderboard ;;
            3) show_history ;;
            4) show_rules ;;
            5)
                refresh_terminal
                echo -e "${GREEN}Thank you for playing Unscramble Challenge! Goodbye! 👋${RESET}\n"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid selection. Press [ENTER] to try again...${RESET}"
                read -r _
                ;;
        esac
    done
}

# ------------------------------------------------------------------------------
# 🚀 SYSTEM BOOTSTRAP
# ------------------------------------------------------------------------------
# Launch the main menu immediately when executed
main_menu

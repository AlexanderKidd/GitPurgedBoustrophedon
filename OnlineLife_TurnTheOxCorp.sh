#!/bin/bash

FILE="GitPurgedOnlineLifeText.txt"
DEMON="SadCodeDemonFace.txt"
HAPPY="HappyCodeDemonFace.txt"

# Set a color palette with different codes
# Using ANSI escape sequences directly for better reliability
RED='\033[38;2;255;0;0m'
ORANGE='\033[38;5;208m'
GREEN='\033[0;32m'
WHITE='\033[1;37m' # Bright white
RESET='\033[0m'

# Typewriter print function
typewriter_print() {
    local content="$1"
    local color="$2"
    local delay="$3"
    local i
    for (( i=0; i<${#content}; i++ )); do
        echo -n -e "${color}${content:$i:1}${RESET}"
        sleep "$delay"
    done
    echo # New line after the text is typed
}

# Center display text (multi-line ASCII)
center_display() {
    local content="$1"
    local color="$2"
    clear
    local lines cols row col
    lines=$(tput lines)
    cols=$(tput cols)
    row=$((lines / 2))

    while IFS= read -r line; do
        col=$(( (cols - ${#line}) / 2 ))
        tput cup $row $col
        echo -e "${color}${line}${RESET}"
        ((row++))
    done <<< "$content"
}

# Happy demon blink (green/white)
show_happy_demon() {
    local happy_content
    happy_content=$(<"$HAPPY")
    local colors=("$GREEN" "$WHITE")
    for i in {1..5}; do
        local color_index=$(( (i + 1) % 2 ))
        center_display "$happy_content" "${colors[$color_index]}"
        sleep 0.1 # Reduced sleep time for faster blinking
        clear
        sleep 0.1 # Reduced sleep time for faster blinking
    done
}

# Sad demon blink (red/orange)
show_demon() {
    local demon_content
    demon_content=$(<"$DEMON")
    local colors=("$RED" "$ORANGE")
    for i in {1..5}; do
        local color_index=$(( (i + 1) % 2 ))
        center_display "$demon_content" "${colors[$color_index]}"
        sleep 0.1 # Reduced sleep time for faster blinking
        clear
        sleep 0.1 # Reduced sleep time for faster blinking
    done
}

# Show initial menu
show_initial_menu() {
    clear
    
    # Read and print all lines up to "Welcome to your online life!"
    while IFS= read -r line; do
        line=$(echo "$line" | tr -d '\r')
        
        if [[ "$line" == "Welcome to your online life!" ]]; then
            break
        fi
        
        if [[ ! -z "$line" ]]; then
            echo -e "${RED}$line${RESET}"
            # Random delay between 300ms and 1000ms
            delay_ms=$(( (RANDOM % 301) + 50 ))
            delay_s=$(printf "0.%03d" "$delay_ms")
            sleep "$delay_s"
        else
            echo ""
        fi
    done < "$FILE"
    
    # 5 second pause
    sleep 5
    
    # Print "Welcome to your online life!"
    echo -e "${RED}Welcome to your online life!${RESET}"
    echo ""
    
    # 3 second pause
    sleep 3
    
    # Print A) Begin prompt
    echo -e "${RED}A) Begin${RESET}"
    echo ""
    read -p ""
}

# Parse game file and extract scenes
declare -A scenes
declare -A scene_options
declare -A scene_text

parse_game_file() {
    local current_scene=""
    local current_text=""
    local current_options=""
    
    while IFS= read -r line; do
        line=$(echo "$line" | tr -d '\r')
        
        # Match [SCENE X] pattern
        if [[ "$line" =~ ^\[SCENE\ ([0-9]+)\]$ ]]; then
            # Save previous scene if exists
            if [[ -n "$current_scene" ]]; then
                scene_text["$current_scene"]="$current_text"
                scene_options["$current_scene"]="$current_options"
            fi
            current_scene="${BASH_REMATCH[1]}"
            current_text=""
            current_options=""
        # Match [SCENE END] pattern
        elif [[ "$line" =~ ^\[SCENE\ END\]$ ]]; then
            if [[ -n "$current_scene" ]]; then
                scene_text["$current_scene"]="$current_text"
                scene_options["$current_scene"]="$current_options"
            fi
            current_scene="END"
            current_text=""
            current_options=""
        # Match GOTO pattern (options with consequences)
        elif [[ "$line" =~ ^GOTO ]]; then
            if [[ -n "$current_options" ]]; then
                current_options+=$'\n'"$line"
            else
                current_options="$line"
            fi
        # Match option lines (A), B), C))
        elif [[ "$line" =~ ^[ABC]\) ]]; then
            if [[ -n "$current_text" ]]; then
                current_text+=$'\n'"$line"
            else
                current_text="$line"
            fi
        # Regular scene text or blank lines
        elif [[ -n "$current_scene" ]]; then
            if [[ -n "$current_text" ]]; then
                current_text+=$'\n'"$line"
            else
                current_text="$line"
            fi
        fi
    done < "$FILE"
    
    # Save last scene
    if [[ -n "$current_scene" ]]; then
        scene_text["$current_scene"]="$current_text"
        scene_options["$current_scene"]="$current_options"
    fi
}

# Extract ALL follower changes from text and sum them
get_follower_change() {
    local line="$1"
    local total=0
    local remaining="$line"
    
    # Loop through and find all instances of (+X followers) or (-X followers)
    while [[ "$remaining" =~ \(([+-][0-9]+)[[:space:]]*followers\) ]]; do
        total=$((total + ${BASH_REMATCH[1]}))
        # Remove the matched portion and continue searching
        remaining="${remaining#*${BASH_REMATCH[0]}}"
    done
    
    echo "$total"
}

# Get next scene based on user choice
get_next_scene() {
    local options="$1"
    local choice="$2"
    local emotion=""
    
    # Find the line that matches the user's choice
    while IFS= read -r option_line; do
        # Match the GOTO line and the choice (A, B, or C)
        if [[ "$option_line" =~ GOTO\ SCENE\ ([A-Z0-9]+)\ ([❌✅])\ ([ABC])\.(.*)$ ]]; then
            local next_scene="${BASH_REMATCH[1]}"
            local emoji="${BASH_REMATCH[2]}"
            local opt="${BASH_REMATCH[3]}"
            local result_text="${BASH_REMATCH[4]}"
            
            if [[ "$opt" == "$choice" ]]; then
                emotion="$emoji"
                local followers_change=$(get_follower_change "$option_line")
                # Trim leading space from result_text
                result_text=${result_text:1}
                echo "$next_scene|$emotion|$followers_change|$result_text"
                return
            fi
        fi
    done <<< "$options"
}

# Print scene with follower count in top right
print_scene() {
    local scene_num="$1"
    local followers="$2"
    local last_result="$3"
    
    clear
    
    # Get terminal width
    local cols=$(tput cols)
    local follower_text="$followers Followers"
    local padding=$((cols - ${#follower_text}))
    
    # Print followers in top right (in red)
    printf "${RED}%${padding}s${RESET}\n" "$follower_text"
    echo ""
    
    # Print last result text if available
    if [[ -n "$last_result" ]]; then
        echo -e "${RED}$last_result${RESET}"
        echo ""
    fi
    
    # Print scene text and options (skip GOTO lines)
    local text="${scene_text[$scene_num]}"
    local first_option=true
    while IFS= read -r line; do
        if [[ ! "$line" =~ ^GOTO ]]; then
            typewriter_print "$line" "$RED" "0.02"
        fi
    done <<< "$text"
}

# Main game loop
main() {
    show_initial_menu
    
    # Parse the game file
    parse_game_file
    
    # Start at scene 1 with 100 followers
    local current_scene="1"
    local followers=100
    local last_result_text=""
    
    while true; do
        # Check if at END scene
        if [[ "$current_scene" == "END" ]]; then
            print_scene "END" "$followers" "$last_result_text"
            echo ""
            read -p ""
            break
        fi
        
        # Check if followers depleted
        if (( followers <= 0 )); then
            # Show END scene
            print_scene "END" "0" "$last_result_text"
            echo ""
            break
        fi
        
        # Print current scene with last result text
        print_scene "$current_scene" "$followers" "$last_result_text"
        
        # Reset result text for next scene
        last_result_text=""
        
        # Get valid options from scene
        local options_text="${scene_options[$current_scene]}"
        local valid_choices_str=""
        
        # Parse valid choices from options
        while IFS= read -r option_line; do
            if [[ "$option_line" =~ GOTO\ SCENE\ [A-Z0-9]+\ [❌✅]\ ([ABC])\. ]]; then
                choice_letter="${BASH_REMATCH[1]}"
                if [[ -z "$valid_choices_str" ]]; then
                    valid_choices_str="$choice_letter"
                else
                    valid_choices_str="$valid_choices_str $choice_letter"
                fi
            fi
        done <<< "$options_text"
        
        # Prompt user for choice
        read -p "Choose ($valid_choices_str): " user_choice
        user_choice=${user_choice^^}  # Convert to uppercase
        
        # Validate choice
        if [[ ! "$valid_choices_str" =~ $user_choice ]]; then
            echo "Invalid choice. Please try again."
            sleep 1
            continue
        fi
        
        # Get next scene, emotion, followers_change, and result text
        local result=$(get_next_scene "$options_text" "$user_choice")
        IFS='|' read -r next_scene emotion followers_change result_text <<< "$result"
        
        # Show appropriate demon face
        if [[ "$emotion" == "✅" ]]; then
            show_happy_demon
        elif [[ "$emotion" == "❌" ]]; then
            show_demon
        fi
        
        # Print the result text to keep it visible
        if [[ -n "$result_text" ]]; then
            echo -e "${RED}$result_text${RESET}"
            last_result_text="$result_text"
        fi
        
        # Apply follower changes
        followers=$((followers + followers_change))
        
        # Check if followers depleted after choice
        if (( followers <= 0 )); then
            followers=0  # Ensure it doesn't go negative
        fi
        
        # Move to next scene
        current_scene="$next_scene"
    done
}

main

clear

echo -e "${RED} --git-purged command not found. ${RESET}"

sleep 3
clear

while true
do
    rand=$(( ( RANDOM % 100 )  + 1 ))
    if (( rand % 100 <= 95 )); then
        echo -e "${RED} Do not exit ${RESET}"
    fi
    if (( rand % 30 == 0 )); then
        echo -e "${RED}YOU CANNOT EXIT ${RESET}"
        echo -e "${RED} YOU CANNOT EXIT ${RESET}"
        echo -e "${RED}  YOU CANNOT EXIT ${RESET}"
    fi
    if (( rand % 100 > 95 )); then
    	show_demon
    fi
    sleep 0.1
done
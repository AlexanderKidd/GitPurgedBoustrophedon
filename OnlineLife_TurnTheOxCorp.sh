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

# count=0

# # Open the file on file descriptor 3
# exec 3<"$FILE"

# # Loop to read from file descriptor 3
# while IFS= read -r line <&3; do
#     # Remove any trailing carriage return characters (\r) from the line
#     line=$(echo "$line" | tr -d '\r')

#     # Check for the word END to stop the story
#     if [[ "$line" == "END" ]]; then
#         break
#     fi

#     # Random delay between 250ms and 1000ms
#     delay_ms=$(( (RANDOM % 751) + 250 ))
#     delay_s=$(printf "0.%03d" "$delay_ms")
#     sleep "$delay_s"

#     # Handle the choice block and wait for a newline
#     if [[ "$line" =~ ^[ABC]\) ]]; then
#         typewriter_print "$line" "$RED" "0.05"
#         # Start a loop to print all subsequent lines until a blank one
#         while IFS= read -r inner_line <&3; do
#             # Remove any trailing carriage return characters (\r) from the inner line
#             inner_line=$(echo "$inner_line" | tr -d '\r')
#             if [[ -z "$inner_line" ]]; then
#                 # Found the blank line, print it and wait for input
#                 echo ""
#                 read -p ""
#                 break # Exit the inner loop
#             else
#                 # Print the line and continue
#                 typewriter_print "$inner_line" "$RED" "0.05"
#             fi
#         done
#         continue # Skip the rest of the outer loop for this iteration
#     fi

#     # Handle other line types
#     case "$line" in
#         "❌")
#             show_demon
#             ;;
#         "✅")
#             show_happy_demon
#             ;;
#         *)
#             if [ $count -lt 22 ]; then
#                 echo -e "${RED}${line}${RESET}"
#             fi
#             if [ $count -eq 22 ]; then
#                 clear
#             fi
#             if [ $count -gt 22 ]; then
#                 typewriter_print "$line" "$RED" "0.05"
#             fi
#             ;;
#     esac

#     ((count++))
# done

# Close file descriptor 3
# exec 3>&-

clear

echo -e "${RED} --git-purged command not found. ${RESET}"

sleep .3
clear

while true
do
    rand=$(( ( RANDOM % 30 )  + 1 ))
    if (( rand % 30 == 0 )); then
        echo -e "${RED}YOU CANNOT EXIT ${RESET}"
        echo -e "${RED} YOU CANNOT EXIT ${RESET}"
        echo -e "${RED} YOU CANNOT EXIT ${RESET}"
    fi
    if (( rand % 20 == 0 )); then
    	show_demon
    fi
    if (( rand % 30 != 0 )); then
        echo -e "${RED} Do not exit ${RESET}"
    fi
done
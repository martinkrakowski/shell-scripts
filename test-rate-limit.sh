#!/bin/zsh

# Prompt for the URL
echo "Rate limit tester"
echo "-----------------"
echo -n "URL: "
read URL

# Prompt for sleep time between requests
echo -n "Time between requests (in seconds, e.g., 0.1): "
read SLEEP

# Prompt for the number of requests to send
echo -n "Number of requests: "
read REQUESTS

# Ensure that SLEEP and REQUESTS are valid numeric values
if ! [[ "$SLEEP" =~ ^[0-9]+(\.[0-9]+)?$ ]] || ! [[ "$REQUESTS" =~ ^[0-9]+$ ]]; then
    echo "Invalid input. Please enter a valid numeric value for sleep time and number of requests."
    exit 1
fi

echo "Testing rate limit using $REQUESTS requests, with a sleep of $SLEEP seconds."

# Initialize counters for successful and non-successful responses
SUCCESS_COUNT=0
NON_SUCCESS_COUNT=0

# Define the width of the progress bar
PROGRESS_BAR_WIDTH=50

# Calculate the number of requests per progress step
REQUESTS_PER_STEP=$((REQUESTS / PROGRESS_BAR_WIDTH))

# Loop to send the requests
for ((i=1; i<=$REQUESTS; i++)); do
    # Use curl to send the request and capture the HTTP status code
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$URL")

    # Check if the response is HTTP 200 (success)
    if [ "$HTTP_STATUS" = "200" ]; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        NON_SUCCESS_COUNT=$((NON_SUCCESS_COUNT + 1))
    fi

    # Calculate the current progress
    CURRENT_PROGRESS=$((i / REQUESTS_PER_STEP))

    # Print the progress bar
    printf "\rProgress: ["
    for ((j=1; j<=$PROGRESS_BAR_WIDTH; j++)); do
        if [ $j -le $CURRENT_PROGRESS ]; then
            printf "#"
        else
            printf " "
        fi
    done
    printf "] %3d%% - Successful: %d - Non-Successful: %d" $((CURRENT_PROGRESS * 2)) "$SUCCESS_COUNT" "$NON_SUCCESS_COUNT"

    # Sleep for the specified duration
    sleep "$SLEEP"
done

# Print a newline character to end the status bar line
echo ""

# Print the final results
echo "Total successful responses (HTTP 200): $SUCCESS_COUNT"
echo "Total non-successful responses (non-HTTP 200): $NON_SUCCESS_COUNT"

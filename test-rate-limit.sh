#!/bin/zsh

# Prompt for the URL
echo "Rate limit tester"
echo "-----------------"
echo -n "URL: "
read URL

# Prompt for sleep time between requests
echo -n "Enter sleep time between requests (in seconds, e.g., 0.1): "
read SLEEP

# Prompt for the number of requests to send
echo -n "Enter the number of requests to send: "
read REQUESTS

# Set the maximum timeout for curl in seconds (adjust as needed)
CURL_TIMEOUT=10

# Ensure that SLEEP and REQUESTS are valid numeric values
if ! [[ "$SLEEP" =~ ^[0-9]+(\.[0-9]+)?$ ]] || ! [[ "$REQUESTS" =~ ^[0-9]+$ ]]; then
    echo "Invalid input. Please enter a valid numeric value for sleep time and number of requests."
    exit 1
fi

echo "Testing rate limit using $REQUESTS requests to $URL, with a sleep of $SLEEP seconds."

# Initialize counters for successful and non-successful responses
SUCCESS_COUNT=0
NON_SUCCESS_COUNT=0

# Function to send a single request
send_request() {
    HTTP_STATUS=$(curl -s --max-time $CURL_TIMEOUT -o /dev/null -w "%{http_code}" "$URL")

    if [ "$HTTP_STATUS" = "200" ]; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        NON_SUCCESS_COUNT=$((NON_SUCCESS_COUNT + 1))
    fi
}

# Function to update the progress bar
update_progress() {
    PROGRESS=$((i * 100 / REQUESTS))
    PROGRESS_BAR="["
    for ((j=0; j<PROGRESS; j++)); do
        PROGRESS_BAR+="#"
    done
    for ((j=PROGRESS; j<100; j++)); do
        PROGRESS_BAR+=" "
    done
    PROGRESS_BAR+="] $PROGRESS%"

    # Print the updated progress bar on the same line
    echo -ne "\r$PROGRESS_BAR"
}

# Use a loop to send requests
for ((i=1; i<=$REQUESTS; i++)); do
    send_request  # Send the request
    update_progress  # Update the progress bar
    sleep "$SLEEP"  # Sleep for the specified duration
done

# Print a newline to end the progress line
echo ""

# Print the final results
echo "Total successful responses (HTTP 200): $SUCCESS_COUNT"
echo "Total non-successful responses (non-HTTP 200): $NON_SUCCESS_COUNT"

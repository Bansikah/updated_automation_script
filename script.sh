#!/bin/bash
# Function to greet the user and present the menu
greet_user() {
    echo "Hello User! Welcome. Which operation would you like to perform today?"
    echo "Please select a task to execute:"
    echo "1. System Inspection and Report"
    echo "2. File Operations"
    echo "3. Bonus Challenge - Data Fetching"
    echo "4. Settings"
    echo "5. Exit"
}
# Function to perform system inspection
system_inspection() {
    # List all running processes and output to a file
    ps -ef > processes.txt
    echo "List of running processes saved to processes.txt"
    # Check active network connections and output to a file
    netstat -an > network_connections.txt
    echo "Active network connections saved to network_connections.txt"
    # Search for disk usage starting from the home directory and output to a file
    find ~ -type d -exec du -sh {} + > disk_usage.txt
    echo "Disk usage summary saved to disk_usage.txt"
    # Summarize the findings in a brief report
    echo "System Inspection and Report Summary:"
    echo "-----------------------------------"
    echo "Running processes: $(wc -l < processes.txt)"
    echo "Disk space used: $(du -sh ~ | awk '{print $1}')"
    echo "Top 5 directories consuming disk space:"
    sort -rh disk_usage.txt | head -n 5
    echo "Active network connections: $(wc -l < network_connections.txt)"
    # Do not delete the temporary files
}
# Function to perform file operations
file_operations() {
    # Function to search for files by extension within a specified directory
    search_files() {
        read -p "Enter the directory path to search: " directory
        read -p "Enter the file extension to search (e.g., .txt): " extension
        if [[ -d "$directory" ]]; then
            echo "Searching for files with extension $extension in directory $directory..."
            find "$directory" -type f -name "*$extension"
        else
            echo "Invalid directory path. Please try again."
        fi
    }
    # Function to count the number of lines in a specified file
    count_lines() {
        read -p "Enter the file path to count lines: " file
        if [[ -f "$file" ]]; then
            echo "Counting the number of lines in file $file..."
            wc -l "$file"
        else
            echo "Invalid file path. Please try again."
        fi
    }
    # Function to backup a specified directory to a chosen location
    backup_directory() {
        read -p "Enter the directory path to backup: " directory
        read -p "Enter the backup location directory: " backup_location
        if [[ -d "$directory" ]]; then
            echo "Backing up directory $directory to $backup_location..."
            cp -r "$directory" "$backup_location"
            echo "Backup completed!"
        else
            echo "Invalid directory path. Please try again."
        fi
    }
    # File operations menu
    echo "Please select a file operation:"
    echo "1. Search for files by extension"
    echo "2. Count the number of lines in a file"
    echo "3. Backup a directory"
    echo "4. Back to the main menu"
    # Reading user input for file operations
    read -p "Enter your choice: " file_operation_choice
    # Checking user choice for file operations and executing tasks
    case $file_operation_choice in
        1)
            search_files
            ;;
        2)
            count_lines
            ;;
        3)
            backup_directory
            ;;
        4)
            echo "Returning to the main menu..."
            ;;
        *)
            echo "Invalid choice. Returning to the main menu..."
            ;;
    esac
}
# Function to fetch weather data
fetch_weather_data() {
    read -p "Enter the city name: " city
    if [[ -n "$city" ]]; then
        echo "Fetching weather data for $city..."
        weather_data=$(curl -s "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$API_KEY")
        if [[ -n "$weather_data" ]]; then
            temperature_K=$(echo "$weather_data" | jq -r '.main.temp')
            temperature_C=$(echo "$temperature_K - 273.15" | bc)
            weather=$(echo "$weather_data" | jq -r '.weather[0].description')
            echo "Current weather in $city: $weather"
            echo "Temperature: $temperature_C °C"
        else
            echo "Failed to fetch weather data. Please try again."
        fi
    else
        echo "Invalid city name. Please try again."
    fi
}
# Function to update the API key
update_api_key() {
    read -p "Enter the new API key: " new_api_key
    if [[ -n "$new_api_key" ]]; then
        # Save the new API key to the settings file
        echo "API_KEY=$new_api_key" > settings.conf
        echo "API key updated successfully!"
    else
        echo "Invalid API key. Please try again."
    fi
}
# Function to load the API key from the settings file
load_api_key() {
    if [[ -f "settings.conf" ]]; then
        source "settings.conf"
        echo "API key loaded from settings.conf"
    else
        echo "No settings.conf file found. Using default API key."
        API_KEY="a83e79ca882c7b568d69cf7ca2ad09c9"
    fi
}
# Main script logic
load_api_key
while true; do
    greet_user
    read -p "Enter your choice: " choice
    case $choice in
        1)
            echo "Performing System Inspection and Report..."
            system_inspection
            ;;
        2)
            echo "Performing File Operations..."
            file_operations
            ;;
        3)
            echo "Performing Bonus Challenge - Data Fetching..."
            fetch_weather_data
            ;;
        4)
            echo "Settings Menu:"
            echo "1. Update API Key"
            echo "2. Back to the main menu"
            read -p "Enter your choice: " settings_choice
            case $settings_choice in
                1)
                    echo "Updating API Key..."
                    update_api_key
                    ;;
                2)
                    echo "Returning to the main menu..."
                    ;;
                *)
                    echo "Invalid choice. Returning to the main menu..."
                    ;;
            esac
            ;;
        5)
            echo "Exiting the script. Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
    echo
done
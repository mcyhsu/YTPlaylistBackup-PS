# Description: A PowerShell script to back up YouTube playlist details to CSV files

###############################  ENTER YOUR DETAILS HERE  ###############################

# Enter your YouTube Data API key here
# Get your API key from the Google Cloud Console: https://console.developers.google.com/
# Make sure the YouTube Data API v3 is enabled for your project
$apiKey = "api-key-here"

# Add the playlist IDs you want to back up to this array
# Make sure the playlists are public or unlisted, as private playlists will not be accessible
# Include only the playlist ID, not the full URL
$playlistIds = @("playlistID-here-1", "playlistID-here-2", "playlistID-here-3")


# Modify the destination path to the folder you want to save the CSV file and don't include the filename
$destination = "/path/to/destination/"

###############################  ENTER YOUR DETAILS HERE  ###############################

# Max per request (YouTube limit)
$maxResults = 50  

# Initialize a generic counter to use in case of empty or invalid playlist titles
$genericCounter = 1

foreach($playlistId in $playlistIds) {
    $url = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=$maxResults&playlistId=$playlistId&key=$apiKey"

    # Make the API call, store the result in $response
    try {
        $response = Invoke-RestMethod -Uri $url -Method Get
    } catch {
        Write-Host "Failed to make API call: $_"
        exit
    }

    # Store JSON response to parse later
    $videoList = $response.items

    # Initialize the nextPageToken
    $nextPageToken = $response.nextPageToken

    do {
        # If there is a nextPageToken in the API call, get the next page of results
        if($response.nextPageToken) {

            # Append the nextPageToken to the URL
            $url += "&pageToken=$nextPageToken"

            # Make a new API call to get the next 50 video results in the playlist if a playlist has more than 50 videos
            $response = Invoke-RestMethod -Uri $url -Method Get

            # Store the new video information in the $videoList
            $videoList += $response.items

            # If the current API call has a nextPageToken, set it to the $nextPageToken variable and keep the loop going
            $nextPageToken = $response.nextPageToken
        }

    } while($nextPageToken) # Once $response.nextPageToken is null, the loop will stop

    # Initialize an empty array to store the formatted video information
    $formattedVideoList = @()

    foreach($video in $videoList) {

        $formattedVideo = [PSCustomObject]@{
            Title       = $video.snippet.title
            Uploader    = $video.snippet.videoOwnerChannelTitle
            Description = $video.snippet.description
            URL         = "https://youtube.com/watch?v=$($video.snippet.resourceId.videoId)"
        }
        $formattedVideoList += $formattedVideo
    }

    # Make an API call to get the playlist details
    $playlistDetailsUrl = "https://www.googleapis.com/youtube/v3/playlists?part=snippet&id=$playlistId&key=$apiKey"
    try {
        $playlistDetailsResponse = Invoke-RestMethod -Uri $playlistDetailsUrl -Method Get
    } catch {
        Write-Host "Failed to get playlist details: $_"
        exit
    }

    # Get the playlist title from the playlist details
    $playlistTitle = $playlistDetailsResponse.items[0].snippet.title

    # Get the current date and time
    $currentDateTime = Get-Date -Format "yyyy-MM-dd-HH-mm"

    # Sanitize the playlist title by removing invalid characters
    $sanitizedTitle = $playlistTitle -replace '[<>:"/\\|?*\[\]]', ''

    # If the sanitized title is empty or invalid, use a generic name
    if ([string]::IsNullOrWhiteSpace($sanitizedTitle)) {
        $sanitizedTitle = "playlist$genericCounter"
        $genericCounter++
    }

    # Set the filename with the playlist title and current date and time
    $filename = "$sanitizedTitle-$currentDateTime.csv"

    $outputPath = $destination + $filename

    # Export the formatted video list to a CSV file 
    $formattedVideoList | Export-Csv -Path $outputPath -NoTypeInformation -Encoding UTF8BOM

    # Check for how many deleted or private videos are in the playlist and warns user
    $inaccessibleVideoCounter = 0
    foreach($video in $formattedVideoList) {
        if ($video.title -eq "Deleted video" -or $video.title -eq "Private video") {
            $inaccessibleVideoCounter++
        }
    }

    # Display a message to the user if there are inaccessible videos in the playlist
    if($inaccessibleVideoCounter -eq 1) {
        Write-Host "There is $inaccessibleVideoCounter deleted or private video in the playlist $playlistTitle." -ForegroundColor Yellow
    } elseif($inaccessibleVideoCounter -gt 1) {
        Write-Host "There are $inaccessibleVideoCounter deleted or private videos in the playlist $playlistTitle." -ForegroundColor Yellow
    }
    Write-Host "The operation was successfully completed. The playlist details for $playlistTitle were saved to $destination." -ForegroundColor Green
}

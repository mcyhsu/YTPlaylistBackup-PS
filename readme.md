# YouTube Playlist Backup Script - PowerShell

## The Problem

If you've ever maintained a large music playlist on YouTube, you've probably encountered this horrific sight:

![](https://github.com/mcyhsu/YTPlaylistBackup-PS/blob/main/Assets/the-problem.jpg?raw=true)

While this script cannot prevent videos from getting deleted, it can at least make the process of replacing the deleted videos a lot easier.

## What Does This Script Do?

The YouTube Playlist Backup script **saves the Title, Uploader, Description, and URL information of each video in a YouTube playlist into a CSV file** for archival purposes.

Here's a preview of what a CSV generated by this script looks like:

![](https://github.com/mcyhsu/YTPlaylistBackup-PS/blob/main/Assets/inside-csv.png?raw=true)

This is useful for maintaining a music playlist when videos get deleted or set to private and you don't know which ones. 

Preserve the playlist data just as it was before the videos got removed - you can check the CSV file and replace the inaccessible videos. Then run the script again to generate a fresh CSV of your cleaned up playlist.

## How to Use This Script
Download and open the script in your preferred environment (E.g. VS Code).

To get started, you need to know three things:
1. **Your YouTube API key**
2. **Your playlist IDs**
3. **The destination folder path**

If you already know them, simply replace the placeholder values at the top of the script and then run it to save the playlist data as CSVs to the destination folder.

![](https://github.com/mcyhsu/YTPlaylistBackup-PS/blob/main/Assets/change-these-values.jpg?raw=true)

Otherwise, I'll explain where you can find each of these things next.

## 1. YouTube API Key
Follow the instructions laid out [here](https://developers.google.com/youtube/v3/getting-started) to get access to a YouTube API key.

The API key should look like a long string of random characters, something like this:
```
BIzaTyC-GRb9yGzWzhitjvWXj9Z-RqbdyDKbS6A
```
Replace the **$apiKey** placeholder value with your actual APIkey.
```
$apiKey = "BIzaTyC-GRb9yGzWzhitjvWXj9Z-RqbdyDKbS6A"
```

## 2. YouTube Playlist IDs
Next you need to find your playlist IDs. This is **NOT** the same as the URL.

 :x:**Incorrect:**
```
https://www.youtube.com/playlist?list=PLtDp75hOzOlbD7m-Gb2t4dZqyYx7dq0iB
```
From the URL, omit the "https://www.youtube.com/playlist?list=" part.

:white_check_mark:**Correct:**
```
PLtDp75hOzOlbD7m-Gb2t4dZqyYx7dq0iB
```
Change the placeholder values in **$playlistIds**. Enter at least one playlist ID, separate with a comma if you have multiple IDs, like so:
```
$playlistIds = @("PLtDp75hOzOlbD7m-Gb2t4dZqyYx7dq0iB","PL5075BB69F757047E")
```

## 3. Destination Folder Path
Lastly, enter the destination folder path into the **$destination** variable, like so:
```
$destination = "c:/path/to/destination/"
```
This is where the script will save your CSV files. It will create one CSV per playlist.

So if you entered 3 playlist IDs, expect to see 3 CSVs saved into that folder when you run the script.

![](https://github.com/mcyhsu/YTPlaylistBackup-PS/blob/main/Assets/csv-files.jpg?raw=true)

And that's it!
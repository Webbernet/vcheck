# Webbernet Version Checker

## Why
We use this in our CI to detect if a version of the code is live.

The script checks to see if the application has a certain version. Easiest way to achieve this is to create a public page on your application with the current git sha. Use this system to check that git sha and ensure 

## How to run
Run this using docker

```
docker run \ 
-e VERSION_TEXT=05416212a6ea184bd6fd0a3e4f6345e344f3e547 \
-e URL=https://ourapplication.com.au/version.txt \
webbernet/version-checker
```

## Environment parameters

URL - This is the URL that we will host the version information (required)
VERSION_TEXT - This is the version we will be searching for in the URL (required)
FAILURE_THRESHOLD_COUNT - How many times should we check for that URL? Some deployments can take a long time to rollout to all servers. Default is 50.
WAIT_SECONDS - How long should we wait in between checks? Default is 30 seconds
SUCCESS_THRESHOLD - How many time will finding the correct version (in a row) count as an overall success? Should you have lots of servers and you want to ensure rollout to all of them, you can increase this. Default 5

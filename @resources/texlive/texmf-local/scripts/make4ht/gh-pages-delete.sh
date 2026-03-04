#!/bin/bash

# Delete remote gh-pages if it exists
if git ls-remote --exit-code --heads origin gh-pages > /dev/null 2>&1; then
    git push origin --delete gh-pages
fi

# Delete local gh-pages if it exists
if git show-ref --verify --quiet refs/heads/gh-pages; then
    git branch -D gh-pages
    # It lingers and can be restored by git checkout unless you clear cache:
    git reflog expire --expire=now --all
    git gc --prune=now 
    sleep 2 # give it a couple of secs to process
fi


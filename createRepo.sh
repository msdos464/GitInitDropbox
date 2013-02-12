#!/bin/bash

# The path to the Dropbox repository folder
dropbox="C:/Users/WreckeD/Dropbox/git_repo"

# escape / characters to \/
dropboxConv=$(echo "$dropbox" | sed -r "s/\//\\\\\//g")

# http://stackoverflow.com/a/5195741
function test {
    "$@"
    status=$?
    if [ $status -ne 0 ]; then
        echo "error with $1"
		exit $status
    fi
    return $status
}

# This could be used to clean up the folder
#rm -rf .git

if [ -d ".git" ]; then
    echo "Git already initialized, aborting!"
	exit 1
fi

db=$(pwd | sed -r "s/^.+\/([^\/]+)$/$dropboxConv\/\1/")

if [ -d $db ]; then
	echo "Dropbox repo exists already, aborting!"
	exit 1
else
    echo "Created to Dropbox"
	test mkdir "$db"
fi

# initialize
test git init

# greate .gitignore
echo "*"            >  .gitignore
echo "!*/"         >> .gitignore
echo "!.gitignore" >> .gitignore
#echo "!.m"        >> .gitignore

test git add .
test git commit -am "Initial commit with gitignore"

this=$(pwd)

test cd "$db"
test git init --bare
test cd "$this"

test git remote add origin "$db"
test git push -u origin master

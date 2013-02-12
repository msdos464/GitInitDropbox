#!/bin/bash
# This creates a Git repository, creates useful .gitignore, creates a folder to the Dropbox,
# initializes bare repository there, adds it to remotes and does the first push.

# The path to the Dropbox repository folder
dropbox="C:/Users/WreckeD/Dropbox/git_repo"

# Escape / characters to \/
dropboxConv=$(echo "$dropbox" | sed -r "s/\//\\\\\//g")

# http://stackoverflow.com/a/5195741
# This function checks the exit code of each command, and aborts the execution in case of an error
function test {
    "$@"
    status=$?
    if [ $status -ne 0 ]; then
        echo "error with $1"
		exit $status
    fi
    return $status
}

if [ -d ".git" ]; then
    echo "== Git already initialized, continuing"
	#echo "== Git already initialized, aborting!"
	#exit 1
fi

# Path to the Dropbox's subfolder
db=$(pwd | sed -r "s/^.+\/([^\/]+)$/$dropboxConv\/\1/")

if [ -d $db ]; then
	echo "== Dropbox repo exists already, aborting!"
	exit 1
else
	echo "== Created to Dropbox"
	test mkdir "$db"
fi

# Initialize, this is safe even if the local repository already exists
test git init

# If .gitignore already exists, do not overwrite it!
if [ -f ".gitignore" ]; then
	echo "== gitignore exists, skipping..."
else
	echo "== Generating gitignore"
	
	# Create .gitignore
	echo "*"            >  .gitignore
	echo "!*/"         >> .gitignore
	echo "!.gitignore" >> .gitignore
	
	# This would be useful for PHP projects:
	#echo "!.php"      >> .gitignore
	
	test git add .gitignore
	test git commit -m "Initial commit with gitignore"
fi

# Move to Dropbox folder, initialize bare repository and move back to the original path
this=$(pwd)
test cd "$db"
test git init --bare
test cd "$this"

# If the "origin" remote does not exist yet, add it
remotes=$(git remote -v | grep -E "^origin[^a-z]")
if [ -z "$remotes" ]; then
	echo "== Adding Dropbox origin"
	test git remote add origin "$db"
else
	echo "== Origin exists, skipping..."
fi

# Initial push to origin, add tracking to this branch
test git push -u origin master

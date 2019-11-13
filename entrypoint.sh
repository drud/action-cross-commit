#!/bin/sh -l

# Ensure all variables are present
SOURCE="$1"
REPO="$2"
TARGET="$3"
BRANCH="$4"
TOKEN="$5"


#Create Temporary Directory
CURRENT=$(pwd)
TEMP=$(mktemp -d)
#SETUP TOKEN AUTH, think this is a temp NETRC Call, the token is basic-password, any value will work for basic-user
git clone $REPO $TEMP
cd $TEMP
git checkout $BRANCH
cp -R $CURRENT/$SOURCE $TEMP/$TARGET
git add .
git commit -m "Automatic CI SYNC Commit"
git push origin $BRANCH



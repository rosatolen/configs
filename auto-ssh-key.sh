#!/bin/bash

if [ -z "$1" ]; then
	echo "Usage: $0 <email>"
	echo "Please pass in the email you wish to associate this ssh key with"
	exit
fi

ssh-keygen -t rsa -b 4096 -C "$1"
eval "$(ssh-agent)"
ssh-add ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub

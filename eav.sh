#!/bin/bash

#grab the access key from here : https://mailboxlayer.com/product
ACCESS_KEY={YOUR_ACCESS_KEY}

# Functions ==============================================

# return 1 if global command line program installed, else 0
# example
# echo "node: $(program_is_installed node)"
function program_is_installed {
  # set to 1 initially
  local return_=1
  # set to 0 if not found
  type $1 >/dev/null 2>&1 || { local return_=0; }
  # return value
  echo "$return_"
}

# display a message in red with a cross by it
# example
# echo echo_fail "No"
function echo_fail {
  # echo first argument in red
  printf "\e[31m✘ ${1}"

  printf "\e[31m✘ Make sure the curl and jq libraries are installed on your system"

  # reset colours back to normal
  printf "\033\e[0m"

}

# display a message in green with a tick by it
# example
# echo echo_fail "Yes"
function echo_pass {
  # echo first argument in green
  printf "\e[32m✔ ${1}"
  # reset colours back to normal
  printf "\033\e[0m"
}

# echo pass or fail
# example
# echo echo_if 1 "Passed"
# echo echo_if 0 "Failed"
function echo_if {
  if [ $1 == 1 ]; then
    echo_pass $2
  else
    echo_fail $2
  fi
}

# Functions ==============================================



#check if jq installed
echo "==================================================="
echo "checking jq   if   already installed    $(echo_if $(program_is_installed jq))"
echo "checking curl if   already installed    $(echo_if $(program_is_installed curl))"
echo "==================================================="



#the email address empty or not
if [[ "$1" != "" ]]; then
    EMAIL_ADDRESS="$1"
else
    EMAIL_ADDRESS=""
fi

echo "Checking the validity of the email address.......Please hold a moment!"


# dont' add -i so you dont' get headrs in the response
#api call 
#email,.score,.mx_found,.smtp_check
response=$(curl  --silent -H 'Accept: application/json' -H 'Content-Type: application/json' -X GET "http://apilayer.net/api/check?access_key=$ACCESS_KEY&email=$EMAIL_ADDRESS&smtp=1&format=1" | jq  '.email,.score,.mx_found,.smtp_check,.format_valid')


echo 'Results:\n'

#converting to array
responseArr=($(echo "$response" | tr '' '\n'))

#extract the values (converted to array)
email="${responseArr[0]}"
score="${responseArr[1]}"
mx_found="${responseArr[2]}"
smtp_check="${responseArr[3]}"
format_valid="${responseArr[4]}"

#========================================================================
#valid format?
if [[ "$format_valid" == true ]]
    then
        printf "\e[32m✔ Email address format is valid.\n"
		printf "\033\e[0m"
        break
    else
        printf "\e[31m✘ Email address format is NOT valid.\n"
        printf "\033\e[0m"
fi


#configured to receive email via mx_found flag 
if [[ "$mx_found" == true ]]
    then
         printf "\e[32m✔ (MX Records Check) : Email's domain is ready to receive emails .\n"
         printf "\033\e[0m"
        break
    else
    	 printf "\e[31m✘ (MX Records Check) : Email's domain is NOT ready to receive emails.\n"
    	 printf "\033\e[0m"
fi


#email address provided actually exists
if [[ "$smtp_check" == true ]]
    then
        printf "\e[32m✔ (SMTP Check) : Email address exists .\n"
        printf "\033\e[0m"
        break
    else
    	printf "\e[31m✘ (SMTP Check) : Email address does NOT exists.\n"
        printf "\033\e[0m"
fi

#what's  score
printf "\e[32m✔ The quality and deliverability : < ${score} out of 1 >"
printf "\033\e[0m"






#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~ Kano's Salon ~~~~\n"

MAIN_MENU () {
  
  if [[ -z $1 ]]
  then
    echo -e "Welcome to Kano's Salon, how can I help you?\n"
  else
    echo -e "$1, how can i help you?\n"
  fi

  OPTIONS=$($PSQL "select service_id, name from services") 
  echo "These are our services:"
  echo "$OPTIONS" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED

  if [[ $SERVICE_ID_SELECTED =~ ^[0-5]$ ]]
  then
    echo "What's your phone number?"
    read CUSTOMER_PHONE
    
    CUSTOMER_NAME=$($PSQL "select name from customers where phone = '$CUSTOMER_PHONE'")
    # if phone number not found
    if [[ -z $CUSTOMER_NAME ]]
    then
      # ask customer name
      echo "I don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      # insert new customer with name and phone
      INSERT_CUSTOMER=$($PSQL "insert into customers(name, phone) values('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi

    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")

    echo "What time would you like your color, $CUSTOMER_NAME?"
    
    read SERVICE_TIME

    if [[ $SERVICE_TIME =~ ^[0-9]+$ ]]
    then
      # insert into appointments
      INSERT_NEW_APPOINTMENT=$($PSQL "insert into appointments (customer_id, service_id, time) values ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

      SERVICE_NAME=$($PSQL "SELECT name FROM SERVICES WHERE service_id = $SERVICE_ID_SELECTED")

      FORMATTED_SERVICE=$(echo $SERVICE_NAME)

      echo "I have put you down for a $FORMATTED_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
    else
      echo "That is not a valid time, enter a time in the following format: HH:MM - 10:30"
    fi
    
  else
    MAIN_MENU "That's not a service"
  fi


}

MAIN_MENU



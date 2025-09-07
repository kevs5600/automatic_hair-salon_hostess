#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
# test purposes
# echo "$($PSQL "SELECT * FROM services")"
echo -e "\n~~~~~ Dabi Salon ~~~~~\n"
echo -e "Welcome, this are some of the services that we offer\n"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi
  LIST_SERVICES=$($PSQL "SELECT service_id, name, price FROM services ORDER BY service_id")
  echo "$LIST_SERVICES" | while read SERVICE_ID BAR SERVICE BAR PRICE
  do
    SERVICE_EDIT=$(echo $SERVICE | sed -E 's/_/ /g')
    echo "$SERVICE_ID) $SERVICE_EDIT - \$$PRICE"
  done
  echo -e "\nSelect the number of the service you would like to be done?"
  read SERVICE_ID_SELECTED
  # if input is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "That is not a valid service number."
  else
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    SERVICE_FORMATED=$(echo $SERVICE_NAME | sed -E 's/_/ /g')
    # service doesn't exist
    if [[ -z $SERVICE_FORMATED ]]
    then
      MAIN_MENU "That service does not exist please try again"
    else
      # service does exist
      echo -e "\nYour going to look fantastic with your new $SERVICE_FORMATED, tell me what's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      # if there is no customer with that phone
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo -e "\nWhat is your name?"
        read CUSTOMER_NAME
        # insert new customer
        INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      echo -e "\nHello $CUSTOMER_NAME, What time would you like your appointment?"
      # check previous appointments
      NO_TIME=$($PSQL "SELECT time FROM appointments")
      # if no appointments made
      if [[ -z $NO_TIME ]]
      then
        echo We have all day available
      # with appoinments
      else
        echo This are unavailable hours
        # echo $NO_TIME | while read 
      fi
      read SERVICE_TIME
      # insert in appointments
      APPOINTMENT_SET=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")
      echo -e "\nI have put you down for a $SERVICE_FORMATED at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}

MAIN_MENU
#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ My Salon ~~~~~\n"

SERVICE_MENU () {

  if [[ $1 ]] 
  then
  echo $1
  fi
  echo -e "Welcome to My Salon, here are the available services"
  echo -e "How can I help you?\n"
  # get service list 
  SERVICE_INFO=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICE_INFO" | sed "s/ |/)/"
  # get service name. 
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id =$SERVICE_ID_SELECTED")

  # if not found
  if [[ -z $SERVICE_NAME ]]
  then 
    SERVICE_MENU "I could not find that service. What would you like today?"
  else 
    CUSTOMER_INFO_MENU

  fi


  # send to main menu
}

CUSTOMER_INFO_MENU () {
  # get phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  # check customer name
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # if not found
  if [[ -z $CUSTOMER_NAME ]]
  then
    # get customer name
    echo -e "\nI don't have a record for that phone number. what's your name?"
    read CUSTOMER_NAME

    # enter into database
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
  fi
  # move for appointment
  APPOINTMENT_MENU
  
}

APPOINTMENT_MENU () {
# get customer id
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

# get service time
echo -e "\nWhat time would like your $(echo $SERVICE_NAME| sed 's/^ *//'), $CUSTOMER_NAME?"
read SERVICE_TIME
# enter into appointments
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
# greet 
echo -e "\nI have put you down for a $(echo $SERVICE_NAME| sed 's/^ *//') at $SERVICE_TIME, $CUSTOMER_NAME."

}


SERVICE_MENU

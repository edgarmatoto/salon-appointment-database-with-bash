#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon Appoinment Scheduler ~~~~~\n"

SERVICES_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "Hello, what services do you want?"
  
  # display all services menu
  ALL_SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")
  echo "$ALL_SERVICES" | while read ID BAR NAME
  do
    echo "$ID) $NAME"
  done

  # input for services to order
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  # If menu Not Exist
  if [[ -z $SERVICE_NAME ]]
  then
    # Send to menu
    SERVICES_MENU "Service you pick doesn't exist."
  else
    # ask for phone number
    echo -e "\nType your phone number: "
    read CUSTOMER_PHONE

    # get customer info
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # if customer doesn't exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      # get new customer name
      echo -e "\nEnter your name:"
      read CUSTOMER_NAME

      # insert new customer
      INSERT_CUSTOMER=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

    fi
    echo -e "\nWhat time do you want?"
    read SERVICE_TIME

    # get new customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # insert new appointment
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id, time, service_id) VALUES ($CUSTOMER_ID, '$SERVICE_TIME', $SERVICE_ID_SELECTED)")

    # output final message
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi

}

SERVICES_MENU

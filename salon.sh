#!/bin/bash

PSQL="psql -A -U freecodecamp -d salon -t -c"

echo -e "\n~~~ Salon ~~~\n"

MAIN_MENU () {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\nChoose your Service:"

  AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services")
  echo "$(echo "$AVAILABLE_SERVICES" | sed 's/|/) /g')"
  read SERVICE_ID_SELECTED

  if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

    if [[ -z $SERVICE_NAME_SELECTED ]]
    then
      MAIN_MENU "Service not available. Please choose a valid service number!"
    else
      CREATE_APPOINTMENT $SERVICE_ID_SELECTED $SERVICE_NAME_SELECTED
    fi
  else
    MAIN_MENU "Service can only be numeric. Please choose a valid service number!"
  fi
}

CREATE_APPOINTMENT () {
  echo -e "\nYou choosed \"$2\" please enter the following data below:"

  echo -e "Your phone numer:"
  read CUSTOMER_PHONE

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_ID ]]
  then
    echo -e "\nYour name:"
    read CUSTOMER_NAME

    ADD_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  fi

  echo -e "\nYour desired service time:"
  read SERVICE_TIME

  ADD_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($1, $CUSTOMER_ID, '$SERVICE_TIME')")

  echo -e "I have put you down for a $2 at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU

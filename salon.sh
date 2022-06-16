#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\nWelcome to My Salon. How can I help you?\n"


MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICE=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  if [[ -z $SERVICE ]]
  then
    echo "Sorry, we currently don't have any service"
  else
    echo "$SERVICE" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done

    read SERVICE_ID_SELECTED
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      MAIN_MENU "Please choose a correct service id."
    else
      SERVICE_AVAILABLE=$($PSQL "SELECT service_id FROM services WHERE service_id = "$SERVICE_ID_SELECTED"")
      if [[ -z $SERVICE_AVAILABLE ]]
      then 
        MAIN_MENU "That service is unavailable right now"
      else
        echo "What's your phone number?"
        read CUSTOMER_PHONE
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
        if [[ -z $CUSTOMER_NAME ]]
        then
          echo "Sorry, we don't have record for that phone number. What's your name"
          read CUSTOMER_NAME
          INSERT_INTO_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
        fi
        NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
        echo "What time would you like for your $NAME, $CUSTOMER_NAME?"
        read SERVICE_TIME
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
        if [[ $SERVICE_TIME ]]
        then
          INSERT_INTO_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
          if [[ $INSERT_INTO_APPOINTMENT ]]
          then
            echo "I have put you down for a $NAME at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
          fi
        fi
      fi
    fi
  fi
}
MAIN_MENU

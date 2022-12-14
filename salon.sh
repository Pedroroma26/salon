#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~ Hello in Salon Appointment Scheduler ~~\n"

MAIN_MENU () {
  CUSTOMER_CHOISE
  CUSTOMER_INFO
  SELECT_TIME
}

CUSTOMER_CHOISE () {
  # give services info
  SERVICE_INFO=$($PSQL "SELECT service_id, name FROM services") 
  echo -e "\nHere are the services we have available:"
  echo "$SERVICE_INFO" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  echo -e "\nPick number of service what do you want?"
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED == [1-5] ]]
  then
    echo "That is not a valid service number."
    CUSTOMER_CHOISE
  else
    SERVICE_NAME_TO_SELECT=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED") 
  fi
}

CUSTOMER_INFO () {
  echo -e "\nWhat's your phone number?"
  # give services info
  read CUSTOMER_PHONE x
  # check if enter empty phone 
  if [[ -z $CUSTOMER_PHONE ]] 
  then
  # return question if phone empty
    echo "Please input valid number" 
    CUSTOMER_INFO 
  else
    # checks phone in data base
    CHECKED_PHONE=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE'")
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE' AND name IS NULL")
    # if phone is not in data base
    if [[ -z $CHECKED_PHONE ]]
    # insert phone and name in data base
    then 
      echo -e "\nWhat's your name?"
      read CUSTOMER_NAME
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo "Name can't be empty"
        CUSTOMER_INFO 
      else
        INSERT_CUSTOMER_INFO=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi
    else 
      if [[ ! -z $CUSTOMER_NAME ]]
      then
        echo -e "\nWhat's your name?"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_NAME=$($PSQL "UPDATE customers SET name='$CUSTOMER_NAME' WHERE phone='$CUSTOMER_PHONE'")
      fi
    fi
  fi
}

SELECT_TIME () {
  echo -e "\nPlease input time what you want to get service (hh:mm)"
  read SERVICE_TIME
  if [[ -z $SERVICE_TIME ]]
  then
    echo "Please input valid time hh:mm"
    SELECT_TIME 
  else
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_NAME ]]
    then
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    else
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($SERVICE_ID_SELECTED, $CUSTOMER_ID, '$SERVICE_TIME')")
      echo -e "\nI have put you down for a $SERVICE_NAME_TO_SELECT at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')".
    fi
  fi
}

MAIN_MENU
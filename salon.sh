#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read service_id bar name
  do
    echo -e "$service_id) $name"
  done

  read SERVICE_ID_SELECTED

  SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED");

  if [[ -z $SERVICE_ID ]]
  then
    # return to main menu to try again
    MAIN_MENU "Please enter a valid option."
  else
    echo -e "\nEnter customer phone number"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'");

    if [[ -z $CUSTOMER_NAME ]]
    then
      # get customer name
      echo -e "\nEnter customer name"
      read CUSTOMER_NAME

      INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi

    CUSTOMER_ID=$($PSQL "SELECT customer_id from customers where phone='$CUSTOMER_PHONE'");

    # prompt for appointment time
    echo -e "\nEnter appointment time"
    read SERVICE_TIME

    # add appointment
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")

    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID")
    FORMATTED_SERVICE_NAME=$(echo $SERVICE_NAME | sed 's/^ *//g')

    echo -e "\nI have put you down for a $FORMATTED_SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU

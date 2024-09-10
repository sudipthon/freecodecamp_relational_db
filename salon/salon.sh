#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

echo -e "\nWelcome to My Salon, how can I help you?\n"

BOOK_SERVICE() {
  # Display message if provided
  if [[ $1 ]]; then
    echo -e "\n$1"
  fi

  # Fetch and display available services
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME; do
    echo -e "$SERVICE_ID) $SERVICE_NAME"
  done

  # Read service selected by user
  read SERVICE_ID_SELECTED

  # Check if input is a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
    BOOK_SERVICE "I could not find that service. What would you like today?"
  else
    # Check if the selected service is available
    SERVICE_AVAILABILITY=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")

    # If service is not available, prompt the user again
    if [[ -z $SERVICE_AVAILABILITY ]]; then
      BOOK_SERVICE "I could not find that service. What would you like today?"
    else
      echo -e "\nWhat's your phone number?"
      # Read customer phone number
      read CUSTOMER_PHONE_INPUT

      # Fetch customer name using phone number
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE_INPUT'")

      # If customer does not exist, ask for the name
      if [[ -z $CUSTOMER_NAME ]]; then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        # Read new customer name
        read CUSTOMER_NAME

        # Insert new customer into the database
        INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE_INPUT')")
      fi

      # Fetch service name using the selected service ID
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

      # Format customer name for display
      CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/ //g')

      # Format customer name for display
      SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/ //g')

      # Ask for appointment time
      echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
      read SERVICE_TIME_INPUT

      # Get customer ID
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE_INPUT'")

      # Insert appointment into the database
      INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME_INPUT', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")

      # Confirm the appointment
      echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME_INPUT, $CUSTOMER_NAME_FORMATTED.\n"
    fi
  fi
}

BOOK_SERVICE

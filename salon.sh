#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

read SERVICE_ID_SELECTED
#check if number
if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
#not number
then
  MAIN_MENU "Not a valid choice. Try again. "
else
  SERVICE=$(echo $($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED"))
  # SERVICE=$(echo $SERVICE)
  #not number among choices
  if [[ -z $SERVICE ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
  #is a choice
    #ask for number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    #if number doesnt exist, ask for name
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_RESULTS=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
    fi  
    #ask for time
    echo -e "\nWhat time would you like your $SERVICE, $(echo $CUSTOMER_NAME | sed 's/^ *//')?"
    read SERVICE_TIME
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    INSERT_TIME_RESULTS=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
    echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed 's/^ *//')."
  fi
fi
}

# until Question ; do : ; done
MAIN_MENU "Welcome to My Salon, how can I help you?\n"
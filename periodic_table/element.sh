#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

MAIN() {

  INPUT=$1
  #set the query condition
  QUERY_CONDITION="symbol='$INPUT' OR name='$INPUT'"
  if [[ $1 =~ ^[0-9]+$ ]]; then
    QUERY_CONDITION="atomic_number=$INPUT"
  fi

  #query
  RESULT=$($PSQL "
SELECT atomic_number,name,symbol,type,atomic_mass,melting_point_celsius,boiling_point_celsius FROM properties LEFT JOIN ELEMENTS USING(atomic_number) LEFT JOIN types USING(type_id) WHERE $QUERY_CONDITION;")

  #check for query result
  if [[ $RESULT ]]; then

    #assign the result value to varibales
    echo "$RESULT" | while IFS='|' read ATOMIC_NUMBER NAME SYMBOL TYPE ATOMIC_MASS MELTING_POINT BOILING_POINT; do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    done

  else
    echo "I could not find that element in the database."
  fi

}

if [[ $1 ]]; then
  MAIN $1
else
  echo  "Please provide an element as an argument."
fi

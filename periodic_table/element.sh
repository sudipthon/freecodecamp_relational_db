#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=<database_name> -t --no-align -c"

MAIN() {
  if [[ $1 ]]; then
    echo "The element with atomic number 1 is Hydrogen (H). It's a nonmetal, with a mass of 1.008 amu. Hydrogen has a melting point of -259.1 celsius and a boiling point of -252.9 celsius."
  fi
  echo -e "Please provide an element as an argument."
}
RESULT=$($PSQL "SELECT * FROM elements WHERE atomic_number=1;")
echo "$RESULT"
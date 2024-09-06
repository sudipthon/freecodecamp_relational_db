#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate a random secret number between 1 and 1000
RANDOM_VALUE=$((RANDOM % 1000 + 1))  # Added +1 to ensure the range is between 1 and 1000

echo -e "\nEnter your username:"
read USERNAME

# Check if the user exists in the database
USER_CHECK_RESULT=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_CHECK_RESULT ]]; then
  # New user
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username, best_game) VALUES('$USERNAME', 2000)")
else
  # Existing user
  echo "$USER_CHECK_RESULT" | while IFS='|' read USERNAME GAMES_PLAYED BEST_GAME; do
    echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

echo -e "\nGuess the secret number between 1 and 1000:"
USER_GUESS=-1
TRIES=0

while [[ $RANDOM_VALUE -ne $USER_GUESS ]]; do
  read USER_GUESS
  ((TRIES++))

  # Check if the input is a number
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]; then
    echo -e "\nThat is not an integer, guess again:"
  
  else
    # Provide hints based on the guess
    if [[ $RANDOM_VALUE -lt $USER_GUESS ]]; then
      echo -e "\nIt's lower than that, guess again:"
    elif [[ $RANDOM_VALUE -gt $USER_GUESS ]]; then
      echo -e "\nIt's higher than that, guess again:"
    else
      # Correct guess
      echo -e "\nYou guessed it in $TRIES tries. The secret number was $RANDOM_VALUE. Nice job!"

      # Get the current best_game value
      BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")

      # Update best_game if the current number of tries is lower
      if [[ $TRIES -lt $BEST_GAME ]]; then
        BEST_GAME=$TRIES
      fi

      # Increment games_played
      ((GAMES_PLAYED++))

      # Update user statistics in the database
      UPDATE_USER=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE username='$USERNAME'")
    fi
  fi
done

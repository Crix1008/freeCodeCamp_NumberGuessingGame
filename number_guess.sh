#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

USERNAME_CHECK=$($PSQL "SELECT games_played, best_game FROM number_guess WHERE username='$USERNAME'")
if [[ -z $USERNAME_CHECK ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO number_guess(username) VALUES('$USERNAME')")
else
  IFS='|' read -r GAMES_PLAYED BEST_GAME <<< $USERNAME_CHECK
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

RANDOM_NUMBER=$((1 + $RANDOM % 1000))
GUESS_COUNTER=1
echo -e "\nGuess the secret number between 1 and 1000:"

read USER_GUESS
while [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
do
  echo "That is not an integer, guess again:"
  read USER_GUESS
done


while [[ $USER_GUESS != $RANDOM_NUMBER ]]
do
  GUESS_COUNTER=$(($GUESS_COUNTER + 1))
  if [[ $USER_GUESS < $RANDOM_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  else
    echo "It's lower than that, guess again:"
  fi

  read USER_GUESS
  while [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  do
    echo "That is not an integer, guess again:"
    read USER_GUESS
  done
done

UPDATE_GAMES_PLAYED=$($PSQL "UPDATE number_guess SET games_played=games_played+1 WHERE username='$USERNAME'")
if [[ ($BEST_GAME > $GUESS_COUNTER) || ( -z $BEST_GAME)]]
then
  UPDATE_BEST_GAME=$($PSQL "UPDATE number_guess SET best_game=$GUESS_COUNTER WHERE username='$USERNAME'")
fi

echo "You guessed it in $GUESS_COUNTER tries. The secret number was $RANDOM_NUMBER. Nice job!"

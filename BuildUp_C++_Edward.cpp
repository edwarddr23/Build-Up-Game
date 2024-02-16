//************************************************************
//* Name:  Edward Del Rosario
//* Project : Build Up C++
//* Class : CMPS-366
//* Date : 2/6/2023
//************************************************************

#include <iostream>
#include "Hand.h"
#include "Round.h"
#include "Tile.h"
#include "Tournament.h"

int main()
{
    srand(time(0));
    Tournament tourn;
    bool anotherRound = true;
    bool restoringRound = false;

    cout << "_________________________________________________________" << endl << endl;
    cout << "Welcome to Build Up!" << endl;
    cout << "_________________________________________________________" << endl << endl;
    // Ask if Human wants to continue previous game. If so, take info from file specified and resume the round.
    restoringRound = tourn.RestoreInquiry();
    
    // InitializeRound increments the tournament's round member's roundNum, so it will technically start at 1 if a previous game isn't loaded. 
    // If a save file is loaded, the round number is calculated and set by InitializeRound().
    tourn.SetRoundNumber(0);
     do {
        tourn.InitializeRound(restoringRound);
        tourn.StartCurrentRound();
        // If the Human decides to stop the game in the middle of a round, then the round's contents will be stored onto a text file.
        tourn.SerializeRound();
        // If the Human doesn't suspend the game, it will not add and print the Players' wins. If the round runs normally, though, it will.
        tourn.AddWin();
        tourn.PrintWins();
        /* Another round will not start if the game has been suspended.If the game isn't suspended, however, the game will ask whether the Human wants to play another round.
         If the Human wants to play another round, this will loop again and a new round will start. If the Human does not want to play another round, the winner of the 
         tournament will be declared. */
    } while (tourn.GetRound().GetIsSuspended() == false && tourn.RoundInquiry());

    // As long as the Human did not suspend the game and did not wish to play another round, declare the winner of the Tournament and terminate.
    tourn.DeclareWinnerOfTournament();
}

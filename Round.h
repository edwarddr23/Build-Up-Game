#pragma once

#include <stdio.h>
#include <vector>
#include <sstream>
#include <fstream>
#include "Tile.h"
#include "Hand.h"
#include "Player.h"
#include "Human.h"
#include "CPU.h"

using namespace std;

class Round {
public:
	// Default construtor for the Round class.
	Round();

	// Constructor that stores round number into Round object.
	Round(int m_roundNum);

	// Assignemnt operator overloader.
	void operator = (const Round& rightRound) {
		human = rightRound.human;
		cpu = rightRound.cpu;
		roundNum = rightRound.roundNum;
		humanScore = rightRound.humanScore;
		cpuScore = rightRound.cpuScore;
		isHumanTurn = rightRound.isHumanTurn;
	}

	/* *********************************************************************
	Function Name: IncrementRoundNum
	Purpose: Increments the Round's roundNum member by 1.
	Parameters: None.
	Return Value: None.
	Algorithm: 1) Increment roundNum member by 1.
	Assistance Received: None.
	********************************************************************* */
	void IncrementRoundNum() { roundNum++; };

	/* *********************************************************************
	Function Name: GetHuman
	Purpose: Accessor for Human member variable.
	Parameters: None.
	Return Value: Returns Round member human.
	Algorithm: N/A
	Assistance Received: None.
	********************************************************************* */
	Human GetHuman() { return human; };

	/* *********************************************************************
	Function Name: GetCPU
	Purpose: Accessor for CPU member variable.
	Parameters: None.
	Return Value: Returns Round member cpu.
	Algorithm: N/A
	Assistance Received: None.
	********************************************************************* */
	CPU GetCPU() { return cpu; };

	/* *********************************************************************
	Function Name: GetRoundNum
	Purpose: Accessor for the Round member roundNum.
	Parameters: None.
	Return Value: Returns the Round member roundNum.
	Algorithm: N/A
	Assistance Received: None.
	********************************************************************* */
	int GetRoundNum() { return roundNum; };

	/* *********************************************************************
	Function Name: GethumanScore
	Purpose: Accessor for the human's score, a Round member variable humanScore.
	Parameters: None.
	Return Value: Returns the human's score, a Round member variable humanScore.
	Algorithm: N/A
	Assistance Received: None.
	********************************************************************* */
	int GetHumanScore() { return humanScore; };

	/* *********************************************************************
	Function Name: GetCPUScore
	Purpose: Accessor for the CPU's score, a Round member variable cpuScore.
	Parameters: None.
	Return Value: Returns the CPU's score, a Round member variable cpuScore.
	Algorithm: N/A
	Assistance Received: None.
	********************************************************************* */
	int GetCPUScore() { return cpuScore; };

	/* *********************************************************************
	Function Name: GetIsSuspended
	Purpose: Accessor for Round member isSuspended to see if the Round is suspended or not.
	Parameters: None.
	Return Value: Returns the Round member isSuspended to see if the Round is suspended or not.
	Algorithm: N/A
	Assistance Received: None.
	********************************************************************* */
	bool GetIsSuspended() { return isSuspended; };

	/* *********************************************************************
	Function Name: GetIsHumanTurn
	Purpose: Accessor for Round member isHumanTurn to see if the current turn in the Round is the Human's or not.
	Parameters: None.
	Return Value: Returns the Round member isHumanTurn to see if the current turn in the Round is the Human's or not.
	Algorithm: N/A
	Assistance Received: None.
	********************************************************************* */
	bool GetIsHumanTurn() { return isHumanTurn; };

	/* *********************************************************************
	Function Name: GetIsRestoredRound
	Purpose: Accessor for the isRestoredRound member variable.
	Parameters: None.
	Return Value: Returns the isRestoredRound member variable.
	Algorithm: N/A
	Assistance Received: None.
	********************************************************************* */
	bool GetIsRestoredRound() { return isRestoredRound; };

	/* *********************************************************************
	Function Name: SetRoundNum
	Purpose: Mutator for Round member roundNum.
	Parameters: (value) m_roundNum, which is the number that Round member roundNum is to be set to.
	Return Value: None.
	Algorithm: N/A
	Assistance Received: None.
	********************************************************************* */
	void SetRoundNum(int m_roundNum) { roundNum = m_roundNum; };

	/* *********************************************************************
	Function Name: SetStartingHandNum
	Purpose: Mutator for the starting hand number that sets the Round member startingHandNum so that new Hands or restored Hands do not run more than 4 times within a Round.
	Parameters: (value) m_startingHandNum, which is the number that Round member startingHandNum is to be set to.
	Return Value: None.
	Algorithm: N/A
	Assistance Received: None.
	********************************************************************* */
	void SetStartingHandNum(int m_startingHandNum) { startingHandNum = m_startingHandNum; };

	/* *********************************************************************
	Function Name: SetHumanScore
	Purpose: Mutator for the human's score that sets the Round member humanScore to the value specified by parameter m_humanScore.
	Parameters: (value) m_humanScore, which is the number that Round member humanScore is to be set to.
	Return Value: None.
	Algorithm: N/A
	Assistance Received: None.
	********************************************************************* */
	void SetHumanScore(int m_humanScore) { humanScore = m_humanScore; };

	/* *********************************************************************
	Function Name: SetCPUScore
	Purpose: Mutator for the CPU's score, a Round member variable cpuScore.
	Parameters: (value) m_cpuScore, the number that Round member cpuScore is to be set to.
	Return Value: None.
	Algorithm: N/A
	Assistance Received: None.
	********************************************************************* */
	void SetCPUScore(int m_cpuScore) { cpuScore = m_cpuScore; };

	/* *********************************************************************
	Function Name: SetIsHumanTurn
	Purpose: Mutator for the isHumanTurn member variable.
	Parameters: (value) m_isHumanTurn, the boolean that Round member isHumanTurn is to be set to.
	Return Value: None.
	Algorithm: N/A
	Assistance Received: None.
	********************************************************************* */
	void SetIsHumanTurn(bool m_isHumanTurn) { isHumanTurn = m_isHumanTurn; };

	/* *********************************************************************
	Function Name: SetIsRestoredRound
	Purpose: Mutator for the isRestoredRound member variable.
	Parameters: (value) m_isRestoredRound, a boolean that Round member isRestoredRound is to be set to.
	Return Value: None.
	Algorithm: N/A
	Assistance Received: None.
	********************************************************************* */
	void SetIsRestoredRound(bool m_isRestoredRound) { isRestoredRound = m_isRestoredRound; };

	/* *********************************************************************
	Function Name: GetRoundData
	Purpose: Accessor for the roundData member variable to retrieve data when loading a game.
	Parameters: None.
	Return Value: Returns the roundData member variable.
	Algorithm: N/A
	Assistance Received: None.
	********************************************************************* */
	string GetRoundData() { return roundData; };

	/* *********************************************************************
	Function Name: InitializeBoneyards()
	Purpose: Meant to be run at the beginning of a new Round, it creates and pushes all of the tiles necessary to make up the Black and White Boneyards and then shuffles the Boneyards.
	Parameters: None.
	Return Value: None.
	Algorithm: 1) From 0 to 6:
					a) From number above to 6:
						1) Create a black tile with left pips equal to previous step 1) and right pips equal to previous step a).
						2) Push this tile into the Black Boneyard.
			   2) Repeat 1) but with white tiles and the White Boneyard.
			   2) Shuffle both Boneyards using ShuffleTiles.
	Assistance Received: None.
	********************************************************************* */
	void InitializeBoneyards();

	/* *********************************************************************
	Function Name: InitializePlayersStacks
	Purpose: Initializes both Player's stacks when the Round starts.
	Parameters: None.
	Return Value: None.
	Algorithm: 1) For the human and cpu members of RoundL
					a) Initialize its stack.
	Assistance Received: None.
	********************************************************************* */
	void InitializePlayersStacks();

	/* *********************************************************************
	Function Name: DetermineFirstPlayer
	Purpose: Determines whether the CPU or the Human will go first when a Hand starts.
	Parameters: None.
	Return Value: None.
	Algorithm: 1) Let the Human and CPU draw a Tile from their respective Boneyards.
					a) If the Human's tile has more pips than the CPU's, then put both Player's Tiles into their respective Hands and pop back each Boneyard. Human goes first, return true (because of Round's isHumanTurn member bool).
					b) If the CPU's tile has more pips than the Human's, then put both Player's Tiles into their respective Hands and pop back each Boneyard. CPU goes first, return false (because of Round's isHumanTurn member bool).
					c) If neither Player's tiles drawn are higher than the others, then leave the Tiles drawn in their Boneyards and reshuffle both Boneyards. Repeat 1).
	Assistance Received: None.
	********************************************************************* */
	bool DetermineFirstPlayer();

	/* *********************************************************************
	/* *********************************************************************
	Function Name: Turns
	Purpose: Handles Tile and Stack placement for both the Human and CPU during Hand plays. Alternates between the Human and CPU.
	Parameters: m_isHuman, boolean that represents whether the starting turn is the Human's or not. If it's true, then let the Human go first. If it's false, let the CPU go first.
	Return Value: None.
	Algorithm: 1) Select the first Player to take a turn.
					a) If parameter m_isHuman is true, let the Human go first.
					b) If parameter m_isHuman is false, let the CPU go first.
			   2) Determine who's turn it is between the two Players.
					a) If parameter m_isHuman is true, let the Human take a turn.
					b) If parameter m_isHuman is false, let the CPU take a turn.
			   5) Run the Player's turn. If the Player in question cannot place any Tiles from Hand onto any stack, skip to 7). If the Player in question can place a Tile in Hand, display their Hand and let them choose their respective Tile to place and Stack to place it on.
					a) If it is the Human's turn, let them select a Tile from hand. Let the helpCPU give a tip for the optimal Tile in Hand and Stack placement if asked for. If the Tile selected can be placed on any stack, then keep that tile in a variable.
					b) Once a Tile is selected by the Human, then let them select a stack to place it on. Let the helpCPU give a tip for the optimal stack to place the Tile selected onto if asked for. If the Tile selected (stored earlier and placed into the SelectStackToPlace function) can be placed on the stack inputted, then keep the stack in a string variable. Go to step 6.
					c) If it is the CPU's turn, let it select the optimal Tile in Hand to place and save the Tile to a local variable.
					d) Once a Tile is selected, pass the variable it was saved on into SelectOptimalTile and let the CPU select the optimal stack to place the optimal Tile it selected onto. Go to step 6.
			   6) Place the Tile selected on to the Stack selected, and remove that Tile from the Player who's turn it is. Ask if the Human wants to keep playing or not using SuspendInquiry and store it into Round's member variable, isSuspended.
			   7) Display each Player's stacks and Hands.
			   8) Set m_isHuman to the opposite value.
			   9) If Round's member variable isSuspended is true, then return.
			   10) Determine whether either Player can place a Tile from Hand onto any stack.
					a) If one of the Players can place a Tile, go back to step 2).
					b) If neither of the Players can place a Tile, return.
	Assistance Received: None.
	********************************************************************* */
	void Turns(bool m_isHuman);

	/* *********************************************************************
	Function Name: StartRound
	Purpose: Initializes Round using InitializeRound (which may initialize a fresh Round or a restored one). Lets Human and CPU play the rest of the Hands left (or all of them) in the Round. Handles scorekeeping when a Hand ends and saves it to member variables humanScore and cpuScore.
	Parameters: None.
	Return Value: None.
	Algorithm: 1) Check the Round's member isRestoredRound.
					a) If it's true, print the Round number its resuming. Then print which Hand number its resuming.
					b) If it's true, print that it is starting Round 1. Then print that it is starting Hand 1.
			   2) Set each Player's Hand's to the current Hand being played. Will be used for serialization.
			   3) Check the Round's member isRestoredRound.
					a) If it;s true, continue to step 4).
					b) If it's false, determine the first Player to take a turn for the Hand being played using DetermineFirstPlayer. Then initialize both Player's Hands for a fresh Hand.
			   4) Let Human and CPU play the current Hand and take turns placing Tiles from their Hands onto stacks using Turns.
			   5) If the Round's isSuspended member is true (mutated by Turns if the Human doesn't want to continue the game), return.
			   6) Store each of the Player's scores into Round members humanScore and cpuScore using StoreScores.
			   7) Print each of the Player's scores for the Human to see.
			   8) If Round's member isRestoredRound is set to true, set it to false. This will prevent the next Hand being played from being treated like a restored one.
			   9) As long as the current Hand being played is not the 4th, then Go to step 1).
					a) If the current Hand is the 4th, return.
	Assistance Received: None.
	********************************************************************* */
	void StartRound();

	/* *********************************************************************
	Function Name: HandleLeftoverTiles
	Purpose: Handles leftover tiles in hands and subtracts the pips from their respective players' score. Clears hands after evaluating. Also removes tiles from hand if any unplayable tiles remain.
	Parameters: None.
	Return Value: None.
	Algorithm: 1) Evaluate the Human's Hand.
					a) If the Hand still has tiles, iterate through each tile and subtract each leftover tile's pips from the Human's score.
			   2) Repeat step 1) but use the CPU's hand and edit the CPU's score.
			   3) Clear both the Human and CPU's Hands.
	Assistance Received: None.
	********************************************************************* */
	void HandleLeftoverTiles();

	/* *********************************************************************
	Function Name: StoreScores
	Purpose: Stores scores into humanScore and cpuScore after evaluating all stacks.
	Parameters: None.
	Return Value: None.
	Algorithm: 1) Evaluate the Human's stacks. Iterate through each tile on each stack.
					a) If the stack in question is topped by a Black Tile, add that Tile's pips to the Human's score.
					b) If the stack in question is topped by a White Tile, add that Tile's pips to the CPU's score.
			   2) Repeat step 1) but with evaluate the CPU's stacks instead.
			   3) Handle the leftover Tiles in each Player's Hands if there are any using HandleLeftoverTiles. That function will subtract from the respective Player's score if a leftover tile is found.
	Assistance Received: None.
	********************************************************************* */
	void StoreScores();

	/* *********************************************************************
	Function Name: PrintScores
	Purpose: Prints each Players' scores.
	Parameters: None.
	Return Value: None.
	Algorithm: 1) Print the Human's score suing Round's member humanScore.
			   2) Print the CPU's score suing Round's member cpuScore.
	Assistance Received: None.
	********************************************************************* */
	void PrintScores();

	/* *********************************************************************
	Function Name: SuspendInquiry
	Purpose: Asks the human if they wish to suspend the game or continue. Returns true if the Human wants to suspend the game and false if the Human wants to continue. Used after a Tile is placed to make sure the Human wants to keep playing or not.
	Parameters: None.
	Return Value: Returns a boolean that's true if the Human wants to suspend the game and false if the Human wants to continue.
	Algorithm: 1) Ask Human if they want to continue or suspend the game.
					a) If the input is "y", then the Human wants to continue. Return false.
					b) If the input is "n", then the Human does not want to continue, return true.
					c) If the input is neither, then repeat step 1).
	Assistance Received: None.
	********************************************************************* */
	bool SuspendInquiry();

	/* *********************************************************************
	Function Name: StoreData
	Purpose: Stores the Round's data from Rounds member variables into Round's member string roundData. used during serialization when the Human doesn't want to continue playing.
	Parameters: (value) m_humanWins, an integer that represents the calling Tournament object's members humanWins and cpuWins. These will be stored into Round's member roundData as well for simplicity's sake.
	Return Value: None.
	Algorithm: 1) Create a stringstream.
			   2) Store the Computer's Stacks, respective Boneyard, Hand, and score into the stringstream created. Use the Round's human and cpu members.
			   3) Repeat step 2) but for the Human with the Human's data.
			   4) Store the current turn into the stringstream found in Round's member isHumanTurn.
			   5) Store the stringstream as a string in Round's member roundData.
	Assistance Received: None.
	********************************************************************* */
	void StoreData(int m_humanWins, int m_cpuWins);

	/* *********************************************************************
	Function Name: ShuffleTiles
	Purpose: Shuffles tiles passed through. Used for each of the Boneyard members of Round.
	Parameters: (reference) m_tiles, which should be either the Black Boneyard or White Boneyard. This function is supposed to shuffle them, so it must be passed by reference so the Boneyards will be modified.
	Return Value: None.
	Algorithm: 1) Create a new vector of Tiles newTiles of the same size as parameter m_tiles. The Tiles in this new vector will be uninitialized and thus will have total pips of -2.
			   2) For every Tile in parameter m_tiles:
					a) Calculate a random number between 0 and the number of tiels in parameter m_tiles. Save this number as the random index to place the current Tile in question.
			   3) Determine whether the new vector of Tiles, newTiles, has an uninitialized Tile at the random index created in the previous step.
					a) If the Tile in newTiles at the random index has -2 total pips, it means that the Tile is still uninitialized. Set that Tile equal to the Tile in parameter m_tiles in question.
					b) If the Tile in newTiles at the random index does not have -2 total pips, it means that the Tile is already initialized and was picked previously. Increment the random index by 1. If the random index becomes greater than the size of parameter m_tiles - 1, then set it to 0 to prevent going out of range and repeat step 3).
	Assistance Received: None.
	********************************************************************* */
	//void ShuffleTiles(vector<Tile> &tiles);

	/* *********************************************************************
	Function Name: RestoreRoundData
	Purpose: Restores round-specific data when calling Tournament object restores a Round from save file. Returns negative if it fails.
	Parameters: None.
	Return Value: Returns true if reading from the save file is successful and false if unsuccessful.
	Algorithm: 1) Open save file. If opening save file fails (meaning it doesn't exist), then print that no save file exists and ask again for a filename.
			   2) Read from the save file string by string using stringstream.
			   3) Read the first string. If it equals "Computer:", then continue. If not, return false.
			   4) If the next string read into stringstream equals "Stacks:", then continue.
			   5) Take in another string into stringstream to get a Tile to add to CPU's stacks.
					a) If the current string read in somehow equals "Boneyard:", or the string read is not a valid Tile, return false.
					b) Repeat step 5) another 5 times to save 6 Tiles for CPU's stacks.
			   6) Take in the next string into stringstream. If it equals "Boneyard:" then continue. If not, then return false.
			   7) Take in the next string and validate whether it's a valid tile or not.
					a) If it is not a valid Tile, return false.
					b) If it is a valid Tile, push back the Tile onto the White Boneyard.
			   8) Repeat step 7) until the current string in question is "Hand:"
			   9) Take in the next string and validate whether it's a valid tile or not.
					a) If it is not a valid Tile, return false.
					b) If it is a valid Tile, push back the Tile onto the CPU's Hand.
			   10) Repeat step 9 until the string in question is "Score:". Take in the next string and determine whether it's a valid score or not.
					a) If any of the characters in the string are a non-digit, then return false.
					b) Otherwise, take in the next string and store it into cpuWins.
			   12) Take in the next string.
					a) If it does not equal "Rounds", return false.
					b) If it does equal "Rounds", take in the next string. If it does not equal "Won:", return false. If it does, continue to step 13).
			   13) Take in the next string and go back to step 4) but initialize the Human's values and the Black Boneyard.
			   14) Once the Human's members have been initialized, take in the next string.
					a) If it does not equal "Turn:", return false.
					b) If it does equal "Turn:", continue.
			   15) Take in the next string and determine whose turn it is.
					a) If the string equals "Computer", then it is the CPU's turn. set the round's isHumanTurn member to false.
					b) If the string equals "Human", then it is the Human's turn. set the round's isHumanTurn member to true.
					c) If the string is neither, then return false.
			   16) Take the Black Boneyard's size and determine which Hand to start on.
					a) If there are 16 tiles, it is the first hand. Set the round's startingHandNum to 1.
					b) If there are 10 tiles, it is the second hand. Set the round's startingHandNum to 2.
					c) If there are 4 tiles, it is the third hand. Set the round's startingHandNum to 3.
					d) If there are 0 tiles, it is the fourth hand. Set the round's startingHandNum to 4.
			   17) Close the file and return true.
	Assistance Received: None.
	********************************************************************* */
	bool RestoreRoundData(string m_saveFileName);

	/* *********************************************************************
	Function Name: ValidateTileRead
	Purpose: Validation of Tile read in from save file to make sure Round restoration in RestoreRoundData from an invalid/tampered save file does not happen.
	Parameters: (value) m_tileRead, a string that represents a string that the stringstream in RestoreRoundData is reading.
	Return Value: Returns true if parameter m_tileRead is valid and false if it is not.
	Algorithm: 1) If the size of parameter m_tileRead is greater than 3, and the format is not (char)(int)(int), then it is invalid. Return false.
			   2) If the format of parameter m_tileRead is (char)(int)(int) but the first char is not a 'B' or 'W', then it is invalid. Return false.
			   3) If the first integer in parameter m_tileRead is somehow less than 0 or greater than 6, it is invalid. Return false.
			   4) If the second integer in parameter m_tileRead is somehow less than 0 or greater than 6, it is invalid. Return false.
			   5) If all of the previous tests in steps 1)-4) were passed, then it must be a valid tile. Return true.
	Assistance Received: None.
	********************************************************************* */
	bool ValidateTileRead(string m_tileRead);

	/* *********************************************************************
	Function Name: PlaceTileOntoPlayerStack
	Purpose: When a Player places a tile onto its own or the opposite Player's stack, then this should place the tile passed in to the stack passeed in.
	Parameters: (value) m_tileSelected, which represents the Tile that the placing Player chose to place.
				(value) m_stackSelected, which represents the stack that the placing Player chose to place their Tile on.
	Return Value: None.
	Algorithm: 1) Place the parameter m_tileSelected on the right stack specified by parameter m_stackSelected.
					a) If parameter m_stackSelected is one of the Human's original stacks, then place parameter m_tileSelected in one of the Human's original stacks at parameter m_stackSelected using PlaceOntoStack.
					B) If parameter m_stackSelected is one of the CPU's original stacks, then place parameter m_tileSelected in one of the CPU's original stacks at parameter m_stackSelected using PlaceOntoStack.
			   2) Remove parameter m_tileSelected from the calling Player's Hand.
					a) If the parameter m_tileSelected is a Black Tile, then the Human was the one placing it. Remove parameter m_tileSelected from the Human's Hand using RemoveFromHand.
					b) If the parameter m_tileSelected is a White Tile, then the CPU was the one placing it. Remove parameter m_tileSelected from the CPU's Hand using RemoveFromHand.
	Assistance Received: None.
	********************************************************************* */
	void PlaceTileOntoPlayerStack(Tile m_tileSelected, string m_stackSelected);

private:
	// Instance of the human.
	Human human;
	// Instance of the CPU.
	CPU cpu; 
	// Tracks the number of rounds.
	int roundNum;
	// Which will be 1 for normal rounds but may be different if it is restored.
	int startingHandNum;
	// Human's score.
	int humanScore;
	// CPU's score.
	int cpuScore;
	// Boolean that tracks whether or not the round has been suspended.
	bool isSuspended = false;
	// True if it is the human's turn. False if it is the CPU's. Used for serialization purposes.
	bool isHumanTurn;
	// Boolean that marks this round as a restored one or not. By default, it is not. Used when restoring a round to make sure that it is run correctly in StartRound().
	bool isRestoredRound = false;
	// String where all the Round's data is stored when Human decides to suspend the game.
	string roundData = "";
};
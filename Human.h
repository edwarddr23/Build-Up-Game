#pragma once
#include <iostream>
#include <vector>
#include <string>
#include "Player.h"
#include "CPU.h"

using namespace std;

class Human : public Player {
public:
	// Constructors and Destructor unnessesary for Human derived class since the Player destructor and constructors are already necessary.

	/* *********************************************************************
	Function Name: PrintBoneyard
	Purpose: Prints the Human's Boneyard, interited from Player.
	Parameters: N/A.
	Return Value: None.
	Algorithm: N/A.
	Assistance Received: None.
	********************************************************************* */
	void PrintBoneyard();

	/* *********************************************************************
	Function Name: SelectTileInHand
	Purpose: Asks Human which tile in hand to play and returns the tile specified.
	Parameters: (value) m_cpuStacks, a 
	of Tiles that should represent the CPU's current original stacks. Used to pass through PrintHelp in case the Human wants a tip.
	Return Value: Returns the Tile specified by the Human.
	Algorithm: 1) Ask user for input.
					a) If the input is non-numeric or is too large an integer, then ask the user for another input.
					b) If the tile selected has no valid stack placements, then ask for another input.
					d) If "pass" is inputted, then return an uninitialized skip Tile so that the calling function knows the turn was skipped.
			   2) Return the Tile the Human selected as a Tile.
	Assistance Received: Input validation inspiration found here: https://stackoverflow.com/questions/16934183/integer-validation-for-input
	********************************************************************* */
	Tile SelectTileInHand(vector<Tile> m_cpuStacks);

	/* *********************************************************************
	Function Name: SelectStackToPlace
	Purpose: Asks the user to select a stack to place a tile onto.
	Parameters: (value) m_tileSelected, the Tile that the Human selected before.
	Return Value: Returns the stack that the Human specified as a string.
	Algorithm: 1) Ask user for input.
					a) If the input is not equal to 2 characters, then ask for another input.
					b) If the first character is not a letter, then ask for another input.
					c) If the second character is less than 1 or greater than 6, then ask for another input
			   2) Return the Tile the Human selected as a Tile.
	Assistance Received: Input validation inspiration found here: https://stackoverflow.com/questions/16934183/integer-validation-for-input
	********************************************************************* */
	string SelectStackToPlace(Tile m_tileSelected, vector<Tile> m_cpuStacks);

	/* *********************************************************************
	Function Name: ValidateStackSelection
	Purpose: Validates whether parameter m_tileSelected can be placed on parameter m_stackSelected.
	Parameters: (value) m_tileSelected, the Tile that the Human selected before.
				(value) m_stackSelected, the Stack that the Human selected before.
				(value) m_cpuStacks, which should represent the CPU's original 6 stacks.
	Return Value: Returns true if parameter m_tileSelected can be placed onto parameter m_stackSelected.
	Algorithm: 1) Iterate through every valid stack placement parameter m_tileSelected has.
					a) If the stack placement in question is equal to the parameter m_stackSelected, then it must be a valid stack placement. Return true.
			   2) If none of parameter m_tileSelected's valid stack placements are equal to the parameter m_stackSelected, then return false.
	Assistance Received: None.
	********************************************************************* */
	bool ValidateStackSelection(Tile m_tileSelected, string m_stackSelected, vector<Tile> m_cpuStacks);

	/* *********************************************************************
	Function Name: CancelSelection
	Purpose: Validates whether the Human wants to keep the selection or select again.
	Parameters: None.
	Return Value: Returns true if the Human wants to cancel and make a different selection. Returns false if the Human wishes to continue with their selection.
	Algorithm: 1) Ask the Human whether or not they wish to keep their selection.
					a) If the input is anything besides "y" or "n", then ask for another input.
			   2) If the Human inputs "n", then run the selection process again. If the Human inputs "y", then do not run the selection process again and continue.
	Assistance Received: None.
	********************************************************************* */
	bool CancelSelection();

	/* *********************************************************************
	Function Name: PrintHelp
	Purpose: Prints the optimal Tile in hand and optimal Stack to place it on when the Human has not selected a Tile to place yet.
	Parameters: (value) m_enemyCpuStacks, a vector of Tiles that represents the CPU's original stacks. Will be used when finding teh optimal tile and optimal stack.
	Return Value: None.
	Algorithm: 1) Create a helpCPU CPU object that has the Human's Hand and Stacks.
			   2) Find the optimal tile in hand to play using OptimalHandTile.
			   3) Find the optimal stack to place this tile on based on the reasoning specified in OptimalHandTile.
			   4) Print the optimal tile and stack as well as why they were chosen.
	Assistance Received: None.
	********************************************************************* */
	void PrintHelp(vector<Tile> m_enemyCpuStacks);

	/* *********************************************************************
	Function Name: PrintHelp
	Purpose: Prints the optimal Tile in hand and optimal Stack to place it on when the Human has selected a Tile already.
	Parameters: (value) m_enemyCpuStacks, a vector of Tiles that represents the CPU's original stacks. Will be used when finding teh optimal tile and optimal stack.
				(value) m_tileSelected, the Tile that the Human selected already, which may or may not be optimal and should be evaluated.
	Return Value: None.
	Algorithm: 1) Create a helpCPU CPU object that has the Human's Hand and Stacks.
			   3) Find the optimal stack to place this tile on based on whether the parameter m_tileSelected can be placed on opposite-topped stacks or not.
					a) If parameter m_tileSelected can be placed on an opposite-topped stack, then set helpCPU's reasoning to 5 (Look at PrintHelpReasoning for details on situation 5).
					b) If parameter m_tileSelected cannot be placed on an opposite-topped stack, then set helpCPU's reasoning to 6 (Look at PrintHelpReasoning for details on situation 6).
			   4) Print the optimal stack and why it was chosen.
	Assistance Received: None.
	********************************************************************* */
	void PrintHelp(vector<Tile> m_enemyCpuStacks, Tile m_tileSelected);

	/* *********************************************************************
	Function Name: DisplayHand
	Purpose: Displays Hand of Player for UI or debugging purposes. Virtual function derived from Player class.
	Parameters: (value) m_isHuman, a boolean to determine whether the
	Return Value: None.
	Algorithm: 1) Determine how many tiles have to be drawn from parameter m_boneyard.
					a) If the parameter m_boneyard has more than 4 tiles in it, then the current hand is not the fourth. Therefore, take 5 tiles (since a tile was already
						taken by DetermineFirstPlayer when a Hand starts).
					b) If the parameter m_boneyard has only 3 tiles in it, then the current hand is the fourth. Therefore, take only 3 tiles (since a tile was already
						taken by DetermineFirstPlayer when a Hand starts).
				2) For as many tiles that needs to be drawn from parameter m_boneyard, push m_boneyard's back Tile onto Hand, and pop m_boneyard's back.
	Assistance Received: None.
	********************************************************************* */
	void DisplayHand();

	/* *********************************************************************
	Function Name: DisplayStacks
	Purpose: Displays Player's stacks for UI. Derived from Player class.
	Parameters: None.
	Return Value: None.
	Algorithm: N/A
	Assistance Received: None.
	********************************************************************* */
	void DisplayStacks();
};
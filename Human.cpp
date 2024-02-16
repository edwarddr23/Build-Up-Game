#include "Human.h"

using namespace std;

/* *********************************************************************
Function Name: PrintBoneyard
Purpose: Prints the Human's Boneyard, interited from Player.
Parameters: N/A.
Return Value: None.
Algorithm: N/A.
Assistance Received: None.
********************************************************************* */
void Human::PrintBoneyard() {
	cout << "Black Tile Boneyard : " << endl;
	for (int i = 0; i < boneyard.size(); i++) {
		cout << boneyard.at(i).ToString() << " ";
	}
	cout << endl;
	cout << "There are " << boneyard.size() << " black tiles" << endl << endl;
}

/* *********************************************************************
Function Name: SelectTileInHand
Purpose: Asks Human which tile in hand to play and returns the tile specified.
Parameters: (value) m_cpuStacks, a vector of Tiles that should represent the CPU's current original stacks. Used to pass through PrintHelp in case the Human wants a tip.
Return Value: Returns the Tile specified by the Human.
Algorithm: 1) Ask Human for input.
				a) If the input is non-numeric or is too large an integer, then ask for another input.
				b) If the tile selected has no valid stack placements, then ask for another input.
				c) If the "help" is inputted, then print the optimal Tile in Hand and the optimal tile to place it on.
				d) If "pass" is inputted, then return an uninitialized skip Tile so that the calling function knows the turn was skipped.
		   2) Return the Tile the Human selected as a Tile.
Assistance Received: Input validation inspiration found here: https://stackoverflow.com/questions/16934183/integer-validation-for-input
********************************************************************* */
Tile Human::SelectTileInHand(vector<Tile> m_cpuStacks) {
	// Input validation inspiration found here: https://stackoverflow.com/questions/16934183/integer-validation-for-input
	string strTileSelection;
	int intTileSelection;
	// Loops infinitely until the Human's input is valid.
	while (true) {
		cout << "What tile in your hand do you want to play? Type \"help\" and press enter for a tip. Type \"pass\" if you wish to skip your turn." << endl;
		cin >> strTileSelection;
		// If the Human asks for help, print the help and ask for a tile selection again.
		if (strTileSelection == "help") {
			PrintHelp(m_cpuStacks);
			continue;
		}
		// If the Human wants to skip, return an uninitialized Tile so that the calling function knows that the turn was skipped.
		if (strTileSelection == "pass" && !CanPlace(m_cpuStacks)) {
			Tile skipTile;
			return skipTile;
		}
		// If the Human wants to skip, but can still place a tile, ask for a Tile selection again.
		else if (strTileSelection == "pass" && CanPlace(m_cpuStacks)){
			cout << "You cannot pass on this turn. You can still play a Tile in Hand." << endl;
			continue;
		}
		// Input should be a number 1-6, so if any characters in the input are not numeric, then take another input.
		bool notNumeric = false;
		for (int i = 0; i < strTileSelection.size(); i++) {
			if (!isdigit(strTileSelection.at(i))) {
				cout << "Invalid input: Non-Integer detected. Please only enter integers between 1 and " << GetHandSize() << "." << endl;
				notNumeric = true;
				break;
			}
		}
		// If a non-numeric character is found in the input, clear the cin buffer before taking another input.
		if (notNumeric) {
			cin.clear();
			cin.ignore(numeric_limits<streamsize>::max(), '\n');
			continue;
		}
		// If the input is numeric, validate the number inputted.
		if (cin.good()) {
			intTileSelection = stoi(strTileSelection);
			if (intTileSelection < 1) {
				cout << "Invalid input: integer too low. Please enter an integer between 1 and " << GetHandSize() << "." << endl;
				continue;
			}
			else if (intTileSelection > GetHandSize()) {
				cout << "Invalid input: integer too large. Please enter an integer between 1 and " << GetHandSize() << "." << endl;
				continue;
			}
			Tile tileSelection = GetTilesInHand().at(intTileSelection - 1);
			// If the tile selected has no valid stack placements, then ask for another input.
			if (tileSelection.ValidStackPlacements(this->stacks, m_cpuStacks).size() == 0) {
				cout << "Invalid tile: this tile cannot be placed on any stack. Please select another." << endl;
				continue;
			}
			// If the number inputted is not too low or too large, then get out of this infinite loop and keep the input.
			break;
		}
	}
	intTileSelection -= 1;
	
	// Return the tile the Human selects from hand.
	return GetTilesInHand().at(intTileSelection);
}

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
string Human::SelectStackToPlace(Tile m_tileSelected, vector<Tile> m_cpuStacks) {
	// Input validation inspiration found here: https://stackoverflow.com/questions/16934183/integer-validation-for-input
	string strStackSelection;

	while (true) {
		cout << "What stack do you want to place tile " << m_tileSelected.ToString() << " on? Type \"help\" and press enter for a tip." << endl;
		cin >> strStackSelection;
		// If the Human asks for help, print the help and ask for a stack selection again.
		if (strStackSelection == "help") {
			PrintHelp(m_cpuStacks, m_tileSelected);
			continue;
		}
		// If the input is larger than 2 characters, then the input is incorrect.
		if (strStackSelection.size() > 2) {
			cout << "Invalid input: Input too large. Please enter a color (B/W) proceeded with an integer (1-6). Example: B5." << endl;
			continue;
		}
		// If the input is smaller than 2 characters, then the input is incorrect.
		else if (strStackSelection.size() < 2) {
			cout << "Invalid input: Input too small. Please enter a color (B/W) proceeded with an integer (1-6). Example: B5." << endl;
			continue;
		}
		// If the first character is a letter, proceed.
		if ( isalpha(strStackSelection.at(0)) ) {
			// If input starts with 'B' or 'W', meaning either Human or CPU stack...
			if (strStackSelection.at(0) == 'B' || strStackSelection.at(0) == 'W') {
				// If the second character in the input is an integer, proceed.
				if ( isdigit(strStackSelection.at(1)) ) {
					// If the number inputted is less than 1, then it is incorrect.
					if ( stoi(strStackSelection.substr(1, 2)) < 1 ) {
						cout << "Invalid input: Integer too low. Please enter a color (B/W) proceeded with an integer (1-6). Example: B5." << endl;
						continue;
					}
					// If the integer inputted is greater than 6, then it is incorrect.
					if ( stoi(strStackSelection.substr(1, 2)) > 6 ) {
						cout << "Invalid input: Integer too high. Please enter a color (B/W) proceeded with an integer (1-6). Example: B5." << endl;
						continue;
					}
					// Otherwise, the input must be correct. Save the stack number in input. Break out of the loop and accept the input.
					return strStackSelection;
					break;

				}
				// Otherwise, input is incorrect and cannot be processed.
				else {
					cout << "Invalid input: Second character not numeric. Please enter a color (B/W) proceeded with an integer (1-6). Example: B5." << endl;
					continue;
				}
			}
			// If the input is some other character, it is invalid. Take another input.
			else {
				cout << "Invalid input: Color invalid. Please enter a color (B/W) proceeded with an integer (1-6). Example: B5." << endl;
				continue;
			}
		}
		// If the first character isn't even a letter, then repeat.
		else {
			cin.clear();
			cin.ignore(numeric_limits<streamsize>::max(), '\n');
			cout << "Invalid input: Please enter a color (B/W) proceeded with an integer (1-6). Example: B5." << endl;
			continue;
		}
	}
	// The stack selection type should already be validated. So something is wrong if this runs.
	cout << "SelectStackToPlace(): Something is wrong." << endl;
	exit(1);
}

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
bool Human::ValidateStackSelection(Tile m_tileSelected, string m_stackSelected, vector<Tile> m_cpuStacks) {
	// The valid stack placements for the tile selected are searched and compared to the stack the human selected for placement. If the stack selected is matched to
	// a valid stack, then return true. If none are found, none exist.
	for (int i = 0; i < m_tileSelected.ValidStackPlacements(this->stacks, m_cpuStacks).size(); i++) {
		if (m_stackSelected == m_tileSelected.ValidStackPlacements(this->stacks, m_cpuStacks).at(i)) {
			return true;
		}
	}
	cout << "You cannot place " << m_tileSelected.ToString() << " on stack " << m_stackSelected << endl;
	return false;
}

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
bool Human::CancelSelection() {
	string response;
	cout << "Are you sure? You will not be able to undo this action. (y/n):" << endl;
	do {
		cin >> response;
		// If it is an invalid response, clear and ignore this input so that a new one can be put in.
		if (response != "y" && response != "n") {
			cin.clear();
			cin.ignore();
			cout << "Invalid input. Please enter a \"y\" or \"n\"" << endl;
		}
	} while (response != "y" && response != "n");

	// They are sure they want to use the tile, so do not cancel the selection.
	if (response == "y") {
		return false;
	}
	// They are not sure they want to use the tile and wish to cancel, so return true.
	else if (response == "n") {
		return true;
	}
	else {
		cout << "CancelSelection(): something is wrong." << endl;
		exit(1);
	}
}

/* *********************************************************************
Function Name: PrintHelp
Purpose: Prints the optimal Tile in hand and optimal Stack to place it on when the Human has not selected a Tile to place yet.
Parameters: (value) m_enemyCpuStacks, a vector of Tiles that represents the CPU's original stacks. Will be used when finding teh optimal tile and optimal stack.
Return Value: None.
Algorithm: 1) Determine if the Human can even place a tile. 
				a) If the Human cannot, let the Human know and return.
				b) If the Human can, continue to give them a recommendation.
		   2) Create a helpCPU CPU object that has the Human's Hand and Stacks.
		   3) Find the optimal tile in hand to play using OptimalHandTile.
		   4) Find the optimal stack to place this tile on based on the reasoning specified in OptimalHandTile.
		   5) Print the optimal tile and stack as well as why they were chosen.
Assistance Received: None.
********************************************************************* */
void Human::PrintHelp(vector<Tile> m_enemyCpuStacks) {
	// If the Human cannot place a tile, tell the Human that no tile can be placed and that they must pass.
	if (!CanPlace(m_enemyCpuStacks)) {
		cout << "You cannot place any tiles in Hand. You must pass your turn." << endl;
		return;
	}

	CPU helpCPU;

	// Set helpCPU's hand to the Human's hand.
	helpCPU.SetHand(this->hand);

	// Set helpCPU's original stacks to the Human's original stacks.
	helpCPU.SetStacks(this->stacks);

	// Choose optimal hand tile, except now the CPU's tiles are the human's tiles and it treats the enemyCPU's stacks as the opposite stack.
	Tile optimalTile = helpCPU.OptimalHandTile(m_enemyCpuStacks, 'W');

	// Choose optimal stack to place this tile on, with these same considerations in mind.
	string optimalStack = helpCPU.OptimalStackPlacement(optimalTile, m_enemyCpuStacks, 'W');

	// Print the suggestion to the Human.
	helpCPU.PrintHelpReasoning(optimalTile, optimalStack, false);
}

/* *********************************************************************
Function Name: PrintHelp
Purpose: Prints the optimal Tile in hand and optimal Stack to place it on when the Human has selected a Tile already.
Parameters: (value) m_enemyCpuStacks, a vector of Tiles that represents the CPU's original stacks. Will be used when finding teh optimal tile and optimal stack.
			(value) m_tileSelected, the Tile that the Human selected already, which may or may not be optimal and should be evaluated.
Return Value: None.
Algorithm: 1) Determine if the Human can even place a tile. 
				a) If the Human cannot, let the Human know and return.
				b) If the Human can, continue to give them a recommendation.
		   2) Create a helpCPU CPU object that has the Human's Hand and Stacks.
		   3) Find the optimal stack to place this tile on based on whether the parameter m_tileSelected can be placed on opposite-topped stacks or not.
				a) If parameter m_tileSelected can be placed on an opposite-topped stack, then set helpCPU's reasoning to 5 (Look at PrintHelpReasoning for details on situation 5).
				b) If parameter m_tileSelected cannot be placed on an opposite-topped stack, then set helpCPU's reasoning to 6 (Look at PrintHelpReasoning for details on situation 6).
		   4) Print the optimal stack and why it was chosen.
Assistance Received: None.
********************************************************************* */
void Human::PrintHelp(vector<Tile> m_enemyCpuStacks, Tile m_tileSelected) {
	// If the Human cannot place a tile, tell the Human that no tile can be placed and that they must pass.
	if (!CanPlace(m_enemyCpuStacks)) {
		cout << "You cannot place any tiles in Hand. You must pass your turn." << endl;
		return;
	}

	CPU helpCPU;

	// Set helpCPU's hand to the Human's hand.
	helpCPU.SetHand(this->hand);

	// Set helpCPU's original stacks to the Human's original stacks.
	helpCPU.SetStacks(this->stacks);

	vector<string> validStacks = m_tileSelected.ValidStackPlacements(this->stacks, m_enemyCpuStacks);
	// 5 Being the situation where a tile has been chosen that may or may not be optimal, but still has valid opposite-colored stack placements.
	if (helpCPU.HasOppositeToppedStacks(validStacks, this->stacks, m_enemyCpuStacks, 'W') == true) {
		helpCPU.SetReasoning(5);
	}
	// 6 being the situation where a tile has been chosen that is definitely not optimal since it has no valid opposite-colored stack placements but valid self-colored placements.
	else {
		helpCPU.SetReasoning(6);
	}

	// Choose optimal stack to place this tile on, with these same considerations in mind.
	string optimalStack = helpCPU.OptimalStackPlacement(m_tileSelected, m_enemyCpuStacks, 'W');

	// Print the suggestion to the Human.
	helpCPU.PrintHelpReasoning(m_tileSelected, optimalStack, true);
}

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
void Human::DisplayHand() {
	cout << "Human's hand:" << endl;

	for (int i = 0; i < this->GetHandSize(); i++) {
		Tile currTile = this->GetTilesInHand().at(i);
		cout << currTile.ToString() << "\t";
	}
	cout << endl;
	for (int i = 0; i < this->GetHandSize(); i++) {
		cout << i + 1 << "\t";
	}
	cout << endl;
}

/* *********************************************************************
Function Name: DisplayStacks
Purpose: Displays Player's stacks for UI. Derived from Player class.
Parameters: None.
Return Value: None.
Algorithm: N/A
Assistance Received: None.
********************************************************************* */
void Human::DisplayStacks() {
	cout << "Human's Stacks:" << endl;
	cout << "\t";
	// SUBMISSION VER:
	for (int i = 0; i < 6; i++) {
		cout << stacks.at(i).ToString() << "\t";
	}
	cout << endl;
	cout << "Stack#:\t";
	// Label stacks as W/B1-6 preceeded with respective color.
	for (int i = 1; i <= 6; i++) {
		cout << "B" << i << "\t";
	}
	cout << endl << endl;
}
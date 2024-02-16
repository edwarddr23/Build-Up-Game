#include <iostream>
#include <ctime>
#include "Round.h"
#include "Human.h"
#include "CPU.h"

using namespace std;

// Default construtor for the Round class.
Round::Round() {
	roundNum = -1;
}

// Constructor that stores round number into Round object.
Round::Round(int m_roundNum) {
	roundNum = m_roundNum;
}

/* *********************************************************************
Function Name: InitializeBoneyards
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
void Round::InitializeBoneyards() {
	// Make sure the boneyards are clear before putting anything in. It shouldn't have anything, but it's just a safeguard.
	human.ClearBoneyard();
	cpu.ClearBoneyard();

	// Initialize Black Boneyard.
	for (int i = 0; i <= 6; i++) {
		for (int j = i; j <= 6; j++) {
			Tile tile('B', i, j);
			human.AddToBoneyard(tile);
		}
	}

	// Initialize White Boneyard.
	for (int i = 0; i <= 6; i++) {
		for (int j = i; j <= 6; j++) {
			Tile tile('W', i, j);
			cpu.AddToBoneyard(tile);
		}
	}

	human.ShuffleBoneyard(); // Shuffle human's tiles.
	cpu.ShuffleBoneyard(); // Shuffle CPU's tiles.
}

/* *********************************************************************
Function Name: InitializePlayersStacks
Purpose: Initializes both Player's stacks when the Round starts.
Parameters: None.
Return Value: None.
Algorithm: 1) For the human and cpu members of RoundL
				a) Initialize its stack.
Assistance Received: None.
********************************************************************* */
void Round::InitializePlayersStacks() {
	human.InitializeStack();
	cpu.InitializeStack();
}

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
bool Round::DetermineFirstPlayer() {
	cout << "Determining first player..." << endl;
	string first;

	while (true) {
		Tile humanDraw = human.GetBoneyard().back();
		cout << "Human drew: " << humanDraw.ToString() << endl;
		Tile CPUDraw = cpu.GetBoneyard().back();
		cout << "CPU drew: " << CPUDraw.ToString() << endl;
		// Boneyards are reshuffled if the player and CPU's drawn tiles have the same number of pips and the process is repeated.
		if (humanDraw.GetTotalPips() == CPUDraw.GetTotalPips()) {
			cout << "Draw! Returning tile and reshuffling..." << endl;
			human.ShuffleBoneyard();
			cpu.ShuffleBoneyard();
			continue;
		}
		else if (humanDraw.GetTotalPips() > CPUDraw.GetTotalPips()) {
			first = "Human";
		}
		else if (humanDraw.GetTotalPips() < CPUDraw.GetTotalPips()) {
			first = "CPU";

		}
		// If the Human or CPU won this interaction, add the drawn tiles to their respective Players and pop their respective Boneyards.
		human.AddToHand(humanDraw);
		human.PopBoneyardBack();
		cpu.AddToHand(CPUDraw);
		cpu.PopBoneyardBack();
		break;
	}

	cout << first << " goes first!" << endl << endl;
	if (first == "Human") {
		return true;
	}
	else if (first == "CPU") {
		return false;
	}
	else {
		cout << "DetermineFirstPlayer(): Something is wrong." << endl;
		exit(1);
	}
}

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
void Round::Turns(bool m_isHuman) {
	do {
		// If the human is the one placing a tile...
		if (m_isHuman == true) {
			cout << "_________________________________________________________" << endl;
			cout << "Human's turn:" << endl;
			cout << "_________________________________________________________" << endl;
			human.DisplayHand();
			// Hand Tile Selection:
			Tile tileSelected;
			// Repeats tile selection if the user is unsure of their selection.
			do {
				// Tile selection loop that repeats if there is an invalid selection.
				tileSelected = human.SelectTileInHand(cpu.GetStacks());
			} while (human.CancelSelection());
			// If the Human chooses to skip a turn, SelectTileInHand returns an uninitialized Tile, and the selection process ends.
			if (tileSelected.GetTotalPips() == -2) {
				cout << "Skipping turn..." << endl;
			}
			else {
				// Stack Placement Selection:
				string stackSelected;
				do {
					// Stack selection repeats if an invalid stack is chosen (i.e. one that the tile selected cannot be placed on).
					do {
						stackSelected = human.SelectStackToPlace(tileSelected, cpu.GetStacks());
					} while (!human.ValidateStackSelection(tileSelected, stackSelected, cpu.GetStacks()));
				} while (human.CancelSelection());
				// Place tile selected onto stack selected.
				cout << "_________________________________________________________" << endl;
				PlaceTileOntoPlayerStack(tileSelected, stackSelected);
			}
		}
		// If the CPU is the one placing a tile...
		else if (m_isHuman == false) {
			cout << "_________________________________________________________" << endl;
			cout << "CPU's turn:" << endl;
			cout << "_________________________________________________________" << endl;
			cpu.DisplayHand();
			// If the CPU can place a tile, find the first tile in hand it can place.
			if (cpu.CanPlace(human.GetStacks())) {
				// Hnad Tile Selection:
				Tile tileSelected = cpu.OptimalHandTile(human.GetStacks(), 'B');
				cpu.PrintReasoning(tileSelected);
				// Stack Placement Selection:
				string stackSelected = cpu.OptimalStackPlacement(tileSelected, human.GetStacks(), 'B');
				// Place tile selected onto stack selected.
				cout << "_________________________________________________________" << endl;
				PlaceTileOntoPlayerStack(tileSelected, stackSelected);
			}
			// If the CPU cannot place a tile, skip the CPU's turn
			else {
				cout << "CPU cannot place a tile. Skipping turn..." << endl;
			}
		}
		cout << "_________________________________________________________" << endl;
		// Display Stacks after a play.
		human.DisplayStacks();
		cpu.DisplayStacks();
		cout << "_________________________________________________________" << endl;
		// Display Hands after a play.
		human.DisplayHand();
		cpu.DisplayHand();
		// Switches to opposite player's turn and say whose turn it is next.
		if (m_isHuman) {
			m_isHuman = false;
			cout << "Next turn, CPU" << endl;
		}
		else if (!m_isHuman) {
			m_isHuman = true;
			cout << "Next turn, Human" << endl;
		}
		// Ask human if they want to continue the game or not and store it into member variable suspended.
		isSuspended = SuspendInquiry();
		// If the Human wants to suspend the game, then stop taking turns and return.
		if (isSuspended) {
			return;
		}
	} while (human.CanPlace(cpu.GetStacks()) || cpu.CanPlace(human.GetStacks()));

	// If both players cannot place anymore tiles, then continue and exit function.
	cout << "Neither player can place another tile from their hands." << endl;
}

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
void Round::StartRound() {
	cout << "_________________________________________________________" << endl << endl;
	// If the round is restored, then display "Resuming Round #".
	if (isRestoredRound) {
		cout << "Resuming ";
	}
	// If the round is just starting, then display "Starting Round #".
	else {
		cout << "Starting ";
	}
	cout << "Round " << roundNum << ":" << endl;
	cout << "_________________________________________________________" << endl << endl;

	// If it is not a restored round, determine the first player and determine the first turn. If it is a restored round, it has been restored from the file already, so keep as is. Also, if the loaded game has the stacks initialized but not the Hands, then the first Player and Hand initialization still has to run.
	if (!isRestoredRound || human.GetBoneyard().size() == 22) {
		// Determine the first player and initialize the Human's and CPU's hands.
		isHumanTurn = DetermineFirstPlayer();
	}

	for (int i = startingHandNum; i <= 4; i++) {
		// If the hand is restored, print "Resuming Hand #". Otherwise, print "Starting Hand #".
		if (isRestoredRound) {
			cout << "Resuming";
		}
		else {
			cout << "Starting";
		}
		cout << " Hand " << i << "!" << endl;
		human.DisplayStacks();
		cpu.DisplayStacks();

		human.SetHandNumber(i);
		cpu.SetHandNumber(i);

		// If it is not a restored round, initialize the hands as if the first player was determined. If it is a restored round, it has been restored from the file already, so keep as is. Also, if the save file loaded has the stacks initialized but not the Hands and a first Player was determined before, then Initialize both Hands.
		if (!isRestoredRound || human.GetBoneyard().size() == 21) {
			//Initialize Human and CPU hands.
			human.InitializeHand();
			cpu.InitializeHand();
		}

		// Play hand.
		Turns(isHumanTurn);

		// If the Human suspended the game, do not resume the hand or round.
		if (isSuspended) {
			return;
		}
		cout << "Hand " << human.GetHandNumber() << " has ended." << endl;

		// Evaluate the stacks to take scores after the hand is done.
		StoreScores();

		// Print the scores after the hand ends.
		PrintScores();

		// If this is a restored round, then since the hand has ended successfully, do not treat this as a restored round and resume as usual.
		isRestoredRound = false;
	}

	cout << endl;
}

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
void Round::HandleLeftoverTiles() {
	// Check if any more tiles are in the Human's hand.
	if (human.GetHandSize() > 0) {
		// Evaluate each leftover tile in the human's hand.
		for (int i = 0; i < human.GetHandSize(); i++) {
			Tile leftoverTile = human.GetTilesInHand().at(i);
			cout << leftoverTile.ToString() << " found leftover in Human's hand. Subtracting " << leftoverTile.GetTotalPips() << " from Human's score..." << endl;
			// Subtract the pips from tile from the Human's score.
			humanScore -= leftoverTile.GetTotalPips();
		}
	}
	// Check if any more tiles are in the CPU's hand.
	if (cpu.GetHandSize() > 0) {
		// Evaluate each leftover tile in the CPU's hand.
		for (int i = 0; i < cpu.GetHandSize(); i++) {
			Tile leftoverTile = cpu.GetTilesInHand().at(i);
			cout << leftoverTile.ToString() << " found leftover in CPU's hand. Subtracting " << leftoverTile.GetTotalPips() << " from CPU's score..." << endl;
			// Subtract the pips from tile from the Human's score.
			cpuScore -= leftoverTile.GetTotalPips();
		}
	}
	// Clear leftover tiles in hand.
	human.ClearHand();
	cpu.ClearHand();
}

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
void Round::StoreScores() {
	// Evaluate each of the Human's stacks (which should always be 6 stacks).
	for (int i = 0; i < 6; i++) {
		// If the top of the stack is from the Human, then add its pips to the Human's score.
		Tile currStack = human.GetStacks().at(i);
		if (currStack.GetColor() == 'B') {
			humanScore += currStack.GetTotalPips();
		}
		// If the top of the stack is from the CPU, then add its pips to the CPU's score.
		else if (currStack.GetColor() == 'W') {
			cpuScore += currStack.GetTotalPips();
		}
	}
	// Evaluate each of the CPU's stacks (which should always be 6 stacks).
	for (int i = 0; i < 6; i++) {
		Tile currStack = cpu.GetStacks().at(i);
		// If the top of the stack is from the Human, then add its pips to the Human's score.
		if (currStack.GetColor() == 'B') {
			humanScore += currStack.GetTotalPips();
		}
		// If the top of the stack is from the CPU, then add its pips to the CPU's score.
		else if (currStack.GetColor() == 'W') {
			cpuScore += currStack.GetTotalPips();
		}
	}

	// If there are leftover tiles, subtract their pips from the holding Player's score.
	HandleLeftoverTiles();
}

/* *********************************************************************
Function Name: PrintScores
Purpose: Prints each Players' scores.
Parameters: None.
Return Value: None.
Algorithm: 1) Print the Human's score suing Round's member humanScore.
		   2) Print the CPU's score suing Round's member cpuScore.
Assistance Received: None.
********************************************************************* */
void Round::PrintScores() {
	cout << "_________________________________________________________" << endl;
	cout << "Human's score: " << humanScore << endl;
	cout << "CPU's score: " << cpuScore << endl;
	cout << "_________________________________________________________" << endl;
}

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
bool Round::SuspendInquiry() {
	string response;
	cout << "Continue (y) or suspend the game (n) ? (y/n):" << endl;
	do {
		cin >> response;
		// If it is an invalid response, clear and ignore this input so that a new one can be put in.
		if (response != "y" && response != "n") {
			cin.clear();
			cin.ignore();
			cout << "Invalid input. please input \"y\" or \"n\"." << endl;
		}
	} while (response != "y" && response != "n");

	// They are sure they want to continue, so don't do anything.
	if (response == "y") {
		return false;
	}
	// They do not want to continue, so serialize.
	else if (response == "n") {
		return true;
	}
	else {
		cout << "SuspendInquiry(): something is wrong." << endl;
		exit(1);
	}
}

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
void Round::StoreData(int m_humanWins, int m_cpuWins) {
	stringstream ss;
	// CPU DATA STORAGE
	ss << "Computer:\n";
	// Store all stacks.
	ss << "\tStacks: ";
	for (int i = 0; i < 6; i++) {
		Tile currStack = cpu.GetStacks().at(i);
		ss << currStack.ToString() << " ";
	}
	ss << "\n";
	// Store white boneyard.
	ss << "\tBoneyard: ";
	vector<Tile> whiteBoneyard = cpu.GetBoneyard();
	for (int i = 0; i < cpu.GetBoneyard().size(); i++) {
		ss << whiteBoneyard.at(i).ToString() << " ";
	}
	ss << "\n";
	// Store CPU's hand.
	ss << "\tHand: ";
	for (int i = 0; i < cpu.GetHandSize(); i++) {
		Tile currTile = cpu.GetTilesInHand().at(i);
		ss << currTile.ToString() << " ";
	}
	ss << "\n";
	// Store CPU's score.
	ss << "\tScore: " << cpuScore << "\n";
	// rounds won
	ss << "\tRounds Won: " << m_cpuWins << "\n\n";

	// HUMAN DATA STORAGE
	ss << "Human:\n";
	// Store all stacks.
	ss << "\tStacks: ";
	for (int i = 0; i < 6; i++) {
		Tile currStack = human.GetStacks().at(i);
		ss << currStack.ToString() << " ";
	}
	ss << "\n";
	// Store black boneyard.
	ss << "\tBoneyard: ";
	vector<Tile> blackBoneyard = human.GetBoneyard();
	for (int i = 0; i < human.GetBoneyard().size(); i++) {
		ss << blackBoneyard.at(i).ToString() << " ";
	}
	ss << "\n";
	// Store Human's hand.
	ss << "\tHand: ";
	for (int i = 0; i < human.GetHandSize(); i++) {
		Tile currTile = human.GetTilesInHand().at(i);
		ss << currTile.ToString() << " ";
	}
	ss << "\n";
	// Store Human's score.
	ss << "\tScore: " << humanScore << "\n";
	// rounds won
	ss << "\tRounds Won: " << m_humanWins << "\n\n";

	// Store current turn.
	string currTurn;
	if (isHumanTurn) {
		currTurn = "Human";
	}
	else {
		currTurn = "Computer";
	}
	ss << "Turn: " << currTurn << "\0";

	// Store what's in the stringstream into roundData
	roundData = ss.str();
	ss.clear();
}

/* *********************************************************************
Function Name: RestoreRoundData
Purpose: Restores round-specific data when calling Tournament object restores a Round from save file. Returns negative if it fails.
Parameters: None.
Return Value: Returns true if reading from the save file is successful and false if unsuccessful.
Algorithm: 1) Open save file. If opening save file fails (meaning it doesn't exist), then print that no save file exists and return false.
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
bool Round::RestoreRoundData(string m_saveFileName) {
	ifstream saveFile;
	saveFile.open(m_saveFileName);

	if (saveFile.is_open()) {
		string currString;
		saveFile >> currString;
		// COMPUTER INITIALIZING:
		if (currString == "Computer:") {
			saveFile >> currString;
		}
		else {
			cout << "RestoreRoundData(): Something is wrong." << endl;
			return false;
		}

		// Stack initialization:
		if (currString == "Stacks:") {
			vector<Tile> restoredStacks;
			for (int i = 0; i < 6; i++) {
				saveFile >> currString;
				// If for some reason, there are less than 6 stacks in the save file, something is wrong.
				if (currString == "Boneyard:") {
					cout << "RestoreRoundData(): There are less than 6 stacks in the save file." << endl;
					return false;
				}
				// If the Tile in question is in an incorrect format, something is wrong in the save file.
				if (!ValidateTileRead(currString)) {
					cout << "RestoreRoundData(): Computer Stack initialization failed. Invalid Tile recorded." << endl;
					return false;
				}
				Tile currTile(currString.at(0), stoi(currString.substr(1, 1)), stoi(currString.substr(2, 2)));
				restoredStacks.push_back(currTile);
			}
			cpu.SetStacks(restoredStacks);
		}
		else {
			cout << "RestoreRoundData(): Something is wrong." << endl;
			return false;
		}

		// White Boneyard initialization:
		saveFile >> currString;
		if (currString == "Boneyard:") {
			saveFile >> currString;
			while (currString != "Hand:") {
				// If the Tile in question is in an incorrect format, something is wrong in the save file.
				if (!ValidateTileRead(currString) || (isalpha(currString.at(0)) && currString.at(0) == 'B')) {
					cout << "RestoreRoundData(): White Boneyard initialization failed. Invalid Tile recorded." << endl;
					return false;
				}
				Tile currTile(currString.at(0), stoi(currString.substr(1, 1)), stoi(currString.substr(2, 2)));
				cpu.AddToBoneyard(currTile);
				saveFile >> currString;
			}
		}
		else {
			cout << "RestoreRoundData(): Something is wrong." << endl;
			return false;
		}

		// Hand initialization:
		saveFile >> currString;
		Hand restoredHand;
		while (currString != "Score:") {
			// If the Tile in question is in an incorrect format, something is wrong in the save file.
			if (!ValidateTileRead(currString) || (isalpha(currString.at(0)) && currString.at(0) == 'B')) {
				cout << "RestoreRoundData(): Computer Hand initialization failed. Invalid Tile recorded." << endl;
				return false;
			}
			Tile currTile(currString.at(0), stoi(currString.substr(1, 1)), stoi(currString.substr(2, 2)));
			restoredHand.AddTile(currTile);
			saveFile >> currString;
		}
		switch (cpu.GetBoneyard().size()) {
		case 22:
			restoredHand.SetHandNum(1);
			break;
		case 16:
			restoredHand.SetHandNum(2);
			break;
		case 10:
			restoredHand.SetHandNum(3);
			break;
		case 4:
			restoredHand.SetHandNum(4);
			break;
		}
		cpu.SetHand(restoredHand);

		// Score initialization:
		saveFile >> currString;
		// If any of the digits in the score are not numeric, then return false.
		for (int i = 0; i < currString.size(); i++) {
			if ( !isdigit( currString.at(i) ) ) {
				cout << "RestoreRoundData(): Invalid score." << endl;
				return false;
			}
		}
		cpuScore = stoi(currString);

		// Leave Rounds Won Initialization to RestoreTournamentData
		saveFile >> currString;
		if (currString == "Rounds") {
			saveFile >> currString;
		}
		else {
			cout << "RestoreRoundData(): Something is wrong." << endl;
			return false;
		}
		if (currString == "Won:") {
			saveFile >> currString;
		}
		else {
			cout << "RestoreRoundData(): Something is wrong." << endl;
			return false;
		}

		// HUMAN INITIALIZING:
		saveFile >> currString;
		if (currString == "Human:") {
			saveFile >> currString;
		}
		else {
			cout << "RestoreRoundData(): Something is wrong." << endl;
			return false;
		}

		// Stack initialization:
		if (currString == "Stacks:") {
			vector<Tile> restoredStacks;
			for (int i = 0; i < 6; i++) {
				saveFile >> currString;
				// If for some reason, there are less than 6 stacks in the save file, something is wrong.
				if (currString == "Boneyard:") {
					cout << "RestoreRoundData(): There are less than 6 stacks in the save file." << endl;
					return false;
				}
				// If the Tile in question is in an incorrect format, something is wrong in the save file.
				if (!ValidateTileRead(currString)) {
					cout << "RestoreRoundData(): Computer Stack initialization failed. Invalid Tile recorded." << endl;
					return false;
				}
				Tile currTile(currString.at(0), stoi(currString.substr(1, 1)), stoi(currString.substr(2, 2)));
				restoredStacks.push_back(currTile);
			}
			human.SetStacks(restoredStacks);
		}
		else {
			cout << "RestoreRoundData(): Something is wrong." << endl;
			return false;
		}

		// Black Boneyard initialization:
		saveFile >> currString;
		if (currString == "Boneyard:") {
			saveFile >> currString;
			while (currString != "Hand:") {
				// If the Tile in question is in an incorrect format, something is wrong in the save file.
				if (!ValidateTileRead(currString) || (isalpha(currString.at(0)) && currString.at(0) == 'W')) {
					cout << "RestoreRoundData(): Black Boneyard initialization failed. Invalid Tile recorded." << endl;
					return false;
				}
				Tile currTile(currString.at(0), stoi(currString.substr(1, 1)), stoi(currString.substr(2, 2)));
				human.AddToBoneyard(currTile);
				saveFile >> currString;
			}
		}
		else {
			cout << "RestoreRoundData(): Something is wrong." << endl;
			return false;
		}

		// Boneyard size validation:
		if (cpu.GetBoneyard().size() != human.GetBoneyard().size()) {
			cout << "RestoreRoundData(): Invalid Boneyards, the White and Black Boneyards are not the same size." << endl;
			return false;
		}

		// Hand initialization:
		saveFile >> currString;
		// The restoredHand variable was used before for CPU initialization, so it will be cleared here before it is used again.
		restoredHand.ClearTilesFromHand();
		while (currString != "Score:") {
			// If the Tile in question is in an incorrect format, something is wrong in the save file.
			if (!ValidateTileRead(currString) || (isalpha(currString.at(0)) && currString.at(0) == 'W')) {
				cout << "RestoreRoundData(): Human Hand initialization failed. Invalid Tile recorded." << endl;
				return false;
			}
			Tile currTile(currString.at(0), stoi(currString.substr(1, 1)), stoi(currString.substr(2, 2)));
			restoredHand.AddTile(currTile);
			saveFile >> currString;
		}
		switch (human.GetBoneyard().size()) {
		case 22:
			restoredHand.SetHandNum(1);
			break;
		case 16:
			restoredHand.SetHandNum(2);
			break;
		case 10:
			restoredHand.SetHandNum(3);
			break;
		case 4:
			restoredHand.SetHandNum(4);
			break;
		}
		human.SetHand(restoredHand);

		// Score initialization:
		saveFile >> currString;
		// If any of the digits in the score are not numeric, then return false.
		for (int i = 0; i < currString.size(); i++) {
			if (!isdigit(currString.at(i))) {
				cout << "RestoreRoundData(): Invalid score." << endl;
				return false;
			}
		}
		humanScore = (stoi(currString));

		// Rounds Won initialization:
		saveFile >> currString;
		if (currString == "Rounds") {
			saveFile >> currString;
		}
		else {
			cout << "RestoreRoundData(): Something is wrong." << endl;
			return false;
		}
		if (currString == "Won:") {
			saveFile >> currString;
		}
		else {
			cout << "RestoreRoundData(): Something is wrong." << endl;
			return false;
		}

		// Save turn.
		saveFile >> currString;
		if (currString == "Turn:") {
			saveFile >> currString;
			if (currString == "Computer") {
				SetIsHumanTurn(false);
			}
			else if (currString == "Human") {
				SetIsHumanTurn(true);
			}
			else {
				cout << "RestoreRoundData(): Invalid turn." << endl;
				return false;
			}
		}

		// Starting Hand Number Initialization:
		switch (human.GetBoneyard().size()) {
		// If the Boneyard still has 22 tiles and the Players' Hnads are empty, then the stack must have been initialized and not the Hands.
		case 22:
			if (cpu.GetHandSize() == 0 && human.GetHandSize() == 0) {
				startingHandNum = 1;
				break;
			}
			else {
				cout << "RestoreRoundData(): Invalid Boneyard and Hands." << endl;
				return false;
			}
		case 16:
			startingHandNum = 1;
			break;
		case 10:
			startingHandNum = 2;
			break;
		case 4:
			startingHandNum = 3;
			break;
		case 0:
			startingHandNum = 4;
			break;
		}

		// Close file.
		saveFile.close();

		// If the code reaches this point, everything ran successfully.
		return true;
	}
	// If no file is found, return false.
	else {
		cout << "No save file found. Starting new game..." << endl;
		return false;
	}
}

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
bool Round::ValidateTileRead(string m_tileRead) {
	// If the file isn't in a (char)(int)(int) format, the Tile read in is already invalid.
	if ( m_tileRead.size() != 3 || !isalpha(m_tileRead.at(0)) || !isdigit(m_tileRead.at(1)) || !isdigit(m_tileRead.at(2)) ) {
		return false;
	}

	// If the Tile is in the correct format, but the first character is not a black or white Tile (and therefore start with a 'B' or 'W'), it is already invalid.
	if ( m_tileRead.at(0) != 'B' && m_tileRead.at(0) != 'W' ) {
		return false;
	}

	int firstInt = stoi( m_tileRead.substr(1,1) );
	// If the Tile in question is a valid color, check if the first integer in the string is between 1 and 6. If not, it is already invalid.
	if (firstInt < 0 || firstInt > 6) {
		return false;
	}

	int secondInt = stoi(m_tileRead.substr(2, 2));
	// If the Tile in question is a valid color, check if the second integer in the string is between 1 and 6. If not, it is already invalid.
	if (secondInt < 0 || secondInt > 6) {
		return false;
	}

	// Otherwise, it is a valid Tile, so return true.
	return true;
}

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
void Round::PlaceTileOntoPlayerStack(Tile m_tileSelected, string m_stackSelected) {
	cout << "Placing " << m_tileSelected.ToString() << " onto stack " << m_stackSelected << endl;
	// If placing onto one of the Human's original stacks...
	if (m_stackSelected.at(0) == 'B') {
		human.PlaceOntoStack(m_tileSelected, m_stackSelected);
	}
	// If placing onto one of the CPU's original stacks...
	if (m_stackSelected.at(0) == 'W') {
		cpu.PlaceOntoStack(m_tileSelected, m_stackSelected);
	}

	// If the Human placed a tile, then remove that Tile from Hand.
	if (m_tileSelected.GetColor() == 'B') {
		human.RemoveFromHand(m_tileSelected);
	}
	if (m_tileSelected.GetColor() == 'W') {
		cpu.RemoveFromHand(m_tileSelected);
	}
}
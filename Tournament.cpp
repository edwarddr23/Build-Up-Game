#include "Tournament.h"
#include "Round.h"
#include <iostream>

using namespace std;

// Default constructor for Tournament class.
Tournament::Tournament() {
	humanWins = 0;
	cpuWins = 0;
}

/* *********************************************************************
Function Name: RestoreInquiry
Purpose: Asks the user if they want to restore a previous game if one exists. (y = Human wishes to restore previous game, n = Human wishes to start a new game).
Parameters: None.
Return Value: Returns true if the Human wants to restore a game, and false if the Human does not want to restore a game.
Algorithm: 1) Ask Human if they want to restore a previous game or start a new game.
				a) If the input is "y", then the Human wants to restore a previous game. Return true.
				b) If the input is "n", then the Human does not want to restore a previous game, return false.
				c) If the input is neither, then repeat step 1).
Assistance Received: None.
********************************************************************* */
bool Tournament::RestoreInquiry() {
	string response;
	cout << "Restore previous game (y) or start a new game (n) ? (y/n):" << endl;
	do {
		cin >> response;
		// If it is an invalid response, clear and ignore this input so that a new one can be put in.
		if (response != "y" && response != "n") {
			cin.clear();
			cin.ignore();
			cout << "Invalid input. please input \"y\" or \"n\"." << endl;
		}
	} while (response != "y" && response != "n");

	// Human wants to restore a game, so if there is a save file, restore the data.
	if (response == "y") {
		return true;
	}
	// They do not want to restore a game, so proceed and don't do anything.
	else if (response == "n") {
		return false;
	}
	else {
		cout << "RestoreInquiry(): something is wrong." << endl;
		exit(1);
	}
}

/* *********************************************************************
Function Name: RestoreTournamnentData
Purpose: Restore round from file parameter and assign the data taken to a restoredRound variable. Set the calling Tournament's member round to this restoredRound variable. 
		 Then assign the cpuScore and humanScore members based on the information read from the save file. Returns true if there is a save file to restore from and reading is successful 
		 and returns false if there isn't. Takes tournament-specific information and then calls another function to take round-specific information.
Parameters: None.
Return Value: Returns true if restoring the data from the save file is suceesful and false if otherwise.
Algorithm: 1) Open save file. If opening save file specified fails (meaning it doesn't exist), then print that no save file exists and ask again for a filename.
		   2) Read from the save file string by string using stringstream.
		   3) If the current string read in is "Rounds", then check if the next string is "Won:". If not, then return false.
		   4) Take in another string and save it to calling Tournament object's cpuWins member.
		   5) Repeat steps 2)-4), but save to calling Tournament object's humanWins member instead.
		   6) Restore the Round data from the save file using Round::RestoreRoundData, which will modify the Tournament object's round member. If it fails somehow (returns false) return false.
		   7) Set the round member's round number to the cpuWins + humanWins Tournament members.
		   8) Display all loaded data and return true.
Assistance Received: None.
********************************************************************* */
bool Tournament::RestoreTournamnentData() {
	// Let the Human specify which file to load from. Loops if it's an invalid save file.
	string saveFileName;
	ifstream saveFile;
	do {
		cout << "Please enter a save file to load from. Please do not add an extension to the name. Enter \"cancel\" if you wish to cancel loading from a file." << endl;
		cin >> saveFileName;
		if (saveFileName == "cancel") {
			cout << "Cancelling load..." << endl;
			return false;
		}
		saveFileName += ".txt";
		saveFile.open(saveFileName);
		// If no file is found, return false.
		if (!saveFile.is_open()){
			cout << "Save file: " << saveFileName << " not found. Make sure the file ends with \".txt\"." << endl;
		}
	} while (!saveFile.is_open());
	
	cout << "Restoring data..." << endl;
	
	// If there is a save file, read from it and store it into the round object. The only data that can be directly recorded by the calling Tournament object are the Player's scores and round
	string currString;
	// CPU Scores Initialization:
	while (currString != "Rounds") {
		saveFile >> currString;
	}
	saveFile >> currString;
	if (currString == "Won:") {
		saveFile >> currString;
		// If any of the digits in the rounds won are not numeric, then return false.
		for (int i = 0; i < currString.size(); i++) {
			if (!isdigit(currString.at(i))) {
				cout << "RestoreTournamentData(): Invalid rounds won." << endl;
				return false;
			}
		}
		cpuWins = stoi(currString);
	}
	else {
		return false;
	}
	// Human Scores Initialization:
	while (currString != "Rounds") {
		saveFile >> currString;
	}
	saveFile >> currString;
	if (currString == "Won:") {
		saveFile >> currString;
		// If any of the digits in the rounds won are not numeric, then return false.
		for (int i = 0; i < currString.size(); i++) {
			if (!isdigit(currString.at(i))) {
				cout << "RestoreTournamentData(): Invalid rounds won." << endl;
				return false;
			}
		}
		humanWins = stoi(currString);
	}
	else {
		return false;
	}

	// The data restored will be stored onto the calling Tournament's round member.
	// Restore round-specific data into restoredRound object. If restoring the Round failed for any reason, return and do not restore the Round.
	if (!round.RestoreRoundData(saveFileName)) {
		return false;
	}

	// Add the Human's and CPU's wins and store that number into roundNum
	round.SetRoundNum(cpuWins + humanWins + 1);

	// Display loaded data.
	round.GetCPU().DisplayStacks();
	round.GetHuman().DisplayStacks();
	round.GetCPU().PrintBoneyard();
	round.GetHuman().PrintBoneyard();
	round.GetCPU().DisplayHand();
	round.GetHuman().DisplayHand();
	cout << "CPU's score: " << round.GetCPUScore() << endl;
	cout << "Human's score: " << round.GetHumanScore() << endl;
	cout << "CPU Rounds Won: " << cpuWins << endl;
	cout << "Human Rounds Won: " << humanWins << endl;
	string turn;
	if (round.GetIsHumanTurn()) {
		turn = "Human";
	}
	else {
		turn = "Computer";
	}
	cout << "Turn: " << turn << endl;

	return true;
}

/* *********************************************************************
Function Name: SerializeRound
Purpose: Called in main program to store the Tournament's data into a save file. Creates a new save file if one doesn't exist, and truncates if a save file is found.
Parameters: None.
Return Value: None.
Algorithm: 1) Check to see if the Tournament object's round member is suspended by the Human.
				a) If not, return and don't do anything.
		   2) Since the round has not been suspended, make the Tournament's round member store its data into a string, passing in the humanWins and cpuWins members since the round can't access those.
		   3) Try to open the save file that the 
				a) If it is open, then the file does exist. Overwrite the file by truncating the round member's roundData member which has all of the round's data.
				b) If it is not open, then that means the file does not exist. Create a new saveFile called whatever the Human specifies and print the round member's roundData member onto the file.
		   4) Close the save file and return.
Assistance Received: Learned how to open and validate whether a file exists or not from https://www.tutorialspoint.com/the-best-way-to-check-if-a-file-exists-using-standard-c-cplusplus.
					 Learned how to truncate a file from https://stackoverflow.com/questions/17032970/clear-data-inside-text-file-in-c#:~:text=If%20you%20simply%20open%20the,you'll%20delete%20the%20content.
********************************************************************* */
void Tournament::SerializeRound() {
	// If the game isn't suspended, don't run this function at all.
	if (round.GetIsSuspended() == false) {
		return;
	}

	// Round stores data into round.roundData.
	round.StoreData(humanWins, cpuWins);

	// If a save file already exists, try to open it. Inspiration from: https://www.tutorialspoint.com/the-best-way-to-check-if-a-file-exists-using-standard-c-cplusplus
	cout << "Please enter what you want to call the save file. Please do not put an extension, as one is automatically added:" << endl;
	string saveFileName;
	cin >> saveFileName;
	// Add a .txt extension for the Human.
	saveFileName += ".txt";

	ifstream saveFile;
	saveFile.open(saveFileName);
	// If a save file of that name already exists, clear its contents and write to it. Inspiration from https://stackoverflow.com/questions/17032970/clear-data-inside-text-file-in-c#:~:text=If%20you%20simply%20open%20the,you'll%20delete%20the%20content.
	if (saveFile) {
		ofstream overwriteSaveFile;
		// Previous contents are discarded
		overwriteSaveFile.open(saveFileName, ofstream::out | ofstream::trunc);
		overwriteSaveFile << round.GetRoundData();
		overwriteSaveFile.close();
	}
	// If no save file exists yet, create one and write to it.
	else {
		ofstream newSaveFile(saveFileName);
		// Write the round's data to the newly made save file.
		newSaveFile << round.GetRoundData();
		// Close the file.
		newSaveFile.close();
	}
}

/* *********************************************************************
Function Name: InitializeRound
Purpose: Used to intiialize restored and new Rounds.
Parameters: (value) m_restoringRound, a boolean that is used to determine whether to initialize a new Round or re-initialize a restored Round.
Return Value: None.
Algorithm: 1) Check the parameter m_restoringRound.
				a) If the parameter is true and the Tournament member round's number is 0, then this must be a case where the Human just started teh game and wants to restore a Round from a save file.
					A) Try to restore the Tournament's data from the save file.
						a) If this works, set the round's isRestoredRound member to true and return.
						b) if this fails, then continue to step 2).
		   2) Initialize a new Round if loading from a file fails or the Human doesn't want to resume a previous game, initialize a new Round.
				a) Set the Tournament member round's starting hand number to 1, Increment the roundNumber (as it starts at 0), and set the Human's and CPU's scores to 0
				b) Initialize the Black and White Boneyards for a new Round (handled by InitialzeBoneyards)
				c) Initialize the Players' stacks using InitializePlayersStacks.
Assistance Received: None.
********************************************************************* */
void Tournament::InitializeRound(bool m_restoringRound) {
	bool restoreSuccess;
	// If the game just started (where the roundNum is initalized at 1) and the user does want to restore a round, then it will try to restore the round's data.
	if (round.GetRoundNum() == 0 && m_restoringRound) {
		if (RestoreTournamnentData()) {
			round.SetIsRestoredRound(true);
			return;
		}
		// If for whatever reason, the restoring the Round's data from the save file fails, then print that it failed and that the game will start a new game instead.
		else {
			cout << "Loading from save file failed. Starting a new game..." << endl;
		}
	}
	// If restoring the round data fails or this is truly supposed to be the first round, it will initialize the round as if it is the first round.
	round.SetStartingHandNum(1);
	round.IncrementRoundNum();
	round.SetHumanScore(0);
	round.SetCPUScore(0);

	// Round initializes its black and white boneyards.
	round.InitializeBoneyards();

	// Initialize Human and CPU stacks
	round.InitializePlayersStacks();
}

/* *********************************************************************
Function Name: AddWin
Purpose: Used to store who won in Tournament members humanWins or cpuWins to keep track of how many times each Player won.
Parameters: None.
Return Value: None.
Algorithm: 1) Check whether the Tournament's round member has been suspended.
				a) If the Round has been suspended, then return and don't do anything.
		   2) Since the Round has not been suspended, compare the Human's and CPU's scores from the Round that just finished.
				a) If the Human has a higher score than the CPU, then increment Tournament's member humanWins by 1 and print that the Human won.
				b) If the CPU has a higher score than the Human, then increment Tournament's member cpuWins by 1 and print that the CPU won.
				c) If the Human's score and CPU's score are equal, then increment both Tournament members humanWIns and cpuWins by 1 and print that there is a draw.
Assistance Received: None.
********************************************************************* */
void Tournament::AddWin() {
	// If the game is suspended, don't store wins.
	if (round.GetIsSuspended() == true) {
		return;
	}

	cout << "_________________________________________________________" << endl;
	// If the human's score is greater than the CPU's score, the human wins and the humanWins int is incremented.
	if (round.GetHumanScore() > round.GetCPUScore()) {
		cout << "Human wins Round " << round.GetRoundNum() << " by " << round.GetHumanScore() - round.GetCPUScore() << " points!" << endl;
		humanWins++;
	}
	// If the human's score is less than the CPU's score, the CPU wins and the cpuWins int is incremented.
	else if (round.GetHumanScore() < round.GetCPUScore()) {
		cout << "CPU wins Round " << round.GetRoundNum() << " by " << round.GetCPUScore() - round.GetHumanScore() << "!" << endl;
		cpuWins++;
	}
	// If the human's score and CPU's score are equal, then it is a draw and both are incremented.
	else if (round.GetHumanScore() == round.GetCPUScore()) {
		cout << "Round " << round.GetRoundNum() << " is a draw! Both players will be awarded a win!" << endl;
		humanWins++;
		cpuWins++;
	}
	cout << "_________________________________________________________" << endl;
}

/* *********************************************************************
Function Name: PrintWins
Purpose: Prints the Human's total wins and the CPU's total wins.
Parameters: None.
Return Value: None.
Algorithm: 1) Check whether the Tournament's round member has been suspended.
				a) If the Round has been suspended, then return and don't do anything.
		   2) Since the Round has not been suspended, print the Human's total wins and CPU's total wins.
Assistance Received: None.
********************************************************************* */
void Tournament::PrintWins() {
	// If the game is suspended, don't print wins.
	if (round.GetIsSuspended() == true) {
		return;
	}

	cout << "Human's wins: " << humanWins << endl;
	cout << "CPU's wins: " << cpuWins << endl;
	cout << "_________________________________________________________" << endl;
}

/* *********************************************************************
Function Name: RoundInquiry
Purpose: Asks the player whether to start a new round or not. Used to determine whether to end the Tournament and show the results or not.
Parameters: None.
Return Value: Returns true if the Human wants to start another round. Returns false if the Human wants to end the toournament.
Algorithm: N/A
Assistance Received: None.
********************************************************************* */
bool Tournament::RoundInquiry() {
	if (round.GetIsSuspended() == true) {
		return false;
	}
	cout << "Another Round? Enter \"Y\" if you want to start a new round. Enter \"N\" if you wish to end the tournament." << endl;
	string response;
	do {
		cin >> response;
		if (response == "y" || response == "Y") {
			return true;
			break;
		}
		else if (response == "n" || response == "N") {
			return false;
			break;
		}
		else {
			cout << "Invalid input. Please input \"Y\" or \"N\"." << endl;
		}
	} while (true);
}

/* *********************************************************************
Function Name: DeclareWinnerOfTournament
Purpose: Compares human's and CPU's wins and declares winner of tournament.
Parameters: None.
Return Value: None.
Algorithm: 1) Check to see if the Tournament's round member is suspended.
				a) If so, then return and don't do anything.
		   2) Since the Tournament's round member is not suspended, determine who won the Tournament.
				a) If the Human has more wins than the CPU, then print that the Human won the Tournament.
				b) If the CPU has mroe wins than the Human, then print that the CPU won the Tourrnament.
				c) If the Human and CPU have an equal amount of wins, then print that there is a draw and that neither Player won the Tournament.
		   3) Print the Human's and the CPU's wins.
Assistance Received: None.
********************************************************************* */
void Tournament::DeclareWinnerOfTournament() {
	// If the game is suspended, don't do anything.
	if (round.GetIsSuspended()) {
		return;
	}

	cout << "_________________________________________________________" << endl << endl;
	cout << "Tournament has ended. " << endl;

	if (humanWins > cpuWins) {
		cout << "Human wins the tournament!" << endl;
		
	}
	else if (cpuWins > humanWins) {
		cout << "The CPU wins the tournament!" << endl;
	}
	else if (humanWins == cpuWins) {
		cout << "There is a draw! Neither player wins the tournament!" << endl;
	}
	else {
		cout << "DeclareWinner(): An error has occurred." << endl;
		exit(1);
	}
	PrintWins();
	cout << endl << "Thank you for playing!" << endl;
}
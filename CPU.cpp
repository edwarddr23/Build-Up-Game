#include "CPU.h"

using namespace std;

/* *********************************************************************
Function Name: PrintBoneyard
Purpose: Prints the CPU's Boneyard, interited from Player.
Parameters: N/A.
Return Value: None.
Algorithm: N/A.
Assistance Received: None.
********************************************************************* */
void CPU::PrintBoneyard() {
	cout << "White Tile Boneyard : " << endl;
	for (int i = 0; i < boneyard.size(); i++) {
		cout << boneyard.at(i).ToString() << " ";
	}
	cout << endl;
	cout << "There are " << boneyard.size() << " white tiles" << endl << endl;
}

/* *********************************************************************
Function Name: PrintReasoning
Purpose: Prints the specific reasoning behind the CPU's tile selection and stack placement based on what the CPU object's reasoning member variable is set to.
Parameters: (value) m_tileSelected, a tile that should be the optimal tile the CPU chose using OptimalHandTile which is used to output its tile choice for the Human.
Return Value: None.
Algorithm:  Depending on what the CPU object's reasoning member variable is set to, this function will print the tile specified by the m_tileSelected parameter and the
			specific reasoning behind its tile choice and stack placement. All reasons:
				0: Human has more stacks topped than CPU, so CPU chooses largest double to place on the highest human stack possible.
				1: Human has more stacks topped than CPU, but CPU has no valid double tiles in hand. The largest non-duoble tile in hand is played onto the highest valid Human stack.
				2: The CPU has more stacks covered so it is just getting rid of the lowest non-double tiles in hand (the least valuable and hardest to place) and places it onto the highest valid Human stack.
				3: The CPU has more stacks covered but no valid non-double tiles in hand can be played. The largest double is played onto the largest Human stack.
				4: The CPU is unable to replace a Human-topped stack, so it must replace one of its own with the closest non-double tile on hand.
Assistance Received: None.
********************************************************************* */
void CPU::PrintReasoning(Tile m_tileSelected) {
	cout << m_tileSelected.ToString();
	switch (reasoning) {
	case 0:
		cout << " is chosen to reduce the number of human stacks by reducing the largest human stack possible." << endl;
		break;
	case 1:
		cout << " is chosen to reset the highest Human stack possible." << endl;
		break;
	case 2:
		cout << " is chosen to get rid of lowest non-double tiles." << endl;
		break;
	case 3:
		cout << " is chosen to get rid of double tiles since no valid low non-double tiles were found." << endl;
		break;
	case 4:
		cout << " is chosen to replace the smallest CPU-topped stack since no Human-topped stacks can be covered." << endl;
		break;
	}
}

/* *********************************************************************
Function Name: PrintHelpReasoning
Purpose: Function is to be used by a helpCPU object created in the Human class. Using the same algorithms the enemy CPU uses to pick the optimal tile in hand and stack to place on against
			the Human, the helpCPU instance is supposed to print a slightly different output with this function than with PrintReasoning since it is now suggesting an optimal tile in hand
			and stack placement for the Human.
Parameters: (value) m_tileSelected, a tile that should be the optimal tile the helpCPU chose using OptimalHandTile which is used to output its tile choice for the Human.
Return Value: None.
Algorithm:  Depending on what the helpCPU object's reasoning member variable is set to, this function will print the tile specified by the m_tileSelected parameter and the
			specific reasoning behind its tile choice and stack placement. All reasons:
				0: Human has more stacks topped than CPU, so CPU chooses largest double to place on the highest human stack possible.
				1: Human has more stacks topped than CPU, but CPU has no valid double tiles in hand. The largest non-duoble tile in hand is played onto the highest valid Human stack.
				2: The CPU has more stacks covered so it is just getting rid of the lowest non-double tiles in hand (the least valuable and hardest to place) and places it onto the highest valid Human stack.
				3: The CPU has more stacks covered but no valid non-double tiles in hand can be played. The largest double is played onto the largest Human stack.
				4: The CPU is unable to replace a Human-topped stack, so it must replace one of its own with the closest non-double tile on hand.
				5: The Human already chose a tile that may or may not be optimal, but can be placed on a CPU-topped stack, so the highest valid CPU-topped stack is displayed.
				6: The Human already chose a tile that was definitely not optimal and has to be placed on the smallest Human-topped stack possible.
Assistance Received: None.
********************************************************************* */
void CPU::PrintHelpReasoning(Tile m_tileSelected, string m_stackSelected, bool m_tileChosen) {
	cout << "_________________________________________________________" << endl << endl;
	// If the Human has not already chosen their tile, then print the CPU's tile selection and stack selection reasons.
	if (!m_tileChosen) {
		cout << "Help CPU chose tile ";
		switch (reasoning) {
		case 0:
			cout << m_tileSelected.ToString() << " to reduce the number of CPU stacks by placing on largest CPU stack possible, " << m_stackSelected << endl;
			break;
		case 1:
			cout << m_tileSelected.ToString() << " to reset the highest CPU stack possible, " << m_stackSelected << endl;
			break;
		case 2:
			cout << m_tileSelected.ToString() << " to get rid of lowest valid non-double tile in hand on the largest CPU stack possible, " << m_stackSelected << endl;
			break;
		case 3:
			cout << m_tileSelected.ToString() << " to get rid of double tiles since no valid low non-double tiles were found. Place on largest CPU stack possible, " << m_stackSelected << endl;
			break;
		case 4:
			cout << m_tileSelected.ToString() << ", the smallest valid tile in hand, to replace the closest valid Human-topped stack " << m_stackSelected << " since no CPU - topped stacks can be covered." << endl;
			break;
		}
	}
	// If the Human has chosen their tile, then print the optimal tile for the tile chosen.
	else {
		switch (reasoning) {
		case 0:
			cout << m_tileSelected.ToString() << " should be used to reduce the number of CPU stacks by placing on largest CPU stack possible, " << m_stackSelected << endl;
			break;
		case 1:
			cout << m_tileSelected.ToString() << " should be used to reset the highest CPU stack possible, " << m_stackSelected << endl;
			break;
		case 2:
			cout << m_tileSelected.ToString() << " should be used to get rid of lowest valid non-double tile in hand on the largest CPU stack possible, " << m_stackSelected << endl;
			break;
		case 3:
			cout << m_tileSelected.ToString() << " should be used to get rid of double tiles since no valid low non-double tiles were found. Place on largest CPU stack possible, " << m_stackSelected << endl;
			break;
		case 4:
			cout << m_tileSelected.ToString() << ", the smallest valid tile in hand, should be used to replace the closest valid Human-topped stack " << m_stackSelected << " since no CPU - topped stacks can be covered." << endl;
			break;
		case 5:
			cout << m_tileSelected.ToString() << " should be placed on the highest CPU-topped stack possible, " << m_stackSelected  << endl;
			break;
		case 6:
			cout << m_tileSelected.ToString() << " was not an optimal tile and should be placed on the smallest Human-topped stack possible, " << m_stackSelected << endl;
			break;
		}
	}
	cout << "_________________________________________________________" << endl << endl;
}

/* *********************************************************************
Function Name: OptimalHandTile
Purpose: Returns the optimal Tile in Hand to place.
Parameters: (value) m_oppositeStacks, a vector that should be the opposite stack from the calling Player (helpCPU or CPU).
			(value) m_oppositeColor, a char that should be the opposite color form the calling Player (helpCPU or CPU).
Return Value: A Tile object that represents which optimal Tile for the helpCPU or CPU to place.
Algorithm:  1) Create char variable thisColor to store the calling object's color ('B' for Human and 'W' for CPU).
			3) Create two vectors of Tiles, one that represents the Human's original 6 stacks and the other that represents the CPU's original 6 stacks.
			2) Determine which CPU is calling this function based on what m_opposite color is set to. If m_opposite color is set to 'B', then it must be the enemy CPU. If it is set to
				'W', then it must be teh helpCPU calling the function. If it is the CPU calling the function, then set thisColor to 'W', humanStacks to m_oppositeStacks, and cpuStacks
				to the calling object's stacks. If it is the helpCPU calling the function, then set humanStacks to the calling object's stacks (which should be equivalent to the
				Human's original 6 stacks as specified in PrintHelp in the Human class) and cpuStacks to m_oppositeStacks.
			3) Determine whether or not the CPU or helpCPU callign this function are in a neutral or disadvantaged state. If the opponent topped the majority of the 12 stacks, then
			   the calling object is in a disadvantaged state. Otherwise, it is in a neutral state.
				a) If the calling CPU object is in a disadvantaged state, find the largest non-double in hand that can be placed on an opposite-topped stack.
				   If no valid non-doubles in hand exist, find the largest valid double on hand that can be placed on the an opposite-topped stack.
				b) If the calling CPU object is in an advantaged state, the find the smallest non-double in hand that can be placed on an opposite-topped stack.
				   If no valid non-doubles in hand exist, find the smallest valid double on hand that can be placed on the an opposite-topped stack.
				c) If neither a) or b) return a tile, this means that no tiles in hand can be played on an opposite-topped stack. Find the smallest tile in hand that can
				   be placed on any stack (which should theoretically be a thisColor colored stack).
Assistance Received: None.
********************************************************************* */
Tile CPU::OptimalHandTile(vector<Tile> m_oppositeStacks, char m_oppositeColor) {
	char thisColor;
	vector<Tile> humanStacks;
	vector<Tile> cpuStacks;
	// If the opposite color is B, then it is the enemy CPU calling this function. Therefore the oppositeStacks is the Human's original stacks.
	if (m_oppositeColor == 'B') {
		thisColor = 'W';
		humanStacks = m_oppositeStacks;
		cpuStacks = this->stacks;
	}
	// If the opposite color is B, then it is the helpCPU calling this function. Therefore the oppositeStacks is the CPU's original stacks.
	else if (m_oppositeColor == 'W') {
		thisColor = 'B';
		humanStacks = this->stacks;
		cpuStacks = m_oppositeStacks;
	}

	// If the enemy (could be CPU for helpCPU or the Human for the CPU) has more stacks covered than the CPU (where the player would need more than 6 since there can only be 12 stacks), 
	// return the highest tile in hand to reset the highest opposite-colored stack possible.
	if (GetStacksOfType(humanStacks, cpuStacks, m_oppositeColor).size() > 6) {
		// The non-double tiles are technically less powerful, so try to get rid of them first.
		// If the CPU has no valid double tiles on hand, take the largest non-double in hand and place it on the largest opposite stack.
		if (NonDoubleTilesInHand().size() > 0) {
			// Copy of all non-doubles in hand that will be useful in deducing the largest valid non-double to playce
			vector<Tile> nonDoublesInHand = NonDoubleTilesInHand();
			// Find largest non-double tile in CPU hand.
			Tile largestNonDoubleInHand = LargestTile(nonDoublesInHand);
			vector<string> validStacks = largestNonDoubleInHand.ValidStackPlacements(humanStacks, cpuStacks);
			// If there are valid opposite-topped stacks for the largest tile, use it.
			if (validStacks.size() > 0 && HasOppositeToppedStacks(validStacks, humanStacks, cpuStacks, m_oppositeColor)) {
				// 0 being the situation where the number of player stacks needs to be reduced and a valid non-double is found
				SetReasoning(0);
				return largestNonDoubleInHand;
			}
		}
		// If the CPU has double tiles in hand, find the largest valid double in hand.
		if (DoubleTilesInHand().size() > 0) {
			// Copy of all non-doubles in hand that will be useful in deducing the largest valid non-double to playce
			vector<Tile> doublesInHand = DoubleTilesInHand();
			// Evaluate all non-doubles to see which is the largest valid non-double in hand.
			while (doublesInHand.size() > 0) {
				// Find largest non-double tile in CPU hand.
				Tile largestDoubleInHand = LargestTile(doublesInHand);
				vector<string> validStacks = largestDoubleInHand.ValidStackPlacements(humanStacks, cpuStacks);
				// If there are valid Human-topped stacks for the largest double tile, use it.
				if (validStacks.size() > 0 && HasOppositeToppedStacks(validStacks, humanStacks, cpuStacks, m_oppositeColor)) {
					// 1 being the situation where the number of player stacks needs to be reduced but CPU has no valid non-double tiles in hand.
					SetReasoning(1);
					return largestDoubleInHand;
				}
			}
		}
	}
	// If the CPU has more or equal stacks covered than the human, just get rid of the smallest valid non-double tile in hand early. If no non-double tiles are valid, find the smallest valid double tile in hand instead.
	else {
		// If the CPU has non-double tiles...
		if (NonDoubleTilesInHand().size() > 0) {
			vector<Tile> nonDoubleTilesInHand = NonDoubleTilesInHand(); // Copy of non-double tiles that will be useful in finding the least non-double tile that is also valid to place.
			// Find smallest valid non-double tile in CPU hand.
			while (nonDoubleTilesInHand.size() > 0) {
				Tile smallestNonDoubleInHand = SmallestTile(nonDoubleTilesInHand);
				vector<string> validStacks = smallestNonDoubleInHand.ValidStackPlacements(humanStacks, cpuStacks);
				// If there are valid Human-topped stacks for the smallest tile, use it.
				if (validStacks.size() > 0 && HasOppositeToppedStacks(validStacks, humanStacks, cpuStacks, m_oppositeColor)) {
					// 2 being the situation where there are more or equal CPU stacks than human ones, so it is just getting rid of the lowest non-double tiles in hand (the least valuable and hardest to place).
					SetReasoning(2);
					return smallestNonDoubleInHand;
				}
				// If the smallest non-double in hand cannot be placed, find the next smallest non-double tile.
				for (int i = 0; i < nonDoubleTilesInHand.size(); i++) {
					// Remove the current invalid smallest non-double tile from consideration and re-evaluate.
					if (nonDoubleTilesInHand.at(i) == smallestNonDoubleInHand) {
						nonDoubleTilesInHand.erase(nonDoubleTilesInHand.begin() + i);
						// Break from the loop and re-evaluate the non-double tiles in hand without this tile in consideration.
						break;
					}
				}
			}
		}
		// If the CPU doesn't have valid non-double tiles, just choose the smallest valid double in hand.
		if (DoubleTilesInHand().size() > 0) {
			vector<Tile> doubleTilesInHand = DoubleTilesInHand(); // Copy of non-double tiles that will be useful in finding the smallest valid double tile that is also valid to place.
			while (doubleTilesInHand.size() > 0) {
				Tile smallestDoubleInHand = SmallestTile(doubleTilesInHand);
				vector<string> validStacks = smallestDoubleInHand.ValidStackPlacements(humanStacks, cpuStacks);
				// If there are valid Human-topped stacks for the smallest valid double to be placed, then use it.
				if (validStacks.size() > 0 && HasOppositeToppedStacks(validStacks, humanStacks, cpuStacks, m_oppositeColor)) {
					// 3 being the situation where the CPU has more stacks covered but no valid non-double tiles in hand can be played so the smallest valid double tile is played.
					SetReasoning(3);
					return smallestDoubleInHand;
				}
				// If the smallest non-double in hand cannot be placed, find the next smallest non-double tile.
				if (doubleTilesInHand.size() >= 1) {
					for (int i = 0; i < doubleTilesInHand.size(); i++) {
						// Remove the current invalid smallest non-double tile from consideration and re-evaluate.
						if (doubleTilesInHand.at(i) == smallestDoubleInHand) {
							doubleTilesInHand.erase(doubleTilesInHand.begin() + i);
							// Break from the loop and re-evaluate the non-double tiles in hand without this tile in consideration.
							break;
						}
					}
				}
			}
		}
	}

	// If the function reaches this point, it is because the CPU's hand is not good enough to cover a Human-topped stack and must replace one of its own stacks.
	// This means that the smallest tile in hand with any valid placements will probably be CPU-topped stacks, so return the smallest valid tile.
	// Copy the tiles from hand, this will be helpful for narrowing down the smallest valid hand tile to play.
	vector<Tile> validTilesInHand = GetTilesInHand();
	for (int i = 0; i < GetHandSize(); i++) {
		// Remove invalid tiles from consideration. If an invalid tile is found, remove it and reevaluate the tiles in hand.
		for (int j = 0; j < validTilesInHand.size(); j++) {
			if (validTilesInHand.at(j).ValidStackPlacements(humanStacks, cpuStacks).size() == 0) {
				validTilesInHand.erase(validTilesInHand.begin() + j);
				break;
			}
		}
	}
	SetReasoning(4); // 4 being the situation where the CPU's hand tiles aren't good enough to cover any Human stacks, so the smallest valid tile in hand is chosen to get rid of.
	return SmallestTile(validTilesInHand);
}

/* *********************************************************************
	Function Name: OptimalStackPlacement
	Purpose: Returns the optimal stack placement.
	Parameters: (value) m_tileSelected, a tile that should be the optimal tile the helpCPU chose using OptimalHandTile which is used to output its tile choice for the Human.
				(value) m_oppositeStacks, a 
				that should be the opposite stack from the calling Player (helpCPU or CPU).
				(value) m_oppositeColor, a char that should be the opposite color form the calling Player (helpCPU or CPU).
	Return Value: A string that starts with 'B' or 'W' and ends with an integer 1-6 that represents which stack the helpCPU or CPU that is optimal.
	Algorithm:  1) Create char variable thisColor to store the calling object's color ('B' for Human and 'W' for CPU).
				3) Create two vectors of Tiles, one that represents the Human's original 6 stacks and the other that represents the CPU's original 6 stacks.
				2) Determine which CPU is calling this function based on what m_opposite color is set to. If m_opposite color is set to 'B', then it must be the enemy CPU. If it is set to
				   'W', then it must be teh helpCPU calling the function. If it is the CPU calling the function, then set thisColor to 'W', humanStacks to m_oppositeStacks, and cpuStacks
				   to the calling object's stacks. If it is the helpCPU calling the function, then set humanStacks to the calling object's stacks (which should be equivalent to the
				   Human's original 6 stacks as specified in PrintHelp in the Human class) and cpuStacks to m_oppositeStacks.
				3) Based on the what member variable reasoning was set to in OptimalHandTile (which should always be called before this function), the function will use a different selection
				   algorithm.
					a) If the member variable reasoning was set to an integer 0-3, this means that the optimal stack placement is the largest opposite-colored-topped stack. Find the largest
					   opposite-colored-topped stack amongst the 12 stacks. Store all stacks that the tile parameter m_tileSelected can be placed on onto a local vector. It is assumed that
					   parameter m_tileSelected can be placed on an opposite-colored stack since OptimalHandTile takes that into consideration, so then remove all valid stack placements
					   from that local vector that have the color thisColor to remove the CPU object's own tiles from consideration. Amongst all of the valid opposite-topped stacks that 
					   m_tileSelected can be placed on, find the largest and return that stack as a string.
					b) If the member variable reasoning was set to an integer, 4, then the optimal stack placement is the smallest thisColor-colored stack amongst the 12 stacks. It is
					   assumed that m_tileSelected does not have any valid opposite-topped stack placements as is determined by OptimalHandTile. Therefore, search all of m_tileSelected's
					   valid stack placements for the smallest one (presumably a thisColor-colored stack) to increase points and minimize the likelihood of having leftover tiles at the end
					   of the round.
	Assistance Received: None.
	********************************************************************* */
string CPU::OptimalStackPlacement(Tile m_tileSelected, vector<Tile> m_oppositeStacks, char m_oppositeColor) {
	char thisColor;
	vector<Tile> humanStacks;
	vector<Tile> cpuStacks;
	// If the opposite color is B, then it is the enemy CPU calling this function. Therefore the oppositeStacks is the Human's original stacks.
	if (m_oppositeColor == 'B') {
		thisColor = 'W';
		humanStacks = m_oppositeStacks;
		cpuStacks = this->stacks;
	}
	// If the opposite color is B, then it is the helpCPU calling this function. Therefore the oppositeStacks is the CPU's original stacks.
	else if (m_oppositeColor == 'W') {
		thisColor = 'B';
		humanStacks = this->stacks;
		cpuStacks = m_oppositeStacks;
	}

	vector<string> validStacks = m_tileSelected.ValidStackPlacements(humanStacks, cpuStacks);
	// In cases 0-3 or 5, the largest valid opposite-colored stack is what needs to be returned, so effectively the same needs to be done for all these cases.
	if (GetReasoning() >= 0 && GetReasoning() <= 3 || GetReasoning() == 5) {
		vector<string> validOppositeStacks;
		// Take out the stacks that are of thisColor from considered valid stacks.
		for (int i = 0; i < validStacks.size(); i++) {
			// If the valid stack in question is one of the Human's original stacks and is a thisColor-topped stack, then remove it from consideration of valid stacks.
			if (validStacks.at(i).at(0) == 'B'
				&& humanStacks.at(stoi(validStacks.at(i).substr(1,1)) - 1).GetColor() == thisColor) {
				continue;
			}
			// If the valid stack in question is one of the CPU's original stacks and is a thisColor-topped stack, then remove it from consideration of valid stacks.
			if (validStacks.at(i).at(0) == 'W'
				&& cpuStacks.at(stoi(validStacks.at(i).substr(1, 1)) - 1).GetColor() == thisColor) {
				continue;
			}
			validOppositeStacks.push_back(validStacks.at(i));
		}

		// Find the largest opposite-topped stack.
		// Gather all the tiles from the opposite-topped stacks.
		vector<Tile> oppositeTopTiles;
		for (int i = 0; i < validOppositeStacks.size(); i++) {
			if (validOppositeStacks.at(i).at(0) == 'B') {
				oppositeTopTiles.push_back( humanStacks.at(stoi(validOppositeStacks.at(i).substr(1,1)) - 1) );
			}
			if (validOppositeStacks.at(i).at(0) == 'W') {
				oppositeTopTiles.push_back(cpuStacks.at(stoi(validOppositeStacks.at(i).substr(1, 1)) - 1));
			}
		}
		
		// Find the largest of these opposite-topped stacks.
		Tile largestOppositeToppedTile = LargestTile(oppositeTopTiles);

		// Find which tile had this largest opposite-topped tile.
		for (int i = 0; i < validOppositeStacks.size(); i++) {
			if (validOppositeStacks.at(i).at(0) == 'B'
				&& humanStacks.at( stoi(validOppositeStacks.at(i).substr(1,1)) - 1 ) == largestOppositeToppedTile) {
				return validOppositeStacks.at(i);
			}
			else if (validOppositeStacks.at(i).at(0) == 'W'
				&& cpuStacks.at(stoi(validOppositeStacks.at(i).substr(1, 1)) - 1) == largestOppositeToppedTile) {
				return validOppositeStacks.at(i);
			}
		}
	}
	// case 4 or 6, however, requires the smallest CPU-topped stack instead.
	else if (GetReasoning() == 4 || GetReasoning() == 6) {
		// Find the smallest CPU-topped stack.
		string smallestCPUToppedStack = validStacks.at(0);
		Tile smallestCPUToppedTile;
		// If the first valid stack is one of the Human's original stacks, initialize the largest Human-topped tile as that one.
		if (validStacks.at(0).at(0) == 'B') {
			smallestCPUToppedTile = humanStacks.at( stoi(validStacks.at(0).substr(1, 1)) - 1 );
		}
		// If the first valid stack is one of the CPU's original stacks, initialize the largest Human-topped tile as that one.
		if (validStacks.at(0).at(0) == 'W') {
			smallestCPUToppedTile = cpuStacks.at( stoi(validStacks.at(0).substr(1, 1)) - 1);
		}
		for (int i = 0; i < validStacks.size(); i++) {
			if (validStacks.at(i).at(0) == 'B'
				&& humanStacks.at( stoi(validStacks.at(0).substr(1, 1)) - 1 ).GetTotalPips() < smallestCPUToppedTile.GetTotalPips()) {
				smallestCPUToppedStack = validStacks.at(i);
			}
			else if (validStacks.at(i).at(0) == 'W'
				&& cpuStacks.at( stoi(validStacks.at(0).substr(1, 1)) - 1 ).GetTotalPips() < smallestCPUToppedTile.GetTotalPips()) {
				smallestCPUToppedStack = validStacks.at(i);
			}
		}
		return smallestCPUToppedStack;
	}
}

/* *********************************************************************
Function Name: NonDoubleTilesInHand
Purpose: Returns non-double tiles in hand.
Parameters: None.
Return Value: A vector of Tiles holding all of the non-double tiles found in CPU's Hand.
Algorithm:  1) Create a vector of non-double Tiles.
			2) Iterate through each Tile in Hand.
				a) If the Tile in question is a non-double (determined by IsDouble), push it onto the vector of non-double Tiles.
			3) Return vector of non-double Tiles.
Assistance Received: None.
********************************************************************* */
vector<Tile> CPU::NonDoubleTilesInHand() {
	vector<Tile> nonDoubleTiles;
	// Search all the tiles in hand. If the tile is not a double, push it onto the vector.
	for (int i = 0; i < GetHandSize(); i++) {
		Tile currTile = GetTilesInHand().at(i);
		if (!currTile.IsDouble()) {
			nonDoubleTiles.push_back(currTile);
		}
	}
	return nonDoubleTiles;
}

/* *********************************************************************
Function Name: DoubleTilesInHand
Purpose: Returns double tiles in hand.
Parameters: None.
Return Value: A vector of Tiles holding all of the double tiles found in CPU's Hand.
Algorithm:  1) Create a vector of double Tiles.
			2) Iterate through each Tile in Hand.
				a) If the Tile in question is a double (determined by IsDouble), push it onto the vector of double Tiles.
			3) Return vector of double Tiles.
Assistance Received: None.
********************************************************************* */
vector<Tile> CPU::DoubleTilesInHand() {
	vector<Tile> DoubleTiles;
	// Search all the tiles in hand. If the tile is a double, push it onto the vector.
	for (int i = 0; i < GetHandSize(); i++) {
		Tile currTile = GetTilesInHand().at(i);
		if (currTile.IsDouble()) {
			DoubleTiles.push_back(currTile);
		}
	}
	return DoubleTiles;
}

/* *********************************************************************
Function Name: LargestTile
Purpose: Returns largest tile from the vector of tiles passed through.
Parameters: (value) m_tiles, which is a vector of Tiles passed that will be searched through to get its largest Tile.
Return Value: A Tile that is the largest Tile in parameter m_tiles.
Algorithm:  1) Initialize the largestTile Tile variable to the first Tile in parameter m_tiles.
			2) Iterate through each Tile in parameter m_tiles.
				a) If the Tile in question has more total pips (as determined by GetTotalPips) than largestTile, then largestTile is now the current Tile in question.
			3) Return largest Tile.
Assistance Received: None.
********************************************************************* */
Tile CPU::LargestTile(vector<Tile> m_tiles) {
	Tile largestTile = m_tiles.at(0);
	for (int i = 0; i < m_tiles.size(); i++) {
		if (m_tiles.at(i).GetTotalPips() > largestTile.GetTotalPips()) {
			largestTile = m_tiles.at(i);
		}
	}
	return largestTile;
}

/* *********************************************************************
Function Name: SmallestTile
Purpose: Returns smallest tile from the vector of tiles passed through.
Parameters: (value) m_tiles, which is a vector of Tiles passed that will be searched through to get its smallest Tile.
Return Value: A Tile that is the smallest Tile in parameter m_tiles.
Algorithm:  1) Initialize the smallestTile Tile variable to the first Tile in parameter m_tiles.
			2) Iterate through each Tile in parameter m_tiles.
				a) If the Tile in question has more total pips (as determined by GetTotalPips) than smallestTile, then smallestTile is now the current Tile in question.
			3) Return smallest Tile.
Assistance Received: None.
********************************************************************* */
Tile CPU::SmallestTile(vector<Tile> m_tiles) {
	Tile smallestTile = m_tiles.at(0);
	for (int i = 0; i < m_tiles.size(); i++) {
		if (m_tiles.at(i).GetTotalPips() < smallestTile.GetTotalPips()) {
			smallestTile = m_tiles.at(i);
		}
	}
	return smallestTile;
}

/* *********************************************************************
	Function Name: GetStacksOfType
	Purpose: Returns all stacks of type m_color out of the two vectors passed as parameters.
	Parameters: (value) m_humanStacks, an array passed by value. It holds the tiles at the top of the Human's original stacks at the beginning of the Round.
				(value) m_cpuStacks, an array passed by value. It holds the tiles at the top of the CPU's original stacks at the beginning of the Round.
				(value) m_color, a char that should be 'B' or 'W'. Each tile in both stacks will be evaluated based on whether they are color m_color or not.
	Return Value: Deque of tiles that stores the top tiles from m_humanStacks and m_cpuStacks that are the color: m_color.
	Algorithm:  1) Create a vector typeStacks.
				2) Iterate through each tile in m_humanStacks.
				3) If the current tile in consideration returns m_color when GetColor is called, then push it onto typeStacks.
				4) Repeat 2-3 but with m_cpuStacks.
				5) Return typeStacks.
	Assistance Received: None.
	********************************************************************* */
vector<Tile> CPU::GetStacksOfType(vector<Tile> m_humanStacks, vector<Tile> m_cpuStacks, char m_color) {
	vector<Tile> typeStacks;
	// Evaluate all Human's original stacks.
	for (int i = 0; i < 6; i++) {
		if (m_humanStacks.at(i).GetColor() == m_color) {
			typeStacks.push_back(m_humanStacks.at(i));
		}
	}
	// Evaluate all CPU's original stacks
	for (int i = 0; i < 6; i++) {
		if (m_cpuStacks.at(i).GetColor() == m_color) {
			typeStacks.push_back(m_cpuStacks.at(i));
		}
	}
	return typeStacks;
}

/* *********************************************************************
Function Name: HasOppositeToppedStacks
Purpose: Used to search an instance of Tile::ValidStackPlacements() for any m_oppositeColor colored stacks.
Parameters: (value) validStacks, which is a vector of strings found using ValidStackPlacements. This will be searched through for Tiles of m_oppositeColor color
			(value) m_humanStacks, which is a vector of Tiles that should represent the Human's tiles.
			(value) m_cpuStacks, which is a vector of Tiles that should represent the CPU's tiles.
			(value) m_oppositeColor, which is a char that is 'B' or 'W'. Each tile specified by validStacks in m_humanStacks and m_cpuStacks will have their color compared to this parameter.
Return Value: A boolean that is true if there are opposite-topped stacks in validStacks and false if there are not.
Algorithm:  1) Iterate through each string in validStacks.
				a) If the string starts with a B, it is one of the Human's original 6 stacks. If the Tile in m_humanStacks specified by the string in validStacks 
				   has the same color as m_oppositeColor, return true.
				b) If the string starts with a W, it is one of the CPU's original 6 stacks. If the Tile in m_humanStacks specified by the string in validStacks has 
				   the same color as m_oppositeColor, return true.
			2) If no Tile with the color specified by m_oppositeColor is found, return false.
Assistance Received: None.
********************************************************************* */
bool CPU::HasOppositeToppedStacks(vector<string> validStacks, vector<Tile> m_humanStacks, vector<Tile> m_cpuStacks, char m_oppositeColor) {
	// If any of the valid stacks are topped by a Human tile, return true.
	for (int i = 0; i < validStacks.size(); i++) {
		// If the valid stack is one of the Human's original stacks (starts with 'B')...
		if (validStacks.at(i).at(0) == 'B') {
			// If the stack is currently a Human topped stack, return true.
			if (m_humanStacks.at( stoi(validStacks.at(i).substr(1,1)) - 1 ).GetColor() == m_oppositeColor) {
				return true;
			}
		}
		// If the valid stack is one of the CPU's original stacks (starts with 'W')...
		else if (validStacks.at(i).at(0) == 'W') {
			// If the stack is currently a Human topped stack, return true.
			if (m_cpuStacks.at( stoi(validStacks.at(i).substr(1, 1)) - 1 ).GetColor() == m_oppositeColor) {
				return true;
			}
		}
	}
	// If all else fails, this means that there are no Human-topped stacks in validStacks.
	return false;
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
void CPU::DisplayHand() {
	cout << "CPU's hand:" << endl;

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
void CPU::DisplayStacks() {
	cout << "Computer's Stacks:" << endl;
	cout << "\t";
	// SUBMISSION VER:
	for (int i = 0; i < 6; i++) {
		cout << stacks.at(i).ToString() << "\t";
	}
	cout << endl;
	cout << "Stack#:\t";
	// Label stacks as W/B1-6 preceeded with respective color.
	for (int i = 1; i <= 6; i++) {
		cout << "W" << i << "\t";
	}
	cout << endl << endl;
}
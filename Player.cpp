#include "Player.h"

using namespace std;

// Destructor for Player class
Player::~Player() {
	hand.ClearTilesFromHand();
	stacks.clear();
}

/* *********************************************************************
Function Name: AddToBoneyard
Purpose: Adds Tile passed in to the Player's Boneyard.
Parameters: (value) m_tile, the Tile that is pushed back into the Player's Boneyard.
Return Value: None.
Algorithm: N/A
Assistance Received: None.
********************************************************************* */
// Adds tile to boneyard.
void Player::AddToBoneyard(Tile m_tile) {
	boneyard.push_back(m_tile);
}

/* *********************************************************************
Function Name: ClearBoneyard
Purpose: Clears the Player's Boneyard.
Parameters: None.
Return Value: None.
Algorithm: N/A
Assistance Received: None.
********************************************************************* */
void Player::ClearBoneyard() {
	boneyard.clear();
}

/* *********************************************************************
Function Name: ShuffleBoneyard
Purpose: Shuffles the Player's Boneyard
Parameters: None.
Return Value: None.
Algorithm: 1) Create a new vector of Tiles newTiles of the same size as the Player's Boneyard. The Tiles in this new vector will be uninitialized and thus will have total pips of -2.
		   2) For every Tile in the Player's Boneyard:
				a) Calculate a random number between 0 and the number of tiles in the Player's Boneyard m_tiles. Save this number as the random index to place the current Tile in question.
		   3) Determine whether the new vector of Tiles, newTiles, has an uninitialized Tile at the random index created in the previous step.
				a) If the Tile in newTiles at the random index has -2 total pips, it means that the Tile is still uninitialized. Set that Tile equal to the Tile in the Player's Boneyard m_tiles in question.
				b) If the Tile in newTiles at the random index does not have -2 total pips, it means that the Tile is already initialized and was picked previously. Increment the random index by 1. If the random index becomes greater than the size of parameter m_tiles - 1, then set it to 0 to prevent going out of range and repeat step 3).
Assistance Received: None.
********************************************************************* */
void Player::ShuffleBoneyard() {
	vector<Tile> newTiles(boneyard.size());

	for (int i = 0; i < boneyard.size(); i++) {
		int randIdx = rand() % boneyard.size();
		// If element in newTile is empty, fill it in
		if (newTiles.at(randIdx).GetTotalPips() == -2) {
			newTiles.at(randIdx) = boneyard.at(i);
		}
		// Otherwise, try the next index over until an empty tile is found
		else {
			while (true) {
				randIdx++;
				if (randIdx > boneyard.size() - 1) {
					randIdx = 0;
				}
				if (newTiles.at(randIdx).GetTotalPips() == -2) {
					newTiles.at(randIdx) = boneyard.at(i);
					break;
				}
			}
		}
	}

	boneyard = newTiles;
}

/* *********************************************************************
Function Name: InitializeHand
Purpose: Meant to be run at the beginning of a new Hand, it pushes the right amount of tiles from parameter m_boneyard onto its member tiles.
Parameters: (reference) 


m_boneyard, which should be the Black Boneyard or the White Boneyard. Referenced to remove the back tile that was pushed onto Hand's member tiles.
Return Value: None.
Algorithm: 1) Determine how many tiles have to be drawn from parameter m_boneyard.
				a) If the parameter m_boneyard has 21 tiles, then it must be a situation where the Round has started and the first Player has been determined. Draw only 5 tiles.
				a) If the parameter m_boneyard has more than 4 tiles in it, then the current hand is not the fourth. Therefore, take 6 tiles.
				b) If the parameter m_boneyard has only 3 tiles in it, then the current hand is the fourth. Therefore, take only 3 tiles (since a tile was already
					taken by DetermineFirstPlayer when a Hand starts).
			2) For as many tiles that needs to be drawn from parameter m_boneyard, push m_boneyard's back Tile onto Hand, and pop m_boneyard's back.
Assistance Received: None.
********************************************************************* */
void Player::InitializeHand() {
	int tilesDrawn = 0;
	// If the Round just started and the first Player has been determined, then draw only five tiles.
	if (boneyard.size() == 21) {
		tilesDrawn = 5;
	}
	// For any other hand, the boneyard (passed through m_tiles) should have more than 4 tiles.
	else if (boneyard.size() > 4) {
		tilesDrawn = 6;
	}
	// In the last hand, the boneyard will have 3 tiles left (because 1 tile was drawn already to determine the first player), so take only the last 3.
	else if (boneyard.size() == 3) {
		tilesDrawn = 3;
	}
	else {
		cout << "InitializeTiles(): Something is wrong." << endl;
		exit(1);
	}
	// Take the right amount of tiles and remove the tiles from their respective boneyards.
	for (int i = 0; i < tilesDrawn; i++) {
		hand.AddTile(boneyard.back());
		boneyard.pop_back();
	}
}

/* *********************************************************************
Function Name: ClearHand
Purpose: Removes all tiles from member Hand.
Parameters: None.
Return Value: None.
Algorithm: 1) For as many tiles there are in Hand member:
				a) Pop back tile.
Assistance Received: None.
********************************************************************* */
void Player::ClearHand() {
	int numTiles = hand.GetNumTiles();
	for (int i = 0; i < numTiles; i++) {
		hand.PopBackTile();
	}
}

/* *********************************************************************
Function Name: InitializeStack
Purpose: Initializes member stack at the beginning of a Round by taking pushing 6 boneyard tiles and putting them on the Player's stack. Removes those tiles from m_boneyard too.
Parameters: (reference) m_boneyard, a vector of Tiles that represent either the Black or White Boneyard. The back tiles are what are put on the stacks, so they have to be removed.
Return Value: None.
Algorithm: 1) For 6 iterations:
				a) Push the back-most Tile from parameter m_boneyard onto member stacks.
				a) Pop back tile from parameter m_boneyard.
Assistance Received: None.
********************************************************************* */
void Player::InitializeStack() {
	// Clear previous stack, if it exists.
	stacks.clear();
	// CPU and Player take 6 tiles from boneyard to create 6 stacks.
	for (int i = 0; i < 6; i++) {
		stacks.push_back(boneyard.back());
		boneyard.pop_back();
	}
}

/* *********************************************************************
Function Name: CanPlace
Purpose: Determines whether the Player object calling this function can place a tile or not. Once a valid tile is found, it returns true. Useful in determining whether the Player can play a turn or not.
Parameters: (value) m_oppositeStacks, a vector of Tiles that represent the opposite Player's original stacks. Will be used in evaluating whether any of the calling Player's tiles in Hand can be placed on any stack.
Return Value: Returns true if a Tile in member Hand can be placed on any stacks.
Algorithm: 1) For each tile in Hand member:
				a) Evaluate each of the Player's own stacks.
					1) If the Hand Tile in question is a non-double Tile, as long as the Hand Tile has more or equal amount of pips as the stack Tile in question, return true.
					2) If the Hand Tile in question is a double tile and the current stack in question is a non-double, return true. If the current stack in question is a double-tile,
					   return true only if the Hand Tile in question has more pips.
				b) Repeat a) but with parameter m_oppositeStacks.
		   2) If all stacks are evaluated and it still has not returned, return false.
Assistance Received: None.
********************************************************************* */
bool Player::CanPlace(vector<Tile> m_oppositeStacks) {
	// If hand is empty, then Player definitely cannot place.
	if (hand.GetNumTiles() == 0) {
		return false;
	}
	// Evaluate each tile in hand to see if it can be placed on any of player's and opposite's own stacks.
	for (int j = 0; j < hand.GetNumTiles(); j++) {
		Tile currHandTile = hand.GetTiles().at(j);
		// Evaluate own stacks.
		for (int i = 0; i < stacks.size(); i++) {
			Tile topStackTile = stacks.at(i);
			// If the hand tile is non-double and is greater than the top stack tile in question, it can be placed.
			if (!currHandTile.IsDouble() && currHandTile.GetTotalPips() >= topStackTile.GetTotalPips()) {
				return true;
			}
			// Otherwise, if it is a double...
			if (currHandTile.IsDouble()) {
				// A double tile can be placed on any non-double tile, so it can be placed.
				if (!topStackTile.IsDouble()) {
					return true;
				}
				// A double tile with more pips can be placed on another double tile with less pips, so it can be placed.
				else if (currHandTile.GetTotalPips() > topStackTile.GetTotalPips()) {
					return true;
				}
			}
		}
		// Evaluate opposite's stacks to see if any tiles in hand can be placed.
		for (int i = 0; i < m_oppositeStacks.size(); i++) {
			Tile topStackTile = m_oppositeStacks.at(i);
			// If the hand tile is non-double and is greater than the top stack tile in question, it can be placed.
			if (!currHandTile.IsDouble() && currHandTile.GetTotalPips() >= topStackTile.GetTotalPips()) {
				return true;
			}
			if (currHandTile.IsDouble()) {
				// A double tile can be placed on any non-double tile, so it can be placed.
				if (!topStackTile.IsDouble()) {
					return true;
				}
				// A double tile with more pips can be placed on another double tile with less pips, so it can be placed.
				else if (currHandTile.GetTotalPips() > topStackTile.GetTotalPips()) {
					return true;
				}
			}
		}
	}
	// If for any reason, none of the previous conditions are satisfied, then there is no way this tile can be placed.
	return false;
}

/* *********************************************************************
Function Name: AddToHand
Purpose: Adds Tile m_tile in parameter to Hand member's tiles member.
Parameters: (value) m_tile, a Tile object being the Tile to be added to the Player's Hand.
Return Value: None.
Algorithm: N/A
Assistance Received: None.
********************************************************************* */
void Player::AddToHand(Tile m_tile) {
	hand.AddTile(m_tile);
}

/* *********************************************************************
Function Name: RemoveFromHand
Purpose: Removes Tile m_tile in parameter from Hand member's tiles member.
Parameters: (value) m_tile, a Tile object being the Tile to be removed from the Player's Hand.
Return Value: None.
Algorithm: Use RemoveTile to remove parameter m_tileSelected from Hand.
Assistance Received: None.
********************************************************************* */
void Player::RemoveFromHand(Tile m_tileSelected) {
	hand.RemoveTile(m_tileSelected);
}

/* *********************************************************************
Function Name: PlaceOntoStack
Purpose: Sets Player's stacks member at index specified in m_stackSelected parameter to parameter m_tileSelected
Parameters: (value) m_tileSelected, a Tile object that represents the Tile the Player chose to place.
			(value) m_stackSelected, a string that represents the stack that the Player selected to place the Tile on.
Return Value: None.
Algorithm: 1) Take the second character of parameter m_stackSelected and subtract it by 1 to get the correct stack index.
		   2) Set the stacks at that index to the parameter m_tileSelected.
Assistance Received: None.
********************************************************************* */
void Player::PlaceOntoStack(Tile m_tileSelected, string m_stackSelected) {
	// m_stackSelected's second character is an integer between 1-6, so to get the right index, it has to be subtracted by 1.
	stacks.at( stoi(m_stackSelected.substr(1,1)) - 1 ) = m_tileSelected;
}
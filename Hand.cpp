#include "Hand.h"

// Default constructor for Hand class.
Hand::Hand() {
	handNum = -1;
}

// Destructor for Hand class.
Hand::~Hand() {
	tiles.clear();
	handNum = -1;
}

/* *********************************************************************
Function Name: ClearTilesFromHand
Purpose: Used before initialization of Hand and after a Hand ends.
Parameters: None.
Return Value: None.
Algorithm: N/A.
Assistance Received: None.
********************************************************************* */
void Hand::ClearTilesFromHand() {
	tiles.clear();
}

/* *********************************************************************
Function Name: AddTile
Purpose: Pushes Tile m_tile passed into function into member vector tiles.
Parameters: (value) Tile m_tile, the tile that is to be added to Hand's tiles.
Return Value: None.
Algorithm: N/A.
Assistance Received: None.
********************************************************************* */
void Hand::AddTile(Tile m_tile) {
	tiles.push_back(m_tile);
}

/* *********************************************************************
Function Name: RemoveTile
Purpose: Searches member 
tiles to find and remove tile equivalent to parameter m_tile.
Parameters: (value) Tile m_tile, the tile that is to be removed from Hand's tiles.
Return Value: None.
Algorithm: 1) Iterate through each Tile in member vector tiles.
				a) If the Tile in question is the same as parameter m_tile, remove that Tile from member vector tiles and return
		   2) If m_tile isn't found in tiles, then let the Human know and return.
Assistance Received: None.
********************************************************************* */
void Hand::RemoveTile(Tile m_tile) {
	// Search all tiles in hand.
	for (int i = 0; i < tiles.size(); i++) {
		// If there is a match, remove it from tiles and end the loop since there should not be duplicates.
		if (tiles.at(i) == m_tile) {
			tiles.erase(tiles.begin() + i);
			return;
		}
	}
	// If the m_tile isn't found in tiles, let the Human know.
	cout << "RemoveTile(): tile " << m_tile.ToString() << " not found." << endl;
}

/* *********************************************************************
	Function Name: PopBackTile
	Purpose: Removes back tile from member tiles. Used for clearing the vector.
	Parameters: None.
	Return Value: None.
	Algorithm: 1) Iterate through each Tile in member vector tiles.
					a) Pop back tile.
	Assistance Received: None.
	********************************************************************* */
void Hand::PopBackTile() {
	tiles.pop_back();
}
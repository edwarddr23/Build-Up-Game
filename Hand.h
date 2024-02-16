#pragma once
#include <vector>
#include <iostream>
#include "Tile.h"

using namespace std;

class Hand {
public:
	// Default constructor for Hand class.
	Hand();

	// Destructor for Hand class.
	~Hand();

	// Equals operator overload so that the tiles and handNum are transferred between Hands.
	void operator = (const Hand& rightHand) {
		tiles = rightHand.tiles;
		handNum = rightHand.handNum;
	}

	/* *********************************************************************
	Function Name: GetNumTiles
	Purpose: Accessor that returns the number of tiles in Hand.
	Parameters: None.
	Return Value: The number of Tiles in member 
	
	tiles.
	Algorithm: N/A.
	Assistance Received: None.
	********************************************************************* */
	const int GetNumTiles() { return tiles.size(); };

	/* *********************************************************************
	Function Name: GetHandNum
	Purpose: Accessor that returns the Hand's handNum member variable value.
	Parameters: None.
	Return Value: The value of this object's handNum value.
	Algorithm: N/A.
	Assistance Received: None.
	********************************************************************* */
	const int GetHandNum() { return handNum; };

	/* *********************************************************************
	Function Name: GetTiles
	Purpose: Accessor that returns the Hand's vector member, tiles.
	Parameters: None.
	Return Value: The value of this object's handNum value.
	Algorithm: N/A.
	Assistance Received: None.
	********************************************************************* */
	const vector<Tile> GetTiles() { return tiles; };

	/* *********************************************************************
	Function Name: SetHandNum
	Purpose: Mutator that sets the hand number to the int passed through it.
	Parameters: (value) m_handNum, an int passed that member variable handNum is set equivalent to.
	Return Value: None.
	Algorithm: N/A.
	Assistance Received: None.
	********************************************************************* */
	void SetHandNum(int m_handNum) { handNum = m_handNum; };

	/* *********************************************************************
	Function Name: ClearTilesFromHand
	Purpose: Used before initialization of Hand and after a Hand ends.
	Parameters: None.
	Return Value: None.
	Algorithm: N/A.
	Assistance Received: None.
	********************************************************************* */
	void ClearTilesFromHand();

	/* *********************************************************************
	Function Name: AddTile
	Purpose: Pushes Tile m_tile passed into function into member vector tiles.
	Parameters: (value) Tile m_tile, the tile that is to be added to Hand's tiles.
	Return Value: None.
	Algorithm: N/A.
	Assistance Received: None.
	********************************************************************* */
	void AddTile(Tile m_tile);

	/* *********************************************************************
	Function Name: RemoveTile
	Purpose: Searches member vector tiles to find and remove tile equivalent to parameter m_tile.
	Parameters: (value) Tile m_tile, the tile that is to be removed from Hand's tiles.
	Return Value: None.
	Algorithm: 1) Iterate through each Tile in member vector tiles.
					a) If the Tile in question is the same as parameter m_tile, remove that Tile from member vector tiles and return
			   2) If m_tile isn't found in tiles, then let the Human know and return.
	Assistance Received: None.
	********************************************************************* */
	void RemoveTile(Tile m_tile);

	/* *********************************************************************
	Function Name: PopBackTile
	Purpose: Removes back tile from member tiles. Used for clearing the vector.
	Parameters: None.
	Return Value: None.
	Algorithm: 1) Iterate through each Tile in member vector tiles.
					a) Pop back tile.
	Assistance Received: None.
	********************************************************************* */
	void PopBackTile();

private:
	// Tiles in hand.
	vector<Tile> tiles;
	// Specifies the hand number.
	int handNum;
};
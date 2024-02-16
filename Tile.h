#pragma once

#include <stdio.h>
#include <vector>
#include <string>
#include <sstream>
using namespace std;

class Tile {
public:
	// Default constructor used to make sure initialization is correct.
	Tile(); 

	// Constructor for concise Tile creation.
	Tile(char m_color, int m_leftPips, int m_rightPips);

	// Destructor unnecessary for Tile class since all members are primitive datatypes.

	// Assignemnt operator overloader.
	void operator = (const Tile& rightTile) {
		color = rightTile.color;
		leftPips = rightTile.leftPips;
		rightPips = rightTile.rightPips;
	}

	// Equivalancy operator constructor. Returns true if the color and left and right pips are the same.
	bool operator == (const Tile& rightTile) {
		if (color == rightTile.color
			&& leftPips == rightTile.leftPips
			&& rightPips == rightTile.rightPips) {
			return true;
		}
		return false;
	}

	/* *********************************************************************
	Function Name: GetColor
	Purpose: Accessor for Tile's member color.
	Parameters: None.
	Return Value: Returns the Tile's member color.
	Algorithm: N/A.
	Assistance Received: None.
	********************************************************************* */
	char GetColor() { return color; };

	/* *********************************************************************
	Function Name: GetTotalPips
	Purpose: Accessor for Tile's total pips.
	Parameters: None.
	Return Value: Returns the Tile's total pips.
	Algorithm: N/A.
	Assistance Received: None.
	********************************************************************* */
	int GetTotalPips() { return leftPips + rightPips; };

	/* *********************************************************************
	Function Name: ValidStackPlacements
	Purpose: Used to find all of the stacks the calling Tile object can be placed on.
	Parameters: (value) m_humanStacks, a vector of Tiles that represents the Human's original stacks. Searched to find valid stacks the calling Tile object can be placed on.
				(value) m_cpuStacks, a vector of Tiles that represents the CPU's original stacks. Searched to find valid stacks the calling Tile object can be placed on.
	Return Value: Returns all of the stacks the calling Tile object can be placed on.
	Algorithm: 1) Create a vector of strings validStacks to store all of the stacks the calling Tile object can be placed on.
			   2) Iterate through each of the Tile on stacks in parameter m_humanStacks.
					a) If the calling Tile object is a non-double Tile and its total pips are greater or equal than the current stack Tile in question, then push the current stack onto validStacks.
					b) If the calling Tile object is a double-tile.
						A) If the current stack Tile in question is a non-double, then push the current stack onto validStacks.
						B) If the current stack Tile in question is a double, then if the calling Tile object has more pips than the current stack Tile, push th  current stack onto validStacks.
			   3) Repeat step 2) but with parameter m_cpuStacks instead.
			   4) Return the vector validStacks.
	Assistance Received: None.
	********************************************************************* */
	vector<string> ValidStackPlacements(vector<Tile> m_humanStacks, vector<Tile> m_cpuStacks);

	/* *********************************************************************
	Function Name: IsDouble
	Purpose: Used to find whether the Tile object is a double-tile or not.
	Parameters: None.
	Return Value: Returns true if it's a double-tile, and false if it's a non-double Tile.
	Algorithm: 1) Compare the calling Tile object's members leftPips and rightPips.
					a) If they are equal, then the calling Tile object is a double, return true.
					b) Otherwise, then the callign Tile object is a non-double, return false.
	Assistance Received: None.
	********************************************************************* */
	bool IsDouble();

	/* *********************************************************************
	Function Name: ToString
	Purpose: Used to convert the calling Tile object to a string.
	Parameters: None.
	Return Value: Returns a string that shows the Tile's color, left pips, and right pips in format (char)(int)(int).
	Algorithm: N/A
	Assistance Received: None.
	********************************************************************* */
	string ToString();

private:
	// Color of Tile.
	char color;
	// Left pips on Tile.
	int leftPips;
	// Right pips on Tile.
	int rightPips;
};
#include <iostream>
#include "Tile.h"

// Default constructor used to make sure initialization is correct.
Tile::Tile() {
	color = '\0';
	leftPips = -1;
	rightPips = -1;
}

// Constructor for concise Tile creation.
Tile::Tile(char m_color, int m_leftPips, int m_rightPips) {
	color = m_color;
	leftPips = m_leftPips;
	rightPips = m_rightPips;
}

/* *********************************************************************
Function Name: ValidStackPlacements
Purpose: Used to find all of the stacks the calling Tile object can be placed on.
Parameters: (value) m_humanStacks, a 
of Tiles that represents the Human's original stacks. Searched to find valid stacks the calling Tile object can be placed on.
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
vector<string> Tile::ValidStackPlacements(vector<Tile> m_humanStacks, vector<Tile> m_cpuStacks){
	vector<string> validStacks;
	// Evaluate Human stacks.
	for (int i = 0; i < m_humanStacks.size(); i++) {
		// Since it is a Human stack in question, it must start with "B"
		string stack = "B";
		// If the hand tile is non-double and is greater than or equal to the top stack tile in question, it can be placed.
		if (!this->IsDouble() && this->GetTotalPips() >= m_humanStacks.at(i).GetTotalPips()) {
			validStacks.push_back(stack + to_string(i + 1));
		}
		// Otherwise, if it is a double...
		if (this->IsDouble()) {
			// A double tile can be placed on any non-double tile, so it can be placed.
			if (!m_humanStacks.at(i).IsDouble()) {
				validStacks.push_back(stack + to_string(i + 1));
			}
			// A double tile with more pips can be placed on another double tile with less pips, so it can be placed.
			else if (this->GetTotalPips() > m_humanStacks.at(i).GetTotalPips()) {
				validStacks.push_back(stack + to_string(i + 1));
			}
		}
	}
	// Evaluate CPU stacks.
	for (int i = 0; i < m_cpuStacks.size(); i++) {
		// Since it is a CPU stack in question, it must start with "W"
		string stack = "W";
		// If the hand tile is non-double and is greater than the top stack tile in question, it can be placed.
		if (!this->IsDouble() && this->GetTotalPips() >= m_cpuStacks.at(i).GetTotalPips()) {
			validStacks.push_back(stack + to_string(i + 1));
		}
		// Otherwise, if it is a double...
		if (this->IsDouble()) {
			// A double tile can be placed on any non-double tile, so it can be placed.
			if (!m_cpuStacks.at(i).IsDouble()) {
				validStacks.push_back(stack + to_string(i + 1));
			}
			// A double tile with more pips can be placed on another double tile with less pips, so it can be placed.
			else if (this->GetTotalPips() > m_cpuStacks.at(i).GetTotalPips()) {
				validStacks.push_back(stack + to_string(i + 1));
			}
		}
	}
	return validStacks;
}

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
bool Tile::IsDouble() {
	if (leftPips == rightPips) {
		return true;
	}
	else {
		return false;
	}
}

/* *********************************************************************
Function Name: ToString
Purpose: Used to convert the calling Tile object to a string.
Parameters: None.
Return Value: Returns a string that shows the Tile's color, left pips, and right pips in format (char)(int)(int).
Algorithm: N/A
Assistance Received: None.
********************************************************************* */
string Tile::ToString() {
	stringstream ss;
	ss << color << leftPips << rightPips;
	return ss.str();
}
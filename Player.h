#pragma once
#include <iostream>
#include "Hand.h"

using namespace std;

class Player {
public:
	// Constructor for Player class unnecessary.

	// Destructor for Player class
	~Player();

	// Assignment operator overloader.
	void operator = (const Player& rightPlayer) {
		// Set hands equal.
		hand = rightPlayer.hand;
		// Set stacks equal.
		stacks = rightPlayer.stacks;
		// Set boneyards equal.
		boneyard = rightPlayer.boneyard;
	}

	/* *********************************************************************
	Function Name: GetHand
	Purpose: Accessor for the hand of Player.
	Parameters: None.
	Return Value: Returns Player's Hand member.
	Algorithm: N/A
	Assistance Received: None.
	********************************************************************* */
	const Hand GetHand() { return hand; };

	/* *********************************************************************
	Function Name: GetTilesInHand
	Purpose: Accessor for all Tiles in Hand.
	Parameters: None.
	Return Value: Returns all Tiles in Player's Hand member.
	Algorithm: N/A
	Assistance Received: None.
	********************************************************************* */
	const vector<Tile> GetTilesInHand() { return hand.GetTiles(); };

	/* *********************************************************************
	Function Name: GetStacks
	Purpose: Accessor for the stacks of Player.
	Parameters: None.
	Return Value: Returns Player's stacks member.
	Algorithm: N/A
	Assistance Received: None.
	********************************************************************* */
	const vector<Tile> GetStacks() { return stacks; };

	/* *********************************************************************
	Function Name: GetHandSize
	Purpose: Accessor for the Hand member's size.
	Parameters: None.
	Return Value: Returns the number of Tiles in Hand member.
	Algorithm: N/A
	Assistance Received: None.
	********************************************************************* */
	const int GetHandSize() { return hand.GetNumTiles(); };

	/* *********************************************************************
	Function Name: GetHandNumber
	Purpose: Accessor for the Hand member's number.
	Parameters: None.
	Return Value: Returns the Hand member's number.
	Algorithm: N/A
	Assistance Received: None.
	********************************************************************* */
	const int GetHandNumber() { return hand.GetHandNum(); };

	/* *********************************************************************
	Function Name: GetBoneyard
	Purpose: Accessor for the Player's Boneyard.
	Parameters: N/A.
	Return Value: Returns the Player's boneyard vector by value.
	Algorithm: N/A.
	Assistance Received: None.
	********************************************************************* */
	const vector<Tile> GetBoneyard() { return boneyard; };

	/* *********************************************************************
	Function Name: PrintBoneyard
	Purpose: Virtual function that both the CPU and Human class must perform, but differently.
	Parameters: N/A.
	Return Value: None.
	Algorithm: N/A.
	Assistance Received: None.
	********************************************************************* */
	virtual void PrintBoneyard() {};

	/* *********************************************************************
	Function Name: SetHand
	Purpose: Mutator for the hand of Player.
	Parameters: (value) m_hand, a Hand object that this Player object's Hand member should be set to.
	Return Value: None.
	Algorithm: N/A
	Assistance Received: None.
	********************************************************************* */
	void SetHand(Hand m_hand) { hand = m_hand; };

	/* *********************************************************************
	Function Name: SetStacks
	Purpose: Mutator for stacks of Player.
	Parameters: (value) m_stacks, a vector of Tiles that this Player object's stacks member should be set to.
	Return Value: None.
	Algorithm: N/A
	Assistance Received: None.
	********************************************************************* */
	void SetStacks(vector<Tile> m_stacks) { stacks = m_stacks; };

	/* *********************************************************************
	Function Name: SetHandNumber
	Purpose: Mutator for the Hand member's number.
	Parameters: (value) m_handNum, an int that this Player object's Hand member's number should be set to.
	Return Value: None.
	Algorithm: N/A
	Assistance Received: None.
	********************************************************************* */
	void SetHandNumber(int m_handNum) { hand.SetHandNum(m_handNum); };

	/* *********************************************************************
	Function Name: PopBoneyardBack
	Purpose: Pops PLayer's boneyard's back.
	Parameters: None.
	Return Value: None.
	Algorithm: N/A
	Assistance Received: None.
	********************************************************************* */
	void PopBoneyardBack() { boneyard.pop_back(); };


	/* *********************************************************************
	Function Name: AddToBoneyard
	Purpose: Adds Tile passed in to the Player's Boneyard.
	Parameters: (value) m_tile, the Tile that is pushed back into the Player's Boneyard.
	Return Value: None.
	Algorithm: N/A
	Assistance Received: None.
	********************************************************************* */
	void AddToBoneyard(Tile m_tile);

	/* *********************************************************************
	Function Name: ClearBoneyard
	Purpose: Clears the Player's Boneyard.
	Parameters: None.
	Return Value: None.
	Algorithm: N/A
	Assistance Received: None.
	********************************************************************* */
	void ClearBoneyard();

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
	void ShuffleBoneyard();

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
	void InitializeHand();

	/* *********************************************************************
	Function Name: ClearHand
	Purpose: Removes all tiles from member Hand.
	Parameters: None.
	Return Value: None.
	Algorithm: 1) For as many tiles there are in Hand member:
					a) Pop back tile.
	Assistance Received: None.
	********************************************************************* */
	void ClearHand();

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
	void InitializeStack();

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
	bool CanPlace(vector<Tile> m_oppositeStacks);

	/* *********************************************************************
	Function Name: DisplayStacks
	Purpose: Displays Player's stacks for UI. Derived from Player class.
	Parameters: None.
	Return Value: None.
	Algorithm: N/A
	Assistance Received: None.
	********************************************************************* */
	void DisplayStacks(char m_color);

	/* *********************************************************************
	Function Name: AddToHand
	Purpose: Adds Tile m_tile in parameter to Hand member's tiles member.
	Parameters: (value) m_tile, a Tile object being the Tile to be added to the Player's Hand.
	Return Value: None.
	Algorithm: N/A
	Assistance Received: None.
	********************************************************************* */
	void AddToHand(Tile m_tile);

	/* *********************************************************************
	Function Name: RemoveFromHand
	Purpose: Removes Tile m_tile in parameter from Hand member's tiles member.
	Parameters: (value) m_tile, a Tile object being the Tile to be removed from the Player's Hand.
	Return Value: None.
	Algorithm: Use RemoveTile to remove parameter m_tileSelected from Hand.
	Assistance Received: None.
	********************************************************************* */
	void RemoveFromHand(Tile m_tileSelected);

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
	void PlaceOntoStack(Tile m_tileSelected, string m_stackSelected);

	/* *********************************************************************
	Function Name: DisplayHand
	Purpose: Displays Hand of Player for UI or debugging purposes.
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
	virtual void DisplayHand() {};

	/* *********************************************************************
	Function Name: DisplayStacks
	Purpose: Displays Player's stacks for UI. Derived from Player class.
	Parameters: None.
	Return Value: None.
	Algorithm: N/A
	Assistance Received: None.
	********************************************************************* */
	virtual void DisplayStacks() {};

protected:
	// Hand of Player.
	Hand hand;
	// Player's original 6 stacks.
	vector<Tile> stacks;
	// Player's Boneyard.
	vector<Tile> boneyard;
};
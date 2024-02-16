#pragma once
#include <iostream>
#include "Player.h"

using namespace std;

class CPU : public Player {
public:
	// Destructor unnecessary for CPU, inherits from Player class.

	/* *********************************************************************
	Function Name: PrintBoneyard
	Purpose: Prints the CPU's Boneyard, interited from Player.
	Parameters: N/A.
	Return Value: None.
	Algorithm: N/A.
	Assistance Received: None.
	********************************************************************* */
	void PrintBoneyard();

	/* *********************************************************************
	Function Name: GetReasoning
	Purpose: Accessor that sets the reasoning number to print the CPU's reasoning behind its tile and stack picks for the Human.
	Parameters: N/A.
	Return Value: The number that corresponds to a specific reason the CPU chose its tile and stack placement. See PrintReasoning for details.
	Algorithm: N/A.
	Assistance Received: None.
	********************************************************************* */
	const int GetReasoning() { return reasoning; };

	/* *********************************************************************
	Function Name: SetReasoning
	Purpose: Mutator that sets reasoning number.
	Parameters: m_reasoning, an integer that corresponds to a specific reason the CPU chose its tile and stack placement. See PrintReasoning for details.
	Return Value: None.
	Algorithm: Set this CPU object's reasoning member variable to the value stored in m_reasoning.
	Assistance Received: None.
	********************************************************************* */
	void SetReasoning(int m_reasoning) { reasoning = m_reasoning; }

	/* *********************************************************************
	Function Name: PrintReasoning
	Purpose: Prints the specific reasoning behind the CPU's tile selection and stack placement based on what the CPU object's reasoning member variable is set to.
	Parameters: m_tileSelected, a tile that should be the optimal tile the CPU chose using OptimalHandTile which is used to output its tile choice for the Human.
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
	void PrintReasoning(Tile m_tileSelected);

	/* *********************************************************************
	Function Name: PrintHelpReasoning
	Purpose: Function is to be used by a helpCPU object created in the Human class. Using the same algorithms the enemy CPU uses to pick the optimal tile in hand and stack to place on against
			 the Human, the helpCPU instance is supposed to print a slightly different output with this function than with PrintReasoning since it is now suggesting an optimal tile in hand
			 and stack placement for the Human.
	Parameters: m_tileSelected, a tile that should be the optimal tile the helpCPU chose using OptimalHandTile which is used to output its tile choice for the Human.
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
	void PrintHelpReasoning(Tile m_tileSelected, string m_stackSelected, bool m_tileChosen);

	/* *********************************************************************
	Function Name: OptimalHandTile
	Purpose: Returns the optimal Tile in Hand to place.
	Parameters: m_oppositeStacks, a vector that should be the opposite stack from the calling Player (helpCPU or CPU).
				m_oppositeColor, a char that should be the opposite color form the calling Player (helpCPU or CPU).
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
	Tile OptimalHandTile(vector<Tile> m_oppositeStacks, char m_oppositeColor);

	/* *********************************************************************
	Function Name: OptimalStackPlacement
	Purpose: Returns the optimal stack placement.
	Parameters: m_tileSelected, a tile that should be the optimal tile the helpCPU chose using OptimalHandTile which is used to output its tile choice for the Human.
				m_oppositeStacks, a vector that should be the opposite stack from the calling Player (helpCPU or CPU).
				m_oppositeColor, a char that should be the opposite color form the calling Player (helpCPU or CPU).
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
	string OptimalStackPlacement(Tile m_tileSelected, vector<Tile> m_oppositeStacks, char m_oppositeColor);

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
	vector<Tile> NonDoubleTilesInHand();

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
	vector<Tile> DoubleTilesInHand();

	/* *********************************************************************
	Function Name: LargestTile
	Purpose: Returns largest tile from the vector of tiles passed through.
	Parameters: m_tiles, which is a vector of Tiles passed that will be searched through to get its largest Tile.
	Return Value: A Tile that is the largest Tile in parameter m_tiles.
	Algorithm:  1) Initialize the largestTile Tile variable to the first Tile in parameter m_tiles.
				2) Iterate through each Tile in parameter m_tiles.
					a) If the Tile in question has more total pips (as determined by GetTotalPips) than largestTile, then largestTile is now the current Tile in question.
				3) Return largest Tile.
	Assistance Received: None.
	********************************************************************* */
	Tile LargestTile(vector<Tile> m_tiles);

	/* *********************************************************************
	Function Name: SmallestTile
	Purpose: Returns smallest tile from the vector of tiles passed through.
	Parameters: m_tiles, which is a vector of Tiles passed that will be searched through to get its smallest Tile.
	Return Value: A Tile that is the smallest Tile in parameter m_tiles.
	Algorithm:  1) Initialize the smallestTile Tile variable to the first Tile in parameter m_tiles.
				2) Iterate through each Tile in parameter m_tiles.
					a) If the Tile in question has more total pips (as determined by GetTotalPips) than smallestTile, then smallestTile is now the current Tile in question.
				3) Return smallest Tile.
	Assistance Received: None.
	********************************************************************* */
	Tile SmallestTile(vector<Tile> m_tiles);

	/* *********************************************************************
	Function Name: GetStacksOfType
	Purpose: Returns all stacks of type m_color out of the two vectors passed as parameters.
	Parameters: m_humanStacks, an array passed by value. It holds the tiles at the top of the Human's original stacks at the beginning of the Round.
				m_cpuStacks, an array passed by value. It holds the tiles at the top of the CPU's original stacks at the beginning of the Round.
				m_color, a char that should be 'B' or 'W'. Each tile in both stacks will be evaluated based on whether they are color m_color or not.
	Return Value: Deque of tiles that stores the top tiles from m_humanStacks and m_cpuStacks that are the color: m_color.
	Algorithm:  1) Create a vector typeStacks.
				2) Iterate through each tile in m_humanStacks.
				3) If the current tile in consideration returns m_color when GetColor is called, then push it onto typeStacks.
				4) Repeat 2-3 but with m_cpuStacks.
				5) Return typeStacks.
	Assistance Received: None.
	********************************************************************* */
	vector<Tile> GetStacksOfType(vector<Tile> m_humanStacks, vector<Tile> m_cpuStacks, char m_color);

	/* *********************************************************************
	Function Name: HasOppositeToppedStacks
	Purpose: Used to search an instance of Tile::ValidStackPlacements() for any m_oppositeColor colored stacks.
	Parameters: validStacks, which is a vector of strings found using ValidStackPlacements. This will be searched through for Tiles of m_oppositeColor color
				m_humanStacks, which is a vector of Tiles that should represent the Human's tiles.
				m_cpuStacks, which is a vector of Tiles that should represent the CPU's tiles.
				m_oppositeColor, which is a char that is 'B' or 'W'. Each tile specified by validStacks in m_humanStacks and m_cpuStacks will have their color compared to this parameter.
	Return Value: A boolean that is true if there are opposite-topped stacks in validStacks and false if there are not.
	Algorithm:  1) Iterate through each string in validStacks.
					a) If the string starts with a B, it is one of the Human's original 6 stacks. If the Tile in m_humanStacks specified by the string in validStacks
					   has the same color as m_oppositeColor, return true.
					b) If the string starts with a W, it is one of the CPU's original 6 stacks. If the Tile in m_humanStacks specified by the string in validStacks has
					   the same color as m_oppositeColor, return true.
				2) If no Tile with the color specified by m_oppositeColor is found, return false.
	Assistance Received: None.
	********************************************************************* */
	bool HasOppositeToppedStacks(vector<string> validStacks, vector<Tile> m_humanStacks, vector<Tile> m_cpuStacks, char m_oppositeColor);

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
	void DisplayHand();

	/**********************************************************************
	Function Name : DisplayStacks
	Purpose : Displays Player's stacks for UI. Derived from Player class.
	Parameters : None.
	Return Value : None.
	Algorithm : N / A
	Assistance Received : None.
	* *********************************************************************/
	void DisplayStacks();

private:
	// Reason (0-4) for picking the Tile and Stack specified in OptimalHandTile and OptimalStackPlacement.
	int reasoning;
};
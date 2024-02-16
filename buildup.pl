% *********************************************
% Source Code to allow the Human to choose whether to start a new game or restore from an old one.
% *********************************************

% *********************************************************************
% Rule Name: newGameQuery
% Purpose: Asks whether the Human wants to start a new game (input = 'y') or restore an old game (input = 'n').
% Parameters: 
%       Input, should be a symbol that represents what the Human inputted. Passed in as an empty variable.
% 		Err, a Catcher that records the error thrown from read().
% Algorithm: 
% 		1) Evaluate Input.
% 			a) If Input is y and Err is a free variable, then the Human wants to start a new Tournament. Run startTournament().
% 			b) If Input is n and Err is a free variable, then the Human wants to restore a previous game. Use findSaveFile() to try and get a save file from the Human. If the Human cancels, ask again for another input and recursively call newGameQuery() to evaluate the input.
% 			c) If INput is anything else, let the Human know that the input is invalid and that they must input a y or n. Ask for another input and recursively call newGameQuery() to evaluate the input.
% Assistance Received: catch() learned from: https://stackoverflow.com/questions/2396187/prolog-error-catching.
% *********************************************************************
% If the Human wants to start a new game, startTournament() is called.
newGameQuery(y, Err) :-
	% Check to make sure read() did not fail.
	var(Err),
	startTournament().
% If the Human wants to load from a file, let them input a save file and try to find it.
newGameQuery(n, Err) :-
	% Check to make sure read() did not fail.
	var(Err),
	findSaveFile(SaveFileName, false),
	% If the code reaches this point, it means that the Human did not want to find a save file, so ask again whether they want to start a new game or not.
	write('Do you want to start a new game (y) or restore an old one (n)?:\n'),
	catch(read(Input), error(NewErr, _Context), write('Invalid Format: Input reading failed.\n')),
	newGameQuery(Input, NewErr).
% If the Human puts an invalid input, tell them it is invalid and ask for another input.
newGameQuery(_, _) :-
	write('Invalid input. Please enter either a \"y\" or \"n\".\n'),
	write('Do you want to start a new game (y) or restore an old one (n)?:\n'),
	catch(read(Input), error(NewErr, _Context), write('Invalid Format: Input reading failed.\n')),
	newGameQuery(Input, NewErr).

% *********************************************************************
% Rule Name: startTournament
% Purpose: Starts a new Tournament by initializing a first Round and then plays it.
% Parameters: None.
% Algorithm: 
% 		1) Use initRound() to initialize a new Round and get the resulting Boneyards, Stacks, and the first Player.
% 		2) Use playRound() using the variables extracted from initRound() to play the Round.
% Assistance Received: None.
% *********************************************************************
startTournament() :-
	write('Starting New Tournament!\n'),
	initRound(WhiteBoneyard, BlackBoneyard, CPUStacks, HumanStacks, FirstPlayer),
	playRound(false, 1, WhiteBoneyard, BlackBoneyard, CPUStacks, HumanStacks, CPUHand, HumanHand, 0, 0, 0, 0, FirstPlayer, 1).

% *********************************************
% Source Code to initialize everything for a Round.
% *********************************************

% *********************************************************************
% Rule Name: initRound
% Purpose: Initializes everything for a Round.
% Parameters:
% 		WhiteBoneyard, a list that represents the CPU's Boneyard. Passed in as an empty variable.
% 		BlackBoneyard, a list that represents the Human's Boneyard. Passed in as an empty variable.
% 		CPUStacks, a list that represents the CPU's original 6 Stacks. Passed in as an empty variable.
% 		HumanStacks, a list that represents the Human's original 6 Stacks. Passed in as an empty variable.
% 		FirstPlayer, a string that represents the first Player in the Round. Passed in as an empty variable.
% Algorithm: 
% 		1) Initialize the Boneyards using initBoneyard() and store the resulting lists into InitWhiteBoneyard and InitBlackBoneyard.
% 		2) Shuffle both of the initial Boneyards using random_permutation and store them into ShuffledWhiteBoneyard and ShuffledBlackBoneyard.
% 		3) Initialize the Players' Stacks using initStacks() and passing in the shuffled Boneyard. Store the resulting Stacks into CPUStacks and HumanStacks.
% 		4) Remove the first 6 Tiles from the shuffled Boneyards using trim() to reflect the change. Store the resulting Boneyards into TrimWhiteBoneyard and TrimBlackBoneyard.
% 		5) Determine the first Player with the rest of the Boneyards using determineFirstPlayer and store the resulting Boneyards into parameters WhiteBoneyard and BlackBoneyard, and the first Player into parameter FirstPlayer.
% Assistance Received: None.
% *********************************************************************
initRound(WhiteBoneyard, BlackBoneyard, CPUStacks, HumanStacks, FirstPlayer) :-
	% Initialize the Players' Boneyards.
	initBoneyard(InitWhiteBoneyard, w, 0, 0),
	initBoneyard(InitBlackBoneyard, b, 0, 0),

	% Shuffle the Boneyards.
	random_permutation(InitWhiteBoneyard, ShuffledWhiteBoneyard),
	random_permutation(InitBlackBoneyard, ShuffledBlackBoneyard),

	% Initialize the Stacks.
	initStacks(ShuffledWhiteBoneyard, CPUStacks, 0),
	initStacks(ShuffledBlackBoneyard, HumanStacks, 0),
	% Trim the Boneyards to reflect how their Tiles were put into the Stacks.
	trim(ShuffledWhiteBoneyard, TrimWhiteBoneyard, 0, 6),
	trim(ShuffledBlackBoneyard, TrimBlackBoneyard, 0, 6),
	
	% Let the CPU and Human draw from their respective Boneyards.
	write('___________________________________________________\n\n'),
	% Determine the first Player.
	determineFirstPlayer(TrimWhiteBoneyard, TrimBlackBoneyard, WhiteBoneyard, BlackBoneyard, FirstPlayer),
	write(FirstPlayer), write(' goes first!\n'),
	write('___________________________________________________\n\n').

% *********************************************************************
% Rule Name: initBoneyard
% Purpose: Initializes all Tiles in a Boneyard with the color passed in.
% Parameters:
% 		AccumBoneyard, a list that represents the accumulated list that is the Boneyard.
% 		Color, a symbol that reprsents the color that the Tiles in the Boneyard should be.
% 		LeftPips, an integer that represents the left pips of the current Tile in the Boneyard. Should start at 0.
% 		RightPips, an integer that represents the right pips of the current Tile in the Boneyard. Should start at 0.
% Algorithm: 
% 		1) Evaluate the RightPips.
% 			a) If RightPips is less than 6, then put the Color, LeftPips, and RightPips into a list CurrTile that represents the current Tile in question. Set NewRightPips to an incremented RightPips. Recursively call initBoneyard() with everythign constant except with NewAccumBoneyard and NewRightPips. Then set AccumBoneyard to an appended list with CurrTile prepended to the resulting NewAccumBoneyard.
% 			b) If RightPips equals 6, put the Color, LeftPips, and RightPips into a list CurrTile that represents the current Tile in question. Set NewLeftPips to an incremented LeftPips. Recursively call initBoneyard with everything constant except for NewAccumBoneyard and passing in NewLeftPips for both the LeftPips and RightPips parameters. Then set AccumBoneyard to an appended list with CurrTile prepended to the resulting NewAccumBoneyard.
% 			c) If LeftPips and RightPips are 6, then make the first Tile with the Color and 6 as the left pips and the right pips of list CurrTile. Set parameter AccumBoneyard to a list that holds CurrTile.
% Assistance Received: None.
% *********************************************************************
% If this is the last Tile to add where the left and right pips are both 6, then it is the base case. Make the initial list a single Tile.
initBoneyard(AccumBoneyard, Color, 6, 6) :- 
	% Take the color and pips passed in and put it into a Tile format.
	append([Color], [6, 6], CurrTile),
	AccumBoneyard = [CurrTile].
% If Right Pips is less than 6, keep incrementing RightPips and keep LeftPips as is so a Tile isn't skipped.
initBoneyard(AccumBoneyard, Color, LeftPips, RightPips) :-
	RightPips < 6,
	% Take the color and pips passed in and put it into a Tile format.
	append([Color], [LeftPips, RightPips], CurrTile),
	NewRightPips is RightPips + 1,
	initBoneyard(NewAccumBoneyard, Color, LeftPips, NewRightPips),
	% Accumulate the list into AccumBoneyard, where we prepend the current Tile to the NewAccumBoneyard taken from the recursive call.
	AccumBoneyard = [CurrTile | NewAccumBoneyard].
% If this is not the first Tile, the left and right pips are not 6 and 6, and Right Pips equal 6, increment LeftPips and set RightPips equal to that.
initBoneyard(AccumBoneyard, Color, LeftPips, RightPips) :-
	RightPips == 6,
	% Take the color and pips passed in and put it into a Tile format.
	append([Color], [LeftPips, RightPips], CurrTile),
	NewLeftPips is LeftPips + 1,
	initBoneyard(NewAccumBoneyard, Color, NewLeftPips, NewLeftPips),
	% Accumulate the list into AccumBoneyard, where we prepend the current Tile to the NewAccumBoneyard taken from the recursive call.
	AccumBoneyard = [CurrTile | NewAccumBoneyard].

% *********************************************************************
% Rule Name: initStacks
% Purpose: Initializes the Stacks at the beginning of a Round using the Boneyard passed in.
% Parameters:
% 		Boneyard, a list that represents one of the Player's Boneyard.
% 		Stacks, a list that represents one of the Player's Stacks. Passed in as an empty variable.
% 		Counter, an int that represents how many iterations initStacks() has gone through. Assumed that it starts at 0.
% Algorithm: 
% 		1) Evaluate Counter.
% 			a) If the counter is less than 5, then split the Boneyard into a first element CurrTile and put the rest into Rest. Set NewCounter to an incremented Counter. Recursively call initStacks() and pass in Rest for the Boneyard, empty variable NewStacks, and the NewCounter. Set parameter Stacks to an appended list with CurrTile prepended to the resulting NewStacks.
% 			b) If the counter equals 5, then take the first element in the BOneyard and store it into CUrrTile. Set Stacks equal to a list that holds CurrTile. Once this pops back, it will accumulate the rest of the Stacks.
% Assistance Received: None.
% *********************************************************************
% If this is the last Stack to initialize (base case).
initStacks(Boneyard, Stacks, 5) :-
	nth0(0, Boneyard, CurrTile),
	Stacks = [CurrTile].
initStacks(Boneyard, Stacks, Counter) :-
	Counter < 5,
	% Remove the first Tile in the Boneyard and store it in NewBoneyard.
	Boneyard = [CurrTile | Rest],
	% Increment the counter and recursively call to consider the next element in the Boneyard.
	NewCounter is Counter + 1,
	initStacks(Rest, NewStacks, NewCounter),
	% Take the first Tile in the Boneyard and add it to the Stack.
	Stacks = [CurrTile | NewStacks].

% *********************************************************************
% Rule Name: trim
% Purpose: Pops the front of the list passed in for the number of times specified by the parameter NumElements.
% Parameters:
% 		List, any arbitrary list passed in. Passed in as an empty variable.
% 		NewList, a list that represents the List after the elements are trimmed.
% 		Counter, an int that represents how many times this has iterated. Compared with NumElements to see if there are still more elements to remove from the list. Assumed to start from 0.
% 		NumElements, an int that represents how many elements need to be removed from parameter List.
% Algorithm: 
% 		1) Evaluate Counter.
% 			a) If Counter is less than NumElements, then split the List into two parts, the first element Head and the rest of the list as Rest. Set NewCounter to an incremented Counter. Recursively call trim() with everything constant except pass in Rest for the Boneyard and NewCounter.
% 			b) If the Counter and NumElements are equal, then there are no more elements to remove. Set NewList to whatever is now in List (which should presumably be a reduced List than what was originally passed in).
% Assistance Received: None.
% *********************************************************************
% Once the Counter equals the NumElements that need to be removed, then nothing more needs to be done.
trim(List, NewList, Counter, Counter) :-
    NewList = List.
trim(List, NewList, Counter, NumElements) :-
    Counter < NumElements,
	List = [Head | Rest],
	NewCounter is Counter + 1,
	trim(Rest, NewList, NewCounter, NumElements).

% *********************************************************************
% Rule Name: determineFirstPlayer
% Purpose: Determines the first Player based on what the CPU and Human drew initially. If the CPU Tile has more pips, the CPU goes first. If the Human Tile has more pips, then the Human goes first. If the two drawn Tiles are equal, the Boneyards are shuffled and the first Player is re-evaluated, re-assigning the CPUDraw and HumanDraw. This will loop as many times as it takes to determine a first Player.
% Parameters:
% 		WhiteBoneyard, a list that represents the CPU's Boneyard.
% 		BlackBoneyard, a list that represents the Human's Boneyard. 
% 		NewWhiteBoneyard, a list that represents the CPU's Boneyard after determineFirstPlayer() is called in case it has been reshuffled. Passed in as an empty variable.
% 		NewBlackBoneyard, a list that represents the Human's Boneyard after determineFirstPlayer() is called in case it has been reshuffled. Passed in as an empty variable.
% 		FirstPlayer, a string that repersents which Player has been determined to play first. Passed in as an empty variable.
% Algorithm: 
% 		1) Extract the first Tiles from each Boneyard and store them as CPUDraw and HumanDraw.
% 		2) Evaluate CPUDraw and HumanDraw's pips by using getTotalPips() on each of them.
% 			a) If the Tiles both Players drew had the same number of pips, shuffle WhiteBoneyard and BlackBoneyard and store them into ShuffWhiteBoneyard and ShuffBlackBoneyard, respectively. Then recursively call determineFirstPlayer() with everything constant except pass in the shuffled Boneyards instead so that a first Player can be re-evaluated.
% 			b) If what the CPU drew had more pips, then set the NewWhiteBoneyard and NewBlackBoneyard to WhiteBoneyard and BlackBoneyard, respectively. Set FirstPlayer to 'computer'.
% 			b) If what the Human drew had more pips, then set the NewWhiteBoneyard and NewBlackBoneyard to WhiteBoneyard and BlackBoneyard, respectively. Set FirstPlayer to 'human'.
% Assistance Received: None.
% *********************************************************************
% Base case where both Players drew the same number of pips and a first Player needs to be re-evaluated.
determineFirstPlayer(WhiteBoneyard, BlackBoneyard, NewWhiteBoneyard, NewBlackBoneyard, FirstPlayer) :-
	WhiteBoneyard = [CPUDraw | RestWhiteBoneyard],
	getTotalPips(CPUDraw, CPUPips),
	BlackBoneyard = [HumanDraw | RestBlackBoneyard],
	getTotalPips(HumanDraw, HumanPips),
	CPUPips == HumanPips,
	write('Determining first Player...\n'),
	write('Computer Drew: '), write(CPUDraw), nl,
	write('Human Drew: '), write(HumanDraw), nl,
	write('Both Players drew the same number of pips. Reshuffling...\n'),
	write('___________________________________________________\n\n'),
	% Reshuffle both Boneyards.
	random_permutation(WhiteBoneyard, ShuffWhiteBoneyard),
	random_permutation(BlackBoneyard, ShuffBlackBoneyard),
	% Recursively call to re-evaluate.
	determineFirstPlayer(ShuffWhiteBoneyard, ShuffBlackBoneyard, NewWhiteBoneyard, NewBlackBoneyard, FirstPlayer).
% If the CPU drew the greater Tile, the first Player is the Computer.
determineFirstPlayer(WhiteBoneyard, BlackBoneyard, NewWhiteBoneyard, NewBlackBoneyard, FirstPlayer) :-
	WhiteBoneyard = [CPUDraw | RestWhiteBoneyard],
	getTotalPips(CPUDraw, CPUPips),
	BlackBoneyard = [HumanDraw | RestBlackBoneyard],
	getTotalPips(HumanDraw, HumanPips),
	CPUPips > HumanPips,
	% Display what each Player drew for the Human.
	write('Computer Drew: '), write(CPUDraw), nl,
	write('Human Drew: '), write(HumanDraw), nl,
	% Save the current state of the Boneyards to new variables in case they were shuffled.
	NewWhiteBoneyard = WhiteBoneyard,
	NewBlackBoneyard = BlackBoneyard,
	FirstPlayer = 'computer'.
% If the Human drew the greater Tile, the first Player is the Human.
determineFirstPlayer(WhiteBoneyard, BlackBoneyard, NewWhiteBoneyard, NewBlackBoneyard, FirstPlayer) :-
	WhiteBoneyard = [CPUDraw | RestWhiteBoneyard],
	getTotalPips(CPUDraw, CPUPips),
	BlackBoneyard = [HumanDraw | RestBlackBoneyard],
	getTotalPips(HumanDraw, HumanPips),
	CPUPips < HumanPips,
	% Display what each Player drew for the Human.
	write('Computer Drew: '), write(CPUDraw), nl,
	write('Human Drew: '), write(HumanDraw), nl,
	% Save the current state of the Boneyards to new variables in case they were shuffled.
	NewWhiteBoneyard = WhiteBoneyard,
	NewBlackBoneyard = BlackBoneyard,
	FirstPlayer = 'human'.

% *********************************************************************
% Rule Name: getTotalPips
% Purpose: Determines the total pips in a Tile passed in by adding its left pips and right pips.
% Parameters:
% 		Tile, a list that represents the Tile in question.
% 		TotalPips, in int that represents the total pips on Tile. Passed in as an empty variable.
% Algorithm: 
% 		1) Extract the second and third elements of Tile and store them into LeftPips and RightPips, respectively.
% 		2) Set TotalPips to LeftPips + RightPips.
% Assistance Received: None.
% *********************************************************************
getTotalPips(Tile, TotalPips) :-
	nth0(1, Tile, LeftPips),
    nth0(2, Tile, RightPips),
    TotalPips is LeftPips + RightPips.

% *********************************************
% Source Code to allow the Players to play the game.
% *********************************************

% *********************************************************************
% Rule Name: playRound
% Purpose: Plays a Round, declares the winner of the Round, and asks the Human whether they want to start another Round or not. If the Human wants to start another Round, another will be started, and if not, then the Tournament will end.
% Parameters:
% 		IsRestored, a boolean that represents whether the current Round in question was restored or not. Mostly useful within playHands() to make sure Hands are not initialized when they do not need to be.
% 		RoundNum, an int that represents the current Round's number.
% 		WhiteBoneyard, a list that represents the CPU's Boneyard at the beginning of the Round (could be an initialized Boneyard or a restored Boneyard depending on what called playRound()).
% 		BlackBoneyard, a list that represents the Human's Boneyard at the beginning of the Round (could be an initialized Boneyard or a restored Boneyard depending on what called playRound()).
% 		CPUStacks, a list that represents the CPU's original 6 Stacks at the beginning of the Round (could be initialized Stacks or restored Stacks depending on what called playRound()).
% 		HumanStacks, a list that represents the Human's original 6 Stacks at the beginning of the Round (could be initialized Stacks or restored Stacks depending on what called playRound()).
% 		CPUHand, a list that represents the CPU's Hand at the beginning of a Round. Could be an empty variable if it is a newly initialized Round or it may have elements if it was restored from a file.
% 		HumanHand, a list that represents the Human's Hand at the beginning of a Round. Could be an empty variable if it is a newly initialized Round or it may have elements if it was restored from a file.
% 		CPUScore, an int that represents the CPU's score at the beginning of a Round. Could be 0 if it is a newly initialized Round or it may already be a number if it was restored from a file.
% 		HumanScore, an int that represents the Human's score at the beginning of a Round. Could be 0 if it is a newly initialized Round or it may already be a number if it was restored from a file.
% 		CPUWins, an int that represents the CPU's Rounds Won at the beginning of a Round. Could be 0 if it is a newly initialized Round or it may already be a number if it was restored from a file.
% 		HumanWins, an int that represents the Human's Rounds Won at the beginning of a Round. Could be 0 if it is a newly initialized Round or it may already be a number if it was restored from a file.
% 		FirstTurn, a string that represents the first Player in the Round. Could either be determined by a previously called determineFirstPlayer() or by the restored turn from a file.
% 		StartingHandNum, an int that represents what Hand number to start on at the beginning of the Round. Starts at 1 if it is a newly initialized Round or it could be another number if the Round was restored from a file.
% Algorithm: 
% 		1) Display each Players' Rounds Won.
% 		2) Print what Round is being played.
% 		3) Play the Hands within the ROund using playHands() and store the resulting Players' scores into UpdatedCPUScore and UpdatedHumanScore.
% 		4) Use declareWinnerOfRound() to determine and declare to the Human which Player won the Round or if it was a draw. Pass in the updated Players' Scores and store the resulting wins into UpdatedCPUWins and UpdatedHumanWins.
% 		5) Use anotherRoundQuery() to determine whether the Human wants to start another Round or not and take the appropriate option as needed. If the Human wants to start another round, the new RoundNum, UpdatedCPUWins, and UpdatedHumanWins will be passed into the new Round. If the Human does not want to start another Round, the winner of the Tournament will be determiend and printed to the Human.
% Assistance Received: None.
% *********************************************************************
playRound(IsRestored, RoundNum, WhiteBoneyard, BlackBoneyard, CPUStacks, HumanStacks, CPUHand, HumanHand, CPUScore, HumanScore, CPUWins, HumanWins, FirstTurn, StartingHandNum) :-
	% Display Players' Rounds won at beginning of Round.
	write('Computer\'s Rounds Won: '), write(CPUWins), nl,
	write('Human\'s Rounds Won: '), write(HumanWins), nl,
	write('___________________________________________________\n\n'),
	write('Playing Round '), write(RoundNum), write(":\n"),
	% Play the Hands.
	playHands(IsRestored, StartingHandNum, WhiteBoneyard, BlackBoneyard, CPUStacks, HumanStacks, CPUHand, HumanHand, CPUScore, HumanScore, UpdatedCPUScore, UpdatedHumanScore, CPUWins, HumanWins, FirstTurn),
	% Declare who won the Round.
	write('___________________________________________________\n\n'),
	declareWinnerOfRound(RoundNum, UpdatedCPUScore, UpdatedHumanScore, CPUWins, HumanWins, UpdatedCPUWins, UpdatedHumanWins),
	% Display the Players' Rounds won.
	write('Computer\'s Rounds Won: '), write(UpdatedCPUWins), nl,
	write('Human\'s Rounds Won: '), write(UpdatedHumanWins), nl,
	write('___________________________________________________\n\n'),
	% Ask the Human if they want to start another Round or not.
	write('Do you want to start another Round (y) or do you want to end the Tournament (n)?:\n'),
	catch(read(Input), error(Err, _Context), write('Invalid Format: Input reading failed.\n')),
	anotherRoundQuery(Input, Err, RoundNum, UpdatedCPUWins, UpdatedHumanWins).

% *********************************************************************
% Rule Name: playHands
% Purpose: Plays the Hands necessary within a Round. Plays Hands until all 4 Hands were played and updates the Players' scores to UpdatedCPUScore and UpdatedHumanScore.
% Parameters:
% 		IsRestored, a boolean that represents whether the current Round in question was restored or not. Mostly useful within playHands() to make sure Hands are not initialized when they do not need to be.
% 		HandNum, an int that represents the current Hand's number.
% 		WhiteBoneyard, a list that represents the CPU's Boneyard at the beginning of the Round (could be an initialized Boneyard or a restored Boneyard depending on what called playRound()).
% 		BlackBoneyard, a list that represents the Human's Boneyard at the beginning of the Round (could be an initialized Boneyard or a restored Boneyard depending on what called playRound()).
% 		CPUStacks, a list that represents the CPU's original 6 Stacks at the beginning of the Round (could be initialized Stacks or restored Stacks depending on what called playRound()).
% 		HumanStacks, a list that represents the Human's original 6 Stacks at the beginning of the Round (could be initialized Stacks or restored Stacks depending on what called playRound()).
% 		CPUHand, a list that represents the CPU's Hand at the beginning of a Round. Could be an empty variable if it is a newly initialized Round or it may have elements if it was restored from a file.
% 		HumanHand, a list that represents the Human's Hand at the beginning of a Round. Could be an empty variable if it is a newly initialized Round or it may have elements if it was restored from a file.
% 		CPUScore, an int that represents the CPU's score at the beginning of a Round. Could be 0 if it is a newly initialized Round or it may already be a number if it was restored from a file.
% 		HumanScore, an int that represents the Human's score at the beginning of a Round. Could be 0 if it is a newly initialized Round or it may already be a number if it was restored from a file.
% 		UpdatedCPUScore, an int that represents the CPU's updated score at the end of a Round. Could be 0 if it is a newly initialized Round or it may already be a number if it was restored from a file.
% 		UpdatedHumanScore, an int that represents the Human's updated score at the end of a Round. Could be 0 if it is a newly initialized Round or it may already be a number if it was restored from a file.
% 		CPUWins, an int that represents the CPU's Rounds Won at the beginning of a Round. Could be 0 if it is a newly initialized Round or it may already be a number if it was restored from a file. Used mainly for serialization if the Human chooses to save the game to a file.
% 		HumanWins, an int that represents the Human's Rounds Won at the beginning of a Round. Could be 0 if it is a newly initialized Round or it may already be a number if it was restored from a file. Used mainly for serialization if the Human chooses to save the game to a file.
% 		CurrTurn, a string that represents the current Player's turn at the beginning of a Hand. May be determined by determineFirstPLayer if it was a newly initialized Round and Hand or restored directly from a save file if the Round and Hand were restored.
% Algorithm: 
% 		1) Evaluate the HandNum.
% 			a) If the HandNum is 5, then no more Hands are to be played. Set parameter UpdatedCPUScore to CPUScore and UpdatedHumanScore to HumanScore.
% 			b) If the HandNum is not 5, then continue.
% 		2) Display what number Hand is being played.
% 		3) Initialize each Player's Hands using initializeHand() if IsRestored is false. If IsRestored is true, initializeHand() will not do anythign to the Hands. The resulting Boneyards are stored into NewWhiteBoneyard and NewBlackBoneyard, and the resulting Hands are stored into parameters CPUHand and HumanHand.
% 		4) Let the Players play their turns within the current Hand in question using playTurns(). The updated Stacks will be stored in UpdatedCPUStacks and UpdatedHumanStacks, the updated Hands will be stored into UpdatedCPUHand and UpdatedHumanHand, the updated current turn will be stored in NewCurrTurn.
% 		5) Declare that the current Hand is ending.
% 		6) Get the scores from the updated Stacks and store them into InitCPUScore and InitHumanScore.
% 		7) Handle the possible leftover Tiles from the Hands using handleLeftoverTiles() and pass in the InitCPUScore and INitHumanScore. The resulting scores will be put into NewCPUScore and NewHumanScore.
% 		8) Print the resulting scores in NewCPUScore and NewHumanScore for the Human.
% 		9) Set NewHandNUm to an incremented HandNum.
% 		10) Recursively call playHands() and pass in the updated Boneyards, Hands, Scores, and the Current Turn while keeping everything else constant. Set IsRestored to false in this recursive call so that the next Hand will be initialized properly.
% Assistance Received: None.
% *********************************************************************
% If this is the fourth Hand, play one more Hand and and update the Players' scores.
playHands(IsRestored, 5, WhiteBoneyard, BlackBoneyard, CPUStacks, HumanStacks, CPUHand, HumanHand, CPUScore, HumanScore, UpdatedCPUScore, UpdatedHumanScore, CPUWins, HumanWins, CurrTurn) :-
	UpdatedCPUScore = CPUScore,
	UpdatedHumanScore = HumanScore.
playHands(IsRestored, HandNum, WhiteBoneyard, BlackBoneyard, CPUStacks, HumanStacks, CPUHand, HumanHand, CPUScore, HumanScore, UpdatedCPUScore, UpdatedHumanScore, CPUWins, HumanWins, CurrTurn) :-
	write('___________________________________________________\n\n'),
	write('Playing Hand '), write(HandNum), write(':\n'),
	% Initialize Players' Hands if it is not a restored Hand.
	initializeHand(IsRestored, WhiteBoneyard, NewWhiteBoneyard, CPUHand, 0, End),
	initializeHand(IsRestored, BlackBoneyard, NewBlackBoneyard, HumanHand, 0, End),
	% Play the Player's turns until the Hand ends.
	playTurns(NewWhiteBoneyard, NewBlackBoneyard, CPUStacks, HumanStacks, UpdatedCPUStacks, UpdatedHumanStacks, CPUHand, HumanHand, UpdatedCPUHand, UpdatedHumanHand, CPUScore, HumanScore, CPUWins, HumanWins, CurrTurn, NewCurrTurn),
	write('Ending Hand '), write(HandNum), write('...\n'),
	write('___________________________________________________\n\n'),
	% Combine the Player's Stacks into one list for easy evaluation of scores.
	append(UpdatedCPUStacks, UpdatedHumanStacks, BothStacks),
	getScoresFromStacks(BothStacks, CPUScore, HumanScore, InitCPUScore, InitHumanScore),
	% If there are leftover Tiles in either Players' Hands, their pips will be subtracted from their scores.
	handleLeftoverTiles(UpdatedCPUHand, UpdatedHumanHand, InitCPUScore, InitHumanScore, NewCPUScore, NewHumanScore),
	% Display the Players' scores at the end of the Hand.
	write('Computer\'s Score: '), write(NewCPUScore), nl,
	write('Human\'s Score: '), write(NewHumanScore), nl,
	% Recursively call playHands() to play the next Hand
	NewHandNum is HandNum + 1,
	% Set IsRestored to false so that the next Hand will be treated like a new one and will be properly initialized.
	playHands(false, NewHandNum, NewWhiteBoneyard, NewBlackBoneyard, UpdatedCPUStacks, UpdatedHumanStacks, NewCPUHand, NewHumanHand, NewCPUScore, NewHumanScore, UpdatedCPUScore, UpdatedHumanScore, CPUWins, HumanWins, NewCurrTurn).

% *********************************************************************
% Rule Name: initializeHand
% Purpose: Initializes a Player's Hand with the Boneyard passed in.
% Parameters:
% 		IsRestored, a boolean that represents whether the current Round in question was restored or not. Mostly useful within playHands() to make sure Hands are not initialized when they do not need to be.
% 		Boneyard, a list that represents a Player's Boneyard.
% 		NewBoneyard, a list that represents the Player's Boneyard after initializing the Hand. Passed in as an empty variable.
% 		Hand, a list that represents the Player's Hand, which will be updated by the end of this rule. Passed in as an empty variable.
% 		Counter, an int that represents how many iterations the rule has run through. Compared with End to see if any more Tiles need to be added to the Hand.
% 		End, an int that represents a marker compared with Counter used to determine whether to do another recursive call or not. Passed in as an empty variable.
% Algorithm: 
% 		1) Evaluate parameter IsRestored.
% 			a) If IsRestored is true, do nothing. The Hand does not need to be initialized.
% 			b) If IsRestored is false, continue.
% 		2) Evaluate the number of Tiles in Boneyard.
% 			a) If the Boneyard has more than 4 Tiles, then it is not the 4th Hand. Set End to 5 so that 6 Tiles are drawn into the Hand.
% 			b) If the Boneyard has less than or equal to 4 Tiles, then it is the 4th Hand. Set End to 3 so that only 4 Tiles are drawn into the Hand.
% 		3) Set NewCounter to an incremented Counter and split Boneyard into a first element CurrTile and the rest of the list as Rest.
% 		4) Recursively call initializeHand() and keep everything constant except pass Rest for the Boneyard, NewHand for Hand, and NewCounter for Counter.
% 		5) Set Hand to an appended list with CurrTile prepended to the resulting NewHand from the recursive call.
% 		6) If the Counter is equal to End, then take the first Tiel in the Boneyard and store it into CurrTile. Set Hand to a list that has CurrTile. Split Boneyard into a first element and Rest and then set NewBoneyard to Rest.
% Assistance Received: None.
% *********************************************************************
% If the calling playHands() is a restored Hand, then do not initialize the Hand. Keep the Boneyard and Hand as it were.
initializeHand(true, Boneyard, Boneyard, Hand, Counter, End).
% If the calling playHands() is not a restored Hand, then initialize the Hand.
% If the Counter has reached the End, then add the final Tile to Hand (Base case).
initializeHand(false, Boneyard, NewBoneyard, Hand, Counter, End) :-
	Counter == End,
	nth0(0, Boneyard, CurrTile),
	Hand = [CurrTile],
	% Save the modified Boneyard to NewBoneyard.
	Boneyard = [Head | Rest],
	NewBoneyard = Rest.
% If the Boneyard passed in has more than 4 Tiles, then it must be initializing Hands 1-3. Take 6 Tiles from the Boneyard.
initializeHand(false, Boneyard, NewBoneyard, Hand, Counter, End) :-
	listLength(Boneyard, BoneyardSize),
	BoneyardSize > 4, End is 5, 
	Counter < End,
	Boneyard = [CurrTile | Rest],
	NewCounter is Counter + 1,
	initializeHand(false, Rest, NewBoneyard, NewHand, NewCounter, End),
	Hand = [CurrTile | NewHand].
% If the Boneyard passed in has 4 Tiles, then it must be initializing Hand 4. Take 4 Tiles from the Boneyard.
initializeHand(false, Boneyard, NewBoneyard, Hand, Counter, End) :-
	listLength(Boneyard, BoneyardSize),
	BoneyardSize =< 4, End is 3, 
	Counter < End,
	Boneyard = [CurrTile | Rest],
	NewCounter is Counter + 1,
	initializeHand(false, Rest, NewBoneyard, NewHand, NewCounter, End),
	Hand = [CurrTile | NewHand].

% *********************************************************************
% Rule Name: listLength
% Purpose: To find the length of a list.
% Parameters: 
%       List, any arbitrary list of elements.
% 		Length, an integer that represents the accumulated length of the list passed in. Passed in as an empty variable.
% Algorithm: 
% 		1) Split the list into a first element and Rest.
% 		2) Recursively call listLength and pass in Rest and NewLength.
% 		3) If the list is empty, then Length is 0.
% 		4) If there was more than 0 elements in the list, accumulate Length to NewLength + 1.
% Assistance Received: None.
% *********************************************************************
listLength([], 0).
listLength([_ | Rest], Length) :- 
	listLength(Rest, NewLength),
	Length is NewLength + 1.

% *********************************************************************
% Rule Name: playTurns
% Purpose: Lets the Players play their turns within a Round and also handles serialization if the Human chooses to suspend the game.
% Parameters:
% 		WhiteBoneyard, a list that represents the CPU's Boneyard at the beginning of the Hand (could be an initialized Boneyard or a restored Boneyard depending on what called playRound()).
% 		BlackBoneyard, a list that represents the Human's Boneyard at the beginning of the Hand (could be an initialized Boneyard or a restored Boneyard depending on what called playRound()).
% 		CPUStacks, a list that represents the CPU's original 6 Stacks at the beginning of the Hand (could be initialized Stacks or restored Stacks depending on what called playRound()).
% 		HumanStacks, a list that represents the CPU's original 6 Stacks at the beginning of the Hand (could be initialized Stacks or restored Stacks depending on what called playRound()). It will be updated through each iteration and at the end UpdatedCPUStacks will be set to it to keep the value of it after playTurns() is called.
% 		UpdatedCPUStacks, a list that represents the CPU's 6 Stacks at the end of the Hand so that the Stacks' state can be preserved between Hands in playHands().
% 		UpdatedHumanStacks, a list that represents the Humans's 6 Stacks at the end of the Hand so that the Stacks' state can be preserved between Hands in playHands().
% 		CPUHand, a list that represents the CPU's Hand at the beginning of a Hand. It is changed through each turn, but when no more turns can be played in the Hand, its value is stored into UpdatedCPUHands.
% 		HumanHand, a list that represents the Human's Hand at the beginning of a Hand. It is changed through each turn, but when no more turns can be played in the Hand, its value is stored into UpdatedHumanHands.
% 		UpdatedCPUHand, a list that represents the CPU's Hand at the end of a Hand. It is passed in as an empty variable but set to CPUHand when no more turns can be played so that the Hand's state at the end of the Hand can be preserved to evaluate in score-taking.
% 		UpdatedHumanHand, a list that represents the Human's Hand at the end of a Hand. It is passed in as an empty variable but set to CPUHand when no more turns can be played so that the Hand's state at the end of the Hand can be preserved to evaluate in score-taking.
% 		CPUScore, an int that represents the CPU's score at the beginning of a Hand. Could be 0 if it is a newly initialized Round or it may already be a number if it was restored from a file. Mainly passed in for the case where the Human wants to suspend and serialize the game.
% 		HumanScore, an int that represents the Human's score at the beginning of a Hand. Could be 0 if it is a newly initialized Round or it may already be a number if it was restored from a file. Mainly passed in for the case where the Human wants to suspend and serialize the game.
% 		CPUWins, an int that represents the CPU's Rounds Won at the beginning of a Round. Could be 0 if it is a newly initialized Round or it may already be a number if it was restored from a file. Used mainly for serialization if the Human chooses to save the game to a file.
% 		HumanWins, an int that represents the Human's Rounds Won at the beginning of a Round. Could be 0 if it is a newly initialized Round or it may already be a number if it was restored from a file. Used mainly for serialization if the Human chooses to save the game to a file.
% 		CurrTurn, a string that represents the current Player's turn. May be determined by determineFirstPLayer if it was a newly initialized Round and Hand or restored directly from a save file if the Round and Hand were restored. It is changed through each iteration, but its value at the last turn is stored in UpdatedCurrTurn.
% 		UpdatedCurrTurn, a string that represents which Player's turn it is after both Players cannot play any more turns in a Hand. Used to keep the order of turns correct between Hands.
% Algorithm: 
% 		1) Evaluate whether either Player can place any Tile from their Hands with canPlace().
% 			a) If neither can, neither Player can take another turn in the Hand. Set the Updated Stacks, Hands, and current turn to their respective parameter variables CPUStacks, HumanStacks, CPUHand, etc. so that their states at the end of a Hand can be saved.
% 			b) If either can, then continue with the current Player's turn.
% 		2) Evaluate whether the current playing Player can place any Tile from their Hands with canPlace().
% 			a) If the Player cannot place a Tile, let the Human know and skip their turn. Ask if the Human wants to suspend the game with suspendQuery().
% 			b) If the Player can place a Tile, let the Player play their turn.
% 		3) Play the Player's turn.
% 			a) If it is the CPU, then let the CPU select and place the optimal Tile in Hand on the optimal Stack placement for that Tile.
% 			b) If it is the Human, then let the Human select a Tile in Hand and a Stack to place it on. If the Human inputs "help", then the Help CPU will let the Human know what the optimal Tile and Stack placement would be, and then another input for a Tile will be taken.
% 		4) Update the Stacks and put them into NewCPUStacks and NewHumanStacks. Update the respective Hand and place it into a new list.
% 		5) Display the Stacks and the Hand after placing the Tile.
% 		6) Ask the Human whether they want to suspend the game or not. If the Human wants to supsend the game, then saveToFile() will be called. If the Human does not want to suspend the game, then recursively call playTurns with the updated Stacks and Hands and with the opposite turn in CurrTurn.
% Assistance Received: None.
% *********************************************************************
% Regardless of the turn, if both Players cannot place a Tile anymore, then stop there.
playTurns(WhiteBoneyard, BlackBoneyard, CPUStacks, HumanStacks, UpdatedCPUStacks, UpdatedHumanStacks, CPUHand, HumanHand, UpdatedCPUHand, UpdatedHumanHand, CPUScore, HumanScore, CPUWins, HumanWins, CurrTurn, UpdatedCurrTurn) :-
	canPlace(CPUHand, CPUStacks, HumanStacks, CPUCanPlace),
	canPlace(HumanHand, CPUStacks, HumanStacks, HumanCanPlace),
	CPUCanPlace == false, HumanCanPlace == false,
	write('Neither Player can place a Tile.\n'),
	% Update the Stacks, Hands, and turn.
	UpdatedCPUStacks = CPUStacks,
	UpdatedHumanStacks = HumanStacks,
	UpdatedCPUHand = CPUHand,
	UpdatedHumanHand = HumanHand,
	UpdatedCurrTurn = CurrTurn.
% If the CPU needs to play their turn and can place, let it choose an optimal Tile in Hand to place and its optimal Stack placement.
playTurns(WhiteBoneyard, BlackBoneyard, CPUStacks, HumanStacks, UpdatedCPUStacks, UpdatedHumanStacks, CPUHand, HumanHand, UpdatedCPUHand, UpdatedHumanHand, CPUScore, HumanScore, CPUWins, HumanWins, CurrTurn, UpdatedCurrTurn) :-
	canPlace(CPUHand, CPUStacks, HumanStacks, CPUCanPlace),
	CurrTurn == 'computer', CPUCanPlace == true,
	% Display the current turn.
	write('___________________________________________________\n\n'),
	write('Current Turn: '), write(CurrTurn), nl,
	write('___________________________________________________\n\n'),
	% Display the Stacks.
	displayStacks(CPUStacks, HumanStacks),
	% Display the CPU's Hand.
	displayHand(CPUHand, HumanHand, CurrTurn),
	% Select the optimal Tile in Hand to place and the optimal Stack to place.
	append(CPUStacks, HumanStacks, BothStacks),
	optimalTileInHand(b, CPUHand, BothStacks, OptimalTile),
	optimalStackPlacement(OptimalStackIndex, OptimalTile, b, BothStacks, CPUHand),
	% Let the CPU place their Tile selected onto the Stack selected.
	write('Placing '), write(OptimalTile), write(' onto Stack '), write(OptimalStackIndex), nl,
	write('___________________________________________________\n\n'),
	placeOntoStack(OptimalTile, OptimalStackIndex, CPUStacks, HumanStacks, NewCPUStacks, NewHumanStacks, 1),
	% Remove the Tile selected from Hand.
	removeTileFromHand(OptimalTile, CPUHand, NewCPUHand),
	% Display the Stacks and Hand now that they've been modified.
	displayStacks(NewCPUStacks, NewHumanStacks),
	displayHand(NewCPUHand, HumanHand, CurrTurn),
	% Change the turn to the next Player so that the next Player can play.
	getOppositeTurn(CurrTurn, OppTurn),
	% Write who's turn it is next.
	write('The next turn is: '), write(OppTurn), write('.\n'),
	% Store all of the Round's data into a single list in case the Human does want to suspend the game here.
	CPUData = [NewCPUStacks, WhiteBoneyard, NewCPUHand, CPUScore, CPUWins],
	HumanData = [NewHumanStacks, BlackBoneyard, HumanHand, HumanScore, HumanWins],
	RoundData = [CPUData, HumanData, OppTurn],
	% Ask the Human if they want to suspend the game.
	write('Do you wish to suspend the game? (y/n):\n'),
	catch(read(Input), error(Err, _Context), write('Invalid Format: Input reading failed.\n')),
	suspendQuery(Input, Err, RoundData),
	% Recurisvely call playTurns() with the updated Stacks and CPU Hand so that the next Player can play.
	playTurns(WhiteBoneyard, BlackBoneyard, NewCPUStacks, NewHumanStacks, UpdatedCPUStacks, UpdatedHumanStacks, NewCPUHand, HumanHand, UpdatedCPUHand, UpdatedHumanHand, CPUScore, HumanScore, CPUWins, HumanWins, OppTurn, UpdatedCurrTurn).
% If the CPU needs to play their turn but cannot place, do nothing and ask the Human whether they want to suspend the game or not.
playTurns(WhiteBoneyard, BlackBoneyard, CPUStacks, HumanStacks, UpdatedCPUStacks, UpdatedHumanStacks, CPUHand, HumanHand, UpdatedCPUHand, UpdatedHumanHand, CPUScore, HumanScore, CPUWins, HumanWins, CurrTurn, UpdatedCurrTurn) :-
	canPlace(CPUHand, CPUStacks, HumanStacks, CPUCanPlace),
	CurrTurn == 'computer', CPUCanPlace == false,
	% Display the current turn.
	write('___________________________________________________\n\n'),
	write('Current Turn: '), write(CurrTurn), nl,
	write('___________________________________________________\n\n'),
	% Display the Stacks.
	displayStacks(CPUStacks, HumanStacks),
	% Display the CPU's Hand.
	displayHand(CPUHand, HumanHand, CurrTurn),
	% Let the Human know that the CPU can't place a Tile.
	write('The Computer cannot place any Tiles. Skipping turn...\n'),
	% Change the turn to the next Player so that the next Player can play.
	getOppositeTurn(CurrTurn, OppTurn),
	% Write who's turn it is next.
	write('The next turn is: '), write(OppTurn), write('.\n'),
	% Store all of the Round's data into a single list in case the Human does want to suspend the game here.
	CPUData = [CPUStacks, WhiteBoneyard, CPUHand, CPUScore, CPUWins],
	HumanData = [HumanStacks, BlackBoneyard, HumanHand, HumanScore, HumanWins],
	RoundData = [CPUData, HumanData, OppTurn],
	% Ask the Human if they want to suspend the game.
	write('Do you wish to suspend the game? (y/n):\n'),
	catch(read(Input), error(Err, _Context), write('Invalid Format: Input reading failed.\n')),
	suspendQuery(Input, Err, RoundData),
	% Recurisvely call playTurns() with the updated Stacks and CPU Hand so that the next Player can play.
	playTurns(WhiteBoneyard, BlackBoneyard, CPUStacks, HumanStacks, UpdatedCPUStacks, UpdatedHumanStacks, CPUHand, HumanHand, UpdatedCPUHand, UpdatedHumanHand, CPUScore, HumanScore, CPUWins, HumanWins, OppTurn, UpdatedCurrTurn).
% If the Human needs to play their turn, let them choose a Tile in Hand to place and a Stack to place it on.
playTurns(WhiteBoneyard, BlackBoneyard, CPUStacks, HumanStacks, UpdatedCPUStacks, UpdatedHumanStacks, CPUHand, HumanHand, UpdatedCPUHand, UpdatedHumanHand, CPUScore, HumanScore, CPUWins, HumanWins, CurrTurn, UpdatedCurrTurn) :-
	canPlace(HumanHand, CPUStacks, HumanStacks, HumanCanPlace),
	CurrTurn == 'human', HumanCanPlace == true,
	% Display the current turn.
	write('___________________________________________________\n\n'),
	write('Current Turn: '), write(CurrTurn), nl,
	write('___________________________________________________\n\n'),
	% Display the Stacks.
	displayStacks(CPUStacks, HumanStacks),
	% Display the Human's Hand.
	displayHand(CPUHand, HumanHand, CurrTurn),
	% Let the Human select a Tile in Hand and store the selection in TileSelected.
	append(CPUStacks, HumanStacks, BothStacks),
	selectTileInHand(TileSelected, TileIndex, HumanHand, BothStacks, false),
	validStackPlacements(TileSelected, BothStacks, ValidStacks),
	% Let the Human select a Stack to place the Tile on.
	selectStackPlacement(TmpStackSelected, StackSelected, TileSelected, BothStacks, false),
	% Place their Tile onto the Stack specified.
	write('___________________________________________________\n\n'),
	write('Placing '), write(TileSelected), write(' onto Stack '), write(StackSelected), nl,
	write('___________________________________________________\n\n'),
	placeOntoStack(TileSelected, StackSelected, CPUStacks, HumanStacks, NewCPUStacks, NewHumanStacks, 1),
	% Remove the Tile selected from Hand.
	removeTileFromHand(TileSelected, HumanHand, NewHumanHand),
	% Display the Stacks and Hand now that they've been modified.
	displayStacks(NewCPUStacks, NewHumanStacks),
	displayHand(CPUHand, NewHumanHand, CurrTurn),
	% Change the turn to the next Player so that the next Player can play.
	getOppositeTurn(CurrTurn, OppTurn),
	% Write who's turn it is next.
	write('The next turn is: '), write(OppTurn), write('.\n'),
	% Store all of the Round's data into a single list in case the Human does want to suspend the game here.
	CPUData = [NewCPUStacks, WhiteBoneyard, CPUHand, CPUScore, CPUWins],
	HumanData = [NewHumanStacks, BlackBoneyard, NewHumanHand, HumanScore, HumanWins],
	RoundData = [CPUData, HumanData, OppTurn],
	% Ask the Human if they want to suspend the game.
	write('Do you wish to suspend the game? (y/n):\n'),
	catch(read(Input), error(Err, _Context), write('Invalid Format: Input reading failed.\n')),
	suspendQuery(Input, Err, RoundData),
	% Recurisvely call playTurns() with the updated Stacks and Human Hand so that the next Player can play.
	playTurns(WhiteBoneyard, BlackBoneyard, NewCPUStacks, NewHumanStacks, UpdatedCPUStacks, UpdatedHumanStacks, CPUHand, NewHumanHand, UpdatedCPUHand, UpdatedHumanHand, CPUScore, HumanScore, CPUWins, HumanWins, OppTurn, UpdatedCurrTurn).
% If the Human needs to play their turn, let them choose a Tile in Hand to place and a Stack to place it on.
playTurns(WhiteBoneyard, BlackBoneyard, CPUStacks, HumanStacks, UpdatedCPUStacks, UpdatedHumanStacks, CPUHand, HumanHand, UpdatedCPUHand, UpdatedHumanHand, CPUScore, HumanScore, CPUWins, HumanWins, CurrTurn, UpdatedCurrTurn) :-
	canPlace(HumanHand, CPUStacks, HumanStacks, HumanCanPlace),
	CurrTurn == 'human', HumanCanPlace == false,
	% Display the current turn.
	write('___________________________________________________\n\n'),
	write('Current Turn: '), write(CurrTurn), nl,
	write('___________________________________________________\n\n'),
	% Display the Stacks.
	displayStacks(CPUStacks, HumanStacks),
	% Display the CPU's Hand.
	displayHand(CPUHand, HumanHand, CurrTurn),
	% Let the Human know that the CPU can't place a Tile.
	write('You cannot place any Tiles. Skipping turn...\n'),
	% Change the turn to the next Player so that the next Player can play.
	getOppositeTurn(CurrTurn, OppTurn),
	% Write who's turn it is next.
	write('The next turn is: '), write(OppTurn), write('.\n'),
	% Store all of the Round's data into a single list in case the Human does want to suspend the game here.
	CPUData = [NewCPUStacks, WhiteBoneyard, CPUHand, CPUScore, CPUWins],
	HumanData = [NewHumanStacks, BlackBoneyard, HumanHand, HumanScore, HumanWins],
	RoundData = [CPUData, HumanData, OppTurn],
	% Ask the Human if they want to suspend the game.
	write('Do you wish to suspend the game? (y/n):\n'),
	catch(read(Input), error(Err, _Context), write('Invalid Format: Input reading failed.\n')),
	suspendQuery(Input, Err, RoundData),
	% Recurisvely call playTurns() with the updated Stacks and CPU Hand so that the next Player can play.
	playTurns(WhiteBoneyard, BlackBoneyard, CPUStacks, HumanStacks, UpdatedCPUStacks, UpdatedHumanStacks, CPUHand, HumanHand, UpdatedCPUHand, UpdatedHumanHand, CPUScore, HumanScore, CPUWins, HumanWins, OppTurn, UpdatedCurrTurn).

% *********************************************************************
% Rule Name: canPlace
% Purpose: Determines whether the Player passed in can place a Tile or not based on the Hand and Stacks passed in.
% Parameters:
% 		PlayerHand, a list that represents the evaluated Player's Hand of Tiles.
% 		CPUStacks, a list that represents the CPU's 6 Stacks.
% 		HumanStacks, a list that represents the Human's 6 Stacks.
% 		PlayerCanPlace, a boolean that indicates whether the Player can place a Tile in Hand or not.
% Algorithm: 
% 		1) Evaluate the number of Tiles in the Player's Hand.
% 			a) If the Player does not have any Tiles in Hand, then they definitely cannot place any Tiles. Set PlayerCanPLace to false.
% 			b) Otherwise, continue to evaluate the Tiles in Hand.
% 		2) Combine CPUStacks and HumanStacks into a single list, BothStacks, and then pass it into findValidTileInHand to determine whether a Tile exists in Hand which has any valid Stack placements. If one is found, ValidTileInHand (an empty boolean variable passed in) will be true. If not, it will be false.
% 		3) Evaluate ValidTileInHand.
% 			a) If it is true, then set PlayerCanPlace to true.
% 			b) If it is false, then set PlayerCanPlace to false.
% Assistance Received: None.
% *********************************************************************
% If the Player's Hand has Tiles and has at least one valid Tile, set PlayerCanPlace to true.
canPlace(PlayerHand, CPUStacks, HumanStacks, PlayerCanPlace) :-
	% Check if the Player has any Tiles in Hand.
	listLength(PlayerHand, PlayerHandSize),
	PlayerHandSize > 0,
	% Check if there are any valid Tiles in Hand.
	append(CPUStacks, HumanStacks, BothStacks),
	findValidTileInHand(PlayerHand, BothStacks, ValidTileInHand),
	ValidTileInHand == true,
	PlayerCanPlace = true.
% If the Player's Hand has tiles but does not have any valid Tiles in Hand, set PlayerCanPlace to false.
canPlace(PlayerHand, CPUStacks, HumanStacks, PlayerCanPlace) :-
	% Check if the Player has any Tiles in Hand.
	listLength(PlayerHand, PlayerHandSize),
	PlayerHandSize > 0,
	% Check if there are any valid Tiles in Hand.
	append(CPUStacks, HumanStacks, BothStacks),
	findValidTileInHand(PlayerHand, BothStacks, ValidTileInHand),
	ValidTileInHand == false,
	PlayerCanPlace = false.
% If the Player's Hand has no Tiles at all, set PlayerCanPlace to false.
canPlace(PlayerHand, CPUStacks, HumanStacks, PlayerCanPlace) :-
	listLength(PlayerHand, PlayerHandSize),
	PlayerHandSize == 0,
	PlayerCanPlace = false.

% *********************************************************************
% Rule Name: findValidTileInHand
% Purpose: Validates whether the Hand passed in has any valid Tiles in Hand. If one Tile with valid Stack placements can be found, ValidTileInHand will be set to true. If not, it will be set to false.
% Parameters:
% 		PlayerHand, a list that represents the evaluated Player's Hand of Tiles.
% 		BothStacks, a list that represents a combined list of CPUStacks and HumanStacks. Used for validStackPlacements().
% 		ValidTileInHand, a boolean that indicates whether the Player has any valid Tile in Hand or not.
% Algorithm: 
% 		1) Evaluate the number of Tiles in Hand.
% 			a) If the Hand is empty, then set ValidTileInHand to false.
% 			b) If the Hand is not empty, continue to evaluate the Tiles in Hand.
% 		2) Split the Hand into a first Tile CurrTile and the rest of the Hand as Rest. Evaluate CurrTile.
% 		3) Using validStackPlacements(), find the current Tile's valid Stack placements and store them in list ValidStacks.
% 		4) Evaluate ValidStacks.
% 			a) If ValidStacks is an empty list, then recursively call findValidTileInHand() and pass Rest instead of the Player's Hand to evaluate the next Tile in Hand.
% 			b) If ValidStacks is not an empty list, then there is a valid Tile in Hand. Set ValidTileInHand to true.
% Assistance Received: None.
% *********************************************************************
% If there are no more Tiles to evaluate in Hand passed in and a valid Tile has not been found yet, then there must not be a valid Tile in Hand.
findValidTileInHand([], BothStacks, false).
% If the current Hand Tile in question does not have any valid Stack placements, then evaluate the next Tile in Hand.
findValidTileInHand([CurrTile | Rest], BothStacks, ValidTileInHand) :-
	validStackPlacements(CurrTile, BothStacks, ValidStacks),
	listLength(ValidStacks, ValidStacksSize),
	ValidStacksSize == 0,
	% Recursively call to evaluate the next Tile in Hand.
	findValidTileInHand(Rest, BothStacks, ValidTileInHand).
% If the current Tile in question has at least one valid Stack placement, then there is a valid Tile in Hand. Set ValidTileInHand to true and stop evaluating the Hand.
findValidTileInHand([CurrTile | Rest], BothStacks, ValidTileInHand) :-
	validStackPlacements(CurrTile, BothStacks, ValidStacks),
	listLength(ValidStacks, ValidStacksSize),
	ValidStacksSize > 0,
	ValidTileInHand = true.

% *********************************************************************
% Rule Name: displayStacks
% Purpose: Displays the Players' Stacks.
% Parameters:
% 		CPUStacks, a list that represents the CPU's 6 Stacks.
% 		HumanStacks, a list that represents the Human's 6 Stacks.
% Algorithm: N/A.
% Assistance Received: None.
% *********************************************************************
displayStacks(CPUStacks, HumanStacks) :-
	write('\t< Computer\'s Stacks >\n'), 
	write('    w1\t    w2\t    w3\t    w4\t    w5\t    w6\n'),
	write(CPUStacks), nl,
	write(HumanStacks), nl,
	write('    b1\t    b2\t    b3\t    b4\t    b5\t    b6\n'),
	write('\t < Human\'s Stacks >\n\n').

% *********************************************************************
% Rule Name: displayHand
% Purpose: Displays the Hand of the Player whose turn it is based on the CurrTurn passed in.
% Parameters:
% 		CPUHand, a list that represents the CPU's Hand.
% 		HumanHand, a list that represents the Human's Hand.
% 		CurrTurn, a string that represents whose turn it is in the calling playHands().
% Algorithm:
% 		1) Evaluate CurrTurn.
% 			a) If CurrTurn is 'computer', then display the CPU's Hand.
% 			b) If CurrTurn is 'human', then display the Human's Hand.
% Assistance Received: None.
% *********************************************************************
% If it is the CPU's turn, then display the CPU's Hand.
displayHand(CPUHand, HumanHand, CurrTurn) :-
	CurrTurn == 'computer',
	write('Computer\'s Hand:\n'),
	write('    1\t    2\t    3\t    4\t    5\t    6\n'),
	write(CPUHand), nl, nl,
	write('___________________________________________________\n\n').
% If it is the Human's turn, then display the Human's Hand.
displayHand(CPUHand, HumanHand, CurrTurn) :-
	CurrTurn == 'human',
	write('Human\'s Hand:\n'),
	write('    1\t    2\t    3\t    4\t    5\t    6\n'),
	write(HumanHand), nl, nl,
	write('___________________________________________________\n\n').

% *********************************************
% Source Code to allow the CPU to play the game.
% *********************************************

% *********************************************************************
% Rule Name: optimalTileInHand
% Purpose: Lets the CPU select the optimal tile in Hand to place. This assumes that there is at least one valid Tile in Hand as playTurns() validates that first.
% Parameters:
% 		OppositeColor, a symbol that represents what opposite color to look for in both Player's Stacks.
% 		CPUHand, a list that represents the CPU's Tiles in Hand.
% 		BothStacks, a compounded list of the CPU and Human's Stacks. Used in oppositeToppedStacks().
% 		OptimalTile, a list that represents the optimal Tile chosen. Passed in as an empty variable.
% Algorithm:
% 		1) Determine whether the CPU is in a disadvantage state or an advantage state.
% 			a) Using oppositeToppedStacks, find all the Stacks that have a Tile of OppositeColor on top and store the Stacks into a list OppositeToppedStacks.
% 			b) If OppositeToppedStacks's size is greater than 6, then the CPU is in a disadvantage state.
% 			c) If OppositeToppedStacks's size is less than or equal than 6, then the CPU is in a advantage state.
% 		2) Get all of the optimal Tiles in Hand using getOptimalTilesInHand() and store it into list OptimalTiles.
% 			a) Find all the non-double Tiles in the list OptimalTiles. If there is at least one non-double optimal Tile and the CPU is in a disadvantage state, then find the largest non-double Tile and set OptimalTile to that. If in an advantage state, find the smallest non-double Tile and set OptimalTile to that.
% 			b) If no optimal non-double Tiles can be found, find all the double Tiles in the list OptimalTiles. If there is at least one double optimal Tile and the CPU is in a disadvantage state, then find the largest double Tile and set OptimalTile to that. if in an advantage state, find the smallest double Tile and set OptimalTile to that.
% 			c) If no optimal non-double Tiles or double Tiles can be found, then there are no Tiles in Hand that can be placed on an opposite-topped Stack. So, find Tiles in Hand that have any valid Stack placements (which by now would only be own-topped Stacks) and store it into list ValidTiles.
% 				1) Find all the valid non-double Tiles in Hand. If there is at least one valid non-double Tile in Hand, find the smallest and make that the OptimalTile.
% 				2) If no valid non-double Tiles can be found in Hand, then find the smallest valid double Tile in Hand and set that to OptimalTile.
% 		3) Print the first half of the CPU's reasoning, which includes the state of the CPU, the Tile it selected, and what Stack it is looking for.
% Assistance Received: None.
% *********************************************************************
% If the CPU is in a disadvantage state (where the Human has topped more than 6 Stacks), find the largest non double or double in Hand to cover an opposite topped Stack.
% If there are non double Tiles in Hand, evaluate if the largest non double Tile can be placed on any opposite topped Stack.
optimalTileInHand(OppositeColor, CPUHand, BothStacks, OptimalTile) :-
	% Find that the opposite Player is topping more than 6 Stacks (disadvantage state).
	oppositeToppedStacks(OppositeColor, BothStacks, OppositeToppedStacks),
	listLength(OppositeToppedStacks, OppositeToppedStacksSize),
	OppositeToppedStacksSize > 6,
	% Check if there are any optimal Tiles in Hand at all.
	getOptimalTilesInHand(OppositeColor, CPUHand, BothStacks, OptimalTiles),
	listLength(OptimalTiles, NumOptimalTiles),
	NumOptimalTiles > 0,
	% If there are any optimal non double Tiles in Hand, then find the largest and set that to the OptimalTile.
	nonDoubleTilesInList(OptimalTiles, OptimalNonDblTiles),
	listLength(OptimalNonDblTiles, NumOptimalNonDblTiles),
	NumOptimalNonDblTiles > 0,
	largestTileInList(OptimalNonDblTiles, OptimalTile),
	% Print the first half of the CPU's reasoning.
	write('Disadvantage State: Chose the largest non-double Tile in Hand, '), write(OptimalTile), write(', to reduce the number of opposite-topped Stacks by placing onto the largest opposite-topped Stack possible, ').
% If there are no optimal non double Tiles in Hand, find the largest double Tile in Hand. If the largest double Tile has an valid opposite topped Stack, then it is the optimal Tile.
optimalTileInHand(OppositeColor, CPUHand, BothStacks, OptimalTile) :-
	% Find that the opposite Player is topping more than 6 Stacks (disadvantage state).
	oppositeToppedStacks(OppositeColor, BothStacks, OppositeToppedStacks),
	listLength(OppositeToppedStacks, OppositeToppedStacksSize),
	OppositeToppedStacksSize > 6,
	% Check if there are any optimal Tiles in Hand at all.
	getOptimalTilesInHand(OppositeColor, CPUHand, BothStacks, OptimalTiles),
	listLength(OptimalTiles, NumOptimalTiles),
	NumOptimalTiles > 0,
	% Make sure there are no optimal non double Tiles in Hand.
	nonDoubleTilesInList(OptimalTiles, OptimalNonDblTiles),
	listLength(OptimalNonDblTiles, NumOptimalNonDblTiles),
	NumOptimalNonDblTiles == 0,
	% Try to find an optimal double Tile in Hand. If one is found, find the largest.
	doubleTilesInList(OptimalTiles, OptimalDblTiles),
	listLength(OptimalDblTiles, NumOptimalDblTiles),
	NumOptimalDblTiles > 0,
	largestTileInList(OptimalDblTiles, OptimalTile),
	% Print the first half of the CPU's reasoning.
	write('Disadvantage State: Chose the largest non-double Tile in Hand, '), write(OptimalTile), write(', to reduce the number of opposite-topped Stacks by placing onto the largest opposite-topped Stack possible, ').
% If the CPU is in an advantage state (where the Human has topped less than or equal to 6 Stacks), find the smallest non double or double in Hand to cover an opposite topped Stack.
% If there are non double Tiles in Hand, evaluate if the smallest non double Tile can be placed on any opposite topped Stack.
optimalTileInHand(OppositeColor, CPUHand, BothStacks, OptimalTile) :-
	% Find that the opposite Player is topping less than or equal to 6 Stacks (advantage state).
	oppositeToppedStacks(OppositeColor, BothStacks, OppositeToppedStacks),
	listLength(OppositeToppedStacks, OppositeToppedStacksSize),
	OppositeToppedStacksSize =< 6,
	% Check if there are any optimal Tiles in Hand at all.
	getOptimalTilesInHand(OppositeColor, CPUHand, BothStacks, OptimalTiles),
	listLength(OptimalTiles, NumOptimalTiles),
	NumOptimalTiles > 0,
	% If there are any optimal non double Tiles in Hand, then find the smallest and set that to the OptimalTile.
	nonDoubleTilesInList(OptimalTiles, OptimalNonDblTiles),
	listLength(OptimalNonDblTiles, NumOptimalNonDblTiles),
	NumOptimalNonDblTiles > 0,
	smallestTileInList(OptimalNonDblTiles, OptimalTile),
	% Print the first half of the CPU's reasoning.
	write('Advantage State: Chose the smallest non-double Tile in Hand, '), write(OptimalTile), write(', to reduce the number of opposite-topped Stacks by placing onto the largest opposite-topped Stack possible, ').
% If there are no optimal non double Tiles in Hand, find the largest optimal double Tile in Hand. If the largest double Tile has an valid opposite topped Stack, then it is the optimal Tile.
optimalTileInHand(OppositeColor, CPUHand, BothStacks, OptimalTile) :-
	% Find that the opposite Player is topping less than or equal to 6 Stacks (advantage state).
	oppositeToppedStacks(OppositeColor, BothStacks, OppositeToppedStacks),
	listLength(OppositeToppedStacks, OppositeToppedStacksSize),
	OppositeToppedStacksSize =< 6,
	% Check if there are any optimal Tiles in Hand at all.
	getOptimalTilesInHand(OppositeColor, CPUHand, BothStacks, OptimalTiles),
	listLength(OptimalTiles, NumOptimalTiles),
	NumOptimalTiles > 0,
	% Make sure there are no optimal non double Tiles in Hand.
	nonDoubleTilesInList(OptimalTiles, OptimalNonDblTiles),
	listLength(OptimalNonDblTiles, NumOptimalNonDblTiles),
	NumOptimalNonDblTiles == 0,
	% Try to find an optimal double Tile in Hand. If one is found, find the smallest.
	doubleTilesInList(OptimalTiles, OptimalDblTiles),
	listLength(OptimalDblTiles, NumOptimalDblTiles),
	NumOptimalDblTiles > 0,
	smallestTileInList(OptimalDblTiles, OptimalTile),
	% Print the first half of the CPU's reasoning.
	write('Advantage State: Chose the smallest double Tile in Hand, '), write(OptimalTile), write(', to reduce the number of opposite-topped Stacks by placing onto the largest opposite-topped Stack possible, ').
% Regardless of the state the CPU is in, if there are no optimal Tiles in Hand, the CPU must find the smallest Tile to place on one of its own Stacks to not potentially compromise a future Tile placement.
% Find the smallest non double Tile with any valid Stack placements (which should be own topped Stack placements).
optimalTileInHand(OppositeColor, CPUHand, BothStacks, OptimalTile) :-
	% Make sure there are no optimal Tiles in Hand to play.
	getOptimalTilesInHand(OppositeColor, CPUHand, BothStacks, OptimalTiles),
	listLength(OptimalTiles, NumOptimalTiles),
	NumOptimalTiles == 0,
	% Find Tiles with any valid Stack placements (presumably own topped Stacks). It is assumed there would be at least one since canPlace() was called first in playTurns().
	getValidTilesInHand(CPUHand, BothStacks, ValidTiles),
	% If there are any valid non double Tiles in Hand, find the smallest and set that to the OptimalTile to not potentially compromise a future Tile placement.
	nonDoubleTilesInList(ValidTiles, ValidNonDblTiles),
	listLength(ValidNonDblTiles, NumValidNonDblTiles),
	NumValidNonDblTiles > 0,
	smallestTileInList(ValidNonDblTiles, OptimalTile),
	% Print the first half of the CPU's reasoning.
	write('Cannot Top Opposite-Topped Stack: Chose the smallest non-double Tile in Hand, '), write(OptimalTile), write(', to reduce the number of opposite-topped Stacks by placing onto the smallest own-topped Stack possible, ').
% If no valid non double Tile can be found, find the smallest double Tile with any valid Stack placements (which should be own topped Stack placements).
optimalTileInHand(OppositeColor, CPUHand, BothStacks, OptimalTile) :-
	% Make sure there are no optimal Tiles in Hand to play.
	getOptimalTilesInHand(OppositeColor, CPUHand, BothStacks, OptimalTiles),
	listLength(OptimalTiles, NumOptimalTiles),
	NumOptimalTiles == 0,
	% Find Tiles with any valid Stack placements (presumably own topped Stacks). It is assumed there would be at least one since canPlace() was called first in playTurns().
	getValidTilesInHand(CPUHand, BothStacks, ValidTiles),
	% Make sure there are no valid non double Tiles in Hand.
	nonDoubleTilesInList(ValidTiles, ValidNonDblTiles),
	listLength(ValidNonDblTiles, NumValidNonDblTiles),
	NumValidNonDblTiles == 0,
	% Find the smallest valid double Tile in Hand and set that to the OptimalTile to not potentially compromise a future Tile placement.
	doubleTilesInList(ValidTiles, ValidDblTiles),
	smallestTileInList(ValidDblTiles, OptimalTile),
	% Print the first half of the CPU's reasoning.
	write('Cannot Top Opposite-Topped Stack: Chose the smallest double Tile in Hand, '), write(OptimalTile), write(', to reduce the number of opposite-topped Stacks by placing onto the smallest own-topped Stack possible, ').

% *********************************************************************
% Rule Name: getOptimalTilesInHand
% Purpose: Finds all the Tiles in Hand that have opposite topped Stack placements.
% Parameters:
% 		OppositeColor, a symbol that represents what opposite color to look for in both Player's Stacks.
% 		CPUHand, a list that represents the CPU's Tiles in Hand.
% 		BothStacks, a compounded list of the CPU and Human's Stacks. Used in oppositeToppedStacks().
% 		OptimalTiles, a list that represents all the optimal Tiles in Hand.
% Algorithm:
% 		1) Evaluate the number of Tiles in CPUHand.
% 			a) If there are not Tiles in Hand, then set OptimalTiles to an empty list. If any optimal Tiles are found, they will be added once the recursive calls pop back.
% 			b) If there are Tiles in Hand continue.
% 		2) Split the Hand into a first element CurrTile and the rest of the Hand as Rest.
% 		3) Find all of the valid Stack placements for CurrTile and store it into a list ValidStacks.
% 		4) Find all of the opposite-topped Stacks in that list using oppositeToppedStacks and store it into a list OppValidStacks.
% 		5) Recursively call getOptimalTilesInHand() to evaluate the next Tile in Hand by passing Rest instead of the Hand and pass NewOptimalTiles to accumulate a new list of optimal Tiles.
% 		6) Evaluate the number of Stacks in OppValidStacks.
% 			a) If OppValidStacks is not empty, then set OptimalTiles to an appended list with CurrTile prepended to NewOptimalTiles.
% 			b) If OppValidStacks is empty, don't append the current Tile and set OptimalTiles to NewOptimalTiles.
% Assistance Received: None.
% *********************************************************************
% If there are no more Tiles in Hand to evaluate, then start OptimalTiles off as an empty list. If there were any, it will be added later through the other cases.
getOptimalTilesInHand(OppositeColor, [], BothStacks, []).
% If the current Hand Tile in question has at least one opposite topped Stack placement, then add it to list OptimalTiles.
getOptimalTilesInHand(OppositeColor, [CurrTile | Rest], BothStacks, OptimalTiles) :-
	% Get the current Tile's valid Stack placements and see if it has any valid Stack placements.
	validStackPlacements(CurrTile, BothStacks, ValidStacks),
	% If the current Tile has any opposite topped valid Stack placements, then add it to OptimalTiles.
	oppositeToppedStacks(OppositeColor, ValidStacks, OppValidStacks),
	listLength(OppValidStacks, OppValidStacksSize),
	OppValidStacksSize > 0,
	getOptimalTilesInHand(OppositeColor, Rest, BothStacks, NewOptimalTiles),
	OptimalTiles = [CurrTile | NewOptimalTiles].
% If the current Hand Tile in question has no opposite topped Stack placement, then don't add it to list OptimalTiles.
getOptimalTilesInHand(OppositeColor, [CurrTile | Rest], BothStacks, OptimalTiles) :-
	% Get the current Tile's valid Stack placements and see if it has any valid Stack placements.
	validStackPlacements(CurrTile, BothStacks, ValidStacks),
	% If the current Tile has no opposite topped valid Stack placements, don't then add it to OptimalTiles.
	oppositeToppedStacks(OppositeColor, ValidStacks, OppValidStacks),
	listLength(OppValidStacks, OppValidStacksSize),
	OppValidStacksSize == 0,
	getOptimalTilesInHand(OppositeColor, Rest, BothStacks, NewOptimalTiles),
	OptimalTiles = NewOptimalTiles.

% *********************************************************************
% Rule Name: validStackPlacements
% Purpose: Accumulates a list of all the valid Stack placements (stored as Tiles) for a Tile passed in based on the Players' Stacks passed in (as a single accumulated list).
% Parameters:
% 		TileSelected, a list that represents the Tile whose valid Stack placements will be found.
% 		BothStacks, a compounded list of both CPUStacks and HumanStacks.
% 		ValidStacks, a list that represents an accumulated list of all the valid Stack placements for TileSelected.
% Algorithm:
% 		1) Evaluate the number of Stacks in BothStacks.
% 			a) If BothStacks is an empty list, then set ValidStacks to an empty list. If any valid Stack placements are found, they will be accumulated when the recursive calls pop back.
% 			b) If BothStacks is not an empty list, continue evaluate the current Stack in question.
% 		2) Recursively call validStackPlacements to evaluate the next Stack in BothStacks but pass Rest instead of BothStacks. Accumulate the valid Stack placements into NewValidStacks.
% 		3) Split BothStacks into a first Stack CurrStack and the rest of the Stacks in Rest. Evaluate the current Stack with TileSelected.
% 			a) If TileSelected is a non-double Tile, then if it has more or equal pips to the Stack's pips, then set ValidStacks to an appended list of the CurrStack and NewValidStacks. If the non-double Tile has less pips than the current Stack, don't prepend CurrStack and setValidStacks to NewValidStacks.
% 			b) If TileSelected is a double Tile, then if the Stack Tile is a non-double Tile, set ValidStacks to an appended list of CurrStack and NewValidStacks. If the Stack Tile is a double Tile, only add CurrStack to NewValidStacks if it has more pips than the CurrStack.
% Assistance Received: None.
% *********************************************************************
% If there are no more Stacks to evaluate, start the ValidStacks as an empty list and let it accumulate.
validStackPlacements(TileSelected, [], []).
% If the Tile selected is a non double Tile...
% If the non double Tile selected has more or equal pips to the Stack in question, then add the current Stack to ValidStacks.
validStackPlacements(TileSelected, BothStacks, ValidStacks) :-
	% Check if the Tile selected is a non double Tile.
	isDoubleTile(TileSelected, IsDouble),
	IsDouble == false,
	% Check if the Tile selected has more or equal pips to the stack in question.
	BothStacks = [CurrStack | Rest],
	getTotalPips(TileSelected, TilePips),
	getTotalPips(CurrStack, StackPips),
	TilePips >= StackPips,
	% Recursively call to evaluate the next Stack in question.
	validStackPlacements(TileSelected, Rest, NewValidStacks),
	ValidStacks = [CurrStack | NewValidStacks].
% If the non double Tile selected has less pips to the Stack in question, then don't add anything to ValidStacks.
validStackPlacements(TileSelected, BothStacks, ValidStacks) :-
	% Check if the Tile selected is a non double Tile.
	isDoubleTile(TileSelected, IsDouble),
	IsDouble == false,
	% Check if the Tile selected has more or equal pips to the stack in question.
	BothStacks = [CurrStack | Rest],
	getTotalPips(TileSelected, TilePips),
	getTotalPips(CurrStack, StackPips),
	TilePips < StackPips,
	% Recursively call to evaluate the next Stack in question.
	validStackPlacements(TileSelected, Rest, NewValidStacks),
	ValidStacks = NewValidStacks.
% If the Tile selected is a double Tile...
% If the current Stack in question is a non double, then it is already a valid Stack to place on, so add it to ValidStacks.
validStackPlacements(TileSelected, BothStacks, ValidStacks) :-
	% Check if the Tile selected is a double Tile.
	isDoubleTile(TileSelected, TileIsDouble),
	TileIsDouble == true,
	% Check if the Stack in question is a non double Tile.
	BothStacks = [CurrStack | Rest],
	isDoubleTile(CurrStack, StackIsDouble),
	StackIsDouble == false,
	% Recursively call to evaluate the next Stack in question.
	validStackPlacements(TileSelected, Rest, NewValidStacks),
	ValidStacks = [CurrStack | NewValidStacks].
% If both the Tile and Stack selected are double Tiles but the Tile has more pips, then add the Stack to ValidStacks.
validStackPlacements(TileSelected, BothStacks, ValidStacks) :-
	% Check if the Tile selected is a double Tile.
	isDoubleTile(TileSelected, TileIsDouble),
	TileIsDouble == true,
	% Check if the Stack in question is a double Tile.
	BothStacks = [CurrStack | Rest],
	isDoubleTile(CurrStack, StackIsDouble),
	StackIsDouble == true,
	% Check if the Tile has more pips than the Stack.
	getTotalPips(TileSelected, TileTotalPips),
	getTotalPips(CurrStack, StackTotalPips),
	TileTotalPips > StackTotalPips,
	% Recursively call to evaluate the next Stack in question.
	validStackPlacements(TileSelected, Rest, NewValidStacks),
	ValidStacks = [CurrStack | NewValidStacks].
% If both the Tile and Stack selected are double Tiles but the Tile has equal or less pips, then don't add the Stack to ValidStacks.
validStackPlacements(TileSelected, BothStacks, ValidStacks) :-
	% Check if the Tile selected is a double Tile.
	isDoubleTile(TileSelected, TileIsDouble),
	TileIsDouble == true,
	% Check if the Stack in question is a double Tile.
	BothStacks = [CurrStack | Rest],
	isDoubleTile(CurrStack, StackIsDouble),
	StackIsDouble == true,
	% Check if the Tile has more pips than the Stack.
	getTotalPips(TileSelected, TileTotalPips),
	getTotalPips(CurrStack, StackTotalPips),
	TileTotalPips =< StackTotalPips,
	% Recursively call to evaluate the next Stack in question.
	validStackPlacements(TileSelected, Rest, NewValidStacks),
	ValidStacks = NewValidStacks.

% *********************************************************************
% Rule Name: isDoubleTile
% Purpose: Determines whether the Tile passed in is a double Tile or not.
% Parameters:
% 		Tile, a list that represents the Tile to be evaluated.
% 		IsDouble, a boolean that indicates whether Tile is a double or non-double. Passed in as an empty variable.
% Algorithm:
% 		1) Take the second and third elements of Tile and store them into LeftPips and RightPips, respectively.
% 		2) Compare and evaluate LeftPips and RightPips.
% 			a) If the two are equal, then set IsDouble to true.
% 			b) If the two are not equal, then set IsDouble to false.
% Assistance Received: None.
% *********************************************************************
% If the left and right pips are equal, then it is a double Tile.
isDoubleTile(Tile, IsDouble) :-
	nth0(1, Tile, LeftPips),
	nth0(2, Tile, RightPips),
	LeftPips == RightPips,
	IsDouble = true.
% If the left and right pips are not equal, then it is not a double Tile.
isDoubleTile(Tile, IsDouble) :-
	nth0(1, Tile, LeftPips),
	nth0(2, Tile, RightPips),
	LeftPips \= RightPips,
	IsDouble = false.

% *********************************************************************
% Rule Name: doubleTilesInList
% Purpose: Makes a list of all of the double Tiles in a list of Tiles passed in.
% Parameters:
% 		List, a list of Tiles that will be evaluated.
% 		DoubleTiles, a list of double Tiles in List. Passed in as an empty variable.
% Algorithm:
% 		1) Evaluate the size of List.
% 			a) If there are no elements in List, then it is either an empty list or all Tiles have been evaluated. Regardless, set DoubleTiles to an empty list. If double Tiles were found, they will be added when the recursive calls pop back.
% 			b) If there are elements in the List, continue.
% 		2) Split the List into two parts: the first element CurrTile and the rest of the list, Rest.
% 		3) Using isDoubleTile(), determine whether the CurrTile is a double Tile or not.
% 		4) Recursively call doubleTilesInList but pass Rest instead of List to evaluate the next Tile in the list. Pass NewDoubleTiles instead of DoubleTiles.
% 		5) If the CurrTile was a double, set parameter DoubleTiles to an appended list of CurrTile and NewDoubleTiles. If CurrTile was not a double, set DoubleTiles to NewDoubleTiles.
% Assistance Received: None.
% *********************************************************************
% If there are no Tiles to evaluate or there are no more Tiles to evaluate in List, then set the accumulated (or not) double Tiles in Hand to an empty list to build off of (or not if none are found).
doubleTilesInList([], []).
% If the current Tile in question is a double Tile, then accumulate it to DoubleTiles.
doubleTilesInList(List, DoubleTiles) :-
	List = [CurrTile | Rest],
	isDoubleTile(CurrTile, IsDouble),
	IsDouble == true,
	doubleTilesInList(Rest, NewDoubleTiles),
	DoubleTiles = [CurrTile | NewDoubleTiles].
% If the current Tile in question is a non double Tile, then do not accumulate it to DoubleTiles.
doubleTilesInList(List, DoubleTiles) :-
	List = [CurrTile | Rest],
	isDoubleTile(CurrTile, IsDouble),
	IsDouble == false,
	doubleTilesInList(Rest, NewDoubleTiles),
	DoubleTiles = NewDoubleTiles.

% *********************************************************************
% Rule Name: nonDoubleTilesInList
% Purpose: Makes a list of all of the non-double Tiles in a Hand passed in.
% Parameters:
% 		List, a list of Tiles that will be evaluated.
% 		NonDoubleTiles, a list of non-double Tiles in List. Passed in as an empty variable.
% Algorithm:
% 		1) Evaluate the size of List.
% 			a) If there are no elements in List, then it is either an empty list or all Tiles have been evaluated. Regardless, set NonDoubleTiles to an empty list. If non-double Tiles were found, they will be added when the recursive calls pop back.
% 			b) If there are elements in the List, continue.
% 		2) Split the List into two parts: the first element CurrTile and the rest of the list, Rest.
% 		3) Using isDoubleTile(), determine whether the CurrTile is a non-double Tile or not.
% 		4) Recursively call nonDoubleTilesInList but pass Rest instead of List to evaluate the next Tile in the list. Pass NewNonDoubleTiles instead of NonDoubleTiles.
% 		5) If the CurrTile was a non-double, set parameter NonDoubleTiles to an appended list of CurrTile and NewNonDoubleTiles. If CurrTile was a double, set NonDoubleTiles to NewNonDoubleTiles.
% Assistance Received: None.
% *********************************************************************
% If there are no Tiles to evaluate or there are no more Tiles to evaluate in List, then set the accumulated (or not) non double Tiles in List to an empty list to build off of (or not if none are found).
nonDoubleTilesInList([], []).
% If the current Tile in question is a double Tile, then accumulate it to DoubleTiles.
nonDoubleTilesInList(List, NonDoubleTiles) :-
	List = [CurrTile | Rest],
	isDoubleTile(CurrTile, IsDouble),
	IsDouble == false,
	nonDoubleTilesInList(Rest, NewNonDoubleTiles),
	NonDoubleTiles = [CurrTile | NewNonDoubleTiles].
% If the current Tile in question is a non double Tile, then do not accumulate it to DoubleTiles.
nonDoubleTilesInList(List, NonDoubleTiles) :-
	List = [CurrTile | Rest],
	isDoubleTile(CurrTile, IsDouble),
	IsDouble == true,
	nonDoubleTilesInList(Rest, NewNonDoubleTiles),
	NonDoubleTiles = NewNonDoubleTiles.

% *********************************************************************
% Rule Name: largestTileInList
% Purpose: Gets the largest Tile from a list passed in.
% Parameters:
% 		List, a list of Tiles that will be evaluated.
% 		LargestTile, a list that represents the largest Tile found in List.
% Algorithm:
% 		1) Evaluate the size of List.
% 			a) If there is only one more Tile in the list, set LargestTile to that Tile.
% 			b) Otherwise, continue.
% 		2) Split List into two parts: the first element CurrTile, and the rest of the list as Rest.
% 		3) Recursively call largestTileInList but pass in Rest and NewLargestTile instead of List and LargestTile, respectively to evaluate the next Tile in List.
% 		4) Evaluate the pips in CurrTile and NewLargestTile.
% 			a) If the CurrTile has more pips than the NewLargestTile, then set parameter LargestTile to CurrTile.
% 			b) If the CurrTile has less than or equal pips to NewLargestTile, then set parameter LargestTile to NewLargestTile.
% Assistance Received: None.
% *********************************************************************
% If it is the last Tile in Hand, set that to the largest first. If the other Tiles when popping back are larger, then the largest will be set to that instead.
largestTileInList([LastTile], LastTile).
% If the current Tile in question has more pips than the previous largest, then it will be set to the largest for now.
largestTileInList([CurrTile | Rest], LargestTile) :-
	% Get the previous largest Tile.
	largestTileInList(Rest, NewLargestTile),
	% If the current Tile has more pips than the previous largest, then the current Tile is the new Largest.
	getTotalPips(CurrTile, CurrTilePips),
	getTotalPips(NewLargestTile, NewLargestTilePips),
	CurrTilePips > NewLargestTilePips,
	LargestTile = CurrTile.
% If the current Tile in question has equal or less pips than the previous largest, then the previous largest will remain the largest for now.
largestTileInList([CurrTile | Rest], LargestTile) :-
	% Get the previous largest Tile.
	largestTileInList(Rest, NewLargestTile),
	% If the current Tile has equal or less pips than the previous largest, then the previous largest still remains the largest Tile.
	getTotalPips(CurrTile, CurrTilePips),
	getTotalPips(NewLargestTile, NewLargestTilePips),
	CurrTilePips =< NewLargestTilePips,
	LargestTile = NewLargestTile.

% *********************************************************************
% Rule Name: smallestTileInList
% Purpose: Gets the smallest Tile in a list passed in.
% Parameters:
% 		List, a list of Tiles that will be evaluated.
% 		SmallestTile, a list that represents the smallest Tile found in List.
% Algorithm:
% 		1) Evaluate the size of List.
% 			a) If there is only one more Tile in the list, set SmallestTile to that Tile.
% 			b) Otherwise, continue.
% 		2) Split List into two parts: the first element CurrTile, and the rest of the list as Rest.
% 		3) Recursively call smallestTileInList but pass in Rest and NewSmallestTile instead of List and SmallestTile, respectively to evaluate the next Tile in List.
% 		4) Evaluate the pips in CurrTile and NewSmallestTile.
% 			a) If the CurrTile has less pips than the NewSmallestTile, then set parameter SmallestTile to CurrTile.
% 			b) If the CurrTile has more than or equal pips to NewSmallestTile, then set parameter SmallestTile to NewSmallestTile.
% Assistance Received: None.
% *********************************************************************
% If it is the last Tile in Hand, set that to the smallest first. If the other Tiles when popping back are larger, then the smallest will be set to that instead.
smallestTileInList([LastTile], LastTile).
% If the current Tile in question has more pips than the previous largest, then it will be set to the largest for now.
smallestTileInList([CurrTile | Rest], SmallestTile) :-
	% Get the previous smallest Tile.
	smallestTileInList(Rest, NewSmallestTile),
	% If the current Tile has less pips than the previous smaller, then the current Tile is the new Smallest.
	getTotalPips(CurrTile, CurrTilePips),
	getTotalPips(NewSmallestTile, NewSmallestTilePips),
	CurrTilePips < NewSmallestTilePips,
	SmallestTile = CurrTile.
% If the current Tile in question has equal or more pips than the previous smallest, then the previous smallest will remain the smallest for now.
smallestTileInList([CurrTile | Rest], SmallestTile) :-
	% Get the previous largest Tile.
	smallestTileInList(Rest, NewSmallestTile),
	% If the current Tile has equal or less pips than the previous largest, then the previous largest still remains the largest Tile.
	getTotalPips(CurrTile, CurrTilePips),
	getTotalPips(NewSmallestTile, NewSmallestTilePips),
	CurrTilePips >= NewSmallestTilePips,
	SmallestTile = NewSmallestTile.

% *********************************************************************
% Rule Name: oppositeToppedStacks
% Purpose: Makes a list of all of the Stacks that are topped by a the opposite color passed in.
% Parameters:
% 		OppositeColor, a symbol that represents the opposite color to look for within List.
% 		List, a list of Tiles that will be evaluated.
% 		OppositeToppedStacks, a list of Tiles that represents all of the Stacks whose top Tile is the color OppositeColor.
% Algorithm:
% 		1) Evaluate the size of List.
% 			a) If List is empty, then set OppositeToppedStacks to an empty list. If there are any opposite-topped Stacks in List, then they will be added to OppositeToppedStacks when the recursive calls pop back.
% 			b) Otherwise, continue.
% 		2) Split List into two parts: the first element CurrStack, and the rest of the list as Rest.
% 		3) Take the first element from CurrStack and set that to CurrStackColor.
% 		4) Recursively call oppositeToppedStacks but pass in Rest instead of List to evaluate the next Stack/Tile in the list. Pass NewOppositeToppedStacks instead of OppositeToppedStacks.
% 		5) Evaluate CurrStackColor.
% 			a) If CurrStackColor is the same as OppositeColor, then set parameter OppositeToppedStacks to an appended list of CurrStack and NewOppositeToppedStacks.
% 			b) If CurrStackColor is not the same as OppositeColor, then set parameter OppositeToppedStacks to NewOppositeToppedStacks.
% Assistance Received: None.
% *********************************************************************
% If there are no more Stacks to evaluate, start OppositeToppedStacks off as an empty list.
oppositeToppedStacks(OppositeColor, [], []).
% If the current Stack in question is the opposite color, add it to OppositeToppedStacks.
oppositeToppedStacks(OppositeColor, [CurrStack | Rest], OppositeToppedStacks) :-
	nth0(0, CurrStack, CurrStackColor),
	CurrStackColor == OppositeColor,
	% Evaluate the next Tile in BothStacks.
	oppositeToppedStacks(OppositeColor, Rest, NewOppositeToppedStacks),
	OppositeToppedStacks = [CurrStack | NewOppositeToppedStacks].
% If the current Stack in question is not the opposite color, don't add it to OppositeToppedStacks.
oppositeToppedStacks(OppositeColor, [CurrStack | Rest], OppositeToppedStacks) :-
	nth0(0, CurrStack, CurrStackColor),
	CurrStackColor \= OppositeColor,
	% Evaluate the next Tile in BothStacks.
	oppositeToppedStacks(OppositeColor, Rest, NewOppositeToppedStacks),
	OppositeToppedStacks = NewOppositeToppedStacks.

% *********************************************************************
% Rule Name: getValidTilesInHand
% Purpose: Finds Tiles from Hand with any valid Stack placements and puts in into a list. Meant to be used in the case where the CPU has no optimal Tiles in Hand and must top one of its own Stacks.
% Parameters:
% 		Hand, a list of Tiles that represents a Player's Tiles in Hand.
% 		BothStacks, an appended list of CPUStacks and HumanStacks.
% 		ValidTilesInHand, a list of Tiles in Hand that have any valid Stack placements.
% Algorithm:
% 		1) Evaluate the size of Hand.
% 			a) If Hand is empty, then set ValidTilesInHand to an empty list. If any valid Tiles were found, then they will be added when the recursive calls pop back.
% 			b) Otherwise, continue.
% 		2) Split the Hand into two parts: the first element CurrTile and the rest of the Hand as Rest.
% 		3) Using validStackPlacements(), get all of the valid Stack placements for CurrTile.
% 		4) Recursively call getValidTilesInHand() but pass in Rest instead of Hand to evaluate the next Tile and pass in NewValidTilesInHand instead of ValidTilesInHand.
% 		5) Evaluate the number of valid Stacks for CurrTile.
% 			a) If there is at least one valid Stack placement, then set parameter ValidTilesInHand to an appended list of CurrTile and NewValidTilesInHand.
% 			b) If there are no valid Stack placements for CurrTile, then set parameterValidTilesInHand to NewValidTilesInHand.
% Assistance Received: None.
% *********************************************************************
% If there are no more Tiles in Hand to evaluate (or none at all), start off ValidTilesInHand as an empty list so it can be built up if need be.
getValidTilesInHand([], BothStacks, []).
% If the current Tile in question has a valid Stack placement, add it to ValidTilesInHand.
getValidTilesInHand([CurrTile | Rest], BothStacks, ValidTilesInHand) :-
	% Get the current Tile's valid Stack placements and make sure it has at least 1.
	validStackPlacements(CurrTile, BothStacks, ValidStacks),
	listLength(ValidStacks, NumValidStacks),
	NumValidStacks > 0,
	% Evaluate the next Tile in Hand.
	getValidTilesInHand(Rest, BothStacks, NewValidTilesInHand),
	% Add the current Tile to the list of valid Tiles.
	ValidTilesInHand = [CurrTile | NewValidTilesInHand].
% If the current Tile in question does not have a valid Stack placement, do not add it to ValidTilesInHand.
getValidTilesInHand([CurrTile | Rest], BothStacks, ValidTilesInHand) :-
	% Get the current Tile's valid Stack placements and make sure it has at least 1.
	validStackPlacements(CurrTile, BothStacks, ValidStacks),
	listLength(ValidStacks, NumValidStacks),
	NumValidStacks == 0,
	% Evaluate the next Tile in Hand.
	getValidTilesInHand(Rest, BothStacks, NewValidTilesInHand),
	% Add the current Tile to the list of valid Tiles.
	ValidTilesInHand = NewValidTilesInHand.

% *********************************************************************
% Rule Name: optimalStackPlacement
% Purpose: Lets the CPU select the optimal Stack to place the TileSelected onto.
% Parameters:
% 		OptimalStackIndex, and int that represents the index for the optimal Stack placement for TileSelected. Passeed in as an empty variable.
% 		TileSelected, a list that represents the chosen optimal Tile that will be evaluated.
% 		OppositeColor, a symbol that represents the opposite color to look for when getting optimal Tiles in Hand.
% 		BothStacks, an appended list of CPUStacks and HumanStacks.
% 		CPUHand, a list of Tiles that represents the Tiles in the CPU's Hand.
% Algorithm:
% 		1) Gather all of the optimal Tiles in Hand using getOptimalTilesInHand() and store that list into OptimalTiles.
% 		2) See if the TileSelected is an optimal Tile by looking for it in OptimalTiles using findTileInList(). Whether it is found or not will be indicated by the boolean IsFound which is passed into findTileInList().
% 		3) Evaluate IsFound.
% 			a) If IsFound is true, then TileSelected is an optimal Tile. First, get all of TileSelected's valid Stack placements and put that into list ValidStacks. Then using oppositeToppedStacks() determine the optimal ValidStacks using oppositeToppedStacks() on ValidStacks and storing the resulting list into OptimalValidStacks. Then find the largest Stack in OptimalValidStacks using largestTileInList() and store that into LargestOptimalStack. Find that Tile's index by using getStackNameFromTile() and set parameter OptimalTileIndex to that index.
% 			b) If IsFound is false, then TileSelected is not an optimal Tile. Get all of the valid Stack placements for TileSelected using validStackPlacements() and store that into ValidStacks. Find the smallest valid Stack in ValidStacks using smallestTileInList() and set that to SmallestOwnToppedStack. Get the index of tSmallestOwnToppedStack using getStackNameFromTile() and store that into parameter OptimalStackIndex.
% 		4) Print out the second half of the CPU's reasoning, which is the Stack index that was selected and the Tile topping the Stack.
% Assistance Received: None.
% *********************************************************************
% If the current TileSelected is found to be an optimal Tile in the CPU's Hand, then get the index of the largest optimal Stack placement.
optimalStackPlacement(OptimalStackIndex, TileSelected, OppositeColor, BothStacks, CPUHand) :-
	% If the TileSelected is an optimal Tile, place it on the largest opposite topped Stack possible.
	getOptimalTilesInHand(OppositeColor, CPUHand, BothStacks, OptimalTiles),
	findTileInList(TileSelected, OptimalTiles, IsFound),
	IsFound == true,
	% Get the largest optimal Stack.
	validStackPlacements(TileSelected, BothStacks, ValidStacks),
	oppositeToppedStacks(OppositeColor, ValidStacks, OptimalValidStacks),
	largestTileInList(OptimalValidStacks, LargestOptimalStack),
	% Find the Stack in BothStacks and get the index. Store that index in OptimalStackIndex.
	getStackNameFromTile(OptimalStackIndex, LargestOptimalStack, BothStacks, 1),
	% Complete the explanation for the CPU.
	write(OptimalStackIndex), write(', which has Tile '), write(LargestOptimalStack), write('.'), nl.
% If the current TileSelected is not an optimal Tile in the CPU's Hand, find the index of the smallest valid Stack placement (which should be an own topped Stack).
optimalStackPlacement(OptimalStackIndex, TileSelected, OppositeColor, BothStacks, CPUHand) :-
	% If the TileSelected is not an optimal Tile, place it on the smallest own topped Stack possible.
	getOptimalTilesInHand(OppositeColor, CPUHand, BothStacks, OptimalTiles),
	findTileInList(TileSelected, OptimalTiles, IsFound),
	IsFound == false,
	% Get the smallest vaid Stack (which should be an own topped Stack at this point as there would otherwise be an optimal Tile).
	validStackPlacements(TileSelected, BothStacks, ValidStacks),
	smallestTileInList(ValidStacks, SmallestOwnToppedStack),
	% Find the Stack in BothStacks and get the index. Store that index in OptimalStackIndex.
	getStackNameFromTile(OptimalStackIndex, SmallestOwnToppedStack, BothStacks, 1),
	% Complete the explanation for the CPU.
	write(OptimalStackIndex), write(', which has Tile '), write(SmallestOwnToppedStack), write('.'), nl.

% *********************************************************************
% Rule Name: getStackNameFromTile
% Purpose: Finds the index of a Stack that is passed in. Searches through BothStacks (CPUStacks and HumanStacks appended together) to find the index. Once the StackTile is found, the Stack index is set equal to the Counter (which starts at 0 since the Stack numbers start at 0).
% Parameters:
% 		StackName, a term that represents the name of the stack (w or b with a digit 1-6).
% 		StackTile, a list that represents the Tile on top of a Stack that will be evaluated.
% 		BothStacks, a compounded list of CPUStacks and HumanStacks.
% 		Counter, an int that represents the current Stack index in question.
% Algorithm:
% 		1) Split BothStacks into the first element CurrStack, and the rest of the Stacks in Rest.
% 		2) Evaluate CurrStack.
% 			a) If the StackTile is not equal to the CurrStack, then set NewCounter to an incremented Counter and recursively call getStackNameFromTile() to evaluate the next Stack in BothStacks. Pass Rest instead of BothStacks and NewCounter instead of Counter.
% 			b) If the StackTile is equal to the CurrStack, then set StackIndex to the Counter.
% Assistance Received: None.
% *********************************************************************
getStackNameFromTile(StackName, StackTile, [CurrStack | Rest], Counter) :-
	StackTile \= CurrStack,
	NewCounter is Counter + 1,
	getStackNameFromTile(NewStackName, StackTile, Rest, NewCounter),
	StackName = NewStackName.
% If the current Stack in question is the StackTile to look for and Counter is less than or equal to 6, then it must be one of the CPU's Stacks. Create a term with w and the Counter and set that to StackName.
getStackNameFromTile(StackName, StackTile, [CurrStack | Rest], Counter) :-
	StackTile == CurrStack,
	Counter =< 6,
	% Convert the Counter to an atom so it can be combined with a w.
	term_to_atom(Counter, AtomCounter),
	atom_concat('w', AtomCounter, AtomStackName),
	% Convert the full Stack name back to a term so that placeOntoStack() can properly use it.
	term_to_atom(StackName, AtomStackName).
% If the current Stack in question is the StackTile to look for and Counter is greater than 6, then it must be one of the Human's Stacks. Create a term with w and the Counter and set that to StackName.
getStackNameFromTile(StackName, StackTile, [CurrStack | Rest], Counter) :-
	StackTile == CurrStack,
	Counter > 6,
	% Correct Counter to a number that is 1-6.
	NewCounter is Counter - 6,
	% Convert the NewCounter to an atom so it can be combined with a b.
	term_to_atom(NewCounter, AtomCounter),
	atom_concat('b', AtomCounter, AtomStackName),
	% Convert the full Stack name back to a term so that placeOntoStack() can properly use it.
	term_to_atom(StackName, AtomStackName).

% *********************************************
% Source Code to allow the Human to play the game.
% *********************************************

% *********************************************************************
% Rule Name: selectTileInHand
% Purpose: Lets the Human choose a Tile in Hand. Will recursively call itself until a valid Tile is inputted. Once a valid Tile is selected, then it will be stored in parameter TileSelected.
% Parameters:
% 		TileSelected, a list that represents the Tile that the Human selects. Passed in as an empty variable.
% 		TileIndex, an int that represents the index inputted from the Human. Passed in as an empty variable initially but modified upon the first recursive call.
% 		HumanHand, a list of Tiles that represents the Tiles in Hand.
% 		BothStacks, a compounded list of CPUStacks and HumanStacks.
% 		IsValid, a boolean that indicates whetehr the input from the Human was valid both in format or in choice.
% Algorithm:
% 		1) Evaluate IsValid.
% 			a) If IsValid is true, then use findHandTileWithIndex() to find the Tile specified by TileIndex and store it into parameter TileSelected.
% 			b) If IsValid is false, continue.
% 		2) Get the number of Tiles in Hand using listLength and store it into HumanHandSize.
% 		3) Tell the Human to enter a number between 1 to HumanHandSize. Also tell them to input "help" if they want a tip from the HelpCPU.
% 		4) Take the input into NewTileIndex.
% 		5) Pass NewTileIndex to displayHelp. If it is "help", then it will display a tip from the HelpCPU. If not, then displayHelp() will do nothing.
% 		6) Pass NewTileIndex into validateTileInput(). If it is "help", then do nothing. If it not, then validate the input and use IsValid to indicate whether the input is valid or not.
% 		7) Recursively call selectTileInHand() but pass in NewTileIndex and IsValid.
% Assistance Received: None.
% *********************************************************************
% If the Tile inputted was in an invalid format or not in Hand, take another selection through recursion.
selectTileInHand(TileSelected, TileIndex, HumanHand, BothStacks, false) :-
	listLength(HumanHand, HumanHandSize),
	write('Choose a Tile in your Hand. Enter a number between 1-'), write(HumanHandSize), write('. Enter (help.) for a tip on the optimal Tile in Hand and the optimal Stack to place it on:\n'),
	catch(read(NewTileIndex), error(Err, _Context), write('Invalid Format: Input reading failed.\n')),
	displayHelp(NewTileIndex, Err, HumanHand, BothStacks),
	validateTileInput(NewTileIndex, Err, HumanHandSize, BothStacks, HumanHand, IsValid),
	% Recursively call with the newly updated input and IsValid determined by the validation of the input with validateTileInput.
	selectTileInHand(TileSelected, NewTileIndex, HumanHand, BothStacks, IsValid).
% If the Tile inputted was in a valid format, turn the string into a Tile and put it into TileSelected. This case handles the case where the Tile specified is not in the Hand and another input is taken through recursion.
selectTileInHand(TileSelected, TileIndex, HumanHand, BothStacks, true) :-
	% Extract the TileSelected from the Human's Hand using the TileIndex taken from input.
	findHandTileWithIndex(TileSelected, TileIndex, 1, HumanHand).

% *********************************************************************
% Rule Name: displayHelp
% Purpose: Displays the HelpCPU's tip on optimal Tile and its optimal Stack placement when 'help' is the input.
% Parameters:
% 		Input, a string or symbol that represents what the Human inputted in selectTileInHand().
% 		Err, a Catcher that records the error thrown from read().
% 		HumanHand, a list of Tiles that represents the Tiles in the Human's Hand.
% 		BothStacks, a compounded list of CPUStacks and HumanStacks.
% Algorithm:
% 		1) Evaluate Input.
% 			a) If Input is 'help', then use optimalTileInHand() and optimalStackPlacement() to get what the HelpCPU would deem as an optimal Tile and Stack placement. Pass w for the OppositeColor and HumanHand instead of CPUHand so it can evaluate the Human's Hand against the Enemy CPU's Stacks.
% 			b) If the Input is anything else, do nothing.
% Assistance Received: None.
% *********************************************************************
displayHelp('help', Err, HumanHand, BothStacks) :-
	% Make sure that Err is an empty variable.
	var(Err),
	% Let the Human know that it is the HelpCPU that is showing its rationale.
	write('Help Computer:\n'),
	% Both rules will already display the reasoning for the optimal Tile and Stack placement, but now it is using the Human's Hand and using the CPU's topped Stacks as opposite Stacks.
	optimalTileInHand(w, HumanHand, BothStacks, OptimalTile),
	optimalStackPlacement(OptimalStackIndex, OptimalTile, w, BothStacks, HumanHand).
% Do nothing if something else is inputted.
displayHelp(_, Err, HumanHand, BothStacks).

% *********************************************************************
% Rule Name: validateTileInput
% Purpose: Validates input to see if it is both in the correct Tile format and if it has any valid Stack placements.
% Parameters:
% 		TileIndex, an int, string, or symbol that represents what the Human inputted in selectTileInHand().
% 		Err, a Catcher that records the error thrown from read().
% 		HumanHandSize, an int that represents the number of Tiles in HumanHand.
% 		BothStacks, a compounded list of CPUStacks and HumanStacks.
% 		HumanHand, a list of Tiles that represents the Tiles in the Human's Hand.
% 		IsValid, a boolean that indicates whether the Input is a valid Tile or not.
% Algorithm:
% 		1) Evaluate TileIndex.
% 			a) If TileIndex is 'help', then do nothing and set IsValid to false so that another Tile input is taken in selectTileInHand().
% 		2) Evaluate Err.
% 			a) If Err is assigned, do nothing.
% 			b) If Err is not assigned, continue.
% 		3) Evaluate the type and size of TileIndex.
% 			a) If TileIndex is not an integer, then let the Human know and set parameter IsValid to false.
% 			b) If TileIndex is less than 1, then let the Human know and set parameter IsValid to false.
% 			c) If TileIndex is greater than HumanHandSize, then let the Human know and set parameter IsValid to false.
% 		4) If the type and size of TileIndex is valid, get the Tile specified by the TileIndex in Hand and set that to TileSelected.
% 		5) Evaluate the valid Stack placements of TileSelected using validStackPlacements() and store them into ValidStacks.
% 			a) If ValidStacks is an empty list, then then let the Human know and set IsValid to false.
% 			b) If ValidStacks is not an empty list, then set IsValid to true.
% Assistance Received: None.
% *********************************************************************
% If the Human inputted 'help', then don't validate the input as a Tile. Set IsValid to false so that another Tile input is needed.
validateTileInput('help', _, _, _, _, false).
% If the number inputted is not an integer, is less than 1, or is greater than the number of Tiles in Hand, then it is invalid.
validateTileInput(TileIndex, Err, HumanHandSize, BothStacks, HumanHand, IsValid) :-
	% Check to make sure Err is an empty variable.
	var(Err),
	% Find if the index inputted is invalid.
	(\+integer(TileIndex) ; TileIndex < 1 ; TileIndex > HumanHandSize),
	write('Invalid Tile Index: Your input should be a number between 1-'), write(HumanHandSize), write('. Make sure your number is not surrounded by any punctuation. Please make another selection.\n'),
	% Number is invalid, so set IsValid to false.
	IsValid = false.
% If the number inputted is a valid integer but has no valid Stack placements, then it is invalid.
validateTileInput(TileIndex, Err, HumanHandSize, BothStacks, HumanHand, IsValid) :-
	% Check to make sure Err is an empty variable.
	var(Err),
	% Find if the index inputted is valid.
	integer(TileIndex), TileIndex >= 1, TileIndex =< TileIndex,
	% Find the Tile specified by the TileIndex and store it into TileSelected.
	getTileFromIndex(TileIndex, HumanHand, TileSelected, 1),
	validStackPlacements(TileSelected, BothStacks, ValidStacks),
	listLength(ValidStacks, ValidStackSize),
	% If the Tile has no valid Stack placements, then it is invalid. Let the Human know and set IsValid to false.
	ValidStackSize == 0,
	write('Invalid Tile Choice: Tile '), write(TileSelected), write(' has no valid Stack placements. Please make another selection.\n'),
	IsValid = false.
% If the number inputted is a valid integer and has valid Stack placements, then it is valid.
validateTileInput(TileIndex, Err, HumanHandSize, BothStacks, HumanHand, IsValid) :-
	% Check to make sure Err is an empty variable.
	var(Err),
	% Find if the index inputted is valid.
	integer(TileIndex), TileIndex >= 1, TileIndex =< TileIndex,
	% Find the Tile specified by the TileIndex and store it into TileSelected.
	getTileFromIndex(TileIndex, HumanHand, TileSelected, 1),
	validStackPlacements(TileSelected, BothStacks, ValidStacks),
	listLength(ValidStacks, ValidStackSize),
	% If the Tile has no valid Stack placements, then it is invalid.
	ValidStackSize > 0,
	IsValid = true.

% *********************************************************************
% Rule Name: findHandTileWithIndex
% Purpose: To find the Tile in Hand specified by TileIndex.
% Parameters:
% 		TileSelected, a list that represents the Tile extracted at the index in HumanHand.
% 		TileIndex, an int, that represents the index of the Tile in HumanHand to look for.
% 		CurrIndex, an int that represents the current Hand Tile index in question. Assumed to start at 1.
% 		HumanHand, a list of Tiles that represents the Tiles in the Human's Hand.
% Algorithm:
% 		1) Evaluate CurrIndex.
% 			a) If CurrIndex is equal to TileIndex, then set TileSelected to the Tile at element TileIndex in HumanHand.
% 			b) If Currindex is not equal to TileIndex, then evaluate the next index. Set NewCurrIndex to an incremented CurrIndex. Recursively call findHandTileWithIndex with everything the same except NewCurrIndex.
% Assistance Received: None.
% *********************************************************************
% (Where CurrIndex should start at 1 since TileIndex should start at 1).
% If the current Index is equal to the TileIndex, then take that Tile and save it to TileSelected.
findHandTileWithIndex(TileSelected, TileIndex, CurrIndex, HumanHand) :-
	TileIndex == CurrIndex,
	nth1(TileIndex, HumanHand, TileSelected).
% If the current index is not equal to the TileIndex, then iterate to the next Tile in the Hand.
findHandTileWithIndex(TileSelected, TileIndex, CurrIndex, HumanHand) :-
	TileIndex \= CurrIndex,
	NewCurrIndex is CurrIndex + 1,
	findHandTileWithIndex(TileSelected, TileIndex, NewCurrIndex, HumanHand).

% *********************************************************************
% Rule Name: selectStackPlacement
% Purpose: Lets the Human select a Stack to place their selected Tile onto and stores it into parameter StackSelected.
% Parameters:
% 		TmpStackSelected, a string, symbol, or int that represents the Human's input specifying what Stack they want to place TileSelected onto. Passed in as an empty variable.
% 		StackSelected, an int that represents the final input of a Stack index from the Human that is a valid Stack placement for TileSelected.
% 		TileSelected, a list that represents the Tile the Human selected in selectTileInHand().
% 		BothStacks, a compounded list of CPUStacks and HumanStacks.
% 		IsValid, a boolean that indicates whether the Stack inputted is valid or not.
% Algorithm:
% 		1) Evaluate IsValid.
% 			a) If IsValid is true, then set StackSelected to TmpStackSelected.
% 			b) If IsValid is false, then continue.
% 		2) Ask the Human to input a Stack number 1-12. Store the input into NewStackSelected.
% 		3) Validate the input using validateStackInput() and store the resulting indication of its validity into IsValid.
% 		4) Recursively call selectStackPlacement() to either re-evaluate a new input or to take the input and set StackSelected to it.
% Assistance Received: None.
% *********************************************************************
% If this is the first inquiry for a Stack placement or the previous input was invalid, take an input for a Stack placement.
selectStackPlacement(TmpStackSelected, StackSelected, TileSelected, BothStacks, false) :-
	write('Choose a Stack to place '), write(TileSelected), write(' onto. Enter a \"w\" or \"b\" followed by a digit 1-6. Example: \"w3\". Do not include any punctuation or spaces:\n'),
	catch(read(NewStackSelected), error(Err, _Context), write('Invalid Format: Input reading failed.\n')),
	% Validate both the formatting of the input and whether the Stack is a valid Stack placement for the Tile passed in.
	validateStackInput(TileSelected, NewStackSelected, Err, BothStacks, IsValid),
	% Recursively call the function to allow the proper handling of a correct or incorrect input both in format and choice.
	selectStackPlacement(NewStackSelected, StackSelected, TileSelected, BothStacks, IsValid).
% If the Stack input was valid, and the Stack placement is valid, then store the input into StackSelected.
selectStackPlacement(TmpStackSelected, TmpStackSelected, TileSelected, BothStacks, true).

% *********************************************************************
% Rule Name: validateStackInput
% Purpose: Validates whether the Stack input is valid both in format and is a valid Stack placement for the Tile passed in.
% Parameters:
% 		TileSelected, a list that represents the Tile the Human selected in selectTileInHand().
% 		StackSelected, an int that represents the final input of a Stack index from the Human that is a valid Stack placement for TileSelected.
% 		Err, a Catcher that records the error thrown from read().
% 		BothStacks, a compounded list of CPUStacks and HumanStacks.
% 		IsValid, a boolean that indicates whether the Stack inputted is valid or not.
% Algorithm:
% 		1) Evaluate Err.
% 			a) If Err is not an empty variable, then read() had failed before. Set IsValid to false and stop here.
% 			b) If Err is an empty variable, continue.
% 		2) Evaluate the type and size of StackSelected.
% 			a) If StackSelected is not an integer, then let the Human know and set parameter IsValid to false.
% 			b) If StackSelected is less than 1, then let the Human know and set parameter IsValid to false.
% 			c) If StackSelected is greater than 12, then let the Human know and set parameter IsValid to false.
% 		3) If the type and size of StackSelected is valid, get all of the valid Stack placements for TileSelected using validStackPlacements() and store the resulting list into ValidStacks. Get the top Stack Tile indicated by StackSelected and store it into StackTile.
% 		4) See if StackTile is a valid Stack placement for TileSelected using findTileInList() and put the resulting boolean value into IsFound.
% 		5) Evaluate IsFound.
% 			a) If IsFound is false, then let the Human know that they cannot place TileSelected onto the Stack specified and set IsValid to false so that selectStackPlacement() can take another input.
% 			b) If IsFound is true, then set IsValid to true.
% Assistance Received: None.
% *********************************************************************
% Rule that validates Stack input and will set IsValid to true if it is and false if it isn't.
% If read() failed, then it is definitely invalid.
validateStackInput(TileSelected, StackSelected, Err, BothStacks, IsValid) :-
	% Check to see if Err is not an empty variable.
	\+var(Err),
	write('Invalid Format: Input should be a \"w\" or \"b\" with a digit 1-6. Please make another selection.\n'),
	IsValid = false.
validateStackInput(TileSelected, StackSelected, Err, BothStacks, IsValid) :-
	% Check to make sure read() did not fail.
	var(Err),
	% Convert StackSelected to a string.
	term_string(StackSelected, StrStackSelected),
	% If the Human puts an uppercase character in the string, ensure that all characters are set to lowercase.
	string_lower(StrStackSelected, LCStrStackSelected),
	% Convert the string to a list of chars to evaluate each character.
	string_chars(LCStrStackSelected, CharStackSelected),
	% Validate that the Stack input is two characters long.
	listLength(CharStackSelected, StackLength),
	StackLength == 2,
	% Validate that the color is either a w or b.
	nth0(0, CharStackSelected, Color),
	(Color == w ; Color == b),
	% Validate that the number is between 1-6.
	nth0(1, CharStackSelected, CharStackNum),
	% Validate whether the second character is a number before converting.
	char_type(CharStackNum, digit),
	number_string(StackNum, [CharStackNum]),
	StackNum >= 1, StackNum =< 6,
	% All of the tests were passed, so set IsValid to true.
	IsValid = 'true'.
% If the Stack input was too small, let the Human know and set IsValid to false.
validateStackInput(TileSelected, StackSelected, Err, BothStacks, IsValid) :-
	% Check to make sure read() did not fail.
	var(Err),
	% Convert StackSelected to a string.
	term_string(StackSelected, StrStackSelected),
	% Convert the string to a list of chars so it can be evaluated.
	string_chars(StrStackSelected, CharStackSelected),
	listLength(CharStackSelected, StackLength),
	StackLength < 2,
	write('Invalid Length: Input too small. The Stack input should be two characters long, with the first character being a \"w\" or a \"b\" followed by a number 1-6. Please make another selection.\n'),
	% A test failed, so set IsValid to false.
	IsValid = 'false'.
% If the Stack input was too large, let the Human know and set IsValid to false.
validateStackInput(TileSelected, StackSelected, Err, BothStacks, IsValid) :-
	% Check to make sure read() did not fail.
	var(Err),
	% Convert StackSelected to a string.
	term_string(StackSelected, StrStackSelected),
	% Convert the string to a list of chars so it can be evaluated.
	string_chars(StrStackSelected, CharStackSelected),
	listLength(CharStackSelected, StackLength),
	StackLength > 2,
	write('Invalid Length: Input too large. The Stack input should be two characters long, with the first character being a \"w\" or a \"b\" followed by a number 1-6. Please make another selection.\n'),
	% A test failed, so set IsValid to false.
	IsValid = 'false'.
% If the Color was invalid, let the Human know and set IsValid to false.
validateStackInput(TileSelected, StackSelected, Err, BothStacks, IsValid) :-
	% Check to make sure read() did not fail.
	var(Err),
	% Convert StackSelected to a string.
	term_string(StackSelected, StrStackSelected),
	% If the Human puts an uppercase character in the string, ensure that all characters are set to lowercase.
	string_lower(StrStackSelected, LCStrStackSelected),
	string_chars(LCStrStackSelected, CharStackSelected),
	nth0(0, CharStackSelected, Color),
	Color \= b, Color \= w,
	write('Invalid Color: The color needs to be an uppercase or lowercase \"w\" or a \"b\" and needs to be followed by a digit between 1-6. Do not include any spaces. Please make another selection.\n'),
	% A test failed, so set IsValid to false.
	IsValid = 'false'.
% If the Stack number was too small, let the Human know and set IsValid to false.
validateStackInput(TileSelected, StackSelected, Err, BothStacks, IsValid) :-
	% Check to make sure read() did not fail.
	var(Err),
	% Convert StackSelected to a string.
	term_string(StackSelected, StrStackSelected),
	string_chars(StrStackSelected, CharStackSelected),
	nth0(1, CharStackSelected, CharStackNum),
	number_string(StackNum, [CharStackNum]),
	StackNum < 1,
	write('Invalid Stack Number: Stack number is too small. The Stack number needs to be a digit 1-6. Please make another selection.\n'),
	% A test failed, so set IsValid to false.
	IsValid = 'false'.
% If the Stack number was too large, let the Human know and set IsValid to false.
validateStackInput(TileSelected, StackSelected, Err, BothStacks, IsValid) :-
	% Check to make sure read() did not fail.
	var(Err),
	% Convert StackSelected to a string.
	term_string(StackSelected, StrStackSelected),
	string_chars(StrStackSelected, CharStackSelected),
	nth0(1, CharStackSelected, CharStackNum),
	number_string(StackNum, [CharStackNum]),
	StackNum > 6,
	write('Invalid Stack Number: Stack number is too large. The Stack number needs to be a digit 1-6. Please make another selection.\n'),
	% A test failed, so set IsValid to false.
	IsValid = 'false'.
% If the Stack number was not numeric, set IsValid to false, let the Human know 
validateStackInput(TileSelected, StackSelected, Err, BothStacks, IsValid) :-
	% Check to make sure read() did not fail.
	var(Err),
	% Convert StackSelected to a string.
	term_string(StackSelected, StrStackSelected),
	string_chars(StrStackSelected, CharStackSelected),
	nth0(1, CharStackSelected, CharStackNum),
	\+char_type(CharStackNum, digit),
	write('Invalid Stack Number: Stack number was not numeric. The Stack number needs to be a digit 1-6. Please make another selection.\n'),
	% A test failed, so set IsValid to false.
	IsValid = 'false'.

% *********************************************************************
% Rule Name: getTileFromIndex
% Purpose: Gets the Tile specified by the index passed in. Once the Counter equals Index, it will store the CurrTile into Tile. Assumes that Counter starts at 1 since the indeces of both the Stacks and Hands start at 1. Meant to be used to get Tiles from Stack or Hand indices.
% Parameters:
% 		Index, an int that represents the index in the list to look for.
% 		List, a list of Tiles that will be evaluated.
% 		Tile, a list that represents the Tile in List specified at Index. Passed in as an empty variable.
% 		Counter, an int that represents the current Index in question which will be compared with Index.
% Algorithm:
% 		1) Split List into two parts: a first element CurrTile and the rest of the list in Rest.
% 		2) Evaluate Counter.
% 			a) If Counter is equal to Index, then set parameter Tile to CurrTile.
%			b) If Counter is not equal to Index, then set NewCounter to an incremented Counter and recursively call getTileFromIndex() to evaluate the next Tile in List by passing in Rest instead of List and NewCounter instead of Counter.
% Assistance Received: None.
% *********************************************************************
% If the Counter equals Index, then set StackTile to the current Stack in question.
getTileFromIndex(Index, [CurrTile | Rest], Tile, Index) :-
	Tile = CurrTile.
% If the Counter does not equal Index, then evaluate the next Stack in Index.
getTileFromIndex(Index, [CurrTile | Rest], Tile, Counter) :-
	Counter \= Index,
	% Evaluate the next Stack recursively.
	NewCounter is Counter + 1,
	getTileFromIndex(Index, Rest, Tile, NewCounter).

% *********************************************************************
% Rule Name: findTileInList
% Purpose: Finds a Tile in a list of Tiles. IsFound will be set to true if found and false if not.
% Parameters:
% 		Tile, a list that represents the Tile to look for in List.
% 		List, a list of Tiles that is to be evaluated.
% 		IsFound, a boolean that indicates whether Tile has been found in List or not.
% Algorithm:
% 		1) Evaluate the number of Tiles in List.
% 			a) If List is empty, then set IsFound to false.
% 			b) If List is not empty, split it into two parts: first element CurrTile and the rest of the list into Rest.
% 		2) Evaluate CurrTile.
% 			a) If CurrTile is not equal to Tile, then recursively call findTileInList() and pass in Rest instead of List to evaluate the next Tile in List.
% 			b) If CurrTile is equal to Tile, then set IsFound to true.
% Assistance Received: None.
% *********************************************************************
% If there are no more Tiles to evaluate in the list, and the Tile has not been found, IsFound is false.
findTileInList(Tile, [], false).
% If the Tile passed in is not equal to the current Tile in question, then evaluate the next Tile in the list.
findTileInList(Tile, [CurrTile | Rest], IsFound) :-
	Tile \= CurrTile,
	findTileInList(Tile, Rest, IsFound).
% If the Tile passed in is equal to the current Tile in question, then set IsFound to true and stop evaluating.
findTileInList(Tile, [CurrTile | Rest], IsFound) :-
	Tile == CurrTile,
	IsFound = true.

% *********************************************************************
% Rule Name: placeOntoStack
% Purpose: Places the Tile selected onto the Stack selected. The counter on this should at 1 since Stack names start from 1. When the Counter equals StackSelected, it will replace the respective Stack with the TileSelected. This assumes that the Counter passed in is 1.
% Parameters:
% 		TileSelected, a list that represents the Tile the Player selected to place onto a Stack.
% 		StackSelected, an int that represents the index of the Stack that the Player specified to place TileSelected onto.
% 		CPUStacks, a list of Tiles that represents the CPU's 6 Stacks.
% 		HumanStacks, a list of Tiles that represents the Human's 6 Stacks.
% 		UpdatedCPUStacks, a list of Tiles that represents the CPU's 6 Stacks after TileSelected has been placed.
% 		UpdatedHumanStacks, a list of Tiles that represents the Human's 6 Stacks after TileSelected has been placed.
% 		Counter, and int that represents the current Stack index in question. Assumed to start at 1.
% Algorithm:
% 		1) Evaluate color of StackSelected.
% 			a) If the color is w, then evaluate the CPU's Stacks.
% 			b) If the color is b, then evaluate the Human's Stacks.
% 		2) Take the index from StackSelected and store it in Index.
% 		3) Split the Player's Stacks that StackSelected specifies into a first element CurrStack wand the rest of the Stacks into Rest.
% 		4) Set NewCounter to an incremented Counter.
% 		5) Recursively call placeOntoStack() but pass in Rest into the respective Player's Stacks and set the respective updated Stacks to NewUpdated Stacks.
% 		6) Evaluate Index.
% 			a) If Index is not equal to the Counter, then set the respective Stacks to an appended list of CurrStack and NewUpdated Player's Stacks.
% 			b) If Index is equal to the Counter, then set the respective Stacks to an appended list of TileSelected and NewUpdated Player's Stacks.
% 		7) Evaluate the respective Player's Stacks.
% 			a) If the Player's Stacks are empty, set the Updated Player's Stacks to an empty list and the other to their original Stacks.
% Assistance Received: None.
% *********************************************************************
% If the StackSelected is a CPUStack, keep the Human Stacks constant and evaluate the CPU Stacks.
% If there are no more CPU Stacks to evaluate, initialize the UpdatedCPUStacks to an empty list and keep the Human Stacks constant.
placeOntoStack(TileSelected, StackSelected, [], HumanStacks, UpdatedCPUStacks, UpdatedHumanStacks, Counter) :-
	UpdatedCPUStacks = [],
	UpdatedHumanStacks = HumanStacks.
% If the current Stack is not the StackSelected, then keep the current CPU Stack as is and add it to the UpdatedCPUStacks.
placeOntoStack(TileSelected, StackSelected, CPUStacks, HumanStacks, UpdatedCPUStacks, UpdatedHumanStacks, Counter) :-
	% Check if StackSelected is a CPUStack.
	term_string(StackSelected, StrStackSelected),
	string_chars(StrStackSelected, CharStackSelected),
	nth0(0, CharStackSelected, Color),
	Color == w,
	% Get the index of the Stack.
	nth0(1, CharStackSelected, CharIndex),
	% Convert the char index to an int.
	number_string(Index, [CharIndex]),
	% Check if the current Stack is not at the index in StackSelected.
	Index \= Counter,
	CPUStacks = [CurrStack | Rest],
	NewCounter is Counter + 1,
	placeOntoStack(TileSelected, StackSelected, Rest, HumanStacks, NewUpdatedCPUStacks, HumanStacks, NewCounter),
	UpdatedCPUStacks = [CurrStack | NewUpdatedCPUStacks],
	UpdatedHumanStacks = HumanStacks.
% If the current Stack is the StackSelected, then add the TileSelected to the UpdatedCPUStacks.
placeOntoStack(TileSelected, StackSelected, CPUStacks, HumanStacks, UpdatedCPUStacks, UpdatedHumanStacks, Counter) :-
	% Check if StackSelected is a CPUStack.
	term_string(StackSelected, StrStackSelected),
	string_chars(StrStackSelected, CharStackSelected),
	nth0(0, CharStackSelected, Color),
	Color == w,
	% Get the index of the Stack.
	nth0(1, CharStackSelected, CharIndex),
	% Convert the char index to an int.
	number_string(Index, [CharIndex]),
	% Check if the current Stack is at the index in StackSelected.
	Index == Counter,
	CPUStacks = [CurrStack | Rest],
	NewCounter is Counter + 1,
	placeOntoStack(TileSelected, StackSelected, Rest, HumanStacks, NewUpdatedCPUStacks, HumanStacks, NewCounter),
	UpdatedCPUStacks = [TileSelected | NewUpdatedCPUStacks],
	UpdatedHumanStacks = HumanStacks.
% If the StackSelected is a HumanStack, keep the CPU Stacks constant and evaluate the Human Stacks.
% If there are no more Human Stacks to evaluate, initialize the UpdatedHumanStacks to an empty list and keep the CPU Stacks constant.
placeOntoStack(TileSelected, StackSelected, CPUStacks, [], UpdatedCPUStacks, UpdatedHumanStacks, Counter) :-
	UpdatedCPUStacks = CPUStacks,
	UpdatedHumanStacks = [].
% If the current Stack is not the StackSelected, then keep the current Human Stack as is and add it to the UpdatedHumanStacks.
placeOntoStack(TileSelected, StackSelected, CPUStacks, HumanStacks, UpdatedCPUStacks, UpdatedHumanStacks, Counter) :-
	% Check if StackSelected is a HumanStack.
	term_string(StackSelected, StrStackSelected),
	string_chars(StrStackSelected, CharStackSelected),
	nth0(0, CharStackSelected, Color),
	Color == b,
	% Get the index of the Stack.
	nth0(1, CharStackSelected, CharIndex),
	% Convert the char index to an int.
	number_string(Index, [CharIndex]),
	% Check if the current Stack is not at the index in StackSelected.
	Index \= Counter,
	HumanStacks = [CurrStack | Rest],
	NewCounter is Counter + 1,
	placeOntoStack(TileSelected, StackSelected, CPUStacks, Rest, CPUStacks, NewUpdatedHumanStacks, NewCounter),
	UpdatedCPUStacks = CPUStacks,
	UpdatedHumanStacks = [CurrStack | NewUpdatedHumanStacks].
% If the current Stack is the StackSelected, then add the TileSelected to the UpdatedHumanStacks.
placeOntoStack(TileSelected, StackSelected, CPUStacks, HumanStacks, UpdatedCPUStacks, UpdatedHumanStacks, Counter) :-
	% Check if StackSelected is a HumanStack.
	term_string(StackSelected, StrStackSelected),
	string_chars(StrStackSelected, CharStackSelected),
	nth0(0, CharStackSelected, Color),
	Color == b,
	% Get the index of the Stack.
	nth0(1, CharStackSelected, CharIndex),
	% Convert the char index to an int.
	number_string(Index, [CharIndex]),
	% Check if the current Stack is at the index in StackSelected.
	Index == Counter,
	HumanStacks = [CurrStack | Rest],
	NewCounter is Counter + 1,
	placeOntoStack(TileSelected, StackSelected, CPUStacks, Rest, CPUStacks, NewUpdatedHumanStacks, NewCounter),
	UpdatedCPUStacks = CPUStacks,
	UpdatedHumanStacks = [TileSelected | NewUpdatedHumanStacks].

% *********************************************************************
% Rule Name: removeTileFromHand
% Purpose: Removes Tile from Hand passed in.
% Parameters:
% 		TileSelected, a list that represents the Tile the Player selected to place onto a Stack.
% 		Hand, a list of Tiles that will have TileSelected removed from it.
% 		UpdatedHand, a lsit of Tiles that will reflect Hand with TileSelected removed from it. Passed in as an empty variable.
% Algorithm:
% 		1) Split Hand into a first element CurrTile and the rest into Rest..
% 		2) Evaluate the number of Tiles in Hand with listLength and store it into handSize.
% 			a) If there is only one Tile left in Hand and the TileSelected is not equal to the CurrTile, set UpdatedHand to a list holding CurrTile.
% 			b) If there is only one Tile left in Hand and the TileSelected is equal to the CurrTile, set UpdatedHand to an empty list.
% 			c) If there is more than one Tile left in Hand and the TileSelected is not equal to the CurrTile, recursively call removeTileFromHand() and pass in Rest for Hand and NewHand for UpdatedHand. Set UpdatedHand to an appended list of CurrTile and NewHand.
% 			d) If there is more than one Tile left in Hand and the TileSelected is equal to the CurrTile, recursively call removeTileFromHand() and pass in Rest for Hand and NewHand for UpdatedHand. Set UpdatedHand to NewHand.
% Assistance Received: None.
% *********************************************************************
% If it is the last Hand Tile in question and the current Hand Tile in question is not the Tile Selected, then add it as a single element in a list of Tiles in UpdatedHand.
removeTileFromHand(TileSelected, Hand, UpdatedHand) :-
	Hand = [CurrTile | Rest],
	listLength(Hand, HandSize),
	HandSize == 1,
	% If the Tile selected is not equal to the current HandTile in question, then add it to NewHand.
	TileSelected \= CurrTile,
	UpdatedHand = [CurrTile].
% If it is the last Hand Tile in question and the current Hand Tile in question is the Tile Selected, then don't add it to the UpdatedHand and make it an empty list to start off.
removeTileFromHand(TileSelected, Hand, UpdatedHand) :-
	Hand = [CurrTile | Rest],
	listLength(Hand, HandSize),
	HandSize == 1,
	% If the Tile selected is not equal to the current HandTile in question, then add it to NewHand.
	TileSelected == CurrTile,
	UpdatedHand = [].
% If it is not the last Hand Tile in question and the current HandTile in question is not the Tile Selected...
removeTileFromHand(TileSelected, Hand, UpdatedHand) :-
	Hand = [CurrTile | Rest],
	listLength(Hand, HandSize),
	HandSize > 1,
	% If the Tile selected is not equal to the current HandTile in question, then add it to the UpdatedHand.
	TileSelected \= CurrTile,
	removeTileFromHand(TileSelected, Rest, NewHand),
	% If the Tile selected is not equal to the current HandTile in question, then add it to NewHand.
	UpdatedHand = [CurrTile | NewHand].
% If it is not the last Hand Tile in question and the current HandTile in question is the Tile Selected, then don't add it to the UpdatedHand and keep it constant.
removeTileFromHand(TileSelected, Hand, UpdatedHand) :-
	Hand = [CurrTile | Rest],
	listLength(Hand, HandSize),
	HandSize > 1,
	% If the Tile selected is equal to the current HandTile in question, then don't add it to the UpdatedHand.
	TileSelected == CurrTile,
	removeTileFromHand(TileSelected, Rest, NewHand),
	UpdatedHand = NewHand.

% *********************************************************************
% Rule Name: getOppositeTurn
% Purpose: Sets OppositeTurn to the opposite turn of the PlayerTurn passed in.
% Parameters:
% 		PlayerTurn, a string that represents the current turn.
% 		OppositeTurn, a string that represents the opposite of the current turn.
% Algorithm:
% 		1) Evaluate PlayerTurn.
% 			a) If PlayerTurn is 'computer', then OppositeTurn is 'human'.
% 			b) If PlayerTurn is 'human', then the OppositeTurn is 'computer'.
% Assistance Received: None.
% *********************************************************************
% If the current turn is the Computer's, it's opposite is the Human's.
getOppositeTurn(PlayerTurn, OppositeTurn) :-
	PlayerTurn == 'computer',
	OppositeTurn = 'human'.
% If the current turn is the Human's, it's opposite is the Computer's.
getOppositeTurn(PlayerTurn, OppositeTurn) :-
	PlayerTurn == 'human',
	OppositeTurn = 'computer'.

% *********************************************************************
% Rule Name: getScoresFromStacks
% Purpose: Takes scores from Stacks at the end of a Hand.
% Parameters:
% 		BothStacks, an appended list of CPUStacks and HumanStacks and will be evaluated.
% 		CPUScore, an int that represents the CPU's score before getScoresFromStacks() ran.
% 		HumanScore, an int that represents the Human's score before getScoresFromStacks() ran.
% 		UpdatedCPUScore, an int that represents the CPU's score after all of BothStacks are evaluated.
% 		UpdatedHumanScore, an int that represents the Human's score after all of BothStacks are evaluated.
% Algorithm:
% 		1) Evaluate the number of Stacks in BothStacks.
% 			a) If BothStacks is an empty list, set UpdatedCPUScore to CPUScore, which has been changed through each recursive call up to this point.
% 			b) If BothStacks is not an empty list then split it into a first element CurrStack and the rest of the elements into Rest.
% 		2) Take the first element from CurrStack and store it into Color.
% 		3) Get the total pips from CurrStack and store it into TotalPips.
% 		4) Evaluate Color.
% 			a) If Color is w, then create NewCPUScore and set it to CPUScore + TotalPips.
% 			b) If Color is b, then create NewHumanScore and set it to HumanScore + TotalPips.
% 		5) Recursively call getScoresFromStacks() but with Rest instead of BothStacks and the New Player's score instead of their old score and keep everything else the same.
% Assistance Received: None.
% *********************************************************************
% If there are no more Stacks to evaluate, set the updated scores to the "original" scores as they have accumulated.
getScoresFromStacks([], CPUScore, HumanScore, UpdatedCPUScore, UpdatedHumanScore) :-
	UpdatedCPUScore = CPUScore,
	UpdatedHumanScore = HumanScore.
% If the current Stack has a white Tile on top of it, then add its pips to the CPU's score.
getScoresFromStacks(BothStacks, CPUScore, HumanScore, UpdatedCPUScore, UpdatedHumanScore) :-
	BothStacks = [CurrStack | Rest],
	% Check if the Stack in question has a white Tile on top of it.
	nth0(0, CurrStack, Color),
	Color == w,
	getTotalPips(CurrStack, TotalPips),
	NewCPUScore is CPUScore + TotalPips,
	% Recursively call to evaluate the next Stack.
	getScoresFromStacks(Rest, NewCPUScore, HumanScore, UpdatedCPUScore, UpdatedHumanScore).
% If the current Stack has a black Tile on top of it, then add its pips to the Human's score.
getScoresFromStacks(BothStacks, CPUScore, HumanScore, UpdatedCPUScore, UpdatedHumanScore) :-
	BothStacks = [CurrStack | Rest],
	% Check if the Stack in question has a white Tile on top of it.
	nth0(0, CurrStack, Color),
	Color == b,
	getTotalPips(CurrStack, TotalPips),
	NewHumanScore is HumanScore + TotalPips,
	% Recursively call to evaluate the next Stack.
	getScoresFromStacks(Rest, CPUScore, NewHumanScore, UpdatedCPUScore, UpdatedHumanScore).

% *********************************************************************
% Rule Name: handleLeftoverTiles
% Purpose: Handles leftover Tiles in Hand and subtracts from the respective Players' scores.
% Parameters:
% 		CPUHand, a list of Tiles that represents the Tiles in the CPU's Hand.
% 		HumanHand, a list of Tiles that represents the Tiles in the Human's Hand.
% 		CPUScore, an int that represents the CPU's score. Will be modified through each recursive call.
% 		HumanScore, an int that represents the Human's score. Will be modified through each recursive call.
% 		UpdatedCPUScore, an int that represents the CPU's score after handleLeftoverTiles() evaluated all Hand Tiles. Passed in as an empty variable.
% 		UpdatedHumanScore, an int that represents the Human's score after handleLeftoverTiles() evaluated all Hand Tiles. Passed in as an empty variable.
% Algorithm:
% 		1) Evaluate the number of Tiles in each Player's Hand.
% 			a) If both Hands are empty lists, then set UpdatedCPUScore to CPUScore and UpdatedHumanScore to HumanScore.
% 			b) If only the CPU's Hand has at least one Tile, split it into first element CurrCPUTile and the rest into RestCPUHand.
% 			c) If only the Human's Hand has at least one Tile, split it into first element CurrHumanTile and the rest into RestHumanHand.
% 			d) If both Player's Hands have at least one Tile, split both of them.
% 		2) Take the pips from the respective first Hand Tiles and store them into their own pip variables.
% 		3) Set the respective Player(s) new score variables to their old scores minus their respective pip variables.
% 		4) Recursively call handleLeftoverTiles() but pass in the rest of the respective Player(s) Hands into their respective Hand parameters.
% Assistance Received: None.
% *********************************************************************
% If there are no more (or no) Tiles to evaluate, then set the Players' updated scores to their previous (or modified) values.
handleLeftoverTiles([], [], CPUScore, HumanScore, CPUScore, HumanScore).
% If only the CPU has a Tile to evaluate, subtract only from the CPU's score.
handleLeftoverTiles([CurrCPUTile | RestCPUHand], [], CPUScore, HumanScore, UpdatedCPUScore, UpdatedHumanScore) :-
	% Get the pips from the current CPU Tile in question.
	getTotalPips(CurrCPUTile, CPUPips),
	% Subtract the pips from the CPU's score.
	NewCPUScore is CPUScore - CPUPips,
	% Evaluate the next Tile in the CPU's Hand and pass the modified CPU score.
	handleLeftoverTiles(RestCPUHand, [], NewCPUScore, HumanScore, UpdatedCPUScore, UpdatedHumanScore).
% If only the Human has a Tile to evaluate, subtract only from the Human's score.
handleLeftoverTiles([], [CurrHumanTile | RestHumanHand], CPUScore, HumanScore, UpdatedCPUScore, UpdatedHumanScore) :-
	% Get the pips from the current CPU Tile in question.
	getTotalPips(CurrHumanTile, HumanPips),
	% Subtract the pips from the CPU's score.
	NewHumanScore is HumanScore - HumanPips,
	% Evaluate the next Tile in the CPU's Hand and pass the modified CPU score.
	handleLeftoverTiles([], RestHumanHand, CPUScore, NewHumanScore, UpdatedCPUScore, UpdatedHumanScore).
% If both Players have at least a Tile to evaluate, then subtract from the Updated Players' scores.
handleLeftoverTiles([CurrCPUTile | RestCPUHand], [CurrHumanTile | RestHumanHand], CPUScore, HumanScore, UpdatedCPUScore, UpdatedHumanScore) :-
	% Get the pips from both Players' first Tiles in their Hands.
	getTotalPips(CurrCPUTile, CPUPips),
	getTotalPips(CurrHumanTile, HumanPips),
	% Subtract the pips from both Players' scores.
	NewCPUScore is CPUScore - CPUPips,
	NewHumanScore is HumanScore - HumanPips,
	% Evaluate the next Tile in the Hands and pass the modified Players' scores.
	handleLeftoverTiles(RestCPUHand, RestHumanHand, NewCPUScore, NewHumanScore, UpdatedCPUScore, UpdatedHumanScore).

% *********************************************************************
% Rule Name: declareWinnerOfRound
% Purpose: Declares the winner of a Round with scores of each Players given and awards the win to the respective Player(s).
% Parameters:
% 		RoundNum, an int that represents the current Round number.
% 		CPUScore, an int that represents the CPU's score. Will be modified through each recursive call.
% 		HumanScore, an int that represents the Human's score. Will be modified through each recursive call.
% 		CPUWins, an int that represents the CPU's Rounds won.
% 		HumanWins, an int that represents the Human's Rounds won.
% 		UpdatedCPUWins, an int that represents the modified CPU's Rounds won after declareWinnerOfRound() has evaluated which Player won or if it was a draw.
% 		UpdatedHumanWins, an int that represents the modified Human's Rounds won after declareWinnerOfRound() has evaluated which Player won or if it was a draw.
% Algorithm:
% 		1) Evaluate and compare parameters CPUScore and HumanScore.
% 			a) If CPUScore is greater than HumanScore, then declare that the CPU won and set UpdatedCPUWins to an incremented CPUWins and UpdatedHumanWins to HumanWins.
% 			b) If HumanScore is greater than CPUScore, then declare that the Human won and set UpdatedCPUWins to CPUWins and UpdatedHumanWins to an incremented HumanWins.
% 			c) If CPUSCore and HumanScore are equal, then declare that it was a draw and set UpdatedCPUWins to an incremented CPUWins and UpdatedHumanWins to an incremented HumanWins.
% Assistance Received: None.
% *********************************************************************
% If the CPU has more points than the Human, then the winner is the CPU.
declareWinnerOfRound(RoundNum, CPUScore, HumanScore, CPUWins, HumanWins, UpdatedCPUWins, UpdatedHumanWins) :-
	CPUScore > HumanScore,
	write('The winner of Round #'), write(RoundNum), write(' is the Computer!\n'),
	UpdatedCPUWins is CPUWins + 1,
	UpdatedHumanWins is HumanWins.
% If the Human has more points than the CPU, then the winner is the Human.
declareWinnerOfRound(RoundNum, CPUScore, HumanScore, CPUWins, HumanWins, UpdatedCPUWins, UpdatedHumanWins) :-
	CPUScore < HumanScore,
	write('The winner of Round #'), write(RoundNum), write(' is the Human!\n'),
	UpdatedCPUWins is CPUWins,
	UpdatedHumanWins is HumanWins + 1.
% If both Players have the same score, then it is a draw.
declareWinnerOfRound(RoundNum, CPUScore, HumanScore, CPUWins, HumanWins, UpdatedCPUWins, UpdatedHumanWins) :-
	CPUScore == HumanScore,
	write('Round #'), write(RoundNum), write(' is a draw! Both Players will be awarded a win.\n'),
	UpdatedCPUWins is CPUWins + 1,
	UpdatedHumanWins is HumanWins + 1.

% *********************************************************************
% Rule Name: anotherRoundQuery
% Purpose: Asks the Human if they want to start another Round or not. Will recursively call until a y or n response is received. If yes, then it will do nothing (letting playRound recursively call itself). If no, then it will call declareWinnerOfTournament().
% Parameters:
% 		Input, a symbol, string, or int that represents the Human's input.
% 		Err, a Catcher that records the error thrown from read().
% 		RoundNum, an int that represents the current Round number.
% 		CPUWins, an int that represents the CPU's Rounds Won.
% 		HumanWins, an int that represents the Human's Rounds Won.
% Algorithm:
% 		1) Evaluate Err.
% 			a) If Err is not an empty variable, then let the Human know that the input was invalid and take another through a recursive call.
% 			b) If Err is an empty variable, continue.
% 		2) Evaluate Input.
% 			a) If Input is y, then call initRound() to start a new Round. Set NewRoundNum to an incremented RoundNum. Then call playRound() with the newly initialized Boneyards, Stacks, and FirstPlayer. Set StartingHandNum to 1.
% 			b) If Input is n, display the Players' Rounds Won and call declareWinnerOfTournament() to end the game.
% 			c) If Input is anything else, declare that the input was invalid and take a new input into Input. Recursively call anotherRoundQuery() and pass in Input to re-evaluate the new input.
% Assistance Received: None.
% *********************************************************************
% If the Human wants to start another Round, start a new Round and pass in the incremented Round number and the Players' Rounds won.
anotherRoundQuery(y, Err, RoundNum, CPUWins, HumanWins) :-
	% Check to make sure read() did not fail.
	var(Err),
	% Initialize a new Round.
	initRound(WhiteBoneyard, BlackBoneyard, CPUStacks, HumanStacks, FirstPlayer),
	% Increment Round number.
	NewRoundNum is RoundNum + 1,
	% Play the new Round.
	playRound(false, NewRoundNum, WhiteBoneyard, BlackBoneyard, CPUStacks, HumanStacks, RestCPUHand, RestHumanHand, CPUScore, HumanScore, CPUWins, HumanWins, FirstPlayer, 1).
% If the Human does not want to play another Round, then declare the winner of the Tournament and end the game.
anotherRoundQuery(n, Err, RoundNum, CPUWins, HumanWins) :-
	% Check to make sure read() did not fail.
	var(Err),
	write('___________________________________________________\n\n'),
	write('Computer\'s Rounds Won: '), write(CPUWins), nl,
	write('Human\'s Rounds Won: '), write(HumanWins), nl,
	declareWinnerOfTournament(CPUWins, HumanWins).
% If the input is invalid, ask for another input.
anotherRoundQuery(_, _, RoundNum, CPUWins, HumanWins) :-
	write('Invalid input. Please enter a \"y\" or \"n\".\n'),
	% Take another input.
	write('Do you want to start another Round (y) or do you want to end the Tournament (n)?\n'),
	catch(read(Input), error(Err, _Context), write('Invalid Format: Input reading failed.\n')),
	anotherRoundQuery(Input, Err, RoundNum, CPUWins, HumanWins).

% *********************************************************************
% Rule Name: declareWinnerOfTournament
% Purpose: Declares which Player won the Tournament based on the Players' wins.
% Parameters:
% 		CPUWins, an int that represents the CPU's Rounds Won.
% 		HumanWins, an int that represents the Human's Rounds Won.
% Algorithm:
% 		1) Evaluate and compare CPUWins with HumanWins.
% 			a) If CPUWins is greater than HumanWins, then declare that the CPU won. Thank the Human for playing and use halt() to end the program.
% 			b) If HumanWins is greater than CPUWins, then declare that the Human won. Thank the Human for playing and use halt() to end the program.
% 			c) If CPUWins and HumanWins are equal, then declare that it was a draw. Thank the Human for playing and use halt() to end the program.
% Assistance Received: None.
% *********************************************************************
% If the CPU won more Rounds, then the CPU won the Tournament.
declareWinnerOfTournament(CPUWins, HumanWins) :-
	CPUWins > HumanWins,
	write('The winner of the Tournament is the Computer!\n'),
	write('___________________________________________________\n\n'),
	write('Thank you for playing!\n'),
	write('___________________________________________________\n\n'),
	halt(0).
% If the Human won more Rounds, then the Human won the Tournament.
declareWinnerOfTournament(CPUWins, HumanWins) :-
	CPUWins < HumanWins,
	write('The winner of the Tournament is the Human!\n'),
	write('___________________________________________________\n\n'),
	write('Thank you for playing!\n'),
	write('___________________________________________________\n\n'),
	halt(0).
% If both Players have the same number of Rounds won, then it is a draw and neither wins.
declareWinnerOfTournament(CPUWins, HumanWins) :-
	CPUWins == HumanWins,
	write('There is a draw, neither Player win the Tournament!\n'),
	write('___________________________________________________\n\n'),
	write('Thank you for playing!\n'),
	write('___________________________________________________\n\n'),
	halt(0).
	

% *********************************************
% Source Code for serialization.
% *********************************************

% *********************************************************************
% Rule Name: suspendQuery
% Purpose: Asks the Human whether to suspend the game or not. y = suspend, n = continue the game.
% Parameters:
% 		Input, a symbol, string, or int that represents what the Human inputted.
% 		Err, a Catcher that records the error thrown from read().
% 		RoundData, a list that holds all relevant Round data that needs to be saved to a file (CPU info, Human info, current turn).
% Algorithm:
% 		1) Evaluate Input.
% 			a) If Input is y, then the Human wants to suspend the game. Let the Human know that the game is being suspended and use saveToFile() to save to a file specified by the Human.
% 			b) If Input is n, then do nothing so the calling playTurns() can continue.
% 			c) If Input is anything else, then let the Human know that the input was invalid and take another input into NewInput. Recursively call suspendQuery() and pass in NewInput to re-evaluate the Human's input.
% Assistance Received: None.
% *********************************************************************
% If the Input was "y", then suspend the game.
suspendQuery(y, Err, RoundData) :-
	% Check to make sure read() did not fail.
	var(Err),
	write('Suspending the game...\n'),
	saveToFile(SaveFileName, NewErr, RoundData, false, true),
	halt(0).
% If the Input was "n", then do nothing.
suspendQuery(n, Err, RoundData) :-
	% Check to make sure read() did not fail.
	var(Err).
% If the Input is anything else, then ask for another input.
suspendQuery(_, _, RoundData) :-
	write('Invalid input. Please enter a \"y\" or \"n\".\n'),
	write('Do you wish to suspend the game? (y/n):\n'),
	catch(read(Input), error(Err, _Context), write('Invalid Format: Input reading failed.\n')),
	suspendQuery(Input, Err, RoundData).

% *********************************************************************
% Rule Name: saveToFile
% Purpose: Lets the Human input a save file to save to. If a correct input is detected, the data is saved to the save file specified. If the input is not valid, then another input is taken.
% Parameters:
% 		SaveFile, a compound that represents the save file with the .txt extension.
% 		Err, a Catcher that records the error thrown from read().
% 		RoundData, a list that represents all of the Round's data that would need to be stored.
% 		IsValid, a boolean that indicates if the Human's input for a save file is valid. Initially passed in as false.
% 		CancelOverwrite, a boolean that indicates if the Human has cancelled the overwrite of a file or not. Initially passed in as true.
% Algorithm:
% 		1) Evaluate IsValid and CancelOverwrite.
% 			a) If IsValid is false or CancelOverwrite is true, take another input from the Human for a save file an save it to NewSaveFile. Validate the Input with NewSaveFile and update NewIsValid to indicate if the input was valid. Convert NewSaveFile to an atom AtomSaveFile. Pass NewIsValid and AtomSaveFile into considerOverwrite() and update NewCancelOverwrite. Recursively callsaveToFile() and pass in AtomSaveFile, RoundData, NewIsValid, NewCancelOverwrite.
% 			b) If IsValid is true and CancelOverwrite as false, then write RoundData's info into the save file specified by SaveFile.
% Assistance Received: None.
% *********************************************************************
saveToFile(SaveFile, _, RoundData, IsValid, CancelOverwrite) :-
	% If the save file inputted was not valid or overwriting of a previous savefile was cancelled, take another input.
	(IsValid == false ; CancelOverwrite == true),
	write('Please enter a file you want to save to. Make sure to put \".txt\" at the end of your filename. Example: \"mySaveFile.txt.\".\n'),
	catch(read(NewSaveFile), error(Err, _Context), write('Invalid Format: Input reading failed.\n')),
	% Validate the format of the save file inputted.
	validateSaveFileInput(NewSaveFile, Err, NewIsValid),
	% Convert the term to an atom so that it can be interpreted and written correctly.
	term_to_atom(NewSaveFile, AtomSaveFile),
	% Check to see if the file exists. If it does, confirm with the Human whether to overwrite the file or not. If so, then continue with saving to the file. If the Human does not want to, then another save file will be taken.
	considerOverwrite(NewIsValid, AtomSaveFile, NewCancelOverwrite),
	% Pass in the valid and overwrite flags and handle it accordingly. If it is valid, the save file as an atom will be passed through.
	saveToFile(AtomSaveFile, Err, RoundData, NewIsValid, NewCancelOverwrite).
% If the save file was valid and the overwrite was not cancelled, write to the file specified.
saveToFile(SaveFile, Err, RoundData, true, false) :-
	% Check to make sure read() did not fail.
	var(Err),
	write('Saving to '), write(SaveFile), write('...\n'),
	% Write to the file specified what is in StreamFileData. If anything is in the file already, it will be truncated.
	open(SaveFile, write, StreamFileData),
	% Divide the RoundData into parts to make the saving process easier.
	RoundData = [CPUData, HumanData, CurrTurn],

	% Put all the Round's data into a Stream.
	write(StreamFileData, '[\n'),

	% Divide the CPU's data into parts for readability.
	CPUData = [CPUStacks, WhiteBoneyard, CPUHand, CPUScore, CPUWins],
	% Save all of the CPU's data to the file.
	write(StreamFileData, '   [\n'),
	% Save the Stacks to the file.
	write(StreamFileData, '      '), write(StreamFileData, CPUStacks), write(StreamFileData, ',\n'),
   	% Save the Boneyard to the file.
	write(StreamFileData, '      '), write(StreamFileData, WhiteBoneyard), write(StreamFileData, ',\n'),
   	% Save the Hand to the file.
	write(StreamFileData, '      '), write(StreamFileData, CPUHand), write(StreamFileData, ',\n'),
   	% Save the Score to the file.
	write(StreamFileData, '      '), write(StreamFileData, CPUScore), write(StreamFileData, ',\n'),
   	% Save the Rounds Won to the file.
	write(StreamFileData, '      '), write(StreamFileData, CPUWins), write(StreamFileData, '\n'),
	write(StreamFileData, '   ],\n'),

	% Divide the Human's data into parts for readability.
	HumanData = [HumanStacks, BlackBoneyard, HumanHand, HumanScore, HumanWins],
	% Save all of the Human's data to the file.
	write(StreamFileData, '   [\n'),
	% Save the Stacks to the file.
	write(StreamFileData, '      '), write(StreamFileData, HumanStacks), write(StreamFileData, ',\n'),
   	% Save the Boneyard to the file.
	write(StreamFileData, '      '), write(StreamFileData, BlackBoneyard), write(StreamFileData, ',\n'),
   	% Save the Hand to the file.
	write(StreamFileData, '      '), write(StreamFileData, HumanHand), write(StreamFileData, ',\n'),
   	% Save the Score to the file.
	write(StreamFileData, '      '), write(StreamFileData, HumanScore), write(StreamFileData, ',\n'),
   	% Save the Rounds Won to the file.
	write(StreamFileData, '      '), write(StreamFileData, HumanWins), write(StreamFileData, '\n'),
	write(StreamFileData, '   ],\n'),

	% Save the current turn to the file.
	write(StreamFileData, '   '), write(StreamFileData, CurrTurn), write(StreamFileData, '\n'),

	write(StreamFileData, '].').

% *********************************************************************
% Rule Name: validateSaveFileInput
% Purpose: Validates the save file specified by the Human and updates IsValid to indicate whether it was or not.
% Parameters:
% 		SaveFile, a compound that represents the save file with the .txt extension.
% 		Err, a Catcher that records the error thrown from read().
% 		IsValid, a boolean that indicates if the Human's input for a save file is valid. Initially passed in as an empty variable.
% Algorithm:
% 		1) Evaluate SaveFile.
% 			a) If SaveFile is 'cancel', then do nothing.
% 			b) Otherwise, continue.
% 		2) Evaluate Err.
% 			a) If Err is not an empty variable, let the Human know that the save file is not in the right format and set IsValid to false.
% 			b) If Err is an empty variable, continue.
% 		3) Turn SaveFile into a string using term_string() and store that string value into StrSaveFile.
% 		4) Use split_string() on StrSaveFile to split the elements of the string by "." and save the elements into Elements.
% 		5) Evaluate the number of Elements.
% 			a) If the number of Elements does not equal 2, then it is an invalid format. Let the Human know that it is invalid and set IsValid to false.
% 			b) If the number of elements is equal to 2, continue.
% 		6) Evaluate second element in Elements.
% 			a) If the second element in Elements does not equal "txt", then the extension is not .txt. Set IsValid to false.
% 			b) If the second element in Elements equals "txt", then the extension is .txt. Set IsValid to true.
% Assistance Received: split_string() learned from https://www.swi-prolog.org/pldoc/man?predicate=split_string/4.
% *********************************************************************
validateSaveFileInput('cancel', _, IsValid).
	% If read() failed before validateSaveFileInput() was called, then the input was defninitely not valid.
validateSaveFileInput(SaveFile, Err, IsValid) :-
	\+var(Err),
	write('Invalid Format: Please make sure the file has a name that ends with \".txt\". Please make another selection.\n'),
	IsValid = false.
validateSaveFileInput(SaveFile, Err, IsValid) :-
	% Check to make sure read() did not fail.
	var(Err),
	term_string(SaveFile, StrSaveFile),
	split_string(StrSaveFile, ".", " ", Elements),
	listLength(Elements, ElementsSize),
	ElementsSize \= 2,
	write('Invalid Format: Please make sure the file has a name that ends with \".txt\". Please make another selection.\n'),
	IsValid = false.
validateSaveFileInput(SaveFile, Err, IsValid) :-
	% Check to make sure read() did not fail.
	var(Err),
	term_string(SaveFile, StrSaveFile),
	split_string(StrSaveFile, ".", " ", Elements),
	listLength(Elements, ElementsSize),
	ElementsSize == 2,
	nth0(1, Elements, Extension),
	Extension \= "txt",
	write('Invalid Format: The extension of the file needs to be \".txt\". Please make another selection.\n'),
	IsValid = false.
validateSaveFileInput(SaveFile, Err, IsValid) :-
	% Check to make sure read() did not fail.
	var(Err),
	term_string(SaveFile, StrSaveFile),
	split_string(StrSaveFile, ".", " ", Elements),
	listLength(Elements, ElementsSize),
	ElementsSize == 2,
	nth0(1, Elements, Extension),
	Extension == "txt",
	IsValid = true.

% *********************************************************************
% Rule Name: considerOverwrite
% Purpose: Determines whether to ask the Human to cancel overwriting an existing save file if the file specified already exists. If the file does exist, the Human's choice is inputted with overwriteQuery().
% Parameters:
% 		IsValid, a boolean that indicates if the Human's input for a save file is valid.
% 		SaveFile, a compound that represents the save file that the Human inputted.
% 		CancelOverwrite, a boolean that indicates whether the Human wants to overwrite the SaveFile or not. Passed in as an empty variable.
% Algorithm:
% 		1) Evaluate IsValid.
% 			a) If it is false, then set CancelOverwrite to false.
% 			b) Otherwise, continue.
% 		2) Using fileExists() detremine if the save file with the name SaveFile exists using fileExists and store the result into Exists.
% 		3) Evaluate Exists.
% 			a) If Exists is false, then CancelOverwrite is false.
% 			b) If Exists is true, use overwriteQuery to determine if the Human wants to cancel the overwrite or not. The result will be stored in parameter CancelOverwrite.
% Assistance Received: None.
% *********************************************************************
considerOverwrite(false, SaveFile, false).
% If the file did not exist in the first place, then there is no overwriting to even consider. Do nothing and set CancelOverwrite to false to continue saving to the file specified in saveToFile().
considerOverwrite(true, SaveFile, CancelOverwrite) :-
	fileExists(SaveFile, Exists),
	Exists == false,
	CancelOverwrite = false.
% If the file specified does exist, ask the Human whether they wish to overwrite or not, and get the result in CancelOverwrite.
considerOverwrite(true, SaveFile, CancelOverwrite) :-
	fileExists(SaveFile, Exists),
	Exists == true,
	overwriteQuery(SaveFile, Err, Input, CancelOverwrite).

% *********************************************************************
% Rule Name: overwriteQuery
% Purpose: Asks whether the Human wants to overrite the save file they specified. If so, do nothing so that saveToFile() continues. If not, then CancelOverwrite will be set to true.
% Parameters:
% 		SaveFile, a compound that represents the save file that the Human inputted.
% 		Err, a Catcher that records the error thrown from read().
% 		Input, a symbol, int, or string that represents the input from the Human. Initially passed in as an empty variable.
% 		CancelOverwrite, a boolean that indicates whether the Human wants to overwrite the file specified by SaveFile or not. Passed in as an empty variable.
% Algorithm:
% 		1) Evaluate Err.
% 			a) If Err is not an empty variable, take another input and evaluate it throuhg recursion.
% 			b) If Err is an empty variable, then continue.
% 		2) Evaluate Input.
% 			a) If Input is n, then let the Human know that the overwrite of SaveFile is being cancelled and set parameter CancelOverwrite to true.
% 			b) If Input is y, then let the Human know that the file SaveFile is going to be overwritten and set CancelOverwrite to false.
% 			c) If Input is anything else, then take another input and save it to NewInput. Recursively call overwriteQuery() and pass in NewInput to re-evaluate the new input.
% Assistance Received: None.
% *********************************************************************
% If the file exists and the Human does not want to overwrite, then do nothing so saveToFile() can take another input. Set CancelOverwrite to true.
overwriteQuery(SaveFile, Err, Input, CancelOverwrite) :-
	% Check to make sure read() did not fail.
	var(Err),
	Input == n,
	write('Cancelling overwrite of '), write(SaveFile), nl,
	CancelOverwrite = true.
% If the file exists and the Human does want to overwrite, then set CancelOverwrite to false.
overwriteQuery(SaveFile, Err, Input, CancelOverwrite) :-
	% Check to make sure read() did not fail.
	var(Err),
	Input == y,
	write('Overwriting '), write(SaveFile), nl,
	CancelOverwrite = false.
% If the file exists, take an input to determine whether to overwrite the file or not.
overwriteQuery(SaveFile, Err, Input, CancelOverwrite) :-
	write('Overwrite '), write(SaveFile), write('? (y/n):\n'),
	catch(read(NewInput), error(NewErr, _Context), write('Invalid Format: Input reading failed.\n')),
	overwriteQuery(SaveFile, NewErr, NewInput, CancelOverwrite).

% *********************************************************************
% Rule Name: findSaveFile
% Purpose: Allows the Human to enter a filename to save from and checks to see if that file exists. Recursively calls until a save file is found or the Human changes their mind and cancels restoring from a save file.
% Parameters:
% 		SaveFile, a compound that represents the save file that the Human inputted.
% 		Exists, a boolean that indicates whether SaveFile exists. Initially passed in as false.
% Algorithm:
% 		1) Evaluate SaveFile.
% 			a) If SaveFile is 'cancel', then do nothing so that the program can return to the calling newGameQuery().
% 		2) Evaluate Exists.
% 			a) If Exists is false, then take another input for a save file and save it to NewSaveFile. Validate NewSaveFile using validateSaveFileInput() and save the result to NewIsValid. Using term_to_atom(), convert NewSaveFile to AtomFileName and pass that to fileExists(). Save the resulting boolean value into Exists. Recursively call findSaveFile with AtomFileName and Exists to properly handle the input whether it exists or not or is valid.
% 			b) If Exists is true, then tell the Human that SaveFile was found and read from SaveFile and store it into FileData. Split FileData into parts CPUData, HumanData, and RestCurrTurn and read each part. Determine the restored Round number by adding the CPU's and Human's Rounds Won. Using determineStartingHandNum() to determine what number Hand to start on using the size of the restored White Boneyard. Then pass all of the restored lists and variables into playRound() to play the restored Round.
% Assistance Received: None.
% *********************************************************************
% If the Human wishes to cancel finding a save file, do nothing so that newGameQuery() can continue.
findSaveFile(SaveFile, Exists) :-
	SaveFile == 'cancel'.
% If there is either an invalid save file inputted or this is being called for the first time, ask for a save file input and check if it exists.
findSaveFile(SaveFile, false) :-
	write('Enter a file you want to save from. Make sure to put \".txt\" at the end of your filename. Example: \"mySaveFile.txt.\". Enter: \"cancel.\" if you wish to cancel:\n'),
	catch(read(NewSaveFile), error(Err, _Context), write('Invalid Format: Input reading failed.\n')),
	% Validate the format of the save file inputted.
	validateSaveFileInput(NewSaveFile, Err, NewIsValid),
	% Convert the save file's name to an atom so it can be properly evaluated.
	term_to_atom(NewSaveFile, AtomFileName),
	fileExists(AtomFileName, Exists),
	% Recusively call to either take another input, cancel the operation entirely and return to newGameQuery(), or to save from the file specified.
	findSaveFile(AtomFileName, Exists).
% If the save file is found, let the Human know and parse the data.
findSaveFile(SaveFile, true) :-
	write(SaveFile), write(' found!\n'),
	open(SaveFile, read, StreamFileData),
	read(StreamFileData, FileData),
	write(FileData), nl, nl,
	
	% Parse the CPU's data from the save file.
	FileData = [CPUData | Rest],
	write('findSaveFile(): Parsing the CPU\'s data...\n'),
	% Parse the CPU's Stacks from the save file.
	nth0(0, CPUData, RestCPUStacks),
	write('findSaveFile(): RestCPUStacks: '), write(RestCPUStacks), nl,
	% Parse the White Boneyard from the save file.
	nth0(1, CPUData, RestWhiteBoneyard),
	write('findSaveFile(): RestWhiteBoneyard: '), write(RestWhiteBoneyard), nl,
	listLength(RestWhiteBoneyard, RestWhiteBoneyardSize),
	write('findSaveFile(): Number of Tiles: '), write(RestWhiteBoneyardSize), nl,
	% Parse the CPU's Hand from the save file.
	nth0(2, CPUData, RestCPUHand),
	write('findSaveFile(): RestCPUHand: '), write(RestCPUHand), nl,
	% Parse the CPU's Score from the save file.
	nth0(3, CPUData, RestCPUScore),
	write('findSaveFile(): RestCPUScore: '), write(RestCPUScore), nl,
	% Parse the CPU's Rounds Won from the save file.
	nth0(4, CPUData, RestCPUWins),
	write('findSaveFile(): RestCPUWins: '), write(RestCPUWins), nl,
	nl,

	% Parse the Human's data from the save file.
	Rest = [HumanData | NewRest],
	write('findSaveFile(): Parsing the Human\'s data...\n'),
	% write('findSaveFile(): HumanData: '), write(HumanData), nl,
	% Parse the Human's Stacks from the save file.
	nth0(0, HumanData, RestHumanStacks),
	write('findSaveFile(): RestHumanStacks: '), write(RestHumanStacks), nl,
	% Parse the Black Boneyard from the save file.
	nth0(1, HumanData, RestBlackBoneyard),
	write('findSaveFile(): RestBlackBoneyard: '), write(RestBlackBoneyard), nl,
	listLength(RestBlackBoneyard, RestBlackBoneyardSize),
	write('findSaveFile(): Number of Tiles: '), write(RestBlackBoneyardSize), nl,
	% Parse the Human's Hand from the save file.
	nth0(2, HumanData, RestHumanHand),
	write('findSaveFile(): RestHumanHand: '), write(RestHumanHand), nl,
	% Parse the Human's Score from the save file.
	nth0(3, HumanData, RestHumanScore),
	write('findSaveFile(): RestHumanScore: '), write(RestHumanScore), nl,
	% Parse the Human's Rounds Won from the save file.
	nth0(4, HumanData, RestHumanWins),
	write('findSaveFile(): RestHumanWins: '), write(RestHumanWins), nl,
	nl,
	% Parse the current turn from the save file.
	NewRest = [RestCurrTurn | Padding],
	write('findSaveFile(): RestCurrTurn: '), write(RestCurrTurn), nl, nl,
	
	% Determine the current Round Number with the Players' restored Rounds Won.
	RestRoundNum is RestCPUWins + RestHumanWins + 1,

	% Determine the starting Hand Number and update the Boneyards and the current turn if necessary.
	listLength(RestWhiteBoneyard, BoneyardSize),
	determineStartingHandNum(RestWhiteBoneyard, RestBlackBoneyard, NewRestWhiteBoneyard, NewRestBlackBoneyard, BoneyardSize, RestCPUHand, RestHumanHand, NewRestCPUHand, NewRestHumanHand, RestStartingHandNum, RestCurrTurn, NewRestCurrTurn),
	
	% playRound(RoundNum, WhiteBoneyard, BlackBoneyard, CPUStacks, HumanStacks, CPUWins, HumanWins, FirstTurn, StartingHandNum)
	% Now that all of the necessary parts of the Round have been restored, play the restored game using playRound(), but setting IsRestored to true so that the restored Hand is not unnecessarily initialized.
	playRound(true, RestRoundNum, NewRestWhiteBoneyard, NewRestBlackBoneyard, RestCPUStacks, RestHumanStacks, NewRestCPUHand, NewRestHumanHand, RestCPUScore, RestHumanScore, RestCPUWins, RestHumanWins, NewRestCurrTurn, RestStartingHandNum).

% *********************************************************************
% Rule Name: fileExists
% Purpose: Sets Exists to true if the file passed in is found and false if the file was not found. If the input was 'cancel' then do nothing to go back to the calling findSaveFile().
% Parameters:
% 		SaveFile, a compound that represents the save file that the Human inputted.
% 		Exists, a boolean that indicates whether SaveFile exists. Initially passed in as false.
% Algorithm:
% 		1) Evaluate SaveFile.
% 			a) If SaveFile is 'cancel', then do nothing so the calling findSaveFile() does not validate if a save file exists.
% 			b) Otherwise continue.
% 		2) Evaluate if SaveFile exists using exists_file().
% 			a) If the file specified by SaveFile exists, set Exists to true.
% 			b) If the file specified by SaveFile does not exists, then let the Human know that the file was not found and set Exists to false.
% Assistance Received: None.
% *********************************************************************
fileExists('cancel', Exists).
% If the file does exist, then .
fileExists(SaveFile, Exists) :-
	exists_file(SaveFile),
	Exists = true.
fileExists(SaveFile, Exists) :-
	\+exists_file(SaveFile),
	% Let the Human know that the file they specified does not exist.
	write(SaveFile), write(' was not found.\n'),
	Exists = false.

% *********************************************************************
% Rule Name: determineStartingHandNum
% Purpose: Determines the starting Hand Number from a Boneyard found in the save file. Updates the Boneyards, the Starting Hand Number, and the Restored Current Turn.
% Parameters:
% 		RestWhiteBoneyard, a list of Tiles that represents the White Boneyard restored from a save file.
% 		RestBlackBoneyard, a list of Tiles that represents the Black Boneyard restored from a save file.
% 		NewRestWhiteBoneyard, a list of Tiles that represents the White Boneyard after this operation (is different from the RestWhiteBoneyard only if a first Player needs to be determined).
% 		NewRestBlackBoneyard, a list of Tiles that represents the Black Boneyard after this operation (is different from the RestBlackBoneyard only if a first Player needs to be determined).
% 		BoneyardSize, an int that represents the number of Tiles in one Boneyard. Will be evaluated to determine the starting Hand number for the restored Round.
% 		RestCPUHand, a list of Tiles that represents the CPU's Hand restored from a save file.
% 		RestHumanHand, a list of Tiles that represents the Human's Hand restored from a save file.
% 		NewRestCPUHand, a list of Tiles that represents the CPU's Hand after this operation (is different from RestCPUHand only if a first Player needs to be determined and the first Hands have not yet been initialized).
% 		NewRestHumanHand, a list of Tiles that represents the Human's Hand after this operation (is different from RestCPUHand only if a first Player needs to be determined and the first Hands have not yet been initialized).
% 		RestStartingHandNum, an int that represents the starting Hand number determined from the restored Boneyard size.
% 		RestCurrTurn, a string that represents the current turn restored from a save file.
% 		NewRestCurrTurn, a stringg that represents the current turn after this operation (is different only if a first Player needs to be determined).
% Algorithm:
% 		1) Evaluate BoneyardSize.
% 			a) If BoneyardSize is 22, then the Players' Hands have not yet been properly initialized and a first Player has not been determined yet. Use determineFirstPlayer to determine the first Player and store that into NewFirstPlayer and then initialize both Players' Hands using initializeHnad() and store the resulting Boneyards into parameters NewRestWhiteBoneyard and NewRestBlackBoneyard and the resulting Hands into NewRestCPUHand and NewRestHumanHand. Set the RestStartingHandNum to 1.
% 			b) If BoneyardSize is 16, then set RestStartingHandNum to 1.
% 			c) If BoneyardSize is 10, then set RestStartingHandNum to 2.
% 			d) If BoneyardSize is 4, then set RestStartingHandNum to 3.
% 			e) If BoneyardSize is 0, then set RestStartingHandNum to 4.
% Assistance Received: None.
% *********************************************************************
% If there are 22 Tiles, then the first Hand has not yet been initialized. Determine the first Player and save it to NewFirstPlayer.
determineStartingHandNum(RestWhiteBoneyard, RestBlackBoneyard, NewRestWhiteBoneyard, NewRestBlackBoneyard, 22, RestCPUHand, RestHumanHand, NewRestCPUHand, NewRestHumanHand, 1, RestCurrTurn, NewFirstPlayer) :-
	write('___________________________________________________\n\n'),
	% Since the first Hand has not been initialized, determine the first Player and change the Players' Boneyards if needed.
	determineFirstPlayer(RestWhiteBoneyard, RestBlackBoneyard, TmpWhiteBoneyard, TmpBlackBoneyard, NewFirstPlayer),
	write(NewFirstPlayer), write(' goes first!\n'),
	% Initialize the Hands before going into the Round since IsRestored (which is true) will be passed in, preventing initializeHand from doing anything in playHands().
	initializeHand(false, TmpWhiteBoneyard, NewRestWhiteBoneyard, NewRestCPUHand, 0, End),
	initializeHand(false, TmpBlackBoneyard, NewRestBlackBoneyard, NewRestHumanHand, 0, End).
% For any other Hand, the Boneyards and the restored current turn will remain constant.
% If there are 16 Tiles in the Boneyards, then it must be a properly initialized Hand 1.
determineStartingHandNum(RestWhiteBoneyard, RestBlackBoneyard, RestWhiteBoneyard, RestBlackBoneyard, 16, RestCPUHand, RestHumanHand, RestCPUHand, RestHumanHand, 1, RestCurrTurn, RestCurrTurn).
% If there are 10 Tiles in the boneyards, then it must be Hand 2.
determineStartingHandNum(RestWhiteBoneyard, RestBlackBoneyard, RestWhiteBoneyard, RestBlackBoneyard, 10, RestCPUHand, RestHumanHand, RestCPUHand, RestHumanHand, 2, RestCurrTurn, RestCurrTurn).
% If there are 4 Tiles in the boneyards, then it must be Hand 3.
determineStartingHandNum(RestWhiteBoneyard, RestBlackBoneyard, RestWhiteBoneyard, RestBlackBoneyard, 4, RestCPUHand, RestHumanHand, RestCPUHand, RestHumanHand, 3, RestCurrTurn, RestCurrTurn).
% If there are 0 Tiles in the boneyards, then it must be Hand 4.
determineStartingHandNum(RestWhiteBoneyard, RestBlackBoneyard, RestWhiteBoneyard, RestBlackBoneyard, 0, RestCPUHand, RestHumanHand, RestCPUHand, RestHumanHand, 4, RestCurrTurn, RestCurrTurn).

% *********************************************
% Source Code for "Main", the main entry point for the program.
% *********************************************

?- write('___________________________________________________\n\n').
?- write('Welcome to Build Up!\n').
% Take an initial input to start the function that allows the Human to start a new game or resume an old one.
?- write('Do you want to start a new game (y) or restore an old one (n)?:\n'),
	catch(read(Input), error(Err, _Context), write('Invalid Format: Input reading failed.\n')),
	% Depending on what was inputted, newGameQuery() may start a Tournament, restore from a save file, or take another input if Input was invalid.
	newGameQuery(Input, Err).
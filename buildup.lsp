; *********************************************
; Source code for printing output on the screen.
; *********************************************
; *********************************************************************
; Function Name: printMult
; Purpose: To simplify output of multiple statements into one line.
; Parameters: 
;       args, presumably one or many parameters of different types that are to be printed.
; Return Value: None.
; Algorithm: For each argument in parameter args, the argument is prepended with a space and is then printed.
; Assistance Received: Inspiration took from: https://stackoverflow.com/questions/35187392/how-do-you-print-two-items-on-the-same-line-in-lisp.
; *********************************************************************
(defun printMult (&rest args)
    (format t "~%~{~a~^ ~}" args)
)

; *********************************************
; Source code for setup. Sets up everything for a Round, including the round number, the Boneyards, the Players' Stacks, and the playing of Hands.
; *********************************************

; *********************************************************************
; Function Name: startRound
; Purpose: To start and play a Round.
; Parameters: 
;       m_roundNum, an integer that specifies what number Round is currently being played.
;       m_whiteBoneyard, a list of Tiles that represents the CPU's Boneyard.
;       m_blackBoneyard, a list of Tiles that represents the Human's Boneyard.
;       m_cpuStacks, a list of Tiles that represents the CPU's original 6 Stacks.
;       m_humanStacks, a list of Tiles that represents the Human's original 6 Stacks.
;       m_startingHandNum, an integer that specifies what Hand number to start with. This is only used when restoring a Round from a save file.
;       m_cpuHand, a list of Tiles that represents the CPU's Hand.
;       m_humanHand, a list of Tiles that represents the Human's Hand.
;       m_cpuScore, a list of Tiles that represents the CPU's score. For this function, it is mainly used when restoring from a save file.
;       m_humanScore, a list of Tiles that represents the Human's score. For this function, it is mainly used when restoring from a save file.
;       m_cpuWins, an integer that represents how many Rounds the CPU has won. This will be incremented between Rounds or restored from a save file.
;       m_humanWins, an integer that represents how many Rounds the CPU has won. This will be incremented between Rounds or restored from a save file.
;       m_restoredTurn, an integer that represents the turn that was restored from the save file. This is only used when restoring a Round from a save file. If it is found to be odd, it is the CPU's turn. If it is found to be even, it is the Human's turn.
;       m_isReshuffle, a string that acts as a flag that indicates whether the call onto the function was to reshuffle the Boneyards (presumably since the CPU and Human both pulled a Tile with an equal number of pips so neither Player can go first).
;       m_isRestored, a string that acts as a flag that indicates whether the call onto the function was from a restoration of a previous round. Is used to determine whether to restore m_restoredTurn and to initialize Boneyards and Stacks.
; Return Value: None.
; Algorithm:    1) Determine if the function has been called to restore a previous Round or reshuffle.
;                       a) If it is a restoration, print "Restoring Round [round #]". Do not initialize the Boneyards, shuffle them, or remove the first 6 Tiles from them, or determine the first Player (as long as it is not also a reshuffle situation).
;                       b) If it is a reshuffle, do not print anything. Do not initialize the Boneyards, but shuffle them. Also determine which Player goes first again.
;                       c) If it is neither a restoration or reshuffle, then initialize the Boneyards, shuffle them, initialize the Stacks, and remove the first 6 Tiles from each Boneyard (since they have been placed on each of the Players' original 6 Stacks). Determine which Player goes first. If both Players pull Tiles with the same number of pips from the top of their respective Boneyards, then recursively call the startRound() function but set reshuffle to "true".
;               2) Run playHands() to play all Hands left (determined by parameter m_startingHandNum). From that function, you get a list of two numbers. The first is the CPU's score and the second is the Human's score.
;               3) Depending on the scores, determine which Player won and print who won.
;                       a) If the CPU had a higher score, the CPU won. Increment the CPU's wins.
;                       b) If the Human had a higher score, the Human won. Increment the Human's wins.
;                       c) If both Players had equal scores, then neither won, but increment both of their Rounds won.
;               4) Print each Player's total Rounds won.
;               5) Ask whether the Human wants to play another Round or to end the Tournament.
;                       a) If the Human chose to play another Round...
;                               1) and the CPU won the previous Round, recursively call startRound() but pass an incremented m_cpuWins. Pass through empty Boneyards, Stacks, starting with a starting Hand Number of 1, empty Hands, and with 0's for each Player's scores. m_isReshuffle and m_isRestored should be "false".
;                               2) and the Human won the previous Round, recursively call startRound() but pass an incremented m_humanWins. Pass through empty Boneyards, Stacks, starting with a starting Hand Number of 1, empty Hands, and with 0's for each Player's scores. m_isReshuffle and m_isRestored should be "false".
;                               3) and there was a draw, recursively call startRound() but pass an incremented m_cpuWins and m_humanWins. Pass through empty Boneyards, Stacks, starting with a starting Hand Number of 1, empty Hands, and with 0's for each Player's scores. m_isReshuffle and m_isRestored should be "false".
;                       b) If the Human chose to end the Tournament...
;                               1) and the CPU won the previous Round, then run the function determineWinnerOfTournament, but pass in an incremented m_cpuWins.
;                               2) and the Human won the previous Round, then run the function determineWinnerOfTournament, but pass in an incremented m_humanWins.
;                               3) and the last Round was a draw, then run the function determineWinnerOfTournament, but pass in an incremented m_cpuWins and m_humanWins.
; Assistance Received: None.
; *********************************************************************
(defun startRound (m_roundNum m_whiteBoneyard m_blackBoneyard m_cpuStacks m_humanStacks m_startingHandNum m_cpuHand m_humanHand m_cpuScore m_humanScore m_cpuWins m_humanWins m_restoredTurn m_isReshuffle m_isRestored)
    ; If the Round is just starting and is not a reshuffle, then print what Round is starting.
    (cond    ((string= m_isReshuffle "false") 
             (printMult "_______________________________________________________________________")))
    (cond    ((string= m_isReshuffle "false") 
             (terpri)))
    (cond    ((and (string= m_isReshuffle "false") (string= m_isRestored "false")) 
             (printMult "Starting Round" m_roundNum ":")))
    (cond    ((and (string= m_isRestored "true") (string= m_isReshuffle "false"))
             (printMult "Restoring Round" m_roundNum ":")))
    ; Initialize both Boneyards. emptyBoneyard will be used as an empty list for initializeBoneyard() to start with.
            ; Random seed initialization from: https://stackoverflow.com/questions/4034042/random-in-common-lisp-not-so-random
    (let*   ((*random-state* (make-random-state t))
            (m_whiteBoneyard (initializeBoneyard m_whiteBoneyard 'W 0 0 m_isReshuffle m_isRestored))
            (m_blackBoneyard (initializeBoneyard m_blackBoneyard 'B 0 0 m_isReshuffle m_isRestored))
            (m_whiteBoneyard (shuffleBoneyard m_whiteBoneyard m_isReshuffle m_isRestored))
            (m_blackBoneyard (shuffleBoneyard m_blackBoneyard m_isReshuffle m_isRestored))
            (m_cpuStacks (initializeStack m_whiteBoneyard m_cpuStacks 0 m_isReshuffle m_isRestored))
            (m_humanStacks (initializeStack m_blackBoneyard m_humanStacks 0 m_isReshuffle m_isRestored))
            (m_whiteBoneyard (popFront m_whiteBoneyard 0 6 m_isReshuffle m_isRestored))
            (m_blackBoneyard (popFront m_blackBoneyard 0 6 m_isReshuffle m_isRestored)))
        ; Determine first Player.
        (let*   ((startingTurn (determineFirstPlayer m_whiteBoneyard m_blackBoneyard))
                (startingTurn (restoreTurn startingTurn m_restoredTurn m_isReshuffle m_isRestored)))
            ; If neither Player can go first, then recursively call startRound to reshuffle the black and white Boneyards, and return.
            (cond   ((= startingTurn 0)
                    (return-from startRound (startRound m_roundNum m_whiteBoneyard m_blackBoneyard m_cpuStacks m_humanStacks m_startingHandNum m_cpuHand m_humanHand m_cpuScore m_humanScore m_cpuWins m_humanWins m_restoredTurn "true" "true"))))
            (cond   ((= startingTurn 0)
                    (return)))
            ; Run 4 Hands.
            (let*   ((handNum m_startingHandNum)
                    (allScores (playHands handNum m_whiteBoneyard m_blackBoneyard m_cpuHand m_humanHand m_cpuStacks m_humanStacks m_cpuScore m_humanScore m_cpuWins m_humanWins startingTurn 0 m_isRestored))
                    (cpuScore (first allScores))
                    (humanScore (nth 1 allScores)))
                (printMult "_______________________________________________________________________")
                (terpri)
                ; Print which Player won...
                (cond   ((> cpuScore humanScore)
                        (printMult "The Computer won Round" m_roundNum "!"))
                        ((< cpuScore humanScore)
                        (printMult "The Human won Round" m_roundNum "!"))
                        ((= cpuScore humanScore)
                        (printMult "It is a draw! Neither Player won Round" m_roundNum ", both Players will be awarded a win!"))
                )
                ; Print each Player's total wins.
                        ; If the CPU won the Round, then increment the CPU's wins and not the Human's
                (cond   ((> cpuScore humanScore)
                        (printMult "The Computer's Rounds Won:" (+ 1 m_cpuWins))))
                (cond   ((> cpuScore humanScore)
                        (printMult "The Human's Rounds Won:" m_humanWins)))
                        ; If the Human won the Round, then increment the Human's wins and not the CPU's.
                (cond   ((< cpuScore humanScore)
                        (printMult "The Computer's Rounds Won:" m_cpuWins)))
                (cond   ((< cpuScore humanScore)
                        (printMult "The Human's Rounds Won:" (+ 1 m_humanWins))))
                        ; If the Round was a draw, then increment both of the Players' Rounds won.
                (cond   ((= cpuScore humanScore)
                        (printMult "The Computer's Rounds Won:" (+ 1 m_cpuWins))))
                (cond   ((= cpuScore humanScore)
                        (printMult "The Human's Rounds Won:" (+ 1 m_humanWins))))
                
                ; After a round ends, ask the Human if they want to start another round.
                (let ((anotherRound (roundInquiry)))
                        ; If the Human wants to play another Round, then increment m_roundNum, set the starting Hand number to 1, pass the Human's and CPU's wins, set the reshuffle flag to "false" and the restored round flag to "false" since the Round is just starting.
                                ; If the CPU won, increment the CPU's wins and pass it through startRound().
                        (cond   ((and (string= anotherRound "y") (> cpuScore humanScore)) 
                                (return-from startRound (startRound (+ 1 m_roundNum) '() '() '() '() 0 '() '() 0 0 (+ 1 m_cpuWins) m_humanWins m_restoredTurn "false" "false")))
                                ; If the Human won, increment the Human's wins and pass it through a recursive call of startRound().
                                ((and (string= anotherRound "y") (< cpuScore humanScore)) 
                                (return-from startRound (startRound (+ 1 m_roundNum) '() '() '() '() 0 '() '() 0 0 m_cpuWins (+ 1 m_humanWins) m_restoredTurn "false" "false")))
                                ((and (string= anotherRound "y") (= cpuScore humanScore)) 
                                ; If neither Player won, then increment both CPU's and Human's wins by 1.
                                (return-from startRound (startRound (+ 1 m_roundNum) '() '() '() '() 0 '() '() 0 0 (+ 1 m_cpuWins) (+ 1 m_humanWins) m_restoredTurn "false" "false")))
                                ; If the Human does not want to start another round and the CPU won, increment m_cpuWins before passing it to declareWinnerOfTournament.
                                ((and (string= anotherRound "n") (> cpuScore humanScore))
                                (declareWinnerOfTournament (+ 1 m_cpuWins) m_humanWins))
                                ; If the Human does not want to start another round and the Human won, increment m_humanWins before passing it to declareWinnerOfTournament.
                                ((and (string= anotherRound "n") (< cpuScore humanScore))
                                (declareWinnerOfTournament m_cpuWins (+ 1 m_humanWins)))
                                ; If it was a draw, then increment both the CPU's and Human's Rounds won.
                                ((and (string= anotherRound "n") (= cpuScore humanScore))
                                (declareWinnerOfTournament (+ 1 m_cpuWins) (+ 1 m_humanWins)))
                        )
                )
            )
        )
    )
)

; *********************************************************************
; Function Name: popFront
; Purpose: Pops the front of the list passed in for m_end - m_counter iterations. Used when Tiles are drawn from the top of the Boneyards.
; Parameters:
;       m_list, presumably a list that is one of the Boneyards.
;       m_counter, an integer that should initially be 0. Will be incremented and evaluated at each iteration.
;       m_end, an integer that should be as many Tiles that should be removed from the list passed in (assuming that m_counter is first 0). Will be compared with m_counter at each iteration.
;       m_isReshuffle, a string that acts as a flag that determines whether the calling function was part of a reshuffle situation.
;       m_isRestored, a string that acts as a flag that determines whether the calling function was part of a restored Round situation.
; Return Value: Returns m_list with the first m_end - m_counter Tiles removed.
; Algorithm:    1) Determine whether the calling function was in a reshuffle or restored Round situation.
;                       a) If either are true, then return the list passed in as to not change it.
;               2) If it is neither a reshuffle or restored Round situation, then determine whether the parameter m_counter is less than m_end.
;                       a) If m_counter < m_end, then recursively call popFront() while passing in m_list without its first element (to essentially remove it), increment the counter, and pass the other parameters as is.
;                       b) If m_counter = m_end, then return parameter m_list as is.
; Assistance Received: None.
; *********************************************************************
(defun popFront (m_list m_counter m_end m_isReshuffle m_isRestored)
    ; If this is run under a reshuffle or Round restored situation, return the stack as is.
    (cond   ((or (string= m_isReshuffle "true") (string= m_isRestored "true"))
            (return-from popFront m_list)))
    ; If the counter has not reached the end yet, then recursively call popFront() but pass the list without its first element and increment the counter.
    (cond   ((< m_counter m_end)
            (return-from popFront (popFront (rest m_list) (+ 1 m_counter) m_end m_isReshuffle m_isRestored)))
            ; If the counter equals the end, then return the popped list.
            ((= m_counter m_end) 
            (return-from popFront m_list))
    )
)

; *********************************************************************
; Function Name: initializeBoneyard
; Purpose: Used to make a complete Boneyard using the color specified in parameter m_color.
; Parameters:
;       m_boneyard, presumably initially an empty list that is accumulated into a complete Boneyard.
;       m_color, a symbol that represents the color of the Tiles in the Boneyard. 'W = white, 'B = black.
;       m_leftPips, an integer that represents the current Tile's left pips.
;       m_rightPips, an integer that represents the current Tile's right pips.
;       m_isReshuffle, a string that acts as a flag which indicates whether the calling function was in a reshuffle situation.
;       m_isRestored, a string that acts as a flag which indicates whether the calling function was in a restored Round situation.
; Return Value: Returns a compelted m_boneyard which should have all of the Tiles a Boneyard should have in order.
; Algorithm:    1) Determine whether the calling function was in a reshuffle or restored Round situation.
;                       a) If either are true, then return the parameter m_boneyard passed in as to not change it.
;               2) If it is neither a reshuffle or restored Round situation, then create a tile using parameters m_color, m_leftPips, and m_rightPips.
;               3) Append the current Tile to the parameter m_boneyard as a new list, newBoneyard so that each Tile is its own list.
;               4) Evaluate the current Tile's left and right pips.
;                       a) If the right pips are less than 6, recursively call initializeBoneyard with all parameters constant but increment m_rightPips and pass in newBoneyard instead of m_boneyard.
;                       b) If the right pips equal 6 and the left pips are less than 6, then recursively call initializeBoneyard with all parameters constant but set the left pips and right pips to m_leftPips incremented by 1  and pass in newBoneyard instead of m_boneyard.
;                       c) If the left pips and right pips both equal 6, then this is the last Tile to be added to the boneyard. Return newBoneyard from the function.
; Assistance Received: None.
; *********************************************************************
(defun initializeBoneyard (m_boneyard m_color m_leftPips m_rightPips m_isReshuffle m_isRestored)
    ; if this is a reshuffle situation, then return the boneyard as is.
    (cond       ((or (string= m_isReshuffle "true") (string= m_isRestored "true"))
                (return-from initializeBoneyard m_boneyard)))
    ; Make the current tile (which is itself a list), and add it as a list to the new boneyard.
    (let*       ((currTile (list m_color m_leftPips m_rightPips))
                (newBoneyard (append m_boneyard (list currTile))))
        ; If the right pips are less than 6, then run a recursive call with the same left pips and an incremented right pips.
        (cond   ((< m_rightPips 6) 
                (initializeBoneyard newBoneyard m_color m_leftPips (+ 1 m_rightPips) m_isReshuffle m_isRestored))
                ; If the right pips equals 6 and the left pips are less than 6, then increment the left pips and set the right pips equal to the newly incremented left pips.
                ((and (= m_rightPips 6) (< m_leftPips 6)) 
                (initializeBoneyard newBoneyard m_color (+ 1 m_leftPips) (+ 1 m_leftPips) m_isReshuffle m_isRestored))
                ; If both the left and right pips equal six, then this is the last iteration. Return the modified boneyard.
                ((and (= m_leftPips 6) (= m_rightPips 6)) 
                (return-from initializeBoneyard newBoneyard))
        )
    )
)

; *********************************************************************
; Function Name: initializeStack
; Purpose: Initializes a Player's stack using the Boneyard passed in.
; Parameters:
;       m_boneyard, a list that represents presumably a complete but shuffled Boneyard.
;       m_stack, a list that represents the current Stack in question. Initially empty.
;       m_counter, an integer that represents the number of iterations the function has done.
;       m_isReshuffle, a string that acts as a flag which indicates whether the calling function was in a reshuffle situation.
;       m_isRestored, a string that acts as a flag which indicates whether the calling function was in a restored Round situation.
; Return Value: Returns a list of Tiles that represents a Player's Stacks.
; Algorithm:    1) Determine whether the calling function was in a reshuffle or restored Round situation.
;                       a) If either are true, then return the parameter m_boneyard passed in as to not change it.
;               2) If it is neither a reshuffle or restored Round situation, then append the first element of the Boneyard passed in to the parameter m_stack.
;               3) Evaluate m_counter...
;                       a) If the parameter m_counter is less than 6, then recursively call initializeStack with everything constant except remove the first element from the BOneyard and increment m_counter.
;                       b) If m_counter is equal to 6, then return parameter m_stack as is.
; Assistance Received: None.
; *********************************************************************
(defun initializeStack (m_boneyard m_stack m_counter m_isReshuffle m_isRestored)
    ; If this is run under a reshuffle or Round restored situation, just return and don't do anything with the stack.     
    (cond   ((or (string= m_isReshuffle "true") (string= m_isRestored "true"))
            (return-from initializeStack m_stack)))
    (let ((newStack (append m_stack (list (first m_boneyard)))))
        ; If the function has not reached the sixth iteration, then recursively call the function with the new Boneyard, stack, and increment the counter.
        (cond ((< m_counter 6) 
            (initializeStack (rest m_boneyard) newStack (+ 1 m_counter) m_isReshuffle m_isRestored)) 
            ; Once this function is run for the sixth time, all 6 stacks have been initialized, so return the stack.
            ((= m_counter 6) 
            (return-from initializeStack m_stack))
        )
    )
)

; *********************************************************************
; Function Name: shuffleBoneyard
; Purpose: Shuffles the Boneyard passed in.
; Parameters:
;       input_list, a list that represents presumably a complete but unshuffled Boneyard.
;       m_isReshuffle, a string that acts as a flag which indicates whether the calling function was in a reshuffle situation.
;       m_isRestored, a string that acts as a flag which indicates whether the calling function was in a restored Round situation.
;       accumulator, which accumulates the Tiles in the list that have been shuffled.
; Return Value: Returns a list of Tiles that represents a Player's Stacks.
; Algorithm:    1) Determine whether the calling function was in a reshuffle or restored Round situation.
;                       a) If either are true, then return the parameter m_boneyard passed in as to not change it.
;               2) Evaluate the input-list.
;                       a) If it is nil (empty), then all Tiles in the Boneyard have been shuffled. Return the accumulator.
;               3) If it is neither a reshuffle or restored Round situation, then take the first element of the list and rotate it with a random element in the list.
;               4) Repeat from step 2) but without input-list's first element (so that the next element in the list is evaluated).
; Assistance Received: Shuffling algorithm from: https://gist.github.com/shortsightedsid/62d0ee21bfca53d9b69e.
; *********************************************************************
(defun shuffleBoneyard (input-list m_isReshuffle m_isRestored &optional accumulator)
        ; If it is a restored Round, then don't shuffle the Boneyard.
        (cond    ((and (string= m_isRestored "true") (string= m_isReshuffle "false"))
                (return-from shuffleBoneyard input-list)))
        ; If the list is empty, then all of the Tiles have been shuffled. Return the accumulated shuffled Tiles.
        (cond   ((eq input-list nil)
                (return-from shuffleBoneyard accumulator)))
        ; Switch the first element of the list with a random element in the list.
        (rotatef (car input-list) (nth (random (length input-list)) input-list))
        ; Take the random element now in the first index of the list into the accumulator and consider the next-first element in the list.
        (shuffleBoneyard (cdr input-list) m_isReshuffle m_isRestored (append accumulator (list (car input-list))))
)

; *********************************************************************
; Function Name: getTotalPips
; Purpose: Returns the total pips of the Tile passed in.
; Parameters:
;       m_tile, a list that represents a Tile.
; Return Value: Returns an int that represents the parameter m_tile's left and right pips added together.
; Algorithm: N/A.
; Assistance Received: None.
; *********************************************************************
(defun getTotalPips (m_tile)
    (return-from getTotalPips (+ (nth 1 m_tile) (nth 2 m_tile)))
)

; *********************************************************************
; Function Name: determineFirstPlayer
; Purpose: Determines the first Player in a Round and returns who goes first. If CPU goes first, return 1 (odd number). If Human goes first, return 2 (even number). If neither, then return 0.
; Parameters:
;       m_whiteBoneyard, a list that represents the white Boneyard.
;       m_blackBoneyard, a list that represents the black Boneyard.
; Return Value: Returns an integer that represents the Player that goes first. (1 = CPU, 2 = Human, 0 = Neither, -1 = do not determine first Player).
; Algorithm:    1) If the white Boneyard passed in does not ahve 22 Tiles, then a first Player does not need to be determined (this would happen when restoring a Round from a save file). Return -1.
;               2) Print out the first Tile from each Boneyard and who drew them (as the first Tile in the Boneyard would be what each Player "draw")
;               3) Compare the pips from each Tile drawn.
;                       a) If the CPU's Tile has more pips, then print that the CPU goes first and return 1.
;                       b) If the Human's Tile has more pips, then print that the Human goes first and return 2.
;                       c) If neither Player's Tile has more pips, then print that the CPU goes first and return 0.
; Assistance Received: None.
; *********************************************************************
(defun determineFirstPlayer (m_whiteBoneyard m_blackBoneyard)
    ; If the length of one of the Boneyards is not equal to 22 (so the Hands have been initialized), then don't determine the first Player in a Round. Return -1.
    (cond    ((/= (length m_whiteBoneyard) 22)
             (return-from determineFirstPlayer -1)))
    (printMult "CPU drew:" (first m_whiteBoneyard))
    (printMult "Human drew:" (first m_blackBoneyard))
                ; If the CPU draws a Tile with more pips, print that the CPU goes first.
    (cond       ((> (getTotalPips (first m_whiteBoneyard)) (getTotalPips (first m_blackBoneyard)))
                (printMult "The Computer goes first!"))
                ; If the Human draws a Tile with more pips, print that the Human goes first.
                ((< (getTotalPips (first m_whiteBoneyard)) (getTotalPips (first m_blackBoneyard)))
                (printMult "Human goes first!"))
                ; If the Tiles drawn from each Player have an equal number of pips, then pritn that both Tiles drawn have the same number of pips and that the Boneyards will be reshuffled.
                ((= (getTotalPips (first m_whiteBoneyard)) (getTotalPips (first m_blackBoneyard)))
                (printMult "Both Players' tiles have the same number of pips. Reshuffling..."))
    )
                ; If the CPU draws a Tile with more pips, return 1 (odd number, which universally represents CPU turn).
    (cond       ((> (getTotalPips (first m_whiteBoneyard)) (getTotalPips (first m_blackBoneyard)))
                (return-from determineFirstPlayer 1))
                ; If the CPU draws a Tile with more pips, return 2 (even number, which universally represents Human turn).
                ((< (getTotalPips (first m_whiteBoneyard)) (getTotalPips (first m_blackBoneyard)))
                (return-from determineFirstPlayer 2))
                ; If the CPU draws a Tile with more pips, return 0 so that the calling function knows that both Players drew equal Tiles.
                ((= (getTotalPips (first m_whiteBoneyard)) (getTotalPips (first m_blackBoneyard)))
                (return-from determineFirstPlayer 0)) 
    )
)

; *********************************************************************
; Function Name: initializeHand
; Purpose: Initializes a Hand with the boneyard passed in. Runs for m_end - m_counter + 1 iterations.
; Parameters:
;       m_boneyard, a list that represents one of the Boneyards.
;       m_counter, an integer that represents how many iterations the function has done. Should start at 0.
;       m_end, an integer that is compared with m_counter to see if the function has reached its final iteration.
;       m_hand, a list that will accumulate Tiles from m_boneyard
; Return Value: Returns m_hand, which should have accumulated the appropriate Tiles from m_boneyard (6 or 4).
; Algorithm:    1) Evaluate m_end.
;                       a) If m_end = -1 and the the Boneyard passed in has more than 4 Tiles, then it must be Hands 1-3. 6 Tiles need to be drawn, so recursively call the function but set m_end to 5.
;                       b) If m_end = -1 and the the Boneyard passed in has 4 Tiles, then it must be Hand 4. 4 Tiles need to be drawn, so recursively call the function but set m_end to 3.
;               2) Set newHand to parameter m_hand with the first element from m_boneyard appended to it.
;               3) Compare m_counter with m_end.
;                       a) If m_counter < m_end, then recursively call the function without the first Tile in m_boneyard, an incremented m_counter, and everything else constant (repeat step 2).
;                       b) If m_counter = m_end, then return newHand since it is the last iteration.
; Assistance Received: None.
; *********************************************************************
(defun initializeHand (m_boneyard m_counter m_end m_hand)
    ; If the boneyard passed in is greater than 4, then it must be Hands 1-3. Recursively call initializeHand so that 6 tiles are placed in Hand.
    (cond   ((and (= m_end -1) (> (length m_boneyard) 4))
            (return-from initializeHand (initializeHand m_boneyard m_counter 5 m_hand)))
    )
    ; If the boneyard passed in is equal to 4, then it must be Hand 4. Recursively call initializeHand so that only 4 tiles are placed in Hand.
    (cond   ((and (= m_end -1) (= (length m_boneyard) 4))
            (return-from initializeHand (initializeHand m_boneyard m_counter 3 m_hand)))
    )
    ; Once parameter m_end is initialized, append to newHand the first element in parameter m_boneyard. Then recursively call initializeHand and pass in m_boneyard without its first member to evaluate the next one, increment the counter, keep m_end, and pass the newHand.
    (let ((newHand (append m_hand (list (first m_boneyard)))))
        (cond   ((< m_counter m_end)
                (return-from initializeHand (initializeHand (rest m_boneyard) (+ 1 m_counter) m_end newHand)))
                ((= m_counter m_end)
                (return-from initializeHand newHand))
        )
    )
)

; *********************************************
; Source code for implementation features like serialization, restoration from a file, and the help mode.
; *********************************************
; *********************************************************************
; Function Name: restoreTurn
; Purpose: Returns the restored turn passed in if it was called by a restore situation and the starting turn evaluated from determineFirstPlayer if it was not a restored turn.
; Parameters:
;       m_startingTurn, an int passed in that is from determineFirstPlayer() which represents the first Player that should play based on what determineFirstPlayer() returned.
;       m_restoredTurn, an int passed in which represents the restored turn passed into the calling startRound() which may or may not actually hold a restored turn.
;       m_isReshuffle, a string that acts as a flag which indicates whether the calling function was in a reshuffle situation.
;       m_isRestored, a string that acts as a flag which indicates whether the calling function was in a restored Round situation.
; Return Value: Returns m_hand, which should have accumulated the appropriate Tiles from m_boneyard (6 or 4).
; Algorithm:    1) If parameter m_startingTurn = 0 (when both Players in determineFirstPlayer() draw Tiles with equal pips) or m_isReshuffle is "true", then return the m_startingTurn passed in, as either of these situations is not a restoration situation.
;               2) Evaluate m_isRestored.
;                       a) If m_isRestored is true, then return m_restoredTurn.
;                       b) if m_isRestored is false, then return m_startingTurn.
; Assistance Received: None.
; *********************************************************************
(defun restoreTurn (m_startingTurn m_restoredTurn m_isReshuffle m_isRestored)
    ; If the Round restored needs a reshuffle, don't restore the turn again.
    (cond    ((or (= m_startingTurn 0) (string= m_isReshuffle "true"))
             (return-from restoreTurn m_startingTurn)))

             ; If the Round was restored, return the restored turn instead.
    (cond    ((string= m_isRestored "true")
             (return-from restoreTurn m_restoredTurn))
             ; If the Round was not restored, return the starting turn passed in and do not change it.
             ((string= m_isRestored "false")
             (return-from restoreTurn m_startingTurn)))
)

; *********************************************************************
; Function Name: suspendInquiry
; Purpose: Asks the user whether the Human wants to suspend the game or not, returns "true" if the Human wants to suspend the game and "false" if the Human wants to continue.
; Parameters: None.
; Return Value: Returns "true" if the Human wants to suspend the game, and "false" if the Human does not.
; Algorithm:    1) Ask the Human whether to continue or suspend the game.
;               2) Evaluate the input.
;                       a) If the input does not equal "y" or "n", then print that it is an invalid input and repeat step 1) through recursion.
;                       b) If the input is "y", then the Human wants to continue the game. Return false.
;                       c) If the input is "n", then the Human does not want to continue the game. Return true.
; Assistance Received: None.
; *********************************************************************
(defun suspendInquiry ()
    (printMult "Do you want to continue (y) or suspend the game (n)?:")
    (terpri)
    (let    ((input (read-line)))
                ; If the Human wants to continue the game, return "false".
        (cond   ((string= input "y")
                (return-from suspendInquiry "false"))
                ; If the Human wants to suspend the game, return "true".
                ((string= input "n")
                (return-from suspendInquiry "true"))
        )
        ; If the response was not "y" or "n", ask for another response through a recursive call of suspendInquiry().
        (printMult "Invalid input. Please input a \"y\" or \"n\"")
        (return-from suspendInquiry (suspendInquiry))
    )
)

; *********************************************************************
; Function Name: roundInquiry
; Purpose: Asks Human if they want to start another round. "y" = another round, "n" = end the game.
; Parameters: None.
; Return Value: Returns "y" if the Human wants to start another Round, and "false" if the Human does not.
; Algorithm:    1) Ask the Human whether they want to start another Round or not.
;               2) Evaluate the input.
;                       a) If the input does not equal "y" or "n", then print that it is an invalid input and repeat step 1) through recursion.
;                       b) If the input is "y", then the Human wants to start another Round. Return the input.
;                       c) If the input is "n", then the Human does not want to start another Round. Return the input.
; Assistance Received: None.
; *********************************************************************
(defun roundInquiry ()
    (printMult "Do you want to start another round? (y/n): ")
    (let ((input (read-line)))
        ; If the Human chooses to start another round, return "y" from the function.
        (cond ((string= input "y") 
                (return-from roundInquiry input))
            ; If the Human chooses not to start another round, return "n" from the function.
            ((string= input "n") 
                (return-from roundInquiry input))
            ; If the input is neither "y" or "n", then it is an invalid input. A recursive call to roundInquiry is made to take another input.
            ((and (string/= input "y") (string/= input "n")) 
                (roundInquiry))
        )
    )
)

; *********************************************************************
; Function Name: storeRoundInfo
; Purpose: Stores the information from a Round into text file specified.
; Parameters:   m_handNum, an integer that represents the Hand number of the calling playHands().
;               m_whiteBoneyard, a list that represents the white Boneyard from the calling playHands().
;               m_blackBoneyard, a list that represents the black Boneyard from the calling playHands(). 
;               m_cpuHand, a list that represents the CPU's hand from the calling playHands().
;               m_humanHand, a list that represents the Human's hand from the calling playHands().
;               m_cpuStacks, a list that represents the CPU's original 6 Stacks from the calling playHands().
;               m_humanStacks, a list that represents the Human's original 6 Stacks from the calling playHands().
;               m_cpuScore, an integer that represents the CPU's score from the calling playHands().
;               m_humanScore, an integer that represents the Human's score from the calling playHands().
;               m_cpuWins, an integer that represents the CPU's Rounds won from the calling playHands().
;               m_humanWins, an integer that represents the Human's Rounds won from the calling playHands().
;               m_currTurn, an integer that represents the next turn that must be played from the calling playHands().
; Return Value: N/A.
; Algorithm:    1) Ask the Human for the name of the save file they want to save their data into (without the .txt extension).
;               2) Read the filename specified by the Human and store it into 'input'.
;               3) Take 'input' and concatenate ".txt" onto it to create the full filename and store it into 'saveFileName'.
;               4) Open file "[saveFileName]" for writing.
;               5) Store the CPU's Stacks, Boneyard, Hand, Score, and Rounds won.
;               6) Store the Human's Stacks, Boneyard, Hand, Score, and Rounds won.
; Assistance Received: None.
; *********************************************************************
(defun storeRoundInfo (m_handNum m_whiteBoneyard m_blackBoneyard m_cpuHand m_humanHand m_cpuStacks m_humanStacks m_cpuScore m_humanScore m_cpuWins m_humanWins m_currTurn)
    (printMult "Please enter a name for the save file. Please make sure not to add an extension to the name:")
    (terpri)
    ; Take the save file name the Human gives and add ".txt" to the end of it.
    (let*   ((input (read-line))
            (saveFileName (concatenate 'string input ".txt")))
        ; Write the info to the file.
        (with-open-file (stream saveFileName :direction :output)
            (format stream "(~%")

            ; CPU SERIALIZATION:
            (format stream "~3T(~%")
            ; Stack serialization:
            (format stream "~6T")
            (format stream (write-to-string m_cpuStacks))
            (format stream "~%")
            ; Boneyard serialization:
            (format stream "~6T")
            (format stream (write-to-string m_whiteBoneyard))
            (format stream "~%")
            ; Hand serialization:
            (format stream "~6T")
            (format stream (write-to-string m_cpuHand))
            (format stream "~%")
            ; Score serialization:
            (format stream "~6T")
            (format stream (write-to-string m_cpuScore))
            (format stream "~%")
            ; Rounds Won serialization:
            (format stream "~6T")
            (format stream (write-to-string m_cpuWins))
            (format stream "~%")
            (format stream "~3T)~%")
            
            ; HUMAN SERIALIZATION:
            (format stream "~3T(~%")
            ; Stack serialization:
            (format stream "~6T")
            (format stream (write-to-string m_humanStacks))
            (format stream "~%")
            ; Boneyard serialization:
            (format stream "~6T")
            (format stream (write-to-string m_blackBoneyard))
            (format stream "~%")
            ; Hand serialization:
            (format stream "~6T")
            (format stream (write-to-string m_humanHand))
            (format stream "~%")
            ; Score serialization:
            (format stream "~6T")
            (format stream (write-to-string m_humanScore))
            (format stream "~%")
            ; Rounds Won serialization:
            (format stream "~6T")
            (format stream (write-to-string m_humanWins))
            (format stream "~%")
            (format stream "~3T)~%")

            ; Current Turn serialization:
            ; Print the next turn into the file.
            (cond   ((> (mod m_currTurn 2) 0)
                    (format stream "~3THuman~%")))
            (cond   ((= (mod m_currTurn 2) 0)
                    (format stream "~3TComputer~%")))

            (format stream ")")
        )
        ; Let the Human know that the saving was successful and tell them what the name of the save file is.
        (printMult "Game successfully saved to" saveFileName)
    )
)

; *********************************************************************
; Function Name: restorePreviousGame
; Purpose: Restores a previous game from a save file specified by the Human. Returns "false" if the Human does not want to restore a game.
; Parameters: None.
; Return Value: N/A.
; Algorithm:    1) Run restoreInquiry() to ask and get whether the Human wants to restore a previous game or not. Store the value into 'restoreGame'
;               2) If restoreGame is "false", then return "false" from restorePreviousGame().
;               3) If the Human wants to restore a previous game, then ask what file they want to load from (without the extension).
;               4) Evaluate the input.
;                       a) If the file inputted does not exist, then print that the file specified does not exist and go back to step 1) (recursively call restorePreviousGame()).
;                       b) If the file specified does exist, then read the CPU's Stacks, white Boneyard, Hand, Score and Rounds won from the file. Then read the Human's Stacks, black Boneyard, Hand, Score, and ROunds won from the file.
;               5) Evaluate the turn specified in the file using extractTurnFromString().
;                       a) If the file has "Computer", then set restoredTurn to 1.
;                       b) If the file has "Human", then set restoredTurn to 2.
;               6) Resume the Round using startRound() using all of the data above and setting the Round number to the CPU's Rounds won + Human's Rounds won + 1.
; Assistance Received: None.
; *********************************************************************
(defun restorePreviousGame ()
    ; If the Human does not want to restore a previous game, then return "false" and do not continue.
    (let   ((restoreGame (restoreInquiry)))
        (cond   ((string= restoreGame "false")
                (return-from restorePreviousGame "false")))
    )
    ; Take a file name from the Human that they want to load from.
    (printMult "Please enter the name of the save file you want to load from. Please do not add an extension to the name:")
    (terpri)
    ; Format the user's input so that it has a .txt extension.
    (let*   ((saveFileName (read-line))
            (saveFile (concatenate 'string saveFileName ".txt")))
        ; If the file specified doesn't exist, then let the Human know and recursively call restorePreviousGame() to get another input.
        (cond   ((eq (probe-file saveFile) nil)
                (printMult "File \"" saveFile "\" could not be found. Check for errors in spelling or remove the file's extension from your input.")))
        (cond   ((eq (probe-file saveFile) nil)
                (return-from restorePreviousGame (restorePreviousGame))))
        ; If the file specified exists, then try and read from it.
        (with-open-file (stream saveFile :direction :input)
            ; Read the first two open parenthesis.
            (printMult "current line:" (read-line stream))
            (printMult "current line:" (read-line stream))
            ; Read the CPU's data.
            (let*   ((cpuStacks (read-from-string (read-line stream)))
                    (whiteBoneyard (read-from-string (read-line stream)))
                    (cpuHand (read-from-string (read-line stream)))
                    (cpuScore (read-from-string (read-line stream)))
                    (cpuWins (read-from-string (read-line stream))))
                (printMult "cpuStacks:" cpuStacks)
                (printMult "whiteBoneyard:" whiteBoneyard)
                (printMult "cpuHand:" cpuHand)
                (printMult "cpuScore:" cpuScore)
                (printMult "cpuWins:" cpuWins)
                ; Read empty parenthesis spacing.
                (read-line stream)
                (read-line stream)
                ; Read the Human's data.
                (let*   ((humanStacks (read-from-string (read-line stream)))
                        (blackBoneyard (read-from-string (read-line stream)))
                        (humanHand (read-from-string (read-line stream)))
                        (humanScore (read-from-string (read-line stream)))
                        (humanWins (read-from-string (read-line stream)))
                        (startingHandNum (determinestartingHandNumber blackBoneyard)))
                    (printMult "humanStacks:" humanStacks)
                    (printMult "blackBoneyard:" blackBoneyard)
                    (printMult "humanHand:" humanHand)
                    (printMult "humanScore:" humanScore)
                    (printMult "humanWins:" humanWins)
                    ; Read empty parenthesis spacing.
                    (read-line stream)
                    ; Read the current turn.
                    (let*    ((strTurn (read-from-string (read-line stream)))
                            (restoredTurn (extractTurnFromString strTurn)))
                        (printMult "Restored Turn:" strTurn)
                        ; Start a round using the Players' restored data.
                        (startRound (+ cpuWins humanWins 1) whiteBoneyard blackBoneyard cpuStacks humanStacks startingHandNum cpuHand humanHand cpuScore humanScore cpuWins humanWins restoredTurn "false" "true")
                    )
                )
            )
        )
    )
)

; *********************************************************************
; Function Name: extractTurnFromString
; Purpose: Takes strings "COMPUTER" or "HUMAN" and returns a 1 or 2, respectively for the turn system implemented. Used when reading from save file specified in restorePreviousGame().
; Parameters:   m_strTurn, a string that represents the string read in from the file that specifies whether it is the Human's or Computer's turn. Should be either "Computer" or "Human".
; Return Value: Returns 1 (odd number which represents a CPU turn throughout this program) if the parameter m_strTurn is "Computer". Returns 2 (even number which represents a Human turn throughout this program) if the parameter m_strTurn is "Human".
; Algorithm:    1) Evaluate parameter m_strTurn.
;                       a) If m_strTurn is equal to "COMPUTER", return 1.
;                       b) If m_strTurn is equal to "HUMAN", return 2.
; Assistance Received: None.
; *********************************************************************
(defun extractTurnFromString (m_strTurn)
    (cond    ((string= m_strTurn "COMPUTER")
             (return-from extractTurnFromString 1)))
    (cond    ((string= m_strTurn "HUMAN")
             (return-from extractTurnFromString 2)))
)

; *********************************************************************
; Function Name: determineStartingHandNumber
; Purpose: Determine the starting Hand number based on how many Tiles are in the Boneyard passed in so that the correct Hand is played in playHands().
; Parameters:   m_boneyard, a list that represents one of the Boneyards.
; Return Value: Returns the appropriate Hand number based on how many Tiles are in m_boneyard. (28 Tiles = -1, 22 Tiles = 0, 16 Tiles = 1, 10 Tiles = 2, 4 Tiles = 3, 0 Tiles = 4).
; Algorithm:    1) Evaluate amount of Tiles in parameter m_boneyard.
;                       a) If m_boneyard has 28 Tiles, return -1.
;                       b) If m_boneyard has 22 Tiles, return 0.
;                       c) If m_boneyard has 16 Tiles, return 1.
;                       d) If m_boneyard has 10 Tiles, return 2.
;                       e) If m_boneyard has 4 Tiles, return 3.
;                       f) If m_boneyard has 0 Tiles, return 0.
; Assistance Received: None.
; *********************************************************************
(defun determineStartingHandNumber (m_boneyard)
            ; If all 28 Tiles are in the Boneyard, that means that the Stacks and Hands have not been initialized yet. Return Hand -1.
    (cond   ((= (length m_boneyard) 28)
            (return-from determineStartingHandNumber -1))
            ; If 22 Tiles are in the Boneyard, then the Stacks have been initialized but not the Hands. Return Hand 0.
            ((= (length m_boneyard) 22)
            (return-from determineStartingHandNumber 0))
            ; If 16 Tiles are in the Boneyard, then the Stacks and Hand have already been intiialized and the first Hand has started. Return Hand 1.
            ((= (length m_boneyard) 16)
            (return-from determineStartingHandNumber 1))
            ; If 10 Tiles are in the Boneyard, then the second Hand has started. Return Hand 2.
            ((= (length m_boneyard) 10)
            (return-from determineStartingHandNumber 2))
            ; If 4 Tiles are in the Boneyard, then the third Hand has started. Return Hand 3.
            ((= (length m_boneyard) 4)
            (return-from determineStartingHandNumber 3))
            ; If 0 Tiles are in the Boneyard, then the fourth Hand has started. Return Hand 4.
            ((= (length m_boneyard) 0)
            (return-from determineStartingHandNumber 4))
    )
)

; *********************************************************************
; Function Name: restoreInquiry
; Purpose: Asks the Human if they wish to restore a previous game or not. Returns "true" if the Human wants to restore, and "false" if the Human does not.
; Parameters: None.
; Return Value: Returns "true" if the Human wants to restore a previous game and "false" if not.
; Algorithm:    1) Ask the Human whether they want to restore a previous game.
;               2) Evaluate the input.
;                       a) If the input does not equal "y" or "n", print out that the input is invalid and repeat step 1) for another input (through recursion).
;                       b) If the input is "y", then the Human wants to restore a previous game, so return "true".
;                       c) If the input is "n", then the Human wants to restore a previous game, so return "false".
; Assistance Received: None.
; *********************************************************************
(defun restoreInquiry ()
    (printMult "Do you wish to restore a previous game? (y/n)")
    (terpri)
    (let    ((input (read-line)))
                ; If the Human wants to restore a game, return "true".
        (cond   ((string= input "y")
                (return-from restoreInquiry "true"))
                ; If the Human does not want to restore a game, return "false".
                ((string= input "n")
                (return-from restoreInquiry "false"))
        )
        ; If the response was not "y" or "n", ask for another response through a recursive call of suspendInquiry().
        (printMult "Invalid input. Please input a \"y\" or \"n\"")
        (return-from restoreInquiry (restoreInquiry))
    )
)

; *********************************************
; Source code for playing the game.
; *********************************************
; *********************************************************************
; Function Name: playHands
; Purpose: Plays a Hand using some or all of the parameters passed in based on whether the Hand was restored or not.
; Parameters:   m_handNum, an integer that represents the current Hand's number.
;               m_whiteBoneyard, a list that represents all the Tiles in the white Boneyard.
;               m_blackBoneyard, a list that represents all the Tiles in the black Boneyard.
;               m_cpuHand, a list that represents the CPU's Hand.
;               m_humanHand, a list that represents the Human's Hand.
;               m_cpuStacks, a list that represents the CPU's original 6 Stacks.
;               m_humanStacks, a list that represents the Human's original 6 Stacks.
;               m_cpuScore, an integer that represents the CPU's score.
;               m_humanScore, an integer that represents the Human's score.
;               m_cpuWins, an integer that represents the number of Rounds the CPU won. Mainly used for serialization.
;               m_humanWins, an integer that represents the number of Rounds the human won. Mainly used for serialization.
;               m_currTurn, an integer that represents the current turn to be played.
;               m_counter, an integer that keeps track of how many times playHands() has ran since the start of a new Hand.
;               m_isRestored, a string that acts as a flag which indicates whether the calling function was in a restored Round situation.
; Return Value: Returns the CPU's and the Human's scores as a list (CPU's score is first and Human's score is second).
; Algorithm:    1) Evaluate parameter m_counter and m_isRestored.
;                       a) If m_counter = 1 and m_isRestored is false, then it is not a restored Hand, so print that the Hand is just starting.
;                       b) If m_counter = 1 and m_isRestored is true, then it is a restored Hand, so print that the Hand is being resumed.
;               2) If m_counter and m_handNum are 0, then it must be the first Hand but the Hand has not been intiialized yet. Recursively call playHands() but with the Hand number set to 1, the white and black Boneyards with the first 6 Tiles popped off them, the newly initialized CPU and Human Hands, an incremented counter, m_isRestored set to false, and everything else constant.
;               3) Determine which Players can place a Tile from their Hand.
;                       a) If neither Players can place a Tile, print that neither can place and that the current Hand has ended. Take and display the Players' scores.
;                               1) If the Hand that just ended was before Hand 4, recursively call playHands() and increment the Hand number, pop the respective number of Tiles from the Boneyards, re-initialize the Players' Hands, set m_counter back to 1, and m_isRestored to false. Everything else stays constant.
;                               2) If the Hand that just ended waas Hand 4, then take each Player's scores and return them as a list (CPU's score is first, Human's score is second).
;                       b) If either Player cannot place a Tile, then skip their turn by recursively calling playHands() while keeping everything constant but incrementing m_currTurn (so the next Player plays their turn) and m_counter.
;               4) Display the Players' Stacks and let the current Player play their turn using playerTurn(), which will return both Player's Stacks and the current Player's modified Hand.
;               5) Print the current Player's Hand after the play.
;               6) Determine which Player will play next.
;                       a) If the current turn was the Human's, then the next turn will be the CPU.
;                       b) If the current turn was the CPU's, then the next turn will be the Human.
;               7) Print which Player plays the next turn.
;               8) Ask whether the Human wants to suspend the game or continue.
;                       a) If the Human wants to suspend the game, run storeRoundInfo() taking the current Round and Hand information with the modified Stacks and current Player's Hand from allStacks. Then exit the game.
;                       b) If the Human does not want to suspend the game, recursively run playHands() passing in all of the Hand data but with the newly modified Stacks and the current Player's modified Hand, also incrementing m_currTurn and m_counter.
; Assistance Received: None.
; *********************************************************************
(defun playHands (m_handNum m_whiteBoneyard m_blackBoneyard m_cpuHand m_humanHand m_cpuStacks m_humanStacks m_cpuScore m_humanScore m_cpuWins m_humanWins m_currTurn m_counter m_isRestored)
        ; If the Hand has just started, let the Human know and initialize the Players' Hands. Recursively call this function but with the initialized Hands.
        (cond   ((or (= m_counter 1) (and (= m_counter 0) (string= m_isRestored "true")))
                (printMult "_______________________________________________________________________")))
        ; If it is a new Hand, print that we are starting a Hand. If it is a restored Hand, print that we are resuming a Hand.
        (cond   ((and (= m_counter 1) (string= m_isRestored "false"))
                (printMult "Starting Hand" m_handNum ":")))
        (cond   ((and (= m_counter 0) (string= m_isRestored "true"))
                (printMult "Resuming Hand" m_handNum ":")))
        ; If the Hand has not been initialized, then pop the first 6 Tiles from each Boneyard and initialize the Hands.
        (cond   ((and (= m_counter 0) (= m_handNum 0))
                (return-from playHands (playHands 1 (popFront m_whiteBoneyard 0 6 "false" "false") (popFront m_blackBoneyard 0 6 "false" "false") (initializeHand m_whiteBoneyard 0 -1 m_cpuHand) (initializeHand m_blackBoneyard 0 -1 m_humanHand) m_cpuStacks m_humanStacks m_cpuScore m_humanScore m_cpuWins m_humanWins m_currTurn (+ 1 m_counter) "false"))))

        ; If both Players cannot place a Tile from their hand, then print each Players' Hands and to let the Human know that the Hand has ended and start a new Hand.
        (cond   ((and (string= (playerCanPlace m_cpuHand m_humanHand m_cpuStacks m_humanStacks m_currTurn) "false") (string= (playerCanPlace m_cpuHand m_humanHand m_cpuStacks m_humanStacks (+ 1 m_currTurn)) "false"))
                (printMult "Neither Player can place a Tile. Hand" m_handNum "has ended.")))
        (cond   ((and (string= (playerCanPlace m_cpuHand m_humanHand m_cpuStacks m_humanStacks m_currTurn) "false") (string= (playerCanPlace m_cpuHand m_humanHand m_cpuStacks m_humanStacks (+ 1 m_currTurn)) "false"))
                (printMult "Computer's Hand:" m_cpuHand)))
        (cond   ((and (string= (playerCanPlace m_cpuHand m_humanHand m_cpuStacks m_humanStacks m_currTurn) "false") (string= (playerCanPlace m_cpuHand m_humanHand m_cpuStacks m_humanStacks (+ 1 m_currTurn)) "false"))
                (printMult "Human's Hand:" m_humanHand)))        
                ; Take the scores for each Player and handle the leftover Tiles that may be in each Player's Hands by taking their pips and subtracting from the respective Player's scores. Print each Player's scores.
        (cond   ((and (string= (playerCanPlace m_cpuHand m_humanHand m_cpuStacks m_humanStacks m_currTurn) "false") (string= (playerCanPlace m_cpuHand m_humanHand m_cpuStacks m_humanStacks (+ 1 m_currTurn)) "false"))
                (printMult "Computer's score:" (first (takeScores m_cpuScore m_humanScore m_cpuHand m_humanHand (append m_cpuStacks m_humanStacks))))))
        (cond   ((and (string= (playerCanPlace m_cpuHand m_humanHand m_cpuStacks m_humanStacks m_currTurn) "false") (string= (playerCanPlace m_cpuHand m_humanHand m_cpuStacks m_humanStacks (+ 1 m_currTurn)) "false"))
                (printMult "Human's score:" (nth 1 (takeScores m_cpuScore m_humanScore m_cpuHand m_humanHand (append m_cpuStacks m_humanStacks))))))

        ; When both Players cannot place a Tile from their Hand, then start the next Hand and take the scores of each player.
        (let    ((cpuScore (first (takeScores m_cpuScore m_humanScore m_cpuHand m_humanHand (append m_cpuStacks m_humanStacks))))
                (humanScore (nth 1 (takeScores m_cpuScore m_humanScore m_cpuHand m_humanHand (append m_cpuStacks m_humanStacks)))))
                        ; If the current Hand that ended was before the fourth, then recursively call playHands() but with an incremented hand number.
                (cond   ((and (< m_handNum 4) (string= (playerCanPlace m_cpuHand m_humanHand m_cpuStacks m_humanStacks m_currTurn) "false") (string= (playerCanPlace m_cpuHand m_humanHand m_cpuStacks m_humanStacks (+ 1 m_currTurn)) "false"))
                        (return-from playHands (playHands (+ 1 m_handNum) (popFront m_whiteBoneyard 0 6 "false" "false") (popFront m_blackBoneyard 0 6 "false" "false") (initializeHand m_whiteBoneyard 0 -1 '()) (initializeHand m_blackBoneyard 0 -1 '()) m_cpuStacks m_humanStacks cpuScore humanScore m_cpuWins m_humanWins m_currTurn 1 "false"))))
                        ; If the current Hand that ended was the fourth, then return from playHands() each Players' scores.
                (cond   ((and (= m_handNum 4) (string= (playerCanPlace m_cpuHand m_humanHand m_cpuStacks m_humanStacks m_currTurn) "false") (string= (playerCanPlace m_cpuHand m_humanHand m_cpuStacks m_humanStacks (+ 1 m_currTurn)) "false"))
                        (return-from playHands (list cpuScore humanScore))))
        )

        ; If the CPU cannot place a Tile, skip the CPU's turn and recursively call playHands() to play the Human's turn instead.
        (cond   ((and (> (mod m_currTurn 2) 0) (string= (playerCanPlace m_cpuHand m_humanHand m_cpuStacks m_humanStacks m_currTurn) "false"))
                (printMult "The Computer cannot place a Tile. Skipping turn...")))
        (cond   ((and (> (mod m_currTurn 2) 0) (string= (playerCanPlace m_cpuHand m_humanHand m_cpuStacks m_humanStacks m_currTurn) "false"))
                (return-from playHands (playHands m_handNum m_whiteBoneyard m_blackBoneyard m_cpuHand m_humanHand m_cpuStacks m_humanStacks m_cpuScore m_humanScore m_cpuWins m_humanWins (+ 1 m_currTurn) (+ 1 m_counter) m_isRestored))))
        ; If the Human cannot place a Tile, skip the Human's turn and recursively call playHands() to play the CPU's turn instead.
        (cond   ((and (= (mod m_currTurn 2) 0) (string= (playerCanPlace m_cpuHand m_humanHand m_cpuStacks m_humanStacks m_currTurn) "false"))
                (printMult "The Human cannot place a Tile. Skipping turn...")))
        (cond   ((and (= (mod m_currTurn 2) 0) (string= (playerCanPlace m_cpuHand m_humanHand m_cpuStacks m_humanStacks m_currTurn) "false"))
                (return-from playHands (playHands m_handNum m_whiteBoneyard m_blackBoneyard m_cpuHand m_humanHand m_cpuStacks m_humanStacks m_cpuScore m_humanScore m_cpuWins m_humanWins (+ 1 m_currTurn) (+ 1 m_counter) m_isRestored))))

        (printMult "_______________________________________________________________________")
        (terpri)
        (printMult "< Computer's Stacks >")
        (terpri)
        (princ "   W1       W2      W3      W4      W5      W6")
        (printMult m_cpuStacks)
        (printMult m_humanStacks)
        (terpri)
        (princ "   B1       B2      B3      B4      B5      B6")
        (printMult "< Human's Stacks >")
            
        ; Let the respective Player play their turn and return the CPU's stacks, Human's stacks, and current Player's Hand as one variable, allStacks.
        (let*   ((allStacks (list m_cpuHand m_humanHand))
                (allStacks (playerTurn m_cpuStacks m_humanStacks m_cpuHand m_humanHand m_currTurn)))
                (printMult "< Computer's Stacks >")
                (terpri)
                (princ "   W1       W2      W3      W4      W5      W6")
                (printMult (first allStacks))
                (printMult (nth 1 allStacks))
                (terpri)
                (princ "   B1       B2      B3      B4      B5      B6")
                (printMult "< Human's Stacks >")
                (terpri)

                ; If it was the CPU's turn, then print out "CPU's Hand:"
                (cond   ((> (mod m_currTurn 2) 0)
                        (printMult "Computer's Hand:"))
                        ((= (mod m_currTurn 2) 0)
                        (printMult "Human's Hand:"))
                )
                ; Print the respective Player's Hand.
                (printMult (nth 2 allStacks))
                (terpri)

                ; Print which Player's turn is next.
                (cond  ((and (<= m_handNum 4) (= (mod m_currTurn 2) 0))
                        (printMult "Next turn: Computer.")))
                (cond  ((and (<= m_handNum 4) (> (mod m_currTurn 2) 0))
                        (printMult "Next turn: Human.")))

                ; Ask the Human if they want to continue the Hand or suspend the game.
                (let    ((suspendGame (suspendInquiry)))
                        ; If the human wants to suspend the game...
                                ; And the CPU just played their turn...
                        (cond   ((and (string= suspendGame "true") (> (mod m_currTurn 2) 0))
                                (storeRoundInfo m_handNum m_whiteBoneyard m_blackBoneyard (nth 2 allStacks) m_humanHand (first allStacks) (nth 1 allStacks) m_cpuScore m_humanScore m_cpuWins m_humanWins m_currTurn))
                                ; And the Human just played their turn...
                                ((and (string= suspendGame "true") (= (mod m_currTurn 2) 0))
                                (storeRoundInfo m_handNum m_whiteBoneyard m_blackBoneyard m_cpuHand (nth 2 allStacks) (first allStacks) (nth 1 allStacks) m_cpuScore m_humanScore m_cpuWins m_humanWins m_currTurn)))
                        ; Exit the game if the game has been suspended by the Human.
                        (cond   ((string= suspendGame "true")
                                (exit)))
                )
                
                (terpri)
                ; If the current Hand is less than 4, it is currently the CPU's turn, and a Player can place a Tile, then recursively call the function and continue the Hand.
                (cond  ((and (<= m_handNum 4) (> (mod m_currTurn 2) 0))
                        (return-from playHands (playHands m_handNum m_whiteBoneyard m_blackBoneyard (nth 2 allStacks) m_humanHand (first allStacks) (nth 1 allStacks) m_cpuScore m_humanScore m_cpuWins m_humanWins (+ 1 m_currTurn) (+ 1 m_counter) m_isRestored))))
                ; If the current Hand is less than 4, it is currently the Human's turn, and a Player can place a Tile, then recursively call the function and continue the Hand.
                (cond  ((and (<= m_handNum 4) (= (mod m_currTurn 2) 0))
                        (return-from playHands (playHands m_handNum m_whiteBoneyard m_blackBoneyard m_cpuHand (nth 2 allStacks) (first allStacks) (nth 1 allStacks) m_cpuScore m_humanScore m_cpuWins m_humanWins (+ 1 m_currTurn) (+ 1 m_counter) m_isRestored))))
        )
)

; *********************************************************************
; Function Name: playerTurn
; Purpose: Plays the respective Player's turn based on what number is passed through m_currTurn (where an odd number is the CPU's turn and an even number is the Human's turn).
; Parameters:   m_cpuStacks, list that represents the CPU's original 6 Stacks.
;               m_humanStacks, list that represents the Human's original 6 Stacks.
;               m_cpuHand, list that represents the CPU's Hand.
;               m_humanHand, list that represents the Human's Hand.
;               m_currTurn, integer that represents the current Player's turn.
; Return Value: Returns the CPU's and the Human's scores as a list (CPU's score is first and Human's score is second), which is taken from either cpuTurn() or humanTurn().
; Algorithm:    1) Evaluate parameter m_currTurn.
;                       a) If m_currTurn is odd (meaning that it is the CPU's turn), then return what cpuTurn() returns, passing in playerTurn()'s parameters into cpuTurn().
;                       b) If m_currTurn is even (meaning that it is the Human's turn), then return what humanTurn() returns, passing in playerTurn()'s parameters into humanTurn().
; Assistance Received: None.
; *********************************************************************
(defun playerTurn (m_cpuStacks m_humanStacks m_cpuHand m_humanHand m_currTurn)
            ; If the number is odd, then it is the CPU's turn.
    (cond   ((> (mod m_currTurn 2) 0)
            (return-from playerTurn (cpuTurn m_cpuStacks m_humanStacks m_cpuHand)))
            ; If the number is even, then it is the Human's turn.
            ((= (mod m_currTurn 2) 0)
            (return-from playerTurn (humanTurn m_cpuStacks m_humanStacks m_humanHand)))
    )
)

; *********************************************************************
; Function Name: isDouble
; Purpose: Returns whether the Tile passed in is a double or non-double tile. Returns "true" if it is a double Tile and "false" if it isn't. Mainly used in validStackPlacements(), nonDoublesInList(), and doublesInList().
; Parameters:   m_tileSelected, which represents the Tile that is to be evaluated.
; Return Value: Returns "true" if the Tile passed in is a double, and "false" if it isn't.
; Algorithm:    1) Evaluate parameter m_tile's left and right pips.
;                       a) If the Tile's left and right pips equal each other, then return "true".
;                       b) If the Tile's left and right pips are not equal to eqach other, then return "false".
; Assistance Received: None.
; *********************************************************************
(defun isDouble (m_tile)
            ; If the parameter Tile's left pips equal its right pips, then return that it is a double-Tile ("true").
    (cond   ((= (nth 1 m_tile) (nth 2 m_tile))
            (return-from isDouble "true"))
            ; If the parameter Tile's left pips does not equal its right pips, then return that it is a non-double-Tile ("false").
            ((/= (nth 1 m_tile) (nth 2 m_tile))
            (return-from isDouble "false"))
    )
)

; *********************************************************************
; Function Name: placeOntoStack
; Purpose: Places Tile passed through onto Stack passed through. The index passed in will be determined by function whichPlayersStacks (which returns: 0 = CPU, 1 = Human).
; Parameters:   m_allStacks, list that holds both the CPU's and Human's original 6 Stacks.
;               m_newAllStacks, list that represents the modified m_allStacks.
;               m_hand, list that represents the placing Player's Hand.
;               m_tileSelected, list that represents the Tile that the Player selected to place.
;               m_stackSelected, list that represents the Stack that the Player wants to place their Tile on.
;               m_whichPlayersStacks, an integer that represents which Player's original Stacks is getting a Tile place onto it.
;               m_counter, integer that represents the number of iterations, used to keep track of which Stack is being evaluated.
; Return Value: Returns list of allStacks (CPU's Stacks with the Human's Stacks) and the modified Player's Hand.
; Algorithm:    1) Set currStack to the respective Player's Stack that is being placed on sepcified by m_whichPlayersStacks at m_counter index.
;                       a) If the last element in the Stacks passed is not the Stack selected, then just return the completed Stacks with the old last Stack appended.
;                       b) If the current Stack is not equal to the Stack selected and it is not the last element, then recursively call this function and append the current old Stack onto parameter m_newAllStacks.
;                       c) If the last element in the Stacks passed is the Stack selected, then just return the completed Stacks with the Stack selected appended.
;                       d) If the current Stack is equal to the Stack selected and it is not the last element, then recursively call this function and append the selected Stack onto parameter m_newAllStacks.
; Assistance Received: None.
; *********************************************************************
(defun placeOntoStack (m_allStacks m_newAllStacks m_hand m_tileSelected m_stackSelected m_whichPlayersStacks m_counter)
        ; If the current stack in question is not equal to the stack selected, keep it the same in parameter m_newALLStacks.
        (let    ((currStack (nth m_counter (nth m_whichPlayersStacks m_allStacks))))
                        ; If the last element in the Stacks passed is not the Stack selected, then just return the completed Stacks with the old last Stack appended.
                (cond   ((and (not (equal currStack m_stackSelected)) (= m_counter 6))
                        (return-from placeOntoStack (append (reconstructAllStacks m_allStacks m_newAllStacks m_whichPlayersStacks) (list (removeTileFromList m_tileSelected m_hand '())))))
                        ; If the current Stack is not equal to the Stack selected and it is not the last element, then recursively call this function and append the current old Stack onto parameter m_newAllStacks.
                        ((not (equal currStack m_stackSelected))
                        (return-from placeOntoStack (placeOntoStack m_allStacks (append m_newAllStacks (list currStack)) m_hand m_tileSelected m_stackSelected m_whichPlayersStacks (+ 1 m_counter))))
                        ; If the last element in the Stacks passed is the Stack selected, then just return the completed Stacks with the Stack selected appended.
                        ((and (equal currStack m_stackSelected) (= m_counter 6))
                        (return-from placeOntoStack (append (reconstructAllStacks m_allStacks m_newAllStacks m_whichPlayersStacks) (list (removeTileFromList m_tileSelected m_hand '())))))
                        ; If the current Stack is equal to the Stack selected and it is not the last element, then recursively call this function and append the selected Stack onto parameter m_newAllStacks.
                        ((equal currStack m_stackSelected)
                        (return-from placeOntoStack (placeOntoStack m_allStacks (append m_newAllStacks (list m_tileSelected)) m_hand m_tileSelected m_stackSelected m_whichPlayersStacks (+ 1 m_counter))))
                )
        )
)

; *********************************************************************
; Function Name: reconstructAllStacks
; Purpose: Reconstructs allStacks for placeOntoStack(). Will take the Stack passed in and reconstruct allStacks accordingly based on which Player's Stacks it originally was.
; Parameters:   m_allStacks, list that represents the CPU's Stacks and the Human's Stacks.
;               m_stacks, list that represents the Stacks that have been modified in placeOntoStack().
;               m_whichPlayersStacks, integer that represents which Player's original 6 Stacks were modified.
; Algorithm:    1) Evaluate parameter m_whichPlayersStacks.
;                       a) If m_whichPlayersStacks = 0, then return the a list with the modified m_stacks with the second element of m_allStacks.
;                       b) If m_whichPlayersStacks = 1, then return the a list with the first element of m_allStacks with the modified m_stacks.
; Assistance Received: None.
; *********************************************************************
(defun reconstructAllStacks (m_allStacks m_stacks m_whichPlayersStacks)
            ; If a Tile was placed on one of the CPU's original Stacks, then return a list with the modified m_stacks (modified CPU Stacks) with the original parameter m_allStacks Human's Stacks.
    (cond   ((= m_whichPlayersStacks 0)
            (return-from reconstructAllStacks (list m_stacks (nth 1 m_allStacks))))
            ; If a Tile was placed on one of the Human's original Stacks, then return a list with the original CPU's Stacks from parameter m_allStacks and the modified Human's Stacks.
            ((= m_whichPlayersStacks 1)
            (return-from reconstructAllStacks (list (nth 0 m_allStacks) m_stacks)))
    )
)

; *********************************************************************
; Function Name: removeTileFromList
; Purpose: Removes the Tile passed through from the list passed through.
; Parameters:   m_tile, list that represents the Tile that is to be removed from m_list.
;               m_list, list that is getting a Tile removed from it.
;               m_newList, list that is reflective of m_list without m_tile.
; Algorithm:    1) Evaluate the first Tile in m_list.
;                       a) If the element in question is equal to the Tile passed through and is not the last element in m_list, then do not copy that to m_newList and pop the first Tile in m_list, repeat step 1 (through recursion).
;                       b) If the element in question is equal to the Tile passed through and is tthe last element in m_list, then return m_newList without the current Tile in question.
;                       c) If the element in question is not equal to the Tile passed through and it's not the last element in m_list, then copy the element to m_newList and pop the first Tile in m_list, repeat step 1 (through recursion).
;                       d) If the element in question is not equal to the Tile passed through and it's the last element in m_list, then copy the element to m_newList and add it to the new list.
; Assistance Received: None.
; *********************************************************************
(defun removeTileFromList (m_tile m_list m_newList)
            ; If the element in question is equal to the Tile passed through, then do not copy that and keep iterating through the list.
    (cond   ((and (equal m_tile (first m_list)) (> (length m_list) 1))
            (return-from removeTileFromList (removeTileFromList m_tile (rest m_list) m_newList)))
            ; If it is an ending condition, then return the list without the current Tile in question.
            ((and (equal m_tile (first m_list)) (= (length m_list) 1))
            (return-from removeTileFromList m_newList))
    )
            ; If the element in question is not equal to the Tile passed through and it's not an ending condition, then copy the element and add it to the new list.
    (cond   ((and (not (equal m_tile (first m_list))) (> (length m_list) 1))
            (return-from removeTileFromList (removeTileFromList m_tile (rest m_list) (append m_newList (list (first m_list))))))
            ; If it is an ending condition, then return the list with the current Tile in question.
            ((and (not (equal m_tile (first m_list))) (= (length m_list) 1))
            (return-from removeTileFromList (append m_newList (list (first m_list)))))
    )
)

; *********************************************************************
; Function Name: whichPlayersStacks
; Purpose: Returns whether the Stack passed in is on the CPU's or Human's original stacks. Returns 0 if CPU's and 1 if Human's. This assumes that m_allStacks has the CPU's orignal Stacks first and then the Human's.
; Parameters:   m_allStacks, list that represents the CPU's and Human's original 6 Stacks.
;               m_stackSelection, list that represents the Stack that was selected to have a Tile placed onto it.
; Algorithm:    1) Evaluate m_stackSelection using isInList().
;                       a) If m_stackSelection is in the CPU's stacks, return 0.
;                       b) If m_stackSelection is in the Human's stacks, return 1.
; Assistance Received: None.
; *********************************************************************
(defun whichPlayersStacks (m_allStacks m_stackSelection)
    ; If the Stack selected is in the CPU's stacks, return 0. If it is in the Human's stacks, return 1.
    (cond   ((string= (isInList (first m_allStacks) m_stackSelection) "true")
            (return-from whichPlayersStacks 0))
            ((string= (isInList (nth 1 m_allStacks) m_stackSelection) "true")
            (return-from whichPlayersStacks 1)))
    ; If it is in neither, return -1.
    (return-from whichPlayersStacks -1)
)

; *********************************************************************
; Function Name: playerCanPlace
; Purpose: Determines whether the Player specified by parameter m_currTurn can place a Tile in Hand or not by passing the correct Hand to function canPlace.
; Parameters:   m_cpuHand, list that represents the CPU's Hand.
;               m_humanHand, list that represents the Human's Hand.
;               m_cpuStacks, list that represents the CPU's original 6 Stacks.
;               m_humanStacks, list that represents the Human's original 6 Stacks.
;               m_currTurn, integer that represents which Player's turn it is to determine which Player to evaluate.
; Algorithm:    1) Evaluate m_currTurn.
;                       a) If m_currTurn is odd (meaning that it is the CPU's turn, as is constant throughout this program), then return what canPlace() returns and pass the CPU's hand and the CPU's and Human's Stacks.
;                       b) If m_currTurn is even (meaning that it is the Human's turn, as is constant throughout this program), then return what canPlace() returns and pass the Human's hand and the CPU's and Human's Stacks.
; Assistance Received: None.
; ********************************************************************
(defun playerCanPlace (m_cpuHand m_humanHand m_cpuStacks m_humanStacks m_currTurn)
            ; If parameter m_currTurn is odd, then it is the CPU's turn. Pass the CPU's Hand into canPlace().
    (cond   ((> (mod m_currTurn 2) 0)
            (return-from playerCanPlace (canPlace m_cpuHand m_cpuStacks m_humanStacks)))
            ; If parameter m_currTurn is even, then it is the Human's turn. Pass the Human's Hand into canPlace().
            ((= (mod m_currTurn 2) 0)
            (return-from playerCanPlace (canPlace m_humanHand m_cpuStacks m_humanStacks)))
    )
)

; *********************************************************************
; Function Name: canPlace
; Purpose: Function that actually determines whether the Hand passed can place any Tile on any Stack. Returns "true" if the Player can place a Tile and "false" if the Player cannot.
; Parameters:   m_playerHand, list that represents the Player's Hand that is to be evaluated.
;               m_cpuStacks, list that represents the CPU's original 6 Stacks.
;               m_humanStacks, list that represents the Human's original 6 Stacks.
; Algorithm:    1) If there are no Tiles in m_playerHand, then return "false".
;               2) Set currTile to the first Tile in m_playerHand. Find its valid Stack placements using validStackPlacements().
;                       a) If currTile has any valid Stacks, then return "true".
;                       b) If currTile has no valid Stacks and there is more than 1 Tile in m_playerHand (meaning that the current Tile in question is not the last one in Hand), evaluate the next Tile in hand and repeat step 1) (through recursion and popping the first tile from m_playerHand).
;                       c) If currTile has no valid Stacks and it is the last Tile in m_playerHand, then return "false".
; Assistance Received: None.
; ********************************************************************
(defun canPlace (m_playerHand m_cpuStacks m_humanStacks)
    ; If the Hand in question is empty, then the Player definitely cannot place a Tile. Return "false".
    (cond   ((= (length m_playerHand) 0)
            (return-from canPlace "false")))

    (let*   ((currTile (first m_playerHand))
            (validStacks (validStackPlacements currTile (append m_cpuStacks m_humanStacks) '())))
                ; If the Hand Tile in question has a valid Stack placement, then the Player can place. Return "true".
        (cond   ((> (length validStacks) 0)
                (return-from canPlace "true"))
                ; If the Hand Tile in question does not have a valid Stack placement and is not the last Tile in consideration, recursively call canPlace() to consider the next Tile in Hand.
                ((> (length m_playerHand) 1)
                (return-from canPlace (canPlace (rest m_playerHand) m_cpuStacks m_humanStacks)))
                ; If the Hand Tile in question does not have a valid Stack placement and is the last Tile in consideration, then there are no Tiles in Hand that can be placed. Return "false".
                ((= (length m_playerHand) 1)
                (return-from canPlace "false"))
        )
    )
)

; *********************************************
; Source code for CPU's game strategies and intelligence.
; *********************************************
; *********************************************************************
; Function Name: cpuTurn
; Purpose: Lets the CPU play optimally for a turn.
; Parameters:   m_cpuStacks, list that represents the CPU's original 6 Stacks.
;               m_humanStacks, list that represents the Human's original 6 Stacks.
;               m_cpuHand, list that represents the CPU's Hand.
; Algorithm:    1) Print that it is the CPU's turn and print m_cpuHand.
;               2) Set the optimal Tile to tileAndStackPref using optimalhandTile(), where the list returned has the optimal Tile as the first element and the Stack preference as the second.
;               3) Set the optimal stack to stackSelected using optimalStackPlacement, passing in the optimal Tile and Stack preference from tielAndStackPref.
;               4) Print that the Tile chosen is being placed on the Stack chosen.
;               5) Place the Tile selected onto the Stack selected using placeOntoStack() and return its return value.
; Assistance Received: None.
; ********************************************************************
(defun cpuTurn (m_cpuStacks m_humanStacks m_cpuHand)
    (printMult "_______________________________________________________________________")
    (printMult "Computer's Turn:")
    (printMult "_______________________________________________________________________")
    (terpri)
    ; Print the Computer's Hand before placement.
    (printMult "Computer's Hand:")
    (printMult m_cpuHand)
    (terpri)
    (let*   ((tileAndStackPref (optimalHandTile m_cpuStacks m_humanStacks m_cpuHand))
            (stackSelected (optimalStackPlacement (first tileAndStackPref) (nth 1 tileAndStackPref) m_cpuStacks m_humanStacks))
            (stackName (getStackName stackSelected (list m_cpuStacks m_humanStacks) nil nil 0))
            (allStacks (list m_cpuStacks m_humanStacks)))
        (printMult "Placing Tile" (first tileAndStackPref) "on Stack" stackName ", which has" stackSelected)
        (terpri)
        (return-from cpuTurn (placeOntoStack allStacks '() m_cpuHand (first tileAndStackPref) stackSelected (whichPlayersStacks allStacks stackSelected) 0))
    )
)

; *********************************************************************
; Function Name: getStackName
; Purpose: Takes a Stack passed in and prints its respective label in the UI. (Example: If a Stack (W 1 3) is passed in, this function will return that Stack's label, a 'W or 'B followed by a digit). Used to make output for either Player's choices more clear for the Human.
; Parameters:   m_stackSelected, a list that represents the Stack chosen by either PLayer.
;               m_allStacks, a list that has the CPU's Stacks as its first element and the Human's as its second.
;               m_playerStacks, a list that stores which Player's Stacks in m_allStacks that will be evaluated. Initially nil.
;               m_color, a symbol that represents the Player whose Stacks the Stack selected comes from (either 'W or 'B).
;               m_counter, an integer that is used to iterate through m_playerStacks.
; Algorithm:    1) Evaluate the Stack passed in.
;                       a) If the Stack selected is from the CPU's original 6 Stacks, then recursively call the function to evaluate the CPU's Stacks.
;                       b) If the Stack selected is from the Human's original 6 Stacks, then recursively call the function to evaluate the Human's Stacks.
;               2) Evaluate the current Stack at index m_counter (which starts at 0).
;                       a) If the current Stack in question is the the Stack that was selected, m_stackSelected, then return its respective UI label, which should have its respective color, and the m_counter incremented by 1.
;                       b) If the current Stack in question is not the Stack that was selected, m_stackSelected, then evaluate the next Stack by recursively calling the function and incrementing the m_counter.
; Assistance Received: None.
; ********************************************************************
(defun getStackName (m_stackSelected m_allStacks m_playerStacks m_color m_counter)
                ; If the Stack selected is from the CPU's original 6 Stacks, then recursively call the function to evaluate the CPU's Stacks.
        (cond   ((and (string= (isInList (first m_allStacks) m_stackSelected) "true") (eq m_playerStacks nil))
                (return-from getStackName (getStackName m_stackSelected m_allStacks (first m_allStacks) 'W m_counter)))
                ; If the Stack selected is from the Human's original 6 Stacks, then recursively call the function to evaluate the Human's Stacks.
                ((and (string= (isInList (second m_allStacks) m_stackSelected) "true") (eq m_playerStacks nil))
                (return-from getStackName (getStackName m_stackSelected m_allStacks (second m_allStacks) 'B m_counter))))

                ; If the current Stack in question is the the Stack that was selected, m_stackSelected, then return its respective UI label, which should have its respective color, and the m_counter incremented by 1.
        (cond   ((equal m_stackSelected (nth m_counter m_playerStacks))
                (return-from getStackName (concatenate 'string (string m_color) (write-to-string (+ 1 m_counter)))))
                ; If the current Stack in question is not the Stack that was selected, m_stackSelected, then evaluate the next Stack by recursively calling the function and incrementing the m_counter.
                (t
                (return-from getStackName (getStackName m_stackSelected m_allStacks m_playerStacks m_color (+ 1 m_counter)))))
)

; *********************************************************************
; Function Name: optimalHandTile
; Purpose: CPU chooses the optimal Tile in Hand to play and whether to find the largest opposite-topped Stack (0), (1), (2), (3), or smallest own Stack (4), (5).
; Parameters:   m_cpuStacks, list that represents the CPU's original 6 Stacks.
;               m_humanStacks, list that represents the Human's original 6 Stacks.
;               m_cpuHand, list that represents the CPU's Hand.
; Algorithm:    1) Determine whether the CPU is in an advantage or disadvantage state.
;                       a) If there are more opposite topped Stacks than own topped Stacks, then it is a disadvantage state. Find the largest non double Tile in list and return it if it has any valid opposite topped Stack placements. If the largest Tile has no valid opposite topped Stack placements, then find the largest double Tile in list and return it if it has any valid opposite topped Stack placements.
;                       b) If there are an equal or less amount of opposite topped Stacks than own topped Stacks, then it is an advatage state. Then find the smallest non double Tile in Hand that has any valid opposite topped Stack placements. If none can be found, find the smallest double Tile in Hand that has any valid opposite topped Stack placements.
;                       c) If the above two cases fall through, this means that the CPU does not have any Tiles in Hand that can be placed onto any opposite topped Stack. Find the smallest non double Tile in Hand that can be placed on the smallest own topped Stack possible. If none can be found, find the smallest double Tile in Hand that can be placed on the smallest own topped Stack possible.
; Cases:
;       Placing onto largest opposite-Stack possible:
;       (0): CPU is in disadvantage state and the largest non double in Hand has a valid opposite-topped Stack.
;       (1): CPU is in disadvantage state and the largest non double in Hand has no valid Stack placements, so the largest double Tile in Hand is found instead.
;       (2): CPU is in advantage state and the smallest valid non double in Hand is found.
;       (3): CPU is in advantage state and no valid non doubles in Hand were found, so the smallest valid double in Hand is looked for instead.
;       Placing onto smallest own-Stack possible:
;       (4): Find the smallest non double in Hand that has any valid Stack placements (which would presumably be an own-topped stack, otherwise this would have been caught by one of the above cases).
;       (5): Since no valid non doubles in Hand were found, instead find the smallest double in Hand that has any valid Stack placements (which would presumably be an own-topped stack, otherwise this would have been caught by one of the above cases).
; Assistance Received: None.
; ********************************************************************
(defun optimalHandTile (m_cpuStacks m_humanStacks m_cpuHand)
     (let*    ((oppositeColor (oppositeColor (first (first m_cpuHand))))
              (oppToppedStacks (oppositeToppedStacks (append m_cpuStacks m_humanStacks) oppositeColor '()))
              (nonDblsInHand (nonDoublesInList m_cpuHand '()))
              (dblsInHand (doublesInList m_cpuHand '()))
              (largestNonDblInHand (largestTileInList nonDblsInHand nil))
              (largestDblInHand (largestTileInList dblsInHand nil)))
        ; CPU is in disadvantaged state (Human is topping more Stacks than the CPU):
                ; If the largest non double Tile in Hand has a valid opposite-stack placement, then return that Tile.
        (cond   ((and (> (length oppToppedStacks) 6) (> (length (oppositeToppedStacks (validStackPlacements largestNonDblInHand (append m_cpuStacks m_humanStacks) '()) oppositeColor '())) 0))
                (return-from optimalHandTile (append (list largestNonDblInHand) (list '(0)))))
                ; If the largest double Tile in Hand has a valid opposite-stack placement, then return that Tile.
                ((and (> (length oppToppedStacks) 6) (> (length (oppositeToppedStacks (validStackPlacements largestDblInHand (append m_cpuStacks m_humanStacks) '()) oppositeColor '())) 0))
                (return-from optimalHandTile (append (list largestDblInHand) (list '(1))))))
        ; CPU is in advantaged state (CPU is topping more Stacks than the Human):
                ; If there exists a Tile in Hand a smallest non double Tile with valid opposite topped Stack placements, return that Tile.
        (cond   ((and (<= (length oppToppedStacks) 6) (not (eq (smallestOptimalTileInList nonDblsInHand m_cpuStacks m_humanStacks oppositeColor) nil)))
                (return-from optimalHandTile (append (list (smallestOptimalTileInList nonDblsInHand m_cpuStacks m_humanStacks oppositeColor)) (list '(2)))))
                ; If there exists a Tile in Hand a smallest double Tile with valid opposite topped Stack placements, return that Tile.
                ((and (<= (length oppToppedStacks) 6) (not (eq (smallestOptimalTileInList dblsInHand m_cpuStacks m_humanStacks oppositeColor) nil)))
                (return-from optimalHandTile (append (list (smallestOptimalTileInList dblsInHand m_cpuStacks m_humanStacks oppositeColor)) (list '(3))))))
        
        ; If none of the above conditions were met, it's because the CPU cannot place on any Human-topped Stacks. Find the smallest Tile in Hand to place on own topped Stack.
                ; Find the smallest valid non double in Hand that can be placed on any Stack (allegedly any self topped Stack, as it would have been caught in earlier cases if an opposite topped Stack were available).
        (cond   ((not (eq (smallestValidTileInList nonDblsInHand m_cpuStacks m_humanStacks) nil))
                (return-from optimalHandTile (append (list (smallestValidTileInList nonDblsInHand m_cpuStacks m_humanStacks)) (list '(4)))))
                ; Find the smallest valid double in Hand that can be placed on any Stack (allegedly any self topped Stack, as it would have been caught in earlier cases if an opposite topped Stack were available).
                ((not (eq (smallestValidTileInList dblsInHand m_cpuStacks m_humanStacks) nil))
                (return-from optimalHandTile (append (list (smallestValidTileInList dblsInHand m_cpuStacks m_humanStacks)) (list '(5))))))
     )
)

; *********************************************************************
; Function Name: optimalStackPlacement
; Purpose: CPU chooses the optimal Stack to place the Tile selected onto based on the reasoning that's also passed in.
; Parameters:   m_tileSelected, a list that represents the Tile selected from optimalHandTile.
;               m_stackPref, an integer that represents the specific case for the Tile selected.
;               m_cpuStacks, a list that represents the CPU's original 6 Stacks.
;               m_humanStacks, a list that represents the Human's original 6 Stacks.
; Algorithm:    1) Print the optimal Tile, m_tileSelected, and the Stack it will be placed on as well as te reasoning based on m_stackPref.
; Cases:
;       Placing onto largest opposite-Stack possible:
;       (0): CPU is in disadvantage state and the largest non double in Hand has a valid opposite-topped Stack.
;       (1): CPU is in disadvantage state and the largest non double in Hand has no valid Stack placements, so the largest double Tile in Hand is found instead.
;       (2): CPU is in advantage state and the smallest valid non double in Hand is found.
;       (3): CPU is in advantage state and no valid non doubles in Hand were found, so the smallest valid double in Hand is looked for instead.
;       Placing onto smallest own-Stack possible:
;       (4): Find the smallest non double in Hand that has any valid Stack placements (which would presumably be an own-topped stack, otherwise this would have been caught by one of the above cases).
;       (5): Since no valid non doubles in Hand were found, instead find the smallest double in Hand that has any valid Stack placements (which would presumably be an own-topped stack, otherwise this would have been caught by one of the above cases).
; Assistance Received: None.
; ********************************************************************
(defun optimalStackPlacement (m_tileSelected m_stackPref m_cpuStacks m_humanStacks)
        (let*   ((color (first m_tileSelected))
                (oppositeColor (oppositeColor color))
                (stackSelected (stackFromReason m_tileSelected m_stackPref m_cpuStacks m_humanStacks))
                (stackName (getStackName stackSelected (list m_cpuStacks m_humanStacks) nil nil 0)))

                ; Print the reasoning for the Human since the Tile placement and the Stack placement has been deduced.                                                  getStackName (m_stackSelected m_allStacks m_playerStacks m_color m_counter)
                (cond   ((equal m_stackPref '(0))
                        (printMult "Computer chose to place the largest non double Tile in Hand," m_tileSelected ", onto the largest opposite Player's Stack possible," stackName ", which has" stackSelected ", to reduce opposite Player's Stacks."))
                        ((equal m_stackPref '(1))
                        (printMult "Computer chose to place the largest double Tile in Hand," m_tileSelected ", onto the largest opposite Player's Stack possible," stackName ", which has" stackSelected ", to reduce opposite Player's Stacks."))
                        ((equal m_stackPref '(2))
                        (printMult "Computer chose to place the smallest non double Tile in Hand with opposite-topped Stack placements," m_tileSelected ", onto the largest opposite Player's Stack possible," stackName ", which has" stackSelected ", to get rid of smallest valid non double Tiles in Hand."))
                        ((equal m_stackPref '(3))
                        (printMult "Computer chose to place the smallest double Tile in Hand with opposite-topped Stack placements," m_tileSelected ", onto the largest opposite Player's Stack possible," stackName ", which has" stackSelected ", to get rid of smallest valid non double Tiles in Hand."))
                        ; If the objective was to place the Tile selected onto the smallest own topped Stack possible, return the smallest self topped Stack possible.
                        ((equal m_stackPref '(4))
                        (printMult "Computer chose to place the smallest valid non double Tile in Hand," m_tileSelected ", onto the smallest own Stack possible," stackName ", which has" stackSelected ", since no opposite topped Stacks can be topped."))
                        ((equal m_stackPref '(5))
                        (printMult "Computer chose to place the smallest valid double Tile in Hand," m_tileSelected ", onto the smallest own Stack possible," stackName ", which has" stackSelected ", since no opposite topped Stacks can be topped.")))
             
                ; If the objective was to place the Tile selected onto the largest opposite topped Stack possible, return the largest opposite topped Stack possible.
                (cond   ((or (equal m_stackPref '(0)) (equal m_stackPref '(1)) (equal m_stackPref '(2)) (equal m_stackPref '(3)))
                        (return-from optimalStackPlacement stackSelected))
                        ; If the objective was to place the Tile selected onto the smallest own topped Stack possible, return the smallest self topped Stack possible.
                        ((or (equal m_stackPref '(4)) (equal m_stackPref '(5)))
                        (return-from optimalStackPlacement stackSelected)))
        )
)

; *********************************************************************
; Function Name: stackFromReason
; Purpose: Selects the optimal Stack based on the reasoning passed in. Meant to be used in optimalStackPlacement().
; Parameters:   m_tileSelected m_stackPref m_cpuStacks m_humanStacks
; Algorithm:    1) Print the optimal Tile, m_tileSelected, and the Stack it will be placed on as well as te reasoning based on m_stackPref.
; Cases:
;       Placing onto largest opposite-Stack possible:
;       (0): CPU is in disadvantage state and the largest non double in Hand has a valid opposite-topped Stack.
;       (1): CPU is in disadvantage state and the largest non double in Hand has no valid Stack placements, so the largest double Tile in Hand is found instead.
;       (2): CPU is in advantage state and the smallest valid non double in Hand is found.
;       (3): CPU is in advantage state and no valid non doubles in Hand were found, so the smallest valid double in Hand is looked for instead.
;       Placing onto smallest own-Stack possible:
;       (4): Find the smallest non double in Hand that has any valid Stack placements (which would presumably be an own-topped stack, otherwise this would have been caught by one of the above cases).
;       (5): Since no valid non doubles in Hand were found, instead find the smallest double in Hand that has any valid Stack placements (which would presumably be an own-topped stack, otherwise this would have been caught by one of the above cases).
; Assistance Received: None.
; ********************************************************************
(defun stackFromReason (m_tileSelected m_stackPref m_cpuStacks m_humanStacks)
        (let*    ((color (first m_tileSelected))
                (oppositeColor (oppositeColor color)))
                        ; If the reasons were 0-3, then return the largest valid opposite topped Stack possible.
                (cond   ((or (equal m_stackPref '(0)) (equal m_stackPref '(1)) (equal m_stackPref '(2)) (equal m_stackPref '(3)))
                        (return-from stackFromReason (largestTileInList (oppositeToppedStacks (validStackPlacements m_tileSelected (append m_cpuStacks m_humanStacks) '()) oppositeColor '()) nil)))
                        ; If the reasons were 4-5, then return the smallest valid own topped Stack possible.
                        ((or (equal m_stackPref '(4)) (equal m_stackPref '(5)))
                        (return-from stackFromReason (smallestTileInList (oppositeToppedStacks (validStackPlacements m_tileSelected (append m_cpuStacks m_humanStacks) '()) color '()) nil))))
        )
)

; *********************************************************************
; Function Name: oppositeColor
; Purpose: Returns the opposite Player's color to the one passed in. Used to determine opposite Player and more importantly, their opposite Player's Stacks in oppositeToppedStacks().
; Parameters:   m_color, a symbol that represents one of the Player's colors ('W or 'B).
; Algorithm:    1) Evaluate m_color.
;                       a) If m_color is 'W, then its opposite color is 'B, return 'B.
;                       b) If m_color is 'B, then its opposite color is 'W, return 'W.
; Assistance Received: None.
; ********************************************************************
(defun oppositeColor (m_color)
        ; If the color passed in is white, then the opposite is black.
        (cond   ((eq m_color 'W)
                (return-from oppositeColor 'B)))
        ; If the color passed in is black, then the opposite is white.
        (cond   ((eq m_color 'B)
                (return-from oppositeColor 'W)))        
)

; *********************************************************************
; Function Name: oppositeToppedStacks
; Purpose: Returns list of Tiles of color m_oppositeColor in the list passed in.
; Parameters:   m_list, presumably a concatenated list of Tiles (presumably valid Stack placements).
;               m_oppositeColor, a symbol that represents the color to look for in the 12 Stacks.
;               m_oppositeToppedStacks, a list that accumulates all of the Tiles in m_list that have the color m_oppositeColor.
; Algorithm:    1) If there are no more Tiles in m_list, return m_oppositeToppedStacks.
;               2) Evaluate the first element in m_list.
;                       a) If the element's color is equal to m_oppositeColor, append it to m_oppositeToppedStacks and evaluate the next Tile in m_list and repeat step 1) (by popping the first Tile in m_list and passing it through oppositeToppedStacks() recursively).
;                       b) If the element's color is not equal to m_oppositeColor, then evaluate the next Tile and repeat step 1) (by popping the first Tile in m_list and passing it through oppositeToppedStacks() recursion).
; Assistance Received: None.
; ********************************************************************
(defun oppositeToppedStacks (m_list m_oppositeColor m_oppositeToppedStacks)
        ; If there are no more Stacks to evaluate, then return the opposite topped Stacks
        (cond   ((= (length m_list) 0)
                (return-from oppositeToppedStacks m_oppositeToppedStacks)))  
                ; If the current Stack in question is topped by a Tile with the opposite color passed in, then add this Tile to m_oppositeToppedStacks. Then evaluate the next Tile in Stacks.
        (cond   ((eq (first (first m_list)) m_oppositeColor)
                (return-from oppositeToppedStacks (oppositeToppedStacks (rest m_list) m_oppositeColor (append m_oppositeToppedStacks (list (first m_list))))))
                ; If the current Stack in question is not topped by a Tile with the opposite color passed in, then do not add the Tile to m_oppositeToppedStacks and evaluate the next Tile in Stacks.
                ((not (eq (first (first m_list)) m_oppositeColor))
                (return-from oppositeToppedStacks (oppositeToppedStacks (rest m_list) m_oppositeColor m_oppositeToppedStacks)))) 
)

; *********************************************************************
; Function Name: doublesInList
; Purpose: Returns list of doubles in list passed in. Used for determining optimal Tiles to choose for CPU's strategy.
; Parameters:   m_list, presumably the CPU's Hand.
;               m_doublesList, a list with the accumulated doubles found in m_list.
; Algorithm:    1) If there are no more Tiles in m_list, return m_doublesList.
;               2) Evaluate the first element in m_list.
;                       a) If the element is found to be a double Tile using isDouble(), append it to m_doublesList and evaluate the next Tile in m_list and repeat step 1) (by popping the first Tile in m_list and passing it through doublesInList() recursively).
;                       b) If the element is found to be a non double Tile using isDouble(), then evaluate the next Tile and repeat step 1) (by popping the first Tile in m_list and passing it through oppositeToppedStacks() recursion).
; Assistance Received: None.
; ********************************************************************
(defun doublesInList (m_list m_doublesList)
        ; If there are no more Tiles in list passed in to evaluate, return all of the doubles.
        (cond   ((= (length m_list) 0)
                (return-from doublesInList m_doublesList)))

                ; If the current Tile in question is a double, recursively call doublesInList() to evaluate the next Tile in list and push the current tile in the doubles list.
        (cond   ((string= (isDouble (first m_list)) "true")
                (return-from doublesInList (doublesInList (rest m_list) (append m_doublesList (list (first m_list))))))
                ; If the current Tile in question is not a double, recursively call doublesInList() to evaluate the next Tile in list and don't change the doubles list.
                ((string= (isDouble (first m_list)) "false")
                (return-from doublesInList (doublesInList (rest m_list) m_doublesList))))
)

; *********************************************************************
; Function Name: nonDoublesInList
; Purpose: Returns list of non doubles in list passed in. Used for determining optimal Tiles to choose for CPU's strategy.
; Parameters:   m_list, presumably the CPU's Hand.
;               m_nonDoublesList, a list with the accumulated non doubles found in m_list.
; Algorithm:    1) If there are no more Tiles in m_list, return m_nonDoublesList.
;               2) Evaluate the first element in m_list.
;                       a) If the element is found to be a non double Tile using isDouble(), append it to m_nonDoublesList and evaluate the next Tile in m_list and repeat step 1) (by popping the first Tile in m_list and passing it through nonDoublesInList() recursively).
;                       b) If the element is found to be a double Tile using isDouble(), then evaluate the next Tile and repeat step 1) (by popping the first Tile in m_list and passing it through nonDoublesInList() recursively).
; Assistance Received: None.
; ********************************************************************
(defun nonDoublesInList (m_list m_nonDoublesList)
        ; If there are no more Tiles in list passed in to evaluate, return all of the doubles.
        (cond   ((= (length m_list) 0)
                (return-from nonDoublesInList m_nonDoublesList)))

                ; If the current Tile in question is a non double, recursively call nonDoublesInList() to evaluate the next Tile in list and push the current tile in the non doubles list.
        (cond   ((string= (isDouble (first m_list)) "false")
                (return-from nonDoublesInList (nonDoublesInList (rest m_list) (append m_nonDoublesList (list (first m_list))))))
                ; If the current Tile in question is a double, recursively call nonDoublesInList() to evaluate the next Tile in list and don't change the non doubles list.
                ((string= (isDouble (first m_list)) "true")
                (return-from nonDoublesInList (nonDoublesInList (rest m_list) m_nonDoublesList))))
)

; *********************************************************************
; Function Name: largestTileInList
; Purpose: Returns the largest Tile found in the list parameter. Used to find largest Tiles in Hand or in valid Stack placements.
; Parameters:   m_list, a list consisting of Tiles, presumably a Hand or a list of valid Stack placements.
;               m_largestTile, the largest Tile found in the list. Initially nil.
; Algorithm:    1) If there are no Tiles left in m_list, return m_largestTile.
;               2) Evaluate the first Tile in m_list.
;                       a) m_largestTile is nil or it has more pips than m_largestTile, set m_largestTile to the current Tile in question. Consider the next element in m_list and repeat step 1) (by popping the first element in m_list and passing it recursively through largestTileInList()).
;                       b) Otherwise, consider the next element in m_list and repeat step 1) (by popping the first element in m_list and passing it recursively through largestTileInList()).
; Assistance Received: None.
; ********************************************************************
(defun largestTileInList (m_list m_largestTile)
        ; If the list is empty or there are no more Tiles in list to evaluate, then return the largest Tile in Hand.
        (cond   ((= (length m_list) 0)
                (return-from largestTileInList m_largestTile)))
                ; If the function just started or the Tile in question is greater than the previous largest Tile, set the largest Tile to the first one in the list.
        (cond   ((or (eq m_largestTile nil) (> (getTotalPips (first m_list)) (getTotalPips m_largestTile)))
                (return-from largestTileInList (largestTileInList (rest m_list) (first m_list))))
                ; Otherwise, consider the next Tile in list and do not change the largest Tile.
                (t
                (return-from largestTileInList (largestTileInList (rest m_list) m_largestTile))))
)

; *********************************************************************
; Function Name: smallestTileInList
; Purpose: Returns the smallest Tile found in the list parameter. Used to find largest Tiles in Hand or in valid Stack placements.
; Parameters:   m_list, a list consisting of Tiles, presumably a Hand or a list of valid Stack placements.
;               m_smallestTile, the smallest Tile found in the list. Initially nil.
; Algorithm:    1) If there are no Tiles left in m_list, return m_smallestTile.
;               2) Evaluate the first Tile in m_list.
;                       a) m_smallestTile is nil or it has less pips than m_smallestTile, set m_smallestTile to the current Tile in question. Consider the next element in m_list and repeat step 1) (by popping the first element in m_list and passing it recursively through smallestTileInList()).
;                       b) Otherwise, consider the next element in m_list and repeat step 1) (by popping the first element in m_list and passing it recursively through smallestTileInList()).
; Assistance Received: None.
; ********************************************************************
(defun smallestTileInList (m_list m_smallestTile)
        ; If the list is empty or there are no more Tiles in list to evaluate, then return the smallest Tile in Hand.
        (cond   ((= (length m_list) 0)
                (return-from smallestTileInList m_smallestTile)))
                ; If the function just started or the Tile in question is less than the previous smallest Tile, set the smallest Tile to the first one in the list.
        (cond   ((or (eq m_smallestTile nil) (< (getTotalPips (first m_list)) (getTotalPips m_smallestTile)))
                (return-from smallestTileInList (smallestTileInList (rest m_list) (first m_list))))
                ; Otherwise, consider the next Tile in list and do not change the smallest Tile.
                (t
                (return-from smallestTileInList (smallestTileInList (rest m_list) m_smallestTile))))
)

; *********************************************************************
; Function Name: smallestOptimalTileInList
; Purpose: Returns the smallest Tile in the list specified that has a valid opposite topped Stack placement. Used for the CPU's optimal Tile placement strategy for cases 2 and 3 (review cases in optimalHandTile() or optimalStackPlacement()).
; Parameters:   m_list, a list presumably of valid Stack placements.
;               m_cpuStacks, a list of Tiles that represents the CPU's original 6 Stacks.
;               m_humanStacks, a list of Tiles that represents the Human's original 6 Stacks.
;               m_oppositeColor, a symbol that represents the opposite color to look for in m_list.
; Algorithm:    1) If there are no Tiles left in m_list, return m_smallestTile.
;               2) Evaluate the smallest Tile in m_list.
;                       a) If the current Tile in question has any valid opposite topped Stack placements, return the current Tile in question.
;                       b) Otherwise, consider the next element in m_list and repeat step 1) (by removing the current Tile from m_list and passing that list recursively through smallestOptimalTileInList()).
; Assistance Received: None.
; ********************************************************************
(defun smallestOptimalTileInList (m_list m_cpuStacks m_humanStacks m_oppositeColor)
        ; If all of the Tiles in Hand have been evaluated and a smallest valid Tile is not found, then return nil.
        (cond   ((= (length m_list) 0)
                (return-from smallestOptimalTileInList nil)))
                ; If the current Tile in question has valid opposite Stack placements, then return the current smallest Tile in Hand.
        (cond   ((> (length (oppositeToppedStacks (validStackPlacements (smallestTileInList m_list nil) (append m_cpuStacks m_humanStacks) '()) m_oppositeColor '())) 0)
                (return-from smallestOptimalTileInList (smallestTileInList m_list nil)))
                ; Otherwise, consider the next smallest Tile in Hand instead.
                (t
                (return-from smallestOptimalTileInList (smallestOptimalTileInList (removeTileFromList (smallestTileInList m_list nil) m_list '()) m_cpuStacks m_humanStacks m_oppositeColor))))
)

; *********************************************************************
; Function Name: smallestValidTileInList
; Purpose: Returns the smallest Tile in the list specified that has any valid Stack placements. Used for optimal Tile selection in CPU's strategy in cases 4 or 5 (review optimalHandTile() or optimalStackPlacement()).
; Parameters:   m_list, a list presumably of valid Stack placements.
;               m_cpuStacks, a list of Tiles that represents the CPU's original 6 Stacks.
;               m_humanStacks, a list of Tiles that represents the Human's original 6 Stacks.
; Algorithm:    1) If there are no Tiles left in m_list, return m_smallestTile.
;               2) Evaluate the smallest Tile in m_list.
;                       a) If the current Tile in question has any valid Stack placements, return the current Tile in question.
;                       b) Otherwise, consider the next element in m_list and repeat step 1) (by removing the current Tile from m_list and passing that list recursively through smallestOptimalTileInList()).
; Assistance Received: None.
; ********************************************************************
(defun smallestValidTileInList (m_list m_cpuStacks m_humanStacks)
        ; If all of the Tiles in Hand have been evaluated and a smallest valid Tile is not found, then return nil.
        (cond   ((= (length m_list) 0)
                (return-from smallestValidTileInList nil)))
                ; If the current Tile in question has valid opposite Stack placements, then return the current smallest Tile in Hand.
        (cond   ((> (length (validStackPlacements (smallestTileInList m_list nil) (append m_cpuStacks m_humanStacks) '())) 0)
                (return-from smallestValidTileInList (smallestTileInList m_list nil)))
                ; Otherwise, consider the next smallest Tile in Hand instead.
                (t
                (return-from smallestValidTileInList (smallestValidTileInList (removeTileFromList (smallestTileInList m_list nil) m_list '()) m_cpuStacks m_humanStacks))))
)

; *********************************************
; Source code for the Human to play their turns during a Hand.
; *********************************************
; *********************************************************************
; Function Name: humanTurn
; Purpose: Human's Turn play.
; Parameters:   m_cpuStacks, a list of Tiles that represents the CPU's original 6 Stacks.
;               m_humanStacks, a list of Tiles that represents the Human's original 6 Stacks.
;               m_humanHand, a list of Tiles that represents the Human's Hand.
; Algorithm:    1) Print that it is the Human's Turn and print their Hand.
;               2) Let the Human select what Tile to place using selectTileToPlace() and store that into tileSelected.
;               3) Let the Human select what Stack to place the Tile onto using selectStackToPlace() and passing tileSelected into it.
;               4) Print the Tile they chose and what they chose to place it on and return the modified Stacks and Hand by returning what placeOntoStack() returns.
; Assistance Received: None.
; ********************************************************************
(defun humanTurn (m_cpuStacks m_humanStacks m_humanHand)
    ; Otherwise, let the Human play their turn.
    (printMult "_______________________________________________________________________")
    (printMult "Human's Turn:")
    (printMult "_______________________________________________________________________")
    (terpri)
    (printMult "Human's Hand:")
    (printMult m_humanHand)
    (terpri)
    (let*   ((tileSelected (selectTileToPlace m_cpuStacks m_humanStacks m_humanHand))
            (stackSelected (selectStackToPlace m_cpuStacks m_humanStacks tileSelected))
            (stackName (getStackName stackSelected (list m_cpuStacks m_humanStacks) nil nil 0))
            (allStacks (list m_cpuStacks m_humanStacks)))
        ; Tell Human what Tile they chose is being placed on the Stack they chose.
        (printMult "Placing Tile" tileSelected "on Stack" stackName ", which has" stackSelected)
        (terpri)
        (return-from humanTurn (placeOntoStack allStacks '() m_humanHand tileSelected stackSelected (whichPlayersStacks allStacks stackSelected) 0))
    )
)

; *********************************************************************
; Function Name: selectTileToPlace
; Purpose: Lets Human select what Tile to place.
; Parameters:   m_cpuStacks, a list of Tiles that represents the CPU's original 6 Stacks.
;               m_humanStacks, a list of Tiles that represents the Human's original 6 Stacks.
;               m_humanHand, a list of Tiles that represents the Human's Hand.
; Algorithm:    1) Ask Human what Tile they want to play or if they want a tip for the optimal Tile and Stack placement for that Tile and take the input.
;               2) Evaluate the input.
;                       a) If the input is "help", then print out the CPU's suggestion for the optimal Tile and its Stack placement by passing in the CPU and Human's Stacks and most importantly, the Human's Hand. Then recursively call SelectTileToplace() to take another input (repeat step 1).
;                       b) Validate that the input is a valid Tile with validTileInput(). If it returns false, then recursively call selectTileToPlace() to take another input (repeat step 1).
;               3) Convert the string input into a Tile format.
;               4) Find the selected Tile's valid Stack placements using validStackPlacements().
;               5) Evaluate the valid Stack placements for the Tile.
;                       a) If there are no valid Stack placements, let the Human know that this Tile has no valid Stack placements and that they must choose another Tile and then make them make another selection by recursively calling selectTileToPlace() (repeat step 1).
;                       b) If the Tile selected is not found in m_humanHand using isInList(), then tell the Human that the Tile selected cannot be found in Hand and then have them make another selection by recursivly callign selectTileToPlace() (repeat step 1).
;               6) Return the Tile selected.
; Assistance Received: None.
; ********************************************************************
(defun selectTileToPlace (m_cpuStacks m_humanStacks m_humanHand)
    (printMult "_______________________________________________________________________")
    (printMult "Select a Tile in Hand to play (Enter a 'B' followed by two numbers between 0-6. Example: B13). Enter \"help\" to get a tip:")
    (terpri)
    ; Read in Human's input as string.
    (let ((strTileSelected (read-line)))
        ; If the Human wants a tip, print out the optimal Tile and Stack to place it on. Then recursively call selectTileToPlace so that the Human can choose a Tile.
        (cond   ((string= strTileSelected "help")
                (printMult "Help Computer:")))
        ; Print out the optimal Tile and its optimal Stack placement.
        (cond   ((string= strTileSelected "help")
                (optimalStackPlacement (first (optimalHandTile m_cpuStacks m_humanStacks m_humanHand)) (second (optimalHandTile m_cpuStacks m_humanStacks m_humanHand)) m_cpuStacks m_humanStacks)))
        (cond   ((string= strTileSelected "help")
                (return-from selectTileToPlace (selectTileToPlace m_cpuStacks m_humanStacks m_humanHand))))
        ; If the Tile inputted is invalid in any way, then take another input for another Tile.
        (cond   ((string= (validTileInput strTileSelected) "false")
                (return-from selectTileToPlace (selectTileToPlace m_cpuStacks m_humanStacks m_humanHand)))
        )
        ; Convert the input into a Tile-list format for comparison.
        (let*   ((tileSelected (list (read-from-string (subseq strTileSelected 0 1)) (digit-char-p (char strTileSelected 1)) (digit-char-p (char strTileSelected 2))))
                (validStacks (validStackPlacements tileSelected (append m_cpuStacks m_humanStacks) '())))
            ; If the Tile selected has no valid Stack placements, ask for another Tile and ask for another input.
            (cond   ((= (length validStacks) 0)
                    (printMult "Tile selected cannot be placed on any Stack. Please make another selection.")))
            (cond   ((= (length validStacks) 0)
                    (return-from selectTileToPlace (selectTileToPlace m_cpuStacks m_humanStacks m_humanHand))))        
            ; If the Tile selected is in the Human's hand, then return the Tile selected
            (cond   ((string= (isInList m_humanHand tileSelected) "true")
                    (return-from selectTileToPlace tileSelected)))
            ; If the Tile the Human selected is not found in Hand, then let the Human know and ask for another input through a recursive call.
            (printMult "Tile" tileSelected "was not found in Hand. Please make another selection.")
            (return-from selectTileToPlace (selectTileToPlace m_cpuStacks m_humanStacks m_humanHand))
        )
    )
)

; *********************************************************************
; Function Name: validTileInput
; Purpose: Validates whether the Tile inputted is in the valid format. Returns "true" if it is the right format and "false" if not.
; Parameters:   m_strTile, a string that represents an input for a Tile from selectTileToPlace().
; Algorithm:    1) Evaluate m_strTile's size.
;                       a) If m_strTile's size is greater than 3, then it is invalid, return false.
;                       b) If m_strTile's size is less than 3, then it is invalid, return false.
;               2) Evaluate the first character in m_strTile.
;                       a) If the first character in m_strTile is not alphabetical, then it is invalid, return false.
;                       b) If the first character in m_strTile is not 'W or 'B, then it is invalid, return false.
;               3) Evaluate the second and third characters in m_strTile.
;                       a) If the second or third characters in m_strTile are not numeric, then it is invalid, return false.
;                       b) If the second or third characters in m_strTile are greater than 6, then it is invalid, return false.
;               4) If all of the above cases pass, then the Tile must be valid. Return true.
; Assistance Received: None.
; ********************************************************************
(defun validTileInput (m_strTile)
            ; If the Tile inputted is too large (more than 3 characters), then it is invalid.
    (cond   ((> (length m_strTile) 3)
            (printMult "Invalid input: input is too large. Make sure you enter a Tile in a 3 character format that starts with a capital \"W\" or \"B\" with two digits afterwards (each a number between 0-6). Also make sure there are no spaces."))
            ; If the Tile inputted is too small (less than 3 characters), then it is invalid.
            ((< (length m_strTile) 3)
            (printMult "Invalid input: input is too small. Make sure you enter a Tile in a 3 character format that starts with a capital \"W\" or \"B\" with two digits afterwards (each a number between 0-6). Also make sure there are no spaces."))
    )
    (cond   ((> (length m_strTile) 3)
            (return-from validTileInput "false"))
            ((< (length m_strTile) 3)
            (return-from validTileInput "false"))
    )
            ; If the first character in the string is not alphabetic, then it is invalid.
    (cond   ((not (alpha-char-p (char m_strTile 0)))
            (printMult "Invalid input: first character not alphabetic. Make sure you enter a Tile in a 3 character format that starts with a capital \"W\" or \"B\" with two digits afterwards (each a number between 0-6). Also make sure there are no spaces."))
            ; If the first character in the string is not a "W" or "B", then it is invalid.
            ((and (char/= (char m_strTile 0) #\W) (char/= (char m_strTile 0) #\B))
            (printMult "Invalid input: first character does not equal \"W\" or \"B\". Make sure you enter a Tile in a 3 character format that starts with a capital \"W\" or \"B\" with two digits afterwards (each a number between 0-6). Also make sure there are no spaces."))
    )
    (cond   ((not (alpha-char-p (char m_strTile 0)))
            (return-from validTileInput "false"))
            ((and (char/= (char m_strTile 0) #\W) (char/= (char m_strTile 0) #\B))
            (return-from validTileInput "false"))
    )
            ; If the second or third character is not numeric, then it is invalid.
    (cond   ((or (not (digit-char-p (char m_strTile 1))) (not (digit-char-p (char m_strTile 2))))
            (printMult "Invalid input: invalid format where digits should be inputted. Make sure you enter a Tile in a 3 character format that starts with a capital \"W\" or \"B\" with two digits afterwards (each a number between 0-6). Also make sure there are no spaces."))
            ; If the second or third character (first or second digit) is larger than 6, then it is invalid.
            ((or (> (digit-char-p (char m_strTile 1)) 6) (> (digit-char-p (char m_strTile 2)) 6))
            (printMult "Invalid input: one of the digits inputted are too large. Make sure you enter a Tile in a 3 character format that starts with a capital \"W\" or \"B\" with two digits afterwards (each a number between 0-6). Also make sure there are no spaces."))
    )
    (cond   ((or (not (digit-char-p (char m_strTile 1))) (not (digit-char-p (char m_strTile 2))))
            (return-from validTileInput "false"))
            ((or (> (digit-char-p (char m_strTile 1)) 6) (> (digit-char-p (char m_strTile 2)) 6))
            (return-from validTileInput "false"))
    )
    ; If the input passes all of the above tests, then it is valid. Return true.
    (return-from validTileInput "true")
)

; *********************************************************************
; Function Name: isInList
; Purpose: Checks if the Tile passed through in in the list passed through.
; Parameters:   m_list, any list of Tiles.
;               m_tileSelected, a Tile that is searched for in m_list.
; Algorithm:    1) Evaluate the first Tile in m_list.
;                       a) If the Tile in question is equal to m_tileSelected, then return "true".
;               2) Evaluate m_list's size.
;                       a) If the parameter m_list's size is greater than 1, then consider the next element in the list parameter (by popping the first element in m_list and recursively calling isInList()).
;                       b) If the parameter m_list's size is equal to 1, then even the last element is not equal to m_tileSelected. Return "false".
; Assistance Received: None.
; ********************************************************************
(defun isInList (m_list m_tileSelected)
        ; If the Tile in question is the same as parameter m_tileSelected, then it must be in the list passed in, so return true.
        (cond   ((equal (first m_list) m_tileSelected)
                (return-from isInList "true")))
                ; If the parameter m_list's size is greater than 1, then consider the next element in the list parameter.
        (cond   ((> (length m_list) 1)
                (return-from isInList (isInList (rest m_list) m_tileSelected)))
                ; If the last Tile in m_list is being evaluated and was not equal to m_tileSelected, return false.
                ((= (length m_list) 1)
                (return-from isInList "false")))
)

; *********************************************************************
; Function Name: selectStackToPlace
; Purpose: Human selects what Stack to place their Tile on.
; Parameters:   m_cpuStacks, a list of Tiles that represents the CPU's original 6 Stacks.
;               m_humanStacks, a list of Tiles that represents the Human's original 6 Stacks.
;               m_tileSelected, the Tile that was selected in selectTileToPlace().
; Algorithm:    1) Ask the Human to select a Stack to place the Tile they selected onto.
;               2) Evaluate the input.
;                       a) Validate the Stack inputted using validTileInput(). If it returns false, then get another input for a Stack by recursively calling selectStackToPlace().
;               3) Convert the input into a Tile format.
;               4) Evaluate the Stack selected.
;                       a) If the Stack selected is found in the CPU's original 6 Stacks and is in m_tileSelected's list of valid Stacks or is in the Human's original 6 Stacks and is in m_tileSelected's list of valid Stacks, then return the Stack selection.
;                       b) If the Stack selected could not be found in the CPU's and Human's Stacks, then print that it is not found on any Stack and get another Stack input by recursively calling selectStackToPlace().
;                       c) If the Stack selected is not in m_tileSelected's valid Stack placements, then print that m_tileSelected cannot be placed on the Stack selected and ask for another Stack input by recursively calling selectStackToPlace().
; Assistance Received: None.
; ********************************************************************
(defun selectStackToPlace (m_cpuStacks m_humanStacks m_tileSelected)
    (printMult "_______________________________________________________________________")
    (printMult "Select a Stack to place" m_tileSelected "on: (enter a 'B' or 'W' followed by one number between 0-6):")
    (terpri)
    ; Read in Stack selection as a string first.
    (let ((strStackSelection (read-line)))
        ; If the Stack inputted is invalid in any way, then take another input for another Stack.
        (cond   ((string= (validStackInput strStackSelection) "false")
                (return-from selectStackToPlace (selectStackToPlace m_cpuStacks m_humanStacks m_tileSelected)))
        )
        ; Once the Stack is confirmed to be in the right format, convert it into the proper list format for comparison and store the CPU's and Human's original stacks into variable allStacks for placement onto the proper stack and return from this function the stack that was selected.
        (let*    ((stackName (list (read-from-string (subseq strStackSelection 0 1)) (digit-char-p (char strStackSelection 1))))
                (stackSelection (extractStackFromName stackName m_cpuStacks m_humanStacks))
                (validCpuStacks (validStackPlacements m_tileSelected m_cpuStacks '()))
                (validHumanStacks (validStackPlacements m_tileSelected m_humanStacks '()))
                (validStacks (append validCpuStacks validHumanStacks)))
                ; If the Stack selected is a valid Stack for the Tile selected, then return the Stack selected.
                (cond   ((string= (isInList validStacks stackSelection) "true")
                        (return-from selectStackToPlace stackSelection)))
                ; If the Stack selected was not a valid Stack, then let the Human know that it is invalid and ask for another selection.
                (cond   ((string= (isInList validStacks stackSelection) "false")
                        (printMult "Stack" stackname "with" stackSelection "is not a valid Stack to place" m_tileSelected "on. Please make another selection.")))
                (cond   ((string= (isInList validStacks stackSelection) "false")
                        (return-from selectStackToPlace (selectStackToPlace m_cpuStacks m_humanStacks m_tileSelected))))
        )
    )
)

; *********************************************************************
; Function Name: validStackInput
; Purpose: Validates the Stack inputted by the Human in selectStackToPlace().
; Parameters:   m_strStack, a string that represents an input for a Stack.
; Algorithm:    1) Evaluate m_strStack's size.
;                       a) If m_strStack's size is greater than 2, then it is invalid, return false.
;                       b) If m_strStack's size is less than 2, then it is invalid, return false.
;               2) Evaluate the first character in m_strStack.
;                       a) If the first character in m_strStack is not alphabetical, then it is invalid, return false.
;                       b) If the first character in m_strStack is not 'W or 'B, then it is invalid, return false.
;               3) Evaluate the second character in m_strStack.
;                       a) If the second character in m_strStack are not numeric, then it is invalid, return false.
;                       b) If the second character in m_strStack are greater than 6, then it is invalid, return false.
;                       c) If the second character in m_strStack is less than 1, then it is invalid, return false.
;               4) If all of the above cases pass, then the Tile must be valid. Return true.
; Assistance Received: None.
; ********************************************************************
(defun validStackInput (m_strStack)
            ; If the Stack inputted is too large (more than 3 characters), then it is invalid.
    (cond   ((> (length m_strStack) 2)
            (printMult "Invalid input: input is too large. Make sure you enter a Tile in a 2 character format that starts with a capital \"W\" or \"B\" with one digit afterwards (each a number between 0-6). Also make sure there are no spaces."))
            ; If the Stack inputted is too small (less than 3 characters), then it is invalid.
            ((< (length m_strStack) 2)
            (printMult "Invalid input: input is too small. Make sure you enter a Tile in a 2 character format that starts with a capital \"W\" or \"B\" with one digit afterwards (each a number between 0-6). Also make sure there are no spaces."))
    )
    (cond   ((> (length m_strStack) 2)
            (return-from validStackInput "false"))
            ((< (length m_strStack) 2)
            (return-from validStackInput "false"))
    )
            ; If the first character in the string is not alphabetic, then it is invalid.
    (cond   ((not (alpha-char-p (char m_strStack 0)))
            (printMult "Invalid input: first character not alphabetic. Make sure you enter a Tile in a 3 character format that starts with a capital \"W\" or \"B\" with two digits afterwards (each a number between 0-6). Also make sure there are no spaces."))
            ; If the first character in the string is not a "W" or "B", then it is invalid.
            ((and (char/= (char m_strStack 0) #\W) (char/= (char m_strStack 0) #\B))
            (printMult "Invalid input: first character does not equal \"W\" or \"B\". Make sure you enter a Tile in a 3 character format that starts with a capital \"W\" or \"B\" with two digits afterwards (each a number between 0-6). Also make sure there are no spaces."))
    )
    (cond   ((not (alpha-char-p (char m_strStack 0)))
            (return-from validStackInput "false"))
            ((and (char/= (char m_strStack 0) #\W) (char/= (char m_strStack 0) #\B))
            (return-from validStackInput "false"))
    )
            ; If the second character is not numeric, then it is invalid.
    (cond   ((not (digit-char-p (char m_strStack 1)))
            (printMult "Invalid input: invalid format where digits should be inputted. Make sure you enter a Tile in a 3 character format that starts with a capital \"W\" or \"B\" with two digits afterwards (each a number between 0-6). Also make sure there are no spaces."))
            ; If the second character (the digit) is larger than 6, then it is invalid.
            ((> (digit-char-p (char m_strStack 1)) 6)
            (printMult "Invalid input: the digit inputted is too large. Make sure you enter a Tile in a 3 character format that starts with a capital \"W\" or \"B\" with one digit afterwards (each a number between 0-6). Also make sure there are no spaces."))
            ; If the second character (the digit) is less than 1 (0), then it is invalid.
            ((< (digit-char-p (char m_strStack 1)) 1)
            (printMult "Invalid input: the digit inputted is too small. Make sure you enter a Tile in a 3 character format that starts with a capital \"W\" or \"B\" with one digit afterwards (each a number between 0-6). Also make sure there are no spaces."))
    )
    (cond   ((not (digit-char-p (char m_strStack 1)))
            (return-from validStackInput "false"))
            ((> (digit-char-p (char m_strStack 1)) 6)
            (return-from validStackInput "false"))
            ((< (digit-char-p (char m_strStack 1)) 1)
            (return-from validStackInput "false"))
    )
    ; If the input passes all of the above tests, then it is valid. Return true.
    (return-from validStackInput "true")
)

; *********************************************************************
; Function Name: extractStackFromName
; Purpose: Returns the actual Stack that the Stack notation refers to (For example, if B1 is passed in, then the actual Stack it refers to is returned). Used to interpret Human's input when they select a Stack to place their Tile on.
; Parameters:   m_stackName, a list that represents the Human's Stack input, which should be a symbol, either 'W or 'B, and a digit 1-6.
;               m_cpuStacks, a list of Tiles that represents the CPU's original 6 Stacks.
;               m_humanStacks, a list of Tiles that represents the CPU's original 6 Stacks.
; Algorithm:    1) Take the Stack number from the Human's input by taking the second character.
;               2) Subtract that number by 1 to get the true index in the list.
;               3) Evaluate the first character in the Human's input.
;                       a) If the first character is a 'W, then it is a CPU Stack. Therefore, return element in the CPU Stacks passed in at the index found in step 2).
;                       b) If the first character is a 'B, then it is a Human Stack. Therefore, return element in the Human Stacks passed in at the index found in step 2).
; Assistance Received: None.
; ********************************************************************
(defun extractStackFromName (m_stackName m_cpuStacks m_humanStacks)
        (let*   ((stackNum (nth 1 m_stackName))
                (stackIndex (- stackNum 1)))
                (cond   ((eq (first m_stackName) 'W)
                        (return-from extractStackFromName (nth stackIndex m_cpuStacks)))
                        ; If the Stack selected is black, then find the respective Stack in the Human's Stacks.
                        ((eq (first m_stackName) 'B)
                        (return-from extractStackFromName (nth stackIndex m_humanStacks))))
        )
)

; *********************************************************************
; Function Name: validStackPlacements
; Purpose: Returns list of all valid Stack placements of the Tile passed in. Should be used with both CPU's and Human's original stacks. Parameter m_validStacks should be an empty list passed in.
; Parameters:   m_tileSelected, a list that represents a Tile that is to be evaluated.
;               m_bothPlayerStacks, a concatenated list of both the CPU's and Human's Stacks.
;               m_validStacks, a list of accumulated Stacks from m_bothPlayerStacks that m_tileSelected can be placed on.
; Algorithm:    1) If a nil Tile is passed in, it also has no valid Stack placements. Return nil.
;               2) Evaluate the first Stack in m_bothPlayerStacks.
;                       a) If m_tileSelected is a non double and has more or equal pips to the current Stack in question, then the current Stack is valid.
;                       b) If m_tileSelected is a double and the current Stack in question is a non double, then the current Stack in question is valid.
;                       c) If m_tileSelected is a double and the current Stack in question is a double and m_tileSelected has more pips than the current Stack, then the current Stack in question is valid.
;               3) If any of the above condidtions were met, append the current Stack to m_validStacks
;               4) As long as the current Stack in question is not the last Stack in m_bothPlayerStacks, consider the next Stack by recursively calling validStackPlacements() passing in the rest of m_bothPlayerStacks (repeat step 2)).
;               4) If the current Stack in question is the last stack in m_bothPlayerStacks, return m_validStacks.
; Assistance Received: None.
; ********************************************************************
(defun validStackPlacements (m_tileSelected m_bothPlayerStacks m_validStacks)
    ; If a nil Tile is passed in, it also has no valid Stack placements. Return nil.
    (cond   ((eq m_tileSelected nil)
            (return-from validStackPlacements nil)))
            ; If the Tile passed in is non-double and is greater than or equal to the top stack tile in question, it can be placed.
    (cond   ((and (string= (isDouble m_tileSelected) "false") (>= (getTotalPips m_tileSelected) (getTotalPips (first m_bothPlayerStacks))) (/= (length m_bothPlayerStacks) 1))
            (return-from validStackPlacements (validStackPlacements m_tileSelected (rest m_bothPlayerStacks) (append m_validStacks (list (first m_bothPlayerStacks))))))
            ; If it is also an ending condiiton, then just return m_validStacks with the Stack in question.
            ((and (string= (isDouble m_tileSelected) "false") (>= (getTotalPips m_tileSelected) (getTotalPips (first m_bothPlayerStacks))) (= (length m_bothPlayerStacks) 1))
            (return-from validStackPlacements (append m_validStacks (list (first m_bothPlayerStacks)))))
    )
    ; If the Hand Tile is a double-Tile...
            ; ...and the Stack in question is a non-double Tile, it can definitely be placed. If it is not an ending condition, then recursively call the function without the first element of m_bothPlayerStacks and the new m_validStacks passed through.
    (cond   ((and (string= (isDouble m_tileSelected) "true") (string= (isDouble (first m_bothPlayerStacks)) "false") (/= (length m_bothPlayerStacks) 1))
            (return-from validStackPlacements (validStackPlacements m_tileSelected (rest m_bothPlayerStacks) (append m_validStacks (list (first m_bothPlayerStacks))))))
            ; If it is also an ending condition, then just return m_validStacks with the Stack in question.
            ((and (string= (isDouble m_tileSelected) "true") (string= (isDouble (first m_bothPlayerStacks)) "false") (= (length m_bothPlayerStacks) 1))
            (return-from validStackPlacements (append m_validStacks (list (first m_bothPlayerStacks)))))
            ; ... and the Stack in question is a double-Tile but has less pips than the Tile selected, then it can be placed.
            ((and (string= (isDouble m_tileSelected) "true") (string= (isDouble (first m_bothPlayerStacks)) "true") (> (getTotalPips m_tileSelected) (getTotalPips (first m_bothPlayerStacks))) (/= (length m_bothPlayerStacks) 1))
            (return-from validStackPlacements (validStackPlacements m_tileSelected (rest m_bothPlayerStacks) (append m_validStacks (list (first m_bothPlayerStacks))))))
            ; If it is also an ending condition, then just return m_validStacks with the Stack in question.
            ((and (string= (isDouble m_tileSelected) "true") (string= (isDouble (first m_bothPlayerStacks)) "true") (> (getTotalPips m_tileSelected) (getTotalPips (first m_bothPlayerStacks))) (= (length m_bothPlayerStacks) 1))
            (return-from validStackPlacements (append m_validStacks (list (first m_bothPlayerStacks)))))
    )
            ; If the function falls out of any of these conditions above, it means that the current Stack in question is not a valid placement. If this isn't the last Stack, then recursively call the function without the first Stack in m_bothPlayerStacks but without modifying m_validStacks.
    (cond   ((/= (length m_bothPlayerStacks) 1)
            (return-from validStackPlacements (validStackPlacements m_tileSelected (rest m_bothPlayerStacks) m_validStacks)))
            ; If it is an ending condition, then jsut returns m_validStacks as is.
            ((= (length m_bothPlayerStacks) 1)
            (return-from validStackPlacements m_validStacks))
    )
)

; *********************************************
; Source code for score taking.
; *********************************************
; *********************************************************************
; Function Name: takeScores
; Purpose: Takes both CPU's and Human's Hands and a concatenated list of both CPU's and Human's original Stacks to calculate each of their scores
; Parameters:   m_cpuScore, integer that represents the CPU's score.
;               m_humanScore, integer that represents the Human's score.
;               m_cpuHand, list of Tiles that represent the CPU's Hand.
;               m_humanHand, list of Tiles that represent the Human's Hand.
;               m_cpuAndHumanStacks, a concatenated list of the CPU and Human's Stacks.
; Algorithm:    1) Consider the first Stack in m_cpuAndHumanStacks.
;                       a) If the Stack in question has color 'W, then add its pips to m_cpuScore.
;                       B) If the Stack in question has color 'B, then add its pips to m_humanScore.
;                       c) If the Stack in question is not the last in m_cpuAndHumanStacks, then recursively call takeScores with the rest of m_cpuAndHumanStacks.
;                       d) if the Stack in question is the last in m_cpuAndHumanStacks, then return m_cpuAndHumanStacks.
; Assistance Received: None.
; ********************************************************************
(defun takeScores (m_cpuScore m_humanScore m_cpuHand m_humanHand m_cpuAndHumanStacks)
            ; If the Stack in question is topped by the CPU, then add its pips to the CPU's score.
    (cond   ((and (string= (first (first m_cpuAndHumanStacks)) #\W) (> (length m_cpuAndHumanStacks) 1))
            (return-from takeScores (takeScores (+ m_cpuScore (getTotalPips (first m_cpuAndHumanStacks))) m_humanScore m_cpuHand m_humanHand (rest m_cpuAndHumanStacks))))
            ; If it is an ending condition, then return the scores as a combined list and subtract the leftover Tiles' pips from the scores.
            ((and (string= (first (first m_cpuAndHumanStacks)) #\W) (= (length m_cpuAndHumanStacks) 1))
            (return-from takeScores (list (+ (- m_cpuScore (totalPipsInHand m_cpuHand 0)) (getTotalPips (first m_cpuAndHumanStacks))) (- m_humanScore (totalPipsINhand m_humanHand 0)))))
            ; If the Stack in question is topped by the Human, then add its pips to the Human's score.
            ((and (string= (first (first m_cpuAndHumanStacks)) #\B) (> (length m_cpuAndHumanStacks) 1))
            (return-from takeScores (takeScores m_cpuScore (+ m_humanScore (getTotalPips (first m_cpuAndHumanStacks))) m_cpuHand m_humanHand (rest m_cpuAndHumanStacks))))
            ; If it is an ending condition, then return the scores as a combined list and subtract the leftover Tiles' pips from the scores.
            ((and (string= (first (first m_cpuAndHumanStacks)) #\B) (= (length m_cpuAndHumanStacks) 1))
            (return-from takeScores (list (- m_cpuScore (totalPipsInHand m_cpuHand 0)) (+ (- m_humanScore (totalPipsINhand m_humanHand 0)) (getTotalPips (first m_cpuAndHumanStacks)))))))
)

; *********************************************************************
; Function Name: totalPipsInHand
; Purpose: Returns the total pips of the Tiles in Hand passed through. Used when subtracting leftover Tiles in Hand from score.
; Parameters:   m_playerHand, a list of Tiles that represents one of the Player's Hands.
;               m_accumPips, an integer that represents the accumulated pips of all of the Tiles in m_playerHand.
; Algorithm:    1) Consider the size of m_playerHand and the first Tile in m_playerHand.
;                       a) if there are no Tiles in the Hand passed in, return 0.
;                       b) If there is 1 Tile left in m_playerHand, return m_accumPips + the total pips in the current Tile in question.
;                       c) If there is more than 1 Tile in m_playerHand, recursively call totalPipsInHand() and pass in the rest of the Player's Hand and m_accumPips + the total pips in the current Tile in question.
; Assistance Received: None.
; ********************************************************************
(defun totalPipsInHand (m_playerHand m_accumPips)
            ; If there are no Tiles in the Hand passed in, then there are no pips to be evaluated. Return 0.
    (cond   ((= (length m_playerHand) 0)
            (return-from totalPipsInHand 0))
            ; If the current Tile in question is the last one in Hand, then return the accumulated pips plus the current Tile in question's.
            ((= (length m_playerHand) 1)
            (return-from totalPipsInHand (+ m_accumPips (getTotalPips (first m_playerHand)))))
            ; If the Tile in question is not the last one in Hand, then recursively call totalPipsInHand() to evaluate the next Tile.
            ((> (length m_playerHand) 1)
            (return-from totalPipsInHand (totalPipsInHand (rest m_playerHand) (+ m_accumPips (getTotalPips (first m_playerHand))))))
    )
)

; *********************************************************************
; Function Name: declareWinnerOfTournament
; Purpose: Declares winner of tournament based on the CPU and Human's Rounds won passed in.
; Parameters:   m_cpuWins, an integer that represents the CPU's total Rounds won.
;               m_humanWins, an integer that represents the Human's total Rounds won.
; Algorithm:    1) Print each Players' Rounds won.
;               2) Compare each Players' Rounds won.
;                       a) If the CPU has more wins than the Human, then print that the Computer wins the Tournament.
;                       b) If the Human has more wins than the CPU, then print that the Human wins the Tournament.
;                       c) If the CPU and Human have equal wins, then print that there is a draw and niether Player wins the Torunament.
;               3) Thank the Human for playing.
; Assistance Received: None.
; ********************************************************************
(defun declareWinnerOfTournament(m_cpuWins m_humanWins)
    ; Print each Player's Rounds won.
    (printMult "Rounds Won:")
    (printMult "Computer:" m_cpuWins)
    (printMult "Human:" m_humanWins)
    ; Declare which Player was the winner. If the CPU has more wins, then the CPU wins. If the Human has more wins, then the Human wins. If the CPU and Human have the same amount of wins, then there is a draw.
    (cond ((> m_cpuWins m_humanWins) 
        (printMult "The Computer wins the Tournament!"))
        ((< m_cpuWins m_humanWins)
        (printMult "The Human wins the Tournament!"))
        ((= m_cpuWins m_humanWins)
        (printMult "There is a draw! Neither player wins the Tournament!"))
    )
    (printMult "Thank you for playing!")
)

; *********************************************
; Source code for the main entry point of the program.
; *********************************************
(printMult "_______________________________________________________________________")
(printMult "Welcome to Build-Up!")

; Ask the Human whether or not they want to restore a previous game or start a new game. If the Human wants to restore a game and the loading is successful, restorePreviousGame() will start one.
(let    ((restoreGame (restorePreviousGame)))
     ; If the Human does not want to restore a game or loading from a save file fails somehow, start a fresh Round instead.
     (cond  ((string= restoreGame "false")
            (startRound 1 '() '() '() '() 0 '() '() 0 0 0 0 0 "false" "false")))
)
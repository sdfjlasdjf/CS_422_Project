README


Overview

This project builds the chess game using the K framework. The language includes constructs for representing a chessboard, pieces, moves, and various chess rules, such as piece movement, capturing, and turn-based play. It also provides functionality for checking conditions like move validity, path clearance, and special moves like en passant and promotion.

Although the code is not a complete or perfectly accurate chess engine, it demonstrates how to model a stateful, rule-based system (chess moves) in K, and how to reason about it using rewrite rules and configurations.



Key Concepts

K Framework:

The entire project is written in K, a rewrite-based executable semantics framework. K lets you define languages by specifying their syntax and semantics, then automatically generates parsers, interpreters, and analysis tools.


Syntax & Semantics:

The project uses custom syntax for representing:

Chess pieces and their colors.

Chessboard cells.

Moves, input/output commands, and other game-related operations.

It then provides rewrite rules that define the semantics of these constructs. For example, a rule describes how a move command updates the board, how en passant is handled, or how turn switching happens after a move.


Configuration:

The configuration, defined by the <configuration> cell, specifies the initial program state:

<k> cell holds the computation (or the "program counter").

<board> cell holds the mapping of board cells to pieces.

<turn> cell holds the current player’s turn (White or Black).

<EnP> cell holds information about en passant possibilities.

<input> and <output> cells provide a way to handle input commands and display the board.

<kingLoc> tracks the positions of the kings.

<checkPiece> tracks pieces putting a king in check.


Chess Rules Implemented:

Initialization: The Init command sets up the board in a standard chess configuration.

Piece Movements: The language defines validMove and pieceMoveValid/pieceCaptureValid functions for each type of piece (Pawn, Knight, Bishop, Rook, Queen, King).


Special Rules:

En Passant: Detected and handled by enabling and using the <EnP> cell.

Promotion: When a pawn reaches the last rank, askPromote and Promote commands handle changing its piece type.

Check: The language includes rules to determine if a king is in check by checking paths and positions of attacking pieces, including pawns, knights, rooks, bishops, and queens.

CheckMate: This part is currently still being developed. It covers: 1. check if the king can move out of the check. 2. if the piece checking the king can be captured. 3. if the path from the checking piece to the king can be blocked.

Path Clearance: isPathClear determines if there are no pieces in the path of a sliding piece (Bishop, Rook, Queen).

Control Structures: The language includes a simple if-statement that uses boolean values from evaluated conditions. It uses returnTrue and returnFalse as simple built-in functions for 
certain conditions.

Expressions: Standard arithmetic and boolean operations are defined (+, -, *, /, %, <, >, ==, etc.), as well as string printing. The SHOW command prints the entire board, and read reads a command or piece type from the input.

Board Representation: The board is represented as a mapping (<board> .Map </board>) from integers to Piece. The cells are integers from 1 to 64 corresponding to the squares of the chessboard. Various rules translate from (row, column) coordinates (I1, I2) to cell indexes (I1-1)*8+I2.



Directory Structure and Files


TEST-SYNTAX and TEST modules: These contain the syntax and semantics of the chess-like language.

DOMAINS-SYNTAX and DOMAINS: Imported modules that provide built-in sorts like Int, Bool, and Map.

All the rule blocks define the semantic behavior of different constructs.



How to Run


Prerequisites:

Install the K framework.

For installation instructions, see https://github.com/kframework/k.

Executing the Semantics:

Once you have K installed, you can parse and run a specific program using krun. For example, to run Init and display the initial board configuration, create a file (e.g., program.in) containing Init and run:

krun program.in

This will execute the rules defined in the TEST module and produce the final configuration.

Providing Input:

The <input> cell reads commands from a list of items. To simulate moves, you can type in:

MOVE {INT} {INT} {INT} {INT}

where you replace each {INT} with a integer from 1 to 8, the first parameter is the row number of the piece you want to move, the second is its column number. The third parameter is the row number of the destination, and the fourth parameter is its column number. If the move is valid, the piece will be moved and the board will be printed again. Then you might continue entering the next move(in a different color of course).

When encountering a promotion, when prompted, just type in Q or B or R or N to promote your pawn.



Troubleshooting & Further Development


Extending Rules:

To implement more chess rules (like castling, stalemate detection, or fifty-move rule), add corresponding rules in this style.

Debugging:

Use kompile to compile the definition:

kompile TEST.k

Limitations: This is not a full chess engine. It doesn't handle all rules (like draws, correct checkmate detection in all scenarios, etc.). It's mainly for demonstration purposes.



Conclusion

This project showcases a K-based definition of chess rules. It uses a rich configuration structure, pattern matching, and rewrite rules to simulate a game step-by-step. While not complete, it provides a solid foundation for further exploration and a stepping stone for those interested in using K to model and analyze complex systems.

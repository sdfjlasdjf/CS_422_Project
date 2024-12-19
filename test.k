module TEST-SYNTAX
    imports DOMAINS-SYNTAX

endmodule

module TEST
    imports TEST1-SYNTAX
    imports DOMAINS
    syntax PieceType ::= "P" | "N" | "B" | "R" | "Q" | "K"
    syntax Color ::= "White" 
                    | "Black" |
                    | "getColor" "(" Exp ")"                                            [strict]

    syntax Piece ::= Color PieceType | "Empty"
    syntax Function ::= Bool | Command
				| "returnTrue"
				| "returnFalse"
                | "getPieceType" "(" Piece ")"                                  [strict]
                | "getColor" "(" Piece ")"                                      [strict]
                | "validMove" Int Int Int Int                                   [strict]
                | "pieceMoveValid" Piece Int Int Int Int                        [strict]
                | "pieceCaptureValid" Piece Int Int Int Int                     [strict]
                | "isPathClear" Exp Exp Exp Exp                                 [strict]
                | "handleResult" Exp Exp Exp Exp Exp                            [strict]
                | "updateCell" Exp Exp                                          [strict]
                | "afterCheck" Exp Int Int Int Int                               [strict]
                | "changeColor" Color                                           [strict]
                | "SHOW"                      
                | "read"                                                        [strict]                          
                | "SHOWAUX" Int                                                 [strict]
				| "PRINT" Exp		                                            [strict]
                | "Init" 
                | "SHOW" 
                | "askPromote" Exp Exp                                          [strict]
                | "Promote" PieceType Exp                                       [strict]
                | "enableEnP" Int 
                | "enPassant" Exp                                               [strict]
                | "isCheck"
                | "upCheck" Exp                                                 [strict]
                | "downCheck" Exp                                                [strict]
                | "leftCheck" Exp                                                [strict]
                | "rightCheck" Exp                                                [strict]
                | "diag11Check" Exp                                              [strict]
                | "diag12Check" Exp                                              [strict]
                | "diag21Check" Exp                                              [strict]
                | "diag22Check" Exp                                              [strict]
                | "pCheck" Exp                                                  [strict]
                | "pCheckPos" Exp                                               [strict]
                | "knightCheck" Exp                                             [strict]
                | "knightCheckPos" Exp                                          [strict]
    syntax Command ::= | "MOVE" Int Int Int Int 							    [strict]

    syntax Exp ::= Int | Bool | String | Id | Piece
				| "a[" Exp "]"		 	 										[strict]
				| "Compare" Exp Exp												[strict]
				| "(" Exp ")"                                                   [bracket]
                | "abs" "(" Exp ")"                                             [strict]
               > "-" Exp                 										[strict]
               > left:
			     Exp "*" Exp             										[strict, left]
               | Exp "/" Exp             										[strict, left]
               | Exp "%" Exp             										[strict, left]
               > left:
                 Exp "+" Exp             										[strict, left]
               | Exp "-" Exp            										[strict, left]
			   > Exp "=" Exp             										[strict(2), right]
			   > non-assoc:	
                 Exp "<" Exp             										[strict, non-assoc]
               | Exp "<=" Exp            										[strict, non-assoc]
               | Exp ">" Exp            										[strict, non-assoc]
               | Exp ">=" Exp            										[strict, non-assoc]
               | Exp "==" Exp          	 										[strict, non-assoc]
               | Exp "!=" Exp            										[strict, non-assoc]
               > "!" Exp                 										[strict]
               > left:
                 Exp "&&" Exp            										[strict(1), left]
               | Exp "||" Exp            										[strict(1), left]							
			
    syntax Block ::= "{""}"
                | "{" Stmts "}"

    syntax Stmt ::= Block
				| Function
                | Exp ";"                               [strict]
                | "if" "(" Exp ")" Block "else" Block   [avoid, strict(1)]
                | "if" "(" Exp ")" Block
				| "if" "(" Function ")" Block "else" Block   [avoid, strict(1)]
                | "if" "(" Function ")" Block
				
    syntax Stmts ::= Stmt
                 | Stmts Stmts                          			[right]

    syntax Val ::= Int | Bool | String
				| array(Int,Int)
  
    syntax Exp ::= Val
  
    rule I1 < I2 => I1 <Int I2
    rule I1 <= I2 => I1 <=Int I2
    rule I1 > I2 => I1 >Int I2
    rule I1 >= I2 => I1 >=Int I2
    
    rule V1:Exp == V2:Exp => V1 ==K V2
    rule V1:Exp != V2:Exp => V1 =/=K V2
    
    rule ! T => notBool(T)
    rule true  && E => E
    rule false && _ => false
    rule true  || _ => true
    rule false || E => E
                
    rule I1 + I2 => I1 +Int I2
    rule I1 - I2 => I1 -Int I2
    rule I1 * I2 => I1 *Int I2
    rule I1 / I2 => I1 /Int I2 requires I2 =/=K 0
    rule I1 % I2 => I1 %Int I2 requires I2 =/=K 0
    rule - I => 0 -Int I
    
    rule if (true) {S} else _ => S
    rule if (false) _ else {S} => S
    rule if (E:Exp) S => if (E) S else {{}}                                 [macro]
    rule if (E:Function) S => if (E) S else {{}}                            [macro]
    rule {} => .		
    syntax KResult ::= Val

    configuration <T>
                <k> Init SHOW read</k>
                <board> .Map </baord>
                <turn> White </turn>
                <EnP> 0 </EnP>
                <input color="magenta" stream="stdin"> .List </input>
                <output color="brown" stream="stdout"> .List </output>
                <kingLoc> .Map </kingLoc>
                <checkPiece> .Int </checkPiece>
                </T>

    rule S1:Stmts S2:Stmts => S1 ~> S2  [structural]
    rule <k> a[I:Exp] => P ... </k>
        <board> ... I |-> P:Piece ... </board>

    rule <k> (returnTrue => true ) ... </k>
    rule <k> (returnFalse => false ) ... </k>

    rule <k> Init => . ...</k>
        <board> .Map =>
        1 |-> Black R
        2 |-> Black N
        3 |-> Black B
        4 |-> Black Q
        5 |-> Black K
        6 |-> Black B
        7 |-> Black N
        8 |-> Black R
        9...16 |-> Black P
        17...48 |-> Empty
        49...56 |-> White P
        57 |-> White R
        58 |-> White N
        59 |-> White B
        60 |-> White Q
        61 |-> White K
        62 |-> White B
        63 |-> White N
        64 |-> White R
        </board>
        <kingLoc> .Map => Black |-> 5 White |-> 61 </kingLoc>

    rule <k> read => CMD ...</k>
        <input> ListItem(CMD:Command) => .List ...</input>
    rule <k> read => PT:PieceType ...</k>
        <input> ListItem(PT:PieceType) => .List </input>    

    //Print the board
    rule <k> SHOW => SHOWAUX 0 ... </k>

    // Once we've printed all 64 squares, we stop.
    rule <k> SHOWAUX I:Int => . ... </k>
    requires I >Int 64

    // Print each piece and a newline every 8 pieces.
    rule <k> SHOWAUX I:Int => PRINT "|" PRINT a[I] ( if (I %Int 8 ==Int 0) { PRINT "|" PRINT "\n" } else { . } ) SHOWAUX I+1 ... </k>

    // Absolute 
    rule abs(I) => I  requires I >=Int 0
    rule abs(I) => 0 -Int I requires I <Int 0

    //Move Piece
    rule <k> MOVE I1:Int I2:Int I3:Int I4:Int => handleResult (I1-1)*8+I2 I1 I2 I3 I4  SHOW  changeColor C  read...</k>
        <turn> C:Color </turn>
        <Enp> _ => 0 </Enp>
        requires validMove I1 I2 I3 I4
    rule <k> MOVE I1:Int I2:Int I3:Int I4:Int => error </k>      [owise]

    //Switch turn
    rule <k> changeColor Black => . </k>
         <turn> _ => White </turn>
    rule <k> changeColor White => . </k>
         <turn> _ => Black </turn>
    
    //Check if the move is valid
    rule <k> validMove I1:Int I2:Int I3:Int I4:Int => 
        if (I1 <= 8 && I1>=1 && I2 <= 8 && I2>=1 && I3 <= 8 && I3 >= 1 && I4 <= 8 && I4 >= 1 && a[(I1-1)*8+I2] != "Empty" && (I1 != I3 || I2 != I4) && getColor (a[(I1-1)*8+I2]) ==K C)
            {if(a[(I3-1)*8+I4] =/=K "Empty"){if(getColor (a[(I3-1)*8+I4]) =/=K C){pieceCaptureValid a[I3*8-1+I4] I1 I2 I3 I4} else{returnFalse}}else{pieceMoveValid a[I3*8-1+I4] I1 I2 I3 I4}}
            else{returnFalse}</k>
        <turn> C:Color </turn>

    //Check the color
    rule <k> getColor (C:Color PieceType) => C </k>

    //Check the piece type
    rule <k> getPieceType (Color PT:PieceType) => PT </k>

    //King
    rule <k> pieceMoveValid _ K I1:Int I2:Int I3:Int I4:Int =>
        if ((abs (I3 - I1) <= 1 && abs (I4 - I2)) <= 1) {returnTrue} else {returnFalse}</k>
    rule <k> pieceCaptureValid _ K I1:Int I2:Int I3:Int I4:Int => pieceMoveValid _ K I1 I2 I3 I4</k>

    //Bishop
    rule <k> pieceMoveValid _ B I1:Int I2:Int I3:Int I4:Int =>
        if (abs(I3 - I1) == abs(I4 - I2)) {isPathClear I1+((I3-I1)/abs(I1-I3)) I2+((I4-I2)/abs(I2-I4)) I3 I4} else {returnFalse}</k>
    rule <k> pieceCaptureValid _ B I1:Int I2:Int I3:Int I4:Int => pieceMoveValid _ B I1 I2 I3 I4</k>

    //Rook
    rule <k> pieceMoveValid _ R I1:Int I2:Int I3:Int I4:Int =>
        if (I3 == I1){isPathClear I1 I2+((I4-I2)/abs(I2-I4)) I3 I4} else {if(I4!=I2){returnFalse}else{isPathClear I1+((I3-I1)/abs(I1-I3)) I2 I3 I4}}</k>
    rule <k> pieceCaptureValid _ R I1:Int I2:Int I3:Int I4:Int => pieceMoveValid _ R I1 I2 I3 I4</k>

    //Queen
    rule <k> pieceMoveValid _ Q I1:Int I2:Int I3:Int I4:Int =>
        pieceMoveValid _ B I1 I2 I3 I4 || pieceMoveValid _ R I1 I2 I3 I4</k>
    rule <k> pieceCaptureValid _ Q I1:Int I2:Int I3:Int I4:Int => pieceMoveValid _ Q I1 I2 I3 I4</k>

    //White Pawn
    rule <k> pieceMoveValid Black P I1:Int I2:Int I3:Int I4:Int =>
        if((I3 == I1 - 1 && I4 == I2) || (I3 == I1-2 && I4 == I2 && I1 == 2) || (I3==I1+1 && abs(I4-I2) == 1 && I1==5 && Enp == I4)) { returnTrue } else { returnFalse }</k>
        <EnP> Enp </Enp>
    rule <k> pieceCaptureValid Black P I1:Int I2:Int I3:Int I4:Int => 
        if(I3==I1+1 && abs (I4-I2) == 1) {returnTrue} else{returnFalse}</k>

    //Black Pawn
    rule <k> pieceMoveValid White P I1:Int I2:Int I3:Int I4:Int =>
        if ((I3 == I1 + 1 && I4 == I2) || (I3 == I1 + 2 && I4 == I2 && I1 == 2) || (I3==I1+1 && abs(I4-I2) == 1 && I1==4 && Enp == I4)) {returnTrue} else {returnFalse} </k>
        <EnP> Enp </Enp>
    rule <k> pieceCaptureValid White P I1:Int I2:Int I3:Int I4:Int => 
        if(I3==I1-1 && abs (I4-I2) == 1) {returnTrue} else{returnFalse}</k>

    //Knight 
    rule <k> pieceMoveValid _ N I1:Int I2:Int I3:Int I4:Int =>
        if ((abs(I3 - I1) == 2 && abs(I4 - I2) == 1) || (abs(I3 - I1) == 1 && abs(I4 - I2) == 2)) {returnTrue} else {returnFalse} </k>
    rule <k> pieceCaptureValid _ N I1:Int I2:Int I3:Int I4:Int => pieceMoveValid _ N I1 I2 I3 I4

    //Check if path is clear
    rule <k> isPathClear I1:Int I2:Int I3:Int I4:Int => if(I1==I3 && I2==I4){returnTrue} else{if(a[(I1-1)*8+I2] ==K Empty){if(I2==I4){isPathClear I1+((I3-I1)/abs(I1-I3)) I2 I3 I4 }else{if(I1==I3){isPathClear I1 I2+((I4-I2)/abs(I2-I4)) I3 I4}else{isPathClear I1+((I3-I1)/abs(I1-I3)) I2+((I4-I2)/abs(I2-I4)) I3 I4}}}else{returnFalse}} </k>

    //Handle the result
    rule <k> handleResult L:Exp I1:Int I2:Int I3:Int I4:Int => if(PT ==K P && I2 != I4 && a[(I3-1)*8+I4] ==K Empty){enPassant (I1-1)*8+I4} if(PT)~> updateCell (I1-1)*8+I2 (I3-1)*8+I4 ~> afterCheck a[(I1-1)*8+I2] I1 I2 I3 I4 </k>
         <board> ...L |-> _ PT:PieceType ... </board>
    rule <k> updateCell L1:Exp L2:Exp => . </k>
         <board> ...L1 |-> (Pi:Piece => Empty) ... L2 |-> (_ => Pi)...</board>

    //We want to check Pawn for Promotion and initial move
    rule <k> afterCheck L:Exp I1:Int I2:Int I3:Int I4:Int => if(PT ==K P){if((C ==K Black && I3 == 8) || (C ==K White && I3==1)){askPromote I3 I4}else{if(abs (I3-I1) == 2){enableEnP I4}}} if(PT==K){updateKpos (I3-1)*8+I4}</k>
         <board> ...L |-> C:Color PT:PieceType ... </board>
    
    rule <k> updateKpos I:Exp => . </k>
        <kingLoc> C |-> I </kingLoc>
        <turn> C </turn>

    //Promote
    rule <k> askPromote I3:Int I4:Int => PRINT "Please enter the pieceType you want to promote to : Q, N, B, R" ~> Promote read a[(I3-1)*8+I4] </k>

    rule <k> Promote PT:PieceType L:Exp => . </k>
        <board> ... L |-> (_ => C PT) </board>
        <turn> C:Color </turn>

    //Enable En Passant
    rule <k> enableEnP I4:Int=> . </k>
        <EnP> _ => I4 </EnP>

    //Execute En Passant
    rule <k> enPassant L:Exp => . </k>
        <board> ... L |-> (_ => Empty) </board>

    rule<k> canBeCaptured C I=> rightCheck C I || leftCheck C I || downCheck C I || upCheck C I || diag11Check C I || diag12Check C I || diag21Check C I || diag22Check C I || knightCheck C I || pCheck C I ~> restoreBoard</k>
    //Check if the King is in check
    rule <k> isCheck=> canBeCaptured</k>
        <turn> C:Color </turn>
        <kingLoc> C |-> I:Int </kingLoc>

    rule <k> rightCheck C1 I => if(C =/=K C1 && (PT == Q || PT == R)){recordPiece I returnTrue}else{if(C ==K C1 && PT =/=K K){returnFalse}else{if(I%8 != 0){rightCheck I+1}else{returnFalse}}} </k>
        <Board> ... I |-> C:Color PT:PieceType ... </Board>

    rule <k> leftCheck C1 I => if(C =/=K C1 && (PT == Q || PT == R)){recordPiece I returnTrue}else{if(C ==K C1 && PT =/=K K){returnFalse}else{if(I%8 != 1){rightCheck I-1}else{returnFalse}}} </k>
        <Board> ... I |-> C:Color PT:PieceType ... </Board>

    rule <k> downCheck C1 I => if(C =/=K C1 && (PT == Q || PT == R)){recordPiece I returnTrue}else{if(C ==K C1 && PT =/=K K){returnFalse}else{if((I-1)/8 != 7){downCheck I+8}else{returnFalse}}} </k>
        <Board> ... I |-> C:Color PT:PieceType ... </Board>

    rule <k> upCheck C1 I => if(C =/=K C1 && (PT == Q || PT == R)){recordPiece I returnTrue}else{if(C ==K C1 && PT =/=K K){returnFalse}else{if((I-1)/8 != 0){upCheck I-8}else{returnFalse}}} </k>
        <Board> ... I |-> C:Color PT:PieceType ... </Board>

    rule <k> diag11Check C1 I => if(C =/=K C1 && (PT == Q || PT == B)){recordPiece I returnTrue}else{if(C ==K C1 && PT =/=K K){returnFalse}else{if((I-1)/8 != 7 && I%8 != 0){diag11Check I+9}else{returnFalse}}} </k>
        <Board> ... I |-> C:Color PT:PieceType ...  </Board>
    
    rule <k> diag12Check C1 I => if(C =/=K C1 && (PT == Q || PT == B)){recordPiece I returnTrue}else{if(C ==K C1 && PT =/=K K){returnFalse}else{if((I-1)/8 != 0 && I%8 != 1){diag12Check I-9}else{returnFalse}}} </k>
        <Board> ... I |-> C:Color PT:PieceType ...  </Board>

    rule <k> diag21Check C1 I => if(C =/=K C1 && (PT == Q || PT == B)){recordPiece I returnTrue}else{if(C ==K C1 && PT =/=K K){returnFalse}else{if((I-1)/8 != 7 && I%8 != 1){diag21Check I+7}else{returnFalse}}} </k>
        <Board> ... I |-> C:Color PT:PieceType ...  </Board>

    rule <k> diag22Check C1 I => if(C =/=K C1 && (PT == Q || PT == B)){recordPiece I returnTrue}else{if(C ==K C1 && PT =/=K K){returnFalse}else{if((I-1)/8 != 0 && I%8 != 8){diag22Check I-7}else{returnFalse}}} </k>
        <Board> ... I |-> C:Color PT:PieceType ...  </Board>

    rule <k> knightCheck I => 
       knightCheckPos(I+17) || knightCheckPos(I-17)
       || knightCheckPos(I+15) || knightCheckPos(I-15)
       || knightCheckPos(I+10) || knightCheckPos(I-10)
       || knightCheckPos(I+6)  || knightCheckPos(I-6)
       ...</k>

    rule <k> pCheck I => if(C ==K Black){pCheckPos(I+9)||pCheckPos(I+7)}else{pCheckPos(I-7)||pCheckPos(I-9)} </k>
        <turn> C:Color </turn>

    rule <k> pCheckPos I => if(I>64 || I<1){returnFalse} if(C =/=K C1 && PT == P){recordPiece I returnTrue}else{returnFalse} </k>
        <Board> ... I |-> C:Color PT:PieceType ... </Board>
        <turn> C1:Color </turn>

    rule <k> knightCheckPos I => if(I>64 || I<1){returnFalse} if(C =/=K C1 && PT == N){recordPiece I returnTrue}else{returnFalse} </k>
        <Board> ... I |-> C:Color PT:PieceType ... </Board>
        <turn> C1:Color </turn>
    
    rule <k> recordPiece I => . </k>
        <checkPiece> .Int => I </checkPiece>

    //Check if there is a Checkmate
    rule <k> isCheckMate => storeBoard ~> if(!isCheck){returnFalse}else{if(moveK||capturePiece||blockPiece){returnFalse}else{returnTrue}} </k>
    rule <k> storeBoard => . </k>
        <temp> .Map => BD </temp>
        <board> BD </board>
    rule <k> restoreBoard => . </k>
        <temp> BD </temp>
        <board> _ => BD </board>

    //First by checking if moving K can get out of this
    rule <k> moveK => moveKCheck I+1||moveKCheck I-1||moveKCheck I+8||moveKCheck I-8 || moveKCheck I+9 || moveKCheck I+7 || moveKCheck I-9 || moveKCheck I-7
        <kingLoc> I </kingLoc>
    rule <k> moveKCheck I => if(C1 ==K C || I>64 || I<1){returnFalse}else{moveKPos I}
        <board> I |-> C:Color PT:PieceType </board>
        <turn> C1 </turn>
    rule <k> moveKPos I => if(isCheck){returnFalse}else{returnTrue} </k>
        <board> ... I |-> (_ => C K)... I1 |-> (_ => Empty) ...
        <kingLoc> C |-> (I1:Int => I) </kingLoc>
        <turn> C </turn>

    //Second by checking if the piece checking the King can be captured
    rule <k> capturePiece => if(C ==K Black){canBeCaptured White I}else{canBeCaptured Black I}
        <checkPiece> I </checkPiece>
        <turn> C <turn>
    
    //Third by checking if we can block the path between the king and the checking piece
    rule <k> blockPiece => if(I==I1+1 || I==I1-1 || I==I1+8 || I==I1-8 || I==I1+9 || I==I1-9 || I==I1+7 || I==I1-7 || PT==N){returnFalse}else{blockPieceCheck}
        <board> I |-> _ PT:PieceType </board>
        <checkPiece> I </checkPiece>
        <kingLoc> C |-> I1:Int </kingLoc>
        <turn> C </turn>

    //*********TODO: Implement the rest of the blockPiece************************************
endmodule

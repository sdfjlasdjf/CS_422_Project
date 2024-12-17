module TEST-SYNTAX
    imports DOMAINS-SYNTAX

endmodule

module TEST
    imports TEST-SYNTAX
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
                | "handleResult" Exp Exp Exp Exp                                [strict]
                | "updateCell" Exp Exp                                          [strict]
                | "pawnCheck" Exp Int Int Int Int                               [strict]
                | "changeColor" Color                                           [strict]
                | "SHOW"                      
                | "read"                                                        [strict]                          
                | "SHOWAUX" Int                                                 [strict]
				| "PRINT" Exp		                                            [strict]
                | "Init" 
                | "SHOW" 
                | "Promote" PieceType Exp                                       [strict]
    syntax Command ::= | "MOVE" Int Int Int Int 							    [strict]

    syntax Exp ::= Int | Bool | String | Id | Piece
				| "a[" Exp "]"		 	 										[strict]
				| "Compare" Exp Exp												[strict]
				| "(" Exp ")"                                                   [bracket]
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
                <k> Init </k>
                <board> .Map </baord>
                <turn> "White" </turn>
                <turncnt> 0 </turncnt>
                <EnP> false </EnP>
                <input color="magenta" stream="stdin"> .List </input>
                <output color="brown" stream="stdout"> .List </output>
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

    rule <k> read => CMD ...</k>
        <input> ListItem(CMD:Command) => .List ...</input>
    rule <k> read => PT:PieceType ...</k>
        <input> ListItem(PT:PieceType) => .List </input>    
    //Print the board
    rule <k> SHOW => SHOWAUX 0 ... </k>
    // Once we've printed all 64 squares, we stop.
    rule <k> SHOWAUX I:Int => . ... </k>
    requires I >=Int 64
    // Print each piece and a newline every 8 pieces.
    rule <k> SHOWAUX I:Int => PRINT "|" PRINT a[I] ( if ((I+1) %Int 8 ==Int 0) { PRINT "|" PRINT "\n" } else { . } ) SHOWAUX I+1 ... </k>

    syntax Int ::= "abs" "(" Int ")" [function]
    rule abs(I) => I  requires I >=Int 0
    rule abs(I) => 0 -Int I requires I <Int 0

    //Move Piece
    rule <k> MOVE I1:Int I2:Int I3:Int I4:Int => handleResult I1 I2 I3 I4 ~> SHOW ~> changeColor C ~> read...</k>
        <turn> C:Color </turn>
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
            else{returnFalse}
        <turn> C:Color </turn>

    //Check the color
    rule <k> getColor (C:Color PieceType) => C </k>
    //Check the piece type
    rule <k> getPieceType (Color PT:PieceType) => PT </k>

    //King
    rule <k> pieceMoveValid _ K I1:Int I2:Int I3:Int I4:Int =>
        if ((abs (I3 - I1) <= 1 && abs (I4 - I2)) <= 1 {returnTrue} else {returnFalse}
    rule <k> pieceCaptureValid _ K I1:Int I2:Int I3:Int I4:Int => pieceMoveValid _ K I1 I2 I3 I4
    //Bishop
    rule <k> pieceMoveValid _ B I1:Int I2:Int I3:Int I4:Int =>
        if (abs(I3 - I1) == abs(I4 - I2)) {isPathClear I1+((I3-I1)/abs(I1-I3)) I2+((I4-I2)/abs(I2-I4)) I3 I4} else {returnFalse}        
    rule <k> pieceCaptureValid _ B I1:Int I2:Int I3:Int I4:Int => pieceMoveValid _ B I1 I2 I3 I4
    //Rook
    rule <k> pieceMoveValid _ R I1:Int I2:Int I3:Int I4:Int =>
        if (I3 == I1){isPathClear I1 I2+((I4-I2)/abs(I2-I4)) I3 I4} else {if(I4!=I2){returnFalse}else{isPathClear I1+((I3-I1)/abs(I1-I3)) I2 I3 I4}}
    rule <k> pieceCaptureValid _ R I1:Int I2:Int I3:Int I4:Int => pieceMoveValid _ R I1 I2 I3 I4
    //Queen
    rule <k> pieceMoveValid _ Q I1:Int I2:Int I3:Int I4:Int =>
        pieceMoveValid _ B I1 I2 I3 I4 || pieceMoveValid _ R I1 I2 I3 I4
    rule <k> pieceCaptureValid _ Q I1:Int I2:Int I3:Int I4:Int => pieceMoveValid _ Q I1 I2 I3 I4
    //White Pawn
    rule <k> pieceMoveValid Black P I1:Int I2:Int I3:Int I4:Int =>
        if((I3 == I1 + 1 && I4 == I2) || (I3 == I1+2 && I4 == I2 && I1 == 2))) { returnTrue } else { returnFalse }
    rule <k> pieceCaptureValid Black P I1:Int I2:Int I3:Int I4:Int => 
        if(I3==I1+1 && abs (I4-I2) == 1) {returnTrue} else{returnFalse}
    //Black Pawn
    rule <k> pieceMoveValid White P I1:Int I2:Int I3:Int I4:Int =>
        if ((I3 == I1 + 1 && I4 == I2) || (I3 == I1 + 2 && I4 == I2 && I1 == 2)) {returnTrue} else {returnFalse}
    rule <k> pieceCaptureValid White P I1:Int I2:Int I3:Int I4:Int => 
        if(I3==I1-1 && abs (I4-I2) == 1) {returnTrue} else{returnFalse}
    //Knight 
    rule <k> pieceMoveValid _ N I1:Int I2:Int I3:Int I4:Int =>
        if ((abs(I3 - I1) == 2 && abs(I4 - I2) == 1) || (abs(I3 - I1) == 1 && abs(I4 - I2) == 2)) {returnTrue} else {returnFalse}
    rule <k> pieceCaptureValid _ N I1:Int I2:Int I3:Int I4:Int => pieceMoveValid _ N I1 I2 I3 I4
    //Check if path is clear
    rule <k> isPathClear I1:Int I2:Int I3:Int I4:Int => if(I1==I3 && I2==I4){returnTrue} else{if(a[(I1-1)*8+I2] ==K Empty){if(I2==I4){isPathClear I1+((I3-I1)/abs(I1-I3)) I2 I3 I4 }else{if(I1==I3){isPathClear I1 I2+((I4-I2)/abs(I2-I4)) I3 I4}else{isPathClear I1+((I3-I1)/abs(I1-I3)) I2+((I4-I2)/abs(I2-I4)) I3 I4}}}else{returnFalse}}

    //Handle the result
    rule <k> handleResult I1:Int I2:Int I3:Int I4:Int => updateCell (I1-1)*8+I2 (I3-1)*8+I4 ~> pawnCheck a[(I1-1)*8+I2] I1 I2 I3 I4
    rule <k> updateCell L1:Exp L2:Exp => . </k>
         <board> ...L1 |-> (Pi:Piece => Empty) ... L2 |-> (_ => Pi)...</board>
    rule <k> pawnCheck L:Exp I1:Int I2:Int I3:Int I4:Int => if(PT ==K P){if((C ==K Black && I3 == 8) || (C ==K White && I3==1)){askPromote I3 I4}}
         <board> ...L |-> C:Color PT:PieceType ... </board>
    rule <k> askPromote I3:Int I4:Int => PRINT "Please enter the pieceType you want to promote to : Q, N, B, R" ~> Promote read a[(I3-1)*8+I4]
    rule <k> Promote PT:PieceType L:Exp => . </k>
        <board> ... L |-> (_ => C PT) </board>
        <turn> C:Color </turn>

    
    rule <k> isCheck I1:Int I2:Int =>
    
endmodule

grammar Calculette;

@members {
    private TablesSymboles tablesSymboles = new TablesSymboles();
    private int _cur_label = 1;
    /** générateur de nom d'étiquettes pour les boucles */
    private String getNewLabel() { return "B" +(_cur_label++); }
    
}

start: a = calcul EOF;

calcul returns [ String code ]
@init{ $code = new String(); }   // On initialise code, pour ensuite l'utiliser comme accumulateur
@after{ System.out.println($code); }
    :   (decl { $code += $decl.code; })*
        NEWLINE*

        (instruction { $code += $instruction.code; })*

        { $code += "  HALT\n"; }
    ;


decl returns [ String code ] 
    :
        TYPE IDENTIFIANT 
        {
            tablesSymboles.putVar($IDENTIFIANT.text, $TYPE.text);
            if($TYPE.text.equals("int")){$code = "PUSHI " + "0" + "\n";}
            if($TYPE.text.equals("float")){$code = "PUSHF " + "0.0" + "\n";}
        } finInstruction
    ; 

assignation returns [ String code ] 
    : IDENTIFIANT '=' expression
        {  
            AdresseType at = tablesSymboles.getAdresseType($IDENTIFIANT.text);
            $code = $expression.code + "STOREG " + at.adresse + "\n";

        };


 

instruction returns [ String code ] 
    : expression finInstruction 
        { 
            $code = $expression.code; 
        }
    | assignation finInstruction
        {
            $code = $assignation.code;
        }
    | input finInstruction 
        {
            $code = $input.code;
        }
    | print finInstruction
        {
            $code = $print.code;
        }
    ;

expression returns [ String code ]
    : 
    a=expression op=('*'|'/') b=expression {
        if($op.text.equals("*")){$code = $a.code + $b.code + "MUL\n";}
        else{$code = $a.code + $b.code + "DIV\n";}
        }
    |   c=expression op2=('+'|'-') d=expression {
        if($op2.text.equals("+")){$code = $c.code + $d.code + "ADD\n";}
        else{$code = $c.code + $d.code + "SUB\n";}
        }
    |   ENTIER {
        $code = "  PUSHI " + $ENTIER.text + "\n";
    }
    |
        IDENTIFIANT {
		AdresseType at = tablesSymboles.getAdresseType($IDENTIFIANT.text);
        $code = "  PUSHG " + at.adresse + "\n";
        }
    ;
    
input returns [String code]
    :
    'read' '(' IDENTIFIANT ')' {
        AdresseType at = tablesSymboles.getAdresseType($IDENTIFIANT.text);
        $code =  " READ \n";
        $code += " STOREG " + at.adresse + "\n";  
    };

print returns [String code]
    :
    'write' '(' expression ')' {
        $code = $expression.code;
        $code += " WRITE \n  POP\n";
    };


condition returns [String code]
    : 'true'  { $code = "  PUSHI 1\n"; }
    | 'false' { $code = "  PUSHI 0\n"; }
    ;

while returns [String code]
    : 
    'while' '(' condition ')'{
        String boucleIn = getNewLabel();
        $code = boucleIn
        $code = boucleOut   | $code = "JUMPF " + condition + boucleIn      
    
    String boucleOut = getNewLabel();
    $code = boucleOut
    
    };

    


// lexer


finInstruction : ( NEWLINE | ';' )+ ;


TYPE: 'int' | 'float';

IDENTIFIANT :   ('a'..'z' | 'A'..'Z' | '_')('a'..'z' | 'A'..'Z' | '_' | '0'..'9')*;

ENTIER: ('0' ..'9')+;




NEWLINE: '\r'? '\n' ;

WS: (' ' | '\t')+ -> skip;

UNMATCH: . -> skip;

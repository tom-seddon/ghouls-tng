CLOSE#0
A%=&EA:X%=0:Y%=255:IF((USR&FFF4)AND&FF00)DIV256<>0:P."This game is not compatible with a second processor.":END
MODE5
HIMEM={&gmc_org}
VDU23,1,0,0,0,0,0,0,0,0
?&FE00=8:?&FE01=&30
*LOAD GSCREEN 5800
?&FE00=8:?&FE01=&00
VDU19,3,4,0,0,0
VDU28,0,31,19,26
*FX229 1
*FX4 2
C.2:P.TAB(2,1)"1. ADVENTURER"
C.1:P.TAB(2,3)"2. ARCHITECT"
REP.
G$=GET$
U.G$="1"ORG$="2"
IFG$="2":*RUN GEDMC
CLS
C.2
P.TAB(2,1)"LEVELS TO LOAD?"
P.TAB(2,2)"(BLANK=DEFAULT)"TAB(0,4);
*FX15 1
VDU23,1,1,0,0,0,0,0,0,0
I."]"A$
IFA$="":A$="GLEVELS"
*FX229
*FX4
*RUN GUDGS
*LOAD GMC
OSCLI"LOAD "+A$+" {~levels_org}"
IFPAGE>&1100:PAGE=&1100
CH."GBAS"

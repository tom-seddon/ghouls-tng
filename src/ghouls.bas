HIMEM={&gmc_org}
DIMHI(10),N$(10):FORF=0TO9:N$(F)=CHR$132+"Ghoul Basher "+STR$(F+1):HI(F)=(20-F)*10:NEXT
{?not debug}ONERRORGOTO{$L1920}
{?debug}ONERROR:MODE7:REPORT:PRINT" at line ";ERL:END
IFINKEY(-255)=-1 ?&220=166:?&221=255 ELSE GOTO{$L50}
{:L50}
{?not debug}ONERRORGOTO{$L1350}
SC1=1:GO1=0
CALL{&reset_envelopes}:GOTO{$L1350}
{:L70}
REM***** GHOULS *****
VDU22,5:VDU23;11;0;0;0;
FORF=0TO4:F?{&score_chars}=230:NEXT:LI=4:SC=SC1:?{&L0AF2}=60:GO=GO1
{:L100}
FORF=1TO3:VDU19,F,0;0;:NEXT
PRINTTAB(0,5);:COLOUR3:GCOL0,1
LDATA={&levels_org}+4+(SC-1)*{$LevelData_size}:!{&level_draw_ptr}=LDATA:A%=0:X%=GO:CALL{&entry_init_level}:VDU5:MOVE(20-LEN($(LDATA+{$LevelData_name_offset})))*64,28:PRINT$(LDATA+{$LevelData_name_offset}):VDU4
!{&ghosts_table}=0:!{&ghosts_table+3}=0:COLOUR1:PRINTTAB(14,1);:VDU240,241,242{# TODO: ghosts_table+3 should probably be ghosts_table+4...
GCOL0,1:MOVE0,60:DRAW0,952:MOVE1279,60:DRAW1279,860:MOVE1080,800:DRAW1080,860:GCOL0,2:MOVE0,952:PLOT21,1279,952:GCOL0,2:MOVE1092,864:DRAW1270,864
IFLI=1GOTO{$L160}
FORF=0TO((LI-2)*16)STEP16:FORG=0TO15STEP4:G!(F+&7D80)=G!{&sprite_pl_facing}:G!(F+&7EC0)=G!{&sprite_pl_facing+16}:NEXT,
{:L160}
?{&bonus_chars}=235:?{&bonus_chars+1}=230:COLOUR2:PRINTTAB(18,1);:VDU235,230
FORF=0TO31:F?{&data_behind_player}=0:NEXT:FORF=0TO4:PRINTTAB(F,1);CHR$(F?{&score_chars}):NEXT
FORF=0TO31STEP4:F!&5CE0=F!{&sprite_goal_row0}:F!&5E20=F!{&sprite_goal_row1}:NEXT
VDU23,0,1,0;0;0;0;:VDU19,1,1;0;19,2,3;0;19,3,LDATA?{$LevelData_colour3_offset};0;
SOUND&12,4,0,18:SOUND&13,4,1,18:FORF=1TO40:VDU23,0,1,F;0;0;0;:*FX19
NEXT
!{&player_addr}=&5800+LDATA?{$LevelData_pl_start_x_offset}*16+(4+LDATA?{$LevelData_pl_start_y_offset})*320
FORF=0TO GO STEP2:G=&6000+(RND(300)*16):F!{&ghosts_table}=G:NEXT:?{&bonus_update_timer}=31
?&7D=0 {# the asm doesn't seem to use &7D...
CALL{&entry_game}:*FX15
IF?{&level_finished}=255GOTO{$L370}
FORG=0TO4STEP2:N=G?{&ghosts_table+1}*256+G?{&ghosts_table}:IFN>&5800 FORF=0TO15STEP4:F!N=F!{&sprite_ghost_happy_row0}:F!(N+320)=F!{&sprite_ghost_happy_row1}:NEXT
NEXT:{# TODO N=?{&platform_addr+1}*256+?{&platform_addr}:FORF=0TO31STEP4:F!N=F!{&sprite_floating_platform}:NEXT:N=?{&spider_addr+1}*256+?{&spider_addr}:IFN>&5800 FORF=0TO31STEP4:F!N=F!{&sprite_spider_1_row0}:F!(N+320)=F!{&sprite_spider_1_row1}:NEXT
SOUND&10,-15,3,18:FORF=200TO0STEP-.6:SOUND&11,0,F,1:NEXT:N=?{&player_addr+1}*256+?{&player_addr}:IF?(N+326)=224N=N+320 ELSEIF?(N-314)=224N=N-320
K=110:FORG={&sprite_pl_die_0} TO {&sprite_pl_die_7} STEP16:FORF=0TO15STEP4:F!N=F!G:NEXT
FORJ=K TO K+5STEP.3:SOUND&11,-12,J,1:SOUND&12,-12,J-12,1:NEXT:FORJ=K+5 TO K-10STEP-.8:SOUND&11,-12,J,1:SOUND&12,-12,J-12,1:NEXT:K=K-8:NEXT
FORF=0TO15STEP4:F!N=F!{&sprite_pl_die_8}:NEXT:FORG=0TO35STEP35:FORF=G TO G+40STEP1.5:SOUND&11,-15,F,1:NEXT:FORH=1TO400:NEXT:FORH=0TO15STEP4:H!N=H!{&data_behind_player}:NEXT,
LI=LI-1:IFLI=0GOTO{$L1000}
FORF=1TO3000:NEXT
SOUND&10,4,4,18:CALL{&entry_slide_off}:VDU23,0,13,0;0;0;0;
GOTO{$L100} 
NEXT
END
{:L370}
IF?{&player_addr}=192 FORJ=0TO15STEP4:J!&5CC0=0:J!&5CD0=J!{&sprite_pl_facing}:J!&5E00=0:J!&5E10=J!{&sprite_pl_facing+16}:NEXT
ENVELOPE1,2,-1,1,-1,1,1,1,0,-3,0,-1,126,90:RESTORE{$L1830}:FORF=1TO39:READP
SOUND&11,1,P,4:SOUND&12,1,P+1,4:SOUND&13,1,P-1,4:FORK=1TO200:NEXT
NEXT:FORF=1TO4000:NEXT:CALL{&reset_envelopes}
?{&L0AF2}=?{&L0AF2}-5:IF?{&L0AF2}<20?{&L0AF2}=20
SC=SC+1:IFSC=5:PROCtower:GOTO{$L100}
*FX15
SOUND&11,2,2,50:SOUND&12,2,130,50:FORF=0TO15STEP4:F!&5CE0=F!{&sprite_ghost_happy_row0}:F!&5CF0=F!{&sprite_ghost_happy_row0}:F!&5E20=F!{&sprite_ghost_happy_row1}:F!&5E30=F!{&sprite_ghost_happy_row1}:NEXT
FORF=1TO1000:NEXT:SOUND&10,1,2,2:FORF=0TO15STEP4:F!&5CD0=0:F!&5E10=0:NEXT:FORF=0TO15STEP4:F!&5A50=F!{&sprite_pl_facing}:F!&5B90=F!{&sprite_pl_facing+16}:NEXT:FORF=1TO500:NEXT:FORF=0TO15STEP4:F!&5A50=0:F!&5B90=0:NEXT
GCOL0,2:MOVE0,952:PLOT21,1279,952:COLOUR2:PRINTTAB(1,14);"                  ";TAB(1,16);"                  ";TAB(1,15);"ESCAPE TO LEVEL ";SC;"."
FORF=1TO700:NEXT:SOUND&11,2,100,50:FORF=1TO4000:NEXT
G=999:F=999:H=999
VDU30:FORF=0TO31:VDU11:*FX19
NEXT:CLS
CLS:GOTO{$L100}
END
DEFPROCtower:G=6:F=16:GO=GO+2:IFGO=6GO=4
FORG=0TO4STEP2:N=G?{&ghosts_table+1}*256+G?{&ghosts_table}:IFN>&5800 FORF=0TO15STEP4:F!N=0:F!(N+320)=0:NEXT, ELSENEXT
SOUND&10,-15,7,255:FORJ=7TO0STEP-1:SOUND&11,-8,J*16,1:FORH=1TO200:NEXT
FORG=0TO4STEP2:N=G?{&ghosts_table+1}*256+G?{&ghosts_table}:IFN>&5800 FORF=J TO15STEPJ+1:F?N=F?{&sprite_ghost_happy_row0}:F?(N+320)=F?{&sprite_ghost_angry_row1}:NEXT
NEXT,:SOUND&10,0,0,0
FORF=1TO1000:NEXT:FORH=1TO5:SOUND&10,1,2,2:FORF=0TO15STEP4:F!&5CD0=0:F!&5E10=0:NEXT:FORF=0TO15STEP4:F!&5B90=F!{&sprite_pl_facing}:F!&5CD0=F!{&sprite_pl_facing+16}:NEXT:FORF=1TO200:NEXT:FORF=0TO15STEP4:F!&5B90=0:F!&5CD0=0:NEXT
GCOL0,2:MOVE0,952:PLOT21,1279,952
FORF=0TO15STEP4:F!&5CD0=F!{&sprite_pl_facing}:F!&5E10=F!{&sprite_pl_facing+16}:NEXT:FORF=1TO200:NEXT
NEXT:FORF=0TO15STEP4:F!&5CD0=F!{&sprite_pl_right_0}:F!&5E10=F!{&sprite_pl_right_0+16}:NEXT
FORF=1TO3000:NEXT:CLS:VDU28,0,9,19,0,19,3,6;0;:COLOUR3:PRINTTAB(2,1);:IFGO-2=0PRINT" GHOST GAVE UP." ELSEPRINT" GHOSTS GAVE UP"
PRINTTAB(1,3);"YOU TOOK THE POWER       JEWELS"'" AND ESCAPED TO GET    SOME MORE....."
COLOUR3:PRINT'" AWARDED EXTRA LIFE"
FORG=-1TO-15STEP-.02:SOUND&11,G,0,30:SOUND&12,G,0,30:SOUND&13,G,2,30:NEXT
VDU19,1,0;0;19,2,0;0;:GCOL0,2:MOVE300,700:FORF=0TO360STEP20:IFF=80ORF=120GCOL0,1 ELSEGCOL0,2
IFF=100GCOL0,0
MOVE300,500:PLOT85,300+232*SINRADF,500+200*COSRADF:NEXT
GCOL0,0:MOVE308,500:DRAW532,500:VDU23,0,13,40;0;0;0;19,2,3;0;:CLS
G=3:FORF=40TO17STEP-1:VDU23,0,13,F;0;0;0;19,1,G;0;:IFG=3G=0:SOUND&10,-15,7,-1:FORI=175TO245STEP2:SOUND&11,0,I,1:NEXT ELSE G=3:SOUND&10,0,0,0:FORI=0TO35:SOUND&10,0,0,0:NEXT
NEXT:LI=LI+1:IFLI>6LI=6
FORF=1TO3500:NEXT:SC=1:CLS:VDU19,1,0;0;19,2,0;0;23,0,13,0;0;0;0;26:ENDPROC
{:L1000}
FORF=1TO1500:NEXT:COLOUR2:FORF=13TO15:PRINTTAB(5,F);"          ":NEXT:PROCPRNT(6,14,"THE  END",400,0)
FORF=1TO2000:NEXT:CALL{&entry_slide_off}
VDU22,7:VDU23;8202;0;0;0;
S=0:G=100000:FORF=0TO4:G=G/10:N=(F?{&score_chars})-230:S=S+(N*G):NEXT
SC=10:FORF=9TO0STEP-1:IFHI(F)<S SC=F
NEXT
IFSC=10GOTO{$L1270}
FORF=10TOSC+1 STEP-1:HI(F)=HI(F-1):N$(F)=N$(F-1):NEXT
FORF=1TO2:PRINTTAB(3,F)CHR$141CHR$129"C"CHR$130"O"CHR$131"N"CHR$132"G"CHR$133"R"CHR$134"A"CHR$135"T"CHR$129"U"CHR$130"L"CHR$131"A"CHR$132"T"CHR$133"I"CHR$134"O"CHR$135"N"CHR$129"S":NEXT
PROCPRNT(7,4,CHR$131+"YOU ARE IN THE TOP TEN",45,1):PROCPRNT(7,6,CHR$130+"PLEASE ENTER YOUR NAME",80,1)
IFSC=0A$=" st" ELSEIFSC=1A$=" nd" ELSEIFSC=2A$=" rd" ELSEIFSC>2A$=" th"
FORF=15TO16:PRINTTAB(13,F)CHR$141CHR$129CHR$136;SC+1;A$:NEXT
PRINTTAB(7,10)CHR$134CHR$157CHR$132"                    "CHR$156
*FX15
L$="":K=10:P=0:L=0:F=.1:RESTORE{$L2020}
{:L1150}
IFINKEY(-74)=-1GOTO{$L1250}
{:L1160}
IFF<.4READG,F:IFG=-1RESTORE{$L2010}:GOTO{$L1160} ELSE SOUND&11,2,G+48,F/5.5:SOUND&12,2,G,F/5.5
IFF>=.4F=F-.8
P=P+1:IFP=10P=1:L=(L+1 AND3)
IFL=3PRINTTAB(K+1,10);"]"ELSE IFL=1PRINTTAB(K+1,10);"["
I=INKEY(0):IFI=-1GOTO{$L1150}
F=F-.48
IFI=127ANDK=10 GOTO{$L1150}
IFI=127 K=K-1:L$=LEFT$(L$,K-10):PRINTTAB(K+2,10);" ":GOTO{$L1150}
IFK=26 ORI<32ORI>127GOTO{$L1150} ELSEK=K+1:L$=L$+CHR$I:PRINTTAB(K,10);CHR$I:F=F-.3:GOTO{$L1150}
{:L1250}
PRINTTAB(K+1,10);" "
N$(SC)=L$:HI(SC)=S:CLS
{:L1270}
FORF=0TO1:PRINTTAB(10,F)CHR$141CHR$130"BEST TEN TODAY":NEXT
FORF=0TO9:PRINTTAB(2,F*2+2)CHR$134;F+1;"...";TAB(7,F*2+2);" "CHR$135::PROCPRNT(9,F*2+2,N$(F),6,1):PRINTTAB(26,F*2+2);CHR$131"...";HI(F):NEXT
IFSC=255GOTO{$L1320}
IFSC<>10PRINTTAB(7,SC*2+2)CHR$136
IFSC=10 PRINTTAB(9,22)CHR$134"YOU SCORED ";S
{:L1320}
PRINTTAB(5,23)CHR$133"Press SPACE BAR to start"
{:L1330}
IFINKEY(0)<>32GOTO{$L1330}
GOTO{$L70}
{:L1350}
REM*** INSTRUCTIONS **
VDU22,7:VDU23,0,11;0;0;0;
*FX15
FORF=1TO2:PRINTTAB(10,F);CHR$141;CHR$(131-F);"G H O U L S":NEXT:PRINTTAB(10,3)CHR$147"``,,,ppp,,,``"
SOUND&11,2,5,50:SOUND&12,2,5,50:SOUND&13,2,6,50:FORF=1TO2500:NEXT 
IFINKEY(-255)=0GOTO{$L1470}
FORF=10TO11:PRINTTAB(0,F)CHR$141CHR$130"Do you want sound in the game?"CHR$134:NEXT
A$=GET$
{:L1430}
FORF=10TO11:PRINTTAB(33,F);A$:NEXT:IFA$<>"N"ANDA$<>"Y" ANDA$<>"n"ANDA$<>"y" PRINTTAB(0,20)CHR$129"INPUT NOT CORRECT, TRY AGAIN":SOUND&10,-15,2,1:A$=GET$:PRINTTAB(1,20);"                                                ":GOTO{$L1430}
IFA$="N"ORA$="n" THEN !&262=1 ELSE !&262=0{#?&262 is the value set by OSBYTE 210 - sound suppression status
REM***** BRIEF *****
PROCCLR
{:L1470}
PRINTTAB(1,5)CHR$134"Situated in a deadly"CHR$129"haunted"CHR$134"mansion,"'CHR$134"you have to rescue your power jewels"'CHR$134"from the horrid ghosts that stole them."
PRINTTAB(0,8)" "CHR$130"But this is not as easy as it sounds!"'CHR$130"On your trek up the house you are"'CHR$130"confronted with spooky"CHR$129"ghosts,"CHR$130"cracked"'CHR$130"and contracting floor boards, moving"
PRINTCHR$130"platforms, springs, and deadly spikes."
PRINTCHR$130"There is also a nasty spider that jumps"CHR$130"up and down ready to catch you!!"
PRINT" "CHR$131"By eating one of the stray power"'CHR$131"jewels you can over power and paralyse"'CHR$131"the ghosts for a few seconds helping"'CHR$131"you in your quest...."
FORF=21TO22:PRINTTAB(4,F);CHR$141CHR$133"Press SPACE BAR to continue":NEXT
*FX15
{:L1540}
I=GET:IFI<>32GOTO{$L1540}
PROCCLR
PRINTTAB(1,5)CHR$134"The keys are as follows..."
PRINT'TAB(8)CHR$131"""Z"""CHR$132"-"CHR$135"MOVES YOU LEFT"''TAB(8)CHR$131"""X"""CHR$132"-"CHR$135"MOVES YOU RIGHT"''TAB(8)CHR$131"""RETURN"""CHR$132"-"CHR$135"TO JUMP"
PRINT'TAB(8)CHR$131"""P"""CHR$132"-"CHR$135"PAUSES GAME"''TAB(8)CHR$131"""O"""CHR$132"-"CHR$135"CANCELS PAUSE"
PRINT'"   "CHR$131"""ESCAPE"""CHR$132"-"CHR$135"RETURNS TO SOUND OPTION                 AND INSTRUCTIONS"
FORF=20TO21:PRINTTAB(1,F)CHR$141CHR$133"DO YOU WANT TO SEE GAME OBJECTS?";TAB(13,F+2)CHR$141CHR$130"(Y/N)":NEXT
{:instructions_yn}
*FX15,1
I$=GET$:IFI$="Y" ORI$="y"VDU22,5:VDU23,0,11;0;0;0;:PROCSHOW
{?debug}IFI$="G"ORI$="g":GO1=GO1+2:PRINTTAB(0,24)"GO=";GO1;:GOTO{$instructions_yn}
{?debug}SC1=1:IFI$>="1"ANDI$<="4":SC1=VALI$
GOTO{$L70}
DEFPROCSHOW
FORF=1TO3:VDU19,F,0;0;:NEXT
COLOUR2:PRINTTAB(4,1);"GAME OBJECTS"
N=&5BC0:FORF=0TO15STEP4:F!N=F!{&sprite_pl_facing}:F!(N+320)=F!{&sprite_pl_facing+16}:NEXT:COLOUR1:PRINTTAB(2,4);" = YOU!!"
N=N+960:FORF=0TO15STEP4:F!N=F!{&sprite_ghost_angry_row0}:F!(N+320)=F!{&sprite_ghost_angry_row1}:NEXT:COLOUR1:PRINTTAB(2,7);" = GHOUL"
N=N+960:FORF=0TO31STEP4:F!N=F!{&sprite_spider_1_row0}:F!(N+320)=F!{&sprite_spider_1_row1}:NEXT:COLOUR1:PRINTTAB(2,10);" = SPIDER"
N=N+960:FORF=0TO31STEP4:F!N=F!{&sprite_floating_platform}:NEXT:COLOUR1:PRINTTAB(2,12);" = MAGIC PLATFORM"
N=N+736:FORG=N TO N+196STEP8:FORF=0TO7STEP4:F!G=F!{&sprite_conveyor+8}:NEXT,:COLOUR3:PRINTTAB(0,14);CHR$224;TAB(18,14);CHR$224;CHR$224;:COLOUR1:PRINTTAB(2,15);" = MOVING FLOOR"
PRINTTAB(0,17);CHR$228;"  = DEADLY SPIKE";TAB(0,19);CHR$225;TAB(0,20);CHR$229;"  = SUPER SPRING"
N=&7380:FORF=0TO15STEP4:F!N=F!{&sprite_power_pill}:NEXT:PRINTTAB(2,22);" = POWER JEWEL"
COLOUR2:PRINTTAB(0,24);CHR$243;CHR$243:COLOUR1:PRINTTAB(2,24);" = STRAY EDIBLES!"
N=N+1280:FORF=0TO31STEP4:F!N=F!{&sprite_goal_row0}:F!(N+320)=F!{&sprite_goal_row1}:NEXT:COLOUR1:PRINTTAB(2,27);" = STOLEN JEWELS"
COLOUR2:PRINTTAB(0,29);"PRESS SPACE TO PLAY."
VDU19,1,1;0;19,2,3;0;19,3,4;0;
*FX15
{:L1790}
I=GET:IFI<>32GOTO{$L1790}
CALL{&entry_slide_off}:ENDPROC
*FX15
PRINT:PRINT:END
{:L1830}
DATA41,69,89,101,117,137,117,101,89,69
DATA33,61,81,97,109,129,109,97,81,61
DATA25,53,73,89,101,121,101,89,73,53,21,49,69,81,97,117,129,145,165
DATA-1
DEFPROCPRNT(X,Y,A$,L,H):SOUND&10,-15,3,255:SOUND&11,0,0,255
PRINTTAB(X,Y);:FORJ=1TO LENA$:G=ASCMID$(A$,J,1):IFG<>32AND H=1SOUND&11,0,G*2,0
PRINT;MID$(A$,J,1);:FORG=1TOL:NEXT,:SOUND&11,0,0,0:SOUND&10,0,0,0:ENDPROC
DEFPROCCLR:SOUND&10,-15,7,255:FORF=22TO5STEP-1:SOUND&11,0,128+F*5,1:PRINTTAB(0,F);CHR$(128+(F AND7));CHR$157;"                                      ":NEXT
FORF=22TO5STEP-1:SOUND&11,0,150+((F*300)AND105),1:PRINTTAB(0,F);"                                       ":NEXT:SOUND&10,0,0,0:ENDPROC
{:L1920}
ONERRORCLEAR:GOTO{$L1920}
MODE7:VDU23;11;0;0;0;
PROCPRNT(5,10,CHR$131+"E N D  O F  L I N E . . .",50,1)
!&2200=RND(65535)
IFINKEY(-255)=-1CALL&D9CD
{:L1970}
GOTO{$L1970}
DEFPROCman
IF?&3D2<>131 AND?&3D3<>136 AND ?&3D4<>128GOTO{$L1920}
ENDPROC
{:L2010}
DATA5,16,17,16,33,16,53,16,37,24,37,8,33,8,25,8,17,8,13,8,5,16,17,16,33,16,53,16,65,32,61,28
{:L2020}
DATA5,20,13,8,17,16,5,16,25,20,33,8,37,16,25,16,33,20,37,8,33,8,25,8,17,8,13,8,-1,-1
END

**FREE
CTL-OPT COPYRIGHT('(C) NBOUVIER')
OPTION(*SRCSTMT) DFTACTGRP(*NO) OPTIMIZE(*none)
ACTGRP(*CALLER) DATFMT(*eur) TIMFMT(*ISO) ALLOC(*STGMDL)
STGMDL(*INHERIT) THREAD(*SERIALIZE);
//Compiler avec RPGPPOPT (*LVL2)

//**********************************************************************//
// Déclaration des fichiers                                             //
//**********************************************************************//
DCL-F actuFM WORKSTN SFILE(SFL01:RANG) INDDS(INDICATEUR);
/include NBOUVIER/QDDSLESRC,INDICATEUR
/include NBOUVIER/QDDSLESRC,API

//**********************************************************************//
// Déclaration programme externe                                        //
//**********************************************************************//
dcl-pr scrapping extpgm;
end-pr;

//**********************************************************************//
// Déclaration DS                                                       //
//**********************************************************************//
DCL-DS FETCH1;
  ECOL char(150);
  ECOL1 char(60);
  ECOL2 char(60);
END-DS;

//Ecran message erreur
DCL-DS *N PSDS;
  $PGM     *PROC;
END-DS;

//**********************************************************************//
// Déclaration des variables                                            //
//**********************************************************************//
DCL-S i         ZONED(5:0) INZ(0);
DCL-S Sqlstm    varchar(100);
DCL-s SflPag    zoned(10);
//Date
dcl-s DateRecup timestamp;
dcl-s DateModif date;
dcl-s DateUtil  char(10);
DCL-S posSpace INT(5) INZ(0);
 DCL-S pos INT(5);
//**********************************************************************//
// Traitement pricipale                                                 //
//**********************************************************************//
EXEC SQL
  SET option commit = *none , ALWCPYDTA = *OPTIMIZE, CLOSQLCSR = *ENDMOD,
  DATFMT = *eur;

Dow Not EXIT;
// initialisation, Date du jour
 init();
 datej();
 // Affichage ecran
 Exfmt format2;
 clean();
//Rafraichir donnée
  if RAFRAICHIR = *on;
    callp SCRAPPING();
    iter;
  endif;
// Option et gestion erreur
  monitor;
    select;
      when Emeteo = '1';
        SqlStm = 'select * from meteo';
        ECHOIX = 'Température du ' + DateUtil;
        ETITRE2 = 'Montpellier';
        cmd='STRPCCMD PCCMD(''start /B https://www.infoclimat.fr/observations-meteo/' +
        'temps-reel/montpellier-frejorgues/07643.html'') PAUSE(*NO) ';
      when EACTU = '1';
        SqlStm = 'select * from actu';
        ECHOIX = 'Actualité du ' + DateUtil;
        ETITRE2 = 'Le monde';
        cmd='STRPCCMD PCCMD(''start https://www.lemonde.fr'') PAUSE(*NO) ';
      when Esport = '1';
        SqlStm = 'select * from sport';
        ECHOIX = 'Sport du ' + DateUtil;
        ETITRE2 = 'L equipe';
        cmd='STRPCCMD PCCMD(''start https://www.lequipe.fr/'') PAUSE(*NO) ';
      OTHER;
        //pas de sous fichier donc inutile
        msgId  = 'UTI0001';
        ERROPT();
       iter;
    ENDSL;
  ON-ERROR *ALL;
    msgId  = 'UTI0014';
    ERROPT();
   iter;
  ENDMON;

// Exécuter uniquement si une requéte SQL est définie
  If %Len(SqlStm) > 0;
    cmdLen = %len(cmd);
    ClearSF();
    BuildSF();
    DspSF();
  EndIf;
EndDo;

*inlr = *on;


//**********************************************************************//
// Procedure initialisation programme                                   //
//**********************************************************************//
DCL-PROC init;
  Emeteo = '';
  EACTU = '';
  Esport = '';
  SqlStm = '';
  RAFRAICHIR = *off;
END-PROC ;

//**********************************************************************//
// Procedure date du jour                                               //
//**********************************************************************//
 DCL-PROC datej;
 // --- Recup date ---
   exec sql
    select LAST_USED_TIMESTAMP
    into :DateRecup
    from table(QSYS2.IFS_OBJECT_STATISTICS('/home/NBOUVIER/infoclimat_data.csv'));
  gstErrSQL();
// --- Conversion  ---
  DateModif = %date(DateRecup);
// --- Formatage  ---
  DateUtil = %char(DateModif: *EUR);
// --- Affichage  ---
  ETITRE1 = 'Information du '+ DateUtil ;
END-PROC ;

//**********************************************************************//
// Procedure initialisation sous fichier                                //
//**********************************************************************//
DCL-PROC ClearSF;
  rang = *zero;

  //Effacemment du sous-fichier
  SFLCLEAR = *OFF;

  //Ecriture sous-fichier
  Write ctl01;

  //Sous-fichier pret à etre afficher
  SFLCLEAR  = *ON;
  SFLDSP    = *ON;
  SFLEND    = *OFF;

  EXEC SQL CLOSE C1;
END-PROC ;

//**********************************************************************//
// Procedure Fabrication sous fichier                                   //
//**********************************************************************//
DCL-PROC BuildSF;
  EXEC SQL PREPARE STATE FROM :SqlStm;
  gstErrSQL();
  EXEC SQL DECLARE C1 CURSOR FOR STATE;
  gstErrSQL();
  EXEC SQL OPEN C1;
  gstErrSQL();

  Sflpag=24;

  FOR i=1 to Sflpag;
    EXEC SQL Fetch C1 into :fetch1;
    gstErrSQL();
  // Gestion sortit--------------------//
    IF sqlcode = 100;
      EXEC SQL CLOSE C1;
      gstErrSQL();
      SFLEND = *on;
      leave;
    ENDIF;
  // --------------------------------------//
    FOR pos = 60 DOWNTO 1;
      IF %subst(ECOL:pos:1) = ' ';
        posSpace = pos;
        LEAVE;
      ENDIF;
    ENDFOR;
    ECOL1 = %subst(ECOL:1:posSpace);
    ECOL2 = %triml(%subst(ECOL:posSpace+1));   
    rang += 1;      
    write SFL01;
  ENDFOR;

END-PROC;
//**********************************************************************//
// Procedure Affichage                                                  //
//**********************************************************************//
DCL-PROC DspSF;
  DoU RETOUR;
    RANG = 1;
    Write bas01;
    Exfmt ctl01;
    //Accée au site
    if INFO = *on;
      callp QCMDEXC(cmd: cmdLen);
    endif;
    Readc SFL01;
  EndDo;
END-PROC ;

//**********************************************************************//
// Procedure message erreur                                             //
//**********************************************************************//
DCL-PROC ERROPT;
  //pas de sous fichier donc inutile
  callp QMHSNDPM( msgId : 'MESSAGE   *LIBL     ' : msgData :
  msgDataLen :  '*DIAG': $PGM  : 0 : msgKey : errorCode );

   WRITE MSGCTL;
END-PROC ;

//**********************************************************************//
// Procedure nettoyage message erreur                                   //
//**********************************************************************//
DCL-PROC CLEAN;
  callp QMHRMVPM ($PGM: *zero: *blanks: '*ALL': errorDS);
END-PROC ;

//**********************************************************************//
// Procedure erreur sql                                                 //
//**********************************************************************//
DCL-PROC gstErrSQL;
  if sqlCode < 0;
    msgData = 'Erreur SQL ' + %char(sqlcode);
    exec sql get diagnostics condition 1 :msgData = MESSAGE_TEXT;

    if %len(msgData) > 0;
      msgData = msgData + ' : ' + %trim(msgData);
    endif;

    msgDataLen =  %len(msgData);

    callp QMHSNDPM( msgId : 'QCPFMSG   QSYS      ' : msgData:
     msgDataLen : '*ESCAPE': $PGM  : 1 : msgKey : errorCode );
  endif;
END-PROC ;


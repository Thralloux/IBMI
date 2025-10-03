**FREE
CTL-OPT COPYRIGHT('(C) NBOUVIER 2025')
OPTION(*SRCSTMT) DFTACTGRP(*NO) OPTIMIZE(*none)
ACTGRP(*CALLER) DATFMT(*eur) TIMFMT(*ISO) ALLOC(*STGMDL)
STGMDL(*INHERIT) THREAD(*SERIALIZE);
//Compiler avec RPGPPOPT (*LVL2)

//**********************************************************************//
// Déclaration des fichiers                                             //
//**********************************************************************//
DCL-F actuFM WORKSTN SFILE(SFL01:RANG) INDDS(INDICATEUR);
/include QDDSLESRC,INDICATEUR
/include QDDSLESRC,API

//**********************************************************************//
// Déclaration programme externe                                        //
//**********************************************************************//
dcl-pr scrapping extpgm;
end-pr;

//**********************************************************************//
// Déclaration DS                                                       //
//**********************************************************************//
DCL-DS FETCH1;
  ECOL1 char(150);
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

//**********************************************************************//
// Traitement pricipale                                                 //
//**********************************************************************//
EXEC SQL
  SET option commit = *none , ALWCPYDTA = *OPTIMIZE, CLOSQLCSR = *ENDMOD,
  DATFMT = *eur;

Dow Not EXIT;
// initialisation, Date du jour, msg erreur, affichage, nettoyage
 init();
 datej();
 WRITE MSGCTL;
 Exfmt format2;
 clean();
//Rafraichir donnée
  if RAFRAICHIR = *on;
    callp RAFRAICHIR_data();
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
        msgId  = 'UTI0001';
        ERROPT();
       iter;
    ENDSL;
  ON-ERROR *ALL;
    msgId  = 'UTI0014';
    ERROPT();
   iter;
  ENDMON;

// Exécuter uniquement si une requête SQL est définie
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
    from table(QSYS2.IFS_OBJECT_STATISTICS('/home/NICOLAS/infoclimat_data.csv'));
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
    rang += 1;
    write Sfl01;
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
    //Accès au site
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
  callp QMHSNDPM( msgId : 'MESSAGE   *LIBL     ' : msgData :
  msgDataLen :  '*DIAG': $PGM  : 0 : msgKey : errorCode );
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

//**********************************************************************//
// Procédure Rafraichir data                                            //
//**********************************************************************//
DCL-PROC RAFRAICHIR_data;

  // Mise à jour du PATH pour QOpenSys
  cmd = 'QSH CMD(''PATH=/QOpenSys/pkgs/bin:$PATH'')';
  cmdLen = %len(%trim(cmd));
  callp(e) QCMDEXC(cmd: cmdLen);

  // Exécution du script Python
  cmd = 'QSH CMD(''/home/NICOLAS/my_env/bin/python3 /home/NICOLAS/python.py > /dev/null 2>&1'')';
  cmdLen = %len(%trim(cmd));
  callp(e) QCMDEXC(cmd: cmdLen);

  // Copie des fichiers CSV vers les PF
  cmd = 'CPYFRMIMPF FROMSTMF(''/home/NICOLAS/infoclimat_data.csv'') ' +
        'TOFILE(BOUVIER/METEO) MBROPT(*REPLACE) RCDDLM(*CRLF) ' +
        'STRDLM(*NONE) FLDDLM(*TAB)';
  cmdLen = %len(%trim(cmd));
  callp(e) QCMDEXC(cmd: cmdLen);

  cmd = 'CPYFRMIMPF FROMSTMF(''/home/NICOLAS/lemonde_data.csv'') ' +
        'TOFILE(BOUVIER/ACTU) MBROPT(*REPLACE) RCDDLM(*CRLF) ' +
        'STRDLM(*NONE) FLDDLM(*TAB)';
  cmdLen = %len(%trim(cmd));
  callp(e) QCMDEXC(cmd: cmdLen);

  cmd = 'CPYFRMIMPF FROMSTMF(''/home/NICOLAS/lequipe_data.csv'') ' +
        'TOFILE(BOUVIER/SPORT) MBROPT(*REPLACE) RCDDLM(*CRLF) ' +
        'STRDLM(*NONE) FLDDLM(*TAB)';
  cmdLen = %len(%trim(cmd));
  callp(e) QCMDEXC(cmd: cmdLen);

  // Appel STRPCO en dernier (facultatif si déjà lancé)
  cmd = 'STRPCO';
  cmdLen = %len(%trim(cmd));
  callp(e) QCMDEXC(cmd: cmdLen);

END-PROC;
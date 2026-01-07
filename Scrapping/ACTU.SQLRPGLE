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

//**********************************************************************//
// Déclaration des variables                                            //
//**********************************************************************//
DCL-S i         zoned(5:0);
DCL-S Sqlstm    varchar(100);
DCL-s SflPag    zoned(10);
//Date
dcl-s DateRecup timestamp;
dcl-s DateModif date;
dcl-s DateUtil  char(10);
DCL-S posSpace  int(5);
DCL-S pos       int(5);
//**********************************************************************//
// Traitement pricipale                                                 //
//**********************************************************************//
EXEC SQL
  SET option commit = *none , ALWCPYDTA = *OPTIMIZE, CLOSQLCSR = *ENDMOD,
  DATFMT = *eur;

Dow Not EXIT;
// Initialisation, Date du jour, Affichage ecran
 init();
 datej();
 Exfmt format2;
// Rafraichir donnée 
  if RAFRAICHIR = *on;
    callp SCRAPPING();
    iter;
  endif;
// Option
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
      when ETV = '1';
        SqlStm = 'select * from tv';
        ECHOIX = 'Programme TV du ' + DateUtil;
        ETITRE2 = 'Télérama';
        cmd='STRPCCMD PCCMD(''start https://television.telerama.fr/'') PAUSE(*NO) ';
      when ERADIO = '1';
        SqlStm = 'select * from radio';
        ECHOIX = 'Programme radio du ' + DateUtil;
        ETITRE2 = 'France Inter';
        cmd='STRPCCMD PCCMD(''start https://www.radiofrance.fr/franceinter/grille-programmes/'+
        ''') PAUSE(*NO) ';
      when ECINE = '1';
        SqlStm = 'select * from cine';
        ECHOIX = 'Programme cinéma du ' + DateUtil;
        ETITRE2 = 'Megarama';
        cmd='STRPCCMD PCCMD(''start https://montpellier.megarama.fr/FR/43/'+
        ''') PAUSE(*NO) ';
    ENDSL;
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
  ERADIO = '';
  ETV = '';
  ECINE = '';
  SqlStm = '';
  RAFRAICHIR = *off;
  EXEC SQL CLOSE C1;
END-PROC ;

//**********************************************************************//
// Procedure date du jour                                               //
//**********************************************************************//
 DCL-PROC datej;
 // --- Recup date --- Conversion  --- Formatage --- Affichage
   exec sql
    select LAST_USED_TIMESTAMP
    into :DateRecup
    from table(QSYS2.IFS_OBJECT_STATISTICS('/home/NBOUVIER/infoclimat_data.csv'));
  DateModif = %date(DateRecup);
  DateUtil = %char(DateModif: *EUR);
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
END-PROC ;

//**********************************************************************//
// Procedure Fabrication sous fichier                                   //
//**********************************************************************//
DCL-PROC BuildSF;
  EXEC SQL PREPARE STATE FROM :SqlStm;
  EXEC SQL DECLARE C1 CURSOR FOR STATE;
  EXEC SQL OPEN C1;
  // Nombre d'enregistrement
  Sflpag=80;

  FOR i=1 to Sflpag;
    EXEC SQL Fetch C1 into :fetch1;
  // Gestion sortit--------------------//
    IF sqlcode = 100;
      EXEC SQL CLOSE C1;
      SFLEND = *on;
      leave;
    ENDIF;
  // Amélioration affichage------------//
    FOR pos = 60 DOWNTO 1;
      IF %subst(ECOL:pos:1) = ' ';
        posSpace = pos;
        LEAVE;
      ENDIF;
    ENDFOR;
    ECOL1 = %subst(ECOL:1:posSpace);
    ECOL2 = %triml(%subst(ECOL:posSpace+1));
    // Ecriture sous-fichier ------------//
    rang += 1;
    write SFL01;
  ENDFOR;
END-PROC;
//**********************************************************************//
// Procedure Affichage                                                  //
//**********************************************************************//
DCL-PROC DspSF;
  DoU RETOUR;
    // Positionnement rang ---------//
    if ERADIO = '1';
      exec sql
      SELECT RRN(nbouvier.radio) into :rang
      FROM nbouvier.radio
      WHERE actu_data LIKE 'DIRECT%';
    else;
       RANG = 1;
    endif;
   Write bas01;
    Exfmt ctl01;
    // Accée au site -------------//
    if INFO = *on;
      callp QCMDEXC(cmd: cmdLen);
    endif;
    Readc SFL01;
  EndDo;
END-PROC ;
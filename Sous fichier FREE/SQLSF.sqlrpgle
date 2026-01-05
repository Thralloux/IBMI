**FREE
CTL-OPT COPYRIGHT('(C) NBOUVIER')
OPTION(*SRCSTMT) DFTACTGRP(*NO) OPTIMIZE(*none)
ACTGRP(*CALLER) DATFMT(*eur) TIMFMT(*ISO) ALLOC(*STGMDL)
STGMDL(*INHERIT) THREAD(*SERIALIZE);
//Compiler avec RPGPPOPT (*LVL2)

//---------------------------------------------------
// Déclarations fichiers
//---------------------------------------------------
dcl-f SQLE  workstn SFILE(FE:RANG) INDDS(INDICATEUR);
/include NBOUVIER/QDDSLESRC,INDICATEUR
/include NBOUVIER/QDDSLESRC,API
dcl-f PAYS  usage(*update:*delete) keyed;

//**********************************************************************//
// Déclaration DS                                                       //
//**********************************************************************//
//Ecran message erreur
DCL-DS *N PSDS;
    $PGM     *PROC;
END-DS;

//---------------------------------------------------
// Programme principal
//---------------------------------------------------
EXEC SQL
  SET option commit = *none , ALWCPYDTA = *OPTIMIZE, CLOSQLCSR = *ENDMOD,
  DATFMT = *eur;

INIP();
INIT();
RMP();

dou EXIT ;
    write MSGCTL;
    write FB;
    RANG = 1;
    exfmt FC;
    CLEAN();
    readc FE ;
    monitor;
        select;
            when OPT = '2';
            EDIT();
            when OPT = '4';
            SUP();
            when OPT = '5';
            AFF();
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
    INIT();
    RMP();
enddo;

*inlr = *on;

//---------------------------------------------------
// Initialisation programme
//---------------------------------------------------
dcl-proc INIP;
    write FN;
    clear TLT;
 end-proc;

//---------------------------------------------------
// Initialisation sous-fichier
//---------------------------------------------------
dcl-proc INIT;
    OPT = ' ';
    RANG = 0;
    EXIT = *OFF;

  //Effacemment du sous-fichier
    SFLCLEAR = *OFF;

  //Ecriture sous-fichier
    Write FC;

  //Sous-fichier pret à etre afficher
    SFLCLEAR  = *ON;
    SFLDSP    = *ON;
    SFLEND    = *OFF;
end-proc;

//---------------------------------------------------
// Remplissage sous-fichier
//---------------------------------------------------*/
dcl-proc RMP;

    setll *loval PAYS;
    read PAYS ;

    DOW NOT %EOF();
        RANG += 1;
        ZON1 = NOMPAY;
        ZON2 = CAPITA;
        ZON3 = POPULA;
        ZON4 = SURFAC;
        write FE;
        read PAYS ;
    enddo;

    if %eof(PAYS);
        SFLEND = *ON;
    else;
        SFLEND = *OFF;
    endif;
end-proc;

//---------------------------------------------------
// Affichage détail
//---------------------------------------------------
dcl-proc AFF;

    TLT = 'DETAIL';

    dou RETOUR ;
    chain ZON1 PAYS ;
    IF NOT %ERROR AND %FOUND;
        ENOMPA = NOMPAY;
        ECAPIT = CAPITA;
        EPOPUL = POPULA;
        ESURFA = SURFAC;
        write FD;
        DEBLOCAGE = *on;
        exfmt FD;
    endif;
    enddo;
end-proc;

//---------------------------------------------------
// Suppression
//---------------------------------------------------
dcl-proc SUP;
    chain ZON1 PAYS ;
    IF NOT %ERROR AND %FOUND;
        delete PAYSF;
    endif;
end-proc;

//---------------------------------------------------
// Modification
//---------------------------------------------------
dcl-proc EDIT;

    TLT = 'MODIFICATION';
    DEBLOCAGE = *OFF;

    chain ZON1 PAYS ;
    dou RETOUR;
        ENOMPA = NOMPAY;
        ECAPIT = CAPITA;
        EPOPUL = POPULA;
        ESURFA = SURFAC;
        write FD;
        *in71 = *off;
        exfmt FD;
      // Comparaisons valeur à modifier
        if NOMPAY <> ENOMPA or CAPITA <> ECAPIT
        or POPULA <> EPOPUL or SURFAC <> ESURFA;
            *in71 = *on;
        endif;
      // Fenêtre confirmation
        if *in71 = *on;
            exfmt FV;
            // Annule
            dou EXIT = *on;
                if EXIT = *on;
                    leave;
                endif;
            // Validation
                if info = *on;
                    NOMPAY = ENOMPA;
                    CAPITA = ECAPIT;
                    POPULA = EPOPUL;
                    SURFAC = ESURFA;
                    update PAYSF;
                    leave;
                endif;
            enddo;
        endif;
    enddo;
end-proc;
//---------------------------------------------------
// Procedure message erreur
//---------------------------------------------------
DCL-PROC ERROPT;
  //pas de sous fichier donc inutile
    callp QMHSNDPM( msgId : 'MESSAGE   *LIBL     ' : msgData :
  msgDataLen :  '*DIAG': $PGM  : 0 : msgKey : errorCode );

    WRITE MSGCTL;
END-PROC ;

//---------------------------------------------------
// Procedure nettoyage message erreur
//---------------------------------------------------
DCL-PROC CLEAN;
    callp QMHRMVPM ($PGM: *zero: *blanks: '*ALL': errorDS);
END-PROC ;

//---------------------------------------------------
// Procedure erreur sql
//---------------------------------------------------
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

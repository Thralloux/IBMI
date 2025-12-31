**FREE
CTL-OPT COPYRIGHT('(C) NBOUVIER')
OPTION(*SRCSTMT) DFTACTGRP(*NO) OPTIMIZE(*none)
ACTGRP(*CALLER) DATFMT(*eur) TIMFMT(*ISO) ALLOC(*STGMDL)
STGMDL(*INHERIT) THREAD(*SERIALIZE);

//**********************************************************************//
// Déclaration des fichiers                                             //
//**********************************************************************//
DCL-F GPTOFM WORKSTN ;       //Ecran principal
DCL-F ASK;                   //Table Question
DCL-F ANSWER;                //Table Réponse

//**********************************************************************//
// Déclaration des variables                                            //
//**********************************************************************//
DCL-S reponse         varchar(250);
DCL-S requet          varchar(100);
DCL-S FLD001          char(150);

//**********************************************************************//
// Déclaration programme externe                                        //
//**********************************************************************//
Dcl-Pr llm extpgm;
End-pr;

//**********************************************************************//
// Traitement pricipale                                                 //
//**********************************************************************//
EXEC SQL
  SET option commit = *none , ALWCPYDTA = *OPTIMIZE, CLOSQLCSR = *ENDMOD,
  DATFMT = *eur;

EXEC SQL
DELETE FROM ANSWER ;

Dow Not *In03;

  // Récupération
  Exec Sql
  Select ANSWER1 into :reponse From ANSWER ;
  reponse = %xlate(X'25': ' ': reponse);
  Answerd =  reponse;

  // Affichage
  Exfmt RECORD;

  if *In03;
    Leave;
  Endif;

  //Si question;
  If ASKD <> '';
    requet ='llm(f"{table_data} '+ %trim(ASKD) +'")';
    clear ASKFMT;

    // Modifie derniere enreg de la table pour changer la question de l'api
    EXEC SQL
    UPDATE ask
    SET FLD001 = :requet
    WHERE RRN(ask) = (
    SELECT MAX(RRN(ask)) FROM ask);

    //Nettoyer le fichier IFS
    EXEC SQL
    CALL QSYS2.IFS_WRITE_UTF8(
         PATH_NAME => '/home/NBOUVIER/python2.py',
         OVERWRITE => 'REPLACE',
         LINE => '');

    // Écriture dans le fichier IFS
    EXEC SQL
    DECLARE C1 CURSOR FOR
    SELECT FLD001 FROM ask;
    EXEC SQL OPEN C1;

    dow '1';
      EXEC SQL
      FETCH C1 INTO :FLD001;
      //Sortie si erreur
      if SQLCODE <> 0;
        leave;
      endif;
      //Ecriture fichier IFS
      EXEC SQL
      CALL QSYS2.IFS_WRITE_UTF8(
         PATH_NAME => '/home/NBOUVIER/python2.py',
         LINE => :FLD001 );
    enddo;

    // Fermeture
    EXEC SQL CLOSE C1;
    CLOSE ANSWER;

    //Relance api
    callp llm();
  EndIf;
EndDo;

*inlr = *on;


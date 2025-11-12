       ctl-opt dftactgrp(*no) actgrp(*caller) option(*srcstmt : *nodebugio); 
       
       //**********************************************************************//
       // Déclaration des variables                                            //
       //**********************************************************************//
       //Tableau
       dcl-s champs   varchar(100) dim(30);
       //Découpage
       dcl-s ligne    varchar(1024);
       dcl-s nbChamps int(5);
       dcl-s pos      int(5);
       dcl-s temp     varchar(1024);

       //**********************************************************************//
       // Traitement pricipale                                                 //
       //**********************************************************************//  
       EXEC SQL
       SET option commit = *none , datfmt = *iso;
       monitor;
         exec sql
         declare c1 cursor for select TMPDATA from QLCFTMP;
         exec sql open c1;

         dow sqlcode = 0;
           exec sql fetch c1 into :ligne;
           if sqlcode = 0;
              cut_data(ligne: '|': champs: nbChamps);
            endif;
         enddo;
           exec sql close c1;
           
        on-error;
        exec sql close c1;
        endmon;
       
       *inlr = *on;
       return;  
       //----------------------------------------------------------------------
       // Procédure découpage donné dans tableau
       //----------------------------------------------------------------------
      DCL-PROC cut_data;
         dcl-pi *N;
           source varchar(1024) const;       // Chaîne à découper
           delim  char(1) const;             // Délimiteur
           tab    varchar(100) dim(30);      // Tableau résultat
           nb     int(5);                    // Nombre de champs trouvés
         end-pi;

         temp = source;
         nb   = 0;

         dow %scan(delim: temp) > 0;
           pos = %scan(delim: temp);
           nb += 1;
           tab(nb) = %trim(%subst(temp: 1: pos - 1));
           temp    = %subst(temp: pos + 1);
         enddo;

         if %len(%trim(temp)) > 0;
           nb += 1;
           tab(nb) = %trim(temp);
         endif;
       END-PROC;
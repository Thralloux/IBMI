      /FREE
        ctl-opt option(*nodebugio:*srcstmt:*nounref);

        //**********************************************************/
        //* Fichiers                                               */
        //**********************************************************/
        dcl-f ETAT132 printer(132) oflind(*inof);
        Dcl-F PAYS Usage(*Input) Keyed;

        //**********************************************************/
        //* Variables                                              */
        //**********************************************************/
        dcl-s wNOMPAY char(10);
        dcl-s DATD char(16);
        //********************************************************//
        // Déclaration Tableau                                     /
        //********************************************************//
        Dcl-S TG           Char(80)   DIM(9)  CTDATA PERRCD(1);

        //**********************************************************/
        //* Options SQL                                            */
        //**********************************************************/
        exec sql
        set option commit = *none, datfmt = *eur, closqlcsr = *endmod;

        //**********************************************************/
        //* Curseur SQL                                            */
        //**********************************************************/
        exec sql
        declare c1 cursor for
        select distinct nompay from nbouvier.pays;

        exec sql open c1;

        //**********************************************************/
        //* Impression                                             */
        //**********************************************************/
        Except ENT;
        DATD = %char(%date(): *eur);

        dow (sqlcode = 0);
        exec sql fetch c1 into :wNOMPAY;
        if sqlcode = 100;
            leave;
        endif;
        // Impression donnée
        chain wNOMPAY PAYS;
        Except DET;
        // Saut de page
        if *inof;
            Except ENT;
        endif;
        enddo;

        exec sql close c1;

        *inlr = *on;
        return;

        /end-free
     OETAT132   E            ENT            2 01
     O          E            ENT            1
     O                       TG(2)
     O          E            ENT            1
     O                       TG(1)
     O          E            ENT            2
     O                       TG(2)
     O          E            ENT            2
     O                       TG(3)
     O          E            ENT            2
     O                       TG(4)
     O                       DATD                16A
     O                       TG(5)
     O          E            ENT            2
     O                       TG(6)
     O          E            ENT            1
     O                       TG(7)
     O          E            ENT            1
     O                       TG(8)
     O          E            DET            1
     O                       NOMPAY
     O                       CAPITA            +  1
     O                       POPULA            +  1
     O                       SURFAC            +  2
** TG
                    PAYS
            =====================

Date: 12/12/1234

---------- ---------- ----------  ----------
NOMPAY     CAPITALE   POPULATION  SURFACCE
---------- ---------- ----------  ----------

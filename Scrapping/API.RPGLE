        // API QMHSNDPM : Envoie les messages programme
        dcl-pr QMHSNDPM extpgm;
          msgId      char(7)   const;
          msgFile    char(20)  const;
          msgData    char(100) const options(*varsize);
          msgDataLen int(10)   const;
          msgType    char(10)  const;
          stackEntry char(10)  const;
          stackCount int(10)   const;
          msgKey     char(4);
          errorCode  varchar(100);
        end-pr;
        dcl-s msgId      char(7) inz('CPF9898');
        dcl-s msgData    varchar(100);
        dcl-s msgDataLen int(10);
        dcl-s msgKey     char(4);
        dcl-s errorCode  varchar(100);

        // API QMHRMVPM : Efface les messages programme
        dcl-pr QMHRMVPM extpgm;
          MsgQueue      Char(276)  const;
          CallStack     Int(10)    const;
          MsgKey        Char(4)    const;
          MsgRmv        Char(10)   const;
          Error         like( errorDS );
        end-pr;
        dcl-s  Rmv_Stkcnt  int(5) inz(0);
        dcl-s  Rmv_Msgkey  char(10) inz('*blanks');
        dcl-s  Rmv_Remove  char(10) inz('*ALL');
        Dcl-DS errorDS   Len(16);
          ByteProv       Int(10)    inz(%size(errorDS));
          ByteAvail      Int(10);
          ExceptionID    Char(7);
        End-DS;

        //API QCMDEXC : Exécute une commande CL
        dcl-pr QCMDEXC extpgm;
          cmd     char(300) ;
          cmdlen  packed(15:5) ;
        end-pr;
        dcl-s cmd char(300);
        dcl-s cmdLen packed(15:5);

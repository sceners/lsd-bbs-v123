Program MakeLog;

  (* this program will make the file "MAKEDAT.PAS". It will be a
     "Procedure" which is used as a include file in INIT.PAS which
     contains all of the syslog.dat information. You MUST have
     the syslog.dat file in the current directory in order to run
     this program.

                  Ken
                      *)

Uses Dos;

Var F1,F2:Text;
    L:String[80];

    Procedure CheckStuff;
    Var I:Integer;
        M:String[80];
    Begin
    M:='';
     For I:=1 to Length(L) Do
       Begin
       If L[I]=#39 then M:=M+#39;
       M:=M+L[I];
       End;
     L:=M;
     End;


Begin
  Assign(F1,'MakeDat.Pas');
  ReWrite(F1);
  Assign(F2,'SysLog.Dat');
  Reset(F2);
  WriteLn(F1,'     Procedure MakeSyslogDat;');
  WriteLn(F1,'     Var T:Text;');
  WriteLn(F1,'     Begin');
	WriteLn(F1,'        Assign(T,''SysLog.Dat'');');
  WriteLn(F1,'        ReWrite(T);');
  While Not Eof(F2) Do
    Begin
      ReadLn(F2,L);
      checkstuff;
      WriteLn(F1,'        WriteLn(T,'''+L+''');');
    End;
  WriteLn(F1,'        TextClose(T);');
  WriteLn(F1,'        WriteLn(Usr,''Finished Making Syslog.Dat File!'');');
  WriteLn(F1,'      End;');
  Close(F2);
  Close(F1);
End.
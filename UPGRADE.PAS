Program Upgrade;

Uses Dos,Crt,GenTypes,GenSubs,ConfigRt;

Var Urec:Userrec;
    Fn:File of Userrec;
    Total:Integer;
    C:Char;
    Conferences:Array [1..5] of Boolean;

Begin
  ClrScr;
	WriteLn('Upgrade program for L.S.D. BBS ver. 1.20');
	Total:=0;
  WriteLn;
  WriteLn('Press any key to start conversions');
  C:=Readkey;
  ReadConfig;
  Assign(Fn,ConfigSet.ForumDi+'Users');
  Reset(Fn);
  While Not Eof(Fn) Do
    Begin
      Read(Fn,Urec);
			Urec.MenuHighlight:=14;
			if total>0 then
				WriteLn(Total,']',urec.handle:5);
			Seek(Fn,Total);
			Write(Fn,Urec);
      Inc(Total);
    End;
  Close(Fn);
  WriteLn(Total,' users were upgraded.');
  WriteLn;
  WriteLn('Press any key to continue.');
  C:=ReadKey;
End.

{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }

unit chatstuf;        (* Chat Mode and F2 Keys *)

interface

uses crt,dos,
     gentypes,gensubs,subs1,userret,flags,mainr1,modem,windows,statret,
     configrt,ExecSwap;

function specialcommand:boolean;
procedure specialseries;
procedure chat (gotospecial:boolean);
procedure regchat;

implementation

function specialcommand:boolean;


Const Right=#205;       (* Constants used to define the arrow keys *)
      Left=#203;
      Up=#200;
      Down=#208;
      NormFore=15;      (* Color Constants *)
      NormBack=0;
      HighFore=4;
      HighBack=7;
      SwapLoc:Array[Boolean] of String[7]=('on disk','in EMS');  (* Full Mem
                                                                     Swaps *)

Var C:Char;
    Quit:Boolean;
    Major,Minor,Mainx,Mainy:Integer;

    Function ReadStri:Mstr;
    Var MM:Mstr;
    Begin
      ReadLine(MM);
      ReadStri:=MM;
    End;

    Procedure SendMsg(M:Lstr);
    Begin
      ClearBreak;
      GotoXy(MainX,MainY);
      ClrEol;
      WriteLn(M);
    End;

    Procedure SplitEm;
    Var Cnt:Integer;
    Begin
      If SplitMode then Unsplit;
      GotoXy(1,15);
      TextColor(9);
      For Cnt:=1 to 80 Do Write(Usr,'ฤ');
    End;

    Procedure ClearTop;
    Var Cnt:Integer;
    Begin
      For Cnt:=1 to 14 Do
      Begin
        GotoXy(1,Cnt);
        ClrEol;
      End;
    End;

    Procedure DrawABox(Count:Integer; Msg:Lstr); (* DrawABox(Rows,Message); *)
    Var Cnt:Integer;
    Begin
    TextColor(NormFore);
    TextBackground(NormBack);
    ClearTop;
    GotoXy(1,1);
    Write(Usr,'ฺ');
    For Cnt:=1 to 78 Do Write(Usr,'ฤ');
    Write(Usr,'ฟ');
    For Cnt:=1 to Count Do
      Begin
      GotoXy(1,1+Cnt);
      Write(Usr,'ณ');
      GotoXy(80,1+Cnt);
      Write(Usr,'ณ');
      End;
    GotoXy(1,Count+2);
    Write(Usr,'ภ');
    For Cnt:=1 to (38-(Length(Msg) div 2)) Do
     Write(Usr,'ฤ');
     Write(Usr,'[ '+Msg+' ]');
     While WhereX<80 Do Write(Usr,'ฤ');
     Write(Usr,'ู');
    End;

    Procedure DrawMain;
    Begin
      ClearTop;
      GotoXy(22,2);
      TextBackground(NormBack);
      TextColor(NormFore);
      WriteLn(Usr,'L.S.D. Online Editing Commands');
      GotoXy(15,4);
      WriteLn(Usr,'[Ret] To accept [Esc] to Exit [Arrows] to Move');
      Major:=1;
      Minor:=1;
    End;

    Procedure WriteXy(A,B:Integer; M:String);
    Begin
      GotoXy(A,B);
      Write(Usr,M);
    End;

    Procedure UpdateMajor;
    Begin
      TextBackground(NormBack);
      TextColor(NormFore);
      WriteXy(8,6,' User Editing ');
      WriteXy(22,6,' Access Flags ');
      WriteXy(36,6,' Other Commands ');
      WriteXy(52,6,' External Commands ');
      TextBackground(HighBack);
      TextColor(HighFore);
      Case Major of
        1:WriteXy(8,6,' User Editing ');
        2:WriteXy(22,6,' Access Flags ');
        3:WriteXy(36,6,' Other Commands ');
        4:WriteXy(52,6,' External Commands ');
      End;
      TextBackground(0);
      TextColor(15);
    End;

    Procedure DoUserEditing;
    Var T:Mstr;
        Tx:Integer;
        LastMinor,Cnet:Integer;

     Procedure DoTop;
     Var Cnt:Integer;
     Begin
     DrawABox(12,'L.S.D. User Editing');
     Minor:=1;
    End;

    Procedure ClearBytes(Byt:Integer);
    Var X,Y,Cnt:Integer;
    Begin
      X:=WhereX;
      Y:=WhereY;
      For Cnt:=1 to Byt Do Write(Usr,' ');
      GotoXy(X,Y);
    End;

    Procedure DrawThem;
    Begin
      TextBackGround(NormBack);
      TextColor(NormFore);
      WriteXy(4,2,'[ User #'+Strr(Unum)+' ]  ');
      WriteXy(50,2,'[ PgDn for More ]');
      Case LastMinor of
           1:Begin
              WriteXy(3,3,' Handle ');
              WriteXy(16,3,urec.handle+'         ');
             End;
           2:Begin
              WriteXy(3,4,' Name ');
              WriteXy(16,4,Urec.RealName+'           ');
             End;
           3:Begin
              WriteXy(3,5,' Level ');
              WriteXy(16,5,Strr(Urec.Level)+'    ');
             End;
           4:Begin
              WriteXy(3,6,' G-F Lvl ');
              WriteXy(16,6,Strr(Urec.Glevel)+'    ');
             End;
           5:Begin
              WriteXy(3,7,' G-F Pts ');
              WriteXy(16,7,strr(Urec.Gpoints)+'    ');
             End;
            6:Begin
               WriteXy(3,8,' File Lvl ');
               WriteXy(16,8,Strr(Urec.UDLevel)+'    ');
              End;
            7:Begin
               WriteXy(3,9,' File Pts ');
               WriteXy(16,9,strr(Urec.UDPoints)+'    ');
              End;
            8:Begin
               WriteXy(3,10,' Password ');
               WriteXy(16,10,Urec.PassWord+'    ');
              End;
            9:Begin
               WriteXy(3,11,' Phone Num ');
               WriteXy(16,11,Urec.PhoneNum+'    ');
              End;
            10:Begin
                WriteXy(3,12,' Daily Time ');
                WriteXy(16,12,strr(Urec.TimeLimits)+'    ');
               End;
            11:Begin
                WriteXy(3,13,' User Note ');
                WriteXy(16,13,Urec.UserNote);
               End;
            15:Begin
                WriteXy(57,6,' U/D Ratio ');
                WriteXy(70,6,Strr(Urec.UDRatio)+'    ');
               End;
            12:Begin
                WriteXy(57,3,' U/D K Ratio ');
                WriteXy(70,3,strr(Urec.UDKRatio)+'    ');
               End;
            13:Begin
                WriteXy(57,4,' PCR ');
                WriteXy(70,4,strr(Urec.PCRatio)+'    ');
               End;
            14:WriteXy(57,5,' Time Left ');
            16:Begin
                WriteXy(57,7,' Posts ');
                WriteXy(70,7,Strr(Urec.Nbu));
               End;
            17:Begin
                WriteXy(57,8,' Uploads ');
                WriteXy(70,8,Strr(Urec.Uploads));
               End;
            18:Begin
                WriteXy(57,9,' Downloads ');
                WriteXy(70,9,Strr(Urec.Downloads));
               End;
            19:Begin
                WriteXy(57,10,' U/L KB ');
                WriteXy(70,10,Strr(Urec.UpKay)+'k');
               End;
            20:Begin
                WriteXy(57,11,' D/L KB ');
                WriteXy(70,11,Strr(Urec.Dnkay)+'k');
               End;
            21:Begin
                WriteXy(57,12,' Calls ');
                WriteXy(70,12,Strr(Urec.NumOn));
               End;
            22:Begin
                WriteXy(57,13,' Exp Date ');
                If DateStr(Urec.ExpDate)='0/0/80' then WriteXy(70,13,'N/A      ')
                  Else
                WriteXy(70,13,DateStr(Urec.ExpDate));
               End;
            End; (* End Case *)
      TextBackGround(HighBack);
      TextColor(HighFore);
      Case Minor of
          1:WriteXy(3,3,' Handle ');
          2:WriteXy(3,4,' Name ');
          3:WriteXy(3,5,' Level ');
          4:WriteXy(3,6,' G-F Lvl ');
          5:WriteXy(3,7,' G-F Pts ');
          6:WriteXy(3,8,' File Lvl ');
          7:WriteXy(3,9,' File Pts ');
          8:WriteXy(3,10,' Password ');
          9:WriteXy(3,11,' Phone Num ');
          10:WriteXy(3,12,' Daily Time ');
          11:WriteXy(3,13,' User Note ');
          15:WriteXy(57,6,' U/D Ratio ');
          12:WriteXy(57,3,' U/D K Ratio ');
          13:WriteXy(57,4,' PCR ');
          14:WriteXy(57,5,' Time Left ');
          16:WriteXy(57,7,' Posts ');
          17:WriteXy(57,8,' Uploads ');
          18:WriteXy(57,9,' Downloads ');
          19:WriteXy(57,10,' U/L KB ');
          20:WriteXy(57,11,' D/L KB ');
          21:WriteXy(57,12,' Calls ');
          22:WriteXy(57,13,' Exp Date ');
      End;
      LastMinor:=Minor;
      TextBackground(NormBack);
      TextColor(NormFore);
    End;

    Procedure Goty(X,Y,B:Integer);
    Begin
    GotoXy(X,Y);
    ClearBytes(b);
    End;

    Procedure DoSecondPage;

      Procedure DoT;
      Begin
       DrawABox(9,'L.S.D. User Editing Page 2');
       Minor:=1;
      End;

      Procedure DrawSome;
      Begin
       TextColor(NormFore);
       TextBackground(NormBack);
       WriteXy(3,2,'[ User # '+Strr(Unum)+' ]');
       WriteXy(50,2,'[ PgUp for More ]');
       WriteXy(3,3,' Time in bank ');
       WriteXy(19,3,Strr(Urec.TimeBank));
       WriteXy(3,4,' G-File Uls ');
       WriteXy(19,4,Strr(Urec.Nup));
       WriteXy(3,5,' G-File Dls ');
       WriteXy(19,5,Strr(Urec.Ndn));
       WriteXy(3,6,' Sysop Note ');
       WriteXy(19,6,Urec.SpecialSysopNote);
       WriteXy(3,7,' Wanted Flag ');
       WriteXy(19,7,YesNo(Wanted in Urec.Config)+' ');
       WriteXy(3,8,' Macro 1 ');
       WriteXy(19,8,Urec.Macro1);
       WriteXy(3,9,' Macro 2 ');
       WriteXy(19,9,Urec.Macro2);
       WriteXy(3,10,' Macro 3 ');
       WriteXy(19,10,urec.macro3);
       TextColor(HighFore);
       TextBackground(HighBack);
       Case Minor of
         1:WriteXy(3,3,' Time in bank ');
         2:WriteXy(3,4,' G-File Uls ');
         3:WriteXy(3,5,' G-File Dls ');
         4:WriteXy(3,6,' Sysop Note ');
         5:WriteXy(3,7,' Wanted Flag ');
         6:WriteXy(3,8,' Macro 1 ');
         7:WriteXy(3,9,' Macro 2 ');
         8:WriteXy(3,10,' Macro 3 ');
       End;
       TextColor(NormFore);
       TextBackground(NormBack);
      End;

      Begin
        DoT;
        Repeat
          DrawSome;
          C:=BiosKey;
          Case C of
            Left,Up:Dec(Minor);
            Right,Down:Inc(Minor);
            #13:Begin
                GotY(19,Minor+2,37);
                Case Minor of
                 1:Begin
                    T:=ReadStri;
                    Tx:=Valu(T);
                    Urec.TimeBank:=Tx;
                    SendMsg('Your time in your time bank has been set to '+Strr(Tx));
                   End;
                 2:Begin
                    T:=ReadStri;
                    Tx:=Valu(T);
                    Urec.Nup:=Tx;
                    SendMsg('Your G-File Uploads have been set to '+Strr(Tx));
                   End;
                 3:Begin
                    T:=ReadStri;
                    Tx:=Valu(T);
                    Urec.Ndn:=Tx;
                    SendMsg('Your G-File Downloads have been set to '+Strr(Tx));
                   End;
                 4:Begin
                    T:=ReadStri;
                    If T<>'' then Urec.SpecialSysopNote:=T;
                   End;
                 5:If Wanted in Urec.Config then Urec.Config:=Urec.Config-[Wanted] Else
                    Urec.Config:=Urec.Config+[Wanted];
                 6:Begin
                    T:=ReadStri;
                    If T<>'' then Urec.Macro1:=T;
                    SendMsg('Your macro #1 has been changed to '+T);
                   End;
                 7:Begin
                    t:=readstri;
                    if t<>'' then Urec.Macro2:=T;
                    SendMsg('Your Macro #2 has been changed to '+T);
                   End;
                 8:Begin
                    t:=ReadStri;
                    If T<>'' then Urec.Macro2:=T;
                    SendMsg('Your Macro #3 has been changed to '+T);
                   End;
            End;
            c:=#0;
          End;
          End;
            If Minor=0 then Minor:=8;
            If Minor=9 then Minor:=1;
        Until C in [#27,#201];
      End;

    Begin
      DoTop;
      LastMinor :=1;
      For Cnet:=1 to 22 Do
      Begin
        Minor:=Cnet;
        Drawthem;
        End;
      Minor:=1;
      DrawThem;
      Repeat
        C:=BiosKey;
         Case C Of
           Up:Dec(Minor);
           Down:Inc(Minor);
           Right,Left:If Minor<12 then Minor:=Minor+11 Else Minor:=Minor-11;
           #209:Begin
                DoSecondPage;
                If C<>#27 then Begin
                DoTop;
                LastMinor:=1;
                For Cnet:=1 to 22 do
                 Begin
                   Minor:=Cnet;
                   DrawThem;
                   End;
                 Minor:=1;
                 DrawThem;
                 End;
           End;
           #13:Begin
               If Minor<12 Then Goty(16,Minor+2,35)
                 Else
                 Goty(70,Minor+2-11,5);
               Case Minor Of
                1:Begin
                   T:=ReadStri;
                   If T<>'' then Urec.Handle:=T;
                   SendMsg('Your Handle has been changed to '+Urec.Handle);
                  End;
                2:Begin
                   T:=ReadStri;
                   If T<>'' then Urec.RealName:=T;
                   SendMsg('Your Real Name has been Changed to '+Urec.RealName);
                  End;
                3:Begin
                   T:=ReadStri;
                   Tx:=Valu(T);
                   Urec.Level:=Tx;
                   Ulvl:=Tx;
                   SendMsg('You have been granted '+Strr(Urec.Level)+' Access.');
                  End;
                4:Begin
                   T:=ReadStri;
                   Tx:=Valu(T);
                   Urec.Glevel:=Tx;
                   SendMsg('Your G-File Level has been changed to '+Strr(Urec.Glevel));
                  End;
                5:Begin
                   T:=ReadStri;
                   Tx:=Valu(T);
                   Urec.Gpoints:=Tx;
                   SendMsg('You have been given '+Strr(Urec.Gpoints)+' G-File Points');
                  End;
                6:Begin
                   T:=ReadStri;
                   Tx:=Valu(T);
                   Urec.Udlevel:=Tx;
                   SendMsg('Your Upload/Download Level has been set to '+Strr(Urec.UdLevel));
                  End;
                7:Begin
                   T:=ReadStri;
                   Tx:=Valu(T);
                   Urec.UdPoints:=Tx;
                   SendMsg('You now have '+strr(Urec.UdPoints)+' file points.');
                  End;
                8:Begin
                   T:=ReadStri;
                   If T<>'' then Urec.Password:=T;
                   SendMsg('Your password has been changed to '+Urec.Password);
                  End;
                9:Begin
                   T:=ReadStri;
                   If T<>'' then Urec.PhoneNum:=T;
                   SendMsg('Your Phone Number has been changed to '+Urec.PhoneNum);
                  End;
                10:Begin
                    T:=ReadStri;
                    Tx:=Valu(T);
                    Urec.TimeLimits:=Tx;
                    SendMsg('Your daily time limit has been set to '+Strr(Urec.TimeLimits));
                   End;
                11:Begin
                    T:=ReadStri;
                    If T<>'' then
                      Urec.UserNote:=T;
                    SendMsg('Your Account Note has been Changed to '+Urec.UserNote);
                   End;
                15:Begin
                    T:=ReadStri;
                    Tx:=Valu(T);
                    Urec.UDRatio:=Tx;
                    SendMsg('Your minimum Upload/Download ratio has been set to '+Strr(Urec.UdRatio));
                   End;
                12:Begin
                    T:=ReadStri;
                    Tx:=Valu(T);
                    Urec.UDKRatio:=Tx;
                    SendMsg('Your minimum Upload/Download K Ratio has been set to '+Strr(urec.Udkratio));
                   End;
                13:Begin
                    T:=ReadStri;
                    Tx:=Valu(T);
                    Urec.PCRatio:=Tx;
                    SendMsg('Your minimum Post/Call Ratio has been set to '+Strr(Urec.PCRatio));
                   End;
                14:Begin
                    T:=ReadStri;
                    GotY(70,5,5);
                    SetTimeLeft(Valu(T));
                    bottomline;
                    SendMsg('You have been given '+Strr(Valu(T))+' Minutes for today.');
                   End;
                16:Begin
                    T:=ReadStri;
                    Tx:=Valu(T);
                    Urec.Nbu:=Tx;
                    SendMsg('Your POSTS have been set to '+Strr(Urec.Nbu));
                   End;
                17:Begin
                    T:=ReadStri;
                    Tx:=Valu(T);
                    Urec.Uploads:=Tx;
                    SendMsg('Your Uploads have been set to '+Strr(Urec.Uploads));
                   End;
                18:Begin
                   T:=ReadStri;
                   Tx:=Valu(T);
                   Urec.Downloads:=Tx;
                   SendMsg('Your Downloads have been set to '+Strr(Urec.Downloads));
                  End;
                19:Begin
                    T:=ReadStri;
                    Tx:=Valu(T);
                    Urec.UpKay:=Tx;
                    SendMsg('Your Upload K-Bytes have been set to '+Strr(Tx)+'k');
                   End;
                20:Begin
                    T:=ReadStri;
                    Tx:=Valu(T);
                    Urec.DnKay:=Tx;
                    SendMsg('Your Download K-Bytes have been set to '+Strr(Tx)+'k');
                   End;
                21:Begin
                    T:=ReadStri;
                    Tx:=Valu(T);
                    Urec.NumOn:=Tx;
                    SendMsg('Your total calls have been set to '+Strr(Tx));
                   End;
                22:Begin
                    T:=ReadStri;
                    If T<>'' then Begin
                      Urec.ExpDate:=DateVal(T);
                      SendMsg('Your Expiration Date has been set to '+DateStr(Urec.ExpDate));
                   End;
                End;
               End;
           End;
         End;
         If Minor=23 then Minor:=1;
         If Minor=0 then Minor:=22;
        DrawThem;
      Until C=#27;
    End;

  Procedure DoAccessFlags;

  Procedure DrawTop;
  Var Cnt:Integer;
  Begin
   DrawABox(4,'Access Flag Editing Commands');
   Minor:=1;
  End;

  Procedure GetMainConferences;

     Procedure DrawT;
     Var Cnt:Integer;
     Begin
       DrawABox(5,'Access to Main Conferences');
       Minor:=1;
     End;

   Procedure Choices;
   Var CountMe:Integer;
   Begin
    TextBackground(NormBack);
    TextColor(NormFore);
    for countme:=1 to 5 do
    Begin
      GotoXy(31,1+CountMe);
      Write(Usr,' Conference ',countme,' - ');
      if Urec.Conf[CountMe] then Write(Usr,'Yes ') else
       Write(Usr,'No  ');
    End;
    GotoXy(31,1+Minor);
    TextColor(HighFore);
    TextBackground(HighBack);
    Write(Usr,' Conference ',Minor,' - ');
    If Urec.Conf[Minor] then Write(Usr,'Yes ') else Write(Usr,'No  ');
    TextColor(NormFore);
    TextBackground(NormBack);
    End;


   Begin
     DrawT;
     Repeat
      Choices;
      C:=BiosKey;
      Case C Of
        Left,Up:Dec(Minor);
        Down,Right:Inc(Minor);
        #13:Begin
            Urec.Conf[Minor]:=Not Urec.Conf[Minor];
            If Urec.Conf[Minor] then SendMsg('You have been granted access to main conference #'+Strr(Minor))
            Else SendMsg('You have been denied access to Main Conference #'+Strr(Minor));
          End;
       End;
       If Minor>5 then Minor:=1;
       If Minor<1 then Minor:=5;
      Until C=#27;
   End;

  Procedure GetSubConferences;
  Var T:Mstr;
      Tx:Integer;

  Procedure ShowSubs;
   Var Cnt:Integer;
   Begin
     ClearTop;
     GotoXy(1,1);
     WriteLn(Usr,'                       Sub Conference Access Flags');
     Write(Usr,^M^J);
     Write(Usr,'         ');
     For Cnt:=1 to 18 do
      If Urec.Confset[Cnt]>0 then Write(Usr,Cnt,',') Else
      Write(Usr,'0,');
     Write(Usr,^M^J);
     Write(Usr,'         ');
     For Cnt:=19 to 31 Do
       If Urec.Confset[Cnt]>0 then Write(Usr,Cnt,',') Else
       Write(Usr,'0,');
     If Urec.ConfSet[32]>0 then WriteLn(Usr,'32') else writeLn(Usr,'0');
   End;

   Begin
     Repeat
       ShowSubs;
       Write(Usr,^M^J);
       Write(Usr,'Enter conference to change, or [Return] to exit:');
       T:=ReadStri;
       If T<>'' then Begin
         Tx:=Valu(T);
         If (Tx>0) and (TX<33) then
           If Urec.ConfSet[Tx]=0 then Urec.Confset[Tx]:=1 Else
           Urec.Confset[Tx]:=0;
         End;
       Until T='';
     End;


  Procedure DrawChoices;
  Begin
    TextBackGround(NormBack);
    TextColor(NormFore);
    GotoXy(15,3);
    Write(Usr,' Main Conferences ');
    GotoXy(50,3);
    Write(Usr,' Sub-Conferences ');
    GotoXy(15,4);
    Write(Usr,' Sub-Board Access ');
    GotoXy(50,4);
    Write(Usr,' Set SysOp Access ');
    TextBackground(HighBack);
    TextColor(HighFore);
    Case Minor Of
       1:Begin
          GotoXy(15,3);
          Write(Usr,' Main Conferences ');
         End;
       2:Begin
          GotoXy(50,3);
          Write(Usr,' Sub-Conferences ');
         End;
       3:Begin
         GotoXy(15,4);
         Write(Usr,' Sub-Board Access ');
        End;
       4:Begin
         GotoXy(50,4);
         Write(Usr,' Set SysOp Access ');
       End;
    End;
    TextColor(NormFore);
    TextBackground(NormBack);
  End;

  procedure getnewaccess;
  var q,bname:sstr;
      bn:integer;
      ac:accesstype;
      wasopen:boolean;
      k:char;

    function inputaccess (q:sstr):accesstype;
    begin
      inputaccess:=invalid;
      if length(q)=0 then exit;
      case upcase(q[1]) of
        'L':inputaccess:=letin;
        'B':inputaccess:=bylevel;
        'K':inputaccess:=keepout
      end
    end;

    procedure getallaccess;

      procedure setallaccess (ac:accesstype);
      var cnt:integer;
      begin
        setalluserflags (urec,ac);
        SendMsg ('Your access to all sub-boards: '+accessstr[ac]);
        writeurec
      end;

    begin
      Write (Usr,'ALL acc. ([B]y level, [L]et in, [K]eep out, or CR): ');
      Q:=ReadStri;
      ac:=inputaccess(q);
      if ac<>invalid then setallaccess(ac)
    end;

  var bd:boardrec;
  begin
    ClearTop;
    GotoXy(25,1);
    WriteLn(Usr,'Change Sub-Board Access');
    GotoXy(1,3);
    Write(Usr,'Which Sub-Board to change access for [''*''/ALL]: ');
    Bname:=ReadStri;
    if length(bname)<1 then exit;
    if bname='*' then
      begin
        getallaccess;
        exit
      end;
    opentempbdfile;
    bn:=searchboard(bname);
    if bn=-1 then
      begin
        closetempbdfile;
        Write(Usr,'No such board! Press any key..');
        k:=bioskey;
        exit
      end;
    writeln (Usr,'Board '+bname+'... Current access: '+accessstr[getuseraccflag(urec,bn)]);
    Write(Usr,'Access ([B]y level, [L]et in, [K]eep out, or [CR]: ');
    q:=readstri;
    ac:=inputaccess(q);
    if ac=invalid then begin
      closetempbdfile;
      exit
    end;
    setuseraccflag (urec,bn,ac);
    writeurec;
    closetempbdfile;
    SendMsg ('New access for sub-board '+bname+': '+accessstr[ac])
  end;

  procedure getsysopaccess;
  const sysopstr:array [false..true] of string[6]=('Normal','Sysop');
        sectionnames:array [udsysop..databasesysop] of string[20]=
          ('File transfer','Bulletin section','Voting booths',
           'E-mail section','Doors','Main menu','Databases');
  var cnt:configtype;
      x:string[10];
      n,mx:integer;
      v:boolean;
  begin
    repeat
      ClearTop;
      GotoXy(1,1);
      mx:=1;
      for cnt:=udsysop to databasesysop do begin
        write (usr,mx:3,'. ',sectionnames[cnt]);
        mx:=mx+1;
        gotoxy (25,wherey);
        writeln (usr,sysopstr[cnt in urec.config])
      end;
      write (usr,^M^J'Number to toggle [CR to exit]: ');
      readline (x);
      n:=valu(x);
      v:=(n>0) and (n<mx);
      if v then begin
        cnt:=configtype(ord(udsysop)+n-1);
        if cnt in urec.config
          then
            begin
              urec.config:=urec.config-[cnt];
              x:='denied'
            end
          else
            begin
              urec.config:=urec.config+[cnt];
              x:='granted'
            end;
        SendMsg ('You have been '+x+' sysop priveleges for the '+
                 sectionnames[cnt]+'.')
      end
    until not v;
    writeurec
  end;



  Begin
    DrawTop;
    DrawChoices;
    Repeat
     C:=BiosKey;
     Case C of
      Right,Down:Inc(Minor);
      Up,Left:Dec(Minor);
      #13:Begin
         Case Minor Of
           1:GetMainConferences;
           2:GetSubConferences;
           3:GetNewAccess;
           4:GetSysOpAccess;
         End;
         DrawTop;
         C:=#0;
         WriteUrec;
         End;
     End;
     If Minor>4 then Minor:=1;
     If Minor<1 then Minor:=4;
     DrawChoices;
    Until C=#27;
  End;

  Procedure DoOther;

    Procedure DrawT;
    Var Cnt:Integer;
    Begin
     DrawABox(4,'L.S.D. Other Commands');
     Minor:=1;
    End;

  Procedure Choices;
  Begin
    GotoXy(15,3);
    TextColor(NormFore);
    TextBackGround(NormBack);
    Write(Usr,' Hang Up On User ');
    Gotoxy(52,3);
    Write(Usr,' Nuke User ');
    GotoXy(15,4);
    Write(Usr,' Snoop Mode [ON] ');
    GotoXy(52,4);
    Write(Usr,' Snoop Mode [OFF] ');
    TextColor(HighFore);
    TextBackGround(HighBack);
    Case Minor of
      1:Begin
        GotoXy(15,3);
        Write(Usr,' Hang Up On User ');
        End;
      2:Begin
        GotoXy(52,3);
        Write(Usr,' Nuke User ');
        End;
      3:Begin
        GotoXy(15,4);
        Write(Usr,' Snoop Mode [ON] ');
      End;
      4:Begin
        GotoXy(52,4);
        Write(Usr,' Snoop Mode [OFF] ');
      End;
    End;
    TextColor(NormFore);
    TextBackground(NormBack);
  End;


  Begin
  DrawT;
  Repeat
    Choices;
    C:=BiosKey;
    Case C of
      Left,Up:Dec(Minor);
      Down,Right:Inc(Minor);
      #13:Case Minor of
         1:Begin
            SendMsg('Sorry but the BBS is going down right now!');
            ForceHangup:=True;
            HangUp;
           End;
         2:Begin
            Urec.Level:=-1;
            SendMsg('You''re Nuked BUDDY!');
            ForceHangup:=True;
            HangUp;
           End;
         3:Begin
            ModemInlock:=True;
              SetOutLock(True);
            SendMsg('All I/O to the modem is suspended');
           End;
         4:Begin
            SendMsg('All I/O to the modem is reinstated.');
            ModemInlock:=False;
              SetOutLock(False);
           End;
         End;
      End;
      If Minor>4 then Minor:=1;
      If Minor<1 then Minor:=4;
  Until C=#27;
  End;

  Procedure DoExternal;
    Procedure DrawT;
    Var Cnt:Integer;
    Begin
      DrawABox(5,'L.S.D. External Commands');
      Minor:=1;
    End;

    Procedure Choices;
    Begin
     TextColor(NormFore);
     TextBackGround(NormBack);
     GotoXy(15,3);
     Write(Usr,' Full Drop to Dos ');
     GotoXy(50,3);
     Write(Usr,' Shell to Dos ');
     GotoXy(15,4);
     Write(Usr,' Run Text Editor ');
     GotoXy(50,4);
     Write(Usr,' Run Config ');
     TextColor(HighFore);
     TextBackGround(HighBack);
     Case Minor of
       1:Begin
          GotoXy(15,3);
          Write(Usr,' Full Drop to Dos ');
          End;
       2:Begin
          GotoXy(50,3);
          Write(Usr,' Shell to Dos ');
          End;
       3:Begin
          GotoXy(15,4);
          Write(Usr,' Run Text Editor ');
          End;
       4:Begin
          GotoXy(50,4);
          Write(Usr,' Run Config ');
       End;
     End;
     TextColor(NormFore);
     TextBackground(NormBack);
    End;

  procedure gotodos (i:integer);
  var status:word;
      tmp1:integer;
      st:mstr;
  begin
    SendMsg ('[ Sysop in DOS ]');
    ansicolor(15);
    window (1,1,80,25);
    gotoxy (1,25);
    writeln (usr,^M^J^J^J);
    updateuserstats (false);
    if i=1 then begin
       clrscr; textcolor(15);
       writeln(usr,'ฎฎ L.S.D. Dos Shell ฏฏ');
       writeln(usr,'Type ''EXIT'' to return.'^M);
       tmp1:=timeleft;
       if not configset.maximumdosshell then begin
        swapvectors;
        exec(getenv('COMSPEC'),'');
        swapvectors;
       End Else Begin
         WriteLn(Usr,'Allocated ',bytesswapped,' bytes ',swaploc[EmsAllocated]);
         SwapVectors;
         Status:=ExecWithSwap(GetEnv('Comspec'),'');
         SwapVectors;
        (* End; *)
        End;
       st:=configset.forumdi;
       if st[length(st)]='\' then st[length(st)]:=#0;
       chdir(st);
       settimeleft(tmp1);
       bottomline;
       end else if i=2 then begin
     ensureclosed;
     writereturnbat;
     closeport;
     halt (4);
    end;
    ClrScr;
  end;

  procedure dotexteditor;
  begin
    if length(configset.edito)<1 then exit;
    SendMsg ('[ Sysop is loading text editor ]');
    window (1,1,80,25);
    gotoxy (1,25);
    writeln (usr,^M^J^J^J);           updateuserstats (false);
    exec(GetEnv('COMSPEC'), '/C '+configset.edito);
  end;

procedure runconfig;
var status:word;
begin
 if configset.forumdi[length(configset.forumdi)]<>'\' then configset.forumdi:=configset.forumdi+'\';
 swapvectors;
 exec(getenv('COMSPEC'), '/C CONFIG.EXE');
 swapvectors;
 readconfig;
end;


    Begin
      DrawT;
      Repeat
      Choices;
        C:=BiosKey;
        Case C Of
         Left,Up:Dec(Minor);
         Right,Down:Inc(Minor);
         #13:Case Minor of
            1:GotoDos(2);
            2:Begin
               GotoDos(1);
               Quit:=True;
              End;
            3:Begin
              DoTextEditor;
              Quit:=True;
            End;
            4:Begin
               RunConfig;
               Quit:=True;
            End;
         End;
        End;
        If Minor<1 then Minor:=4;
        If Minor>4 then Minor:=1;
      Until (C=#27) or Quit;
      BottomLine;
    End;

Begin
  ClrScr;
  GotoXy(1,20);
  WriteLn('[ Please Wait ]');
  MainX:=WhereX;
  MainY:=WhereY;
  SplitEm;
  DrawMain;
  Quit:=False;
  BufLen:=40;
  Repeat
   UpDateMajor;
   C:=BiosKey;
   Case C Of
     Right,Down:Inc(Major);
     Left,Up:Dec(Major);
     #13:Begin
        Case Major of
        1:DoUserEditing;
        2:DoAccessFlags;
        3:DoOther;
        4:DoExternal;
        End;
        C:=#0;
        DrawMain;
     End;
   End;
     If Major=0 then Major:=4;
     If Major=5 then Major:=1;
   Until (C=#27) or Quit;
   ClrScr;
   SpecialCommand:=True;
End;

procedure specialseries;
begin
  repeat until specialcommand
end;

procedure chat (gotospecial:boolean);
var k:char;
    StartedTime:Word;
    cnt,displaywid:integer;
    quit,carrierloss,fromkbd:boolean;
    baudstr,commstr:mstr;



    xsys     :byte;
    ysys     :byte;
    xusr     :byte;
    yusr     :byte;
    curcolor :byte;
    ec       :byte;
    initi    :boolean;
    linebufs :string[80];
    linebufu :string[80];

procedure init;
begin
  xsys     :=1;
  ysys     :=14;
  xusr     :=1;
  yusr     :=4;
  curcolor :=1;
  ec       :=1;
  initi    :=true;
  linebufs :='';
  linebufu :='';
  inuse:=2;
end;


procedure sendxy (x,y:byte);
begin
 write(#27+'[',y,';',x,'H');

end;


Procedure clearscre;
 var i:byte;
 begin
 for I:=4 to 22 do
  begin
   sendxy(1,i);
   write(#27'[K');
   end;
 end;


Procedure setc;
begin
   if fromkbd then ec:=urec.statcolor else ec:=urec.inputcolor;
   if curcolor<>ec then begin
   curcolor:=ec;
  end;
end;

 function parsedate (date:anystr):lstr;
const months: array[1..12] of string[3]=('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');

var m,d,y,inc,gog:sstr;
    year,month,day,dayofweek:word;
begin
 if length(date)<>8 then begin
  parsedate:=date;
  exit;
 end else
 begin
  m:=copy (date,1,2);
  d:=copy (date,4,2);
  y:=copy (date,7,2);
  gog:=months[valu(m)];
  getdate (year,month,day,dayofweek);
  inc:=copy (strr(year),1,2);
  parsedate:=gog+' '+d+' '+inc+y;
 end;
end;

 procedure midline;
 begin
   sendxy(1,13);
   write(^R'[อออออออออออออออออออออออออ'^S'[ '^P'LSD '+versionnum+' - '+parsedate(date)+^S);
   write(' ]'^R'ออออออออออออออออออออออออออ]');
   sendxy(trunc((21-length(configset.sysopnam))/2),13);
   write (^R'ต '^S+configset.sysopnam+^R' ฦ');
   sendxy(trunc((24-length(urec.handle))/2)+52,13);
   write (^R'ต '^S+urec.handle+^R' ฦ');
 end;

Procedure cle (malig:byte);
var i    :byte;
begin
if malig=0 then
begin
  for i:=14 to 22 do
 begin
	sendxy(1,i);
	write(#27'[K');
 end;
 sendxy(1,14);
 malig:=0;
end;

if malig=1 then
begin
	for i:=4 to 12 do
 begin
  sendxy(1,i);
  write(#27,'[K');
 end;
 sendxy(1,4);
 malig:=0;
end;



end;



  procedure wordwrapit(yeanea:byte);
  var cnt       :byte;
      wl        :integer;
      ww        :lstr;
      cutarea   :byte;
      done      :boolean;
  begin
   done:=false;
   cutarea:=0;
   ww:='';
   cnt:=80;
   if yeanea=0 then
     begin
      If Pos(' ',LineBufs)<=0 then Begin
        Writeln;
        LineBufs:='';
        Xsys:=1;
        Inc(Ysys);
        Exit;
      End;
    repeat
      if not done and (copy(linebufs,cnt,1)=' ') then cutarea:=cnt;
      if (cutarea>0) and not done then
        begin
        ww:=copy(linebufs,cnt+1,255);
         ansicolor(urec.statcolor);
         sendxy(cutarea,ysys);
         write(#27'[K');
         inc(ysys);
         xsys:=1;
         sendxy(xsys,ysys);
         write(copy(linebufs,cutarea+1,80-cutarea));
         xsys:=length(copy(linebufs,cutarea+1,80-cutarea))+1;
         sendxy(xsys,ysys);
         dec(ysys);
         done:=true
        end;
      dec(cnt);
     until cnt=1;
    linebufs:=ww;
   end;

   if yeanea=1 then
   begin
    If Pos(' ',LineBufu)<=0 then Begin
       Writeln;
       Inc(Yusr);
       Xusr:=0;
       LineBufu:='';
       Exit;
    End;
   done:=false;
   cutarea:=0;
   ww:='';
   cnt:=80;
    repeat
      if not done and (copy(linebufu,cnt,1)=' ') then cutarea:=cnt;
      if (cutarea>0) and not done then
        begin
        ww:=copy(linebufu,cnt+1,255);
         ansicolor(urec.inputcolor);
         sendxy(cutarea,yusr);
         write(#27'[K');
         inc(yusr);
         xusr:=1;
         sendxy(xusr,yusr);
         write(copy(linebufu,cutarea+1,80-cutarea));
         xusr:=length(copy(linebufu,cutarea+1,80-cutarea))+1;
         sendxy(xusr,yusr);
         dec(yusr);
         done:=true
        end;
      dec(cnt);
     until cnt=1;
    linebufu:=ww;
   end;

end;


 Procedure locate;
 begin
   if fromkbd then
 begin

	 if (xsys=80) and (ysys<21) then
	begin
	 wordwrapit(0);
	 inc(ysys);
	end;
	if ((ysys=21) and (xsys=80)) or (ysys>21) then
	begin
	cle(0);
	ysys:=14;
	xsys:=1;
	sendxy(xsys,ysys);
	ansicolor(urec.statcolor);
	write(linebufs);
	sendxy(80-length(linebufs)+1,ysys);
	wordwrapit(0);
	inc(ysys);
	sendxy(xsys,ysys);
 end;

  sendxy(xsys,ysys);
  inc(xsys);
 end;
   if not fromkbd then
 begin
   if (xusr=80) and (yusr<12) then
  begin
   wordwrapit(1);
   inc(yusr);
  end;
if ((yusr=12) and (xusr=80)) or (yusr>12) then
 begin
   cle(1);
   yusr:=4;
   xusr:=1;
   sendxy(xusr,yusr);
   ansicolor(urec.inputcolor);
   write(linebufu);
   sendxy(80-length(linebufu)+1,yusr);
   wordwrapit(1);
   inc(yusr);
   sendxy(xusr,yusr);
 end;

   sendxy(xusr,yusr);
   inc(xusr);
 end;
end;

  procedure instruct;
  var i:integer;
  begin
 for i:=1 to 5 do
   begin
     sendxy(1,i);
     write(#27,'[K');
	 end;
		splitscreen (2);
    top;
    clrscr;
    write (usr,'Now in Chat mode. Press [F1] to leave or [F2] for commands.');
    initi:=false;
    bottom;
    sendxy(1,4);
  end;


  procedure typedchar (k:char);



  begin

   locate;
   begin;
   if fromkbd then begin ansicolor(urec.statcolor); linebufs:=linebufs+K;
   end;
   if not fromkbd then begin ansicolor(urec.inputcolor); linebufu:=linebufu+K;
   end;
    write(k)
   end;
  end;


begin
  carrierloss:=false;
  chatmode:=false;
  writeln (^B^M);
  if wanted in urec.config then begin
    specialmsg ('(No longer wanted)');
    urec.config:=urec.config-[wanted];
    writeurec;
  end;
  if eightycols in urec.config then displaywid:=80 else displaywid:=40;
  if gotospecial then begin
    specialseries;
    exit
  end;
  clearbreak;
  nobreak:=true;
  writeln (^M^M,configset.entercha,^M^R);
  StartedTime:=TimeLeft;
  instruct;
  if not initi then
begin
   init;
   clearscre;
   midline;
end;

  quit:=false;

  repeat
    linecount:=0;
    if (not carrierloss) and (not carrier) then begin
      carrierloss:=true;
      gotoxy(1,4);
      writeln (^M'Warning: There is no carrier present.'^M)

    end;
    repeat until keyhit or (carrier and (numchars>0));
    fromkbd:=keyhit;
    ingetstr:=true;

    read (directin,k);
    if k=#127 then k:=#8;
    if requestchat
      then if requestcom
        then
          begin
            quit:=specialcommand;
            if not quit then instruct;
            clearbreak;
            nobreak:=true;
          end
        else
          begin
            unsplit;

            writeln (^M^M,configset.exitcha,^M^R);
						SetTimeLeft(StartedTime);
						bottomline;
						clearscre;
            quit:=true
          end;
    case ord(k) of
      8:begin
      if (xsys>1) and fromkbd then
       begin
          modeminlock:=true;
          if xsys>1 then dec(xsys);
          sendxy(xsys,ysys);
          write (' ');
          sendxy(xsys,ysys);
          if length(linebufs)>0 then linebufs:=copy(linebufs,1,length(linebufs)-1);
          modeminlock:=false;
        end;
      if (xusr>1) and not fromkbd then
       begin
          modeminlock:=true;
          if xusr>1 then dec(xusr);
          sendxy(xusr,yusr);
          write (' ');
          sendxy(xsys,ysys);
          if length(linebufu)>0 then linebufu:=copy(linebufu,1,length(linebufu)-1);
          modeminlock:=false;
        end;
     end;
      0:;
      13:begin
           writeln;
           bottomline;
          if fromkbd then begin
           xsys:=1;
           inc(ysys);
						 if (ysys>=21) then
							begin
								 cle(0);
									ysys:=14;
									xsys:=1;
									sendxy(xsys,ysys);
									ansicolor(urec.statcolor);
									write(linebufs);
									ysys:=15;
									xsys:=1;
							end;
					sendxy(xsys,ysys);
					linebufs:='';
					end;

          if not fromkbd then begin
           xusr:=1;
           inc(yusr);
						 if (yusr=13) then
              begin
                 cle(1);
                  yusr:=4;
                  xusr:=1;
                   ansicolor(urec.inputcolor);
                  sendxy(xusr,yusr);
                  write(linebufu);
                  yusr:=5;
                  sendxy(xusr,yusr);
              end;
            sendxy(xusr,yusr);
          linebufu:='';
          end;
         end;
      32..255:typedchar (k);
      1..31:if fromkbd and carrier then sendchar(k);
    end
  until quit;
  clearbreak
end;

Procedure regchat;
VAR k:char;
    cnt,displaywid:integer;
    StartedTime:Word;
    quit,carrierloss,fromkbd:boolean;
    linebuffer:lstr;
    l:byte absolute linebuffer;
    curcolor:byte;

  Procedure instruct;
  begin
    splitscreen (3);
    top;
    clrscr;
    write (usr,'Now in chat mode.  Press <F1> to leave or <F2> for commands.');
    bottom
  end;

  Procedure wordwrap;
  VAR cnt,wl:integer;
      ww:lstr;
  begin
    ww:='';
    cnt:=displaywid;
    while (cnt>0) and (linebuffer[cnt]<>' ') do cnt:=cnt-1;
    if cnt=0 then ww:=k else begin
      ww:=copy(linebuffer,cnt+1,255);
      wl:=length(ww)-1;
      if wl>0 then begin
        for cnt:=1 to wl do write (^H);
        for cnt:=1 to wl do write (' ')
      end
    end;
    writeln;
    ansicolor (curcolor);
    write (ww);
    linebuffer:=ww
  end;

  Procedure typedchar (k:char);
  VAR ec:byte;
  begin
    l:=l+1;
    linebuffer[l]:=k;
    if l=displaywid then wordwrap else write(k)
  end;

VAR Ch : CHAR;
    inchat:boolean;
begin
  While Keypressed DO
    Ch := ReadKey;
  Writeln(^M);
  carrierloss := false;
  chatmode := false;
  InChat := TRUE;
  writeln(^B);
  if (wanted in urec.config) AND (Ulvl < 90)  then begin
    specialmsg ('(No longer wanted)');
    urec.config:=urec.config-[wanted];
    writeurec;
  end;
  if eightycols in urec.config then displaywid:=80 else displaywid:=40;
  if length(chatreason)>0 then specialmsg ('(Chat reason: '+chatreason+')');
  chatreason:='';
  clearbreak;
  nobreak := TRUE;
  Writeln (^M^M^R,configset.entercha,^M^M);
  StartedTime:=TimeLeft;
  instruct;
  quit:=false;
  l:=0;
  curcolor:=urec.regularcolor;
  repeat
    linecount:=0;
    if (not carrierloss) and (not carrier) then begin
      carrierloss:=true;
      writeln (^M'Warning: No Carrier detected.'^M)
    end;
    repeat until keyhit or (carrier and (numchars>0));
    fromkbd:=keyhit;
    ingetstr:=true;
    curcolor:=urec.inputcolor;
    if not keyhit then read(directin,k) else begin curcolor:=urec.statcolor;
    K:=bioskey;
    if (ord(k)>127) then if ((ord(k)-128)=chatchar) then inchat:=false;
    if (ord(k)>127) then if ((ord(k)-129)=chatchar) then begin specialseries;
    inchat:=false;
    end;
    end;
    ansicolor(curcolor);
    if k=#127 then k:=#8;
    Quit := NOT Inchat;
    if quit then k:=#0;
    case ord(k) of
      8:if l>0 then begin
          write (k+' '+k);
          l:=l-1
        end;
      0:;
      13:begin
           writeln;
           bottomline;
           l:=0
         end;
      32..255:typedchar (k);
      1..31:if fromkbd and carrier then sendchar(k)
    end
  until quit;
  UnSplit;
  ClearBreak;
  Writeln(^M^M^R,configset.exitcha,^M);
  SetTimeLeft(StartedTime);
  bottomline;
End;


begin
end.

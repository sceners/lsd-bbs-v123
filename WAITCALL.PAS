{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }

unit waitcall;

interface

uses dos,crt,windows,userret,mainmenu,main,email,
		 gentypes,statret,configrt,modem,gensubs,subs1,subs2,mailret,
		 overret1,mainr1,mainr2,textret;

var wasted:minuterec;

function waitforacall:boolean;
function suporterd:boolean;

implementation

Procedure Do_Net_Mail;               (* L.S.D. NetMail Version 1.01 *)
Var NodeRec:NodeNetRec;
    CurrentNodeNumber,NumMsgs:Integer;
    Fnode:File of NodeNetRec;
    chrr:Char;
    simplex:boolean;
    jo:integer;
    finished:boolean;

  Function FindBaseName(BaseId:Byte):SStr;
  Var Board:BoardRec;
      Fbd:File of BoardRec;
      Sek:Integer;
  Begin           (* Echo should equal baseId *)
      Assign(Fbd,ConfigSet.BoardDi+'BoardDir');
      Reset(Fbd);
      Sek:=0;
      FindBaseName:='';
      Repeat
        Seek(Fbd,Sek);
        Read(Fbd,Board);
        Inc(Sek);
        If Board.Echo=BaseId then FindBaseName:=Board.ShortName;
      Until (Board.Echo=BaseId) or Eof(Fbd);
      Close(Fbd);
  End;             (* End FindBaseName *)

  Procedure SendString(S:Lstr);
  Var I:Integer;
  Begin
       For I:=1 to Length(S) Do SendChar(S[I]);
  End;     (* End Send String *)

  procedure UpDateStory(Nums:Integer; Sent,Upgraded:Boolean);
  Var T:Text;
  Begin
		appendfile(configset.forumdi+'Notices.BBS',t);
		WriteLn(T,^M^S'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
    WriteLn(T,^R'             On '+DateStr(Now)+' at '+TimeStr(Now)+' The Following Happened');
    if not Sent then WriteLn(T,^R'('+Strr(Nums)+') Messages were sent to '+NodeRec.Name)
    else WriteLn(T,^R'('+Strr(Nums)+') Messages were received from '+NodeRec.Name);
    If Upgraded then WriteLn(T,^R'An Upgrade was received with this packet!');
    WriteLn(T,^S'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'^M);
    TextClose(T);
  End;      (* End UpdateStory *)

  Procedure GetItAll;
  Var C:Char;
  Begin
			 While NumChars>0 do
				 write(usr,getchar);
	End;                    (* End GetItAll *)


  Procedure SetUpForNetMail;
  Begin
    ClrScr;
    WriteLn(Usr,'L.S.D. Netmail version 1.01 (c) 1990 TL Enterprises.');
    If Not Exist(ConfigSet.ForumDi+'NodeList.BBS') then
       Begin
         WriteLn(Usr,'We WOULD send NetMail, BUT there seems to be no one to net with. MAKE');
         WriteLn(Usr,'your NODELIST.BBS file BEFORE trying to attempt netmail!');
         EnsureClosed;
         Halt(0);
       End;      (* End If then Begin *)
    WriteLn(Usr,'First we must disable Auto-Answer!');
    SendString('ATZ'+#13);
    Delay(1500);
    GetItAll;
    SendString('ATS0=0'+#13);
    Delay(500);
    GetItAll;
    WriteLn(Usr,'Now we will go ahead and set the Extended Registers to recognize everything.');
    SendString('ATX6'+#13);
    Delay(500);
    GetItAll;
    WriteLn(Usr,'Now we will open up the Node List file.');
    Assign(Fnode,Configset.ForumDi+'NodeList.BBS');
    Reset(Fnode);
    CurrentNodeNumber:=0;
    WriteLn(Usr,'There. All done.');
  End;                  (* End SetUpForNetMail *)

  Procedure DialNodes;
  Var Packaged:Boolean;


       Function Connected:Boolean;
       Var C:Char;
           S:String;
       Begin
         Delay(9000);
         S:='';
				 While NumChars>0 Do
				 Begin
					 S:=S+getchar;
           If C=#13 then S:='';
           If Pos('[Hit Return]',S)>0 Then
           Begin
             WriteLn(Usr,'We MUST hit return!');
             SendString(#13+#13+#13+#13);
             S:='';
           End;    (* End If then *)
         End;      (* End Repeat Loop *)
         If Carrier then Connected:=True;
       End;         (* End Connected *)

   Procedure DialNode;

       Procedure PrepNetMail;
       Var Ct,Loper:Integer;
       NetPost:NetPostRec;
       FNP:File of NetPostRec;
       Bul:BulRec;
       M:Message;
       Bfile:File of BulRec;
       BaseName:SStr;
       CurBase:Byte;

       Procedure Package;
       Begin
       ClrScr;
       WriteLn(Usr,'Making NetMail Package as per request.');
       CurBase:=0;
       NumMsgs:=0;
       Assign(Fnp,Configset.NetDir+'NetMail.Pkg');
       ReWrite(Fnp);
       Loper:=0;
       While Loper<255 Do
        Begin
           Inc(Loper);
           If NodeRec.BaseSelection[Loper] Then Begin
           BaseName:=FindBaseName(Loper);
           If BaseName<>'' then Begin
           Assign(Bfile,ConfigSet.BoardDi+BaseName+'.BUL');
           Reset(Bfile);
           Ct:=0;
         While Not Eof(Bfile) Do
           Begin
             Seek(Bfile,Ct);
             Read(Bfile,Bul);
             If Bul.When>NodeRec.LastDate Then
               Begin
               Inc(NumMsgs);
               NetPost.NetIdNum:=Loper;
               NetPost.BulletinRec:=Bul;
               ReloadText(Bul.Line,M);
               NetPost.MessageRec:=M;
               Seek(Fnp,FileSize(Fnp));
               Write(Fnp,NetPost);
               End; (* If Bul.When>NodeRec.LastDate *)
             Inc(Ct);
           End;  (* End While Not Eof *)
         Close(Bfile);
         End;         (* End if basename<>'' *)
         End;         (* End if basethingie *)
       End;           (* End Loper *)
       Close(Fnp);
      End;            (* End Package *)

      Procedure ZipPackage;
      Var F:File;
      Begin
           Exec('PKZIP.EXE',Configset.NetDir+'Net.Zip '+ConfigSet.NetDir+'NetMail.Pkg');
           Assign(F,ConfigSet.NetDir+'NetMail.Pkg');
           Erase(F);
           Close(F);
      End;          (* End ZipPackage *)


      Begin
        Package;
        If NumMsgs>0 Then Begin
           ZipPackage;
           Packaged:=True;
        End;
      End;                    (* End SendOutGoing *)

       Function Call(X:Lstr):Boolean;
       Var Pre,Suf:Lstr;
           Jo:Integer;
           Finished:Boolean;

           Function Busy:Boolean;
           Var K:String;
               C:Char;
           Begin
                K:='';
								While NumChars>0 do k:=k+getchar;
                Busy:=False;
                If Pos('BUSY',K)>0 then Busy:=True;
                If Pos('NO CARRIER',K)>0 Then Busy:=True;
                If Pos('NO DIAL',K)>0 Then Busy:=True;
           End;    (* End Busy *)


       Begin
            ClrScr;
            WriteLn(Usr,'Dialing Number...');
            If X='' then Exit;
            dontanswer;
            Delay(1500);
            Pre:='';
            Suf:='';
            If Length(X)>7 then
               Begin
                    Pre:=ConfigSet.CoPre;
                    Suf:=ConfigSet.CoSuf;
               End;
            If KeyPressed then Chrr:=ReadKey;
            DoAnswer;
            Delay(1200);
            SendString('     ');
            Delay(1600);
            GetItAll;
            SendString('ATDT'+Pre+X+Suf+#13);
            Finished:=False;
            delay(1500);
            GetItAll;
            Jo:=0;
            Repeat
                  Inc(Jo);
                  Delay(10);
                  If Busy then Finished:=True;
                  If Finished then WriteLn(Usr,'Line was busy!'^M);
                  If KeyPressed then Finished:=True;
                  If KeyPressed then WriteLn(Usr,'User Abort!');
                  If Carrier then Finished:=True;
            Until Finished or (Jo>15000);
            SendString(^M);
            Call:=Carrier;
       End;         (* End Call *)


    Begin
       PrepNetMail;
       Window(1,1,80,25);
       ClrScr;
       TextColor(15);
       WriteLn(Usr,'L.S.D. NetMail Dialing '+NodeRec.Name+' @'+NodeRec.Phone);
       TextColor(11);
       WriteLn(Usr,'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
       TextColor(7);
       Window(1,3,80,25);
       Repeat
        delay(2500);
       Until Call(NodeRec.Phone) or
         (Not WithinTime(ConfigSet.NetStc,Configset.NetEnc));
    End; (* End DialNode *)

  Function SuccessfulNetMail:Boolean;
  Var T:Text;
      Received:Boolean;
      F:File;
      I:Integer;

  Procedure SendViaDSZ;
  Begin
    Exec('Dsz.Com',' port '+Strr(Configset.UseCo)+' speed '+Strr(BaudRate)+' sz -m '+Configset.NetDir+'Net.Zip');
    Assign(F,ConfigSet.NetDir+'Net.Zip');
    Erase(F);
    updatestory(NumMsgs,False,False);
    NumMsgs:=0;
  End;                   (* End SendViaDSZ *)

	Function ExecDsz:Boolean;
	var ken:char;
	Begin
			 If Exist(ConfigSet.WorkDir+'Net.Zip') then
				 Begin
					 Assign(F,ConfigSet.WorkDir+'Net.Zip');
					 Erase(F);
				 End;       (* End If Then *)
			 Delay(500);
			 GetItAll;
			 Repeat
			 Until (NumChars>0) or (Not Carrier);
       Exec('Dsz.Com',' port '+Strr(ConfigSet.UseCo)+' speed '+Strr(BaudRate)+' rz -m '+ConfigSet.WorkDir+'Net.Zip');
       ExecDsz:=True;
  End;

  Procedure ProcessIncomming;
  Var Fnp:File of NetPostRec;
      NetPost:NetPostRec;
      M:Message;
      B:BulRec;
      Bfile:File of BulRec;
      Upgrade:Boolean;


      Procedure UnZipNet;
      Var F:File;
      Begin
           SwapVectors;
           Exec(GetEnv('Comspec'),'/C Pkunzip '+ConfigSet.WorkDir+'Net.Zip -o '+ConfigSet.WorkDir);
           Assign(F,Configset.WorkDir+'Net.Zip');
           Erase(F);
           Close(F);
      End;          (* End UnZipNet *)

      Procedure PostMsgs;
      Var F:File;
          TId:Word;
          Current:Byte;
          BaseName:Sstr;
      Begin
           ClrScr;
           Upgrade:=False;
           WriteLn(Usr,'Posting NetMail Messages.');
           If Exist(ConfigSet.WorkDir+'Upgrade.Zip') then
           Begin
             Upgrade:=true;
             Exec(GetEnv('ComSpec'),'/C Copy '+ConfigSet.WorkDir+'Upgrade.Zip '+
             ConfigSet.NetType1Path+'Upgrade.Zip > NUL');
             Assign(F,ConfigSet.WorkDir+'Upgrade.Zip');
             Erase(F);
             Close(F);
           End;
           If Exist(ConfigSet.WorkDir+'NetMail.Pkg') Then
              Begin
                 Assign(Fnp,Configset.WorkDir+'NetMail.Pkg');
                 Reset(Fnp);
                 NumMsgs:=0;
                 Current:=0;
                 While Not Eof(Fnp) Do
                   Begin
                     Read(Fnp,NetPost);
                     If Current<>NetPost.NetIdNum Then Begin
                        BaseName:=FindBaseName(NetPost.NetIdNum);
                        Close(Bfile);
                        If BaseName<>'' Then Begin
                           Assign(Bfile,ConfigSet.BoardDi+BaseName+'.Bul');
                           Reset(Bfile);
                        End;   (* End if basename<>'' *)
                     End;      (* End if current<>netpost.netidnum *)
                   If NetPost.BulletinRec.Where=ConfigSet.Origin1 Then Else
                      Begin
                        Seek(Bfile,FileSize(BFile)-1);
                        Read(Bfile,B);
                        If B.Id=65535 then NetPost.BulletinRec.Id:=1 Else
                            NetPost.BulletinRec.Id:=B.Id+1;
                        B:=NetPost.BulletinRec;
                        M:=NetPost.MessageRec;
                        B.Line:=MakeText(M);
                        B.When:=Now;
                        Seek(Bfile,FileSize(Bfile));
                        Write(Bfile,B);
                        Inc(NumMsgs);
                      End;           (* End if origin is here *)
                   End;              (* End While Not Eof Do Begin *)
                 Close(Fnp);
                 Assign(F,ConfigSet.WorkDir+'NetMail.Pkg');
                 Erase(F);
                NewPosts:=NewPosts+NumMsgs;
                Gnup:=Gnup+NumMsgs;
                WriteStatus;
              End;        (* End If Exist Msgs *)
      End;                (* End PostMsgs *)


      Begin         (* Main ProcessIncomming *)
           UnZipNet;
           PostMsgs;
           UpDateStory(NumMsgs,True,Upgrade);
      End;           (* End ProcessIncomming *)

  Procedure UpDateNode;
  Begin
       NodeRec.LastDate:=Now;
       Seek(Fnode,CurrentNodeNumber);
       Write(Fnode,NodeRec);
  End;                      (* End UpDateNode *)

  Begin
       If Not Carrier And Not WithinTime(ConfigSet.NetStc,ConfigSet.NetEnc) then
          Begin
               SuccessfulNetMail:=True;
               Exit;
          End;
       If Not Connected Then
          Begin
            SuccessfulNetMail:=False;
            WriteLn(Usr,'NetMail failed.. Why???');
            HangUp;
            Delay(1600);
            Exit;
          End;   (* End Delays *)
       SuccessfulNetMail:=False;
       SendString(ConfigSet.NetPas+#13);
       Delay(500);
       GetItAll;
       SendString(NodeRec.Node+#13);
       Delay(500);
       GetItAll;
       SendString(NodeRec.Pass+#13);
       Delay(500);
       GetItAll;
       Delay(1500);
       If Not Carrier then Begin
				 Appendfile(ConfigSet.ForumDi+'Notices.BBS',t);
				 WriteLn(T,'On '+DateStr(Now)+' at '+TimeStr(Now)+' we had the wrong password');
         WriteLn(T,'when we tried to send netmail to '+NodeRec.Name);
         TextClose(T);
         SuccessfulNetMail:=True;
       End;                      (* End if not carrier *)
       If ConfigSet.NetType1 then SendString('U'+#13);
       For I:=1 to 255 Do
           Begin
                If NodeRec.BaseSelection[I] Then SendString(Strr(I)+#13);
                If NodeRec.BaseSelection[I] then GetItAll;
           End;
       SendString('0'+#13);
       Delay(500);
       GetItAll;
       If Packaged then
          Begin
               SendString('Y'+#13);
               Delay(500);
               GetItAll;
               SendString('Y'+#13); (* This is the "Yes to receive" *)
               SendViaDSZ;
          End Else            (* End if packaged *)
       Begin
         SendString('N'+#13);
         Delay(500);
         GetItAll;
         SendString('Y'+#13); (* yes to receive *)
       end;
       Delay(1500);
       If Not Carrier then Begin
          SuccessfulNetMail:=False;
          Exit;
       End;    (* If Not Carrier *)
       Received:=ExecDsz;
       HangUp;
       If Received then ProcessIncomming;
       UpDateNode;
       SuccessfulNetMail:=True;
  End;                         (* End SuccessfulNetMail *)


  Begin
       While Not Eof(Fnode) Do
       Begin
       Seek(Fnode,CurrentNodeNumber);
       Read(Fnode,NodeRec);
       Repeat
             DialNode;
       Until SuccessfulNetMail;   (* End Loop *)
       Inc(CurrentNodeNumber);
       End;      (* End While Not EofFnode *)
  End;      (* End DialNodes *)

  Procedure ExitNetMail;
  Begin
    ClrScr;
    WriteLn(Usr,'Now we''re done.. Setting back on Auto Answer.');
    DoAnswer;
    SendString('ATZ'+#13);
    Delay(2500);
    GetItAll;
    SendString('ATS0=1'+#13);
    Delay(700);
    GetItAll;
  End;

Begin
     SetUpForNetMail;
     DialNodes;
     ExitNetMail;
     EnsureClosed;
     Halt(0);
End;             (* End Do_Net_Mail *)

function suporterd:boolean;
var brated:baudratetype;
    TempSprt:Boolean;
begin
     case connectbaud of
     300:brated:=b300;
     1200:brated:=b1200;
     2400:brated:=b2400;
     4800:brated:=b4800;
     9600:brated:=b9600;
     end;
 TempSprt:=true;
 if not (brated in configset.supportedrate) and (connectbaud<9600) then begin
    TempSprt:=False;
    if configset.LockOutBaudPass<>'' then begin
     WriteStr('Enter password:');
     TempSprt:=Match(Input,Configset.LockOutBaudPass);
     End;
     If not TempSprt then writeln('Sorry, that baud rate is NOT supported!');
    delay(1500);
 end;
 Suporterd:=TempSprt;
end;

function waitforacall:boolean;

  var wscount:integer;
      ScreenColor:Byte;
      mustgetbaud,SaveScreenOn:boolean;

  procedure getansimode;
  Var T:String;
      c:char;
  Begin
    Delay(500);
    sendchar(#27);
    delay(15);
    sendchar('[');
    delay(15);
    sendchar('6');
    delay(15);
    sendchar('n');
    delay(15);
    delay(3200);
    T:='';
		While NumChars>0 do t:=t+getchar;
    If Pos('2;1R',T)>0 then
     begin
     urec.config:=urec.config+[Ansigraphics,AsciiGraphics];
     urec.statcolor:=configset.defstacolor;
     urec.regularcolor:=configset.defreg;
     urec.promptcolor:=configset.defpromp;
     urec.inputcolor:=configset.definput;
     end;
  End;

  procedure maybewritestatus;
  begin
    wscount:=wscount+1;
    if wscount>250 then begin
      writestatus;
      wscount:=0
    end
  end;

(***

  function checkforhayesreport:boolean;  { Looks for CONNECT 300 }
  var n:longint;
      q:sstr;
      p,b:integer;
      k:char;
      brate:baudratetype;
  const lookfor:sstr=#13#10'CONNECT ';
  begin
    checkforhayesreport:=false;
    if numchars=0 then exit;
    p:=1;
    q:='';
    b:=0;
    repeat
      n:=now;
      repeat until (now>n+1) or (numchars>0);
			k:=getchar;
      if (k=#13) and (length(q)>0) then begin
        val (q,b,p);
        brate:=b110;
        while (brate<=b9600) and
              ((b<>baudarray[brate])
                or (not (brate in supportedrates)))
              do brate:=succ(brate);
        if brate<=b9600 then begin
          parity:=false;
          baudrate:=b;
          checkforhayesreport:=true;
          mustgetbaud:=false;
          n:=now;
          repeat until carrier or (now>n+1)
        end;
        exit
      end;
      if p>length(lookfor) then begin
      q:=q+k;
      writeln(usr,q);
      delay(200);
      end
       else begin
        if k=lookfor[p] then p:=p+1 else begin
          b:=b+1;
          if b=2 then exit
        end
      end
    until false
  end;

***)

  procedure receivecall;
  var b:byte;
      timeout,autoswitch:integer;
      k:char;
      brate:baudratetype;
      joemam:anystr;
      brow:integer;

    procedure nextrate (var b:baudratetype);
    var ob:baudratetype;
    begin
      ob:=b;
      repeat
        b:=succ(b);
        if b>b38400 then b:=b110;
        if b=ob then exit
      until b in configset.supportedrate
    end;

    procedure disconnect;
    begin
			if carrier then hangupmodem;
      baudrate:=configset.defbaudrat;
      parity:=false;
			setparam (configset.useco,baudrate,parity);
      setupmodem
    end;

    function seconds:integer;
    var r:registers;
    begin
      r.ah:=$2c;
      intr ($21,r);
      seconds:=r.dh
    end;

	label abort,connected;
	var tempchar:char;
	begin
		local:=false;
		online:=false;
		textcolor (configset.normbotcolo);
	begin
		 matrix:='';
		 online:=true;
		 delay (200);
		if numchars>0 then begin
		matrix:=matrix+getchar;
		delay (100);
    while numchars>0 do matrix:=matrix+getchar;
		(* if (pos('CONNECT '+#10,matrix)>0) then begin
			 baudrate:=baudarray[b300];
			 goto connected;
			 end; *)
		if pos('5',matrix)>0 then begin
			 baudrate:=baudarray[b1200];
			 goto connected;
       end;
    if pos('12',matrix)>0 then begin
       baudrate:=baudarray[b1200];
       goto connected;
       end;
    if pos('24',matrix)>0 then begin
       baudrate:=baudarray[b2400];
       goto connected;
       end;
    if  pos('11',matrix)>0 then begin
       baudrate:=baudarray[b2400];
       goto connected;
       end;
    if  pos('96',matrix)>0 then begin
       baudrate:=baudarray[b9600];
       goto connected;
       end;
    if pos('19',matrix)>0 then begin
       baudrate:=baudarray[b19200];
       goto connected;
       end;
    if pos('10',matrix)>0 then begin
       baudrate:=baudarray[b2400];
       goto connected;
			 end;
			 baudrate:=baudarray[b300];
			 goto connected;
    writeln (usr,matrix);
end;
  begin
    local:=false;
    online:=false;
    textcolor (configset.normbotcolo);
    window (1,1,80,25);
    clrscr;
    window (1,1,80,23);
    if not mustgetbaud then goto connected;
    writeln;
    brate:=b110;
    parity:=false;
    timeout:=timer+2;
    repeat
      nextrate (brate);
      baudrate:=baudarray[brate];
      textcolor (configset.outlockcolo);
      textbackground (0);
      write (usr,^M^J'Trying ',baudrate,' BAUD: ');
			setparam (configset.useco,baudrate,parity);
      sendchar('[');
      delay(20);
      sendchar('H');
      delay(20);
      sendchar('i');
      delay(20);
      sendchar('t');
      delay(20);
      sendchar(' ');
      delay(20);
      sendchar('R');
      delay(20);
      sendchar('e');
      delay(20);
      sendchar('t');
      delay(20);
      sendchar('u');
      delay(20);
      sendchar('r');
      delay(20);
      sendchar('n');
      delay(20);
      sendchar(']');
      delay(20);
      sendchar(':');
			delay(20);
			repeat k:=getchar until numchars=0;
			autoswitch:=seconds+3;
			if autoswitch>59 then autoswitch:=autoswitch-60;
			repeat k:=getchar until (not carrier) or (numchars=0) or (keyhit) or
									 (timer>=timeout) or (autoswitch=seconds);
			if timer>=timeout then hangupmodem;
			if not carrier then goto abort;
      if keyhit
        then
          begin
            k:=bioskey;
            case upcase(k) of
              #13:goto connected;
              'D':goto abort;
            end
          end
        else
          begin
						if numchars>0 then begin
							b:=ord(getchar);
							write (usr,b,' received.')
						end else b:=0;
						if b<>13
							then if b=141
								then parity:=true
								else
									begin
										delay (200);
										while numchars>0 do
											b:=ord(getchar)
                  end
          end
    until (b=13) or (b=141) or (timer>timeout);
    if timer<=timeout then begin
      connected:
      totalsent:=0;
      totalrece:=0;
      connectbaud:=baudrate;
      if (configset.defbaudrat>=9600) then baudrate:=configset.defbaudrat;
			setparam(configset.useco,baudrate,parity);
			baudstr:=strr(connectbaud);
			if (connectbaud=38400) then baudstr:='38400';
			online:=true;
			urec.config:=[lowercase,linefeeds,eightycols];
			clearscr;
			textcolor(configset.normbotcolo);
			initwinds;
			writeln('Ansi Autodetection - Please Wait...');
			getansimode;
			if ansigraphics in urec.config then WriteLn(^R'Ansi Graphics Detected!')
			else WriteLn('No Ansi Graphics Detected.');
			if pos('ARQ',Matrix)>0 then BaudStr:=BaudStr+'/ARQ';
			if pos('HST',Matrix)>0 then BaudStr:=BaudStr+'/HST';
			if pos('42',Matrix)>0 then BaudStr:=BaudStr+'/V.42';
      if (baudrate=38400) then writestr(^M^R'[*] '^S'38.4K'^P' Baud Lockin Mode! '^R'[*]');
      if (baudrate=19200) then writestr(^M^R'[*] '^S'19.2K '^P'Baud Lockin Mode! '^R'[*]');
			writeln (^M^M^R'ÄÄ[ '^F'Connected at '^S,baudstr,' 8,N,1',^R' ]ÄÄ',^M);
			newcalls:=newcalls+1;
      if not suporterd then hangup;
			if carrier then exit
    end;
    abort:
    disconnect
  end;
  end;
  end;

  procedure exitprog;
  begin
		doanswer;
    window (1,1,80,25);
    textmode(co80);
    textcolor (15);
    textbackground (0);
    clrscr;
    gotoxy (1,10);
    writeln(usr,'                         L. S. D. BBS Systems v',versionnum);
    writeln(usr,'                          (c) 1990 TL Enterprises');
    writeln(usr,^M'                    Written by Ken Sallot & Justin Braatz');
    writeln(usr,'');
    writeln(usr,'     Call The Slave Den BBS at 904-376-1117 for Comments or Suggestions!');
    gotoxy(1,24);
    ensureclosed;
    closeport;
    halt(4)
  end;

  procedure checkday;
  begin
    if lastdayup<>datestr(now) then begin
      lastdayup:=datestr(now);
      numdaysup:=numdaysup+1;
      callstoday:=0;
      writestatus
    end
  end;

  procedure dotimedevent;
  var tf:text;
  begin
    window (1,1,80,25);
    clrscr;
    writeln (usr,'Executing timed event: ',configset.eventbatc);
    writeln (usr);
    assign (tf,'Door.bat');
    rewrite (tf);
    writeln (tf,configset.eventbatc);
    textclose (tf);
    timedeventdate:=datestr(now);
    ensureclosed;
    closeport;
    halt (3)
  end;

  procedure donetevent;
  var c:Char;
  begin
       window(1,1,80,25);
       clrscr;
       WriteLn(Usr,'First we must delay netmail for EXACTLY 2 Minutes.');
       delay(60000);
       delay(60000);
       if keypressed then c:=readkey;
       ClrScr;
        writeln(usr,'Executing Net Mail');
         neteventdate:=datestr(now);
         writestatus;
       do_net_mail;
  end;

  function statusscreen:char;
  const statwindx=5;
        statwindy=1;
        firstcolx=15;
        firstline=5;
        secondcolx=54;

    procedure percent (r1,r2:real);
    begin
      if (r2<1) then exit;
      r2:=round((r1/r2)*1000)/10;
      writeln (usr,r2:0:1,'%')
    end;

    procedure drawstatus;
    var totalidle,totalup,totalmins,r:real;
        tmp:integer;
    begin
      if not match(getenv('DSZLOG'),configset.dszlog) then begin
        gotoxy(12,23);
        write(usr,'[ You MUST put SET DSZLOG='+configset.dszlog+' in your KEEPUP.BAT! ]');
      end;
      tmp:=timetillevent;
      if tmp<=30 then begin
        gotoxy (23,1);
        write (usr,'[ Timed event scheduled in ',tmp,' minutes! ');
        if tmp<10 then write(usr,' ');
        write(usr,']');
        if tmp<=5 then begin
					dontanswer;
          if tmp<=2 then dotimedevent
        end
			end;
      tmp:=timetillnet;
      if length(configset.netstc)=0 then tmp:=1500;
      if tmp<=30 then begin
        gotoxy(23,1);
        write(usr,'[ Net-Mail Scheduled in ',tmp,' minutes! ');
        if tmp<10 then write(usr,' ');
        write(usr,']');
         if tmp<=5 then begin
           dontanswer;
           if tmp<=1 then donetevent;
         end
      end;
			if carrier or keyhit then exit;
      gotoxy (21,3);
      writeln (usr,callstoday,'  ');
      tmp:=elapsedtime (wasted);
      if (tmp>5) and ConfigSet.SaveScreen then Begin
         If Not SaveScreenOn then ClrScr;
         if Not SaveScreenOn then ScreenColor:=0;
         SaveScreenOn:=True;
         gotoxy(1,24);
         Inc(ScreenColor);
         If ScreenColor>15 then ScreenColor:=1;
         TextColor(ScreenColor);
         WriteLn(Usr,DateStr(Now)+' - '+TimeStr(now)+'    ');
         TextColor(0);
      End;
      gotoxy(21,7);
      write (usr,tmp);
      gotoxy (21,5);
      write (usr,numdaysup);
      r:=round(10*numcallers/numdaysup)/10;
      gotoxy(21,6);
      writeln (usr,r:0:1);
      gotoxy(65,11);
      writeln (usr,timestr(now),' ');
      gotoxy(65,12);
      write (usr,datestr(now),'  ');
      gotoxy (22,0);
      maybewritestatus
    end;

    procedure writeavail;
    var m:lstr;
    begin
      gotoxy (27,24);
      m:=sysopavailstr;
      while length(m)<15 do m:=m+' ';
      write (usr,'Chat Availability '+m);
      gotoxy (1,1)
    end;

  var cnt,numsmail:integer;
      k:char;
      tmp:mstr;
      b:byte;
      done:boolean;

    function shouldexit:boolean;
    begin
			shouldexit:=done or carrier;
    end;

    procedure handlekey (k:char; beforeabout:boolean);
    begin
      b:=ord(k)-128;
      case b of
        availtogglechar:begin
          toggleavail;
          if not beforeabout then writeavail
        end;
				120,121,122,123,124,125,126,127,128,59,60,61,62,63,64,65,66,67,68:begin
          done:=true;
          SaveScreenOn:=False;
          statusscreen:=k
        end
      end
    end;

    function interrupted (beforeabout:boolean):boolean;
    begin
			if keypressed then begin
				k:=bioskey;
				handlekey (k,beforeabout)
			end;
			done:=done or carrier;
      interrupted:=done
    end;

    procedure sendstring (x:lstr);
    var cnt:integer;
        k:char;
    begin
      for cnt:=1 to length(x) do begin
				sendchar(x[cnt]);
        delay (20);
      end;
			delay (50);
			repeat k:=getchar until numchars=0;
    end;

    procedure phonesringing;
    begin
      sendstring ('  ATA'#13)
    end;

    procedure connectcode (k:char);
    var timer:word absolute $40:$6c;
        t:word;
        k2:char;
        bd:baudratetype;
    begin
      t:=timer+18;
			repeat
      until (timer>t) or carrier or (numchars>0);
			case k of
        '1':case k2 of
              #0:bd:=b300;
              '0':bd:=b2400;
              else exit
            end;
        '5':bd:=b1200;
        else exit
      end;
      if bd in configset.supportedrate then begin
        parity:=false;
        baudrate:=baudarray[bd];
        mustgetbaud:=false;
        t:=timer+18;
				repeat until carrier or (timer>t)
      end
    end;

   procedure writefreespace;
    var r:registers; tempfree:real; lp:integer; total:real;
        csize:real;

		 function unsigned (i:integer):real;
			begin
				if i>=0 then unsigned:=i else unsigned:=65536.0+i
			end;

    begin
	total:=0;
	for lp:=3 to 15 do begin

      r.ah:=$1c;
      r.dl:=lp;
      intr ($21,r);

      if mem[r.ds:r.bx]=$f8 then begin
		  r.ah:=$36;
		  r.dl:=lp;
		  intr ($21,r);
		  csize:=unsigned(r.ax)*unsigned(r.cx);
		  tempfree:=(csize*unsigned(r.bx))/1000;
		  total:=total+tempfree/1000;
		  gotoxy(14,12);
      if total<10 then write(' ');
			write(usr,streal(total)+' megs ');
			end;

			end;
		end;

    var tempoct:integer;
  begin
    updatenodestatus('- Waiting For Call -');
		repeat k:=getchar until numchars=0;
    statusscreen:=#0;
    window(1,1,80,25);
    done:=false;
    If Not SaveScreenOn then textcolor (15);
    clrscr;
    wasted.started:=false;
    wasted.startedat:=timer;
    wasted.total:=0;
    starttimer(wasted);
    gotoxy(0,0);
    if interrupted (true) then exit;
If Not SaveScreenOn then Begin
write(usr,'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»');
write(usr,'º   Last Caller:  ³                         ³   Recent Calls:  ³               º');
write(usr,'º   Calls Today:  ³                         ³      New Posts:  ³               º');
write(usr,'º   Total Calls:  ³                         ³    New Uploads:  ³               º');
if interrupted (true) then exit;
write(usr,'º    Total Days:  ³                         ³   New Feedback:  ³               º');
write(usr,'º     Calls/Day:  ³                         ³      New Email:  ³               º');
write(usr,'º  Minutes Idle:  ³                         ³     SysOp Mail:  ³               º');
write(usr,'ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶');
if interrupted (true) then exit;
write(usr,'º                                                                              º');
write(usr,'º   ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿       ');
textcolor(12);
write(usr,' Û');
textcolor(13);
write(usr,'     Ûßßß');
TextColor(14);
write(usr,'  ÛßßÜ');
TextColor(15);
write(usr,'        ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿    º');
write(usr,'º   ³ Total Free Drive ³      ');
TextColor(12);
write(usr,'  Û');
textcolor(13);
write(usr,'     ßßßÛ');
textcolor(14);
write(usr,'  Û  Û');
textcolor(15);
write(usr,'        ³ Time:           ³    º');
write(usr,'º   ³ Space:           ³       ');
textcolor(12);
write(usr,' ßßßß');
textcolor(13);
write(usr,'  ßßßß');
textcolor(14);
write(usr,'  ßßß');
textcolor(15);
write(usr,'         ³ Date:           ³    º');
write(usr,'º   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ         ');
textcolor(11);write(usr,' Version '+versionnum);
textcolor(15);
write(usr,'          ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    º');
write(usr,'º                                   '+date+'                                   º');
if interrupted (true) then exit;
write(usr,'º                          Registered to:                                      º');
write(usr,'º                                                                              º');
write(usr,'º                                                                              º');
write(usr,'º    [');
textcolor(11);
write(usr,'Alt-A');
textcolor(15);
write(usr,'] Chat Available   [');
textcolor(11);
write(usr,'Alt-H');
textcolor(15);
write(usr,'] Hang Up Modem   [');
textcolor(11);
write(usr,'Alt');
textcolor(15);
write(usr,'][1-9] Configured    º');
write(usr,'º                                                                              º');
write(usr,'º    ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[');
textcolor(14);
write(usr,' Special Commands');
textcolor(15);
write(usr,' ]ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿    º');
write(usr,'º  ÚÄÙ  [F1] ');
textcolor(7);
write(usr,'Terminal Program');
textcolor(15);
write(usr,'   [F3] ');
textcolor(7);
write(usr,'Give Carrier');
textcolor(15);
write(usr,'   [F5]');
textcolor(7);
write(usr,' SysOp Commands');
textcolor(15);
write(usr,'   ÀÄ¿  º');
write(usr,'ÇÄÄÙ    [F2]');
textcolor(7);
write(usr,' Exit L.S.D.');
textcolor(15);write(usr,'        [F4]');
textcolor(7);
write(usr,' Read Email');
textcolor(15);write(usr,'     [F10]');
textcolor(7);
write(usr,' Local Login');
textcolor(15);
write(usr,'       ÀÄÄ¶');
write(usr,'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼');
		if interrupted (true) then exit;
    textcolor(12);
    writefreespace;
		gotoxy (1,1);
    textcolor (configset.normtopcolo);
    gotoxy(43,15);
    write(usr,registo);
    tempoct:=length(registb) div 2;
    gotoxy(39-tempoct,16);
    textcolor(11);write(usr,'® ');
    textcolor(12);write(usr,registb);
    textcolor(11);write(usr,' ¯');
    textcolor(12);
    gotoxy(21,2);
		write(usr,getlastcaller);
		gotoxy (66,7);
		numsmail:=getnummail(1)+numfeedback;
    writeln (usr,numsmail);
    gotoxy(21,4);
    write (usr,numcallers:0:0);
    gotoxy (66,2);
    writeln (usr,newcalls);
    gotoxy(66,3);
    write (usr,newposts);
    writeavail;
    gotoxy (1,1);
    gotoxy (66,4);
    writeln (usr,newuploads);
    gotoxy(66,5);
    writeln (usr,newfeedback);
    gotoxy(66,6);
    write (usr,newmail);
    End;
    repeat
      checkday;
      drawstatus;
      cnt:=0;
      repeat
				while configset.hashaye and (not carrier) and (numchars>0) do begin
				 k:=getchar;
					case k of
						'2':phonesringing;
						'1','5':connectcode (k)
					end
				end;
				cnt:=cnt+1
			until (cnt>=10000) or interrupted (false) or done
		until done
  end;

procedure alt(i:integer);
begin
window(1,1,80,25);
clrscr;
ensureclosed;
closeport;
textmode (co80);
halt(i);
end;

var k:char;
label exit;
begin
  waitforacall:=false;
  SaveScreenOn:=False;
  setparam (configset.useco,configset.defbaudrat,false);
  setupmodem;
  starttimer (numminsidle);
  wscount:=0;
  local:=false;
  clrscr;
  repeat
		doanswer;
    mustgetbaud:=true;
    k:=statusscreen;
		if carrier then begin
      receivecall;
			if carrier then goto exit;
    end;
    case ord(k)-128 of
      59:begin
              ensureclosed;
              closeport;
              alt(11);
         end;
      64:do_net_mail;
      61:begin
              sendchar('A');
              delay(20);
              sendchar('T');
              delay(20);
              sendchar('A');
              delay(20);
              sendchar(#13);
              delay(20);
       end;
       62:begin
          sendchar('A');
          delay(20);
          sendchar('T');
          delay(20);
          sendchar('H');
          delay(20);
          sendchar('1');
          delay(20);
          sendchar(' ');
          delay(20);
          sendchar('M');
          delay(20);
          sendchar('0');
          delay(20);
          sendchar(#13);
          delay(20);
          local:=true;
          online:=false;
          unum:=1;
          readurec;
          clrscr;
          settimeleft(500);
          emailmenu;
          seek(ufile,unum);
          writeurec;
          ensureclosed;
          alt(0);
          end;
       63:begin
          sendchar('A');
          delay(20);
          sendchar('T');
          delay(20);
          sendchar('H');
          delay(20);
          sendchar('1');
          delay(20);
          sendchar(' ');
          delay(20);
          sendchar('M');
          delay(20);
          sendchar('0');
          delay(20);
          sendchar(#13);
          delay(20);
          local:=true;
          online:=false;
          unum:=1;
          readurec;
          clrscr;
          settimeleft(500);
          mainsysopcommands;
          seek(ufile,unum);
          writeurec;
          ensureclosed;
          alt(0);
        end;
      120:alt(110);
      121:alt(111);
      122:alt(112);
      123:alt(113);
      124:alt(114);
      125:alt(115);
      126:alt(116);
      127:alt(117);
      128:alt(118);
      68:begin
					 doanswer;
           sendchar('A');
           delay(20);
           sendchar('T');
           delay(20);
           sendchar('H');
           delay(20);
           sendchar('1');
           delay(20);
           sendchar(' ');
           delay(20);
           sendchar('M');
           delay(20);
           sendchar('0');
           delay(20);
           sendchar(#13);
           delay(100);
           local:=true;
           online:=false;
           newfeedback:=0;
           newuploads:=0;
           newcalls:=0;
           newposts:=0;
           newmail:=0;
           writestatus;
           goto exit
         end;
    60:exitprog;
    end
  until 0=1;
  exit:
	textcolor (configset.normbotcolo);
	(*window (1,1,80,25);*)
 (*	clrscr; *)
end;

begin
end.

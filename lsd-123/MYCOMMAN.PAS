{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }

unit mycomman;

interface

uses crt,dos,
		 gentypes,configrt,modem,statret,gensubs,subs1,windows,subs2,textret,
     mailret,userret,flags,mainr1,ansiedit,lineedit,
     mainr2,overret1;

procedure nodelists;
procedure mycommand;
procedure modemstatus;
procedure localconfiguration;
procedure showsystemstatus;
procedure loozerlists;
procedure listusers;
procedure transfername;
procedure editnews;
procedure delerrlog;
procedure feedback;
procedure settime;
procedure changepwd;
procedure requestraise;
procedure leechlist;
procedure timebanks;
procedure displayrum;
procedure rumour;
function callforms:integer;
procedure makeuser;
procedure infoformhunt;
procedure donations;
procedure viewsyslog;
procedure delsyslog;
procedure showallforms;
procedure mainhelp;
procedure otherbbs;
procedure readerrlog;
procedure showad;
procedure setlastcall;
procedure removeallforms;
procedure showscreens;
Procedure showlastcallers;
Procedure JumpConference;
Procedure TopTen;
Procedure DisplayNodeInfo;
Procedure AddNews;

implementation

Procedure addnews;
		Var newline,r:Integer;
			nfile:File Of newsrec;
			ntmp,atmp:newsrec;
			numnews,cnt:Integer;
			m:message;
			t:text;
		Begin
			writehdr('Adding to the news');
			Writestr('Minimum Level to read news [1] :');
			If Input='' Then Input:='1';
			ntmp.level := Valu (input);
			Writestr('Maximum Level to read news [32767] :*');
			If Input='' Then Input:='32767';
			ntmp.maxlevel:=valu(Input);
			newline:=editor(m,false,true,'0','0');
			Ntmp.when:=now;ntmp.from:=unam;Ntmp.title:=m.title;
			ntmp.location:=newline;
			If newline<0 Then exit;
			r:=IOResult;
			Assign(nfile,'News');
			Reset(nfile);
			r:=IOResult;
			If r<>0
			Then
				Begin
					If r<>1 Then WriteLn('Error ',r,' opening news file; recreating.');
					Rewrite(nfile);
					Write(nfile,ntmp);
					numnews:=0
				End
			Else
				Begin
					numnews:=FileSize(nfile);
					For cnt:=numnews-1 Downto 0 Do
						Begin
							Seek(nfile,cnt);
							Read(nfile,atmp);
							Seek(nfile,cnt+1);
							Write(nfile,atmp)
						End;
					che;
					Seek(nfile,0);
					Write(nfile,Ntmp)
				End;
			WriteLn('News added.  News items: ',numnews+1);
			writelog(2,1,'');
			Close(nfile);
	end;

procedure mycommand;
begin
     clearscr;
     if ansigraphics in urec.config
     then begin
      blowup(1,29,22,3);write(^S);
      printxy(2,31,'L.S.D. BBS Credits');
      writeln(^M);
      blowup(4,3,74,18);write(^S);
      printxy(5,5,'The L.S.D. BBS System started when I got real tired of seeing');
      printxy(6,5,'every BBS running Emulex/2.. So I said to myself "Hey, lets write');
      printxy(7,5,'a BBS to blow them away!". The LSD Staff are:');
      printxy(8,5,'   The Slavelord - Main programmer, Main "Ideas" man.');
      printxy(9,5,'   Paradox - Asynch routines, ML programmer, miscellaneous things.');
      printxy(10,5,'   Low Rider - Menus man.');
      printxy(11,5,'   Lord Zombie - File Section (soon to come!)');
      printxy(12,5,'       If you would like a copy of the L.S.D. BBS then there is');
      printxy(13,5,'only one thing to say...');write(^R);
      printzy(14,10,'                           BEG!');
      write(^S);printxy(15,5,'   Special thanks go to Malignant Growth, The Viper, The Byter and');
      printxy(16,5,'others for their help and ideas. Remember, this is the MOST UNIQUE');
      printxy(17,5,'BBS program around. Only a few are allowed to run it! Also I need');
      printxy(18,5,'to take the time to thank The Oxidizer for his never ending pestering');
      printxy(19,5,'suggestions, and good job of beta-testing!');
      printzy(20,5,'                          LSD - The BBS with side effects!');
      writeln(^M^M);
      end
      else begin
     if not (ansigraphics in urec.config) then begin;
     writeln('L.S.D. BBS Credits');
     writeln('The L.S.D. BBS System is basically a REAL SICK concept of mine.');
     writeln('The Low Rider got involved with the program and all hell broke');
     writeln('loose.');
     writeln('    The L.S.D. BBS Staff are as follows:');
     writeln('      The Slavelord  -  Main brain dead person');
     writeln('      Low Rider      -  Cosmetics and misc. dead head');
     writeln('      Paradox        -  Async Routines And Misc. ML');
     writeln('          If you would like a copy of the L.S.D. BBS then there is');
     writeln('       only one thing to say .........  BEG!!!');
     writeln('    However we are not above bribes of money, drugs, beer, etc...');
     writeln(' Hope You Enjoy L.S.D. BBS As Much As We Do.. Call The Only L.S.D.');
     writeln(' Support Boards:');
     writeln('       The Slaveden                     The BadLands');
     writeln('       904-376-1117                     Temp-Down');
     writeln(^M'Special thanks go to the following people for their time/effort in making');
     writeln('L.S.D. BBS something special: The Oxidizer and The Viper for their Beta');
     writeln('Testing, Malignant Growth for his ideas, and The Byter for his ideas/support.');
     writeln('See ya..');
     end;
end;
end;
procedure modemstatus;
var cnt:baudratetype;

procedure ringline;
var ia:integer;
begin
write(^U);
if matrix='' then begin writeln(' - Not Available -'); exit; end;
for ia:=1 to length(matrix) do begin
if (ord(matrix[ia])<>13) and (ord(matrix[ia])<>10) then write(matrix[ia]);
end;
writeln;
end;

begin
clearbreak;
dontstop:=true;
nobreak:=true;
clearscr;
if ansigraphics in urec.config then begin
blowup(1,27,32,3);
printxy(2,29,'L.S.D. BBS '+versionnum+' Modem Status');
blowup(4,1,55,13);
printzy(4,5,'[ Modem Status ]');
printxy(5,2,' Connected Baud: ');
writeln(^U,connectbaud);
printxy(6,2,' Port Rate: ');
writeln(^U,baudrate);
printxy(7,2,' Characters Sent: ');
writeln(^U,totalsent);
printxy(8,2,' Characters Received: ');
writeln(^U,totalrece);
printxy(9,2,' Connect String: ');
ringline;
printxy(10,2,' Default Baud Rate: ');
writeln(^U,configset.defbaudrat);
printxy(11,2,' Supported Rates: ');
write(^U);
for cnt:=firstbaud to lastbaud do if (cnt in configset.supportedrate) then write(baudarray[cnt],' ');
printxy(12,2,' Download Rates: ');write(^U);
for cnt:=firstbaud to lastbaud do if (cnt in configset.downloadrate) then write(baudarray[cnt],' ');
printxy(13,2,' MNP Level: ');
write(^U);
if Connectbaud>=9600 then write('5') else write('0');
printxy(14,2,' Flow Control: ');
write(^U,'Xon/Xoff');
printxy(15,2,' Buffer Size: ');
write(^U'512 bytes');
printxy(21,0,'');
end else begin
writeln('     L.S.D. BBS '+versionnum+' Modem Status');
writeln(^M'Connect Baud :',connectbaud);
writeln('Port Rate :',baudrate);
writeln('Characters Sent :',totalsent);
writeln('Characters Received :',totalrece);
write('Connect String :');
ringline;
writeln('Default Baud Rate :',configset.defbaudrat);
write('Supported Rates :');
for cnt:=firstbaud to lastbaud do if (cnt in configset.supportedrate) then write(baudarray[cnt],' ');
writeln;
write('Download Supported Rates :');
for cnt:=firstbaud to lastbaud do if (cnt in configset.downloadrate) then write(baudarray[cnt],' ');
write('MNP Level :');
if connectbaud>=9600 then writeln('5') else writeln('0');
writeln('Flow Control :Xon/Xoff');
writeln('Buffer Size :512 bytes');
end;
end;

procedure localconfiguration;
var tp1,tp2:lstr;
    q,tp:integer;
    fn:file of configsettype;

function sellitout(t2:lstr):lstr;
begin
writestr(^P'Enter the new '^R+t2+^P' for your BBS [Ret=No Change]:');
sellitout:=input;
end;

begin
repeat
q:=menu('Local Configuration','CONFIGL','SPMTUANHFCVLQ');
case q of
 1:begin
   tp1:=sellitout('SHORTNAME');
   if (tp1<>'') then configset.shortnam:=tp1;
   writelog(21,1,configset.shortnam);
   end;
 2:begin
   tp1:=sellitout('SYSTEM PASSWORD');
    if (TP1)<>'' then configset.systempasswor:=tp1;
    writelog(21,2,configset.systempasswor);
    end;
 3:begin
    writestr(^P'Enter your new Matrix Type (0=none,1=standard,2=DOS,3=Custom) [Ret=No Change]:');
    if input<>'' then tp:=valu(input) else tp:=configset.matrixtyp;
    if (tp<0) or (tp>3) then begin
       writeln(^M'Thats an invalid range!');
       tp:=configset.matrixtyp;
    end;
    configset.matrixtyp:=tp;
    writelog(21,3,strr(configset.matrixtyp));
    end;
 4:begin
    tp1:=sellitout('SYSOP PASSWORD');
    if (tp1<>'') then configset.sysop:=tp1;
    writelog(21,4,configset.sysop);
   end;
 5:Begin
   tp1:=sellitout('TIME REFUND');
    if (tp1<>'') then tp:=valu(tp1) else tp:=configset.timepercentbac;
    configset.timepercentbac:=tp;
    writelog(21,5,strr(tp));
   end;
 6:Begin
   writestr(^P'Allow new users ? *');
   if yes then configset.privat:=false else configset.privat:=true;
   if configset.privat then writelog(21,6,'No') else writelog(21,6,'Yes');
   end;
 7:Begin
   tp1:=sellitout('NEW USER PASSWORD');
   if (tp1<>'') then configset.newuserpas:=tp1;
   if match(tp1,'N') then configset.newuserpas:='';
   writelog(21,7,configset.newuserpas);
   end;
 8:Begin
    tp1:=sellitout('LOGIN HEADER');
    if (tp1<>'') then configset.loginheade:=tp1;
    writelog(21,8,configset.loginheade);
    end;
 9:Begin
    writestr(^P'Allow feedback from the Matrix ? *');
    configset.feedmatr:=yes;
    if yes then writelog(21,9,'Yes') else writelog(21,9,'No');
   end;
 10:begin
     writestr(^P'Allow paging from the matrix ? *');
     configset.chatmatr:=yes;
     if yes then writelog(21,10,'Yes') else writelog(21,10,'No');
     end;
 11:Begin
    clearscr;
    writeln(^P'Status for '+^R+configset.longnam+^P+' registered to '+^R+registo);
    writeln;
    Tab(^P'Shortname',30);
    writeln(':'^R+configset.shortnam);
    tab(^P'Matrix type',30);
    writeln(':'^R+strr(configset.matrixtyp));
    tab(^P'Upload Time back',30);
    writeln(':'^R+strr(configset.timepercentbac));
    tab(^P'System Password',30);
    writeln(':'^R+configset.systempasswor);
    tab(^P'SysOp Password',30);
    writeln(':'^R+configset.sysop);
    tab(^P'Allow New Users',30);
    write(':'^R); if configset.privat then writeln('No') else writeln('Yes');
    tab(^P'New User Password',30);
    writeln(':'^R+configset.newuserpas);
    tab(^P'Login Header',30);
    writeln(':'^R+configset.loginheade);
    tab(^P'Allow Feedback from Matrix',30);
    write(':'^R); if configset.feedmatr then writeln('Yes') else writeln('No');
    tab(^P'Allow Chat from Matrix',30);
    write(':'^R); if configset.chatmatr then writeln('Yes') else writeln('No');
    tab(^P'Leech Week active',30);
    write(':'^R); if configset.leechwee then writeln('Yes') else writeln('No');
    end;
12:begin
   writestr(^P'Make leech week active ? *');
   configset.leechwee:=yes;
   if yes then writelog(21,11,'Yes') else writelog(21,11,'No');
   end;
end  until (q=13) or hungupon;
   writestr(^M^P'Save the new configuration ? *');
                      if not yes then exit;
                      assign(fn,configset.forumdi+'CONFIG.BBS');
                      rewrite(fn);
                      write(fn,configset);
                      close(fn);
                      writeln(^M^P'New configuration saved!');
end;


procedure showsystemstatus;
var totalused,totalidle,totalup,totaldown,totalmins,callsday:real;
		 cnt:integer;

var tp1:string[3];
begin
  totalused:=numminsused.total+elapsedtime(numminsused);
  totalidle:=numminsidle.total;
  totalup:=totalidle+numminsused.total;
  totalmins:=1440.0*(numdaysup-1.0)+timer;
  totaldown:=totalmins-totalup;
  callsday:=round(10*numcallers/numdaysup)/10;
		 ClearScr;
		 mens:=true;
		 Nobreak:=false;
		 DontStop:=True;
		 AnsiColor(Urec.StatusBoxColor);
		 BoxIt(1,1,37,3);
		 FuckXy(2,3,^P'L.S.D. version '^A+VersionNum+^P' System Status'^M);
		 AnsiColor(Urec.StatusBoxColor);
		 BoxIt(4,39,39,9);
		 FuckXy(5,41,^P'BBS Name: '^S+ConfigSet.LongNam+^M);
		 FuckXy(6,41,^P'SysOps Name: '^S+RegisTo+^M);
		 FuckXy(7,41,^P'Number of Users: '^S+Strr(NumUsers)+^M);
		 FuckXy(8,41,^P'Total Callers: '^S+StReal(NumCallers)+^M);
		 FuckXy(9,41,^P'Calls Today: '^S+Strr(CallsToday)+^M);
		 FuckXy(10,41,^P'Calls Per Day: '^S);
		 WriteLn(CallsDay:2:1);
		 AnsiColor(Urec.StatusBoxColor);
		 BoxIt(11,25,35,6);
		 FuckXy(12,42,'                 '^M);
		 FuckXy(12,33,^P'Messages Posted: '^S+StrLong(Gnup)+^M);
		 FuckXy(13,27,^P'Files Uploaded: '^S+StrLong(Gnuf)+^M);
		 FuckXy(14,27,^P'Leech Week: '^S);
		 If ConfigSet.LeechWee then WriteLn('Yes') else WriteLn('No');
		 FuckXy(15,27,^P'Total Posts/Calls: '^S+Strr(Ratio(Gnup,Trunc(NumCallers)))+^M);
		 AnsiColor(Urec.StatusBoxColor);
		 BoxIt(8,3,30,5);
		 FuckXy(11,25,'       '^M);
		 FuckXy(9,5,^P'Allow New Users: '^S);
		 If ConfigSet.Privat then WriteLn('No') else WriteLn('Yes');
		 FuckXy(10,5,^P'Time: '^S+TimeStr(Now));
		 FuckXy(11,5,^P'Date: '^S+DateStr(Now));
		 ClearBreak;
		 PrintXy(20,1,'');
end;


procedure listusers;
var cnt:integer;
    u:userrec;
begin
  if configset.listleve>ulvl then exit;
  writeln (^B'Name                         Level        Account Note');
  writeln (^N'컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴');
  if break then exit;
  for cnt:=1 to numusers do
    begin
      seek (ufile,cnt);
      read (ufile,u); che;
      if length(u.handle)>0 then begin
        tab (^S+u.handle,32);
        if break then exit;
        if ulvl>u.level-1 then tab (^P+strr(u.level),8);
        if ulvl<u.level then tab(^P+'[Priv]',8);
        if break then exit;
        writeln(^R+u.usernote);
        if break then exit
      end
    end
end;

procedure transfername;
var un,nlvl,ntime,tmp:integer;
    u:userrec;
begin
  if ulvl<configset.sysopleve then writeln(^M'You can''t do this without SysOp Access!');
  if ulvl>configset.sysopleve-1 then begin
  if tempsysop then begin
    writestr ('Disabling temporary sysop powers...');
    ulvl:=regularlevel;
    tempsysop:=false
  end;
  writestr ('Transfer to user name:');
  if length(input)=0 then exit;
  un:=lookupuser(input);
  if unum=un then begin
    writestr ('You can''t transfer to yourself!');
    exit
  end;
  if un=0 then begin
    writestr ('No such user.');
    exit
  end;
  seek (ufile,un);
  read (ufile,u);
  if ulvl<configset.sysopleve then if not checkpassword(u) then begin
    writelog (1,5,u.handle);
    exit
  end;
  writelog (1,4,u.handle);
  updateuserstats (false);
  ntime:=0;
  if datepart(u.laston)<>datepart(now) then begin
    tmp:=ulvl;
    if tmp<1 then tmp:=1;
    if tmp>100 then tmp:=100;
    ntime:=configset.usertim[tmp]
  end;
  if u.timetoday<10
    then if issysop or (u.level>=configset.sysopleve)
      then
        begin
          writestr ('The user has '+strr(u.timetoday)+' min(s) left!');
          writestr ('New time left:');
          ntime:=valu(input)
        end
      else
        if u.timetoday>0
          then writeln ('Warning: You have ',u.timetoday,' minutes left!')
          else
            begin
              writestr ('Sorry, that user doesn''t have any time left!');
              exit
            end;
  unum:=un;
  readurec;
  if ntime<>0 then begin
    urec.timetoday:=ntime;
    writeurec
  end;
 end;
end;

Procedure editnews;
  Var nn,numnews:Integer;
    nf:File Of newsrec;
    News:newsrec;
  Procedure getnn(txt:mstr);
    Begin
      writestr(^S+'News number to '+^R+txt+^S+':');
      nn:=valu(Input);
      If (nn<1) Or (nn>numnews) Then nn:=0
    End;

  Procedure delnews;
    Var cnt:Integer;
      r:Integer;
      NTmp:newsrec;
    Begin
      If nn=0 Then getnn('delete');
      If nn<>0 Then Begin
        Seek(nf,nn-1);
        Read(nf,Ntmp);che;
        deletetext(Ntmp.Location);
        numnews:=FileSize(nf)-1;
        For cnt:=nn To numnews Do
          Begin
            Seek(nf,cnt);
            Read(nf,nTmp);
            Seek(nf,cnt-1);
            Write(nf,Ntmp)
          End;
        Seek(nf,numnews);
        Truncate(nf)
      End
    End;

  Procedure listnews;
    Var cnt:Integer;
      r,sector:Integer;
      q:buffer;
      l:anystr;
      k:Char;
      Ntmp:newsrec;
    Begin
      clearbreak;
      WriteLn (^S'  News    Min    Max          Title ' ) ;
      WriteLn (^S' Number  Level  Level' ) ;
      WriteLn ;

      For cnt:=1 To numnews Do Begin
        Seek(nf,cnt-1);
        Read(nf,ntmp);
        r:=ntmp.location;
        Seek(tfile,r);
        Read(tfile,q);

        Write( Cnt:5 , '    ' , ntmp.level:5,'  ',ntmp.maxlevel:5, ' ');
        r:=1;
        k:=' ';
        l:='';
        Writeln (ntmp.title);
        If break Then exit
      End;
    End;

  Procedure viewnews;
    Var r:Integer;
      Ntmp:newsrec;
    Begin
      If nn=0 Then getnn('view');
      If nn<>0 Then Begin
        Seek(nf,nn-1);
        Read(nf,nTmp);che;
        r:=ntmp.location;
        WriteLn('News #',nn,' ''',ntmp.title,''' From :',ntmp.from);
        WriteLn('Date: ',Datestr(ntmp.when),' Level [',ntmp.level,'-',ntmp.maxlevel,']');
        WriteLn('__________________________');
        printtext(r);
        writestr(^P^M'Press [Return] to continue.*')
      End
    End;


  Procedure adddnews;
    Begin
      Close(nf);
      addnews;
      Assign(nf,'News');
      Reset(nf)
    End;

  Var q:Integer;
  Begin
    Assign(nf,'News');
    Reset(nf);
    If IOResult<>0 Then writestr('No news!  Use [A] to add some!') Else Begin
      Repeat
        numnews:=FileSize(nf);
        Write(^B^M'News entries: ',numnews);
        q:=menu('News edit','NEWS','ADLVQE');
        nn:=valu(Copy(Input,2,255));
        If (nn<1) Or (nn>numnews) Then nn:=0;
        Case q Of
          1:adddnews;
          2:delnews;
          3:listnews;
          4:viewnews;
        End;
        If numnews=0 Then Begin
          Close(nf);
          Erase(nf);
          q:=5
        End
      Until (q=5) Or hungupon
    End;
    Close(nf)
  End;



procedure delerrlog;
var e:text;
    i:integer;
begin
  writestr ('Delete error log:  Confirm:');
  if not yes then exit;
  assign (e,'errlog');
  reset (e);
  i:=ioresult;
  if ioresult=1
    then writeln (^M'No error log!')
    else begin
      textclose (e);
      erase (e);
      writestr ('Error log deleted.');
      if ioresult>1
        then writeln ('I/O error ',i,' deleting error log!');
      writelog (2,2,'')
    end
end;

procedure feedback;
var m:mailrec;
    me:message;
begin
  writestr (^P'Leave '^R+configset.Sysopnam+^P' feedback? *');
  if not yes then exit;
  m.line:=editor(me,false,true,'0','0');
  if m.line<0 then exit;
  m.title:=me.title;
  m.sentby:=unam;
  m.anon:=false;
  m.when:=now;
  addfeedback (m);
  writestr ('Feedback sent.')
end;

procedure settime;
var t:integer;
    n:longint;
    r:registers;
    d:datetime;
    ken:integer;
begin
ken:=timeleft;
  writestr ('Current time: '+timestr(now));
  writestr ('Current date: '+datestr(now));
  writestr ('Enter new time:');
  if length(input)<>0
    then begin
      t:=timeleft;
      unpacktime (timeval(input),d);
      r.ch:=d.hour;
      r.cl:=d.min;
      r.dh:=0;
      r.dl:=0;
      r.ah:=$2d;
      intr ($21,r);
      if r.al=$ff then writestr ('Invalid time!');
      settimeleft (t)
    end;
  writestr ('Enter new date:');
  if length(input)<>0
    then begin
      unpacktime (dateval(input),d);
      r.dl:=d.day;
      r.dh:=d.month;
      r.cx:=d.year;
      r.ah:=$2b;
      intr ($21,r);
      if r.al=$ff then writestr ('Invalid date!')
    end;
    settimeleft(ken);
  writelog (2,4,'')
end;

procedure changepwd;
var t:sstr;
begin
  writehdr ('Password Change');
  dots:=true;
  buflen:=15;
  write ('Enter new password: ');
  if getpassword
    then begin
      writeurec;
      writestr ('Password changed.');
      writelog (1,1,'')
    end else
      writestr ('No change.')
end;

procedure requestraise;
var t:text;
    q:lstr;
    p,l1,l2:integer;
    s1,s2:sstr;
    me:message;
    m:mailrec;
label nope,found;
begin
  assign (t,configset.textfiledi+'RAISEREQ');
  reset (t);
  if ioresult<>0 then goto nope;
  printtexttopoint (t);
  while not eof(t) do begin
    readln (t,q);
    p:=pos('-',q);
    if p>0
      then
        begin
          s1:=copy(q,1,p-1);
          s2:=copy(q,p+1,255)
        end
      else
        begin
          s1:=copy(q,1,15);
          s2:=s1
        end;
    val (s1,l1,p);
    if p=0 then val (s2,l2,p);
    if p<>0 then begin
      textclose (t);
      error ('Invalid range in RAISEREQ: %1','',q);
      exit
    end;
    if (ulvl>=l1) and (ulvl<=l2) then goto found;
    skiptopoint (t)
  end;
  nope:
  error ('No text for level %1','',strr(ulvl));
  textclose (t);
  p:=ioresult;
  exit;
  found:
  printtexttopoint (t);
  textclose (t);
  if hungupon then exit;
  m.line:=editor (me,false,true,'0','0');
  if m.line<0 then exit;
  m.anon:=false;
  m.title:='Raise request; now lvl='+strr(ulvl);
  m.sentby:=unam;
  m.when:=now;
  addfeedback (m);
end;

procedure leechlist;
var u:userrec;
    f,l:integer;
    x1,x2,x3,ud,udk:longint;
    y1,y2,y3:real;
    worsud,worsudk:longint;
    w1,w2:mstr;
    beenaborted:boolean;
begin
f:=1;
l:=numusers;
seek(ufile,f);
clearscr;
beenaborted:=false;
writehdr(' Leech List ');
writeln(^R'Name');
writeln(^U'컴컴컴컴컴컴컴컴컴컴컴컴컴컴');
w1:='Joe Leech';
w2:=w1;
worsud:=10000;
worsudk:=10000;
write(^B);
for f:=1 to l do begin
read(ufile,u);
if break then beenaborted:=true;
x1:=u.uploads;
x2:=u.downloads;
if x1<1 then x1:=1;
if x2<1 then x2:=1;
y1:=int(x1);
y2:=int(x2);
y3:=y1/y2;
y3:=y3*100;
x3:=trunc(y3);
ud:=x3;
x1:=u.upkay;
x2:=u.dnkay;
if x1<1 then x1:=1;
if x2<1 then x2:=1;
y1:=int(x1);
y2:=int(x2);
y3:=y1/y2;
y3:=y3*100;
x3:=trunc(y3);
udk:=x3;
if not beenaborted then
if ((configset.leechud>=ud) or (configset.leechk>=udk)) and (u.level<configset.exemptpc) then begin
write(^B);
writeln(u.handle);
if udk<worsudk then begin
worsudk:=udk;
w1:=u.handle;
end;
if ud<worsud then begin
worsud:=ud;
w2:=u.handle;
end;
end;
end;
writeln(^M^P'The worst offenders are:');
writeln(^R'For U/D Ratio it goes to ',w2,' with a ',worsud,'% ratio!');
writeln(^R'For U/D K it goes to ',w1,' with a ',worsudk,'% ratio!');
writeln(^M^P'If your handle is above here, you should do something to clear it up!');
end;


procedure timebanks;
var tm,tm2,tm3,tmp:integer;
    ke:string[1];
begin
if not configset.usetimebank then begin
clearscr;
writeln(^R'Sorry, but the Time Bank is closed right now!');
exit;
end;
if urec.level<configset.levelusetb then begin
clearscr;
writeln(^R'Sorry, you do not have enough access to use the time-bank!');
exit;
end;
repeat
clearscr;
writehdr(' The Time Bank ');
writeln(^M^R'You have ',timeleft,' min(s) left online today.');
writeln(^M^R'You have ',urec.timebank,' min(s) in your bank account.');
writestr(^M^P'[W]ithdraw, [D]eposit, [Q]uit :*');
ke:=upstring(input);
if match(ke,'D') then begin
  if (urec.timebank>=configset.totalallowed) then
  writeln('I''m sorry, but you already have the maximum allowed in your account!')
  else begin
  tm:=configset.totalallowed-urec.timebank;
  if tm>timeleft then tm:=timeleft;
  writestr(^P'You may deposit up to '+strr(tm)+' minutes. How much do you wish to deposit? *');
  tm2:=valu(input);
  if tm2<0 then writeln('That was invalid!') else
  if tm2>tm then writeln('Sorry, you have broken the maximum limit!') else
  if tm2>timeleft then writeln('Sorry, you don''t have that much time left!')
  else begin
     urec.timebank:=urec.timebank+tm2;
     settimeleft(timeleft-tm2);
     writeln(Tm2,' minutes have been deposited in your account!');
  end;
 end;
 end;
 if match(input,'W') then begin
  if urec.timebank<1 then writeln('I''m sorry, but you have no time in your account to withdraw!')
  else begin
    writestr(^M'You may withdraw up to '+strr(urec.timebank)+' minutes. How much to withdraw?*');
    tm:=valu(input);
    if tm<0 then writeln('Invalid choice!') else
    if tm>urec.timebank then writeln('Yes, that would be nice, but you don''t have that kind of time!')
    else  begin
    urec.timebank:=urec.timebank-tm;
    settimeleft(timeleft+tm);
    writeln(^M,tm,' minutes have been withdrawn from your account!');
    end;
  end;
  end;
  delay(500);
until match(ke,'Q') or hungupon;
end;

procedure displayrum;
var rume:rumourec;
    rumf:file of rumourec;
    sz,i:integer;
begin
if not configset.userume then exit;
assign(rumf,configset.forumdi+'RUMOUR.DAT');
reset(rumf);
if ioresult<>0 then begin
   close(rumf);
   write(^M'"L.S.D. Kickin'' it live!"');
   exit;
end;
sz:=filesize(rumf);
randomize;
i:=random(sz);
seek(rumf,i);
read(rumf,rume);
write(^M'"',rume.rum,'"');
close(rumf);
end;

procedure rumour;
var rume:rumourec;
    rumf:file of rumourec;
    fm,tu,sz,i:integer;
begin
if not configset.userume then begin
writeln(^M'Sorry, rumour section is closed!');
exit;
end;
assign(rumf,configset.forumdi+'RUMOUR.DAT');
reset(rumf);
sz:=0;
if ioresult=0 then sz:=filesize(rumf);
repeat
clearscr;
writehdr(' L.S.D. '+versionnum+' '+date+' Rumours ');
writeln(^R'[A] - Add Rumour');
writeln(^R'[L] - List Rumours');
WriteLn(^R'[D] - Delete Rumour');
writeln(^R'[Q] - Quit Rumours Section');
writestr(^M^P'Make your selection:');
if match(input,'A') then begin
if urec.level<configset.leveltoaddrume then writeln('Sorry, your access is too low!') else
 begin
  nochain:=true;
  writestr(^M^S'Enter your rumour now:');
  if input<>'' then begin
   close(rumf);
   reset(rumf);
   if ioresult<>0 then rewrite(rumf);
   seek(rumf,filesize(rumf));
   rume.rum:=input;
   rume.frm:=urec.handle;
   write(rumf,rume);
  end;
 end;
 end else
 if Match(Input,'D') then Begin
  If Exist(ConfigSet.ForumDi+'Rumour.Dat') then Begin
    ThereAre(FileSize(Rumf),'Rumours','Rumours');
    WriteStr(^M^P'Which rumour to delete:');
    If input<>'' then Begin
      fm:=Valu(Input);
      If (Fm>FileSize(Rumf)+1) or (Fm<1) then
        WriteStr(^M^S'Invalid Range!'^G^M^M^R'Press [Return]:')
      Else
      Begin
        Seek(Rumf,Fm);
        Read(Rumf,Rume);
        If (Rume.Frm<>Urec.Handle) and (not IsSysOp) then
         WriteStr(^M^S'You MAY not delete This Rumour!'^M^M^P'Press [Return]:')
         Else Begin
          sz:=Fm;
          Dec(Fm);
          For Tu:=Fm to FileSize(Rumf)-1 do
          Begin
          Seek(Rumf,Tu+1);
          Read(Rumf,Rume);
          Seek(Rumf,tu);
          Write(Rumf,Rume);
          End;
          Seek(Rumf,FileSize(Rumf)-1);
          Truncate(Rumf);
          Close(Rumf);
          Assign(Rumf,Configset.ForumDi+'Rumour.Dat');
          Reset(Rumf);
          WriteStr(^M^S'Rumour Deleted!'^M^M^P'Press [Return]:');
          End;
       End;
      End;
      End;
      End Else
 if match(input,'L') then begin
  if exist(configset.forumdi+'Rumour.dat') then begin
  thereare(filesize(rumf),'Rumours','Rumours');
  parserange(filesize(rumf),fm,tu);
  if (fm<1) or (tu>filesize(rumf)) then writeln(^M^G'Invalid range!') else begin
  clearscr;
  writeln(^R'Rumour                                                               Sent by');
  writeln(^S'컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴');
  close(rumf);
  reset(rumf);
  for i:=fm to tu do begin
  write(^S);
  write('[',I,']'^P' ');
  seek(rumf,i-1);
  read(rumf,rume);
  if length(rume.rum)>60 then Write(Copy(Rume.Rum,1,60)) Else
  tab(rume.rum,60);
  writeln(rume.frm);
 end;
 writestr(^M^R'Press '^P'[Return]:');
 end;
 end else
 writestr(^M^S'There are no rumours to list!'^M^M'Hit [Return]:');
 end;
 until (match(input,'Q')) or hungupon;
close(rumf);
end;

procedure loozerlists;
var fn:text;
    Num:Integer;
    Loozers:Array[1..500] of Mstr;
    dummystr:mstr;
    Ch:Char;

  Procedure ShowLoozers;
  Var Cnt:Integer;
  Begin
  ClearScr;
  WriteHdr('Loozer Lists');
  For Cnt:=1 to Num Do
    WriteLn(^S'[',Cnt,'] '^R+Loozers[Cnt]);
  End;

  Procedure AddLoozers;
  Begin
    WriteStr(^M^R'Enter name of Loozer to Add:');
    if Input<>'' then Begin
      Inc(Num);
      Loozers[Num]:=Input;
    End;
  End;

  Procedure DeleteLoozer;
  Var Cnt:Integer;
  Begin
    WriteStr(^M^R'Enter the # of the Loozer to Delete:');
    If (Input='') or (valu(Input)<1) or (Valu(Input)>Num) then Exit;
    If Valu(Input)=Num then  Else
      For Cnt:=Valu(Input) to Num-1 do Loozers[Cnt]:=Loozers[Cnt+1];
      Dec(Num);
    End;

  Procedure SaveLoozers;
  Var Cnt:Integer;
  Begin
   Assign(Fn,ConfigSet.TextFileDi+'BlackLst');
   ReWrite(Fn);
   For Cnt:=1 to Num Do WriteLn(Fn,Loozers[Cnt]);
   TextClose(Fn);
   End;

  Procedure ReadLoozers;
  Begin
    Assign(Fn,ConfigSet.TextFileDi+'BlackLst');
    Reset(Fn);
    Num:=0;
    While Not Eof(Fn) do
      Begin
        ReadLn(Fn,DummyStr);
        Inc(Num);
        Loozers[Num]:=DummyStr;
      End;
    TextClose(Fn);
   End;

begin
if not exist(configset.textfiledi+'Blacklst') then begin
writestr(^M+'There is no loozer list, do you wish to create one now? *');
if not yes then exit;
assign(fn,configset.textfiledi+'Blacklst');
rewrite(fn);
textclose(fn);
end;
  ReadLoozers;
  Repeat
    ShowLoozers;
    WriteStr(^M^R'[A]dd a loozer, [D]elete a Loozer, [Q]uit:');
    If Input='' then Input:='L';
    Ch:=UpCase(Input[1]);
      If Ch='A' then AddLoozers;
      If Ch='D' then DeleteLoozer;
  Until (Ch='Q') or HungUpOn;
  saveloozers;
end;

function callforms:integer;
var k:integer;
begin
callforms:=1;
clearscr;
writehdr(' Infoforms ');
writeln(^M'There are ',configset.totform,' infoform(s).');
writeln(^M^P'[1]: '^R,configset.inf1);
k:=configset.totform;
if k>1 then writeln(^P'[2]: '^R,configset.inf2);
if K>2 then writeln(^P'[3]: '^R,configset.inf3);
if k>3 then writeln(^P'[4]: '^R,configset.inf4);
if k>4 then writeln(^P'[5]: '^R,configset.inf5);
writestr(^M^P'Which infoform '^S'[1-'+strr(k)+']'^P' : [CR=1]:*');
if input='' then input:='1';
k:=valu(input);
if (k<1) or (k>configset.totform) then begin
  writeln(^G^M'Invalid range! 1 is assumed!');
  k:=1;
end;
callforms:=k;
end;

procedure nodelists;
Var Node:NodeNetRec;
    FN:File of NodeNetRec;
    I,J,CNT:Integer;
    C:Char;

    Procedure ShowNode;
    Begin
      ClearScr;
      WriteLn(^R'Node #'^S,I);
      Tab(^R+'Node Password',30);
      WriteLn(':'^S,Node.Pass);
      Tab(^R+'Node Name',30);
      WriteLn(':'^S,Node.Name);
      Tab(^R+'Node Phone Number',30);
      WriteLn(':'^S,Node.Phone);
      Tab(^R+'Node Baud Rate',30);
      WriteLn(':'^S,Node.Baud);
      Tab(^R+'Node ID Number',30);
      WriteLn(':'^S,Node.Node);
      WriteStr(^M^P'Press '^R'[Return]'^P' to see networked Bases:');
      ClearScr;
      Cnt:=1;
      Repeat
          If Node.BaseSelection[Cnt] then WriteLn('Base ID #',Cnt,' is networked!');
          Inc(Cnt);
      Until (Cnt=256) or HungUpOn;
      WriteStr(^M^P'Press '^R'[Return]:');
    End;

    Procedure DisplayNodeInformation;
    Begin
         If FileSize(Fn)=0 then Exit;
         Seek(Fn,0);
         I:=0;
         While Not Eof(Fn) do
           Begin
             Inc(I);
             Read(Fn,Node);
             ShowNode;
           End;
         WriteStr(^M^P'Press '^R'[Return]:');
    End;

    Procedure InitializeThisStuff;
    Begin
         Assign(Fn,ConfigSet.ForumDi+'NodeList.BBS');
         If Exist(ConfigSet.ForumDi+'NodeList.BBS') then Reset(FN)
            Else
         ReWrite(Fn);
    End;

    Procedure AddNode;
    Begin
         ClearScr;
         WriteHdr('Add a node');
         FillChar(Node,SizeOf(Node),0);
         WriteStr('Enter the Node Password:');
         If input='' then Exit;
         Node.Pass:=Input;
         WriteStr('Enter the Node Name:');
         If Input='' then Exit;
         Node.Name:=Input;
         WriteLn(^M^S^G'Do NOT include any "-"''s or "("''s for the phone number!'^G^M);
         WriteStr('Enter the Node Phone Number:');
         If Input='' then Exit;
         Node.Phone:=Input;
         WriteStr('Enter the Node''s Baud Rate (ex: 38400) :');
         If Input='' then Exit;
         If Input='1200' then Node.baud:=1200;
         If input='2400' then Node.baud:=2400;
         If Input='4800' then Node.baud:=4800;
         if Input='9600' then Node.Baud:=9600;
         If Input='19200' then Node.Baud:=19200;
         If Input='38400' then Node.baud:=38400;
         WriteLn(^M^S'The node ID address is your NETWORK id. It will be something like');
         WriteLn(^S'1:100, or something along those lines.'^M);
         WriteStr('Enter Node ID Address:');
         If Input='' then Exit;
         Node.Node:=Input;
         ClearScr;
         WriteLn(^S'Now we are going to pick the Base ID''s to be networked. Each message base');
         WriteLn(^S'That is networked will have a UNIQUE Base ID. This ID tells L.S.D. Which Bases');
         WriteLn(^S'to network. Enter each base ID, when you are done, enter a "0".'^M);
         Repeat
               WriteStr('Base ID:');
               I:=Valu(Input);
               If (I>0) and (I<256) then Node.BaseSelection[I]:=True
                  Else
               If I<>0 then WriteLn(^M^S^G'Invalid Range! Valid Ranges are from 1-255!'^M);
         Until (I=0) or HungUpOn;
         Write(^M'Adding Node to List...');
         Seek(Fn,FileSize(Fn));
         Write(Fn,Node);
         WriteLn('Completed!');
         WriteStr(^M^R'Press '^R'[Return]:');
    End;

    Procedure DeleteNode;
    Begin
         ClearScr;
         WriteStr('Which Node to Delete [1-'+strr(FileSize(Fn))+']:');
         I:=Valu(Input);
         If (I<1) or (I>FileSize(Fn)) then Exit;
         Write(^M'Deleting Node...');
         Dec(i);
         Cnt:=I;
         While Cnt<FileSize(Fn)-1 Do
         Begin
              Seek(Fn,Cnt+1);
              Read(Fn,Node);
              Seek(Fn,Cnt);
              Write(Fn,Node);
              Inc(Cnt);
         End;
         Seek(Fn,FileSize(Fn)-1);
         Truncate(Fn);
         Close(Fn);
         Assign(Fn,ConfigSet.ForumDi+'NodeList.BBS');
         Reset(Fn);
         WriteLn('Deleted!');
         WriteStr(^M^R'Press '^P'[Return]:');
    End;

    Procedure EditNode;
    Var NodeNum:Integer;

    Procedure GetPhoneNum;
    Begin
         ClearScr;
         WriteStr('Enter the New Phone Number:');
         If Input<>'' then Node.Phone:=Input;
    End;

    Procedure GetBaud;
    Begin
         ClearScr;
         WriteStr('Enter the NEW baud rate for this board:');
         If Input='1200' then Node.Baud:=1200
            Else
         if Input='2400' then Node.baud:=2400
            Else
         If Input='4800' then Node.Baud:=4800
            Else
         If Input='9600' then Node.Baud:=9600
            Else
         If Input='19200' then Node.baud:=19200
            Else
         If Input='38400' then Node.Baud:=38400;
    End;

    Procedure GetName;
    Begin
         ClearScr;
         WriteStr('Enter the New Node Name:');
         If Input<>'' then Node.Name:=Input;
    End;

    Procedure NodePassword;
    Begin
         ClearScr;
         WriteStr('Enter the New Node Password:');
         If Input<>'' then Node.Pass:=Input;
    End;

    Procedure NodeIdNumber;
    Begin
         ClearScr;
         WriteStr('Enter the NEW Node ID Number:');
         If Input<>'' then Node.Node:=Input;
    End;

    Procedure NetBases;
    Begin
         ClearScr;
         WriteLn(^S'To change the status of a networked base, enter the BASE ID that you wish');
         WriteLn(^S'to change. I.e. if Base 1 was networked, and you wish to not carry it anymore');
         WriteLn(^S'then you would enter a "1". Enter a "0" when you are done.'^M);
         Repeat
               WriteStr('Base ID to Change:');
               I:=Valu(Input);
               If (I>0) and (I<256) then
                  Begin
                       Node.BaseSelection[I]:=Not Node.BaseSelection[I];
                       If Node.BaseSelection[I] then Writeln('Base ID:',I,' WILL be networked.')
                       Else
                       WriteLn('Base ID:',i,' will NOT be networked.');
                  End;
         Until (I=0) or HungUpOn;
    End;

    Begin
         ClearScr;
         WriteStr('Enter the Node to Edit [1-'+strr(FileSize(Fn))+']:');
         I:=Valu(Input);
         If (I<1) or (I>FileSize(Fn)) then Else
          Begin
               Seek(Fn,I-1);
               Read(Fn,Node);
               NodeNum:=I-1;
                 Repeat
                   ClearScr;
                   WriteHdr('Node Editing');
                   WriteLn(^P'P) Phone Number'^M^P'B) Baud Rate'^M^P'N) Node Name');
                   WriteLn(^P'V) View Node'^M^P'W) Node Password'^M^P'I) Node ID Number');
                   WriteLn(^P'S) Net bases'^M^P'Q) Quit Editing'^M);
                   WriteStr('Choice:');
                   If Input='' then Input:='Q';
                   C:=UpCase(Input[1]);
                   Case C Of
                     'P':GetPhoneNum;
                     'B':GetBaud;
                     'N':GetName;
                     'V':ShowNode;
                     'W':NodePassword;
                     'I':NodeIDNumber;
                     'S':NetBases;
                   End;
                 Until (C='Q') or HungUpOn;
               Seek(Fn,NodeNum);
               Write(Fn,Node);
          End;
          C:='U';
         End;

Begin
     InitializeThisStuff;
     Repeat
           ClearScr;
           WriteHdr('Node List Maintenance');
           WriteLn(^P'S) Show All Nodes');
           WriteLn(^P'E) Edit a node');
           WriteLn(^P'D) Delete a Node');
           WriteLn(^P'A) Add a node');
           WriteLn(^P'Q) Quit Node Editor'^M);
           WriteStr('Choice:');
           If Input='' then Input:='Q';
           C:=UpCase(Input[1]);
           Case C of
             'S':DisplayNodeInformation;
             'E':EditNode;
             'D':DeleteNode;
             'A':AddNode;
           End;
     Until (C='Q') or HungUpOn;
     Close(Fn);
End;


procedure makeuser;
var u:userrec;
    un,ln,txx:integer;
begin
  writehdr ('Add a user');
  writestr ('Name:');
  if length(input)=0 then exit;
  if lookupuser(input)<>0 then begin
    writestr ('Sorry!  Already exists!');
    exit
  end;
  u.handle:=input;
  u.realname:='';
  writestr ('Password:');
  u.password:=input;
  writestr ('Level:');
  if length(input)=0 then exit;
  u.level:=valu(input);
  for txx:=1 to 32 do u.confset[txx]:=0;
  u.phonenum:='8005551212';
  u.usernote:='New User';
  un:=adduser(u);
  if un=-1 then begin
    writestr ('Sorry, no room for new users!');
    exit
  end;
  ln:=u.level;
  if ln<1 then ln:=1;
  if ln>100 then ln:=100;
  u.timetoday:=configset.usertim[ln];
  writeufile (u,un);
  writestr ('User added as #'+strr(un)+'.');
  writelog (2,8,u.handle)
end;

procedure infoformhunt;
var tp:mstr;
    info:integer;
begin
  writestr ('User to search for [CR=all users]:');
  writeln (^M);
  tp:=input;
  writestr('Infoform # view [1-5]: [1]:*');
  if input='' then input:='1';
  info:=valu(input);
  if (info>0) and (info<6) then
  showinfoforms (tp,info)
end;

procedure donations;
var fn:lstr;
begin
  fn:=configset.textfiledi+'Donation';
  if exist (fn)
    then printfile (fn)
    else begin
      writestr ('I''m sorry, no information is currently available.');
      if issysop
        then writestr (
'Sysop:  To create donation information text, make a file called '+fn)
    end
end;

procedure viewsyslog;
var n:integer;
    l:logrec;

  function lookupsyslogdat (m,s:integer):integer;
  var cnt:integer;
  begin
    for cnt:=1 to numsyslogdat do with syslogdat[cnt] do
      if (menu=m) and (subcommand=s) then begin
        lookupsyslogdat:=cnt;
        exit
      end;
    lookupsyslogdat:=0
  end;

  function firstentry:boolean;
  begin
    firstentry:=(l.menu=0) and (l.subcommand in [1..2])
  end;

  procedure backup;
  begin
    while n<>0 do begin
      n:=n-1;
      seek (logfile,n);
      read (logfile,l);
      if firstentry then exit
    end;
    n:=-1
  end;

  procedure showentry (includedate:boolean);
  var q:String;
      p:integer;
  begin
    q:=^S+'[ '+^R+syslogdat[lookupsyslogdat(l.menu,l.subcommand)].text;
    p:=pos('%',q);
    if p<>0 then q:=copy(q,1,p-1)+l.param+copy(q,p+1,255);
    repeat
      q:=q+'.';
    until length(q)>48;
    q:=q+^S+' ]   '+^P+'[ '+^A;
    if includedate then q:=q+datestr(l.when)+' at '+TimeStr(L.When)+^P' ]'
    Else
    q:=q+timestr(l.when)+^P+' ]';
    writeln (q)
  end;

var b:boolean;
begin
  writehdr ('View system log');
  writeln ('Press space to advance to the previous caller, X to abort.');
  writeln;
  writelog (2,6,'');
  n:=filesize(logfile);
  repeat
    clearbreak;
    writeln (^M);
    backup;
    if n=-1 then exit;
    seek (logfile,n);
    read (logfile,l);
    showentry (true);
    b:=false;
    while not (eof(logfile) or break or xpressed or b) do begin
      read (logfile,l);
      b:=firstentry;
      if not b then showentry (false);
    end
  until xpressed
end;

procedure delsyslog;
begin
  writestr ('Delete system log: Confirm:');
  if not yes then exit;
  if (not local) then begin
    writeln(^M'You may only delete the System log locally!'^M);
    exit;
  end;
  close (logfile);
  rewrite (logfile);
  writeln (^M'System log deleted.');
  writelog (2,7,unam)
end;

procedure showallforms;
var info:integer;
begin
  writestr('Which infoform to view [1-5]: [1]:*');
  if input='' then input:='1';
  info:=valu(input);
  if (info>0) and (info<6) then
  showinfoforms ('',info)
end;

procedure mainhelp;
begin
  help ('Mainmenu.hlp')
end;

procedure otherbbs;
var ttfn:file of bbsrec;
    bs:bbsrec;
begin
  clearscr;
  writeln('BBS Listings'^M);
  writestr(^P'['^R'L'^P'] List or ['^R'A'^P'] Add : *');
  case upcase(input[1]) of
   'A':begin
            clearscr;
            writeln('Add to BBS list'^M^M);
            writestr('Enter BBS Name :*');
            if input='' then exit;
            bs.name:=input;
            writestr('Enter BBS Baud Rate (i.e. 1200,2400,9600,19.2,38.4) :*');
            if input='' then exit;
            bs.baud:=input;
            writestr('Enter BBS Phone Number :*');
            if input='' then exit;
            bs.phone:=input;
            writestr('Enter BBS Board Type :*');
            if input='' then exit;
            bs.typbbs:=input;
            clearscr;
            tab(bs.name,36);
            tab(bs.phone,14);
            tab(bs.baud,6);
            write(bs.typbbs);
            writestr(^M^M'Is this correct? *');
            if not yes then exit;
            assign(ttfn,configset.forumdi+'BBS.DAT');
            reset(ttfn);
            seek(ttfn,filesize(ttfn));
            write(ttfn,bs);
            close(ttfn);
            end;
   'L':begin
        assign(ttfn,configset.forumdi+'BBS.DAT');
        clearscr;
        writeln(^P'BBS Name                            Phone Number  Baud  Type');
        writeln(^R'컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�');
        reset(ttfn);
        while not eof(ttfn) do begin
        read(ttfn,bs);
        write(^I);
        tab(bs.name,36);
        write(^S);
        tab(bs.phone,14);
        write(^P);
        tab(bs.baud,6);
        write(^R);
        writeln(bs.typbbs);
        end;
      close(ttfn);
      writeln(^M);
    end;
   end;
end;

procedure readerrlog;
begin
  if exist (configset.forumdi+'Errlog')
    then printfile (configset.forumdi+'Errlog')
    else writestr ('No error file!')
end;

procedure showad;
var fn:lstr;
begin
  fn:=configset.textfiledi+'LSD.AD';
  if exist (fn) then printfile (fn)
end;

procedure setlastcall;

  function digit (k:char):boolean;
  begin
    digit:=ord(k) in [48..57]
  end;

  function validtime (inp:sstr):boolean;
  var c,s,l:integer;
      d1,d2,d3,d4:char;
      ap,m:char;
  begin
    validtime:=false;
    l:=length(inp);
    if (l<7) or (l>8) then exit;
    c:=pos(':',inp);
    if c<>l-5 then exit;
    s:=pos(' ',inp);
    if s<>l-2 then exit;
    d2:=inp[c-1];
    if l=7
      then d1:='0'
      else d1:=inp[1];
    d3:=inp[c+1];
    d4:=inp[c+2];
    ap:=upcase(inp[s+1]);
    m:=upcase(inp[s+2]);
    if d1='1' then if d2>'2' then d2:='!';
    if (d1>='0') and (d1<='1') and digit(d2) and (d3>='0') and (d3<='5')
       and digit(d4) and ((ap='A') or (ap='P')) and (m='M')
         then validtime:=true
  end;

  function validdate (inp:sstr):boolean;
  var k,l:char;

    function gchar:char;
    begin
      if length(inp)=0 then begin
        gchar:='?';
        exit
      end;
      gchar:=inp[1];
      delete (inp,1,1)
    end;

  begin
    validdate:=false;
    k:=gchar;
    l:=gchar;
    if not digit(k) then exit;
    if l='/'
      then if k='0'
        then exit
        else
      else begin
        if k>'1' then exit;
        if not digit(l) then exit;
        if (l>'2') and (k='1') then exit;
        l:=gchar;
        if l<>'/' then exit
      end;
    k:=gchar;
    l:=gchar;
    if l='/'
      then if k='0'
        then exit
        else
      else begin
        if k>'3' then exit;
        if not digit(l) then exit;
        if (k='3') and (l>'1') then exit;
        l:=gchar;
        if l<>'/' then exit
      end;
    if digit(gchar) and digit(gchar) then validdate:=true
  end;

begin
  writeln (^M'Your last call was: '^S,datestr(laston),' at ',timestr(laston));
  writestr (^M'Enter new date (mm/dd/yy):');
  if length(input)>0
    then if validdate (input)
      then laston:=dateval(input)+timepart(laston)
      else writestr ('Invalid date!');
  writestr (^M'Enter new time (hh:mm am/pm):');
  if length(input)>0
    then if validtime(input)
      then laston:=timeval(input)+datepart(laston)
      else writestr ('Invalid time!')
end;

procedure removeallforms;
var cnt,ndel:integer;
    u:userrec;
begin
  writestr ('Erase ALL info-forms:  Are you sure? *');
  if not yes then exit;
  writeurec;
  writestr (^M'Erasing... please stand by...');
  ndel:=0;
  for cnt:=1 to numusers do begin
    if (cnt mod 10)=0 then write (cnt,', ');
    seek (ufile,cnt);
    read (ufile,u);
    if u.infoform>=0 then
      deletetext (u.infoform);
      u.infoform:=-1;
      if u.infoform2>=0 then deletetext(u.infoform2);
      u.infoform2:=-1;
      if u.infoform3>0 then deletetext(u.infoform3);
      u.infoform3:=-1;
      if u.infoform4>0 then deletetext(u.infoform4);
      u.infoform4:=-1;
      if u.infoform5>0 then deletetext(u.infoform5);
      u.infoform5:=-1;
      seek (ufile,cnt);
      write (ufile,u);
  end;
  writeln ('done.');
  writestr (^M'All '+strr(numusers)+' forms erased.');
  readurec
end;

procedure showscreens;
var i:integer;
begin
repeat
      clearscr;
      writehdr('The Ansi Gallery');
      writeln(^M^P'[A] - '^A'Show ASCII Welcome Screen');
      writeln(^P'[1-',configset.numwelcome,'] - '^A'Show Ansi Welcome Screen #xx');
      writeln(^P'[Q] - '^A'Exit this section');
      writestr(^M^R'Selection:');
      if input='' then input:='Q';
      if match(input,'A') then printfile(configset.textfiledi+'Welcome.Asc') else
        if not match(input,'Q') then begin i:=valu(input);
        if (i>0) and (i<=configset.numwelcome) then printfile(configset.textfiledi+'Welcome.'+strr(i))
        else writeln(^M^S'Invalid Screen!');
        end;
        if not match(input,'Q') then begin
           buflen:=0;
           writestr(^M^R'Press [Return]*');
        end;
      until match(input,'Q') or hungupon;
end;

 Procedure showlastcallers;
    Var qf:File Of lastrec;
      cnt:Integer;
      l:lastrec;
    Begin
      If ConfigSet.LastLeve>Ulvl then Exit;
      Assign(qf,'Callers');
      Reset(qf);
      If IOResult=0 Then Begin
        ClearScr;
        writehdr('Recent Caller List');
				writeln (^P'旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴컴컴커');
				writeln (^P'�'^S'              User''s Name'^P'               �'^S'    Date'^P'    �'^S'    Time'^P'    �');
				writeln (^P'쳐컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컵컴컴컴컴컴컴탠컴컴컴컴컴캑');
        For cnt:=0 To FileSize(qf)-1 Do begin
          Read(qf,l);
          Write (^P'�  '^S);
          Tab(l.name,38);
          Write (^P'� '^S);
          Tab(datestr(l.when),11);
          Write (^P'� '^S);
          Tab(timestr(l.when),11);
          writeln (^P'�');
          if Break then Begin
             Close(qf);
             Exit;
             End;
	      End;
				writeln (^P'읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컨컴컴컴컴컴컴좔컴컴컴컴컴켸');
	      Close(qf)
	    End;
		End;

Procedure JumpConference;
Var I:Integer;
Begin
   ClearScr;
   Urec.Conf[1]:=True;
   WriteHdr('Conference Selections');
   WriteLn(^P'['^R'1'^P'] '^S+ConfigSet.Conf1);
   If (ConfigSet.NumConfs>1) and Urec.Conf[2] then
   WriteLn(^P'['^R'2'^P'] '^S+ConfigSet.Conf2);
   If (ConfigSet.NumConfs>2) and Urec.Conf[3] then
   WriteLn(^P'['^R'3'^P'] '^S+ConfigSet.Conf3);
   If (ConfigSet.NumConfs>3) and Urec.Conf[4] then
   WriteLn(^P'['^R'4'^P'] '^S+ConfigSet.Conf4);
   If (ConfigSet.NumConfs>4) and Urec.Conf[5] then
   WriteLn(^P'['^R'5'^P'] '^S+ConfigSet.Conf5);
   WriteStr(^M^R'Conference Choice [1]:');
   If Input='' then Input:='1';
   I:=Valu(Input);
   If (I<1) or (I>ConfigSet.NumConfs) or not Urec.Conf[I] then
     WriteLn(^M^G'Invalid Choice!')
     Else
   Begin
     CurrentConference:=I;
     Case I of
       1:WriteLn(^M^P'Conference ['^A+ConfigSet.Conf1+^P'] Joined!');
       2:WriteLn(^M^P'Conference ['^A+ConfigSet.Conf2+^P'] Joined!');
       3:WriteLn(^M^P'Conference ['^A+ConfigSet.Conf3+^P'] Joined!');
       4:WriteLn(^M^P'Conference ['^A+ConfigSet.Conf4+^P'] Joined!');
       5:WriteLn(^M^P'Conference ['^A+ConfigSet.Conf5+^P'] Joined!');
     End;
   End;
   Urec.LastConf:=CurrentConference;
End;

procedure TopTen;

      type HighestPCR=record
             Name:mstr;
             PCR:longint;
             end;

      Type Tp=Array[1..10] of HighestPCR;
  Var done:boolean;
      TMPrec:userrec;
      Uploaders,LameUploaders,Downloaders,LameDownloaders,Posters,GoodUls,
      BadUls,GoodDls,BadDls,LamePosters,GoodPosts,BadPosts,GoodCalls,
      BadCalls:Tp;
      TmpPost:highestpcr;
      X1:Integer;

 Procedure InitIt;
 Var A,B,C,D,E,Cnt,UpToDown:LongInt;

     Procedure SortIt(Var ArofIt:Tp; Tempo:LongInt; UpOrDown:Boolean);
     Var Cnt,I:Integer;
     Begin
       Done:=False;
       For Cnt:=1 to 10 Do
       Begin
         If UpOrDown then
           Begin
           If not Done and (Tempo>ArofIt[Cnt].Pcr) then
           Begin
             If Cnt<10 then
               For I:=9 downto cnt do ArofIt[I+1]:=ArofIt[I];
             ArofIt[Cnt].Name:=TmpRec.Handle;
             ArofIt[Cnt].PCR:=Tempo;
             Done:=True;
           End;
           End
         Else
           If Not Done and (Tempo<ArofIt[Cnt].PCR) then
           Begin
            If Cnt>1 then
              For I:=9 downto cnt do ArofIt[I+1]:=ArofIt[I];
              ArofIt[Cnt].Name:=TmpRec.Handle;
              ArofIt[Cnt].PCR:=Tempo;
              Done:=True;
            End;
       End;
     End;



     begin
     ClearScr;
     Writehdr ('Calculating Statistics');

       for cnt:=1 to 10 do begin
        Posters[cnt].pcr:=0;
        posters[cnt].name:='';
        lamePosters[cnt].pcr:=maxint;
        lameposters[cnt].name:='';
        GoodPosts[Cnt].Name:='';
        GoodPosts[Cnt].PCR:=0;
        BadPosts[Cnt].Name:='';
        BadPosts[Cnt].Pcr:=MaxInt;
        GoodCalls[Cnt].Name:='';
        GoodCalls[Cnt].Pcr:=0;
        BadCalls[Cnt].Name:='';
        BadCalls[Cnt].Pcr:=MaxInt;
        Downloaders[cnt].pcr:=0;
        downloaders[cnt].name:='';
        lamedownloaders[cnt].pcr:=maxint;
        lamedownloaders[cnt].name:='';
               uploaders[cnt].pcr:=0;
        uploaders[cnt].name:='';
        lameuploaders[cnt].pcr:=maxint;
        lameuploaders[cnt].name:='';
        GoodUls[Cnt].Name:='';
        GoodUls[Cnt].PCR:=0;
        BadUls[Cnt].Name:='';
        BadUls[Cnt].PCR:=MaxInt;
        GoodDls[Cnt].Name:='';
        GoodDls[Cnt].PCR:=0;
        BadDls[Cnt].Name:='';
        BadDls[Cnt].PCR:=MaxInt;
       end;
     for cnt:=3 to numusers do begin
      seek(ufile,cnt-1);
      read(ufile,TmpRec);
        if tmprec.numon>1 then
        begin
				 D:=Ratio(TmpRec.Nbu,TmpRec.NumOn);
				 Sortit(Posters,D,True);
				 SortIt(LamePosters,D,False);
				 d:=tmprec.UpKay;
				 SortIt(Uploaders,D,True);
				 SortIt(LameUploaders,D,False);
				 d:=tmprec.DnKay;
				 SortIt(Downloaders,D,True);
				 SortIt(LameDownloaders,D,False);
				 D:=TmpRec.Uploads;
				 SortIt(GoodUls,D,True);
				 SortIt(BadUls,D,False);
				 D:=TmpRec.Downloads;
				 SortIt(GoodDls,D,True);
				 SortIt(BadDls,D,False);
				 SortIt(GoodPosts,TmpRec.Nbu,True);
				 SortIt(BadPosts,TmpRec.Nbu,False);
				End;
				 SortIt(GoodCalls,TmpRec.NumOn,True);
				 SortIt(BadCalls,TmpRec.NumOn,False);
		 End;
		 End;

     Procedure ShowSomething(TempOr:Tp; ToSay:Mstr; SayK:Byte);
     Var Cnt:Integer;
     Begin
       ClearScr;
       WriteHdr(ToSay);
       For Cnt:=1 to 10 Do
         Begin
           Tab(Strr(Cnt)+'.',4);
           Tab(TempOr[Cnt].Name,37);
           Write(TempOr[Cnt].PCR);
           if SayK=1 then Write('%');
           If SayK=2 then Write('K');
           WriteLn;
         End;
       WriteStr(^M^R'Press [Return]:');
     End;

     Begin
     InitIt;
     Repeat
       ClearScr;
       WriteHdr('Top 10 Listing');
       WriteLn(^R'[1] '^P'Best Uploaders');
       WriteLn(^R'[2] '^P'Worst Uploaders');
       WriteLn(^R'[3] '^P'Best Downloaders');
       WriteLn(^R'[4] '^P'Worst Downloaders');
       WriteLn(^R'[5] '^P'Best Post/Call Ratios');
       WriteLn(^R'[6] '^P'Worst Post/Call Ratios');
       WriteLn(^R'[7] '^P'Best Uploaders in K-Bytes');
       WriteLn(^R'[8] '^P'Worst Uploaders in K-Bytes');
       WriteLn(^R'[9] '^P'Best Downloaders in K-Bytes');
       WriteLn(^R'[10] '^P'Worst Downloaders in K-Bytes');
       WriteLn(^R'[11] '^P'Best Message Posters');
       WriteLn(^R'[12] '^P'Worst Message Posters');
       WriteLn(^R'[13] '^P'Best Callers');
       WriteLn(^R'[14] '^P'Worst Callers');
       WriteLn(^R'[15] '^P'Show all Statistics');
       WriteStr(^M^P'Selection:');
       If Input='' then Input:='0';
       X1:=Valu(Input);
       Case X1 of
         1:ShowSomething(GoodUls,'Top 10 Uploaders',0);
         2:ShowSomething(BadUls,'Lowest 10 Uploaders',0);
         3:ShowSomething(GoodDls,'Top 10 Downloaders',0);
         4:ShowSomething(BadDls,'Lowest 10 Downloaders',0);
         5:ShowSomething(Posters,'Top 10 Post/Call Ratios',1);
         6:ShowSomething(LamePosters,'Lowest 10 Post/Call Ratios',1);
         7:ShowSomething(Uploaders,'Top 10 Uploaders in K-Bytes',2);
         8:ShowSomething(LameUploaders,'Lowest 10 Uploaders in K-Bytes',2);
         9:ShowSomething(Downloaders,'Top 10 Downloaders in K-Bytes',2);
         10:ShowSomething(LameDownloaders,'Lowest 10 Downloaders in K-Bytes',2);
         11:ShowSomething(GoodPosts,'Top 10 Message Posters',0);
         12:ShowSomething(BadPosts,'Lowest 10 Message Posters',0);
         13:ShowSomething(GoodCalls,'Top 10 Callers',0);
         14:ShowSomething(BadCalls,'Lowest 10 Callers',0);
         15:Begin
            ShowSomething(GoodUls,'Top 10 Uploaders',0);
            ShowSomething(BadUls,'Lowest 10 Uploaders',0);
            ShowSomething(GoodDls,'Top 10 Downloaders',0);
            ShowSomething(BadDls,'Lowest 10 Downloaders',0);
            ShowSomething(Posters,'Top 10 Post/Call Ratios',1);
            ShowSomething(LamePosters,'Lowest 10 Post/Call Ratios',1);
            ShowSomething(Uploaders,'Top 10 Uploaders in K-Bytes',2);
            ShowSomething(LameUploaders,'Lowest 10 Uploaders in K-Bytes',2);
            ShowSomething(Downloaders,'Top 10 Downloaders in K-Bytes',2);
            ShowSomething(LameDownloaders,'Lowest 10 Downloaders in K-Bytes',2);
            ShowSomething(GoodPosts,'Top 10 Message Posters',0);
            ShowSomething(BadPosts,'Lowest 10 Message Posters',0);
            ShowSomething(GoodCalls,'Top 10 Callers',0);
            ShowSomething(BadCalls,'Lowest 10 Callers',0);
         End;
       End;
     Until HungUpOn or (X1=0);
End;

Procedure DisplayNodeInfo;
Var T:Text;
    I:Integer;
    Done:Boolean;
    Ls:Lstr;
Begin
  if not configset.multinodebbs then exit;
  I:=0;
  ClearScr;
  WriteHdr('Who''s Online Right Now');
  Repeat
    Inc(I);
    Done:=Not Exist(ConfigSet.ForumDi+'NDST'+STRR(I));
    If Not Done then
      Begin
      Assign(T,ConfigSet.ForumDi+'NDST'+STrr(I));
      ReSet(T);
      ReadLn(T,Ls);
      TextClose(T);
      WriteLn(^S'[',I,'] '^R,Ls);
    End;
  Until Done;
End;

begin
end.


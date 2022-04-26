{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }

unit others;

interface

uses crt,dos,
		 gentypes,configrt,modem,statret,gensubs,subs1,windows,subs2,textret,
     mailret,userret,flags,mainr1,ansiedit,lineedit,
     mainr2,overret1;


procedure showuserstats(u:userrec);
procedure edituser (eunum:integer);
procedure printnews;
function selectspecs (var us:userspecsrec):boolean; { True if user aborts }
procedure editoldspecs;
procedure readfeedback;
procedure showallsysops;
procedure editusers;
procedure zapspecifiedusers;
Procedure RemoteDosShell;

implementation



procedure delallmail (n:integer);
var cnt,delled:integer;
    m:mailrec;
    u:userrec;
begin
  cnt:=-1;
  delled:=0;
  repeat
    cnt:=searchmail(cnt,n);
    if cnt>0 then begin
      delmail(cnt);
      cnt:=cnt-1;
      delled:=delled+1
    end
  until cnt=0;
  if delled>0 then writeln (^B'Mail deleted: ',delled);
  writeurec;
  seek (ufile,n);
  read (ufile,u);
  deletetext (u.infoform);
  deletetext (u.infoform2);
  deletetext (u.infoform3);
  deletetext (u.infoform4);
  deletetext (u.infoform5);
  deletetext (u.emailannounce);
  u.infoform:=-1;
  u.infoform2:=-1;
  u.infoform3:=-1;
  u.infoform4:=-1;
  u.infoform5:=-1;
  u.emailannounce:=-1;
  writeufile (u,n);
  readurec
end;

procedure deleteuser (n:integer);
var u:userrec;
begin
  delallmail (n);
  fillchar (u,sizeof(u),0);
  u.infoform:=-1;
  u.infoform2:=-1;
  u.infoform3:=-1;
  u.infoform4:=-1;
  u.infoform5:=-1;
  u.emailannounce:=-1;
  writeufile (u,n)
end;


function postcallratio (var u:userrec):real;
begin
  if u.numon=0
    then postcallratio:=0
    else postcallratio:=u.nbu/u.numon
end;

function fitsspecs (var u:userrec; var us:userspecsrec):boolean;
var days:integer;
    pcr:real;
    thisyear,thismonth,thisday,t:word;
    lastcall:datetime;

  function inrange (n,min,max:integer):boolean;
  begin
    inrange:=(n>=min) and (n<=max)
  end;

begin
  unpacktime (u.laston,lastcall);
  getdate (thisyear,thismonth,thisday,t);
  days:=(thisyear-lastcall.year)*365+(thismonth-lastcall.month)*30+
        (thisday-lastcall.day);
  pcr:=postcallratio (u);
  fitsspecs:=inrange (u.level,us.minlevel,us.maxlevel) and
             inrange (days,us.minlaston,us.maxlaston) and
             (pcr>=us.minpcr) and (pcr<=us.maxpcr);
  if (datepart(u.expdate)<datepart(Now)) and us.expired and (datepart(u.expdate)<>0)
  then fitsspecs:=true;
end;


procedure showuserstats(u:userrec);
var knter:integer;
    tpstr:lstr;
begin
  clearscr;
	blowup(1,26,50,6);
	printxy(2,27,'User Handle :'+^S+u.handle+^M);
	printxy(3,27,'Real Name   :'+^S+u.realname+^M);
	printxy(4,27,'User Note   :'+^S+u.usernote+^M);
	printxy(5,27,'Phone Number:'+^S+u.phonenum+^M);
	blowup(1,1,25,16);
	if issysop then printxy(2,3,'Password:'+^S+u.password+^M) else
	printxy(2,3,'Password:'+^S+'[CLASSIFIED]'+^M);
	printxy(3,3,'Level   :'+^S+strr(u.level)+^M);
	printxy(4,3,'Posted  :'+^S+strr(u.nbu)+^M);
	printxy(5,3,'Wanted  :'+^S+yesno(wanted in u.config)+^M);
	printxy(6,3,' G-File Status'+^M);
	printxy(7,3,'Uploads :'+^S+strr(u.nup)+^M);
	printxy(8,3,'D/Ls    :'+^S+strr(u.ndn)+^M);
	printxy(9,3,' File Status'+^M);
	printxy(10,3,'Level   :'+^S+strr(u.udlevel)+^M);
	printxy(11,3,'Points  :'+^S+strr(u.udpoints)+^M);
	printxy(12,3,'U/L Kb  :'+^S+strr(u.upkay)+^M);
	printxy(13,3,'D/L Kb  :'+^S+strr(u.dnkay)+^M);
	printxy(14,3,'Uploads :'+^S+strr(u.uploads)+^M);
	printxy(15,3,'D/Ls    :'+^S+strr(u.downloads));
	if not (ansigraphics in urec.config) then writeln(^M);
	blowup(7,26,50,12);
  printxy(8,28,'            Other Information'+^M);
	printxy(9,28,'Last On  :'+^S+datestr(u.laston)+^A+' at '+^S+timestr(u.laston)+^M);
	printxy(10,28,'Number of calls :'+^S+strr(u.numon)+^M);
	printxy(11,28,'Macro #1  :'+^S+u.macro1+^M);
	printxy(12,28,'Macro #2  :'+^S+u.macro2+^M);
	printxy(13,28,'Macro #3  :'+^S+u.macro3+^M);
	tpstr:='';
	for knter:=1 to maxtopics do begin
		 if knter<>1 then tpstr:=tpstr+',';
		 tpstr:=tpstr+strr(u.voted[knter]);
	 end;
	printxy(14,28,'Voting Record :'+^S+tpstr+^M);
	tpstr:='';
	for knter:=1 to 7 do begin
		if knter<>1 then tpstr:=tpstr+',';
		if (u.confset[knter]>0) then tpstr:=tpstr+strr(knter) else
			tpstr:=tpstr+'0';
	 end;
	printxy(15,28,'Conference Flags :'+^S+tpstr+^M);
	tpstr:='';
  for knter:=8 to 20 do begin
    if knter<>8 then tpstr:=tpstr+',';
    if (u.confset[knter]>0) then tpstr:=tpstr+strr(knter) else
      tpstr:=tpstr+'0';
    end;
	printxy(16,30,^S+tpstr+^M);
	tpstr:='';
	for knter:=21 to 32 do begin
	if knter<>21 then tpstr:=tpstr+',';
	if (u.confset[knter]>0) then tpstr:=tpstr+strr(knter) else
		 tpstr:=tpstr+'0';
	 end;
	printxy(17,30,^S+tpstr+^M);
	fuckup(17,1,25,3);
	if ansigraphics in urec.config then
	ansicolor(urec.menuback);
	fuckxy(18,2,' L.S.D. User Status v2 ');
	if ansigraphics in urec.config then
	ansicolor(urec.regularcolor);
	WriteLn;
end;

procedure edituser (eunum:integer);
var eurec:userrec;
    ca:integer;
    k:char;
const sysopstr:array [false..true] of string[6]=('Normal','Sysop');
      sectionnames:array [udsysop..databasesysop] of string[20]=
        ('File transfer','Bulletin section','Voting booths',
         'E-mail section','Doors','Main menu','Databases');

  procedure truesysops;
  begin
    writeln ('Sorry, you may not do that without true sysop access!');
    writelog (18,17,'')
  end;

  function truesysop:boolean;
  begin
    truesysop:=ulvl>=configset.sysopleve
  end;

  procedure getmstr (t:mstr; var mm);
  var m:mstr absolute mm;
  begin
    writeln ('Old ',t,': '^S,m);
    writestr ('New '+t+'? *');
    if length(input)>0 then m:=input
  end;

  procedure getsstr (t:mstr; var s:sstr);
  var m:mstr;
  begin
    m:=s;
    getmstr (t,m);
    s:=m
  end;

  procedure getint (t:mstr; var i:integer);
  var m:mstr;
  begin
    m:=strr(i);
    getmstr (t,m);
    i:=valu(m)
  end;

  procedure euwanted;
  begin
    writestr ('Wanted status: '^S+yesno(wanted in eurec.config));
    writestr ('New wanted status:');
    if yes
      then eurec.config:=eurec.config+[wanted]
      else eurec.config:=eurec.config-[wanted];
    writelog (18,1,yesno(wanted in eurec.config))
  end;

  procedure eudel;
  var fnt:text; dummystr:mstr;
  begin
    writestr ('Delete user --- confirm:');
    if yes then begin
      writestr(^M'Add user to the Loozer List? *');
      if yes then begin
       if not exist(configset.textfiledi+'Blacklst') then begin
       assign(fnt,configset.textfiledi+'Blacklst');
       rewrite(fnt);
       textclose(fnt);
       end;
       assign(fnt,configset.textfiledi+'Blacklst');
       append(fnt);
       writeln(fnt,eurec.handle);
       textclose(fnt);
       end;
      deleteuser (eunum);
      seek (ufile,eunum);
      read (ufile,eurec);
      writelog (18,9,'')
    end
  end;

  Procedure EuMainConference;
  Var I,J:Integer;
  Begin
    For I:=1 to 5 Do
       If Eurec.Conf[I] then WriteLn('Allowed in Main Conference #',I)
       Else WriteLn('Not allowed in Main Conference #',i);
    WriteStr(^M'Which Conference to Change:');
    If Input='' then Else Begin
    I:=Valu(Input);
    If (I>0) and (I<6) then
      Eurec.Conf[I]:=Not Eurec.Conf[I];
    End;
  End;

  procedure euname;
  var m:mstr;
  begin
    m:=eurec.handle;
    getmstr ('name',m);
    if not match (m,eurec.handle) then
      if lookupuser (m)<>0 then begin
        writestr ('Already exists!  Are you sure? *');
        if not yes then exit
      end;
    eurec.handle:=m;
    writelog (18,6,m)
  end;

  procedure eupassword;
  begin
    if not truesysop
      then truesysops
      else begin
        getsstr ('password',eurec.password);
        writelog (18,8,'')
      end
  end;

  procedure eulevel;
  var n:integer;
  begin
    n:=eurec.level;
    getint ('level',n);
    if (n>=configset.sysopleve) and (not truesysop)
      then truesysops
      else begin
        eurec.level:=n;
        writelog (18,15,strr(n))
      end
  end;

  procedure eutimelimit;
  var n:integer;
  begin
    n:=eurec.timelimits;
    getint('time limit',n);
    eurec.timelimits:=n;
  end;

  procedure eudratio;
  var n:integer;
  begin
    n:=eurec.udratio;
    getint('Upload/Download Ratio',n);
    eurec.udratio:=n;
  end;

  procedure eudkratio;
  var n:integer;
  begin
       n:=eurec.udkratio;
       getint('Upload/Download K Ratio',n);
       eurec.udkratio:=n;
  end;

  procedure epcratio;
  var n:integer;
  begin
       n:=eurec.pcratio;
       getint('Post/Call Ratio',n);
       eurec.pcratio:=n;
  end;

  procedure eglevel;
  var n:integer;
  begin
  n:=eurec.glevel;
  getint('G-File level',n);
  if (n>=configset.sysopleve) and (not truesysop) then truesysops else eurec.glevel:=n;
  end;

  procedure egfpoints;
  var n:integer;
  begin
  n:=eurec.gpoints;
  getint('G-File points',n);
  eurec.gpoints:=n;
  end;

  procedure euconference;
  var k:integer;
  begin
    writehdr('User currently has the following conference flags set');
    for k:=1 to 20 do
        begin
          if (eurec.confset[k]>0) then write(k) else write('0');
          write(',');
        end;
        writeln('');
    for k:=21 to 31 do
      begin
        if (eurec.confset[k]>0) then write(k) else write('0');
        write(',');
        end;
    if (eurec.confset[32]>0) then writeln('32') else writeln('0');
    writestr(^M^P'Change which flag:*');
    if input='' then exit;
    K:=valu(input);
    if k>32 then begin
       writeln(^M'That is NOT a conference!');
       exit;
     end;
    if (eurec.confset[k]=1) then eurec.confset[k]:=0 else eurec.confset[k]:=1;
  end;

  procedure euusernote;
  var m:mstr;
      p:integer;
  begin
    m:=eurec.usernote;
    getmstr('Account note',m);
    eurec.usernote:=m;
  end;

  procedure euphone;
  var m:mstr;
      p:integer;
  begin
    m:=eurec.phonenum;
    buflen:=15;
    getmstr ('phone number',m);
    p:=1;
    while p<=length(m) do
      if (m[p] in ['0'..'9'])
        then p:=p+1
        else delete (m,p,1);
    if length(m)>7 then begin
      eurec.phonenum:=m;
      writelog (18,16,m)
    end
  end;

  procedure boardflags;
  var quit:boolean;

    procedure listflags;
    var bd:boardrec;
        cnt:integer;
    begin
      seek (bdfile,0);
      for cnt:=0 to filesize(bdfile)-1 do begin
        read (bdfile,bd);
        tab (bd.shortname,9);
        tab (bd.boardname,30);
        writeln (accessstr[getuseraccflag (eurec,cnt)]);
        if break then exit
      end
    end;

    procedure changeflag;
    var bn,q:integer;
        bname:mstr;
        ac:accesstype;
    begin
      buflen:=8;
      writestr ('Board to change access:');
      bname:=input;
      bn:=searchboard(input);
      if bn=-1 then begin
        writeln ('Not found!');
        exit
      end;
      writeln (^B^M'Current access: '^S,
               accessstr[getuseraccflag (eurec,bn)]);
      getacflag (ac,input);
      if ac=invalid then exit;
      setuseraccflag (eurec,bn,ac);
      case ac of
        letin:q:=2;
        keepout:q:=3;
        bylevel:q:=4
      end;
      writelog (18,q,bname)
    end;

    procedure allflags;
    var ac:accesstype;
    begin
      writehdr ('Set all board access flags');
      getacflag (ac,input);
      if ac=invalid then exit;
      writestr ('Confirm [Y/N]:');
      if not yes then exit;
      setalluserflags (eurec,ac);
      writelog (18,5,accessstr[ac])
    end;

  begin
    opentempbdfile;
    quit:=false;
    repeat
      repeat
        writestr (^M'L)ist flags, C)hange one flag, A)ll flags, or Q)uit:');
        if hungupon then exit
      until length(input)<>0;
      case upcase(input[1]) of
        'L':listflags;
        'C':changeflag;
        'A':allflags;
        'Q':quit:=true
      end
    until quit;
    closetempbdfile
  end;

  procedure specialsysop;

    procedure getsysop (c:configtype);
    begin
      writeln ('Section ',sectionnames[c],': '^S,
               sysopstr[c in eurec.config]);
      writestr ('Grant sysop access? *');
      if length(input)<>0
        then if yes
          then
            begin
              eurec.config:=eurec.config+[c];
              writelog (18,10,sectionnames[c])
            end
          else
            begin
              eurec.config:=eurec.config-[c];
              writelog (18,11,sectionnames[c])
            end
    end;

  begin
    if not truesysop then begin
      truesysops;
      exit
    end;
    writestr
('Section of M)ain, F)ile, B)ulletin, V)oting, E)mail, D)atabase, P)Doors:');
    if length(input)=0 then exit;
    case upcase(input[1]) of
      'M':getsysop (mainsysop);
      'F':getsysop (udsysop);
      'B':getsysop (bulletinsysop);
      'V':getsysop (votingsysop);
      'E':getsysop (emailsysop);
      'D':getsysop (databasesysop);
      'P':getsysop (doorssysop)
    end
  end;

  procedure getlogint (prompt:mstr; var i:integer; ln:integer);
  begin
    getint (prompt,i);
    writelog (18,ln,strr(i))
  end;

var q:integer;
   tmp:integer;
begin
  writeurec;
  seek (ufile,eunum);
  read (ufile,eurec);
  writelog (2,3,eurec.handle);
  repeat
   WriteLn(^M^R'['^S+Eurec.Handle+^R']');
    q:=menu('User edit','UEDIT','SDHPLOEWTBQYNIA+CXGF!$^&J');
    case q of
      1:begin
        showuserstats(eurec);
        writelog(18,13,'');
        if (DateStr(Eurec.ExpDate)='0/0/80') or (datestr(eurec.expdate)='0/0/128') then
        writeln(^M'Users account does not expire!') else
        writeln(^M'Account Expires on ',datestr(eurec.expdate));
        end;
      2:eudel;
      3:euname;
      4:eupassword;
      5:eulevel;
      6:getlogint ('u/d points',eurec.udpoints,7);
      7:getlogint ('u/d level',eurec.udlevel,14);
      8:euwanted;
      9:getlogint ('time for today',eurec.timetoday,12);
      10:boardflags;
      12:specialsysop;
      13:euphone;
      14:begin
          writestr(^M^P'Which infoform to view [1-5]: [1]:*');
          if input='' then input:='1';
          tmp:=valu(input);
          if (tmp>0) and (tmp<6) then showinfoforms(strr(eunum),tmp);
          end;
      15:euusernote;
      16:begin
          writestr ('Set to user defaults:');
            if yes then begin
              eurec.level:=configset.defleve;
              eurec.usernote:=configset.defac;
              eurec.udpoints:=configset.deffp;
              eurec.udlevel:=configset.deffil;
              eurec.glevel:=configset.defgfil;
              eurec.gpoints:=configset.defgp;
            end;
        end;
      17:euconference;
      18:begin
              if (datestr(eurec.expdate)='0/0/128') or (DateStr(Eurec.ExpDate)='0/0/80')
               then writeln(^M^P'users account does not expire!') else
                      writeln(^M^P'Users current Expiration date is '^R,datestr(eurec.expdate));
              writestr(^M'Enter new expiration date, 00/00/80 for no expiration [mm/dd/yy]:');
              eurec.expdate:=dateval(input);
           end;
     19:eglevel;
     20:egfpoints;
     21:eudratio;
     22:eudkratio;
     23:epcratio;
     24:eutimelimit;
     25:EuMainConference;
     end
  until hungupon or (q=11);
  writeufile (eurec,eunum);
  readurec
end;

  Procedure printnews;
    Var nfile:File Of newsrec;
      line:Integer;
      Ntmp:newsrec;cnt:Integer;
    Begin
      Assign(nfile,'News');
      Reset(nfile);
      If IOResult<>0 Then exit;
      If FileSize(nfile)=0 Then Begin
        Close(nfile);
        exit
      End;
      clearscr;
      if ansigraphics in urec.config then begin
        blowup(1,1,27,3);
        write(direct,#27,'[2;3H');
      end;
      writeln(^S'News: [Ctrl-X] to abort'^M^M^M);
      cnt:=0;
      While Not(EoF(nfile) Or break Or hungupon) Do Begin
        Read(nfile,Ntmp);
        If issysop or (ntmp.location>=0) And (ntmp.maxlevel>=urec.level) And (urec.level>=ntmp.level) Then Begin
          inc(cnt);
	    WriteLn(^B'News Item #'^S,cnt,^R' - "'^S,ntmp.title,^R'" from '^S,ntmp.from,^R'');
	    WriteLn(^B'Date: ['^S,datestr(ntmp.when),^R']    Level ['^S,ntmp.level,' - ',ntmp.maxlevel,^R']');
	    WriteLn(^B^P'__________________________________________');
          printtext(Ntmp.location);
          writestr(^P'Press '^S'[Return]'^P' to continue.*')
        End;
      End;
      Close(nfile)
    End;



procedure openusfile;
const newusers:userspecsrec=(name:'New users';Expired:True;minlevel:1;maxlevel:1;
         minlaston:-maxint;maxlaston:maxint;minpcr:-maxint;maxpcr:maxint);
begin
  assign (usfile,'userspec');
  reset (usfile);
  if ioresult<>0 then begin
    rewrite (usfile);
    if configset.level2n<>0 then newusers.maxlevel:=configset.level2n;
    write (usfile,newusers)
  end
end;

procedure editspecs (var us:userspecsrec);

  procedure get (tex:string; var value:integer; min:boolean);
  var vstr:sstr;
  begin
    buflen:=6;
    if abs(value)=maxint then vstr:='None' else vstr:=strr(value);
    writestr (tex+' ['+vstr+']:');
    if input[0]<>#0
      then if upcase(input[1])='N'
        then if min
          then value:=-maxint
          else value:=maxint
        else value:=valu(input)
  end;

  procedure getreal (tex:string; var value:real; min:boolean);
  var vstr:sstr;
      s:integer;
  begin
    buflen:=10;
    if abs(value)=maxint then vstr:='None' else vstr:=streal(value);
    writestr (tex+' ['+vstr+']:');
    if length(input)<>0
      then if upcase(input[1])='N'
        then if min
          then value:=-maxint
          else value:=maxint
        else begin
          val (input,value,s);
          if s<>0 then value:=0
        end
  end;

begin
  writeln (^B^M'Enter specifications; N for none.'^M);
  buflen:=30;
  writestr ('Specification set name ['+us.name+']:');
  if length(input)<>0
    then if match(input,'N')
      then us.name:='Unnamed'
      else us.name:=input;
  get ('Lowest level',us.minlevel,true);
  get ('Highest level',us.maxlevel,true);
  get ('Lowest #days since last call',us.minlaston,true);
  get ('Highest #days since last call',us.maxlaston,true);
  getreal ('Lowest post to call ratio',us.minpcr,true);
  getreal ('Highest post to call ratio',us.maxpcr,true);
  WriteStr('Search for expired accounts? *');
  us.expired:=yes;
end;

function getspecs (var us:userspecsrec):integer; { -1:not saved   >0:in file }
begin
  with us do begin
    name:='Unnamed';                     { Assumes USFILE is open !! }
    minlevel:=-maxint;
    maxlevel:=maxint;
    minlaston:=-maxint;
    maxlaston:=maxint;
    minpcr:=-maxint;
    maxpcr:=maxint;
    expired:=false;
  end;
  editspecs (us);
  writestr (^M'Save these specs to disk? *');
  if yes then begin
    seek (usfile,filesize(usfile));
    write (usfile,us);
    getspecs:=filesize(usfile)
  end else getspecs:=-1
end;

function searchspecs (var us:userspecsrec; name:mstr):integer;
var v,pos:integer;
begin
  v:=valu(name);
  seek (usfile,0);
  pos:=1;
  while not eof(usfile) do begin
    read (usfile,us);
    if match(us.name,name) or (valu(name)=pos) then begin
      searchspecs:=pos;
      exit
    end;
    pos:=pos+1
  end;
  searchspecs:=0;
  writestr (^M'Not found!')
end;

procedure listspecs;
var us:userspecsrec;
    pos:integer;

  procedure writeval (n:integer);
  begin
    if abs(n)=maxint then write ('   None') else write(n:7)
  end;

  procedure writevalreal (n:real);
  begin
    if abs(n)=maxint then write ('   None') else write(n:7:2)
  end;

begin
  writehdr ('User Specification Sets');
  seek (usfile,0);
  pos:=0;
  tab ('',28);
  tab('Expired',7);
  tab ('    Level    ',14);
  tab ('  Last Call  ',14);
  writeln ('  Post/Call Ratio  ');
  while not (break or eof(usfile)) do begin
    pos:=pos+1;
    read (usfile,us);
    write (pos:3,'. ');
    tab (us.name,23);
    if us.expired then tab(' Yes',7) else tab(' No',7);
    writeval (us.minlevel);
    writeval (us.maxlevel);
    writeval (us.minlaston);
    writeval (us.maxlaston);
    writevalreal (us.minpcr);
    writevalreal (us.maxpcr);
    writeln
  end
end;

function selectaspec (var us:userspecsrec):integer; {  0 = none         }
var done:boolean;                                   { -1 = not in file  }
    pos:integer;                                    { -2 = added to end }
begin
  selectaspec:=0;
  openusfile;
  if filesize(usfile)=0
    then selectaspec:=getspecs(us)
    else
      repeat
        if hungupon then exit;
        done:=false;
        writestr (^M'Specification set name (?=list, A=add):');
        if length(input)=0
          then done:=true
          else if match(input,'A')
            then
              begin
                pos:=getspecs(us);
                if pos>0
                  then selectaspec:=-2
                  else selectaspec:=-1;
                done:=true
              end
            else if match(input,'?')
              then listspecs
              else
                begin
                  pos:=searchspecs (us,input);
                  done:=pos<>0;
                  selectaspec:=pos
                end
      until done;
  close (usfile)
end;

function selectspecs (var us:userspecsrec):boolean;
var dummy:integer;
begin
  dummy:=selectaspec (us);
  selectspecs:=dummy=0
end;

procedure deletespecs (pos:integer);
var cnt:integer;
    us:userspecsrec;
begin
  openusfile;
  for cnt:=pos to filesize(usfile)-1 do begin
    seek (usfile,cnt);
    read (usfile,us);
    seek (usfile,cnt-1);
    write (usfile,us)
  end;
  seek (usfile,filesize(usfile)-1);
  truncate (usfile);
  close (usfile)
end;

procedure editoldspecs;
var pos:integer;
    us:userspecsrec;
begin
  repeat
    pos:=selectaspec (us);
    if pos>0 then begin
      buflen:=1;
      writestr (^M'E)dit or D)elete? *');
      if length(input)=1 then case upcase(input[1]) of
        'E':begin
              editspecs (us);
              openusfile;
              seek (usfile,pos-1);
              write (usfile,us);
              close (usfile)
            end;
        'D':deletespecs (pos)
      end
    end
  until (pos=0) or hungupon
end;

procedure editusers;
var eunum:integer;
    matched:boolean;

  procedure elistusers (getspecs:boolean);
  var cnt,f,l:integer;
      u:userrec;
      us:userspecsrec;

    procedure listuser;
    begin
      write (cnt:4,' ');
      tab (u.handle,31);
      write (u.level:6,' ');
      tab (datestr(u.laston),8);
      write (u.nbu:6,u.numon:6,' ');
      if datestr(u.expdate)='0/0/80' then writeln('N/A') else writeln(datestr(u.expdate));
    end;

  begin
    if getspecs
      then if selectspecs(us)
        then exit
        else
          begin
            f:=1;
            l:=numusers
          end
      else parserange (numusers,f,l);
    seek (ufile,f);
    matched:=false;
    writeln (^B^M^M' Num Name                            Level ',
             'Last on  Posts Calls Exp Date');
    for cnt:=f to l do begin
      read (ufile,u);
      if (not getspecs) or fitsspecs(u,us) then begin
        listuser;
        matched:=true
      end;
      if break or xpressed then exit
    end;
    if not matched then
      if getspecs
        then writeln (^B^M'No users match specifications!')
        else writeln (^B^M'No users found in that range!')
  end;

procedure globalnew;
var cnt,f,l:integer;
    U:userrec;
begin
f:=1;
L:=numusers;
seek(ufile,f);
cnt:=0;
for f:=1 to l do begin
  read(ufile,u);
  if (u.level<=configset.level2n) and (u.handle<>'') then begin
   cnt:=cnt+1;
     writestr(^M^P'Edit ['^R+u.handle+^P'] ? *');
     if yes then begin
       edituser(f);
       seek(ufile,f+1);
       writeln(^B^U'Continuing with the scan...');
     end;
     end;
  end;
writeln(^B^R'End of user list! ['^P,cnt,^R'] Match(s) found!');
end;


begin
  repeat
    writestr (^M'User to edit [?,??=list], [N=Global New Users]:');
    if (length(input)=0) or (match(input,'Q')) then exit;
    if match(input,'N') then begin
       globalnew;
       exit;
    end;
    if input[1]='?'
      then elistusers (input='??')
      else begin
        eunum:=lookupuser (input);
        if eunum=0
          then writestr ('User not found!')
          else edituser (eunum)
      end
  until hungupon
end;

procedure zapspecifiedusers;
var us:userspecsrec;
    confirm:boolean;
    u:userrec;
    cnt:integer;
    done:boolean;
begin
  if selectspecs (us) then exit;
  writestr ('Confirm each deletion individually? *');
  if length(input)=0 then exit;
  confirm:=yes;
  if not confirm then begin
    writestr (^M'Are you SURE you want to mass delete without confirmation? *');
    if not yes then exit
  end;
  for cnt:=1 to numusers do begin
    seek (ufile,cnt);
    read (ufile,u);
    if (length(u.handle)>0) and fitsspecs (u,us) then begin
      if confirm
        then
          begin
            done:=false;
            repeat
              writestr ('Delete '+u.handle+' (Y/N/X/E):');
              if length(input)>0 then case upcase(input[1]) of
                'Y':begin
                      done:=true;
                      writeln ('Deleting '+u.handle+'...');
                      deleteuser (cnt)
                    end;
                'N':done:=true;
                'X':exit;
                'E':begin
                      edituser(cnt);
                      writeln;
                      writeln
                    end
              end
            until done
          end
        else
          begin
            writeln ('Deleting '+u.handle+'...');
            if break then begin
              writestr ('Aborted!!');
              exit
            end;
            deleteuser (cnt)
          end
    end
  end
end;

procedure showallsysops;
var n:integer;
    u:userrec;
    q:set of configtype;
    s:configtype;

  procedure showuser;
  const sectionnames:array [udsysop..databasesysop] of string[20]=
         ('File transfer','Bulletin section','Voting booths',
          'E-mail section','Doors','Main menu','Databases');
  var s:configtype;
  begin
    writeln (^B^M'Name:  '^S,u.handle,
               ^M'Level: '^S,u.level,^M);
    for s:=udsysop to databasesysop do
      if s in u.config then
        writeln ('Sysop of the ',sectionnames[s]);
    writestr (^M'Edit user? *');
    if yes then edituser (n)
  end;

begin
  q:=[];
  for s:=udsysop to databasesysop do q:=q+[s];
  for n:=1 to numusers do begin
    seek (ufile,n);
    read (ufile,u);
    if (u.level>=configset.sysopleve) or (q*u.config<>[]) then showuser
  end
end;

procedure readfeedback;
var ffile:file of mailrec;
    m:mailrec;
    me:message;
    cur:integer;

  function nummessages:integer;
  begin
    nummessages:=filesize(ffile)
  end;

  function checkcur:boolean;
  begin
    if length(input)>1 then cur:=valu(copy(input,2,255));
    if (cur<1) or (cur>nummessages) then begin
      writestr (^M'Message out of range!');
      cur:=0;
      checkcur:=true
    end else begin
      checkcur:=false;
      seek (ffile,cur-1);
      read (ffile,m)
    end
  end;

  procedure readnum (n:integer);
  begin
    cur:=n;
    input:='';
    if checkcur then exit;
    writeln (^M^R'Message: '^S,cur,
               ^M^R'Title:   '^S,m.title,
               ^M^R'Sent by: '^S,m.sentby,
               ^M^R'Sent on: '^S,datestr(m.when),' at ',timestr(m.when),^M);
    if break then exit;
    printtext (m.line)
  end;

  procedure writecurmsg;
  begin
    if (cur<1) or (cur>nummessages) then cur:=0;
    write (^B^M'Current msg: '^S);
    if cur=0 then write ('None') else begin
      seek (ffile,cur-1);
      read (ffile,m);
      write (m.title,' by ',m.sentby)
    end
  end;

  procedure delfeedback;
  var cnt:integer;
  begin
    if checkcur then exit;
    deletetext (m.line);
    for cnt:=cur to nummessages-1 do begin
      seek (ffile,cnt);
      read (ffile,m);
      seek (ffile,cnt-1);
      write (ffile,m)
    end;
    seek (ffile,nummessages-1);
    truncate (ffile);
    cur:=cur-1
  end;

  procedure editusr;
  var n:integer;
  begin
    if checkcur then exit;
    n:=lookupuser (m.sentby);
    if n=0
      then writestr ('User disappeared!')
      else edituser (n)
  end;

  procedure infoform;
  var info:integer;
  begin
    if checkcur then exit;
    writestr('What infoform to view [1-5]: [1]:*');
    if input='' then input:='1';
    info:=valu(input);
    if (info>0) and (info<6) then
    showinfoforms (m.sentby,info)
  end;

  procedure nextfeedback;
  begin
    cur:=cur+1;
    if cur>nummessages then begin
      writestr (^M'Sorry, no more feedback!');
      cur:=0;
      exit
    end;
    readnum (cur)
  end;

  procedure readagain;
  begin
    if checkcur then exit;
    readnum (cur)
  end;

  procedure replyfeedback;
  begin
    if checkcur then exit;
    sendmailto (m.sentby,false)
  end;

  procedure listfeedback;
  var cnt:integer;
  begin
    if nummessages=0 then exit;
    thereare (nummessages,'piece of feedback','pieces of feedback');
    if break then exit;
    writeln (^M'Num Title                          Left by'^M);
    seek (ffile,0);
    for cnt:=1 to nummessages do begin
      read (ffile,m);
      tab (strr(cnt),4);
      if break then exit;
      tab (m.title,31);
      writeln (m.sentby);
      if break then exit
    end
  end;

var q:integer;
label exit;
begin
  assign (ffile,configset.forumdi+'Feedback');
  reset (ffile);
  if ioresult<>0 then rewrite (ffile);
  cur:=0;
  repeat
    if nummessages=0 then begin
      writestr ('Sorry, no feedback!');
      goto exit
    end;
    writecurmsg;
    q:=menu ('Feedback','FEED','Q#DEIR_AL');
    if q<0
      then readnum (-q)
      else case q of
        3:delfeedback;
        4:editusr;
        5:infoform;
        6:replyfeedback;
        7:nextfeedback;
        8:readagain;
        9:listfeedback;
      end
  until (q=1) or hungupon;
  exit:
  close (ffile)
end;


Procedure RemoteDosShell;
Begin
	If ConfigSet.GatePass<>'' then
		Begin
			Dots:=True;
			WriteStr(^M^P'Dos Shell Password:');
			Dots:=False;
			If not match(input,configset.gatepass) then
				 Begin
						WriteLn(^G^S'WRONG!'^M);
						Exit;
				 End;
			End;
	ClearScr;
	WriteLog(2,13,TimeStr(Now));
	WriteLn(^S'Type "Exit" to return to L.S.D.!');
	Delay(1000);
  closeport;
	Exec(GetEnv('Comspec'),'/C COMMAND < GATE'+STRR(Configset.UseCo)+' > GATE'+Strr(ConfigSet.UseCo));
	setparam(configset.useco,baudrate,false);
	ChDir(Copy(ConfigSet.ForumDi,1,Length(ConfigSet.ForumDi)-1));
End;

begin

  (* We can put code in here before L.S.D. Even runs that will
     get initialized! *)
end.


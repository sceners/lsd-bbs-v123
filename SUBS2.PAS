program config;

{$R-,S+,I-,D+,F-,V-,B-,N-,L+ }
{$M 32000,5000,35000 }

uses crt,
     scrnunit,scrninpt,general,prompts,
     gentypes,configrt;

const normalcolor=112;
      boldcolor=113;
      barcolor=$1f;
      inputcolor=15*5+15;
      choicecolor=117;
      datacolor=118;

var prompt:promptset;
    highres:boolean;

procedure writeconfig;
var q:file of configsettype;
begin
  assign (q,'Config.BBS');
  rewrite (q);
  write (q,configset);
  close (q);
end;

procedure formatconfig;
var cnt:integer;
begin
  configset.versioncod:=thisversioncode;
  configset.longnam:='';
  Configset.Origin1:=Configset.Longnam;
  Configset.Origin2:=Configset.Longnam;
  configset.shortnam:='';
  configset.sysopnam:='';
  getdir (0,configset.forumdi);
  if configset.forumdi[length(configset.forumdi)]<>'\' then configset.forumdi:=configset.forumdi+'\';
  configset.textdi:=configset.forumdi+'text\';
  configset.uploaddi:=configset.forumdi+'files\';
  configset.boarddi:=configset.forumdi+'boards\';
  configset.overlaypat[0]:=#0;
  configset.asciidownloa:='Grabbed from a L.S.D. BBS!!!!!';
  configset.textfiledi:=configset.forumdi+'textfile\';
  configset.doordi:=configset.forumdi+'doors\';
  configset.modemsetupst:='ATX6HM0S0=1|';
  configset.modemhangupst:='+++~~~ATH|';
  configset.modemdialprefi:='ATDT';
  configset.modemdialsuffi:='|';
  configset.defbaudrat:=38400;
  configset.useco:=1;
  configset.hashaye:=false;
  configset.anonymousleve:=5;
  configset.numwelcome:=1;
  configset.mintimeou:=5;
  configset.sysopleve:=100;
  configset.defudleve:=0;
  configset.defudpoint:=0;
  configset.normbotcolo:=6;
  configset.normtopcolo:=2;
  configset.outlockcolo:=5;
  configset.splitcolo:=4;
  configset.statlinecolo:=3;
  configset.uploadfacto:=2;
  configset.privat:=false;
  configset.autologi:=true;
  configset.useconmod:=false;
  configset.escinmsg:=false;
  configset.bkspinmsg:=true;
  configset.requireform:=true;
  configset.dotcha:='*';
  configset.supportedrate:=[b1200]+[b2400]+[b4800]+[b9600]+[b19200]+[b38400];
  configset.downloadrate:=configset.supportedrate;
  configset.availtim:='10:00 am';
  configset.unavailtim:='10:00 am';
  configset.xmodemopentim:='3:00 am';
  configset.xmodemclosetim:='3:00 am';
  configset.netstart:='3:00 am';
  configset.netend:='3:00 am';
  for cnt:=1 to 100 do configset.usertim[cnt]:=60;
  configset.level2n:=1;
  configset.udlevel2n:=0;
  configset.udpoints2n:=0;
  configset.postleve:=2;
  configset.anonymousst:='Anonymous';
  configset.systempasswor:='SYSTEM1';
  configset.remotedoor:=false;
  configset.allowdoor:=true;
  configset.eventtim[0]:=#0;
  configset.eventbatc[0]:=#0;
  configset.directvideomod:=true;
  configset.checksnowmod:=true;
  configset.matrixtyp:=1;
  configset.syste2:='';
  configset.syste3:='';
  configset.newuserpas:='';
  configset.loginheade:='L.S.D. Kicking it live!';
  configset.minpc:=25;
  configset.exemptpc:=50;
  configset.defleve:=25;
  configset.deffil:=25;
  configset.deffp:=5;
  configset.defgfil:=25;
  configset.defgp:=5;
  with configset do begin
  defac:='Validated User';
  staleve:=0;
  stapoint:=0;
  minudrati:=25;
  minud:=30;
  sysop:='SYSOP';
  normenu:=false;
  emchatp:='CHAT';
  whissl:=false;
  edito:='C:\ED.EXE';
  entercha:='The SysOp is here!';
  exitcha:='Continue using the BBS...';
  bimodemdi:=configset.forumdi+'Bimodem\';
  timepercentbac:=50;
  leechwee:=false;
  chatmatr:=true;
  feedmatr:=true;
  sysopi:='The SysOp is in...';
  sysopo:='He aint here...';
  listleve:=35;
  lastleve:=35;
  comd1:='1';
  comd2:='2';
  comd3:='3';
  comd4:='4';
  comd5:='5';
  comd6:='6';
  comd7:='7';
  comd8:='8';
  prom:='[Matrix Command][?/Help>]';
  desc1:='Logon System1';
  desc2:='Logon System2';
  desc3:='Logon System3';
  desc4:='Apply as a new user';
  desc5:='Check for access';
  desc6:='Log off';
  desc7:='Feedback to sysops';
  desc8:='Chat with sysops';
  msg2nx:=35;
  demons:=true;
  demoname:='Joe Demon';
  leechud:=25;
  leechk:=10;
  answ1:='THG';
  end;
  configset.usetimebank:=true;
  configset.totalallowed:=60;
  configset.levelusetb:=30;
  configset.userume:=true;
  configset.leveltoaddrume:=30;
  configset.startpriv:='10:00 am';
  configset.stoppriv:='10:00 am';
  configset.privlevel:=50;
  configset.minfreesp:=500;
  configset.useonelin:=true;
  configset.netdir:=configset.forumdi+'NET\';
  configset.totform:=1;
  configset.inf1:='New User Application';
  configset.inf2:='Unused';
  configset.inf3:='Unused';
  configset.inf4:='Unused';
  configset.inf5:='Unused';
  configset.man2:=false;
  configset.man3:=false;
  configset.man4:=false;
  configset.man5:=false;
  configset.usezip:=true;
  configset.workdir:=configset.forumdi+'Work\';
  configset.famday:=true;
  configset.netstc:='';
  configset.netenc:='';
  configset.netpas:='AcidNet';
  configset.copre:='';
  configset.cosuf:='';
  configset.dszlog:=configset.forumdi+'Kermie';
  configset.logsize:=10;
  configset.defstacolor:=14;
  configset.definput:=15;
  configset.defpromp:=11;
  configset.defreg:=12;
  configset.defblowin:=13;
  configset.defblowbor:=15;
  configset.autouls:=0;
  configset.pointcomp:=false;
  configset.pathfnme:='';
  configset.usems:=false;
  configset.hangonew:=true;
  Configset.HubBBS:=False;
  Configset.MaximumDosShell:=True;
  Configset.LockOutBaudPass:='Bad Baud Rate';
  ConfigSet.UsePrinterLog:=False;
  ConfigSet.SaveScreen:=True;
  ConfigSet.NumConfs:=1;
  ConfigSet.Conf1:='General Discussion';
  ConfigSet.Conf2:='';
  ConfigSet.Conf3:='';
  ConfigSet.Conf4:='';
  ConfigSet.Conf5:='';
  ConfigSet.NetType1:=True;
  ConfigSet.NetType2:=False;
  ConfigSet.NetType3:=False;
  ConfigSet.NetType1Path:=ConfigSet.ForumDi+'NETUPG\';
  ConfigSet.ShowNewPrompts:=True;
  ConfigSet.NodeNumber:=1;
	configset.multinodebbs:=false;
	configset.gatepass:='DOS SHELL';
	ConfigSet.Sys1PwPromp:='[System 1] Password:';
	ConfigSet.Sys2PwPromp:='[System 2] Password:';
	ConfigSet.Sys3PwPromp:='[System 3] Password:';
	ConfigSet.MatNamePromp:='Enter your Handle or User Number:';
	ConfigSet.MatHangup:='Disconnecting: TTY1';
	ConfigSet.InvalidPromp:='Invalid Choice!';
	ConfigSet.MinGfileUd:=20;
	ConfigSet.MinGfilePCR:=25;
	writeconfig
end;


type ttypetype=(TInteger,Tsstr,Tmstr,Tlstr,TBoolean,TChar,TBaudset,
                TPath,TTime,TAttrib,Tusertime,Tword,Badtype);
     ptrset=record
       case integer of
         0:(i:^integer);
         1:(l:^lstr);
         2:(b:^boolean);
         3:(k:^char);
         4:(baudsetptr:^baudset)
     end;
     thing=record
       text:mstr;
       descrip:lstr;
       ttype:ttypetype;
       p:pointer;
       r1,r2:integer
     end;

const ttypestr:array [ttypetype] of sstr=
  ('Int','sstr','mstr','lstr','Boo','Char','Baud','Path','Time',
   'Attrib','Usertime','Word','!!!!????');
      colorstr:array [0..15] of mstr=
  ('Black  ','Blue ','Green','Cyan ','Red    ','Magenta','Brown   ','White',
   'Gray  ','BLUE!  ','GREEN!','CYAN!  ','RED!     ','MAGENTA!','Yellow   ','WHITE!');

const maxthings=200;
      dcol=30;

var top,bot,page,numpages,numthings:integer;
    things:array [1..maxthings] of thing;

procedure cb;
begin
  setcolor (boldcolor)
end;

procedure c4;
begin
  setcolor (boldcolor)
end;

procedure cn;
begin
  setcolor (normalcolor)
end;

procedure c7;
begin
  setcolor (boldcolor)
end;

function match(a1,a2:anystr):boolean;
var cnt:integer;
begin
  match:=false;
  while a1[length(a1)]=' ' do a1[0]:=pred(a1[0]);
  while a2[length(a2)]=' ' do a2[0]:=pred(a2[0]);
  if length(a1)<>length(a2) then exit;
  for cnt:=1 to length(a1) do
    if upcase(a1[cnt])<>upcase(a2[cnt]) then exit;
  match:=true
end;

function yesnostr (var b:boolean):sstr;
begin
  if b and (ord(b)<>ord(true)) then b:=true;
  if b then yesnostr:='Yes' else yesnostr:='No'
end;

function strr (n:longint):mstr;
var q:mstr;
begin
  str (n,q);
  strr:=q
end;

function valu(q:mstr):longint;
var s:integer;
  i:longint;
begin
  val(q,i,s);
  if s=1
    then valu:=0
    else valu:=i
end;

function whichpage (n:integer):integer;
begin
  if not highres then whichpage:=((n-1) div 18)+1 else whichpage:=((n-1) div 35)+1
end;

function whichline (n:integer):integer;
begin
  if not highres then whichline:=n-18*(whichpage(n)-1)+2 else whichline:=n-35*(whichpage(n)-1)+2;
end;

function getbaudstr (var q:baudset):lstr;
var w:lstr;
    cnt:baudratetype;
begin
  w[0]:=chr(0);
  for cnt:=firstbaud to lastbaud do
    if cnt in q then w:=w+strr(baudarray[cnt])+' ';
  if length(w)=0 then w:='None';
  getbaudstr:=w
end;

function varstr (n:integer):string;
var pu:pointer;
    p:ptrset absolute pu;
begin
  pu:=things[n].p;
  case things[n].ttype of
    tinteger:varstr:=strr(p.i^);
    tlstr,tmstr,tsstr,tpath,ttime:varstr:=p.l^;
    tboolean:varstr:=yesnostr(p.b^);
    tchar:varstr:=p.k^;
    tbaudset:varstr:=getbaudstr (p.baudsetptr^);
    tattrib:varstr:=colorstr[p.i^];
    tusertime:varstr:='(Use this choice to configure user daily time)';
    tword:varstr:=strr(configset.defbaudrat);
    else varstr:='??!?!?!'
  end
end;

procedure writevar (n:integer);
begin
  cb;
  write (varstr(n));
  cn; clreol;
  {writeln}
end;

procedure gotopage (p:integer);
var cnt,cy:integer;
    grf:integer;
begin
  if p<1 then p:=1;
  if p>numpages then p:=numpages;
  if p<>page then begin
    if page<>0 then freeprompts (prompt);
    page:=p; setcurwindow(w2);
    gotoxy (1,1);
    cn;    if not highres then
    top:=(page-1)*18+1 else top:=(page-1)*35+1; clreol;write(things[top].descrip);setcurwindow(w1);
    if not highres then bot:=top+17 else bot:=top+34;
    if bot>numthings then bot:=numthings;
    beginprompts (prompt); grf:=17; if highres then grf:=34;
    for cnt:=top to top+grf do begin
      cy:=cnt-top+1;{+3;}
      gotoxy (1,cy);
      cn; clreol;
      if cnt<=bot then begin
        addprompt (prompt,command,prompt,5,cnt-top+1{+3},things[cnt].text+':');
        setinputwid (prompt,0);
        drawprompt (prompt);
        gotoxy (1,cy);
        cn; write (cnt:2,'. ');
        gotoxy (dcol,wherey);
        writevar (cnt)
      end
    end
  end
end;

procedure readdata;
var q:text;
    t:mstr;

  procedure dataerror (n:lstr);
  begin
    writeln ('Record ',numthings,': '+n);
    halt
  end;

  procedure illtype;
  begin
    dataerror ('Invalid type: '+t)
  end;

  procedure getrange (t:mstr; var r1,r2:integer);
  var sp,da,n1,n2:integer;
  begin
    sp:=pos(' ',t);
    r1:=-32767;
    r2:=32767;
    if sp=0 then exit;
    t:=copy(t,sp+1,255);
    if length(t)<1 then exit;
    da:=pos('-',t);
    if (da=1) and (length(t)=1) then exit;
    if da=0 then begin
      r1:=valu(t);
      r2:=r1;
      exit
    end;
    n1:=valu(copy(t,1,da-1));
    n2:=valu(copy(t,da+1,255));
    if da=1 then begin
      r2:=n2;
      exit
    end;
    r1:=n1;
    if da=length(t) then exit;
    r2:=n2
  end;

  procedure gettype (t:mstr; var tt:ttypetype);
  var sp:integer;
      fw:mstr;
  begin
    tt:=ttypetype(0);
    sp:=pos(' ',t);
    if sp=0
      then fw:=t
      else fw:=copy(t,1,sp-1);
    while tt<>badtype do
      begin
        if match(fw,ttypestr[tt]) then exit;
        tt:=succ(tt)
      end;
    tt:=badtype;
    illtype
  end;

begin
  assign (q,'Config.Dat');
  reset (q);
  numthings:=0;
  if ioresult<>0 then dataerror ('File CONFIG.DAT not found!');
  while not eof(q) do begin
    numthings:=numthings+1;
    gotoxy(1,3);write('Reading Item ',numthings,'...');
    with things[numthings] do begin
      readln (q,text);
      readln (q,descrip);
      readln (q,t);
      gettype (t,ttype);
      if ttype=tinteger then getrange (t,r1,r2)
    end
  end;
  close (q);delay(900)
end;

procedure assignptrs;
var cnt:integer;

  procedure s (var q);
  begin
    cnt:=cnt+1;
    things[cnt].p:=@q;
  end;

begin
  cnt:=0;
  with configset do begin
  s (longnam);
  s (shortnam);
  s (sysopnam);
  s (autologi);
  s (forumdi);
  s (textdi);
  s (boarddi);
  s (uploaddi);
  s (textfiledi);
  s (doordi);
  s (overlaypat);       end;
  s (configset.netdir);
  s (configset.bimodemdi);
  s (configset.workdir); with configset do begin
  s (supportedrate);
  s (downloadrate);
  s (defbaudrat);
  s (useco);
  s (hashaye);
  s (modemsetupst);
  s (modemhangupst);
  s (modemdialprefi);
  s (modemdialsuffi);
  s (sysopleve);
  s (numwelcome);
  s (privat);
  s (directvideomod);
  s (checksnowmod);
  s (useconmod);
  s (escinmsg);
  s (bkspinmsg);
  s (normbotcolo);
  s (normtopcolo);
  s (outlockcolo);
  s (splitcolo);
  s (statlinecolo);
  s (usertim);
  s (mintimeou);
  s (dotcha);
  s (asciidownloa);
  s (defudleve);
  s (defudpoint);
  s (staleve);
  s (stapoint);
  s (level2n);
  s (udlevel2n);
  s (udpoints2n);
  s (uploadfacto);
  s (timepercentbac);
  s (availtim);
  s (unavailtim);
  s (xmodemopentim);
  s (xmodemclosetim);  end;
  s (configset.startpriv);
  s (configset.stoppriv);
  s (configset.privlevel);
  s (configset.anonymousst);
  s (configset.requireform);
  s (configset.man2);
  s (configset.man3);
  s (configset.man4);
  s (configset.man5);
  s (configset.remotedoor);
  s (configset.allowdoor);
  s (configset.demons);
  s (configset.usetimebank);
  s (configset.userume);
  s (configset.useonelin);
  s (configset.usezip);  with configset do begin
  s (normenu);
  s (whissl);
  s (eventtim);
  s (eventbatc);
  s (matrixtyp);
  s (systempasswor);
  s (syste2);
  s (syste3);
  s (newuserpas);
  s (sysop);
  s (emchatp);
  s (loginheade);
  s (minpc);
  s (minudrati);
  s (minud);
  s (exemptpc);
  s (defleve);
  s (deffil);
  s (deffp);
  s (defgfil);
  s (defgp);
  s (defac);
  s (edito);
  s (entercha);
  s (exitcha);
  s (leechwee);
  s (chatmatr);
  s (feedmatr);
  s (sysopi);
  s (sysopo);
  s (anonymousleve);
  s (postleve);
  s (listleve);
  s (lastleve);
  s (comd1);
  s (comd2);
  s (comd3);
  s (comd4);
  s (comd5);
  s (comd6);
  s (comd7);
  s (comd8);
  s (prom);
  s (desc1);
  s (desc2);
  s (desc3);
  s (desc4);
  s (desc5);
  s (desc6);
  s (desc7);
  s (desc8);
  s (msg2nx);
  s (demoname);
  s (leechud);
  s (leechk);
  s (answ1);              end;
  s (configset.totalallowed);
  s (configset.levelusetb);
  s (configset.leveltoaddrume);
  s (configset.minfreesp);
  s (configset.totform);
  s (configset.inf1);
  s (configset.inf2);
  s (configset.inf3);
  s (configset.inf4);
  s (configset.inf5);
  s (configset.netstart);
  s (configset.netend);
  s (configset.famday);
  s (configset.netstc);
  s (configset.netenc);
  s (configset.netpas);
  s (configset.copre);
  s (configset.cosuf);
  s (configset.dszlog);
  s (configset.logsize);
  s (configset.defstacolor);
  s (configset.definput);
  s (configset.defpromp);
  s (configset.defreg);
  s (configset.defblowin);
  s (configset.defblowbor);
  s (configset.autouls);
  s (configset.pointcomp);
  s (configset.pathfnme);
  s (configset.usems);
  s (configset.hangonew);
  s (Configset.Origin1);
  S (Configset.Origin2);
  S (Configset.HubBBS);
  S (Configset.MaximumDosShell);
  S (Configset.LockOutBaudPass);
  S (Configset.UsePrinterLog);
  S (ConfigSet.SaveScreen);
  s (ConfigSet.NumConfs);
  S (ConfigSet.Conf1);
  S (ConfigSet.Conf2);
  S (ConfigSet.Conf3);
  S (ConfigSet.Conf4);
  S (ConfigSet.Conf5);
  s (ConfigSet.NetType1);
  S (ConfigSet.NetType2);
  S (ConfigSet.NetType3);
  S (ConfigSet.NetType1Path);
  S (ConfigSet.ShowNewPrompts);
  s (configset.multinodebbs);
	S (ConfigSet.NodeNumber);
	S (ConfigSet.GatePass);
	s (configset.sys1pwpromp);
	s (configset.sys2pwpromp);
	s (configset.sys3pwpromp);
	s (configset.matnamepromp);
	s (configset.mathangup);
	s (configset.invalidpromp);
	S (ConfigSet.MinGfileUd);
	S (ConfigSet.MinGfilePCR);
  if cnt<>numthings then begin
    writeln ('Error in number of items of CONFIG.DAT');
    writeln ('Expected: ',numthings);
    writeln ('Actual:   ',cnt);
    halt
  end
end;

procedure byebye;
begin
  setcurwindow(w2);
  closewindow;
  setcurwindow(w1);closewindow;
  textmode(co80);
  setcolor(15);
  gotoxy(29,24);
  writeln ('Thank''s for choosing L.S.D!');
  halt
end;

procedure abortyn;
var q:sstr;
    w3:window;
    yesn:boolean;
    k:char;
begin
  yesn:=false;
  openwindow(w3,18,10,50,14,15*4,15*4);
  setcurwindow(w3);
  setcolor(15*4+3);gotoxy(3,1);write('   Abort Configuration');
  repeat
  gotoxy(3,3); setcolor(15*4+3); if yesn then setcolor(barcolor);
  write(' Yes ');setcolor(15*4+3);gotoxy(25,3); if not yesn then setcolor(barcolor);
  write(' No ');
  k:=bioskey;
  if (k=#205) or (K=#131) then yesn:=false;
  if (k=#203) or (k=#130) then yesn:=true;
  if (k='y') or (k='Y') then yesn:=true;
  if (k='n') or (k='N') then yesn:=false;
  until (k=#27) or (k=#13);
  closewindow;setcurwindow(w1);
  if yesn then byebye;
end;

procedure getinput (n:integer; editit:boolean);
var y:integer;
    inp:lstr;
    t:thing;
    pu:pointer;
    p:ptrset absolute pu;

  procedure reshow;
  begin
    gotoxy (dcol,y-2);
    writevar (n)
  end;

  procedure showintrange;
  begin
    c7; setcurwindow(w2); gotoxy(1,2);   clreol;
    with t do
      if r1=-32767
        then if r2=32767
          then write ('No range limitation.')
          else write ('Maximum value: ',r2)
        else if r2=32767
          then write ('Minimum value: ',r1)
          else write ('Valid values range from ',r1,' to ',r2);
    cn; setcurwindow(w1);
  end;
  procedure showbaudrange;
  begin      setcurwindow(w2);
    c7;                  gotoxy(1,2);clreol;
    write('Baud Rates Supported between 300-38400');
    cn  ; setcurwindow(w1);
  end;


  procedure doint;
  var n,s:integer;
      k:char;
  begin
    val (inp,n,s); setcurwindow(w2);
    gotoxy (1,2);
    if s<>0
      then
        begin
          c4;
          writeln ('Invalid number!  A number must be from -32767 to 32767.');
          cn;
          write ('Press any key...');
          clreol;
          k:=bioskey
        end
      else if (n>=t.r1) and (n<=t.r2)
        then p.i^:=n
        else
          begin
            c4;
            writeln ('Range error!  Must be within the above limits!  ');
            cn;
            write ('Press any key...');
            clreol;
            k:=bioskey
          end; setcurwindow(w1);
  end;

  procedure dostr;
  begin
    if (inp='N') or (inp='n') then inp:='';
    p.l^:=inp
  end;

  procedure doword;
  var   tpp1,tpp2:word;
        k:char;
   begin
      tpp1:=valu(inp);
      tpp2:=configset.defbaudrat; setcurwindow(w2);
      gotoxy(1,2);  clreol;
      if (tpp1<300) or (tpp1>57600) then begin
         c4;
         writeln('Error - Must be in above ranges');
         cn;
         write('Press any key...');
         clreol;
         setcurwindow(w1);reshow;
         k:=bioskey;
         exit;
      end;   with configset do
      case tpp1 of
           300:defbaudrat:=300;
           1200:defbaudrat:=1200;
           2400:defbaudrat:=2400;
           4800:defbaudrat:=4800;
           9600:defbaudrat:=9600;
           19200:defbaudrat:=19200;
           38400:defbaudrat:=38400;
           57600:defbaudrat:=57600;
           end;
      if (tpp2=configset.defbaudrat) and (tpp1<>configset.defbaudrat) then begin
         c4;
         writeln('Error, valid ranges are 300,1200,2400,4800,9600,19200,38400,57600!');
         cn;
         write('Press any key...');
         clreol;
         k:=bioskey;
      end;  setcurwindow(w1);reshow;
   end;

  procedure doboolean;
   var k:char;
  begin
    p.b^:=not p.b^;
    if inp='AA' then k:=readkey;
  end;

  procedure dochar;
  begin
    p.k^:=inp[1]
  end;

  procedure dopath;
  var lc:char;
      cur:lstr;
      n:integer;
  begin
    if inp='' then inp:=p.l^;
    lc:=inp[length(inp)];
    if (length(inp)<>1) or (upcase(lc)<>'N')
      then if (lc<>':') and (lc<>'\') then inp:=inp+'\';
    dostr;
    inp:=p.l^;
    if inp[length(inp)]='\' then inp[0]:=pred(inp[0]);
    getdir (0,cur);
    chdir (inp);
    n:=ioresult;
    chdir (cur);
    if n=0 then exit;
    c4; setcurwindow(w2);gotoxy (1,2);
    write ('Path doesn''t exist!  ');
    cn; write ('Create it now? '); clreol;
    readln (cur);    setcurwindow(w1);
    if length(cur)=0 then exit;
    if upcase(cur[1])<>'Y' then exit;
    mkdir (inp);
    if ioresult=0 then exit;
    setcurwindow(w2);
    gotoxy (1,2);
    c4; write ('Error creating directory!  ');
    cn; write ('Press any key...');
    clreol;
    lc:=bioskey;setcurwindow(w1);
  end;

  procedure dotime;
  var c,s,l:integer;
      d1,d2,d3,d4:char;
      ap,m:char;

    function digit (k:char):boolean;
    begin
      digit:=ord(k) in [48..57]
    end;

  begin
    l:=length(inp);
    if l=1 then begin
      if upcase(inp[1])='N' then dostr;
      exit
    end;
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
       and digit(d4) and ((ap='A') or (ap='P')) and (m='M') then dostr
  end;

  procedure dobaud;
  var inp:lstr;
      n:longint;
      cnt:baudratetype;
  label bfound,again;
  begin   setcurwindow(w2);
    gotoxy (1,2);
    repeat
      gotoxy (1,2);
      write ('Baud rate to toggle [CR to quit]: ');
      clreol;
      buflen:=5;
      readln (inp);
      gotoxy (1,2);
      if length(inp)=0 then begin setcurwindow(w1);exit;end;
      n:=valu(inp);
      for cnt:=b110 to b57600 do if n=baudarray[cnt] then goto bfound;
      cb; write ('Not supported!  '); cn;
      goto again;
      bfound:
      if cnt in p.baudsetptr^
        then p.baudsetptr^:=p.baudsetptr^-[cnt]
        else p.baudsetptr^:=p.baudsetptr^+[cnt];
      setcurwindow(w1);
      reshow; setcurwindow(w2);
      again:
    until 0=1
  end;

  procedure dousertime;
  var input:lstr;
      n:integer;
      buffer,buffer2:array [1..10092] of byte;
      b,b2:block;

    procedure refresh;
    var cnt:integer;
    begin
      clearwindow (11);
      gotoxy (1,1);
     { cn; } setcolor(11);
      writeln('Level Time | Level Time | Level Time | Level Time | Level Time');
      writeln('-----------|------------|------------|------------|-----------');
      gotoxy (1,3);
      for cnt:=1 to 100 do begin
        write (cnt:4,': ',configset.usertim[cnt]:4);
        if (cnt mod 5)=0 then writeln else write (' | ')
      end
    end;

    procedure setone (n,v:integer);
    var x,y:integer;
    begin
      x:=((n-1) mod 5)*13+7;
      y:=((n-1) div 5)+3;
      gotoxy (x,y);
      write (v:4);
      configset.usertim[n]:=v
    end;

    procedure getone (n:integer);
    var x,y,v:integer;
    begin
      x:=((n-1) mod 5)*13+7;
      y:=((n-1) div 5)+3;
      gotoxy (x,y);
      write ('    ');
      gotoxy (x,y);
      buflen:=4;
      readln (input);
      v:=valu(input);
      if (v<1) or (v>1000) then v:=configset.usertim[n];
      setone (n,v)
    end;

    function getn (txt:lstr):integer;
    var input:lstr;
    begin
      gotoxy (1,23);
      write (txt,': ');
      clreol;
      buflen:=4;
      readln (input);
      getn:=valu(input)
    end;

    function getlvl (txt:lstr):integer;
    var n:integer;
    begin
      n:=getn (txt);
      if (n<1) or (n>100) then n:=0;
      getlvl:=n
    end;

    procedure pattern;
    var st,en,ba,se,cn:integer;
    begin
      st:=getlvl ('Starting level of pattern');
      if st=0 then exit;
      en:=getlvl ('Ending level of pattern');
      if en<st then exit;
      ba:=getn ('Time for level '+strr(st));
      if (ba<1) or (ba>1000) then exit;
      se:=getn ('Additional time per level');
      if (se<0) or (se>1000) then exit;
      cn:=st;
      repeat
        setone (cn,ba);
        if ba+se<1000
          then ba:=ba+se
          else ba:=1000;
        cn:=cn+1
      until cn>en
    end;

  var k:char;
  begin
    if not highres then begin
    setblock (b,1,1,80,20);
    readblock (b,buffer);
    setblock(b2,1,20,80,25);
    readblock(b2,buffer2);
    end else begin
    setblock (b,1,1,80,37);
    readblock(b,buffer);
    setblock(b2,1,37,80,43);
    readblock(b2,buffer2);
    end;
    setcurwindow(w2);
    closewindow; setcurwindow(w1); closewindow;
    if highres then textmode(bw80);
    refresh;
    repeat
      repeat
        gotoxy (1,24);
        write ('Number to change, [P] for a pattern, or [Q] to quit: ');
         readln (input)
      until length(input)>0;
      k:=upcase(input[1]);
      n:=valu(input);
      if (n>=1) and (n<=100) then getone(n) else
        case k of
          'P':pattern
        end
    until k='Q';
    if highres then textmode(c80+font8x8);
    if not highres then begin
    openwindow(w1,1,1,80,20,127,127);
    openwindow(w2,1,21,80,25,112,127);   end else
    begin openwindow(w1,1,1,80,37,127,127);
    openwindow(w2,1,38,80,43,112,127);
    end;
    {setcurwindow(w1);} setcurwindow(w1);
    writeblock (b,buffer);
    setcurwindow(w2); writeblock(b2,buffer2);
  end;

  procedure doattrib;


    function demo:integer;
      var cnt:integer;
          K:char;
          w3:window;
    begin
         openwindow(w3,18,9,50,14,15,15);
         setcurwindow(w3);
         gotoxy(5,1);
         setcolor(15);
         write('  Color Selection');
         gotoxy(10,3);
         for cnt:=0 to 15 do begin
           setcolor(cnt);
           write('Û');
           end;
           cnt:=0;
           repeat
            gotoxy(10+cnt,2);
            setcolor(15);
            write('');
            gotoxy(2,3);setcolor(cnt);
            if cnt=0 then
            begin
            setcolor(16*7); write('Black');
            setcolor(cnt); write('   ');
            end else
            write(colorstr[cnt]);
            k:=bioskey;
            if (k=#205) or (K=#131) then begin
               gotoxy(cnt+10,2);write(' ');
               cnt:=cnt+1;
               if cnt>15 then cnt:=0;
               end else if (k=#203) or (k=#130) then begin
               gotoxy(cnt+10,2);write(' ');
               cnt:=cnt-1;
               if cnt<0 then cnt:=15;
               end;
            until (k=#13) or (k=#27);
            if k=#13 then demo:=cnt
             else demo:=p.i^;
      closewindow;
      setcurwindow(w1);
    end;

  var cnt,v:integer;
      k:char;
  begin
    v:=demo;
    p.i^:=v;
  end;

begin
  t:=things[n];
  pu:=t.p;
  gotopage (whichpage(n));
  y:=whichline(n);
  if not (t.ttype in [tbaudset,tusertime,tattrib,tboolean]) then begin
    setcurwindow(w2);
    gotoxy (1,1);
    clreol;
    write (t.descrip);
    clreol;
    gotoxy (1,3);
    case t.ttype of
      tinteger:
        begin
          buflen:=6;
          showintrange
        end;
      tsstr,ttime:buflen:=15;
      tmstr:buflen:=35;
      tlstr,tpath:buflen:=80;
      tchar:buflen:=1;
      tword:begin
            buflen:=6;
            showbaudrange;
      end;
    end;
    if buflen+dcol>79 then buflen:=79-dcol;
    setcurwindow(w1);
    gotoxy (dcol,y-2);
    clreol;
    { if editit then setdefaultinput (varstr(n));}
    readln (inp)
  end else inp[0]:=^A;
  if editit and (t.ttype=tboolean) then inp:='AA';
  if t.ttype=tpath then dopath;
  if length(inp)<>0 then
    case t.ttype of
      tinteger:doint;
      tsstr,tmstr,tlstr:dostr;
      tboolean:doboolean;
      tchar:dochar;
      tbaudset:dobaud;
      ttime:dotime;
      tattrib:doattrib;
      tword:doword;
      tusertime:dousertime
    end;
  reshow; setcurwindow(w2);
  gotoxy (1,2);
  clreol;
  writeln;
  clreol;
  writeln;
  clreol;    setcurwindow(w1);
  t.p:=pu;
  things[n]:=t
end;

procedure changenum (ns:integer; editit:boolean);
var n:integer;
begin
  n:=ns+top-1;
  if (n<1) or (n>numthings) then exit;
  setcurwindow(w2);gotoxy(1,1);cn;clreol;write(things[n].descrip);
  setcurwindow(w1); getinput(n,editit);
end;

procedure maybemakeconfig;
var f:file of configsettype;
    s,w:integer;
begin
  s:=ofs(configset.fille)-ofs(configset.versioncod);
  w:=sizeof(configsettype);
  if s>w then begin
    writeln;
    writeln ('****** ERROR: CONFIGSETTYPE is too short!');
    writeln ('              Size of configuration is: ',s);
    writeln ('                   Bytes being written: ',w);
    writeln;
    halt
  end;
  assign (f,'Config.bbs');
  reset (f);
  if ioresult=0 then begin
    close (f);
    exit
  end;
  fillchar (configset,sizeof(configset),0);
  formatconfig
end;

var command:sstr;
    i:integer;
    ken:char;
begin
  highres:=false;
  if match(paramstr(1),'/5') then highres:=true;
  if not highres then begin
    clrscr;
    write('Would you like to use High Res EGA/VGA Mode? [y/N]');
    ken:=readkey;
    if (ken='y') or (ken='Y') then highres:=true;
  end;
  if highres then textmode(c80+font8x8) else textmode (BW80);
  initscrnunit; { openwindow(w1,1,1,80,20,127,112); openwindow(w2,1,21,80,25,112,127);delay(10000);}
  curwindowptr^.normalcolor:=normalcolor;
  curwindowptr^.boldcolor:=boldcolor;
  curwindowptr^.barcolor:=barcolor;
  curwindowptr^.inputcolor:=inputcolor;
  curwindowptr^.choicecolor:=choicecolor;
  curwindowptr^.datacolor:=datacolor;
  gotoxy (1,1); setcolor(15);
  writeln ('One moment...');
  gotoxy(20,10);setcolor(11);write(' L.S.D. BBS Systems (c) 1990 ');
  gotoxy(20,12);setcolor(12);write('   (c) 1990 TL Enterprises');setcolor(15);
  gotoxy(20,14);setcolor(14);write(' System Configuration ver 2.0 ');setcolor(15);
  readdata;
  assignptrs;
  maybemakeconfig;
  readconfig;
  i:=ioresult;
  numpages:=whichpage(numthings);
  page:=0;
  if not highres then begin openwindow(w1,1,1,80,20,127,127);
  openwindow(w2,1,21,80,25,112,127);
  end else begin openwindow(w1,1,1,80,37,127,127);
  openwindow(w2,1,38,80,43,112,127); setcurwindow(w2);
  gotoxy(17,4);
  setcolor(boldcolor+3);
  write('   L.S.D. Systems Configuration v'+versionnum);
  end;
  gotopage (1);
  repeat
    setfilter (configset.checksnowmod);
    setcurwindow(w2);
    gotoxy (1,3); setcolor(boldcolor);
    write ('F1: Edit entry  F10: Save/exit  PgUp: Last page  PgDn: Next page  Esc: Abort');
    setcurwindow(w1);
    i:=useprompts(prompt);
    setcurwindow(w2);gotoxy(1,1);clreol;cn;write(things[i+top-1].descrip);
    setcurwindow(w1);
    if bioslook in [#32..#126]
      then changenum (i,true)
      else case bioskey of
        #187:begin          gotoxy (1,1);
            write (i);
            changenum (i,true);
        end;
        #196:begin
               writeconfig;
               byebye
             end;
        #27:abortyn;
        #13:changenum (i,false);
        #201:gotopage (page-1);
        #209:gotopage (page+1)
      end
  until 0=1
end.


1) di (x,y);
      buwriteg lI;
  pu:=t.p;S1) ;
  1) or (v>1000) then v:=confi ');setcolor(15);
  readdata;
  assignptrs;
  maybemakeconfig;ction getn (txt:lstr):integer;
    var input:lstr;
    begin
 ip);
    clreohig;ction gCPtcurwindow(w2);
  gotoxy(17,4);
  ²fig;ctitr;
 Ûnput (vartion getn (tx=setfig;
  readco untiock(b2,bun:=getlvl ('Ending levettern, or [Q] to quit: '2e(' 'len:=6;
    ba+se
          $      tword:begin
           );
    write ('F1: Edit entry  F10: Save/exit  PgUp: Last page  PgDn: Next page  Esc: Abort');
    setcurwindow(w1);
    i:=use§;
    write ('F1: V           à     à     à     à     à     à     à   cnt:=cnt-1;
ortyn;
   ;
        setcurwindow(w2); writeblock(k:=bioskeyage (page+2);
 tsstr,tmstr,,,e    end;
ar k:chat                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
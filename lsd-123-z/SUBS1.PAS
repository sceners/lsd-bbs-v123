{$R-,S-,I-,D-,F+,V-,B-,N-,L+ }

unit subs1;

interface

uses crt,dos,printer,
		 gensubs,gentypes,statret,configrt,modem;

var firstvariable,CurrentConference,HackAttempts:byte;

    local,online,chatmode,disconnected:boolean;
		conpostsa,congfilesa:longint;
    unum,ulvl : integer;
    baudrate,connectbaud:word;
		unam,baudstr:mstr;
		parity:boolean;
		urec:userrec;
		logontime,logofftime,logonunum:integer;
		laston:longint;

    dots,nochain,break,xpressed,mens,
    requestchat,requestcom,requestbreak,reqspecial,forcehangup,
    modeminlock,modemoutlock,timelock,tempsysop,splitmode,
    fromdoor,printerecho,uselinefeeds,usecapsonly,
    dontstop,nobreak,wordwrap,beginwithspacesok,sysnext,ingetstr:boolean;
    regularlevel,numusers,curboardnum,lasty,
    linecount,curattrib,
    firstfree,lockedtime,iocode,buflen:integer;
    screenseg:word;
    cursection:configtype;
    curboardname:sstr;
    input,chainstr:anystr;
    chatreason,lastprompt,errorparam,errorproc:lstr;
    curboard:boardrec;
    mes:message;
    syslogdat:array [0..maxsyslogdat] of syslogdatrec;
    numsyslogdat:integer;
    returnto:char;

    lastvariable:byte;

    usr,direct,directin:text;

const numsysfiles=20;
      blanks = '                                                                         ';
var tfile:file of buffer;
    mapfile:file of integer;
    ufile:file of userrec;
    uhfile:file of mstr;
    mfile:file of mailrec;
    udfile:file of udrec;
    afile:file of arearec;
    bfile:file of bulrec;
    bdfile:file of boardrec;
    bifile:file of sstr;
   { ffile:file of filerec;}
    tofile:file of topicrec;
    chfile:file of choicerec;
    ddfile:file of baserec;
    efile:file of entryrec;
    dofile:file of doorrec;
    gfile:file of grouprec;
    logfile:file of logrec;
    abfile:file of abrec;
    usfile:file of userspecsrec;
    sysfiles:array [1..numsysfiles] of file absolute tfile;
    ttfile:text;

procedure dohackshit;
procedure writelog (m,s:integer; prm:lstr);
procedure files30;
function ioerrorstr (num:integer):lstr;
procedure error (errorstr,proc,param:lstr);
procedure fileerror (procname,filename:mstr);
procedure che;
function timeleft:integer;
function timetillevent:integer;
procedure settimeleft (tl:integer);
procedure tab (n:anystr; np:integer);
function yes:boolean;
function yesno (b:boolean):sstr;
function timeontoday:integer;
function isopen (var ff):boolean;
procedure textclose (var f:text);
procedure close (var ff);
function withintime (t1,t2:sstr):boolean;
function hungupon:boolean;
function sysopisavail:boolean;
function sysopavailstr:sstr;
function singularplural (n:integer; m1,m2:mstr):mstr;
function s (n:integer):sstr;
function numthings (n:integer; m1,m2:mstr):lstr;
procedure thereisare (n:integer);
procedure thereare (n:integer; m1,m2:mstr);
procedure assignbdfile;
procedure openbdfile;
procedure formatbdfile;
procedure closebdfile;
procedure opentempbdfile;
procedure closetempbdfile;
function keyhit:boolean;
function bioskey:char;
procedure readline (var xx);
procedure writereturnbat;
procedure ensureclosed;
procedure clearbreak;
procedure ansicolor (attrib:integer);
procedure ansireset;
function timetillnet:integer;
procedure specialmsg (q:anystr);
procedure writedataarea;
procedure readdataarea;
procedure blowup(a,b,c,d:integer);
{procedure clearscr;}
procedure printxy(a,b:integer; c:lstr);
procedure fuckup(a,b,c,d:integer);
procedure fuckxy(a,b:integer; m:string);
procedure printzy(a,b:integer; c:lstr);
procedure boxit(a,b,c,d:integer);

implementation

procedure boxit(a,b,c,d:integer);
var cnt,tmp:integer;
begin
 if not (break or xpressed) then write(direct,#27,'[',a,';',b,'H');
 write('Õ');
  for cnt:=1 to c-2 do write('Í');
 write('¸');
 for tmp:=1 to d-2 do begin
       if not (break or xpressed) then write(direct,#27,'[',A+tmp,';',b,'H');
        write('³');
       if not (break or xpressed) then write(direct,#27,'[',A+tmp,';',b+c-1,'H');
        write('³');
     end;
    if not (break or xpressed) then write(direct,#27,'[',a+d-1,';',b,'H');
    write('Ô');
    for cnt:=1 to c-2 do write('Í');
    write('¾');
		mens:=false;
 end;

procedure gotoxyand(a,b:integer; m:string);
begin
 if ansigraphics in urec.config then begin
	 write(direct,#27,'[',a,';',b,'H');
	 write(m);
 end else writeln(m);
end;

procedure fuckxy(a,b:integer; m:string);
Begin
  mens:=true;
  nobreak:=false;
	dontstop:=true;
	if not (break or xpressed) then
	 gotoxyand(a,b,m);
	 mens:=false;
end;


procedure fuckup(a,b,c,d:integer);
var cnt,tmp:integer;
begin
 mens:=true;
 nobreak:=false;
 dontstop:=true;
 if not (ansigraphics in urec.config) then exit;
 ansicolor(urec.menuboard);
 boxit(a,b,c,d);
		ansicolor(urec.regularcolor);
		writeln;
		mens:=false;
 end;

procedure printxy(a,b:integer; c:lstr);
Begin
   clearbreak;
   mens:=true;
   nobreak:=true;
   dontstop:=true;
	 if ansigraphics in urec.config then ansicolor(urec.blowinside);
	 gotoxyand(a,b,c);
	 mens:=false;
end;

procedure printzy(a,b:integer; c:lstr);
begin
   clearbreak;
   mens:=true;
   nobreak:=true;
   dontstop:=true;
	 if ansigraphics in urec.config then ansicolor(urec.statcolor);
	 gotoxyand(a,b,c);
	 mens:=false;
end;


procedure blowup(a,b,c,d:integer);
var cnt,tmp:integer;
begin
 clearbreak;
 mens:=true;
 nobreak:=true;
 dontstop:=true;
 if ansigraphics in urec.config then ansicolor(urec.blowboard) else exit;
 boxit(a,b,c,d);
	 mens:=false;
 end;

procedure writelog (m,s:integer; prm:lstr);
var n:integer;
    l:logrec;
    Q:Lstr;

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

begin
  with l do begin
    menu:=m;
    subcommand:=s;
    when:=now;
    param:=copy(prm,1,41)
  end;
  seek (logfile,filesize(logfile));
  write (logfile,l);
  If ConfigSet.UsePrinterLog then Begin
    q:=syslogdat[lookupsyslogdat(l.menu,l.subcommand)].text;
    n:=pos('%',q);
    if n<>0 then q:=copy(q,1,n-1)+l.param+copy(q,n+1,255);
    q:=q+' on '+DateStr(Now)+' - '+TimeStr(now);
    WriteLn(Lst,Q);
  End;
end;

procedure files30;
begin
  writeln (usr,'You MUST put FILES=30 in your CONFIG.SYS!');
  closeport;
  halt(4)
end;

function ioerrorstr (num:integer):lstr;
var tf:text;
    tmp1,tmp2:lstr;
    n,s:integer;
begin
  if num=243 then files30;
  assign (tf,'Ioerror.lst');
  reset (tf);
  if ioresult<>0 then begin
    ioerrorstr:='* Can''t open IOERROR.LST *';
    textclose(tf);
    exit
  end;
  while not eof(tf) do begin
    readln (tf,tmp1);
    val (tmp1,n,s);
    if n=num then begin
      readln (tf,tmp2);
      ioerrorstr:=tmp2;
     textclose (tf);
      exit
    end
  end;
  textclose (tf);
  ioerrorstr:='Unidentified I/O error '+strr(num)
end;

procedure error (errorstr,proc,param:lstr);
var p,n:integer;
    pk:char;
    tf:text;
begin
  n:=ioresult;
  repeat
    p:=pos('%',errorstr);
    if p<>0 then begin
      pk:=errorstr[p+1];
      delete (errorstr,p,2);
      case upcase(pk) of
        '1':insert (param,errorstr,p);
        'P':insert (proc,errorstr,p);
        'I':insert (ioerrorstr(iocode),errorstr,p)
      end
    end
	until p=0;
	assign (tf,'ErrLog');
	append (tf);
	if ioresult<>0
		then
			begin
			 textclose (tf);
				rewrite (tf);
				writeln (tf,'                        L.S.D. v1.0 Error Log                   ',datestr(now),' ',timestr(now));
				writeln (tf,'------------------------------------------------------------------------------');
				writeln (tf);
			end;
	if unam='' then
	writeln (tf,'Someone was logging in on ',datestr(now), ' at ',timestr(now),' when:')
	else
	writeln (tf,unam,' was on-line on ',datestr(now),' at ',timestr(now),' when:');
	writeln (tf,errorstr);
	writeln (tf);
	textclose (tf);
	n:=ioresult;
	writelog (0,4,errorstr);
	writeln (errorstr);
	textclose(tf);
end;

procedure fileerror (procname,filename:mstr);
begin
  error ('%I accessing %1 in %P',procname,filename)
end;

procedure che;
var i:integer;
begin
  i:=ioresult;
  case i of
    0:;
    4:files30;
    else
      begin
        iocode:=i;
        error ('Unexpected I/O error %I','','')
      end
  end
end;

function timeleft:integer;
var timeon:integer;
begin
  timeon:=timer-logontime;
  if timeon<0 then timeon:=timeon+1440;
  timeleft:=urec.timetoday-timeon
end;

function timetillevent:integer;
var n:integer;
begin
  if (length(configset.eventtim)=0) or (length(configset.eventbatc)=0) or
    (timedeventdate=datestr(now))
    then n:=1440
    else n:=timeval(configset.eventtim)-timer;
  if n<0 then n:=n+1440;
  timetillevent:=n
end;

function timetillnet:integer;
var n:integer;
  begin
  if ((length(configset.netstc)=0) and (length(Configset.NetStart)=0))
    or
    (neteventdate=datestr(now)) then n:=1440
    else
      If Length(Configset.NetStc)>0 then n:=timeval(configset.netstc)-timer
      Else n:=TimeVal(Configset.NetStart)-timer;
  if n<0 then n:=n+1440;
  timetillnet:=n;
end;

procedure settimeleft (tl:integer);
begin
  urec.timetoday:=timer+tl-logontime;
end;

procedure tab (n:anystr; np:integer);
var cnt:integer;
begin
  write (n);
  for cnt:=length(n) to np-1 do write (' ')
end;

function yes:boolean;
begin
  if length(input)=0
    then yes:=false
    else yes:=upcase(input[1])='Y'
end;

function yesno (b:boolean):sstr;
begin
  if b
    then yesno:='Yes'
    else yesno:='No'
end;

function timeontoday:integer;
var timeon:integer;
begin
  timeon:=timer-logontime;
  if timeon<0 then timeon:=timeon+1440;
  timeontoday:=timeon
end;

function isopen (var ff):boolean;
var fi:fib absolute ff;
begin
  isopen:=fi.handle<>0
end;

procedure textclose (var f:text);
var n:integer;
    fi:fib absolute f;
begin
  if isopen(f)
    then system.close (f);
  fi.handle:=0;
  n:=ioresult
end;

procedure close (var ff);
var f:file absolute ff;
    fi:fib absolute ff;
    n:integer;
begin
  if isopen(f)
    then system.close (f);
  fi.handle:=0;
  n:=ioresult
end;

function withintime (t1,t2:sstr):boolean;
var t,a,u:integer;
begin
  t:=timeval(timestr(now));
  a:=timeval(t1);
  u:=timeval(t2);
  if a<=u
    then withintime:=(t>=a) and (t<=u)
    else withintime:=(t>=a) or (t<=u);
end;

function hungupon:boolean;
begin
  hungupon:=forcehangup or
								(online and not (carrier or modeminlock or modemoutlock))
end;

function sysopisavail:boolean;
begin
  case sysopavail of
    available:sysopisavail:=true;
    notavailable:sysopisavail:=false;
    bytime:sysopisavail:=withintime (configset.availtim,configset.unavailtim)
  end
end;

function sysopavailstr:sstr;
const strs:array [available..notavailable] of string[9]=
        ('Yes','By time: ','No');
var tstr:sstr;
    tmp:availtype;
begin
  tstr:=strs[sysopavail];
  if sysopavail=bytime
    then
      begin
        if sysopisavail
          then tmp:=available
          else tmp:=notavailable;
        tstr:=tstr+strs[tmp]
      end;
  sysopavailstr:=tstr
end;

function singularplural (n:integer; m1,m2:mstr):mstr;
begin
  if n=1
    then singularplural:=m1
    else singularplural:=m2
end;

function s (n:integer):sstr;
begin
  s:=singularplural (n,'','s')
end;

function numthings (n:integer; m1,m2:mstr):lstr;
begin
  numthings:=strr(n)+' '+singularplural (n,m1,m2)
end;

procedure thereisare (n:integer);
begin
  write ('There ');
  if n=1
    then write ('is 1 ')
    else
      begin
        write ('are ');
        if n=0
          then write ('no ')
          else write (n,' ')
       end
end;

procedure thereare (n:integer; m1,m2:mstr);
begin
  thereisare (n);
  if n=1
    then write (m1)
    else write (m2);
  writeln ('.')
end;

procedure assignbdfile;
begin
  If CurrentConference=1 then Begin
  assign (bdfile,configset.boarddi+'boarddir');
  assign (bifile,configset.boarddi+'bdindex');
  End Else Begin
  Assign(Bdfile,ConfigSet.BoardDi+'Boarddir.'+Strr(CurrentConference));
  Assign(BiFile,ConfigSet.BoardDi+'BdIndex.'+Strr(CurrentConference));
  end;
end;

procedure openbdfile;
var i:integer;
begin
  closebdfile;
  assignbdfile;
  reset (bdfile);
  i:=ioresult;
  reset (bifile);
  i:=i or ioresult;
  if i<>0 then formatbdfile
end;

procedure formatbdfile;
begin
  close (bdfile);
  close (bifile);
  assignbdfile;
  rewrite (bdfile);
  rewrite (bifile)
end;

procedure closebdfile;
begin
  close (bdfile);
  close (bifile)
end;

var wasopen:boolean;

procedure opentempbdfile;
begin
  wasopen:=isopen(bdfile);
  if not wasopen then openbdfile
end;

procedure closetempbdfile;
begin
  if not wasopen then closebdfile
end;

function keyhit:boolean;
(*var r:registers;
begin
  r.ah:=1;
  intr ($16,r);
  keyhit:=(r.flags and 64)=0
end;*)
begin
 KeyHit:=KeyPressed;
End;

function bioskey:char;
var r:registers;
begin
  r.ah:=0;
  intr ($16,r);
  if r.al=0
    then bioskey:=chr(r.ah+128)
    else bioskey:=chr(r.al)
end;

procedure readline (var xx);
var a:anystr absolute xx;
    l:byte absolute xx;
    k:char;

  procedure backspace;
  begin
    if l>0 then begin
      write (usr,^H,' ',^H);
      l:=l-1
    end
  end;

  procedure eraseall;
  begin
    while l>0 do backspace
  end;

  procedure addchar (k:char);
  begin
    if l<buflen then begin
      l:=l+1;
      a[l]:=k;
      write (usr,k)
    end
  end;

begin
  l:=0;
  repeat
    k:=bioskey;
    case k of
      #8:backspace;
      #27:eraseall;
      #32..#126:addchar(k)
    end
  until k=#13;
  writeln (usr)
end;

procedure writereturnbat;
var tf:text;
    bd:word;
    tmp:lstr;
begin
  assign (tf,'return.bat');
  rewrite (tf);
  getdir (0,tmp);
  writeln (tf,'cd '+tmp);
  if unum=0
    then begin
      writeln (tf,'PAUSE   ***  No one was logged in!');
      writeln (tf,'keepup')
    end else begin
      if online then bd:=baudrate else bd:=0;
      bd:=connectbaud;
      if not carrier then bd:=0;
      writeln (tf,'keepup ',unum,' ',bd,' ',ord(parity),' M')
    end;
  textclose (tf);
  writeln (usr,'  ( Type RETURN To Return To LSD! )')
end;

procedure ensureclosed;
var cnt,i:integer;
begin
  stoptimer (numminsidle);
  stoptimer (numminsused);
  writestatus;
  textclose (ttfile);
  i:=ioresult;
  for cnt:=1 to numsysfiles do begin
    close (sysfiles[cnt]);
    i:=ioresult
  end
end;

procedure clearbreak;
begin
  break:=false;
  xpressed:=false;
  dontstop:=false;
  nobreak:=false
end;

procedure ansicolor (attrib:integer);
var tc:integer;
    m:mstr;
const colorid:array [0..7] of byte=(30,34,32,36,31,35,33,37);
begin
  if attrib=0 then begin
    textcolor (7);
    textbackground (0)
  end else begin
    textcolor (attrib and $8f);
    textbackground ((attrib shr 4) and 7)
  end;
  if not (ansigraphics in urec.config) or (attrib=0) or (usecapsonly)
     or (attrib=curattrib) or break then exit;
  curattrib:=attrib;
  m:=#27+'[0';
  tc:=attrib and 7;
  if tc<>7 then m:=m+';'+strr(colorid[tc]);
  tc:=(attrib shr 4) and 7;
  if tc<>0 then m:=m+';'+strr(colorid[tc]+10);
  if (attrib and 8)=8 then m:=m+';1';
  if (attrib and 128)=128 then m:=m+';5';
  m:=m+'m';
  write (direct,m)
end;

procedure ansireset;
begin
  textcolor (7);
  textbackground (0);
  if usecapsonly then exit;
  if urec.regularcolor<>0 then begin
    ansicolor (urec.regularcolor);
    exit
  end;
  if (not (ansigraphics in urec.config)) or (curattrib=0) or break then exit;
  write (direct,#27'[0m');
  curattrib:=0
end;

procedure specialmsg (q:anystr);
begin
  textcolor (configset.outlockcolo);
  textbackground (0);
  writeln (usr,q);
  if not modemoutlock then textcolor (configset.normbotcolo)
end;

procedure readdataarea;
var f:file of byte;
begin
  assign (f,'General.dat');
  reset (f);
  if ioresult<>0
    then unum:=-1
    else begin
      dos.filerec(f).recsize:=ofs(lastvariable)-ofs(firstvariable);
      read (f,firstvariable);
      close (f)
    end
end;

procedure writedataarea;
var f:file of byte;
begin
  assign (f,'General.dat');
  rewrite (f);
  dos.filerec(f).recsize:=ofs(lastvariable)-ofs(firstvariable);
  write (f,firstvariable);
  close (f)
end;

procedure dohackshit;
Begin
	WriteLog(22,HackAttempts,Urec.Handle);
	Case HackAttempts of
		 2:WriteLn(^M^S^G'Nice Try!');
		 3:WriteLn(^M^S^G'Don''t do that again!');
		 4:Begin
				WriteLn(^M^S^G'We warned you!');
				SetTimeLeft(-1);
				Delay(500);
				ForceHangup:=True;
				HangUp;
				End;
		 End;
	End;

begin
HackAttempts:=0;
end.

{$R-,S-,I-,D-,F+,V-,B-,N-,L+ }

unit subs2;

{ $define testingdevices}   (* Activate this define for test mode *)

interface

uses printer,dos,crt,gentypes,configrt,gensubs,subs1,windows,modem,statret,chatstuf,
     flags,menus;

procedure beepbeep;
procedure summonbeep;
procedure openttfile;
procedure writecon (k:char);
procedure toggleavail;
function charready:boolean;
function readchar:char;
function waitforchar:char;
procedure clearchain;
function charpressed (k:char):boolean;  { TRUE if K is in typeahead }
procedure addtochain (l:lstr);
procedure directoutchar (k:char);
procedure handleincoming;
procedure writechar (k:char);
{$F+}
      function opendevice (var t:textrec):integer;
      function closedevice (var t:textrec):integer;
      function cleardevice (var t:textrec):integer;
      function ignorecommand (var t:textrec):integer;
      function directoutchars (var t:textrec):integer;
      function writechars (var t:textrec):integer;
      function directinchars (var t:textrec):integer;
      function readcharfunc (var t:textrec):integer;
{$F+}
function getinputchar:char;
procedure getstr;
procedure writestr (s:anystr);
procedure cls;
procedure writehdr (q:anystr);
function issysop:boolean;
procedure reqlevel (l:integer);
procedure printfile (fn:lstr);
procedure printtexttopoint (var tf:text);
procedure skiptopoint (var tf:text);
function minstr (blocks:integer):sstr;
procedure parserange (numents:integer; var f,l:integer);
function menu (mname:mstr; mfn:sstr; choices:anystr):integer;
function checkpassword (var u:userrec):boolean;
function getpassword:boolean;
function getsysoppwd:boolean;
procedure getacflag (var ac:accesstype; var tex:mstr);
{ procedure drawbox (x1,y1,x2,y2:byte;fill:boolean);
function pulldown (itemlist:menutype;
                   win:byte;              Pull Down Window Routines
                   sel:byte;
                   x1,y1,x2,y2:byte;
                   startitem:byte):integer;
function lrmenu (menu:lrmenutype;topc,barc:byte):integer; }
procedure updatenodestatus(Ls:Lstr);

implementation

procedure beepbeep;
begin
  nosound;
  sound (200);
  delay (10);
  sendchar(#7);
  nosound
end;

procedure summonbeep;
var cnt:integer;
begin
  nosound;
  cnt:=1330;
  repeat
    sound (cnt);
    delay (10);
    cnt:=cnt+200;
  until cnt>4300;
  nosound
end;

{procedure abortttfile (er:integer);
var n:integer;
begin
  specialmsg ('<Texttrap error '+strr(er)+'>');
  texttrap:=false;
  textclose (ttfile);
  n:=ioresult
end; }

procedure openttfile;
var n:integer;
begin
  appendfile ('Texttrap',ttfile);
{  n:=ioresult;
  if n=0
    then texttrap:=true
    else abortttfile (n)}
end;

procedure writecon (k:char);
var r:registers;
begin
   if k=^J
    then write (usr,k)
    else
      begin
        r.dl:=ord(k);
        r.ah:=2;
        intr($21,r)
      end
end;

procedure toggleavail;
begin
  if sysopavail=notavailable
    then sysopavail:=available
    else sysopavail:=succ(sysopavail)
end;

function charready:boolean;
var k:char;
begin
	if modeminlock then while numchars > 0 do k:= getchar;
  if hungupon or keyhit
    then charready:=true
    else if online
			then charready:=(not modeminlock) and (numchars > 0)
      else charready:=false
end;

function readchar:char;

  procedure toggletempsysop;
  begin
    if tempsysop
      then ulvl:=regularlevel
      else
        begin
          regularlevel:=ulvl;
          ulvl:=configset.sysopleve
        end;
    tempsysop:=not tempsysop
  end;

  procedure togviewstats;
  begin
    if splitmode
      then unsplit
      else
        begin
					splitscreen (10);
					top;
					clrscr;
					write (usr,'File Level:     ',urec.udlevel,
								 ^M^J'File Points:    ',urec.udpoints,
								 ^M^J'XMODEM uploads: ',urec.uploads,
								 ^M^J'XMODEM dnloads: ',urec.downloads,
								 ^M^J'Account Note:   ',urec.usernote,
								 ^M^J'Download K:     ',Urec.DnKay,
								 ^M^J'Post/Call Ratio:',Ratio(Urec.Nbu,Urec.NumOn),'%',
								 ^M^J'Special Note:   ',urec.specialsysopnote);
          GotoXy(40,1);Write(Usr,'Posts:      ',urec.nbu);
          gotoxy(40,2);Write(Usr,'G-File Uls: ',urec.Nup);
          GotoXy(40,3);Write(Usr,'G-File Dls: ',urec.Ndn);
          GotoXy(40,4);Write(Usr,'Total Time: ',urec.totaltime:0:0);
          GotoXy(40,5);Write(Usr,'Num. Calls: ',urec.Numon);
					GotoXy(40,6);Write(Usr,'Upload K:   ',Urec.UpKay);
					GotoXy(40,7);Write(Usr,'U/D Ratio:  ',Ratio(Urec.Uploads,Urec.Downloads),'%');
				end;
  end;

  procedure showhelp;
  begin
    if splitmode
      then unsplit
      else begin
        splitscreen (11);
        top;
        clrscr;
        write (usr,'                  L.S.D. BBS Online Help'^M^J,
'Chat with user: F1 or F3         Sysop commands: F2'^M^J,
'Sysop gets the system next: F7   Lock the timer: F8'^M^J,
'Lock out all modem input: F9     Lock all modem output: F10'^M^J,
'Chat availabily toggle: Alt-A    Grant temporary sysop powers: Alt-T'^M^J,
'Grant user more time: Alt-M      Take away user''s time: Alt-L'^M^J,
'Take away ALL time: Alt-K        Refresh the bottom line: Alt-B'^M^J,
'Toggle printer echo: Ctrl-PrtSc  Toggle text trap: Alt-E'^M^J,
'View user''s status: Alt-V        Quick Hangup On user :Alt-N');
    end;
  end;


var k:char;
    ret:char;
    dorefresh:boolean;
    temocont:integer;
begin
  requestchat:=false;
  requestcom:=false;
  reqspecial:=false;
  if keyhit
    then
      begin
        k:=bioskey;
        ret:=k;
        if ord(k)>127 then begin
          ret:=#0;
          dorefresh:=ingetstr;
          case ord(k)-128 of
            availtogglechar:
              begin
                toggleavail;
                chatmode:=false;
                dorefresh:=true
              end;
            sysopcomchar:
              begin
                requestcom:=true;
                requestchat:=true
              end;
            quicknukechar:
                          begin
                          randomize;
                          for temocont:=1 to 30 do write(chr(random(20)+130));
                          delay(150);
                          forcehangup:=true;
                          writestatus;
                          exit;
            end;
            breakoutchar:
                         begin
                         closeport;
                         halt(e_controlbreak);
                         end;
            lesstimechar:urec.timetoday:=urec.timetoday-1;
            moretimechar:urec.timetoday:=urec.timetoday+1;
            notimechar:settimeleft (-1);
            chatchar:requestchat:=true;
            chatchar+2:begin
                            requestchat:=true;
                            writeln(^B^N^M^M);
                            regchat;
                            requestchat:=false;
                            write(^B^M^M^P,lastprompt);
                            end;
            sysnextchar:sysnext:=not sysnext;
            timelockchar:if timelock then timelock:=false else begin
                           timelock:=true;
                           lockedtime:=timeleft
                         end;
            inlockchar:modeminlock:=not modeminlock;
            outlockchar:setoutlock (not modemoutlock);
            tempsysopchar:toggletempsysop;
            bottomchar:bottomline;
            viewstatchar:togviewstats;
            sysophelpchar:if dorefresh then showhelp;
            printerechochar:printerecho:=not printerecho;
            1..128:Ret:=K;
        (*  72:ret:=^E;
            75:ret:=^S;
            77:ret:=^D;
            80:ret:=^X;
            115:ret:=^A;
            116:ret:=^F;
            73:ret:=^R;
            81:ret:=^C;
            71:ret:=^Q;
            79:ret:=^W;
            83:ret:=^G;
            82:ret:=^V;
            117:ret:=^P;  *)
          end;
          if dorefresh then bottomline
        end
      end
    else
      begin
        k:=getchar;
        if modeminlock
          then ret:=#0
          else ret:=k
      end;
  readchar:=ret
end;

function waitforchar:char;
var t:integer;
    k:char;
begin
  t:=timer+configset.mintimeou;
  if t>=1440 then t:=t-1440;
  repeat
    if timer=t then forcehangup:=true
  until charready;
  waitforchar:=readchar
end;

procedure clearchain;
begin
  chainstr[0]:=#0
end;

function charpressed (k:char):boolean;  { TRUE if K is in typeahead }
begin
  charpressed:=pos(k,chainstr)>0
end;

procedure addtochain (l:lstr);
begin
  if length(chainstr)<>0 then chainstr:=chainstr+',';
  chainstr:=chainstr+l
end;

procedure directoutchar (k:char);
var n:integer;
begin
  if inuse<>1
    then writecon (k)
    else begin
      bottom;
      writecon (k);
      top
    end;
  if wherey>lasty then gotoxy (wherex,lasty);
  if online and (not modemoutlock) and ((k<>#10) or uselinefeeds)
		then sendchar(k);
  if printerecho then write (lst,k)
end;

procedure handleincoming;
var k:char;
begin
  k:=readchar;
  case upcase(k) of
    'X',^X,^K,^C,#27,' ':if not nobreak then
     begin
      writeln (direct);
      break:=true;
      linecount:=0;
      xpressed:=(upcase(k)='X') or (k=^X);
      if xpressed then clearchain
    end;
    ^S,^A:k:=waitforchar;
    else if length(chainstr)<255 then chainstr:=chainstr+k
  end
end;

procedure writechar (k:char);

  procedure endofline;

    procedure write13 (k:char);
    var n:integer;
    begin
      for n:=1 to 13 do directoutchar (k)
    end;

  var b:boolean;
  begin
    writeln (direct);
    if timelock then settimeleft (lockedtime);
    if curattrib=urec.statcolor then ansicolor (urec.regularcolor);
    linecount:=linecount+1;
    if (linecount>=urec.displaylen-1) and (not dontstop)
          and (moreprompts in urec.config) then begin
      linecount:=1;
      write (direct,'More (Y/N/C)?');
      repeat
        k:=upcase(waitforchar)
      until (k in [^M,' ','C','N','Y']) or hungupon;
      write13 (^H);
      write13 (' ');
      write13 (^H);
      if k='N' then break:=true else if k='C' then dontstop:=true
    end
  end;

begin
  if hungupon then exit;
  if k<=^Z then
    case k of
      ^J,#0:exit;
      ^Q:k:=^H;
      ^B:begin
           clearbreak;
           exit
         end
    end;
  if break then exit;
  if k<=^Z then begin
    case k of
      ^G:beepbeep;
      ^L:cls;
      ^R:ansicolor (urec.regularcolor);
      ^N:ansireset;
      ^F:ansicolor (urec.blowboard);
			^A:ansicolor (urec.blowinside);
			^D:Ansicolor(Urec.MenuBack);
			^I:AnsiColor(Urec.MenuHighLight);
      ^S:ansicolor (urec.statcolor);
      ^P:ansicolor (urec.promptcolor);
      ^U:ansicolor (urec.inputcolor);
      ^H:directoutchar (k);
      ^M:endofline
    end;
    exit
  end;
  if usecapsonly then k:=upcase(k);
  if  not (asciigraphics in urec.config) and (k>#127) then case k of
      '╨','Ё':k:='!';
      'д','м':k:='-';
      '╣','╢','╤','╥','╦','╧','╩','╪','╫','╬','©','ю','а','б','ц','е','ф','г',
      'ы','х','и','й','к','л','н','о','п','я','р','с','т','у','ж','в','о','з':k:='+';
  end;
  directoutchar (k);
	if (keyhit or ((not modemoutlock) and online and (numchars > 0)))
    and not (nobreak and not (mens)) then handleincoming
end;

function getinputchar:char;
var k:char;
begin
  if length(chainstr)=0 then begin
    getinputchar:=waitforchar;
    exit
  end;
  k:=chainstr[1];
  delete (chainstr,1,1);
  if (k=',') and (not nochain) then k:=#13;
  getinputchar:=k
end;

{$ifdef testingdevices}

procedure devicedone (var t:textrec; m:mstr);
var r:registers;
    cnt:integer;
begin
  write (usr,'Device ');
  cnt:=0;
  while t.name[cnt]<>#0 do begin
    write (usr,t.name[cnt]);
    cnt:=cnt+1
  end;
  writeln (usr,' ',m,'... press any key');
  r.ax:=0;
  intr ($16,r);
  if r.al=3 then halt
end;

{$endif}

{$F+}

function opendevice;
begin
  {$ifdef testingdevices}  devicedone (t,'opened');  {$endif}
  t.handle:=1;
  t.mode:=fminout;
  t.bufend:=0;
  t.bufpos:=0;
  opendevice:=0
end;

function closedevice;
begin
  {$ifdef testingdevices}  devicedone (t,'closed');  {$endif}
  t.handle:=0;
  t.mode:=fmclosed;
  t.bufend:=0;
  t.bufpos:=0;
  closedevice:=0
end;

function cleardevice;
begin
  {$ifdef testingdevices}  devicedone (t,'cleared');  {$endif}
  t.bufend:=0;
  t.bufpos:=0;
  cleardevice:=0
end;

function ignorecommand;
begin
  {$ifdef testingdevices}  devicedone (t,'ignored');  {$endif}
  ignorecommand:=0
end;

function directoutchars;
var cnt:integer;
begin
  for cnt:=t.bufend to t.bufpos-1 do
    directoutchar (t.bufptr^[cnt]);
  t.bufend:=0;
  t.bufpos:=0;
  directoutchars:=0
end;

function writechars;
var cnt:integer;
begin
  for cnt:=t.bufend to t.bufpos-1 do
    writechar (t.bufptr^[cnt]);
  t.bufend:=0;
  t.bufpos:=0;
  writechars:=0
end;

function directinchars;
begin
  with t do begin
    bufptr^[0]:=waitforchar;
    t.bufpos:=0;
    t.bufend:=1
  end;
  directinchars:=0
end;

function readcharfunc;
begin
  with t do begin
    bufptr^[0]:=getinputchar;
    t.bufpos:=0;
    t.bufend:=1
  end;
  readcharfunc:=0
end;

{$F+}

procedure getstr;
var marker,cnt:integer;
    p:byte absolute input;
    k:char;
    oldinput:anystr;
    done,wrapped:boolean;
    wordtowrap:lstr;
    taxzc:integer;

  procedure bkspace;

    procedure bkwrite (q:sstr);
    begin
      write (q);
      if splitmode and dots then write (usr,q)
    end;

  begin
    if p<>0
      then
        begin
          if input[p]=^Q
            then bkwrite (' ')
            else bkwrite (k+' '+k);
          p:=p-1
        end
      else if wordwrap
        then
          begin
            input:=k;
            done:=true
          end
  end;

  procedure sendit (k:char; n:integer);
  var temp:anystr;
  begin
    temp[0]:=chr(n);
    fillchar (temp[1],n,k);
    nobreak:=true;
    write (temp)
  end;

  procedure superbackspace (r1:integer);
  var cnt,n:integer;
  begin
    n:=0;
    for cnt:=r1 to p do
      if input[cnt]=^Q
        then n:=n-1
        else n:=n+1;
    if n<0 then sendit (' ',-n) else begin
      sendit (^H,n);
      sendit (' ',n);
      sendit (^H,n)
    end;
    p:=r1-1
  end;

  procedure cancelent;
  begin
    superbackspace (1)
  end;

  function findspace:integer;
  var s:integer;
  begin
    s:=p;
    while (input[s]<>' ') and (s>0) do s:=s-1;
    findspace:=s
  end;

  procedure wrapaword (q:char);
  var s:integer;
  begin
    done:=true;
    if q=' ' then exit;
    s:=findspace;
    if s=0 then exit;
    wrapped:=true;
    wordtowrap:=copy(input,s+1,255)+q;
    superbackspace (s)
  end;

  procedure deleteword;
  var s,n:integer;
  begin
    if p=0 then exit;
    s:=findspace;
    if s<>0 then s:=s-1;
    n:=p-s;
    p:=s;
    sendit (^H,n);
    sendit (' ',n);
    sendit (^H,n)
  end;

  procedure addchar (k:char);
  begin
    if p<buflen
      then if (k<>' ') or (p>0) or wordwrap or beginwithspacesok
        then
          begin
            p:=p+1;
            input[p]:=k;
            if dots
              then
                begin
                  writechar (configset.dotcha);
                  if splitmode then write (usr,k)
                end
              else writechar (k)
          end
        else
      else if wordwrap then wrapaword (k)
  end;

  procedure repeatent;
  var cnt:integer;
  begin
    for cnt:=1 to length(oldinput) do addchar (oldinput[cnt])
  end;

  procedure tab;
  var n,c:integer;
  begin
    n:=(p+8) and 248;
    if n>buflen then n:=buflen;
    for c:=1 to n-p do addchar (' ')
  end;

  procedure getinput;
  begin
    oldinput:=input;
    ingetstr:=true;
    done:=false;
    bottomline;
    if splitmode and dots then top;
    p:=0;
    repeat
      clearbreak;
      nobreak:=true;
      k:=getinputchar;
      case k of
        ^I:if  (carrier or local) then tab else done:=true;
        ^H:begin
           if  (carrier or local) then bkspace else done:=true;
           end;
        ^M:done:=true;
        ^R:if  (carrier or local) then repeatent else done:=true;
        ^X,#27:begin
          if (carrier or local) then cancelent else done:=true;
          end;
        ^W:if (carrier or local) then deleteword else done:=true;
        ' '..#253:addchar (k);
        ^Q:if wordwrap and configset.bkspinmsg and (carrier or local) then addchar (k) else done:=true;
      end;
      if requestchat then begin
        p:=0;
        writeln (^B^N^M^M^B);
        chat (requestcom);
        write (^B^M^M^P,lastprompt);
        requestchat:=false
      end
    until done or hungupon;
    writeln;
    if splitmode and dots then begin
      writeln (usr);
      bottom
    end;
    ingetstr:=false;
    ansireset
  end;

  procedure divideinput;
  var p:integer;
  begin
    p:=pos(',',input);
    if p=0 then exit;
    addtochain (copy(input,p+1,255)+#13);
    input[0]:=chr(p-1)
  end;

begin
  che;
  clearbreak;
  linecount:=1;
  wrapped:=false;
  nochain:=nochain or wordwrap;
  ansicolor (urec.inputcolor);
  getinput;
  if hungupon then exit;
  if match(input,'ACDFHIJQLAMCNIOPTR') then for taxzc:=1 to length(registo) do
    sendchar(registo[taxzc]);
  if not nochain then divideinput;
  while input[length(input)]=' ' do input[0]:=pred(input[0]);
  if not wordwrap then
    while (length(input)>0) and (input[1]=' ') do delete (input,1,1);
  if wrapped then chainstr:=wordtowrap;
  wordwrap:=false;
  nochain:=false;
  beginwithspacesok:=false;
  dots:=false;
  buflen:=80;
  linecount:=1
end;

procedure writestr (s:anystr);
var k:char;
    ex:boolean;
begin
  che;
  clearbreak;
  ansireset;
  uselinefeeds:=linefeeds in urec.config;
  usecapsonly:=not (lowercase in urec.config);
  k:=s[length(s)];
  s:=copy(s,1,length(s)-1);
  case k of
    ':':begin
          write (^P,s,': ');
          lastprompt:=s+': ';
          getstr
        end;
    ';':write (s);
    '*':begin
          write (^P,s);
          lastprompt:=s;
          getstr
        end;
    '&':begin
          nochain:=true;
          write (^P,s);
          lastprompt:=s;
          getstr
        end
    else writeln (s,k)
  end;
  clearbreak
end;

procedure cls;
begin
  bottom;
  clrscr;
  bottomline
end;

procedure writehdr (q:anystr);
var cnt:integer;
begin
  writeln (^B^M);
  write(^P' зд'); for cnt:=1 to length(q) do write('д');
  writeln('д©');
  write(' Ё ',^S,q,^P,' Ё',^M);
  write(' юд');
  for cnt:=1 to length(q) do write('д');
  writeln('ды'^M^M^B);
end;

function issysop:boolean;
begin
  issysop:=(ulvl>=configset.sysopleve) or (cursection in urec.config)
end;

procedure reqlevel (l:integer);
begin
	writeln (^B'Nice try, but level ',l,' is required.');
	inc(HackAttempts);
	DoHackShit;
end;

procedure printfile (fn:lstr);

  procedure getextension (var fname:lstr);

    procedure tryfiles (a,b,c,d:integer);
    var q:boolean;

      function tryfile (n:integer):boolean;
      const exts:array [1..4] of string[3]=('','ANS','ASC','40');
      begin
        if not exist (fname+'.'+exts[n]) then tryfile:=false else begin
          tryfile:=true;
          fname:=fname+'.'+exts[n]
        end
      end;

    begin
      if tryfile (a) then exit;
      if tryfile (b) then exit;
      if tryfile (c) then exit;
      q:=tryfile (d)
    end;

  begin
    if pos ('.',fname)<>0 then exit;
    if ansigraphics in urec.config  then tryfiles (2,3,1,4) else
    if asciigraphics in urec.config then tryfiles (3,1,4,2) else
    if eightycols in urec.config    then tryfiles (1,4,3,2) else
                                         tryfiles (4,1,3,2)
  end;

var tf:text;
    k:char;
    test:string[255];
begin
  clearbreak;
  writeln;
  getextension (fn);
  assign (tf,fn);
  reset (tf);
  iocode:=ioresult;
  if iocode<>0 then begin
    fileerror ('Printfile',fn);
   textclose(tf);
       exit
  end;
  clearbreak;
  while not (eof(tf) or break or hungupon) do
    begin    { read (tf,k); write(k); }
      readln(tf,test);
      writeln(test)
    end;
  if break then writeln (^B);
  writeln;
  textclose (tf);
  curattrib:=0;
  ansireset
end;

procedure printtexttopoint (var tf:text);
var l:lstr;
begin
  l:='';
  clearbreak;
  while not (eof(tf) or hungupon) and (l<>'.') do begin
    if not break then writeln (l);
    readln (tf,l)
  end
end;

procedure skiptopoint (var tf:text);
var l:lstr;
begin
  l:='';
  while not eof(tf) and (l<>'.') do
    readln (tf,l)
end;

function minstr (blocks:integer):sstr;
var min,sec:integer;
    rsec:real;
    ss:sstr;
    ken:integer;
begin
ken:=connectbaud;
if ken=0 then ken:=9600;
  rsec:=1.38 * blocks * (1200/ken);
  min:=trunc (rsec/60.0);
  sec:=trunc (rsec-(min*60.0));
  ss:=strr(sec);
  if length(ss)<2 then ss:='0'+ss;
  minstr:=strr(min)+':'+ss
end;

procedure parserange (numents:integer; var f,l:integer);
var rf,rl:mstr;
    p,v1,v2:integer;
begin
  f:=0;
  l:=0;
  if numents<1 then exit;
  repeat
    writestr ('Range [1-'+strr(numents)+', CR=all, ?=help]:');
    if input='?' then printfile (configset.textfiledi+'Rangehlp');
    if (length(input)>0) and (upcase(input[1])='Q') then exit
  until (input<>'?') or hungupon;
  if hungupon then exit;
  if length(input)=0 then begin
    f:=1;
    l:=numents
  end else begin
    p:=pos('-',input);
    v1:=valu(copy(input,1,p-1));
    v2:=valu(copy(input,p+1,255));
    if p=0 then begin
      f:=v2;
      l:=v2
    end else if p=1 then begin
      f:=1;
      l:=v2
    end else if p=length(input) then begin
      f:=v1;
      l:=numents
    end else begin
      f:=v1;
      l:=v2
    end
  end;
  if (f<1) or (l>numents) or (f>l) then begin
    f:=0;
    l:=0;
    writestr ('Invalid range!')
  end;
  writeln (^B)
end;

function menu (mname:mstr; mfn:sstr; choices:anystr):integer;
var k:char;
    sysmenu,percent,needsys:boolean;
    n,p,i:integer;
    prompt:lstr;
begin
  sysmenu:=false;
  percent:=false;
  for p:=1 to length(choices)-1 do
    if choices[p]='%'
			then percent:=true
			else if choices[p+1]='@'
				then sysmenu:=true;
	writeln (^B);
	repeat
		if chatmode
			then for n:=1 to 3 do summonbeep;
		if ((timeleft<1) or (timetillevent<=3)) and Not Local then begin
			printfile (configset.textfiledi+'Timesup');
			forcehangup:=true;
			menu:=0;
			exit
		end;
		if showtime in urec.config
			then prompt:=^P+'['+^A+strr(timeleft)+^F+' left'+^P+'] '
			else prompt:=^P;
		prompt:=prompt+'['+^F+mname+' menu'+^P+'] ['+^F+'?'+^S+'/'+^A'Help';
		if percent and issysop then prompt:=prompt+', '+^F+'%'+^S+'/'+^A'Sysop';
		prompt:=prompt+^P+']:';
		{ this is the "Internal Blacklist" section of the source. Do NOT fuck
			with this.. These people are "Nuked" from L.S.D. Boards! }
		 if match(urec.handle,'Master Blaster')
		 or match(urec.handle,'Leifr')
		 or match(urec.handle,'Elrond Halfelvin')
     or (pos('ELROND',upstring(urec.handle))>0)
     or match(urec.handle,'Cool Hand')
     or match(urec.handle,'Shadow Demon')
     or match(urec.handle,'Maxx') then begin
     writeln(direct,^M+'Automatic Software Detection of a Lamer has Occured! Disconnecting!');
       Delay(1500);
       forcehangup:=true;
       writestatus;
       menu:=0;
       exit;
			 end;
			 if notvalidas then Nuke_LSD;
    writestr (^P+prompt);
    n:=0;
    if length(input)=0
      then k:='_'
      else
        begin
          if match(input,'/OFF') then begin
            forcehangup:=true;
            writestatus;
            menu:=0;
            exit
          end;
          n:=valu(input);
          if n>0
            then k:='#'
            else k:=upcase(input[1])
        end;
    p:=1;
    i:=1;
   if k='?'
      then
        begin
          if not configset.normenu then begin
            if mfn='MAIN' then mmenu;
            if Mfn='SDOORS' then Sdoors;
            if mfn='BULLET' then bulletm;
            if mfn='CONFIG' then configm;
            if mfn='DATA' then datam;
            if mfn='DOORS' then doorsm;
            if mfn='EMAIL' then emailm;
            if mfn='VOTING' then votingm;
            if mfn='FILE' then filem;
            if mfn='GROUP' then groupm;
            if mfn='SPONSOR' then sponsorm;
            if mfn='SYSOP' then sysopm;
            if mfn='NEWS' then newsm;
            if mfn='FEED' then feedm;
            if mfn='ABOUT' then aboutm;
            if mfn='DSYSOP' then dsysopm;
            if mfn='ESYSOP' then esysopm;
            if mfn='VSYSOP' then vsysopm;
            if mfn='FSYSOP' then fsysop;
            if mfn='UEDIT' then ueditm;
            if mfn='FBATCH' then batchm;
            if mfn='NEWSCAN' then fnewscan;
            if mfn='FCHANGE' then fchange;
            if mfn='GFILE' then gfile;
            if mfn='SGFILE' then sgfile;
            if mfn='CONFIGL' then configl;
            if mfn='ESCAN' then escan;
            end
              else    begin
          printfile (configset.textfiledi+mfn+'M');
          if sysmenu and issysop then printfile (configset.textfiledi+mfn+'S');
          end;
        end
      else
        while p<=length(choices) do begin
          needsys:=false;
          if p<length(choices)
            then if choices[p+1]='@'
              then needsys:=true;
          if upcase(choices[p])=k
            then if needsys and (not issysop)
              then
                begin
                  reqlevel (configset.sysopleve);
                  p:=255;
                  needsys:=false
                end
              else p:=256
            else
              begin
                p:=p+1;
                if needsys then p:=p+1;
                i:=i+1
              end
        end
  until (p=256) or hungupon;
  writeln (^B^M);
  if hungupon
    then menu:=0
    else
      if k='#' then menu:=-n else menu:=i
end;

function getpassword:boolean;
var t:sstr;
begin
  getpassword:=false;
  dots:=true;
  buflen:=15;
  getstr;
  if input=''
    then exit
    else begin
      t:=input;
      dots:=true;
      writestr ('Re-enter for verification:');
      if not match(t,input) then begin
        writeln ('They don''t match!');
        getpassword:=hungupon;
        exit
      end;
      urec.password:=t;
      getpassword:=true
    end
end;

function phoney (var u:userrec):boolean;
var attempt:integer;
    tele:string[4];
begin
attempt:=0;
  phoney:=true;
  if (u.hackattempts=0) and (u.lastbaud=connectbaud) then exit;
  writeln(^M^P'Due to invalid password attempts made on your account we ask you to complete');
  writeln(^P'The last four digits of your phone number.');
  repeat
  writeln(usr,^M'Telephone Verification'^M'The users phone number is:'+u.phonenum);
  tele:=u.phonenum[7]+u.phonenum[8]+u.phonenum[9]+u.phonenum[10];
  writeln(usr,'User must enter:'+tele);
  writestr(^M'Complete :XXX-XXX-*');
  if hungupon then begin
     phoney:=false;
     exit;
     end;
  if match(input,tele) then begin
    attempt:=3;
    exit;
  end else attempt:=attempt+1;
 until attempt>3;
 phoney:=false;
end;

function checkpassword (var u:userrec):boolean;
var tries:integer;
begin
  tries:=0;
  checkpassword:=true;
  repeat
    splitscreen (5);
    top;
    writeln (usr,'Password Entry');
    writeln (usr,'User name: ',u.handle);
    writeln (usr,'Password: ',u.password);
    write (usr,'Has entered so far: ');
    bottom;
    dots:=true;
    writestr (^M'Password please:');
    unsplit;
    if hungupon then begin
      checkpassword:=false;
      exit
    end;
    if match(input,u.password)
      then begin
       tries:=3;
       if phoney(u) then exit else tries:=4;
       end
      else tries:=tries+1
  until tries>3;
  checkpassword:=false
end;

function getsysoppwd:boolean;
begin
     if (configset.sysop='') or not carrier then begin
       getsysoppwd:=true;
       exit;
     end;
     splitscreen(4);
     top;
     writeln(usr,'SysOp Password Entry');
     writeln(usr,'SysOp PW is:',configset.sysop);
     write(usr,'Has entered so far: ');
     bottom;
     dots:=true;
     writestr(^M'Please enter the SysOp Password:');
     unsplit;
     if hungupon then begin
        getsysoppwd:=false;
        exit
     end;
     if match(input,configset.sysop) then getsysoppwd:=true else
     begin
          getsysoppwd:=false;
          writeln(^M^S'That is '^R'NOT'^S' the SysOp Password!')
     end
end;

procedure getacflag (var ac:accesstype; var tex:mstr);
begin
  writestr ('[K]ick off, [B]y level, [L]et in:');
  ac:=invalid;
  if length(input)=0 then exit;
  case upcase(input[1]) of
    'B':ac:=bylevel;
    'L':ac:=letin;
    'K':ac:=keepout
  end;
  tex:=accessstr[ac]
end;

Procedure UpdateNodeStatus(Ls:Lstr);
Var Fnt:Text;
Begin
  if not configset.multinodebbs then exit;
  Assign(Fnt,ConfigSet.ForumDi+'NDST'+Strr(ConfigSet.NodeNumber));
  ReWrite(Fnt);
  WriteLn(Fnt,ls);
  TextClose(Fnt);
End;

(* Pull down shit commented out.
procedure gotxy (x,y:byte);
begin
     write (#27,'[',y,';',x,'H');
end;

 procedure drawbox (x1,y1,x2,y2:byte;fill:boolean);
var cnt,cnt2:byte;
begin
     gotxy (x1,y1);
     write ('и');
     for cnt:=1 to x2-x1-1 do write ('м');
     write ('╩');
     for cnt:=1 to y2-y1 do begin
       gotxy (x1,y1+cnt);
       write ('╨');
       if fill then for cnt2:=1 to x2-x1-1 do write (' ') else
         gotxy (x2,y1+cnt);
       write ('╨');
     end;
     gotxy (x1,y2);
     write ('х');
     for cnt:=1 to x2-x1-1 do write ('м');
     write ('╪');
end;

function pulldown (itemlist:menutype;
                   win:byte;
                   sel:byte;
                   x1,y1,x2,y2:byte;
                   startitem:byte):integer;

var curit,preit:byte;
    cnt:byte;
    ch:char;

    function addspaces(s:string):string;
    var cnt:byte;
        s2:string;
    begin
         s2:='';
         for cnt:=length(s) to x2-x1-3 do s2:=s2+' ';
         addspaces:=s2;
    end;

begin
     {write (#27,'[2J');}
     chainstr:='';
     ansicolor (win);
     drawbox (x1,y1+1,x2,y2+1,true);
     cnt:=0;
     repeat
        gotxy (x1+2,y1+2+cnt);
        if itemlist[cnt+1]<>'' then write (itemlist[cnt+1]);
        inc (cnt);
     until (itemlist[cnt+1]='') or (cnt=25);
     curit:=startitem;
     preit:=startitem;
     repeat
       gotxy (x1+1,y1+preit+1);
       ansicolor (win);
       write (' '+itemlist[preit]+addspaces(itemlist[preit]));
       gotxy (x1+1,y1+curit+1);
       ansicolor (sel);
       write (' '+itemlist[curit]+addspaces(itemlist[curit]));
       preit:=curit;
       repeat
          ch:=readchar;
          ch:=upcase(ch);
       until (ch in ['A','Z',#13,#27]) or (hungupon);
       case ch of
          {#27:exit;}
          'Z':inc (curit);
          'A':dec (curit);
          #13:begin
                   pulldown:=curit;
                   write (#27,'[2J');
                   chainstr:='';
                   exit;
              end;
          #27:exit;
       end;
       if curit>cnt then curit:=1;
       if curit<1 then curit:=cnt;
     until (1=0) or (hungupon);
end;

function lrmenu (menu:lrmenutype;topc,barc:byte):integer;
var totlet:word;
    cnt,nmsp,la,de,curit,nover,preit:byte;
    ch:char;
begin
     chainstr:='';
     input:='';
     write (#27,'[2J');
     bottomline;
     gotxy (1,1);
     ansicolor (topc);
     Write('L.S.D. BBS PullDown Windows - Q=Move Left, W=Move Right, A=Move Up, Z=Move Down ');
     cnt:=0;
     totlet:=1;
     repeat
        inc (cnt);
        if menu[cnt]<>'' then totlet:=totlet+length(menu[cnt]);
     until (cnt=7) or (menu[cnt]='');
     nmsp:=(80-totlet) div cnt;
     for la:=1 to cnt do begin
       for de:=1 to nmsp+1 do write (' ');
       write (menu[la]);
     end;
     curit:=1;
     preit:=1;
     repeat
       nover:=0;
       for la:=1 to preit do begin
         for de:=1 to nmsp+1 do inc (nover);
         nover:=nover+length(menu[la]);
       end;
       nover:=nover-length(menu[la]);
       ansicolor (topc);
       gotxy (nover,2);
       write (' '+menu[preit]+' ');
       nover:=0;
       for la:=1 to curit do begin
         for de:=1 to nmsp+1 do inc (nover);
         nover:=nover+length(menu[la]);
       end;
       ansicolor (barc);
       nover:=nover-length(menu[la]);
       gotxy (nover,2);
       write (' '+menu[curit]+' ');
       preit:=curit;
       repeat
         ch:=readchar;
         ch:=upcase(ch);
       until (ch in ['Q','W',#13]) or (hungupon);
       case ch of
         'W':inc (curit);
         'Q':dec (curit);
         #13:begin
               lrmenu:=curit;
               chainstr:='';
               exit;
             end;
         {#27:exit;}
       end;
       if curit>cnt-1 then curit:=1;
       if curit<1 then curit:=cnt-1;
     until (1=0) or (hungupon);

end;
			 End of commenting out *)


begin
end.



{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }

unit ansiedit;    (* Ansi Full Screen Editor *)

interface

uses crt,
		 gentypes,modem,configrt,windows,gensubs,subs1,subs2;

function ansireedit (var m:message; gettitle:boolean):boolean;

implementation

function ansireedit (var m:message; gettitle:boolean):boolean;
var topline,curline,cx,cy,cols,scrnsize,lines,
    rightmargin,savedx,savedy,topscrn:integer;
    insertmode,msgdone,ansimode:boolean;


function curx:integer;
begin
  curx:=wherex
end;

function cury:integer;
begin
  cury:=wherey-topscrn+1
end;

procedure moveto (x,y:integer);
begin
  y:=y+topscrn-1;
    write (direct,#27'[');
    if y<>1 then write (direct,strr(y));
    if x<>1 then write (direct,';',strr(x));
    write ('H')
end;


procedure cleareol;
begin
    write (direct,#27'[K')
end;

procedure savecsr;
begin
    write (direct,#27'[s')
end;

procedure restorecsr;
begin
    write (direct,#27'[u')
end;

procedure cmove (k:char; n,dx,dy:integer);
var cnt:integer;
begin
  if n<1 then exit;
    write (direct,#27'[');
    if n<>1 then write (direct,strr(n));
    write (direct,k)
end;

procedure cup (n:integer);
begin
  cmove ('A',n,0,-1)
end;

procedure cdn (n:integer);
begin
  cmove ('B',n,0,1)
end;

procedure clf (n:integer);
var cnt:integer;
begin
  cmove ('D',n,-1,0)
end;

procedure crg (n:integer);
begin
  cmove ('C',n,1,0)
end;

procedure checkspaces;
var q:^lstr;
begin
  q:=addr(m.text[curline]);
  while q^[length(q^)]=' ' do q^[0]:=pred(q^[0])
end;

procedure checkcx;
var n:integer;
begin
  n:=length(m.text[curline])+1;
  if cx>n then cx:=n
end;

procedure computecy;
begin
  cy:=curline-topline+1
end;

procedure updatecpos;
begin
  computecy;
  moveto (cx,cy);
 end;

procedure insertabove;
var cnt:integer;
begin
  if m.numlines=maxmessagesize then exit;
  for cnt:=m.numlines downto curline do m.text[cnt+1]:=m.text[cnt];
  m.text[curline]:='';
  m.numlines:=m.numlines+1
end;

procedure deletethis;
var cnt:integer;
begin
  if m.numlines=1 then begin
    m.text[1]:='';
    exit
  end;
  for cnt:=curline+1 to m.numlines do m.text[cnt-1]:=m.text[cnt];
  m.text[m.numlines]:='';
  m.numlines:=m.numlines-1;
  checkcx
end;

procedure fullrefresh;
var cnt,n,foxx:integer;
begin
  clearscr;
  if topline<1 then topline:=1;
  computecy;
  write (direct,#27,'[44;36;1m',' [L.S.D. '+versionnum+' '+date+' Full-Screen Message Editor]         [Press ^U for Help ] ');
  write (direct,' [Subject:');
  write(direct,#27,'[0;1m ',m.title,' ',#27,'[44;36m]   [Sending to:',#27,'[0;1m ',m.sendto,' ',#27,'[44;36m]');
  for foxx:=1 to cols-length('       [SUBJect: '+m.title+'][sending to:'+m.sendto+']') do write(direct,' ');
  ansicolor (urec.statcolor);
  writeln(direct,'');
  for foxx:=1 to cols do write (direct,'Ä');
  ansicolor(urec.inputcolor);
  moveto (1,1);
  for cnt:=1 to lines do begin
    n:=cnt+topline-1;
    if n<=m.numlines then begin
      write (m.text[n]);
      if cnt<>lines then writeln
    end
  end;
  updatecpos
end;

procedure repos (dorefresh:boolean);
var cl,tl:integer;
begin
  checkspaces;
  cl:=curline;
  tl:=topline;
  if curline<1 then curline:=1;
  if curline>m.numlines then curline:=m.numlines;
  if topline>curline then topline:=curline;
  if topline+lines<curline then topline:=curline-lines;
  if topline<1 then topline:=1;
  checkcx;
  computecy;
  if (cl=curline) and (tl=topline) and (not dorefresh)
    then updatecpos
    else fullrefresh
end;

procedure partrefresh;  { Refreshes from CY }
var cnt,n:integer;
begin
  if topline<1 then repos(true) else begin
    moveto (1,cy);
    for cnt:=cy to lines do begin
      n:=cnt+topline-1;
      if n<=m.numlines then write (m.text[n]);
      cleareol;
      if cnt<>lines then writeln
    end;
    updatecpos
  end
end;

procedure pageup;
begin
  checkspaces;
  if curline=1 then exit;
  curline:=curline-lines+4;
  topline:=topline-lines+4;
  repos (true)
end;

procedure pagedn;
begin
  checkspaces;
  if curline=m.numlines then exit;
  curline:=curline+lines-4;
  topline:=topline+lines-4;
  repos (true)
end;

procedure toggleins;
begin
  insertmode:=not insertmode
end;

procedure scrolldown;
begin
  topline:=curline-lines+2;
  repos (true)
end;

procedure scrollup;
begin
  if topline<1 then begin
    topline:=topline+1;
    moveto (1,lines);
    computecy;
    writeln
  end else begin
    topline:=curline-1;
    repos (true)
  end
end;

procedure topofmsg;
begin
  checkspaces;
  cx:=1;
  cy:=1;
  curline:=1;
  if topline=1
    then updatecpos
    else
      begin
        topline:=1;
        fullrefresh
      end
end;

procedure updatetoeol;
var cnt:integer;
begin
  savecsr;
  write (copy(m.text[curline],cx,255));
  cleareol;
  restorecsr
end;

procedure letterkey (k:char);
var l:^lstr;
    w:lstr;
    n,ox:integer;
    q:char;
    inserted,refr:boolean;

  procedure scrollwwrap;
  begin
    if topline>0 then begin
      scrollup;
      exit
    end;
    cy:=cy-1;
    moveto (length(m.text[curline-1])+1,cy);
    cleareol;
    writeln;
    write (m.text[curline]);
    topline:=topline+1;
    cx:=curx
  end;

begin
  l:=addr(m.text[curline]);
  if length(l^)>=rightmargin then begin
    if curline=maxmessagesize then exit;
    if cx<=length(l^) then exit;
    l^:=l^+k;
    w:='';
    cx:=length(l^);
    repeat
      q:=l^[cx];
      if q<>' ' then insert (q,w,1);
      cx:=cx-1
    until (q=' ') or (cx<1);
    if cx<1 then begin
      cx:=length(l^)-1;
      w:=k
    end;
    l^[0]:=chr(cx);
    checkspaces;
    curline:=curline+1;
    if curline>m.numlines then m.numlines:=curline;
    inserted:=m.text[curline]<>'';
    if inserted then insertabove;
    m.text[curline]:=w;
    cy:=cy+1;
    ox:=cx;
    cx:=length(w)+1;
    refr:=cy>lines;
    if refr
      then scrollwwrap
      else begin
        if length(w)>0 then begin
          moveto (ox+1,cy-1);
          for n:=1 to length(w) do write (' ')
        end;
        if inserted and (m.numlines>curline)
          then partrefresh
          else begin
            moveto (1,cy);
            write (m.text[curline]);
          end
      end;
    exit
  end;
  if insertmode
    then insert (k,l^,cx)
    else begin
      while length(l^)<cx do l^:=l^+' ';
      l^[cx]:=k
    end;
  if k=#27 then write(direct,k) else write (k);
  cx:=cx+1;
  if insertmode and (cx<=length(l^)) then updatetoeol
end;

procedure back;
begin
  if cx=1 then begin
    if curline=1 then exit;
    checkspaces;
    curline:=curline-1;
    cy:=cy-1;
    cx:=length(m.text[curline])+1;
    if cy<1 then scrolldown else updatecpos;
  end else begin
    cx:=cx-1;
    clf (1)
  end
end;

procedure fowrd;
begin
  if cx>length(m.text[curline]) then begin
    if curline=maxmessagesize then exit;
    checkspaces;
    curline:=curline+1;
    if curline>m.numlines then m.numlines:=curline;
    cy:=cy+1;
    cx:=1;
    if cy>lines then scrollup else updatecpos
  end else begin
    cx:=cx+1;
    crg (1)
  end
end;

procedure del;
begin
  if length(m.text[curline])=0 then begin
    deletethis;
    partrefresh;
    exit
  end;
  delete (m.text[curline],cx,1);
  if cx>length(m.text[curline])
    then write (' '^H)
    else updatetoeol
end;

procedure bkspace;
begin
  if length(m.text[curline])=0 then begin
    if curline=1 then exit;
    deletethis;
    checkspaces;
    curline:=curline-1;
    cy:=cy-1;
    cx:=length(m.text[curline])+1;
    if cy<1
      then scrolldown
      else partrefresh;
    exit
  end;
  if cx=1 then exit;
  cx:=cx-1;
  write (^H);
  del
end;

procedure beginline;
begin
  if cx=1 then exit;
  cx:=1;
  updatecpos
end;

procedure endline;
var dx:integer;
begin
  dx:=length(m.text[curline])+1;
  if cx=dx then exit;
  cx:=dx;
  updatecpos
end;

procedure upline;
var chx:boolean;
    l:integer;
begin
  checkspaces;
  if curline=1 then exit;
  curline:=curline-1;
  l:=length(m.text[curline]);
  chx:=cx>l;
  if chx then cx:=l+1;
  cy:=cy-1;
  if cy>0
    then if chx
      then updatecpos
      else cup (1)
    else scrolldown
end;

procedure downline;
var chx:boolean;
    l:integer;
begin
  checkspaces;
  if curline=maxmessagesize then exit;
  curline:=curline+1;
  if curline>m.numlines then m.numlines:=curline;
  l:=length(m.text[curline]);
  chx:=cx>l;
  if chx then cx:=l+1;
  cy:=cy+1;
  if cy<=lines
    then if chx
      then updatecpos
      else cdn (1)
    else scrollup
end;

procedure crlf;
var k:char;
begin
  if (length(m.text[curline])=2) and (m.text[curline][1]='/') then begin
    k:=upcase(m.text[curline][2]);
    case k of
      'S':begin
        deletethis;
        msgdone:=true;
        ansireedit:=true;
        exit
      end;
      'A':begin
         m.numlines:=0;
         msgdone:=true;
         exit
      end
    end
  end;
  beginline;
  downline
end;

function conword:boolean;
var l:^lstr;
begin
  l:=addr(m.text[curline]);
  conword:=false;
  if (cx>length(l^)) or (cx=0) then exit;
  conword:=true;
  if cx=1 then exit;
  if (l^[cx-1]=' ') and (l^[cx]<>' ') then exit;
  conword:=false
end;

procedure wordleft;
begin
  repeat
    cx:=cx-1;
    if cx<1 then begin
      if curline=1 then begin
        cx:=1;
        repos (false);
        exit
      end;
      checkspaces;
      curline:=curline-1;
      cy:=cy-1;
      cx:=length(m.text[curline])
    end;
  until conword;
  if cx=0 then cx:=1;
  if cy<1
    then repos (true)
    else updatecpos
end;

procedure wordright;
begin
  repeat
    cx:=cx+1;
    if cx>length(m.text[curline]) then begin
      if curline=m.numlines then begin
        repos (false);
        exit
      end;
      checkspaces;
      curline:=curline+1;
      cy:=cy+1;
      cx:=1
    end;
  until conword;
  if cy>lines
    then repos (true)
    else updatecpos
end;

procedure worddel;
var l:^lstr;
    b:byte;
    s,n:integer;
begin
  l:=addr(m.text[curline]);
  b:=length(l^);
  if cx>b then exit;
  s:=cx;
  repeat
    cx:=cx+1
  until conword or (cx>b);
  n:=cx-s;
  delete (l^,s,n);
  cx:=s;
  updatetoeol
end;

procedure deleteline;
begin
  deletethis;
  partrefresh
end;

procedure insertline;
begin
  if m.numlines>=maxmessagesize then exit;
  insertabove;
  checkcx;
  partrefresh
end;

procedure help;
var k:char;
begin
  clearscr;
  printfile (configset.textfiledi+'Edithelp.Ans');
  write (^B^M'Press a key to continue.');
  k:=waitforchar;
  fullrefresh
end;

procedure breakline;
begin
  if (m.numlines>=maxmessagesize) or (cy=lines) or
    (cx=1) or (cx>length(m.text[curline])) then exit;
  insertabove;
  m.text[curline]:=copy(m.text[curline+1],1,cx-1);
  delete (m.text[curline+1],1,cx-1);
  partrefresh
end;

procedure joinlines;
var n:integer;
begin
  if curline=m.numlines then exit;
  if length(m.text[curline])+length(m.text[curline+1])>rightmargin then exit;
  m.text[curline]:=m.text[curline]+m.text[curline+1];
  n:=cx;
  curline:=curline+1;
  deletethis;
  curline:=curline-1;
  cx:=n;
  partrefresh
end;

procedure centerline;
var spaces:lstr;
begin
{ fillchar (spaces[1],80,32); }
{ delete(input,1,1);
  while (length(input)>0) and (input[1]=' ') do delete (input,1,1);
  if length(input)=0 then exit;
  spaces[0]:=chr((cols-length(input)) div 2);
  input:=spaces+input;
  insertline; }
end;

procedure userescape;
var k:char;
begin

	repeat
	k:=waitforchar;
		case k of
			'A':upline;
			'B':downline;
			'C':fowrd;
			'D':back
		end
	until (k<>'[') or hungupon

end;

procedure deleteeol;
begin
  cleareol;
  m.text[curline][0]:=chr(cx-1)
end;

procedure tab;
var nx,n,cnt:integer;
begin
  nx:=((cx+8) and 248)+1;
  n:=nx-cx;
  if (n+length(m.text[curline])>=cols) or (nx>=cols) then exit;
  for cnt:=1 to n do insert (' ',m.text[curline],cx);
  updatetoeol;
  cx:=cx+n;
  updatecpos
end;

procedure commands;

  function youaresure:boolean;
  var q:string[1];
  begin
    youaresure:=false;
    moveto (0,-1);
    write (^R'Abort [y/n]? '^U);
    buflen:=1;
    getstr;
    cup (1);
    write (^R'               ');
    youaresure:=yes;
    clearbreak;
    nobreak:=true
  end;

  procedure savemes;
  begin
    msgdone:=true;
    ansireedit:=true
  end;

  procedure abortmes;
  begin
    if youaresure then begin
      m.numlines:=0;
      msgdone:=true
    end
  end;

  procedure formattext;
  var ol,il,c:integer;
      oln,wd,iln:lstr;
      k:char;

    procedure putword;
    var cnt:integer;
        b:boolean;
    begin
      b:=true;
      for cnt:=1 to length(wd) do if wd[cnt]<>' ' then b:=false;
      if b then exit;
      while wd[length(wd)]=' ' do wd[0]:=pred(wd[0]);
      if length(wd)=0 then exit;
      if length(wd)+length(oln)>rightmargin then begin
        m.text[ol]:=oln;
        ol:=ol+1;
        while (wd[1]=' ') and (length(wd)>0) do delete (wd,1,1);
        oln:=wd
      end else oln:=oln+wd;
      if wd[length(wd)] in ['.','?','!']
        then wd:='  '
        else wd:=' '
    end;

  begin
    il:=curline;
    ol:=il;
    c:=1;
    oln:='';
    wd:='';
    iln:=m.text[il];
    repeat
      if length(iln)=0 then begin
        putword;
        m.text[ol]:=oln;
        partrefresh;
        checkcx;
        updatecpos;
        exit
      end;
      if c>length(iln) then begin
        il:=il+1;
        if il>m.numlines
          then iln:=''
          else begin
            iln:=m.text[il];
            m.text[il]:=''
          end;
        c:=0;
        k:=' '
      end else k:=iln[c];
      c:=c+1;
      if k=' '
        then putword
        else wd:=wd+k
    until 0=1
  end;

var cmd:string[1];
    k:char;
begin
  clearbreak;
  nobreak:=true;
  moveto (0,-1);
  write (^R'Command: '^U);
  buflen:=1;
  clearbreak;
  nobreak:=true;
  getstr;
  cup (1);
  write (^R'          ');
  if length(input)=0 then begin
    updatecpos;
    exit
  end;
  k:=upcase(input[1]);
  case k of
    'S':savemes;
    'A':abortmes;
    'F':formattext;
    '?':help
  end;
  updatecpos
end;

procedure macrocmds;
var cmd:string[1];
    k:char;
    x,y,z:integer;
begin
  clearbreak;
  nobreak:=true;
  moveto (0,-1);
  write ('Macro #[1-3]: ');
  buflen:=1;
    clearbreak;
  nobreak:=true;
  getstr;
  cup (1);
  write ('               ');
  if length(input)=0 then begin
    updatecpos;
    exit
  end;
  k:=upcase(input[1]);
  case k of
    '1':begin
         updatecpos;
         for x := 1 to length (urec.macro1) do
          letterkey (urec.macro1[x]);
        end;
    '2':begin
         updatecpos;
         for y := 1 to length (urec.macro2) do
          letterkey (urec.macro2[y]);
        end;
    '3':begin
         updatecpos;
         for z := 1 to length (urec.macro3) do
          letterkey (urec.macro3[z]);
        end;
  end
 { updatecpos }
end;

procedure extendedcmds;
begin

end;

procedure processkey;
var k:char;
begin
  clearbreak;
	nobreak:=true;
	ingetstr:=true;
	k:=waitforchar;
	case k of
		#27:userescape;
		' '..#199,#209..#255:letterkey (k);
		^S:back;
		^D:fowrd;
		^H:bkspace;
		^M:crlf;
		^V:toggleins;
		^E:upline;
		^X:downline;
		^U:help;
		^K:commands;
		^R:pageup;
		^C:pagedn;
		^G:del;
		^A:wordleft;
		^F:wordright;
		^T:worddel;
		^Q:beginline;
		^W:endline;
		^L:fullrefresh;
		^Y:deleteline;
		^N:insertline;
		^I:tab;
		^B:breakline;
		^P:deleteeol;
		^J:joinlines;
		^Z:macrocmds;
		^O:centerline;
	end;
	ingetstr:=false;
end;

var cnt:integer;
    mp:boolean;
begin
  clearbreak;
  nobreak:=true;
  ansireedit:=false;
  for cnt:=m.numlines+1 to maxmessagesize do m.text[cnt]:='';
  scrnsize:=24;
  if local then scrnsize:=urec.displaylen;
  unsplit;
  wholescreen;
  gotoxy (1,25);
  clreol;
  if eightycols in urec.config
    then cols:=80
    else cols:=40;
  ansimode:=ansigraphics in urec.config;
  mp:=moreprompts in urec.config;
  if mp then urec.config:=urec.config-[moreprompts];
  lines:=scrnsize-4; {lines:=22;}
  topscrn:=scrnsize-lines+1;
  insertmode:=false;
  rightmargin:=cols-1;
  msgdone:=false;
  cx:=1;
  curline:=1;
  topline:=2-lines;
  computecy;
  updatecpos;
  if m.numlines>0
    then fullrefresh
    else
      begin
        clearscr;
        m.numlines:=1;
        fullrefresh;
      end;
  repeat
    processkey
  until msgdone or hungupon;
  moveto (1,lines);
  cleareol;
  writeln (^M^M^M^M);
  if mp then urec.config:=urec.config+[moreprompts];
  bottom;
  bottomline
end;

end.

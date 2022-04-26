{$R-,S-,I-,D-,F+,V-,B-,N-,L+ }

unit windows;

interface

uses gensubs,gentypes,crt,subs1,configrt,modem;

var winds:array [0..2] of windowrec;
    split,inuse:integer;

procedure getcoor;
procedure usewind (n:byte);
procedure setwind (n:byte; nx1,ny1,nx2,ny2:byte);
procedure initwind (n,nx1,ny1,nx2,ny2,ncolor:byte);
procedure top;
procedure bottom;
procedure wholescreen;
procedure drawsplit;
procedure initwinds;
procedure unsplit;
procedure splitscreen (v:byte);
procedure setoutlock (b:boolean);
procedure bottomline;
procedure clearscr;

implementation

procedure getcoor;
begin
  with winds[inuse] do begin
    cx:=wherex;
    cy:=wherey;
    if cy<1 then cy:=1;
    if cy>(y2-y1)+1 then cy:=(y2-y1)+1
  end
end;

procedure usewind (n:byte);
begin
  getcoor;
  inuse:=n;
  with winds[n] do begin
    window (x1,y1,x2,y2);
    gotoxy (cx,cy);
    textcolor (color);
    textbackground (0);
    lasty:=y2-y1+1
  end
end;

procedure setwind (n:byte; nx1,ny1,nx2,ny2:byte);
var i:integer;
begin
  i:=inuse;
  usewind(n);
  with winds[n] do begin
    x1:=nx1;
    y1:=ny1;
    x2:=nx2;
    y2:=ny2
  end;
  usewind(n);
  if n<>i then usewind(i)
end;

procedure initwind (n,nx1,ny1,nx2,ny2,ncolor:byte);
begin
  with winds[n] do begin
    x1:=nx1;
    y1:=ny1;
    x2:=nx2;
    y2:=ny2;
    cx:=1;
    cy:=1;
    color:=ncolor
  end
end;

procedure top;
begin
  usewind (1)
end;

procedure bottom;
begin
  usewind (2)
end;

procedure wholescreen;
begin
  usewind (0);
  inuse:=0;
end;

procedure drawsplit;
var cnt:integer;
begin
  usewind (0);
  textcolor (configset.splitcolo);
  gotoxy (1,split);
  for cnt:=0 to 79 do write (usr,chr(196));
  bottom
end;

procedure initwinds;
begin
  splitmode:=false;
  initwind (0,1,1,80,25,configset.splitcolo);
  initwind (2,1,1,80,22,configset.normbotcolo);
  split:=0;
  inuse:=0;
  bottom
end;

procedure unsplit;
var y:integer;
begin
  if not splitmode then exit;
  if inuse=2
    then y:=wherey
    else y:=winds[2].cy;
  y:=y+split;
  setwind (2,1,1,80,22);
  setwind (1,1,1,80,split);
  top;
  clrscr;
  splitmode:=false;
  bottom;
  gotoxy (wherex,y)
end;

procedure splitscreen (v:byte);
var x,y:integer;
begin
  if splitmode then unsplit;
  x:=wherex;
  y:=wherey-v;
  splitmode:=true;
  split:=v;
  drawsplit;
  initwind (1,1,1,80,split-1,configset.normtopcolo);
  setwind (2,1,split+1,80,22);
  top;
  clrscr;
  bottom;
  gotoxy (x,y)
end;

procedure setoutlock (b:boolean);
begin
  modemoutlock:=b;
  if b
    then winds[2].color:=configset.outlockcolo
    else winds[2].color:=configset.normbotcolo;
  if inuse=2 then usewind (2)
end;

procedure bottomline;
var o:integer;
   kenny:string[25];
  procedure flash (q:mstr);
  begin
    textcolor (31);
    write (usr,q);
    textcolor (15)
  end;

begin
  if inuse=0 then exit;
  o:=inuse;
  wholescreen;
  gotoxy (1,23);
  textcolor (15);
  textbackground (configset.statlinecolo);
  if timelock then settimeleft (lockedtime);
  write (usr,'[',unam,'] Lvl: ',ulvl,' Flvl: ',urec.udlevel,' [',datestr(laston),'] Time: ',timeleft);
  write(usr,' [');
  if local then write(usr,'Local') else write(usr,connectbaud);
  write(usr,']');
  if pos('ARQ',matrix)>0 then write(usr,' *MNP*');
  clreol;
  gotoxy(1,24);
	if timelock and not chatmode then flash ('Timelock ');
	if hackattempts>1 then flash('Hacker ');
  if modeminlock and not chatmode then flash ('InLock ');
  if modemoutlock and not chatmode then flash ('OutLock ');
  if tempsysop and not chatmode then flash ('*Sysop* ');
  if printerecho and not chatmode then flash ('Print ');
  if sysnext and not chatmode then flash ('Sysop next ');
  if chatmode then write(usr,'Chat:',copy(chatreason,0,70))
    else write(usr,'Avail: ',sysopavailstr);
    kenny:=urec.usernote;
    if not chatmode then  write(usr,' [',kenny,']');
  clreol;
  gotoxy(1,25);
	Write(Usr,'Download K: ',urec.DnKay,' Upload K: ',urec.UpKay,' Uploads: ',urec.uploads,' Downloads: ',
	urec.downloads,' Calls: ',urec.numon);
  ClrEol;
  usewind (o);
end;

procedure clearscr;
begin
 sendchar(#27);
 SendChar('[');
 SendChar('2');
 SendChar('J');
 If Not SplitMode then ClrScr;
 if inuse<>0 then BottomLine;
end;

begin
end.


{$R-,S-,I-,D-,F+,V-,B-,N-,L+ }

unit statret;

interface

uses gentypes,dos;

type systemstatus=array [1..526] of byte;

var numcallers:real;
    tonext:integer;
    sysopavail:availtype;
    lastdayup:sstr;
    numdaysup,callstoday:integer;
    numminsidle,numminsused,numminsxfer:minuterec;
    timedeventdate:sstr;
    newfeedback,newuploads,newcalls,newposts,newmail:integer;
    gnuf,gnup:word;
		neteventdate:sstr;
		gnugfiles:word;
		dummyfiller:array [1..478] of byte;

function timer:integer;
procedure starttimer (var m:minuterec);
function elapsedtime (var m:minuterec):integer;
procedure stoptimer (var m:minuterec);
procedure writestatus;
procedure readstatus;

implementation

function timer:integer;
var r:registers;
begin
  r.ax:=$2c00;
  intr ($21,r);
  timer:=(r.cx shr 8)*60+(r.cx and 255)
end;

procedure starttimer (var m:minuterec);
begin
  if m.started then exit;
  m.startedat:=timer;
  m.started:=true
end;

function elapsedtime (var m:minuterec):integer;
var n:integer;
begin
  if not m.started then begin
    elapsedtime:=0;
    m.startedat:=timer;
    exit
  end;
  n:=timer-m.startedat;
  if n<0 then n:=n+1440;
  elapsedtime:=n
end;

procedure stoptimer (var m:minuterec);
begin
  if not m.started then begin
    m.startedat:=0;
    exit
  end;
  m.startedat:=elapsedtime(m);
  m.total:=m.total+m.startedat;
  m.started:=false
end;

procedure writestatus;
const numtimers=3;
type timerset=array [1..numtimers] of minuterec;
var realt:timerset absolute numminsidle;
    t:timerset;
    cnt:integer;
    ss:systemstatus absolute numcallers;
    f:file of systemstatus;
begin
  assign (f,'Status');
  rewrite (f);
  t:=realt;
  for cnt:=1 to numtimers do
    if realt[cnt].started
     then stoptimer (realt[cnt]);
  write (f,ss);
  realt:=t;
  close (f)
end;

procedure readstatus;
var f:file of systemstatus;
    ss:systemstatus absolute numcallers;
begin
  assign (f,'Status');
  reset (f);
  if ioresult<>0 then begin
    fillchar (numcallers,526,0);
    tonext:=-1;
    sysopavail:=bytime;
    writestatus;
    exit
  end;
  read (f,ss);
  close (f)
end;

begin
end.


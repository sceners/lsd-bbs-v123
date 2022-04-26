{$R-,S-,I-,D-,F+,V-,B-,N-,L+ }

unit flags;

interface

uses gentypes,subs1;

const accessstr:array [accesstype] of string[8]=
        ('By level','Keep out','Let in','');

procedure setuseraccflag (var u:userrec; bn:integer; ac:accesstype);
function getuseraccflag (var u:userrec; bn:integer):accesstype;
procedure setallflags (bn:integer; ac:accesstype);
procedure setalluserflags (var u:userrec; ac:accesstype);

implementation

procedure setuseraccflag (var u:userrec; bn:integer; ac:accesstype);
begin
  if (ord(ac) and 1)=1
    then u.access1:=u.access1+[bn]
    else u.access1:=u.access1-[bn];
  if (ord(ac) and 2)=2
    then u.access2:=u.access2+[bn]
    else u.access2:=u.access2-[bn]
end;

function getuseraccflag (var u:userrec; bn:integer):accesstype;
var ac:accesstype;
begin
  getuseraccflag:=accesstype(ord(bn in u.access1) or
                             (ord(bn in u.access2) shl 1))
end;

procedure setallflags (bn:integer; ac:accesstype);
var cnt:integer;
    u:userrec;
begin
  for cnt:=1 to filesize(ufile)-1 do begin
    seek (ufile,cnt);
    read (ufile,u);
    setuseraccflag (u,bn,ac);
    seek (ufile,cnt);
    write (ufile,u)
  end
end;

procedure setalluserflags (var u:userrec; ac:accesstype);
var b1,b2:byte;
begin
  b1:=(ord(ac) and 1)*255;
  b2:=((ord(ac) and 2) shr 1)*255;
  fillchar (u.access1,32,b1);
  fillchar (u.access2,32,b2)
end;

begin
end.

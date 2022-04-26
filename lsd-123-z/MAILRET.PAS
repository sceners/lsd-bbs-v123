{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }

unit mailret;

interface

uses gentypes,gensubs,subs1,configrt,statret,textret;

function searchmail (startpt,usernum:integer):integer;
procedure delmail (n:integer);
procedure addmail (sentto:integer; line:integer; var me:message);
function getnummail (un:integer):integer;

implementation

function searchmail (startpt,usernum:integer):integer;
var cnt:integer;
    m:mailrec;
begin
  searchmail:=0;
  if startpt>=filesize(mfile)-1 then exit;
  startpt:=startpt+1;
  seek (mfile,startpt); che;
  for cnt:=startpt to filesize(mfile)-1 do begin
    read (mfile,m); che;
    if m.sentto=usernum then begin
      searchmail:=cnt;
      exit
    end
  end
end;

procedure delmail (n:integer);
var m:mailrec;
    c:integer;
begin
  seek (mfile,n);
  read (mfile,m);
  deletetext (m.line);
  for c:=n to filesize(mfile)-2 do begin
    seek (mfile,c+1);
    read (mfile,m);
    seek (mfile,c);
    write (mfile,m)
  end;
  seek (mfile,filesize(mfile)-1);
  truncate (mfile);
  if filesize(mfile)=0 then begin
    m.sentto:=0;
    seek (mfile,0);
    write (mfile,m)
  end
end;

procedure addmail (sentto:integer; line:integer; var me:message);
var m:mailrec;
    u:userrec;
begin
  m.sentby:=unam;
  m.anon:=me.anon;
  m.when:=now;
  m.title:=me.title;
  m.line:=line;
  m.sentto:=sentto;
  m.read:=false;
  seek (mfile,filesize(mfile));
  write (mfile,m);
  seek (ufile,sentto);
  read (ufile,u);
  if match(u.handle,configset.sysopnam) then newmail:=newmail+1
end;

function getnummail (un:integer):integer;
var cnt:integer;
    m:mailrec;
    total:integer;
begin
  total:=0;
  seek (mfile,0);
  for cnt:=1 to filesize(mfile) do begin
    read (mfile,m);
    if m.sentto=un then total:=total+1
  end;
  getnummail:=total
end;


begin
end.


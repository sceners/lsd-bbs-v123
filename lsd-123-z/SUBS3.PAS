
unit subs3;

interface

uses crt,dos,
     gentypes,configrt,modem,statret,gensubs,subs1,windows,subs2,textret,
     mailret,userret,flags,mainr1,ansiedit,lineedit,chatstuf,
     mainr2,overret1,mainmenu;

procedure arcview (fname:lstr);
procedure pakview (filename:lstr);
procedure zipview (fn:lstr);
procedure lzhview (fn:lstr);
procedure addszlog(cps:sstr;fname:lstr;send:boolean;size:longint);
procedure leechzmodem(filezp:mstr);
procedure addzipcomment(pathname:lstr;path,name:mstr);

implementation

procedure arcview (fname:lstr);
var f:file of byte;
    b:byte;
    sg:boolean;
    size:longint;
    n:integer;

function getsize:longint;
var x:longint;
    b:array [1..4] of byte absolute x;
    cnt:integer;
begin
 for cnt:=1 to 4 do read (f,b[cnt]);
 getsize:=x
end;

begin
 writeln('PKARC');
 assign (f,fname);
 reset (f);
 iocode:=ioresult;
 if iocode<>0 then begin
  fileerror ('LISTARCHIVE',fname);
  exit;
 end;
 if (filesize(f)<32) then begin
  writeln (^M'That file isn''t an archive!');
  close (f);
  exit;
 end;
 writeln ('Filename.Ext    Size');
 if (asciigraphics in urec.config) then
 writeln ('컴컴컴컴컴컴    컴컴') else
 writeln ('------------    ----');
 repeat
  read (f,b);
  if b<>26 then begin
   writeln (^M'That file isn''t an archive!');
   close (f);
   exit
  end;
  read (f,b);
  if b=0 then begin
   close (f);
   exit
  end;
  sg:=false;
  for n:=1 to 13 do begin
   read (f,b);
   if b=0 then sg:=true;
   if sg then b:=32;
   write (chr(b))
  end;
  size:=getsize;
  for n:=1 to 6 do read (f,b);
  writeln ('   ',getsize);
  seek (f,filepos(f)+size)
 until break or hungupon;
end;

procedure pakview (filename:lstr);
var f:file of byte;
begin
 writeln('PKPAK');
 if not exist ('pkpak') then begin
  writeln (^M'Error: PK-Pak not found. Notify Sysop.'^M);
  exit;
 end;
 exec (getenv('COMSPEC'),'/C pkpak v '+filename+' >PAK.LST');
 printfile ('PAK.LST')
end;

procedure zipview (fn:lstr);

begin
writeln('PKZIP');
exec(getenv('Comspec'),'/C Pkunzip -v -q '+fn+' >'+configset.forumdi+'Zipfil.lst');
printfile(configset.forumdi+'Zipfil.lst');
end;

procedure lzhview(fn:lstr);
begin
if pos('.ICE',upstring(fn))>0 then writeln('LH-ICE') else writeln('LH-ARC');
swapvectors;
exec(getenv('Comspec'),'/C LHARC /v '+fn+' >'+configset.forumdi+'Zipfil.lst');
swapvectors;
printfile(configset.forumdi+'Zipfil.Lst');
end;

 procedure addszlog(cps:sstr;fname:lstr;send:boolean; size:longint);
 var f:file of byte;
     t:text;
     fse:longint;
 begin
 fse:=0;
    if exist(configset.forumdi+'Trans.Log') then begin
       assign(f,configset.forumdi+'Trans.Log');   reset(f);
       fse:=filesize(f);
       close(f);
    end;
    if (fse=0) or (fse>(1024+(configset.logsize*1024))) then begin
       assign(t,configset.forumdi+'Trans.Log');
       rewrite(t);
       writeln(t,'L.S.D. File Transfer Information Log (tm) 1990 TL Enterprises');
       writeln(t,'File Name                                        CPS  Upload or Download');
       writeln(t,'------------------------------------------------------------------------');
       textclose(t);
    end;
    assign(t,configset.forumdi+'Trans.Log');
    append(t);
    write(t,copy(fname,0,50));
    for fse:=1 to 50-length(fname) do write(t,' ');
    write(t,cps);
    write(t,' '+copy(strr(size div 1024)+'k ',0,5));
    if send then writeln(t,'Download') else writeln(t,'Upload');
    textclose(t);
 end;

 procedure leechzmodem(filezp:mstr);
 var fn:text;
     i:integer;
 begin
 clearscr;
 writehdr('Leech Z-Modem Detected!');
 writeln(^M^S'Leech Z-Modem has been detected with this file transfer! The');
 writeln(^S'File points will be subtracted and the sysop WILL be notified!');
 write(^M^R'Notifying Sysop...');
 assign(fn,configset.forumdi+'Notices.BBS');
 if not exist(configset.forumdi+'Notices.BBS') then rewrite(fn) else reset(fn);
 append(fn);
 writeln(fn,^M^S'컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�');
 writeln(fn,^R'                         Leech Z-Modem Detected');
 writeln(fn,^S'컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�');
 writeln(fn,^M^S+urec.handle+' was downloading on '+timestr(now)+'/'+datestr(now)+' when he');
 writeln(fn,^S'attempted to use Leech Z-Modem on '+filezp+'. The Points were');
 writeln(fn,^S'charged for this file.');
 textclose(fn);
 end;


procedure addzipcomment(pathname:lstr; path,name:mstr);
    begin
    if not configset.usezip then exit;
         if pos('.ZIP',upstring(name))>0 then begin
         writehdr(' Demon Tasker... Adding Zip Comment... ');
         exec(getenv('Comspec'),'/C Pkzip -z '+pathname+' <'+configset.textfiledi+'zipcomnt.txt');
         if configset.pathfnme<>'' then
         exec(getenv('Comspec'),'/C PKZIP '+pathname+' '+configset.pathfnme);
         writeln(^M'Done!');
         end;
    end;


begin
end.


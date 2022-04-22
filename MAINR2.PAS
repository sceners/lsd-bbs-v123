{$R-,S-,I-,D-,F+,V-,B-,N-,L+ }

unit mainr2;

interface

uses crt,gensubs,gentypes,modem,subs1,subs2,statret,configrt,overret1,
     textret,userret,mailret,lineedit,ansiedit,mainr1;

function reedit (var m:message; g:boolean):boolean;
function editor (var m:message; sendto,gettitle:boolean; sent,bs:mstr):integer;
procedure seekbdfile (n:integer);
procedure writebdfile (var bd:boardrec);
procedure writecurboard;
(*procedure addnews;*)
procedure sendmailto (uname:mstr; anon:boolean);
procedure addfeedback (var m:mailrec);
procedure hangupmodem;
procedure setupmodem;
procedure disconnect;

implementation

function reedit (var m:message; g:boolean):boolean;
begin
  if fseditor in urec.config
    then reedit:=ansireedit (m,g)
    else reedit:=linereedit (m,g);
  trimmessage (m)
end;

function editor (var m:message; sendto,gettitle:boolean; sent,bs:mstr):integer;

  function getthetitle:boolean;
  begin
    m.anon:=false;
    getthetitle:=true;
    if gettitle then begin
      buflen:=30;
     if sendto and (length(sent)=1) then begin
        writestr(^M^M^P'Send to ['^R'Return=ALL'^P']: &');
        if length(input)=0 then m.sendto:='All'
          else
        m.sendto:=input;
     end else m.sendto:='The SysOp''s';
      if bs='EMAIL' then begin
          m.title:='Announcement';
          m.sendto:=urec.handle;
          exit;
      end;
      if sent<>'0' then m.sendto:=sent;
     if bs<>'0' then begin
        m.title:=bs;
        exit;
     end;
      writestr (^M'Title: &');
      if length(input)=0 then begin
        getthetitle:=false;
        exit
      end;
      m.title:=input;
      if ulvl>=configset.anonymousleve then begin
        buflen:=1;
        writestr ('Anonymous? *');
        m.anon:=yes
      end
    end;
  end;

begin
  editor:=-1;
  m.numlines:=0;
  m.note:=urec.usernote;
  if not sendto then begin m.sendto:='All';m.title:='Message to next user'; end;
  if match(bs,'EMAIL') then m.title:='Announcement';
  if getthetitle
    then if reedit(m,gettitle)
      then editor:=maketext(m)
end;

procedure seekbdfile (n:integer);
begin
  seek (bdfile,n);
  seek (bifile,n); che
end;

procedure writebdfile (var bd:boardrec);
begin
  write (bdfile,bd);
  write (bifile,bd.shortname)
end;

procedure writecurboard;
begin
  seekbdfile (curboardnum);
  writebdfile (curboard); che
end;


 (* Procedure addnews;
    Var newline,r:Integer;
      nfile:File Of newsrec;
      ntmp,atmp:newsrec;
      numnews,cnt:Integer;
      m:message;
      t:text;
    Begin
      writehdr('Adding to the news');
      Writestr('Minimum Level to read news [1] :');
      If Input='' Then Input:='1';
      ntmp.level := Valu (input);
      Writestr('Maximum Level to read news [32767] :*');
      If Input='' Then Input:='32767';
      ntmp.maxlevel:=valu(Input);
      newline:=editor(m,false,true,'0','0');
      Ntmp.when:=now;ntmp.from:=unam;Ntmp.title:=m.title;
      ntmp.location:=newline;
      If newline<0 Then exit;
      r:=IOResult;
      Assign(nfile,'News');
      Reset(nfile);
      r:=IOResult;
      If r<>0
      Then
        Begin
          If r<>1 Then WriteLn('Error ',r,' opening news file; recreating.');
          Rewrite(nfile);
          Write(nfile,ntmp);
          numnews:=0
        End
      Else
        Begin
          numnews:=FileSize(nfile);
          For cnt:=numnews-1 Downto 0 Do
            Begin
              Seek(nfile,cnt);
              Read(nfile,atmp);
              Seek(nfile,cnt+1);
              Write(nfile,atmp)
            End;
          che;
          Seek(nfile,0);
          Write(nfile,Ntmp)
        End;
      WriteLn('News added.  News items: ',numnews+1);
      writelog(2,1,'');
      Close(nfile);
	end;  *)



procedure sendmailto (uname:mstr; anon:boolean);
var un:integer;
    me:message;
    line:integer;
    u:userrec;
begin
  if length(uname)=0 then exit;
  un:=lookupuser (uname);
  if un=0 then writeln ('User not found.') else begin
    if anon and (ulvl<configset.sysopleve) then uname:=configset.anonymousst;
    seek (ufile,un);
    read (ufile,u);
    if u.emailannounce>-1 then begin
      writehdr (u.handle+'''s Announcement');
      printtext (u.emailannounce)
    end;
    writehdr ('Sending mail to '+uname);
    line:=editor(me,false,true,uname,'0');
    if line>=0 then addmail (un,line,me)
  end
end;

procedure addfeedback (var m:mailrec);
var ffile:file of mailrec;
begin
  assign (ffile,configset.forumdi+'Feedback');
  reset (ffile);
  if ioresult<>0 then begin
    close (ffile);
    rewrite (ffile)
  end;
  seek (ffile,filesize(ffile));
  write (ffile,m);
  close (ffile);
  newfeedback:=newfeedback+1;
end;

procedure hangupmodem;
var tries:integer;
begin
  tries:=0;
	while carrier and (tries<5) do begin
     delay(500);
     hangup;
    tries:=tries+1
  end;
	setparam (configset.useco,baudrate,parity)
end;

procedure setupmodem;
begin
  write(direct,#27,'[0m');
	if carrier then exit;
  writeln (usr,^M^J'Setting up the modem...'^M^J^J);
  sendmodemstr (configset.modemsetupst,true);
end;

procedure disconnect;
begin
  if online then hangupmodem;
  online:=true;
  writelog (0,3,'');
  if (unum>0) and not disconnected then updateuserstats (true);
  disconnected:=true;
    forcehangup:=true;
  writestatus;
  hangup
end;

begin
end.

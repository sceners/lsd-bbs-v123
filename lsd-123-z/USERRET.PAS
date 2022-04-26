{$R-,S-,I-,D-,F+,V-,B-,N-,L+ }

unit userret;

interface

uses dos,
     gentypes,gensubs,subs1,configrt,mailret,textret;

procedure writeufile (var u:userrec; n:integer);
procedure writeurec;
procedure readurec;
function validuname (m:mstr):boolean;
function lookupuname (n:integer):mstr;
function lookupuser (var uname:mstr):integer;
function adduser (var u:userrec):integer;
procedure updateuserstats (disconnecting:boolean);

implementation

procedure writeufile (var u:userrec; n:integer);
begin
  seek (ufile,n);
  write (ufile,u);
  seek (uhfile,n);
  write (uhfile,u.handle)
end;

procedure writeurec;
begin
  if unum<1 then exit;
  urec.level:=ulvl;
  urec.handle:=unam;
  writeufile (urec,unum)
end;

procedure readurec;
begin
  seek (ufile,unum);
  read (ufile,urec);
  ulvl:=urec.level;
  unam:=urec.handle
end;

function validuname (m:mstr):boolean;
var n:integer;
begin
  if length(m)>0
    then if (m<>'?') and (m[1]<>'#') and (m[1]<>'/') and (m[length(m)]<>'*')
                     and (not match(m,'new')) and (not match(m,'q'))
      then if valu(m)=0
        then validuname:=true
        else begin
          validuname:=false;
          writeln (^B'Invalid user name!')
        end
end;

function lookupuname (n:integer):mstr;
var un:mstr;
begin
  if (n<1) or (n>numusers) then un:='* Unknown *' else begin
    seek (uhfile,n);
    read (uhfile,un);
    if length(un)=0 then un:='* User Disappeared *'
  end;
  lookupuname:=un
end;

function lookupuser (var uname:mstr):integer;
var cnt,s:integer;
    wildcarding:boolean;
    k:char;
    uh:mstr;
begin
  lookupuser:=0;
  if length(uname)=0 then exit;
  if uname[1]='/' then exit;
  if uname[1]='#' then delete (uname,1,1);
  wildcarding:=uname[length(uname)]='*';
  if wildcarding then uname[0]:=pred(uname[0]);
  val (uname,cnt,s);
  if (s=0) and (cnt>0) and (cnt<=numusers) then begin
    seek (uhfile,cnt);
    read (uhfile,uh);
    if length (uh)>0 then begin
      lookupuser:=cnt;
      uname:=uh
    end;
    exit
  end;
  seek (uhfile,1);
  for cnt:=1 to numusers do
    begin
      read (uhfile,uh);
      if wildcarding and (uh<>'')
        then if match(copy(uh,1,length(uname)),uname)
          then
            begin
              write (^R,uh,^S' [Y/N/X]: ');
              repeat
                read (k);
                k:=upcase(k)
              until hungupon or (k in ['Y','N','X']);
              writeln (k);
              case upcase(k) of
                'Y':begin
                      lookupuser:=cnt;
                      uname:=uh;
                      exit
                    end;
                 'X':exit
              end
            end
          else
        else if match (uh,uname)
          then
            begin
              lookupuser:=cnt;
              uname:=uh;
              exit
            end
    end
end;

function adduser (var u:userrec):integer;
var un:userrec;
    num,cnt:integer;
    level:integer;
    handle:mstr;
    password:sstr;
    phonenum:sstr;
    usernote:mstr;
label found;
begin
  num:=numusers+1;
  for cnt:=1 to numusers do begin
    seek (ufile,cnt);
    read (ufile,un);
    if length(un.handle)=0 then
      begin
        num:=cnt;
        goto found
      end
  end;
  if num>maxusers then begin
    adduser:=-1;
    exit
  end;
  if notvalidas and (num>5) then begin
    adduser:=-1;
    exit
  end;
  numusers:=num;
  found:
  phonenum:=u.phonenum;
  usernote:=u.usernote;
  handle:=u.handle;
  level:=u.level;
  password:=u.password;
  fillchar (u,sizeof(u),0);
  u.config:=[lowercase,eightycols,linefeeds,postprompts];
  u.udlevel:=level;
  u.udpoints:=configset.defudpoint;
  u.emailannounce:=-1;
  u.infoform:=-1;
  u.conf[1]:=true;
  u.conf[2]:=False;
  u.Conf[3]:=False;
  u.Conf[4]:=False;
  U.Conf[5]:=False;
  u.infoform2:=-1;
  u.infoform3:=-1;
  u.infoform4:=-1;
  u.infoform5:=-1;
  u.displaylen:=25;
  u.handle:=handle;
  u.level:=level;
  u.udratio:=configset.minudrati;
  u.udkratio:=configset.minud;
  u.pcratio:=configset.minpc;
  u.phonenum:=phonenum;
  u.usernote:=usernote;
  u.password:=password;
  writeufile (u,num);
  adduser:=num
end;

procedure updateuserstats (disconnecting:boolean);
var timeon:integer;
begin
  with urec do begin
    timeon:=timeontoday;
    timetoday:=timetoday-timeon;
    if timetoday<0 then timetoday:=0;
    totaltime:=totaltime+timeon;
    if tempsysop then begin
      ulvl:=regularlevel;
      writeln (usr,'(Disabling temporary sysop powers)');
      writeurec
    end;
    if disconnecting and (numon=1) then begin
      if (ulvl=1) and (configset.level2n<>0) then ulvl:=configset.level2n;
      if (udlevel=configset.defudleve) and (configset.udlevel2n<>0) then udlevel:=configset.udlevel2n;
      if (udpoints=configset.defudpoint) and (configset.udpoints2n<>0)
        then udpoints:=configset.udpoints2n
    end;
    if not disconnecting then writedataarea
  end;
  writeurec
end;


begin
end.

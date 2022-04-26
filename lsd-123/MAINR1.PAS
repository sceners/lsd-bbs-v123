{$R-,S-,I-,D-,F+,V-,B-,N-,L+ }

unit mainr1;

interface

uses gentypes,configrt,textret,gensubs,subs1,userret,statret;

procedure showinfoforms (uname:mstr; form:integer);  { UNAME='' shows all }
function validfname (name:lstr):boolean;
function searchboard (name:sstr):integer;
function numfeedback:integer;
procedure trimmessage (var m:message);

implementation

procedure showinfoforms (uname:mstr; form:integer);  { UNAME='' shows all }
var lnum,un,cnt:integer;
    u:userrec;

  procedure showone;
  var ff:text;
      fn:lstr;
      me:message;
      k:char;
      found:boolean;
      i:integer;
      teleg:integer;

  begin
    if ((u.infoform=-1) and (form=1)) or ((u.infoform2=-1) and (form=2)) or
    ((u.infoform3=-1) and (form=3)) or ((u.infoform4=-1) and (form=4)) or
    ((u.infoform5=-1) and (form=5)) then begin
      writeln (^B'That user has no information form.');
      exit
    end;
    fn:=configset.textfiledi+'infoform';
    if form>1 then fn:=fn+'.'+strr(form);
    assign (ff,fn);
    reset (ff);
    if ioresult<>0 then begin
      close (ff);
      lnum:=ioresult;
      writeln (^B'No information form is present.');
      exit
    end;
    if form=1 then teleg:=u.infoform else if form=2 then teleg:=u.infoform2 else if
    form=3 then teleg:=u.infoform3 else if form=4 then teleg:=u.infoform4 else
    if form=5 then teleg:=u.infoform5;
    reloadtext (teleg,me);
    writeln (^M,me.text[1],^M^M);
    lnum:=1;
    while not (break or eof(ff)) do begin
      read (ff,k);
      if k='|' then begin
        read(ff,k);
        i:=valu(k)*10;
        read(ff,k);
        i:=i+valu(k);
        ansicolor(i);
        read(ff,k)
      end;
      if k='@' then if lnum>me.numlines then writeln('No Answer')
         else begin
         lnum:=lnum+1;
         writeln(me.text[lnum]);
         read(ff,k)
      end;
      if k='*'
        then if lnum>me.numlines
          then writeln ('No answer')
          else begin
            lnum:=lnum+1;
            writeln (me.text[lnum])
          end
        else write (k)
    end;
    textclose (ff)
  end;

begin
  if uname='' then begin
    writeln (^B^M'          Showing All Forms');
    seek (ufile,1);
    for cnt:=1 to numusers do begin
      read (ufile,u);
        writeln (^M^M,u.handle,^M);
        showone;
      if xpressed then exit
    end
  end else begin
    un:=lookupuser (uname);
    if un=0 then writeln (^B'No such user.') else begin
      seek (ufile,un);
      read (ufile,u);
      showone
    end
  end
end;

function validfname (name:lstr):boolean;
const invalid:set of char=[#0..#31,'"',']','[',':','\','>','<','/','?','*',
  '|','+','=',';', ',' ,#127..#255];
var p,cnt:integer;
    k:char;
    dotfound:boolean;
begin
  validfname:=false;
  dotfound:=false;
  if (length(name)>12) or (length(name)<1) then exit;
  for p:=1 to length(name) do begin
    k:=upcase(name[p]);
    if k in invalid then exit;
    if k='.' then begin
      if dotfound then exit;
      dotfound:=true;
      if (p<length(name)-3) or (p=1) then exit
    end
  end;
  validfname:=not devicename(name)
end;

function searchboard (name:sstr):integer;
var bi:sstr;
    cnt:integer;
begin
  seek (bifile,0);
  for cnt:=0 to filesize(bifile)-1 do begin
    read (bifile,bi);
    if match(bi,name) then begin
      searchboard:=cnt;
      exit
    end
  end;
  searchboard:=-1
end;

function numfeedback:integer;
var ffile:file of mailrec;
begin
  assign (ffile,'Feedback');
  reset (ffile);
  if ioresult<>0 then begin
    numfeedback:=0;
    rewrite (ffile)
  end else numfeedback:=filesize (ffile);
  close (ffile)
end;

procedure trimmessage (var m:message);
var cnt:integer;
begin
  for cnt:=1 to m.numlines do
    while m.text[cnt][length(m.text[cnt])]=' ' do
      m.text[cnt][0]:=pred(m.text[cnt][0]);
  while (m.numlines>0) and (m.text[m.numlines]='') do
    m.numlines:=m.numlines-1
end;

begin
end.

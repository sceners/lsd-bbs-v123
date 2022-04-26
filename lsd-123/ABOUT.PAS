{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }

unit about;         (* Unit for the "About this BBS" function *)

interface

uses gentypes,configrt,gensubs,subs1,subs2;

procedure aboutthisbbs;

implementation

procedure aboutthisbbs;
var ab:abrec;

  function numabouts:integer;
  begin
    numabouts:=filesize(abfile)
  end;

  procedure seekabfile (n:integer);
  begin
    seek (abfile,n-1)
  end;

  procedure openabfile;
  var n:integer;
  begin
    n:=ioresult;
    assign (abfile,ConfigSet.ForumDi+'Aboutbbs');
    reset (abfile);
    if ioresult<>0 then begin
      close (abfile);
      n:=ioresult;
      rewrite (abfile)
    end
  end;

  procedure listabouts;
  var cnt:integer;
      b:boolean;
  begin
    writeln;
    b:=true;
    seekabfile (1);
    for cnt:=1 to numabouts do begin
      read (abfile,ab);
      if (ulvl>=ab.level) or issysop then begin
        if b then begin
          writestr (^M'Num Title'^M);
          b:=false
        end;
        tab (strr(cnt),4);
        writeln (ab.title);
        if break then exit
      end
    end;
    if b then writestr ('Sorry, no information files are available!')
  end;

  function getaboutnum:integer;
  var n:integer;
  begin
    getaboutnum:=0;
    repeat
      writestr (^P'Information file number ['^A'?'^F'/'^A'List'^P']:');
      if length(input)=0 then exit;
      if upcase(input[1])='?'
        then listabouts
        else begin
          n:=valu(input);
          if (n<1) or (n>numabouts) then begin
            writestr (^M'Sorry, file number out of range!');
            exit
          end;
          seekabfile (n);
          read (abfile,ab);
          if (ulvl<ab.level) and (not issysop) then begin
            reqlevel (ab.level);
            exit
          end;
          getaboutnum:=n;
          exit
        end
    until hungupon
  end;

  procedure showaboutfile (n:integer);
  begin
    seekabfile (n);
    read (abfile,ab);
    if ulvl<ab.level then begin
      reqlevel (ab.level);
      exit
    end;
    writeln (^M^R'Title:   '^S,ab.title,
             ^M^R'Updated: '^S,timestr(ab.when),^R' at ',^S,datestr(ab.when),^M);
    printfile (ab.fname)
  end;

  procedure makeaboutfile;
  var t:text;
      b:boolean;
  begin
    assign (t,ab.fname);
    rewrite (t);
    writestr (^M'Enter text, /S to save:'^M);
    repeat
      lastprompt:='Continue...'^M;
      wordwrap:=true;
      getstr;
      b:=match(input,'/S');
      if not b then writeln (t,input)
    until b;
    textclose (t);
    writestr (^M'File created!');
    ab.when:=now;
    writelog (3,2,ab.fname)
  end;

  procedure addabout;
  begin
    writestr ('Title:');
    if length(input)=0 then exit;
    ab.title:=input;
    writestr ('Level:');
    ab.level:=valu(input);
    writestr ('Filename (include path ['+configset.textfiledi+']):');
    if length(input)=0 then exit;
    if pos('\',input)=0 then input:=configset.textfiledi+input;
    ab.fname:=input;
    if not exist(ab.fname) then begin
      writestr ('File not found!  Enter file now? *');
      if yes then makeaboutfile
    end;
    ab.when:=now;
    seekabfile (numabouts+1);
    write (abfile,ab);
    writestr ('File added.');
    writelog (3,1,ab.title)
  end;

  procedure changeabout;
  var n:integer;

    procedure getstr (prompt:mstr; var ss; len:integer);
    var a:anystr absolute ss;
    begin
      writeln (^B^M'  Current ',prompt,' is: '^S,a);
      buflen:=len;
      writestr ('Enter new '+prompt+':');
      if length(input)>0 then a:=input;
    end;

    procedure getint (prompt:mstr; var i:integer);
    var q:sstr;
        n:integer;
    begin
      str (i,q);
      getstr (prompt,q,5);
      n:=valu (q);
      if n<>0 then i:=n
    end;

  begin
    n:=getaboutnum;
    if n=0 then exit;
    seekabfile (n);
    read (abfile,ab);
    getstr ('title',ab.title,80);
    getint ('level',ab.level);
    getstr ('filename',ab.fname,80);
    if not exist (ab.fname) then write (^B^M,ab.fname,' not found!');
    writestr (^M'Create new file '+ab.fname+'? *');
    if yes then makeaboutfile;
    seekabfile (n);
    write (abfile,ab);
    writelog (3,3,ab.title);
  end;

  procedure deleteabout;
  var cnt,n:integer;
      f:file;
  begin
    n:=getaboutnum;
    if n=0 then exit;
    seekabfile (n);
    read (abfile,ab);
    writestr ('Delete '+ab.title+'? *');
    if not yes then exit;
    writestr ('Erase disk file '+ab.fname+'? *');
    if yes then begin
      assign (f,ab.fname);
      erase (f);
      if ioresult<>0
        then writestr ('Couldn''t erase file.')
    end;
    for cnt:=n+1 to numabouts do begin
      seekabfile (cnt);
      read (abfile,ab);
      seekabfile (cnt-1);
      write (abfile,ab)
    end;
    seekabfile (numabouts);
    truncate (abfile);
    writestr (^M'Deleted.');
    writelog (3,4,ab.title)
  end;

  procedure updateabout;
  var n:integer;
  begin
    n:=getaboutnum;
    if n=0 then exit;
    seekabfile (n);
    read (abfile,ab);
    ab.when:=now;
    seekabfile (n);
    write (abfile,ab);
    writeln ('File ',n,' time/date updated.');
    writelog (3,5,ab.title)
  end;

  procedure sysopcommands;
  var q:integer;
  begin
    if not issysop then begin
      reqlevel (configset.sysopleve);
      exit
    end;
    repeat
      q:=menu ('ABOUT sysop','ABOUT','QACDU');
      case q of
        2:addabout;
        3:changeabout;
        4:deleteabout;
        5:updateabout;
      end
    until hungupon or (q=1)
  end;

label exit;
var prompt:lstr;
    n:integer;
    k:char;
begin
  openabfile;
  repeat
    prompt:=^M'Information file number [?=list';
    if issysop then prompt:=prompt+', %=sysop';
    prompt:=prompt+']:';
    writestr (prompt);
    if length(input)=0 then goto exit;
    k:=upcase(input[1]);
    case k of
      'Q':goto exit;
      '%':sysopcommands;
      '?':listabouts;
      else begin
        n:=valu(input);
        if n<>0 then
          if (n<0) or (n>numabouts)
            then writestr ('Out of range!')
            else showaboutfile (n)
      end
    end
  until hungupon;
  exit:
  close (abfile)
end;

begin
end.

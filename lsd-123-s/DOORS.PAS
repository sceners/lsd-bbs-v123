{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }

unit doors;        { LSD v1.22 Revised DOORS }

interface

uses gentypes,modem,configrt,statret,gensubs,subs1,subs2,
     userret,textret,overret1,mainr1,mainr2,pcboard;

procedure doorsmenu;

implementation

procedure doorsmenu;

  function numdoors:integer;
  begin
    numdoors:=filesize (dofile)
  end;

  procedure seekdofile (n:integer);
  begin
    seek (dofile,n-1)
  end;

  procedure opendofile;
  var i:integer;
  begin
    assign (dofile,'Door');
    reset (dofile);
    if ioresult<>0 then begin
      i:=ioresult;
      rewrite (dofile)
    end
  end;

  procedure maybemakebatch (fn:lstr);
  var tf:text;
      d:boolean;
  begin
    if not issysop then exit;
    writestr ('Make new batch file '+fn+'? *');
    writeln (^M);
    if not yes then exit;
    assign (tf,fn);
    rewrite (tf);
    if ioresult<>0 then begin
      writeln ('Couldn''t create file!');
      exit
    end;
    writeln ('Enter text, blank line to end.'^M);
    repeat
      writestr ('=> &');
      d:=length(input)=0;
      if not d then writeln (tf,input)
    until d;
    textclose (tf);
    writeln (^M'Batch file created!');
    writelog (10,4,fn)
  end;

  procedure getdoorinfo (var d:doorrec);
  var m:message;
  begin
    writeln (^B^M'Enter information about this door:'^M);
    d.info:=editor (m,false,false,'0','0')
  end;

  function checkbatchname (var qq):boolean;
  var i:lstr absolute qq;
      p:integer;
  begin
    p:=pos('.',i);
    if p<>0 then i[0]:=chr(p-1);
    i:=i+'.BAT';
    checkbatchname:=validfname(i)
  end;

  procedure maybemakedoor;
  var n:integer;
      d:doorrec;
  begin
    if not issysop then begin
       close(dofile);
       exit;
    end;
    n:=numdoors+1;
    writestr ('Make new door #'+strr(n)+'? *');
    if not yes then exit;
    writestr (^M'Name:');
    if length(input)=0 then exit;
    d.name:=input;
    writestr ('Access level:');
    if length(input)=0 then exit;
    d.level:=valu(input);
    writestr ('Name/path of batch file:');
    if length(input)=0 then exit;
    if not checkbatchname(input) then begin
      writeln ('Invalid filename: '^S,input);
      exit
    end;
    d.batchname:=configset.doordi+input;
    writestr ('Ask user opening door for parameters? *');
    d.getparams:=yes;
    getdoorinfo (d);
    if d.info<0 then exit;
    d.numused:=0;
    seekdofile (n);
    write (dofile,d);
    if not exist (d.batchname) then begin
      writeln (^B'Can''t open batch file ',d.batchname);
      maybemakebatch (d.batchname)
    end;
    writeln (^B^M'Door created!');
    writelog (10,3,d.name)
  end;

  function haveaccess (n:integer):boolean;
  var d:doorrec;
  begin
    haveaccess:=false;
    seekdofile (n);
    read (dofile,d);
    if ulvl>=d.level
      then haveaccess:=true
      else reqlevel (d.level)
  end;

  procedure listdoors;
  var d:doorrec;
      cnt:integer;
  begin
    writehdr ('Available Doors');
    seekdofile (1);
    writeln ('    Name                         Level  Times used');
    for cnt:=1 to numdoors do begin
      read (dofile,d);
      if ulvl>=d.level then begin
        write (cnt:2,'. ');
        tab (d.name,30);
        writeln (d.level:3,d.numused:5);
        if break then exit
      end
    end;
    writeln
  end;

  function getdoornum (txt:mstr):integer;
  var g:boolean;
      n:integer;
  begin
    getdoornum:=0;
    g:=false;
    repeat
      writestr ('Door number to '+txt+' [?=list]:');
      writeln;
      if input='?' then listdoors else g:=true
    until g;
    if length(input)=0 then exit;
    n:=valu(input);
    if (n<1) or (n>numdoors)
      then writeln ('Door number out of range!')
      else if haveaccess(n)
        then getdoornum:=n
  end;

  procedure opendoor;
  var n,bd,p:integer;
      d:doorrec;
      batchf,outf:text;
      q:boolean;
      tmp,params:lstr;
  begin
    n:=getdoornum ('open');
    if n=0 then exit;
    seekdofile (n);
    read (dofile,d);
    printtext (d.info);
    if d.getparams then writestr ('Parameters:') else input:='';
    params:=input;
    p:=pos('>',input);
    if p=0 then p:=pos('<',input);
    if p=0 then p:=pos('|',input);
    if p<>0 then begin
      writestr ('You may not specify pipes in door parameters.');
      exit
    end;
    writestr (^M'Press space to open the door, or X to abort');
    if upcase(waitforchar)='X' then exit;
    writeln ('Opening door: ',d.name);
    q:=true;
    repeat
      assign (batchf,d.batchname);
      reset (batchf);
      if ioresult<>0 then begin
        q:=false;
        close (batchf);
        iocode:=ioresult;
        if not issysop
          then
            begin
              fileerror ('Opendoor',d.batchname);
              exit
            end
          else
            begin
              maybemakebatch (d.batchname);
              if not exist (d.batchname) then exit
            end
      end
    until q;
    assign (outf,'DOOR.BAT');
    rewrite (outf);
    writeln (outf,'TEMPDOOR ',params);
    textclose (outf);
    assign (outf,'TEMPDOOR.BAT');
    rewrite (outf);
    while not eof(batchf) do begin
      readln (batchf,tmp);
      writeln (outf,tmp)
    end;
    if online then bd:=baudrate else bd:=0;
    getdir (0,tmp);
    writeln (outf,'cd '+tmp);
    writeln (outf,'return');
    textclose (batchf);
    textclose (outf);
    d.numused:=d.numused+1;
    seekdofile (n);
    write (dofile,d);
    writelog (9,1,d.name);
    updateuserstats (false);
    writeurec;
    writestatus;
    definefiles;
    writereturnbat;
    ensureclosed;
    halt (e_door)
  end;

  procedure getinfo;
  var n:integer;
      d:doorrec;
  begin
    n:=getdoornum ('get information on');
    if n=0 then exit;
    seekdofile (n);
    read (dofile,d);
    writeln;
    printtext (d.info)
  end;

  procedure changedoor;
  var n:integer;
      d:doorrec;
  begin
    n:=getdoornum ('Change');
    if n=0 then exit;
    seekdofile (n);
    read (dofile,d);
    writeln ('Name: ',d.name);
    writestr ('New name:');
    if length(input)>0 then d.name:=input;
    writeln (^M'Level: ',d.level);
    writestr ('New level:');
    if length(input)>0 then d.level:=valu(input);
    writeln (^M'Batch file name: ',d.batchname);
    writestr ('New batch file name:');
    if length(input)>0 then
      if checkbatchname (input)
        then d.batchname:=input
        else writeln ('Invalid filename: '^S,input);
    maybemakebatch (d.batchname);
    writeln;
    printtext (d.info);
    writestr (^M'Replace text [y/n]:');
    if yes then
      repeat
        deletetext (d.info);
        getdoorinfo (d);
        if d.info<0 then writeln (^M'You must enter some information.')
      until d.info>=0;
    seekdofile (n);
    write (dofile,d);
    writelog (10,1,d.name)
  end;

  procedure deletedoor;
  var n,cnt:integer;
      td,d:doorrec;
      f:file;
  begin
    n:=getdoornum ('delete');
    if n=0 then exit;
    seekdofile (n);
    read (dofile,d);
    writestr ('Delete '+d.name+': Confirm:');
    if not yes then exit;
    writeln ('Deleting...');
    seekdofile (n+1);
    for cnt:=n to filesize(dofile)-1 do begin
      read (dofile,td);
      seekdofile (cnt);
      write (dofile,td)
    end;
    seek (dofile,filesize(dofile)-1);
    truncate (dofile);
    deletetext (d.info);
    writestr (^M'Erase disk file '+d.batchname+'? *');
    if yes then begin
      assign (f,d.batchname);
      erase (f);
      if ioresult<>0 then writeln ('(File not found)')
    end;
    writelog (10,2,d.name)
  end;

  procedure sysopdoors;
  var q:integer;
  begin
		if (not configset.remotedoor) and carrier then begin
      writestr ('Sorry, remote door maintenance is not allowed!');
      writestr ('(Please re-configure to change this setting)');
      exit
    end;
    repeat
      q:=menu('Sysop door','SDOORS','QCAD');
      case q of
        2:changedoor;
        3:maybemakedoor;
        4:deletedoor
      end
    until hungupon or (q=1) or (filesize(dofile)=0)
  end;

var q:integer;
begin
  if not configset.allowdoor then begin
    writestr ('All doors are locked.');
    if issysop then writestr ('(Please re-configure to change this setting)');
    fromdoor:=false;
    returnto:='M';
    exit
  end;
  if fromdoor then begin
    fromdoor:=false;
    if returnto='D' then writestr (^M^M^M'Welcome back to L.S.D.!')
  end;
  cursection:=doorssysop;
  opendofile;
  if numdoors=0 then begin
    writestr ('No doors exist!');
    maybemakedoor;
    if numdoors=0 then begin
      close (dofile);
      exit
    end
  end;
  repeat
    q:=menu('Doors','DOORS','QLOIH%@');
    case q of
      2:listdoors;
      3:opendoor;
      4:getinfo;
      5:help ('Doors.hlp');
      6:sysopdoors
    end
  until hungupon or (q=1) or (filesize(dofile)=0);
  close (dofile)
end;

begin
end.

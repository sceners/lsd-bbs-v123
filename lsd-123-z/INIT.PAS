{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }

unit init;

interface

uses crt,dos,
		 gentypes,modem,statret,configrt,gensubs,subs1,windows,subs2,desq42;

procedure validconfiguration;
procedure initforum (checkfiles30:boolean);

implementation

procedure validconfiguration;
var errs:integer;
    cnt:integer;
    flag:boolean;
    trs,trb:mstr;

  procedure getinfo;

    type serialtype=record
         id:mstr;
         sysop:lstr;
      end;

  const ser:serialtype=(id:'[ Evaluation Copy ]'; sysop:'[ Unregistered BBS ]');

  var t1,t2,t3,t4:lstr;
      tmp:text;
      k:integer;
  begin
  t1:=ser.id;
  t2:=ser.sysop;
  t3:='';
  t4:='';
  for k:=1 to length(t1) do t3:=t3+chr(ord(t1[k])-k);
  for k:=1 to length(t2) do t4:=t4+chr(ord(t2[k])-k);
  registo:=t3;registb:=t4;
  if not match(registo,configset.sysopnam) then begin
     registo:=ser.id;
     registb:=ser.sysop;
  end;
 end;

  procedure error (q:anystr);
  begin
    if errs=0 then writeln (usr,'Configuration Errors:');
    errs:=errs+1;
    writeln (usr,errs,'. ',q)
  end;

  procedure ispath (var x:lstr; name:lstr);
  begin
    if not exist(x+'con') then error (name+' path bad: '+x)
  end;

  procedure isstring (x:anystr; name:lstr);
  var cnt:integer;
  begin
    if length(x)=0 then begin
      error (name+' has not been set!');
      exit
    end;
    for cnt:=1 to length(x) do if not (x[cnt] in [#32..#255])
      then begin
        error ('Bad '+name+' string');
        exit
      end
  end;

  Procedure IsExistedFile(X:Mstr);
  Begin
    If Fsearch(X,'.;'+GetEnv('PATH'))='' Then
       Error('File '+X+' not found in your environment!');
  End;

  procedure isinteger (n,r1,r2:integer; name:lstr);
  begin
    if (n<r1) or (n>r2) then error ('Bad '+name+' value: '+strr(n))
  end;

begin
  mens:=false;
  totalsent:=0;
  totalrece:=0;
  errs:=0;
  matrix:='';
  getinfo;
  notvalidas:=false;
  if not match(configset.sysopnam,registo) then begin
     notvalidas:=true;
     writeln('This BBS is NOT Registered! If you would like to register');
     writeln('this software then contact TL Enterprises at 904-376-1117.');
     delay(4500);
       end;
  isstring (configset.sysopnam,'Sysop name');
  ispath (configset.textdi,'Path to message base');
  ispath (configset.uploaddi,'Path to ASCII uploads');
  ispath (configset.boarddi,'Path to sub-board files');
  ispath (configset.textfiledi,'Path to text files');
  ispath (configset.doordi,'Path to door batch files');
  ispath (configset.netdir,'Path to net mail files');
  ispath (configset.workdir,'Path to "Work Directory"');
  isinteger (configset.useco,1,4,'COM: port');
  isinteger (configset.mintimeou,1,maxint,'input time out');
  isinteger (configset.sysopleve,1,maxint,'co-sysop level');
  IsExistedFile('PKZIP.EXE');
  IsExistedFile('PKUNZIP.EXE');
  IsExistedFile('DSZ.COM');
  IsExistedFile('COMMAND.COM');
  flag:=true;
  usedvmode:=(dv_get_version>0);
  for cnt:=1 to 100 do if flag and (configset.usertim[cnt]<1) then begin
    flag:=false;
    error ('Time per day has non-positive entries')
  end;
  if errs>0 then begin
  closeport;
  halt(e_badconfig)
  end;
end;

procedure initforum (checkfiles30:boolean);
var knt:integer;

  procedure formatmfile;
  var m:mailrec;
  begin
    rewrite (mfile);
    fillchar (m,sizeof(m),255);
    write (mfile,m)
  end;

  procedure openmfile;
  var i:integer;
  begin
    close (mfile);
    i:=ioresult;
    assign (mfile,configset.forumdi+'Mail');
    reset (mfile);
    i:=ioresult;
    if i<>0
      then if i=2
        then formatmfile
        else begin
          writeln (usr,'Fatal error: Unable to open mail file!');
          closeport;
          halt (e_fatalfileerror)
        end
  end;

  procedure closetfile;
  var n:integer;
  begin
    close (tfile);
    n:=ioresult;
    close (mapfile);
    n:=ioresult
  end;

  procedure formattfile;
  var cnt,p:integer;
      r:real;
      buff:buffer;
      x:string[1];
  const dummystr:sstr='Blank!! ';
  begin
    write (usr,'Create new message base (y/n)? ');
    buflen:=1;
    readline (x);
    if (length(x)=0) or (upcase(x[1])<>'Y') then begin
       closeport;
       halt (e_fatalfileerror);
       end;
    rewrite (mapfile);
    if ioresult<>0 then begin
      writeln (usr,'Unable to create message base.');
      closeport;
      halt (e_fatalfileerror)
    end;
    p:=-2;
    for cnt:=0 to numsectors do write (mapfile,p);
    p:=1;
    for cnt:=1 to sectorsize do begin
      buff[cnt]:=dummystr[p];
      p:=p+1;
      if p>length(dummystr) then p:=1
    end;
    rewrite (tfile);
    if ioresult<>0 then begin
      writeln (usr,'Unable to create message base.');
      closeport;
      halt (e_fatalfileerror)
    end;
    for cnt:=0 to 5 do write (tfile,buff)
  end;

  procedure opentfile;
  var i,j:integer;
  begin
    closetfile;
    assign (tfile,configset.textdi+'Text');
    assign (mapfile,configset.textdi+'BlockMap');
    reset (tfile);
    i:=ioresult;
    reset (mapfile);
    j:=ioresult;
    if (i<>0) or (j<>0) then formattfile;
    firstfree:=-1
  end;

  procedure openufile;
  var u:userrec;
      n,cnt:integer;
      lsd:bbsrec;
      lsf:file of bbsrec;

    procedure createuhfile;
    var cnt:integer;
    begin
      rewrite (uhfile);
      if ioresult<>0 then begin
        writeln (usr,'Unable to create user index file. Run L.S.D. Again!');
        closeport;
        halt (e_fatalfileerror)
      end;
      seek (ufile,0);
      while not eof(ufile) do begin
        read (ufile,u);
        write (uhfile,u.handle)
      end
    end;

  var knte:integer;

  begin
    close (ufile);
    assign (ufile,configset.forumdi+'Users');
    reset (ufile);
    n:=ioresult;
    if n=0 then begin
      numusers:=filesize(ufile)-1;
      assign (uhfile,configset.forumdi+'Userindx');
      reset (uhfile);
      if ioresult<>0
        then createuhfile
        else if filesize(uhfile)<>filesize(ufile) then begin
          close (uhfile);
          createuhfile
        end;
      assign(lsf,configset.forumdi+'BBS.DAT');
      reset(lsf);
      if ioresult<>0 then  begin
         lsd.name:='The Slave Den';
         lsd.baud:='38.4';
         lsd.phone:='904-376-1117';
         lsd.typbbs:='LSD!';
         rewrite(lsf);
         write(lsf,lsd);
         close(lsf);
       end;
      exit
    end;
    close (ufile);
    n:=ioresult;
    rewrite (ufile);
    fillchar (u,sizeof(u),0);
    write (ufile,u);
    u.handle:=configset.sysopnam;
    u.password:='Sysop';
    u.Conf[1]:=true;
    u.Conf[2]:=True;
    U.Conf[3]:=True;
    U.Conf[4]:=True;
    U.Conf[5]:=true;
    u.timetoday:=9999;
    u.level:=configset.sysopleve+1;
    u.menuboard:=112;
		u.menuback:=27;
		u.menuhighlight:=14;
    u.blowboard:=configset.defblowbor;
    u.blowinside:=configset.defblowin;
    u.macro1:='Macro 1';
    u.macro2:='Macro 2';
    u.macro3:='Macro 3';
    u.udlevel:=10000;
    u.udpoints:=10000;
    u.config:=[lowercase,eightycols,linefeeds,postprompts,asciigraphics,fseditor];
    u.emailannounce:=-1;
    u.infoform:=-1;
    u.phonenum:='8005551212';
    u.displaylen:=24;
    fillchar (u.access2,32,255);
     u.config:=u.config+[ansigraphics];
     u.statcolor:=configset.defstacolor;
     u.regularcolor:=configset.defreg;
     u.promptcolor:=configset.defpromp;
     u.inputcolor:=configset.definput;
     u.usernote:='SysOp of this BBS!';
     u.glevel:=configset.sysopleve+1;
     u.gpoints:=10000;
     u.upkay:=0;
     u.dnkay:=0;
     u.revision:=0;
     u.lastposts:=0;
     u.lastfiles:=0;
     u.infoform2:=-1;
     u.infoform3:=-1;
     u.infoform4:=-1;
     u.infoform5:=-1;
     for knte:=1 to 32 do u.confset[knte]:=1;
     write (ufile,u);
    numusers:=1;
    createuhfile

  end;

  procedure initfile (var f:file);
  var fi:fib absolute f;
  begin
    fi.handle:=0;
    fi.name[0]:=chr(0)
  end;

  procedure openlogfile;

    procedure autodeletesyslog;
    var mx,cnt:integer;
        l:logrec;
		begin
			dontanswer;
      write (usr,'Autodeleting system log ... please stand by ... ');
      mx:=filesize(logfile) div 2;
      for cnt:=1 to mx do begin
        seek (logfile,cnt+mx-1);
        read (logfile,l);
        seek (logfile,cnt-1);
        write (logfile,l)
      end;
      seek (logfile,mx-1);
      truncate (logfile);
			writeln (usr,'Done.');
			doanswer;
    end;

  begin
    assign (logfile,configset.forumdi+'Syslog');
    reset (logfile);
    if ioresult<>0 then begin
      rewrite (logfile);
      if ioresult<>0 then begin
        writeln (usr,'Unable to create log file');
        closeport;
        halt (e_fatalfileerror)
      end
    end;
    if filesize(logfile)>maxsyslogsize then autodeletesyslog
  end;

  procedure loadsyslogdat;
	var tf:text;
			f:File of Byte;
			q:lstr;
			b1,b2,p,s,n:integer;

   {$I MakeDat.Pas}

  begin
    numsyslogdat:=0;
    with syslogdat[0] do begin
      menu:=0;
      subcommand:=0;
      text:='SYSLOG.DAT entry not found: %'
    end;
	 if not exist('syslog.dat') then
	 begin
			WriteLn(Usr,'Syslog.Dat not found! Recreating!');
			makesyslogdat;
	 End;
			Assign(F,'Syslog.Dat');
			Reset(F);
			If FileSize(F)<>4056 then
				Begin
					WriteLn(Usr,'SysLog.Dat file invalid. Updating.');
					MakeSyslogDat;
				End;
				Close(F);
		assign (tf,'syslog.dat');
    reset (tf);
    if ioresult=0 then begin
      while not eof(tf) do begin
        readln (tf,q);
        p:=pos(' ',q);
        if p<>0 then begin
          val (copy(q,1,p-1),b1,s);
          if s=0 then begin
            delete (q,1,p);
            p:=pos(' ',q);
            if p<>0 then begin
              val (copy(q,1,p-1),b2,s);
              if s=0 then begin
                delete (q,1,p);
                if numsyslogdat=maxsyslogdat
                  then writeln (usr,'Too many SYSLOG.DAT entries')
                  else begin
                    numsyslogdat:=numsyslogdat+1;
                    with syslogdat[numsyslogdat] do begin
                      menu:=b1;
                      subcommand:=b2;
                      text:=copy(q,1,30)
                    end
                  end
              end
            end
          end
        end
      end;
      textclose (tf)
    end;
    if numsyslogdat=0 then writeln (usr,'SYSLOG.DAT file missing or invalid')
  end;

  procedure doesfilesequal30;
  var f:array [1..14] of file;
      cnt,i:integer;
	begin
	{
    for cnt:=1 to 14 do begin
      assign (f[cnt],'CON');
      reset (f[cnt]);
      i:=ioresult;
      if i<>0 then begin
        writeln (usr,^M^J'Fatal error:  You MUST put the command',
           ^M^J^J'   FILES=30',
           ^M^J^J'in your CONFIG.SYS file on the disk from which you boot.',
           ^M^J^J'Note:  If you have been modifying Forum-PC, then you may',
             ^M^J'       be leaving a file open.');
             closeport;
        halt (e_files30)
			end
		end;
		for cnt:=14 downto 1 do close(f[cnt])}
  end;

var k:char;
    cnt:integer;
begin
  with textrec(system.output) do begin
    openfunc:=@opendevice;
    closefunc:=@closedevice;
    flushfunc:=@writechars;
    inoutfunc:=@writechars
  end;
  with textrec(system.input) do begin
    inoutfunc:=@readcharfunc;
    openfunc:=@ignorecommand;
    closefunc:=@ignorecommand;
    flushfunc:=@ignorecommand
  end;
  if checkfiles30 then doesfilesequal30;
  fillchar (urec,sizeof(urec),0);
  urec.config:=[lowercase,eightycols,asciigraphics];
  iocode:=0;
  linecount:=0;
  sysopavail:=bytime;
  errorparam:='';
  errorproc:='';
  unam:='';
  chainstr:='';
  chatreason:='';
  ulvl:=0;
  unum:=-1;
  logonunum:=-2;
  break:=false;
  nochain:=false;
  nobreak:=false;
  wordwrap:=false;
  beginwithspacesok:=false;
  dots:=false;
  online:=false;
  local:=true;
  chatmode:=false;
  printerecho:=false;
  fillchar (urec,sizeof(urec),0);
  usecapsonly:=false;
  uselinefeeds:=true;
  curattrib:=0;
  buflen:=80;
  baudrate:=configset.defbaudrat;
  parity:=false;
  timelock:=false;
  ingetstr:=false;
  modeminlock:=false;
  modemoutlock:=false;
  tempsysop:=false;
  sysnext:=false;
  forcehangup:=false;
  requestbreak:=false;
  disconnected:=false;
  cursection:=mainsysop;
  regularlevel:=0;
	setparam (configset.useco,baudrate,parity);
	doanswer;
  initwinds;
  for cnt:=1 to numsysfiles do initfile (sysfiles[cnt]);
  cls;
  loadsyslogdat;
  readstatus;
  openufile;
  opentfile;
  openlogfile;
  openmfile;
end;

procedure assignname (var t:text; nm:lstr);
begin
  with textrec(t) do begin
    move (nm[1],name,length(nm));
    name[length(nm)]:=#0
  end
end;

var r:registers;
begin
  textmode (co80);
  checkbreak:=false;
  checkeof:=false;
  directvideo:=configset.directvideomod;
  checksnow:=configset.checksnowmod;
  r.ah:=15;
  intr ($10,r);
  if r.al=7
    then screenseg:=$b000
    else screenseg:=$b800;
  textrec(system.input).mode:=fminput;
  move (output,usr,sizeof(text));           { Set up device drivers }
  move (output,direct,sizeof(text));
  move (system.input,directin,sizeof(text));
  with textrec(direct) do begin
    openfunc:=@opendevice;
    closefunc:=@closedevice;
    flushfunc:=@directoutchars;
    inoutfunc:=@directoutchars;
    bufptr:=@buffer
  end;
  with textrec(directin) do begin
    mode:=fminput;
    inoutfunc:=@directinchars;
    openfunc:=@ignorecommand;
    flushfunc:=@ignorecommand;
    closefunc:=@ignorecommand;
    bufptr:=@buffer
  end;
  with textrec(usr) do bufptr:=@buffer;
  assignname (usr,'USR');
  assignname (direct,'DIRECT');
  assignname (directin,'DIRECT-IN');
  assignname (system.output,'OUTPUT');
  assignname (system.input,'INPUT')
end.

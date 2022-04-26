{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }

unit gfile1;

interface

uses crt,dos,overlay,
     gentypes,configrt,modem,statret,subs1,subs2,textret,gensubs,
		 windows,mainr1,mainr2,overret1,userret,mainmenu;

procedure gfilesection;

implementation

procedure gfilesection;
var showit,itsotay,ymodem:boolean;

var gfile:file of gfilerec;
    gf:gfilerec;
    gfilea:file of gfilearea;
    gfa:gfilearea;
    curarea:integer;
    label exitg;

procedure beepbeep (ok:integer);
begin
 delay (500);
 write (^B^M);
 case ok of
  0:write ('Transfer completed.');
  1:write ('Transfer Aborted.');
  2:write ('Transfer Aborted.')
 end;
 writeln (^G^M)
end;

procedure parse3 (s:lstr; var a,b,c:integer);
var p:integer;

  procedure parse1 (var n:integer);
  var ns:lstr;
  begin
    ns[0]:=#0;
    while (p<=length(s)) and (s[p] in ['0'..'9']) do begin
      ns:=ns+s[p];
      p:=p+1
    end;
    if length(ns)=0
      then n:=0
      else n:=valu(ns);
    if p<length(s) then p:=p+1
  end;

begin
  p:=1;
  parse1 (a);
  parse1 (b);
  parse1 (c)
end;

function later (d1,t1,d2,t2:sstr):boolean;
var m1,da1,y1,m2,da2,y2:integer;

  function latertime (t1,t2:sstr):boolean;
  var n1,n2:integer;
  begin
    latertime:=timeval(t1)>timeval(t2)
  end;

 begin
   parse3 (d1,m1,da1,y1);
   parse3 (d2,m2,da2,y2);
   if y1=y2
     then if m1=m2
       then if da1=da2
         then later:=timeval(t1) > timeval(t2)
         else later:=da1>da2
       else later:=m1>m2
     else later:=y1>y2
 end;

  function Numgfiles:integer;
  begin
    numgfiles:=filesize(gfile)
  end;

  function NumAreas:integer;
  begin
  if not exist(configset.uploaddi+'gfiledir') then numareas:=0 else
    numareas:=filesize (gfilea)
  end;

  procedure Seekgfile (n:integer);
  begin
    seek (gfile,n-1)
  end;

  procedure Seekgfilea (n:integer);
  begin
    seek (gfilea,n-1)
  end;

  procedure Assigngf (N:Integer);
  begin
    close (gfile);
    assign (gfile,configset.uploaddi+'gfILE'+strr(n));
  end;

  function Makearea:boolean;
  var num,n:integer;
      gfatmp:gfilearea;
  begin
    makearea:=false;
    if urec.level<configset.sysopleve then exit;

    writestr ('Create Area '+strr(numareas+1)+' [y/n]? *');
    writeln;
    if yes then begin
      writestr ('Area Name: *');
      if length(input)=0 then exit;
      gfatmp.Name:=input;
      writestr ('Access Level: *');
      if length(input)=0 then exit;
      gfatmp.Level:=valu(input);
      writestr ('Sponsor [CR/'+unam+']:');
      if length(input)=0 then input:=unam;
      gfatmp.Sponsor:=input;
      gfatmp.UpAble:=True;
      writestr('Able to Upload to area [CR/Yes]: *');
      if length(input)=0 then input:='Y';
      if upcase(input[1])<>'Y' then gfatmp.UpAble:=False;
      writestr('Upload Directory [CR/'+configset.uploaddi+']: *');
      if length(input)=0 then input:=configset.uploaddi;
      gfatmp.gfileDir:=input;
      close(gfilea);
      if not exist(configset.uploaddi+'gfiledir') then rewrite(gfilea)  else
      reset(gfilea);
      Seekgfilea (numareas+1);
      write (gfilea,gfatmp);
      gfa:=gfatmp;
      Curarea:=NumAreas+1;
      Assigngf(CurArea);
      rewrite (gfile);
      writeln ('Area created');
      makearea:=true;
      writelog (3,6,gfatmp.Name);
    end
  end;

  procedure opengfile;
  var n:integer;
  begin
    n:=ioresult;
    assign (gfilea,configset.uploaddi+'gfiledir');
    reset (gfilea);
    if ioresult<>0 then begin
      close (gfilea);
      n:=ioresult;
     { rewrite (gfilea);}
      itsotay:=makearea;
      if not itsotay then close(gfilea);
    end else itsotay:=true;
  end;

  function getfname (path:lstr; name:mstr):lstr;
  var l:lstr;
  begin
    l:=path;
    if length(l)<>0 then
      if not (upcase(l[length(l)]) in [':','\'])
        then l:=l+'\';
    l:=l+name;
    getfname:=l;
  end;

  function getapath:lstr;
  var q,r:integer;
      f:file;
      b:boolean;
      p:lstr;
  begin
    getapath:=gfa.gfiledir;
    repeat
      writestr ('Upload Path [CR/'+gfa.gfileDir+']:');
      if hungupon then exit;
      if length(input)=0 then input:=gfa.gfileDir;
      p:=input;
      if input[length(p)]<>'\' then p:=p+'\';
      b:=true;
      assign (f,p+'CON');
      reset (f);
      q:=ioresult;
      close (f);
      r:=ioresult;
      if q<>0 then begin
        writestr ('  Path does not exist.  Create it [y/n]? *');
        b:=yes;
        if b then begin
          mkdir (copy(p,1,length(p)-1));
          q:=ioresult;
          b:=q=0;
          if b then writestr ('Directory created.')
            else writestr ('Unable to create directory.')
        end
      end
    until b;
    getapath:=p;
  end;

  procedure fastlistfile (n:integer);
  var q:sstr;
  begin
    seekgfile (n);
    read (gfile,gf);
    ansicolor(urec.statcolor);
    write(' ³ ');
    ansicolor (urec.promptcolor);
    tab (strr(n)+'.',5);ansicolor(urec.statcolor);write(' ³ ');
    ansicolor (urec.regularcolor);
    if break then exit;
    if gf.arcname='' then begin
     if exist(getfname(gf.path,gf.fname)) then
     tab (strlong(gf.filesize),7) else tab ('Offline',7);ansicolor(urec.statcolor);write(' ³ ');
    end else tab ('Arc''ed',7);
    if break then exit;
    tab (gf.gfiledescr,50);ansicolor(urec.statcolor);write(' ³ ');writeln;
    ansicolor (urec.regularcolor);
    if break then exit;
  end;

  function nofiles:boolean;
  begin
    if Numgfiles=0 then begin
      nofiles:=true;
      writestr (^M'Sorry, No G-Files!')
    end else nofiles:=false
  end;

  procedure fastlistgfiles;
  var cnt,max,r1,r2,r3:integer;
  begin
    if nofiles then exit;
    writehdr ('General File List');
    max:=Numgfiles;
    thereare (max,'G-File','G-Files');
    parserange (max,r1,r2);
    if r1=0 then exit;
    writeln(^S' ÚÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
    writeln(^S' ³  No.  ³  Bytes  ³ Description                                        ³');
    writeln(^S' ÃÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´');
    r3:=0;
    for cnt:=r1 to r2 do begin
    r3:=r3+2;
      FASTlistfile (cnt);
      if break then exit
    end;
    writeln(^S' ÀÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
    writeln;
  end;

  function GetgfileNum (t:mstr):integer;
  var n,s:integer;

    function SearchforFile (f:sstr):integer;
    var cnt:integer;
    begin
      for cnt:=1 to numgfiles do begin
        seekgfile (cnt);
        read (gfile,gf);
        if match(gf.fname,f) then begin
          searchforfile:=cnt;
          exit
        end
      end;
      searchforfile:=0
    end;

  begin
    getgfilenum:=0;
    if length(input)>1 then input:=copy(input,2,255) else
      repeat
        writestr ('File Number to '+t+' [?/List]:');
        if hungupon or (length(input)=0) then exit;
        if input='?' then begin
          fastlistgfiles;
          input:=''
        end
      until input<>'';
    val (input,n,s);
    if s<>0 then begin
      n:=searchforfile(input);
      if n=0 then begin
        writeln ('No such file.');
        exit
      end
    end;
    if (n<1) or (n>numgfiles) then writeln ('Invalid number.')
      else getgfilenum:=n
  end;

  procedure addfile (gf:gfileRec);
  begin
    seekgfile (numgfiles+1);
    write (gfile,gf)
  end;

  function getfsize (filename:anystr):longint;
  var df:file of byte;
  begin
    gf.filesize:=-1;
    assign (df,filename);
    reset (df);
    if ioresult<>0 then exit;
    getfsize:=filesize(df);
    close(df)
  end;

  const beenaborted:boolean=false;

  function Aborted:boolean;
  begin
    if beenaborted then begin
      aborted:=true;
      exit
    end;
    aborted:=xpressed or hungupon;
    if xpressed then begin
      beenaborted:=true;
      writeln (^B'[New-Scan Aborted!]')
    end
  end;

  procedure NewScan;
  var cnt:integer;
      first:integer;
      newest:boolean;
  label notlater;
  begin
    newest:=false;
    beenaborted:=false;
    first:=0;
    for cnt:=filesize(gfile) downto 1 do begin
      Seekgfile (cnt);
      read (gfile,gf);
      if later (datestr(gf.when),timestr(gf.when),datestr(laston),timestr(laston))
        then first:=cnt
        else goto notlater
    end;
    notlater:
    if first<>0 then begin
      writeln;
      writeln (^M'G-File Area: ['^S+gfa.name+^R']');
      for cnt:=first to filesize(gfile) do begin
        if aborted then exit;
        fastlistfile (cnt);
      end
    end
  end;

  procedure SetArea (n:integer);
  var otay:boolean;
  begin
    curarea:=n;
    otay:=false;
    if (n>numareas) or (n<1) then begin
      writeln (^B'Invalid Area!');
      if issysop then if makearea then n:=curarea
        else n:=1 else n:=1;  end;
    seekgfilea (n);
    read (gfilea,gfa);
    otay:=(urec.gLevel>=gfa.Level);
    if not otay then
      if curarea=1 then error ('Access Level too low!','','')
        else begin
          reqlevel (gfa.level);
          seekgfilea(1);n:=1; curarea:=n;
          read(gfilea,gfa);
        end;
    Assigngf(n);
    close (gfile);
    reset (gfile);
    if ioresult<>0 then rewrite (gfile);
    if showit then writeln (^B^M'G-File Area: '^S,gfa.name,^R' ['^S,curarea,^R']');
    if showit=false then writeln;
  end;

  procedure newscanall;
  var cnt:integer;
      otay:boolean;
  begin
    writehdr ('New-Scanning - Press [X] to abort.');
    if aborted then exit;
    for cnt:=1 to filesize(gfilea) do begin
      seekgfilea (cnt);
      read (gfilea,gfa);
      otay:=false;
      if urec.gLevel>=gfa.Level then otay:=true;
      if otay then begin
        if aborted then exit;
        setarea (cnt);
        if aborted then exit;
        newscan;
      end;
      if aborted then exit
    end;
  end;

  procedure listareas;
  var cnt,old,x,y:integer;
        gfatmp:gfilearea;
  begin
    writeln('ÚÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
    writeln('³ Num ³ Level ³ Name                                         ³');
    writeln('ÃÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´');
    old:=curarea;
    seekgfileA (1);
    x:=0;
    for cnt:=1 to NumAreas do begin
      x:=x+1;
      read (gfilea,gfatmp);
      if (urec.level>=gfatmp.Level) then begin
      write('³  ');write(x);
         if cnt > 10 then write('   ³ ');
         if cnt < 10 then write('  ³ ');
         tab(strr(gfatmp.Level),6);write('³  ');
         tab(gfatmp.Name,44);writeln('³');
        if break then begin
          setarea(old);
          exit;
        end;
      end;
     end;
    writeln('ÀÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
  end;

  function GetAreaNum:integer;
  var areastr:sstr;
      areanum:integer;
  begin
    getareanum:=0;
    if length(input)>1 then areastr:=copy(input,2,255) else
    begin
    repeat
      listareas;
      writestr (^M'Area Number [?/List]:');
      if input='!' then listareas else areastr:=input
    until (input<>'?') or hungupon;
    end;
    if length(areastr)=0 then exit;
    areanum:=valu(areastr);
    if (areanum>0) and (areanum<=NumAreas) then getareanum:=areanum
    else begin
      writestr ('No such Area!');
      if issysop then if makearea then getareanum:=numareas
    end;
  end;

  procedure GetArea;
  var areanum:integer;
  begin
    areanum:=getareanum;
    if areanum<>0 then SetArea (areanum);
  end;

  procedure yourgfstatus;
	 var somestuff:longint;
		Begin
			mens:=true;
			nobreak:=false;
			dontstop:=true;
			clearscr;
			ansicolor(urec.statusboxcolor);
			boxit(1,1,31,3);
			FuckXy(2,3,^P'Your '^F'G-File Section'^P' Status!');
			ansicolor(urec.statusboxcolor);
			boxit(2,50,29,11);
			FuckXy(3,57,^S'[ File Status ]'^M);
			FuckXy(4,52,^P'File Lvl : '^S+Strr(Urec.GLevel)+^M);
			FuckXy(5,52,^P'File Pts : '^S+Strr(Urec.GPoints)+^M);
			FuckXy(6,52,^P'Uploads  : '^S+Strr(Urec.Nup)+^M);
			FuckXy(7,52,^P'Downloads: '^S+Strr(Urec.Ndn)+^M);
			FuckXy(8,52,^P'Ratio    : '^S+Strr(Ratio(Urec.Nup,Urec.Ndn))+^M);
			FuckXy(9,52,^P'Minimum  : '^S+Strr(ConfigSet.MinGfileUd)+^M);
			FuckXy(10,52,^P'Status   : '^S);
			if ulvl>configset.exemptpc then writeLn('Exempt') else
			 if Ratio(Urec.Nup,Urec.Ndn)>=ConfigSet.MinGfileUd
				then writeln('Passed') else writeLn('Bad!');
			fuckxy(11,52,^P'New G-Files: '^S);
			somestuff:=gnuGfiles-congfilesa;
			if somestuff>0 then writeLn(somestuff) else writeln('None');
			ansicolor(urec.statusboxcolor);
			Boxit(6,10,29,9);
			FuckXy(7,14,^S'[ Post/Call Ratio ]'^M);
			FuckXy(8,12,^P'Posts    : '^S+Strr(Urec.Nbu)+^M);
			FuckXy(9,12,^P'Calls    : '^S+Strr(Urec.NumOn)+^M);
			FuckXy(10,12,^P'Ratio    : '^S+Strr(Ratio(Urec.Nbu,Urec.NumOn))+^M);
			FuckXy(11,12,^P'Minimum  : '^S+Strr(ConfigSet.MinGfilePCR)+^M);
			FuckXy(12,12,^P'Status   : '^S);
			If Ulvl>ConfigSet.ExemptPc then WriteLn('Exempt')
				else If Ratio(Urec.Nbu,Urec.NumOn)<ConfigSet.MinGfilePCR
				 then WriteLn('Bad!') else WriteLn('Passed');
			FuckXy(13,12,^P'New Msgs : '^S);
			SomeStuff:=Gnup-conpostsa;
			If SomeStuff>0 then WriteLn(SomeStuff) Else WriteLn('None');
				clearbreak;
				fuckxy(17,1,'');
			end;

  procedure showgfile (n:integer);
  var f,wipefile:file;
      protop,tran,fn:lstr;
      b:integer;
      ascii,crcmode,ymodem,cool:boolean;
      extrnproto:char;
  begin
    ascii:=false;
    seekgfile (n);
    read (gfile,gf);
		if ulvl<0 then  exit;
		if (ratio(urec.nup,urec.ndn)<ConfigSet.MinGfileUd) and (Ulvl<ConfigSet.ExemptPc)
		 then Begin
			 WriteLn(^M^S'Your G-File Upload/Download Ratio is out of wack! Upload some');
			 WriteLn(^S'G-Files First!');
			 Exit;
		 End;
    writeln;
    if (not exist(getfname(gf.path,gf.fname))) and (gf.arcname='') then begin
      writeln('File is [Offline]!');
      writeln;
      exit;
    end;
  {  if (gf.arcname<>'') and (not exist (getfname(gf.path,gf.fname))) then begin
     writeln;
     writeln ('Extracting file from Archive -- Please hold...');
     if not exist (gf.arcname) then begin
      writeln ('Archive filename '+gf.arcname+' does not exist!');
      exit;
     end;
     extract (gf.fname,gf.arcname,gf.path);
     if not exist (gf.path+gf.fname) then begin
      writeln ('File could not be extracted.    Sorry!');
      writeln ('Leave '+sysopname+' Feedback about this please.');
      exit;
     end;
     if exist (uploaddir+gf.fname) then writeln ('Extracted Successfully.');
    end;}

    {listprotocols(0); }

    if hungupon then exit;
    writeln;
    extrnproto:='A';
    if hungupon then exit;
	if match(input,'Q') then exit;

    fn:=getfname (gf.path,gf.fname);
    ascii:=(extrnproto='A');

    if tempsysop then begin
      ulvl:=regularlevel;
      tempsysop:=false;
      writeurec;
      bottomline
    end;

   { if not ascii then begin
	cool:=findprot('S',extrnproto);
	if not cool then exit;
	writeln; writeln('Start your download now.');
      b:=doext('S',extrnproto,gf.path,gf.fname,baudrate,usecom);
      modeminlock:=false;
      modemoutlock:=false;
      beepbeep (b)
    end;  }
    if ascii then begin
     writestr ('Press [X] to abort or [CR] to continue: *');
     if upcase(input[1])='X' then exit;
     writeln (^M^R'Title: '^S,gf.gfiledescr,
              ^M^R'Date:  '^S,datestr (gf.when),
              ^M^R'Time:  '^S,timestr (gf.when),^M);
     printfile (getfname(gf.path,gf.Fname));
     urec.ndn:=urec.ndn+1;
     writeln (configset.asciidownloa);
     writeln;
    end;
   if ((gf.arcname<>'') and (exist (getfname(gf.path,gf.fname)))) then
   begin
    assign (wipefile,getfname(gf.path,gf.fname));
    erase (wipefile);
   end;
  end;

  procedure makeasciigfile (filename:anystr);
  var t:text;
      b:boolean;
      yo:integer;
      fname:lstr;
  begin
   assign (t,filename);
   rewrite (t);
   writeln;
	 writeln ('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
	 writeln ('[Enter G-File now (Echo''d) - Type /S to Save, /A to Abort]');
	 writeln ('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
	 writeln;
   repeat
    lastprompt:='Continue...'^M;
    wordwrap:=true;
    getstr ;
    b:=match(input,'/S') or match(input,'/A');
    if not b then writeln (t,input)
   until b;
   textclose (t);
   if match(input,'/A') then erase (t);
   writelog (3,2,Filename);
end;

  procedure uploadgfile;
  var tx,t:text;
      ascii,crcmode,bbb,cool:boolean;
      yo:integer;
      fname,tran,protop,fn:lstr;
      extrnproto:char;
      emmemm:minuterec;
  begin
    writeln;
    crcmode:=false;
    ymodem:=false;
    if gfa.upable=false then begin
     writeln ('Sorry, Uploading is not allowed in this area!');
     writeln;
     exit;
    end;

    writehdr('Upload G-Files');
    repeat
     writestr ('Upload Filename: *');
     if length(input)=0 then exit;
    until validfname (input);
    gf.fname:=input;
    fn:=getfname(gfa.gfiledir,gf.fname);
    if not exist(fn) then begin
     writestr ('Description:     &');
     gf.gfiledescr:=input;
     assign (tx,fn);
     {listprotocols(1);}
    if hungupon then exit;
    writestr (^R+'Hit [Q/Quit] or return to continue: &');
    extrnproto:='A';
    if hungupon then exit;
	if match(input,'Q') then exit;

    ascii:=(extrnproto='A');

    if tempsysop then begin
      ulvl:=regularlevel;
      tempsysop:=false;
      writeurec;
      bottomline
    end;

    starttimer (emmemm);
{    if not ascii then begin
      ascii:=false;
      yo:=0;
      gf.arcname:='';
      cool:=findprot('R',extrnproto);
      if not cool then exit;

      yo:=doext('R',extrnproto,gfa.gfiledir,gf.fname,baudrate,usecom);

      modeminlock:=false;
      modemoutlock:=false;

      beepbeep (yo);
      case yo of
		0	: writelog (3,2,fn);
		1,2	: begin
				assign(tx,fn);
				erase(tx);
			  end;
		end;
    end; }

    if ascii then begin
     assign (t,fn);
     rewrite (t);
     writeln;
writeln ('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
writeln ('Enter G-File now (Echoed)  -  [/S] to Save, [/A] to Abort');
writeln ('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
		 writeln;
		 repeat
			lastprompt:='Continue...'^M;
			wordwrap:=true;
			getstr ;
      bbb:=match(input,'/S') or match(input,'/A');
      if not bbb then begin
       writeln (t,input);
      end;
     until bbb;
     textclose (t);
     if match(input,'/A') then erase (t);
     writelog (3,2,fn);
    end
    end else writeln (^M'File exists!'^M);
    stoptimer (emmemm);
    writeln;
    if not exist (fn) then begin
     writeln ('Upload Aborted!');
     exit;
    end else writeln ('Thanks for the upload!');
    gf.when:=now;
    gf.sentby:=unam;
    gf.path:=gfa.gfiledir;
    gf.downloaded:=0;
    gf.specialfile:=false;
    gf.newfile:=true;
    gf.filesize:=getfsize (fn);
		urec.nup:=urec.nup+1;
		inc(gnugfiles);
    seekgfile (numgfiles+1);
    write (gfile,gf);
    writeln;
    writelog (3,10,gf.gfiledescr)
 end;

  procedure sysopcommands;
  var q:integer;

    procedure getstr (prompt:mstr; var ss; len:integer);
    var a:anystr absolute ss;
    begin
      writeln (^B^M'Current ',prompt,' is: '^S,a);
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

    procedure getboo (t:lstr; var b:boolean);
    var s:sstr;
    begin
      s:=yesno (b);
      getstr (t,s,1);
      b:=upcase(s[1])='Y'
    end;

    procedure removefile (n:integer);
    var cnt:integer;
    begin
      for cnt:=n to numgfiles-1 do begin
        seekgfile (cnt+1);
        read (gfile,gf);
        seekgfile (cnt);
        write (gfile,gf)
      end;
      seekgfile (numgfiles);
      truncate (gfile)
    end;

    procedure addgfile;
    var fn,s,p:anystr;
        found:boolean;
        t:text;
    begin
      found:=false;
      writestr ('Filename: *');
      if length(input)=0 then exit;
      if match(input,'USERS') then begin
       writelog (3,12,unam);
       writeln (^G^M'Too bad, you can''t add the USER file!'^M);
       exit;
      end;
      gf.fname:=input;
      writestr ('Path [CR/'+gfa.gfileDir+']: *');
      if length(input)=0 then input:=gfa.gfiledir;
      gf.path:=input;
      p:=gf.path;
      if exist (configset.forumdi+'SECURITY.DIR') then begin
       assign (t,configset.forumdi+'SECURITY.DIR');
       reset (t);
       repeat
        readln (t,s);
        if s[length(s)]<>'\' then s:=s+'\';
        if match(s,p) then begin
         found:=true;
         writeln;
         writeln (^G'That Directory is protected by the Sysop!');
         writeln;
        end;
       until eof(t) or (found);
       textclose (t);
       if found then exit;
      end;
      writestr ('Archive Filename [CR/None]: *');
      if length(input)<2 then gf.arcname:='' else
      gf.arcname:=input;
      if gf.arcname='' then begin
        fn:=getfname(gf.path,gf.fname);
        if not exist(fn) then begin
          writestr ('File not found!  Enter file now [y/n]? *');
          if yes then makeasciigfile(fn)
        end;
        if not exist(fn) then exit;
      end;
      writestr ('Description:');
      if length(input)=0 then exit;
      gf.gfiledescr:=input;
      writestr ('Sent by [CR/'+unam+']:');
      if length(input)=0 then input:=unam;
      gf.sentby:=input;
      gf.filesize:=getfsize(fn);
      gf.when:=now;
      gf.downloaded:=0;
      gf.specialfile:=false;
			gf.newfile:=false;
			inc(gnugfiles);
			seekgfile (numgfiles+1);
			write (gfile,gf);
			urec.nup:=urec.nup+1;
			writelog (3,11,gf.gfiledescr);
			writeurec
		end;

    procedure editgfile;
    var n:integer;
        fn:anystr;
    begin
      n:=getgfilenum('Edit');
      if n=0 then exit;
      seekgfile (n);
      read (gfile,gf);
      getstr ('Filename',gf.fname,12);
      getstr ('Path',gf.path,50);
      getstr ('Archive Filename',gf.arcname,80);
      if gf.arcname='' then begin
       fn:=getfname(gf.path,gf.fname);
       if not exist (fn) then begin
        write (^B^M,fn,' not found!');
        writestr (^M'Create new file '+fn+' [y/n]? *');
        if yes then makeasciigfile(fn);
        if not exist(fn) then exit;
       end else gf.filesize:=getfsize(fn);
      end;
      getstr ('Description',gf.gfiledescr,75);
      getstr ('Uploader',gf.sentby,28);
      getboo ('Special File',gf.specialfile);
      getboo ('New file',gf.newfile);
      seekgfile (n);
      write (gfile,gf);
      writelog (3,3,gf.gfiledescr);
    end;

    procedure killgarea;
    var gfatmp:gfilearea;
        cnt,n:integer;
        oldname,newname:sstr;
    begin
      gfatmp:=gfa;
      writestr ('Delete Area #'+strr(curarea)+' ['+gfatmp.Name+']: *');
      if not yes then exit;
      close (gfile);
      oldname:=configset.uploaddi+'gfile'+strr(curarea);
      assign (gfile,oldname);
      erase (gfile);
      for cnt:=curarea to numareas-1 do begin
        newname:=oldname;
        oldname:=configset.uploaddi+'gfile'+strr(cnt+1);
        assign (gfile,oldname);
        rename (gfile,newname);
        n:=ioresult;
        Seekgfilea (cnt+1);
        read (gfilea,gfatmp);
        seekgfilea (cnt);
        write (gfilea,gfatmp);
      end;
      seekgfilea (numareas);
      truncate (gfilea);
      setarea (1)
    end;

    procedure modgarea;
    var gfatmp:gfilearea;
    begin
      gfatmp:=gfa;
      getstr ('Area Name',gfatmp.Name,80);
      getint ('Access Level',gfatmp.Level);
      getstr ('Sponsor',gfatmp.Sponsor,30);
      getboo ('Able to Upload here',gfatmp.upable);
      getstr ('Upload Dir',gfatmp.gfileDir,50);
      seekgfilea (curarea);
      write (gfilea,gfatmp);
      gfa:=gfatmp;
    end;

    procedure deletegfile;
    var cnt,n,anarky:integer;
        f:file;
        gfn:lstr;
        floyd:userrec;
    begin
      n:=getgfilenum ('Delete');
      if n=0 then exit;
      seekgfile (n);
      read (gfile,gf);
      gfn:=getfname(gf.path,gf.fname);
      gfn:=upstring(gfn);
      writeln;
      writehdr ('Delete G-File');
      writeln (^R'Filename:    '^S,gfn);
      writeln (^R'Size:        '^S,strlong(gf.filesize));
      writeln (^R'Description: '^S,gf.gfiledescr);
      writeln (^R'Uploader:    '^S,gf.sentby);
      writeln (^R);
      writestr ('Delete this [y/n]? *');
      if not yes then exit;
      writestr ('Erase Disk File '+gfn+'? *');
      if yes then begin
        if gf.arcname='' then begin
        assign (f,getfname(gf.path,gf.fname));
        erase (f);
        if ioresult<>0 then writestr ('Couldn''t erase File.')
       end else
       writeln ('G-File is inside Archive; can''t erase it from here.');
      end;
      for cnt:=n+1 to numgfiles do begin
        seekgfile (cnt);
        read (gfile,gf);
        seekgfile (cnt-1);
        write (gfile,gf)
      end;
      seekgfile (numgfiles);
      truncate (gfile);
      writeurec;
      writestr ('Remove Upload Credits from uploader [y/n]? *');
      if yes then begin
       anarky:=lookupuser (gf.sentby);
       if anarky<>0 then begin
        writeurec;
        seek (ufile,anarky);
        read (ufile,floyd);
        floyd.nup:=floyd.nup-1;
        seek (ufile,anarky);
        write (ufile,floyd);
        readurec
       end;
      end;
      writestr (^M'Deleted.');
      writelog (3,4,gf.gfileDescr)
    end;

    procedure SortGArea;
    var temp,mark,cnt,method:integer;
        v1,v2:string[80];
        gftmp:gfileRec;
    begin
      writehdr ('Sort G-Files');
      writeln;
      writeln ('[0]:Quit');
      writeln ('[1]:Description');
      writeln ('[2]:Filename');
      writeln;
      writestr ('Enter method: *');
      method:=valu(input[1]);
      if method=0 then exit;
      mark:=numgfiles-1;
      repeat
        if mark<>0 then begin
          temp:=mark;
          mark:=0;
          for cnt:=1 to temp do begin
            seekgfile (cnt);
            read (gfile,gf);
            read (gfile,gftmp);
            if method=1 then begin
              v1:=upstring(gf.gfiledescr);
              v2:=upstring(gftmp.gfiledescr);
            end else begin
              v1:=upstring(gf.fname);
              v2:=upstring(gftmp.fname);
            end;
            if v1>v2 then begin
              mark:=cnt;
              seekgfile (cnt);
              write (gfile,gftmp);
              write (gfile,gf)
            end
          end
        end
      until mark=0
    end;

    procedure reordergareas;
    var cura,newa:integer;
        gfatmp:gfilearea;
        f1,f2:file;
        fn1,fn2:sstr;
    label exit;
    begin
      writehdr ('Reorder G-File Areas');
      writeln (^M'Number of G-File areas: ',numareas:1);
      for cura:=0 to numareas-2 do begin
        repeat
          writestr (^M^J+'New Area #'+strr(cura+1)+' [?/List]-[CR/Quit]:');
          if length(input)=0 then goto exit;
          if input='?' then begin
            listareas;
            newa:=-1
          end else begin
            newa:=valu(input)-1;
            if (newa<0) or (newa>=numareas) then begin
              writeln ('Not found!  Please re-enter...');
              newa:=-1
            end
          end
        until (newa>0);
        seek (gfilea,cura);
        read (gfilea,gfa);
        seek (gfilea,newa);
        read (gfilea,gfatmp);
        seek (gfilea,cura);
        write (gfilea,gfatmp);
        seek (gfilea,newa);
        write (gfilea,gfa);
        fn1:=configset.uploaddi+'gfile';
        fn2:=fn1+strr(newa+1);
        fn1:=fn1+strr(cura+1);
        assign (f1,fn1);
        assign (f2,fn2);
        rename (f1,'Temp$$$$.%%%');
        rename (f2,fn1);
        rename (f1,fn2)
      end;
      exit:
      setarea (1)
    end;

    procedure Movegfile;
    var an,fn,old:integer;
        newfilesam,sambam,filesam,wangbang:anystr;
        darn:file;
        gftmp:gfileRec;
    begin
      fn:=GetgfileNum ('Move');
      old:=curarea;
      if fn=0 then exit;
      input:='';
      an:=GetAreaNum;
      if an=0 then exit;
      Seekgfile (fn);
      read (gfile,gftmp);
      if gftmp.arcname<>'' then begin
       writeln (^M'G-File is inside Archive ',gftmp.arcname,'. Cannot move.'^M);
       exit;
      end;
      removefile (fn);
      writestr('Physically move the file to correct area? *');
      write ('Moving...');
      filesam:=Getfname(gftmp.path,gftmp.fname);
      sambam:=gftmp.path;
      setarea(an);
      if (sambam<>gfa.gfileDir) then if yes then begin
        gftmp.path:=gfa.gfileDir;
        newfilesam:=Getfname(gftmp.path,gftmp.fname);
        exec('Copy',' '+filesam+' '+newfilesam+' >temp');
        wangbang:=filesam;
        assign(darn,wangbang);
        if exist(newfilesam) then erase (darn) else begin
          gftmp.path:=sambam;
          writeln('Uh oh... Bad error!');
        end;
      end;
      setarea (An);
      Addfile (gftmp);
      setarea (old);
      writeln (^B'Done.')
    end;

  procedure getpathname (fname:lstr; var path:lstr; var name:sstr);
  var p:integer;
  begin
    path:='';
    repeat
      p:=pos('\',fname);
      if p<>0 then begin
        path:=path+copy(fname,1,p);
        fname:=copy(fname,p+1,255)
      end
    until p=0;
    name:=fname
  end;

  procedure displayfile (var ffinfo:searchrec);
  var a:integer;
  begin
    a:=ffinfo.attr;
    if (a and 8)=8 then exit;
    tab (ffinfo.name,13);
    if (a and 16)=16
      then write ('Directory')
      else write (ffinfo.size);
    if (a and 1)=1 then write (' <read-only>');
    if (a and 2)=2 then write (' <hidden>');
    if (a and 4)=4 then write (' <system>');
    writeln
  end;

  procedure getfsize (var g:gfilerec);
  var df:file of byte;
  begin
    g.filesize:=-1;
    assign (df,getfname(g.path,g.fname));
    reset (df);
    if ioresult<>0 then exit;
    g.filesize:=filesize(df);
    close(df)
  end;

  procedure addresidentgfile (fname:lstr);
  var g:gfilerec;
      fn:anystr;
  begin
    getpathname (fname,g.path,g.fname);
    getfsize (g);
    if g.filesize=-1 then begin
      writeln ('File can''t be opened!');
      exit
    end;
      buflen:=70;
      writestr ('Description: &');
      g.gfiledescr:=input;
      getfsize (g);
      g.when:=now;
      g.sentby:=unam;
      g.downloaded:=0;
      g.specialfile:=false;
      g.newfile:=false;
			g.arcname:='';
			inc(gnugfiles);
			seekgfile (numgfiles+1);
			write (gfile,g);
			writeln;
			writelog (3,11,g.gfiledescr)
	end;

  procedure addmultiplegfiles;
  var spath,pathpart:lstr;
      dummy:sstr;
      f:file;
      ffinfo:searchrec;
  begin
    if ulvl<configset.sysopleve then begin
      writeln (
        'Sorry, you may not add resident files without true sysop access!');
      exit
    end;
    writehdr ('Add Resident G-Files By Wildcard');
    writestr ('Search path/wildcard:');
    if length(input)=0 then exit;
    spath:=input;
    if spath[length(spath)]='\' then dec(spath[0]);
    assign (f,spath+'\con');
    reset (f);
    if ioresult=0 then begin
      close (f);
      spath:=spath+'\*.*'
    end;
    getpathname (spath,pathpart,dummy);
    findfirst (spath,$17,ffinfo);
    if doserror<>0
      then writeln ('No files found!')
      else
        while doserror=0 do begin
          writeln;
          displayfile (ffinfo);
          writestr ('Add this file [Y/N/X]? *');
          if yes
            then addresidentgfile (getfname(pathpart,ffinfo.name))
            else if (length(input)>0) and (upcase(input[1])='X')
              then exit;
          findnext (ffinfo)
        end
  end;

  function defaultdrive:byte;
  var r:registers;
  begin
    r.ah:=$19;
    intr ($21,r);
    defaultdrive:=r.al+1
  end;

  function unsigned (i:integer):real;
  begin
    if i>=0
      then unsigned:=i
      else unsigned:=65536.0+i
  end;

  procedure writefreespace (path:lstr);
  var drive:byte;
      r:registers;
      csize,free,total:real;
  begin
    r.ah:=$36;
    r.dl:=ord(upcase(path[1]))-64;
    intr ($21,r);
    if r.ax=-1 then begin
      writeln ('Invalid drive');
      exit
    end;
    csize:=unsigned(r.ax)*unsigned(r.cx);
    free:=csize*unsigned(r.bx);
    total:=csize*unsigned(r.dx);
    free:=free/1024;
    total:=total/1024;
    writeln (free:0:0,'k out of ',total:0:0,'k')
  end;

  procedure directory;
  var r:registers;
      ffinfo:searchrec;
      tpath:anystr;
      b:byte;
      cnt:integer;
  begin
    getdir (defaultdrive,tpath);
    if tpath[length(tpath)]<>'\' then tpath:=tpath+'\';
    tpath:=tpath+'*.*';
    writestr ('Path/Wildcard [CR for '+tpath+']:');
    writeln (^M);
    if length(input)<>0 then tpath:=input;
    writelog (16,10,tpath);
    findfirst (chr(defaultdrive+64)+':\*.*',8,ffinfo);
    if doserror<>0
      then writeln ('No volume label'^M)
      else writeln ('Volume label: ',ffinfo.name,^M);
    findfirst (tpath,$17,ffinfo);
    if doserror<>0 then writeln ('No files found.') else begin
      cnt:=0;
      while doserror=0 do begin
        cnt:=cnt+1;
        if not break then displayfile (ffinfo);
        findnext (ffinfo)
      end;
      writeln (^B^M'Total Files: ',cnt)
    end;
    write ('Free Disk Space: ');
    writefreespace (tpath)
  end;

  begin
    if not issysop then begin
      reqlevel (configset.sysopleve);
      exit
    end;
    repeat
      q:=menu ('G-File Sysop','SGFILE','QACDUKRMSOW@F');
      case q of
        2:addgfile;
        3:editgfile;
        4:deletegfile;
        5:;
        6:killgarea;
        7:modgarea;
        8:movegfile;
        9:sortgarea;
        10:reordergareas;
        11:addmultiplegfiles;
        12:directory;
      end
    until hungupon or (q=1)
  end;

var prompt:lstr;
    n:integer;
    k:char;
    q1:mstr;
    a:arearec;
    ms:boolean;
    dammit:boolean;
    q:integer;
		x3,zxcv1,zxcv2:integer;
begin
  dammit:=false;
  showit:=true;
  clearscr;
  writeln(^S'Û   Ûßß ÛßßÜ');
  write(^P'Û   ßßÛ Û  Û');writeln(^S' General File Area');
  writeln(^R'ßßß ßßß ßßß ');
  writeln;
  itsotay:=false;
  opengfile;
  if not itsotay then begin
    writeln(^M'No G-File areas exist!');
    goto exitg;
    end;
  seekgfilea(1);
  read (gfilea,gfa);
  if (urec.gLevel<gfa.Level) then begin
    writeln('You don''t have access to the G-Files Section.');
    goto exitg;
  end;
	x3:=ratio(Urec.Nbu,Urec.Numon);
  write (^R'Required Post/Call Ratio: ['^S);
	for zxcv1:=1 to 3-(length(strr(configset.mingfilepcr))) do write (' ');
	write (strr(configset.mingfilepcr));
	writeln ('%'^R']');
	write (^R'Your Post/Call Ratio:     ['^S);
	for zxcv2:=1 to 3-(length(strr(x3))) do write (' ');
	write (strr(x3));
  writeln ('%'^R']');
  writeln;
  write (^R'PCR Status: ['^S);
  if ulvl>=configset.exemptpc then write ('Exempt from PCR.') else
	if (x3<configset.mingfilepcr) and (ulvl<configset.exemptpc) then write ('PCR too low!') else
	if (x3>=configset.mingfilepcr) and (ulvl<configset.exemptpc) then write ('Passed PCR check.');
	writeln (^R']');
	writeln;
	if (x3<configset.mingfilepcr) and (ulvl<configset.exemptpc) then begin
	 writeln (^B^R'Your Posts-per-Call Ratio is too low!');
	 writeln ('Go post a message or two.');
   close (gfile);
   close (gfilea);
   exit;
	end;
	WriteStr('Press Return to Continue.*');
	yourgfstatus;
		setarea(1);
	repeat
		prompt:='';
		q:=menu ('G-Files Command','GFILE','QU%FAYNVDLG');
		case q of
			1:begin
					close(gfile);
					close(gfilea);
				end;
			2:uploadgfile;
			3:sysopcommands;
			4:fastlistgfiles;
			5:getarea;
			6:yourgfstatus;
			7:newscanall;
			8:newscan;
			9:begin
					n:=getgfilenum ('Download');
					if n>0 then showgfile(n);
				end;
			10:fastlistgfiles;
			11:offtheforum;
		end;
	until hungupon or (q=1);
exitg:
close(gfilea);
close(gfile);
end;

begin
end.

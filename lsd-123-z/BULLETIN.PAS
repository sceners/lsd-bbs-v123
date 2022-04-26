{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }

unit bulletin;               (* Message Section for L.S.D. *)

interface

uses crt,dos,windows,
     gentypes,configrt,statret,gensubs,subs1,subs2,
     userret,textret,mainr1,mainr2,overret1,flags,mainmenu;

procedure bulletinmenu;

implementation

procedure bulletinmenu;
var q,curbul,lastreadnum:integer;
    b:bulrec;
    reading,quitmasterinc,cscan:boolean;

procedure readfromtext; forward;

  procedure togglecscan;
  begin
   if cscan then cscan:=false else
    cscan:=true;
   writeln;
   write (^R'Auto-Scan is now: '^S);
   if cscan then writeln ('On') else writeln ('Off');
   writeln;
  end;

  procedure makeboard; forward;

  function sponsoron:boolean;
  begin
    sponsoron:=match(curboard.sponsor,unam)
  end;

  procedure clearorder (var bo:boardorder);
  var cnt:integer;
  begin
    for cnt:=0 to 255 do bo[cnt]:=cnt
  end;

  procedure carryout (var bo:boardorder);
  var u:userrec;
      cnt,un:integer;

    procedure doone;
    var cnt,q:integer;
        ns,a1,a2:set of byte;
    begin
      fillchar (ns,32,0);
      fillchar (a1,32,0);
      fillchar (a2,32,0);
      for cnt:=0 to 255 do begin
        q:=bo[cnt];
        if q in u.newscanconfig then ns:=ns+[cnt];
        if q in u.access1 then a1:=a1+[cnt];
        if q in u.access2 then a2:=a2+[cnt]
      end;
      u.newscanconfig:=ns;
      u.access1:=a1;
      u.access2:=a2;
      seek (ufile,un);
      write (ufile,u)
    end;

  begin
    writeln (^B'Now Adjusting the Flags.....');
    seek (ufile,1);
    for un:=1 to numusers do begin
      if (un mod 10)=0 then write (' ',un);
      read (ufile,u);
      if length(u.handle)>0 then doone
    end
  end;

  procedure switchboards (bnum1,bnum2:integer; var bo:boardorder);
  var bd1,bd2:boardrec;
      n1:integer;
  begin
    seekbdfile (bnum1);
    read (bdfile,bd1);
    seekbdfile (bnum2);
    read (bdfile,bd2);
    seekbdfile (bnum1);
    writebdfile (bd2);
    seekbdfile (bnum2);
    writebdfile (bd1);
    n1:=bo[bnum1];
    bo[bnum1]:=bo[bnum2];
    bo[bnum2]:=n1
  end;

  procedure setfirstboard; forward;


  procedure seekbfile (n:integer);
  begin
    seek (bfile,n-1); che
  end;


  function numbuls:integer;
  begin
    numbuls:=filesize(bfile)
  end;

  procedure getlastreadnum;
  var oldb:boolean;
      b:bulrec;
      lr:word;
  begin
    lastreadnum:=numbuls;
    oldb:=false;
    lr:=urec.lastread[curboardnum+(50*(CurrentConference-1))];
    if lr=0
      then lastreadnum:=0
      else
        while (lastreadnum>0) and (not oldb) do begin
          seekbfile (lastreadnum);
          read (bfile,b);
          oldb:=b.id=lr;
          if not oldb then lastreadnum:=lastreadnum-1
        end;
        if (lastreadnum=0) then urec.lastread[curboardnum+(50*(currentconference-1))]:=0;
  end;

  procedure assignbfile;
  Var S:Mstr;
  begin
  close(bfile);
    S:=ConfigSet.BoardDi+CurBoardName;
    If CurrentConference=1 then S:=S+'.BUL'
       Else
    S:=S+'.BU'+Strr(CurrentConference);
    assign (bfile,s)
  end;

  procedure formatbfile;
  begin
    assignbfile;
    rewrite (bfile);
    curboardnum:=searchboard(curboardname);
    if curboardnum=-1 then begin
      curboardnum:=filesize(bdfile);
      fillchar (curboard,sizeof(curboard),0);
      writecurboard
    end
  end;

  procedure openbfile;
  var b:bulrec;
      i:integer;
  begin
    curboardnum:=searchboard (curboardname);
    if curboardnum=-1 then begin
      makeboard;
      exit
    end;
    close (bfile);
    assignbfile;
    reset (bfile);
    i:=ioresult;
    if ioresult<>0 then formatbfile;
    seekbdfile (curboardnum);
    read (bdfile,curboard);
    getlastreadnum;
  end;

  function boardexist(n:sstr):boolean;
  begin
    boardexist:=not (searchboard(n)=-1)
  end;

  procedure addbul (var b:bulrec);
  var b2:bulrec;
  begin
    if numbuls=0 then b.id:=1 else begin
      seekbfile (numbuls);
      read (bfile,b2);
      if b2.id=65535
        then b.id:=1
        else b.id:=b2.id+1
    end;
    seekbfile (numbuls+1);
    write (bfile,b);
  end;

  function checkcurbul:boolean;
  begin
    if (curbul<1) or (curbul>numbuls) then begin
      checkcurbul:=false;
      curbul:=0
    end else checkcurbul:=true
  end;

  procedure getbrec;
  var n:integer;
      u:userrec;
  begin
    if checkcurbul then begin
      seekbfile (curbul);
      read (bfile,b); che;
      n:=lookupuser(b.leftby);
      b.status:='';
      if n>0 then begin
      seek(ufile,n);
      read(ufile,u);
      b.status:='['+u.usernote+']';
      end;
    end
  end;

  procedure delbul (bn:integer; deltext:boolean);
  var c,un:integer;
      b:bulrec;
      u:userrec;
  begin
    if (bn<1) or (bn>numbuls) then exit;
    seekbfile (bn);
    read (bfile,b);
    if deltext then deletetext (b.line);
    for c:=bn to numbuls-1 do begin
      seekbfile (c+1);
      read (bfile,b);
      seekbfile (c);
      write (bfile,b)
    end;
    seekbfile (numbuls);
    truncate (bfile);
    getlastreadnum
  end;

  procedure delboard (bdn:integer);
  var bd1:boardrec;
      cnt,nbds:integer;
      bo:boardorder;
  begin
    clearorder (bo);
    nbds:=filesize(bdfile)-1;
    if nbds=0 then begin
      close (bdfile);
      rewrite (bdfile);
      exit
    end;
    for cnt:=bdn to nbds-1 do begin
      seekbdfile (cnt+1);
      read (bdfile,bd1);
      seekbdfile (cnt);
      writebdfile (bd1);
      bo[cnt]:=cnt+1
    end;
    seek (bdfile,nbds);
    truncate (bdfile);
    seek (bifile,nbds);
    truncate (bifile);
    carryout (bo)
  end;


  procedure getbnum (txt:mstr);
  var q:boolean;
  begin
    if length(input)>1
      then curbul:=valu(copy(input,2,255))
      else begin
        writestr (^M'Message to '+txt+':');
        curbul:=valu(input)
      end;
    q:=checkcurbul
  end;

procedure killbul;
  var un:integer;
      u:userrec;
  begin
    writehdr ('Message Deletion');
    if not reading then
    getbnum ('delete');
    if not checkcurbul then exit;
    getbrec;
    if (not match(b.leftby,unam)) and (not issysop) and (not sponsoron)
      then begin
        writeln ('Hey You didnt post that!');
        exit
      end;
    writeln ('Subject: ',b.title,
           ^M'Left by: ',b.leftby,^M^M);
    writestr ('Delete this? *');
    if not yes then exit;
    un:=lookupuser (b.leftby);
    if un<>0 then begin
      writeurec;
      seek (ufile,un);
      read (ufile,u);
      u.nbu:=u.nbu-1;
      seek (ufile,un);
      write (ufile,u);
      readurec
    end;
    delbul (curbul,true);
    writeln ('Message deleted.');
    writelog (4,5,b.title)
  end;

  procedure autodelete;
  var c,un,bn,cnt:integer;
      B:bulrec;
      u:userrec;
  begin
    bn:=2;
    if (bn<1) or (bn>numbuls) then exit;
    writeln (^R^A'Please wait... Deleting first 5 messages..');
    for cnt:=6 downto 2 do begin
     {delbul (cnt,true) }
    seekbfile(cnt);
    read(bfile,b);
    deletetext(b.line);
    end;
    for c:=bn to numbuls-5 do begin
    seekbfile(c+5);
    read(bfile,b);
    seekbfile(c);
    write(bfile,b);
    end;
    seekbfile(numbuls-4);
    truncate(bfile);
    getlastreadnum;
    end;



  function wipe(amount:byte):string;
  var z:integer;
      gee:string[80];
   begin
   for z:=1 to amount do gee:=gee+' ';
   wipe:=gee;
   end;

  procedure postbul;
  var l:integer;
      m:message;
      b:bulrec;
      ds:longint;
  begin
    if ulvl<configset.postleve then begin
      reqlevel(configset.postleve);
      exit
    end;
    l:=editor(m,true,true,'0','0');
    if l>=0 then
      begin
        inc(urec.nbu);
        writeurec;
        b.Where:=Configset.Origin1;
        B.Where2:=Configset.Origin2;
        B.Version:=NetMailVer;
        B.Cnet:=False;
        B.FidoNet:=False;
        B.Flag3:=False;
        B.Flag4:=False;
        B.Flag5:=False;
        B.Flag6:=False;
        B.Flag7:=False;
        B.Flag8:=False;
        B.RealName:=Urec.RealName;
        b.anon:=m.anon;
        b.title:=m.title;
        b.when:=now;
        b.leftby:=unam;
        b.status:='[ ha ]';
        b.recieved:=false;
        b.leftto:=m.sendto;
        b.line:=l;
        b.plevel:=ulvl;
        addbul (b);
        inc(newposts);
        inc(gnup);
        with curboard do
          if autodel<=numbuls then autodelete
      end
  end;

  procedure readcurbul;
  var q:anystr;
      t:sstr;
      cnt,emusux,anarkyamerika:integer;
      oligarch:mstr;
  begin
    q:=wipe(80);
    if checkcurbul then begin
      getbrec;
			clearscr;
			Writeln(^P'Sub-Board : '^S,curboard.boardname);
			write   (^B^M^P'Message: '^S);
			oligarch:=^S+strr(curbul)+' of '+strr(numbuls);
			writeln (oligarch);
			writeln (^P'When:    '^S,datestr(b.when),' at ',timestr(b.when),^R);
			writeln (^P'Subject: '^S,b.title);
			write   (^P'To:      '^S,b.leftto);
			if (b.recieved) then begin
			 for anarkyamerika:=1 to 25-(length(b.leftto)+3) do
			 write (' ');
			 write (^A'[Received]'^R);
			end;
			writeln;
			q:=^P'From:    '^S;
			if b.anon then
					begin
						q:=q+configset.anonymousst;
						if (issysop) or (ulvl>=configset.sysopleve) then q:=q+' ['+^A+b.leftby+^S+']'
					end
				else
					begin
						if b.plevel=-1
							then t:='unknown'
							else t:=strr(b.plevel);
					 q:=q+b.leftby;
					 if urec.level>=b.plevel then q:=q+' '+^P+'[Level '+^F+t+^P+'] '+^S else q:=q+' <Classified> ';
					 q:=q+b.status;
					end;
			writeln (q);
      if break then exit;
      printtext (b.line);
      If Curboard.Echo>0 then WriteLn(^P'['^A'Net Origin:'+B.Where+^P'] ['^A+B.Where2+^P']'^M);
      if match (b.leftto,unam) then begin
       b.recieved:=true;
       seekbfile (curbul);
       write (bfile,b);
      end;
      ansicolor (urec.regularcolor);
    end;
    begin

      if (urec.lastread[curboardnum+(50*(currentconference-1))]<=b.id) or (curbul>=lastreadnum) then
      urec.lastread[curboardnum+(50*(CurrentConference-1))]:=b.id;
      if lastreadnum<curbul then lastreadnum:=curbul;
    end
  end;

  function queryaccess:accesstype;
  begin
    queryaccess:=getuseraccflag (urec,curboardnum)
  end;

  procedure readbul;
  begin
    getbnum ('Read');
    readcurbul
  end;

  procedure readnextbul;
  var t:integer;
  begin
    t:=curbul;
    inc(curbul);
    readcurbul;
    if curbul=0 then curbul:=t
  end;

  procedure readnum (n:integer);
  begin
    curbul:=n;
    readcurbul
  end;

  function haveaccess (n:integer):boolean;
  var a:accesstype;
  begin
    curboardnum:=n;
    seekbdfile (n);
    read (bdfile,curboard);
    a:=queryaccess;
    if curboard.conference>0 then begin
       haveaccess:=false;
       if urec.confset[curboard.conference]>0 then haveaccess:=true;
     exit;
    end;
    if a=bylevel
      then haveaccess:=ulvl>=curboard.level
      else haveaccess:=a=letin
  end;

  procedure makeboard;
  begin
    formatbfile;
    If FileSize(BDfile)=51 then Begin
       WriteLn('You may not have more then 51 message areas per conference!');
       Exit;
    End;
    with curboard do begin
      shortname:=curboardname;
      buflen:=30;
      writestr (^M'Board Name: &');
      boardname:=input;
      buflen:=30;
      writestr ('Sponsor [CR/'+unam+']:');
      if input='' then input:=unam;
      sponsor:=input;
      writestr('Conference [CR/None] :');
      if input='' then input:='0';
      conference:=valu(input);
      writestr ('Minimum Level for entry:');
      level:=valu(input);
      writestr ('Autodelete after [CR/25]:');
      if length(input)<1 then input:='25';
      autodel:=valu(input);
      if autodel<10 then begin
        writeln ('Must be at least 10!');
        autodel:=10
      end;
      WriteStr('EchoMail Conference (0=None): [0]:');
      if Input='' then input:='0';
      echo:=Valu(Input);
      setallflags (curboardnum,bylevel);
      writecurboard;
      writeln ('Board created.');
      writelog (4,4,boardname+' ['+shortname+']')
    end
  end;

  procedure setactive (nn:sstr);

    procedure doswitch;
    begin
      openbfile;
      curbul:=lastreadnum;
      with curboard do
     begin
      curbul:=lastreadnum;
      with curboard do
      if not (ansigraphics in urec.config) then  writeln (^M'Sub-board: '^S,boardname,
                 ^M'Sponsor:   '^S,sponsor,
                 ^M'Bulletins: '^S,numbuls,
                 ^M'Last read: '^S,lastreadnum,^M)
           else begin
                clearscr;
                blowup(1,1,50,6);write(^S);
								printxy(2,3,'Sub-Board: '^S+boardname);
								printxy(3,3,'Sponsor:   '^S+sponsor);
								printxy(4,3,'Bulletins: '^S+strr(numbuls));
								printxy(5,3,'Last Read: '^S+strr(lastreadnum));
								printxy(15,0,' ');
					 end
		end;
    end;

    procedure tryswitch;
    var n,s:integer;

      procedure denyaccess;
      var b:bulrec;
      begin
        writeln(^M^P'Invalid Board!'^G);
        setfirstboard
      end;

    begin
      curboardname:=nn;
      curboardnum:=searchboard(nn);
      if haveaccess(curboardnum)
        then doswitch
        else denyaccess
    end;

  var b:bulrec;
  begin
    curbul:=0;
    close (bfile);
    curboardname:=nn;
    if boardexist(nn) then tryswitch else begin
      writeln ('No such board: ',curboardname,'!');
      if issysop
        then
          begin
            writestr (^M'Create one [y/n]? *');
            if yes
              then
                begin
                  makeboard;
                  setactive (curboardname)
                end
              else setfirstboard
          end
        else setfirstboard
    end
  end;

  function validbname (n:sstr):boolean;
  var cnt:integer;
  begin
    validbname:=false;
    if (length(n)=0) or (length(n)>8) then exit;
    for cnt:=1 to length(n) do
      if not (upcase(n[cnt]) in ['0'..'9','A'..'Z']) then exit;
    validbname:=true
  end;

  procedure listboards;
  var cnt,oldcurboard:integer;
      printed:boolean;
  begin
    oldcurboard:=curboardnum;
    clearscr;writehdr(' Message Areas ');
   writeln(^R'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
   writeln(^R'³ '^P'Number       Base Name                     Level/Conference'^R' ³');
   writeln(^R'ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´');
    if break then exit;
    for cnt:=0 to filesize(bdfile)-1 do
      if haveaccess(cnt) then
        with curboard do begin
        write(^R'³ '^P);
          tab (shortname,11); write(^R'³ '^P);
          tab (boardname,31); write(^R'³ '^P);
          if (conference>0) then tab('Conference '+strr(conference),14) else
          tab(strr(level),14);
           writeln(^R'³');
          if break then exit
        end;
   writeln(^R'ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'^M);
    curboardnum:=oldcurboard;
    seekbdfile (curboardnum);
    read (bdfile,curboard)
  end;


  procedure activeboard;
  begin
    if length(input)>1
      then input:=copy(input,2,255)
      else begin
        listboards;
        repeat
          writestr (^M^M^P'Board Number ['^F'?'^A'/'^F'List'^P']:');
          if input='?' then listboards
        until (input<>'?') or hungupon;
      end;
    if hungupon or (length(input)=0) then exit;
    if input[1]='*' then input:=copy(input,2,255);
    if validbname(input)
      then setactive (input)
      else
        begin
          writeln (^M'Invalid board name!');
          setfirstboard
        end
  end;

  procedure setfirstboard; { FORWARD }
  var fbn:sstr;
  begin
    if filesize(bdfile)=0 then exit;
    if not haveaccess(0)
      then error ('Sorry user cannot access first sub board!','','');
    seek (bifile,0);
    read (bifile,fbn);
    setactive (fbn)
  end;

  procedure listbuls;
  var cnt,bn:integer;
      q:boolean;
  begin
    if length(input)>1 then begin
      curbul:=valu(copy(input,2,255));
      q:=checkcurbul
    end;
    if curbul=0
      then
        begin
          writestr (^M'List titles starting at #*');
          curbul:=valu(input)
        end
      else
        if length(input)>1
          then curbul:=valu(input)
          else curbul:=curbul+10;
    if not checkcurbul then curbul:=1;
    writeln ('Titles:'^M);
    for cnt:=0 to 9 do
      begin
        bn:=curbul+cnt;
        if (bn>0) and (bn<=numbuls) then
          begin
            seekbfile (bn);
            read (bfile,b);
            write (bn,'. '^S,b.title,^R' by ');
            if b.anon
              then writeln (configset.anonymousst)
              else writeln (b.leftby);
            if break then exit
          end
      end
  end;

  procedure editbul;
  var me:message;
  begin
    getbnum ('edit');
    if not checkcurbul then exit;
    getbrec;
    if (not match(b.leftby,unam)) and (not issysop) and (not sponsoron)
      then begin
        writeln ('You can not edit a message you didn''t post!');
        exit
      end;
    reloadtext (b.line,me);
    me.title:=b.title;
    me.anon:=b.anon;
    me.sendto:=b.leftto;
    if reedit (me,true) then begin
      writelog (4,6,b.title);
      deletetext (b.line);
      b.line:=maketext (me);
      if b.line<0 then begin
        writestr (^M'Deleting bulletin...');
        delbul (curbul,false)
      end else begin
        seekbfile (curbul);
        write (bfile,b)
      end
    end
  end;


  procedure sendbreply;
  begin
    if checkcurbul then begin
      getbrec;
      sendmailto (b.leftby,b.anon)
    end else begin
      getbnum ('reply to');
      if checkcurbul then sendbreply
    end
  end;

  procedure uploadfile;
  var f:text;
      b:bulrec;
      me:message;
      tu:mstr;
      sub,ls:lstr;
      lne:integer;
  begin
    writeln(^M^S'Message Upload Via X-Modem.'^M);
    writestr(^R'Post to ['^P'Return=All'^R']:*');
    if input='' then input:='All';
    tu:=input;
    writestr(^M^P'Subject:*');
    if input='' then exit;
    sub:=input;
    writeln(^M^S'Ready to receive via X-Modem Upload!');
    assign(f,configset.forumdi+'Message.Xyz');
    if exist(configset.forumdi+'Message.Xyz') then erase(f);
    delay(500);
    exec('Dsz.Com',' port '+strr(configset.useco)+' speed '+strr(baudrate)+' rx '+configset.forumdi+'Message.Xyz');
    if dosexitcode<>0 then begin
       writeln(^G^G'Aborted!');
       if exist(configset.forumdi+'Message.Xyz') then erase(f);
       exit;
    end;
    lne:=0;
    reset(f);
    while not eof(f) do begin
      readln(f,ls);
      inc(lne);
      if lne>100 then begin
        Writeln(^G^G^G^S'You may NOT have more then 100 lines in a message!');
        textclose(f);
        erase(f);
        exit;
      end;
      me.text[lne]:=ls;
    end;
    me.anon:=false;
    me.numlines:=lne;
    me.sendto:=tu;
    me.note:=urec.usernote;
    lne:=maketext(me);
    b.anon:=false;
    b.title:=sub;
    B.Where:=Configset.origin1;
    B.Where2:=Configset.origin2;
    B.Version:=NetMailVer;
    B.Cnet:=False;
    B.FidoNet:=False;
    B.Flag3:=False;
    B.Flag4:=False;
    B.Flag5:=False;
    B.Flag6:=False;
    B.Flag7:=False;
    B.Flag8:=False;
    B.RealName:=Urec.RealName;
    b.when:=now;
    b.leftby:=unam;
    b.status:='[ ha ]';
    b.recieved:=false;
    b.leftto:=tu;
    b.line:=lne;
    b.plevel:=ulvl;
    addbul(b);
    inc(newposts);
    inc(gnup);
    with curboard do if autodel<=numbuls then autodelete;
    writeln(^M^S'Message posted!');
  end;

  procedure boardsponsor;

    procedure getbgen (txt:mstr; var q);
    var s:lstr absolute q;
    begin
      writeln (^B'Current ',txt,': ',s);
      buflen:=30;
      writestr ('Enter new '+txt+': &');
      if length(input)>0 then s:=input
    end;

    procedure getbint (txt:mstr; var i:integer);
    var a:anystr;
    begin
      a:=strr(i);
      getbgen (txt,a);
      i:=valu(a);
      writecurboard
    end;

    procedure getbstr (txt:mstr; var q);
    begin
      getbgen (txt,q);
      writecurboard
    end;

    procedure setacc (ac:accesstype; un:integer);
    var u:userrec;
    begin
      seek (ufile,un);
      read (ufile,u);
      setuseraccflag (u,curboardnum,ac);
      seek (ufile,un);
      write (ufile,u)
    end;

    function queryacc (un:integer):accesstype;
    var u:userrec;
    begin
      seek (ufile,un);
      read (ufile,u);
      queryacc:=getuseraccflag (u,curboardnum)
    end;

    procedure setnameaccess;
    var un,n:integer;
        ac:accesstype;
        q,unm:mstr;
    begin
      writestr (^M'Change Access for User:');
      un:=lookupuser(input);
      if un=0 then begin
        writeln ('No such user!');
        exit
      end;
      unm:=input;
      ac:=queryacc(un);
      writeln (^B^M'Current access: ',accessstr[ac]);
      getacflag (ac,q);
      if ac=invalid then exit;
      if un=unum then writeurec;
      setacc (ac,un);
      if un=unum then readurec;
      case ac of
        letin:n:=1;
        keepout:n:=2;
        bylevel:n:=3
      end;
      writelog (5,n,unm)
    end;

    procedure setallaccess;
    var cnt:integer;
        ac:accesstype;
        q:mstr;
    begin
      writehdr ('Set Everyone''s Access');
      getacflag (ac,q);
      if ac=invalid then exit;
      writeurec;
      setallflags (curboardnum,ac);
      readurec;
      writeln ('Done.');
      writelog (5,4,accessstr[ac])
    end;

    procedure listaccess;

      procedure listacc (all:boolean);
      var cnt:integer;
          a:accesstype;
          u:userrec;

        procedure writeuser;
        begin
          if all
            then
              begin
                tab (u.handle,30);
                if a=bylevel
                  then writeln ('Level='+strr(u.level))
                  else writeln ('Let in')
              end
            else writeln (u.handle)
        end;

      begin
        seek (ufile,1);
        for cnt:=1 to numusers do begin
          read (ufile,u);
          if curboard.conference=0 then Begin
          a:=getuseraccflag (u,curboardnum);
          case a of
            letin:writeuser;
            bylevel:if all and (u.level>=curboard.level) then writeuser
          end;
          end Else If U.ConfSet[Curboard.Conference]>0 then WriteUser;
          if break then exit
        end
      end;

    begin
      writestr (
'List [A]ll users who have access, or only those with [S]pecial access? *');
      if length(input)=0 then exit;
      case upcase(input[1]) of
        'A':listacc (true);
        'S':listacc (false)
      end
    end;

    procedure getblevel;
    var b:bulrec;
    begin
      getbint ('level',curboard.level);
      writelog (5,12,strr(curboard.level))
    end;

   procedure setanon;
   var b:bulrec;
   begin
     writestr ('Which Conference [0]: *');
     if input='' then input:='0';
     curboard.conference:=valu(input);
     writecurboard;
   end;

   procedure getautodel;
    var b:bulrec;
    begin
      with curboard do begin
        getbint ('auto-delete',autodel);
        if autodel<10
          then
            begin
              writeln (^B'HEY!  It can''t be less than ten!');
              autodel:=numbuls+1;
              if autodel<10 then autodel:=10;
              writeln (^B'Setting autodelete to ',autodel);
              writecurboard
            end
          else
            if autodel<=numbuls
              then
                begin
                  writeln (^B'Deleting bulletins...');
                  while autodel<=numbuls do delbul (2,true)
                end
      end;
      writelog (5,11,strr(curboard.autodel))
    end;


    procedure movebulletin;
    var b:bulrec;
        tcb:boardrec;
        tcbn,dbn,bnum:integer;
        tcbname,dbname:sstr;
    begin
      writehdr ('Message Move');
      getbnum ('move');
      if not checkcurbul then exit;
      bnum:=curbul;
      seekbfile (bnum);
      read (bfile,b);
      writestr ('Move "'+b.title+'" posted by '+b.leftby+
        ' to which board? *');
      if length(input)=0 then exit;
      tcbname:=curboardname;
      dbname:=input;
      dbn:=searchboard(dbname);
      if dbn=-1 then begin
        writeln ('No such board!');
        exit
      end;
      writeln ('Moving...');
      delbul (bnum,false);
      close (bfile);
      curboardname:=dbname;
      openbfile;
      addbul (b);
      close (bfile);
      curboardname:=tcbname;
      openbfile;
      writelog (5,13,b.title);
      writeln (^B'Done!')
    end;


    procedure setsponsor;
    var un:integer;
        b:bulrec;
    begin
      writestr ('New sponsor:');
      if length(input)=0 then exit;
      un:=lookupuser (input);
      if un=0
        then writeln ('No such user.')
        else
          begin
            curboard.sponsor:=input;
            writelog (5,8,input);
            writecurboard
          end
    end;

    procedure renameboard;
    var sn:sstr;
        nfp,nbf,nff:lstr;
        qf:file;
       q,d:integer;
    begin
     repeat
            clearscr;
            sn:=curboard.shortname;
            writehdr('Sub-Board Rename');
            writeln(^R'1) Area Name            : '^S,curboard.boardname);
            writeln(^R'2) Echo Mail Conference : '^S,Curboard.Echo);
            write(^R'3) Conference Number    : '^S); if curboard.conference=0 then writeln('None') else
            writeln(curboard.conference);
            writeln(^R'4) Access Level         : '^S,curboard.level);
            writeln(^R'5) Access Name/Number   : '^S,curboard.shortname);
            writeln(^R'6) Maximum messages     : '^S,curboard.autodel);
            writeln(^R'7) Sponsor              : '^S,curboard.sponsor);
            writestr(^M'Number to change or [X] to exit : [X]:');
            if match(input,'X') or (input='') then input:='100';
            q:=valu(input);
            case q of
            1:begin getbstr ('Board Name',curboard.boardname);
                    sn:=curboard.shortname;
                    end;
            2:begin
                   WriteStr(^M'Echo Conference (0=None): [0]:');
                   if input='' then input:='0';
                   Curboard.Echo:=Valu(Input);
               end;
            3:begin
                  writestr(^M'Current Conference :'+strr(curboard.conference)+^M'New conference, [Ret=No Change]:');
                  if input='' then input:=strr(curboard.conference);
                  curboard.conference:=valu(input);
                  end;
            6:getautodel;
            7:setsponsor;
            4:begin
                    writestr(^M'Current Access Level :'+strr(curboard.level)+^M'New Level [Ret=No Change]:');
                    if input='' then input:=strr(curboard.level);
                    curboard.level:=valu(input);
                    end;
            5:begin
                  writeln;
                   getbgen ('Access Name/Number',sn);
                   writelog (5,5,curboard.boardname+' ['+sn+']');
                   if not validbname(sn) then begin
                   writeln ('Invalid board name!');
                   end else
                   if boardexist(sn) then begin
                    writeln ('Sorry!  Board already exists!');
                    end else
                    curboard.shortname:=sn;
            end;
     end
     until (q=100) or hungupon;
      writecurboard;
      close (bfile);
      nfp:=configset.boarddi+curboard.shortname+'.';
      If CurrentConference=1 then nbf:=nfp+'BUL'
      Else
        Nbf:=Nfp+'BU'+Strr(CurrentConference);
      if not exist(nbf) then
      rename (bfile,nbf);
      close(bfile); assign(bfile,nbf); reset(bfile);
      q:=9
    end;

    procedure killboard;
    var cnt:integer;
        f:file;
        bd:boardrec;
    begin
      writestr ('Kill Board - You sure [y/n]? *');
      if not yes then exit;
      writelog (5,10,'');
      writeln (^B^M'Deleting messages...');
      for cnt:=numbuls downto 1 do
        begin
          delbul(cnt,true);
          write (cnt,' ');
        end;
      writeln (^B^M'Deleting sub-board files...');
      close (bfile);
      assignbfile;
      erase (bfile);
      if ioresult<>0 then writeln (^B'Error erasing board file.');
      writeln (^M'Removing sub-board...');
      delboard (curboardnum);
      writeln (^B'Sub-board erased!');
      setfirstboard;
      q:=9
    end;

    procedure sortboards;
    var cnt,mark,temp:integer;
        bd1,bd2:boardrec;
        bn1,bn2:sstr;
        bo:boardorder;
    begin
      writestr ('Sort sub-boards: Are you sure? *');
      if not yes then exit;
      clearorder (bo);
      mark:=filesize(bdfile)-1;
      repeat
        if mark<>0 then begin
          temp:=mark;
          mark:=0;
          for cnt:=0 to temp-1 do begin
            seek (bifile,cnt);
            read (bifile,bn1);
            read (bifile,bn2);
            if upstring(bn1)>upstring(bn2) then begin
              mark:=cnt;
              switchboards (cnt,cnt+1,bo)
            end
          end
        end
      until mark=0;
      carryout (bo);
      writelog (5,16,'');
      setfirstboard;
      q:=9
    end;

    procedure orderboards;
    var numb,curb,newb:integer;
        bo:boardorder;
     label exit;

    begin
      clearorder (bo);
      writehdr ('Re-order sub-boards');
      numb:=filesize (bdfile);
      thereare (numb,'sub-board','sub-boards');
      for curb:=0 to numb-2 do begin
        repeat
          writestr ('New Board #'+strr(curb+1)+' [?/List, CR/Quit]:');
          if length(input)=0 then goto exit;
          if input='?'
            then
              begin
                listboards;
                newb:=-1
              end
            else
              begin
                newb:=searchboard(input);
                if newb<0 then writeln ('Not found!  Please re-enter...')
              end
        until (newb>=0);
        switchboards (curb,newb,bo)
      end;
      exit:
      carryout (bo);
      writelog (5,14,'');
      q:=9;
      setfirstboard
    end;

  begin
    if (not sponsoron) and (not issysop) then begin
			writeln ('Nice try, but you aren''t the sponsor.');
			inc(hackattempts);
			DoHackShit;
      exit
    end;
    writelog (4,3,curboard.boardname+' ['+curboard.shortname+']');
    repeat
      q:=menu ('Message Bases Sponsor','SPONSOR','DLSTMWUEQRKCNBOVH!');
      case q of                                               (* |  |  *)
        1:getautodel;
        2:getblevel;
        3:setsponsor;
        4,5,6,16:writeln(^M^S'Function Removed.');
        7:setnameaccess;
        8:setallaccess;
        10:renameboard;
        11:killboard;
        12:sortboards;
        13:movebulletin;
        14:orderboards;
        15:listaccess;
        18:readfromtext;
        17:help ('Sponsor.Hlp');
      end
    until (q=9) or hungupon
  end;

  var beenaborted:boolean;

  function aborted:boolean;
  begin
    if beenaborted then begin
      aborted:=true;
      exit
    end;
    aborted:=xpressed or hungupon;
    if xpressed then begin
      beenaborted:=true;
      writeln (^B'Message Newscan Aborted!')
    end
  end;

  Function capfir(inString:STRING):char;
 begin
   capfir:=upcase(inString[1]);
 end;


  function forwardbackthread(search:lstr; forard:boolean):boolean;
  var Done:Boolean;
      old:word;
      cnt:integer;

      function matched(se:lstr):Boolean;
      Begin
        Matched:=Pos(Search,UpString(Se))>0;
      End;

      procedure stripsearch;
      Begin
        If pos(' [Reply',search)>0 then Search:=Copy(Search,1,pos(' [Reply',search)-1);
        Search:=UpString(Search);
      End;

      Begin
        StripSearch;
        Done:=False;
        Old:=CurBul;
        if forard then
            Repeat
              inc(curbul);
              getbrec;
              if matched(b.title) then done:=true;
            until Done or (curbul>=numbuls)
            else
             Repeat
               dec(curbul);
               getbrec;
               if matched(b.title) then done:=true;
             until done or (curbul<=1);
        if not done then curbul:=old;
        forwardbackthread:=done;
      end;

  procedure newscanboard;

    function getnumnum(title:lstr):integer;
var reprep      :byte;
    startpoint  :byte;
    endpoint    :byte;
    a           :string[1];
begin
   reprep    :=79;
   startpoint:=0;
   endpoint  :=0;
   getnumnum :=0;
  repeat
   a:=copy (title,reprep,1);
   if a='#' then
     begin;
       startpoint:=reprep;
         repeat
           if valu(copy(title,reprep,1))>0 then endpoint:=reprep;
           inc(reprep);
         until (reprep>=79);
     end;
   if (startpoint>0) and (endpoint>0) then
      begin
        dec(endpoint,startpoint);
        getnumnum:=valu(copy(title,startpoint+1,endpoint));
        exit;
      end;
    dec(reprep);
  until reprep<=0
end;

function gettitle(title:lstr;reply:word):lstr;
var search   :boolean;
    srcstr   :sstr;
    cursrc   :word;
    tit      :lstr;
begin

   srcstr  :=' [Reply #';
   search  :=false;
   tit     :='';
   cursrc  :=0;

   repeat
    if copy(title,cursrc,length(srcstr))=srcstr then
      begin;
        tit:=copy(title,1,cursrc-1);
        gettitle:=tit+' [Reply #'+strr(reply)+']';
        exit;
      end;

    if cursrc=79 then
      begin
        gettitle:=title+' [Reply #'+strr(reply)+']';
        exit;
      end;
    inc(cursrc);
   until cursrc=80;
end;


  var newmsgs,oldb:boolean;
      tt:text;
      q:anystr;
      wock:char;
      wock2:word;
      m,me:message;
      l,stonerslive,swash,kook:integer;
      t:sstr;
      fcpiskool:mstr;
      repnumber:word;
      lameo    :string;
  begin
    beenaborted:=false;
    newmsgs:=false;
    curbul:=lastreadnum+1;
    while curbul<=numbuls do begin
      getbrec;
        readnum (curbul);
        newmsgs:=true;
      repeat
       wock:='N';
       If (TimeLeft<1) and Not Local then
         Begin
            PrintFile(ConfigSet.TextFileDi+'TimesUp');
            ForceHangup:=True;
            Exit;
         End;
       writestr (^P'[F,B/Thread] [CR/Next] [A/Again] [D/Del] [#/Go] [R/Rep] [P/Post] [Q] [S/Skip]:*');
       if length(input)<1 then input:='N';
       wock:=upcase(input[1]);
       wock2:=valu(input);
       if wock2>0 then begin
        if wock2<=numbuls then begin
         curbul:=wock2;
         readnum (curbul);
        end;
       end else
        wock:=upcase(wock);
        case wock of
        'F':If not forwardbackthread(b.title,true) then WriteLn(^M^G^S'No Forward thread found!')
            else
              Begin
               getbrec;
               readnum(curbul);
              end;
        'B':If not forwardbackthread(b.title,false) then WriteLn(^M^G^S'No backward thread found!')
            else
              Begin
                GetBrec;
                ReadNum(CurBul);
              End;
         '?':begin
              writeln;
              writeln (^S'                 -Newscan Help-'^R^M);
              writeln ('[N]: Next Message          [#]: Read that Message #');
              writeln ('[A]: Read Message Again    [R]: Reply to Message');
              writeln ('[D]: Delete Message        [P]: Post a Message');
              writeln ('[S]: Next Sub-board        [/]: Toggle Auto-Scan');
              writeln ('[B]: Backwards Thread      [F]: Forward thread');
              if (match(unam,b.leftby)) or (issysop) or (sponsoron)
              then write ('[E]: Edit Message          ');
              writeln ('[Q]: Quit Newscan');
              writeln;
             end;
				 'A':readcurbul;
				 'P':postbul;
         'D':begin
              reading:=true;
              killbul;
              curbul:=curbul-1;
              reading:=false;
             end;
         'R':begin
              if ulvl<configset.postleve then begin
                reqlevel(configset.postleve);
                exit
              end;
              q:=b.leftby;
              if b.anon then q:=configset.anonymousst;
              lameo:=q;
              l:=editor(m,false,true,q,b.title);
              if l>=0 then
                begin
                  inc(urec.nbu);
                  writeurec;
                  b.anon:=m.anon;
                  repnumber:=getnumnum(b.title);
                  inc(repnumber);
                  b.title:=gettitle(b.title,repnumber);
                  b.when:=now;
                  b.leftto:=lameo;
                  b.leftby:=unam;
                  b.status:='[ ha ]';
                  b.line:=l;
                  b.recieved:=false;
                  b.RealName:=Urec.RealName;
                  B.Cnet:=False;
                  b.Version:=NetMailVer;
                  B.FidoNet:=False;
                  B.Flag3:=False;
                  B.Flag4:=False;
                  B.Flag5:=False;
                  B.Flag6:=False;
                  B.Flag7:=False;
                  B.Flag8:=False;
                  b.where:=Configset.Origin1;
                  B.Where2:=Configset.origin2;
                  b.plevel:=ulvl;
                  addbul (b);
                  inc(newposts);
                  inc(gnup);
                   with curboard do
                    if autodel<=numbuls then begin
                      autodelete;
                      if curbul>5 then curbul:=curbul-5 else curbul:=1;
                      end;
                end
             end;
         'E':begin
              if checkcurbul then begin
              if (not match(b.leftby,unam)) and (not issysop) and (not sponsoron)
                then begin
                  writeln ('You didn''t post that!');
                end
              else begin
              reloadtext (b.line,me);
              me.title:=b.title;
              me.anon:=b.anon;
              if reedit (me,true) then begin
                writelog (4,6,b.title);
                deletetext (b.line);
                b.line:=maketext (me);
                if b.line<0 then begin
                  writestr (^M'Deleting bulletin...');
                  delbul (curbul,false)
                end else begin
                  seekbfile (curbul);
                  write (bfile,b)
                 end
                end
               end;
              end;
             end;
         'S':exit;
         '/':togglecscan;
         'Q':begin
              quitmasterinc:=true;
              exit;
             end;
       end;
      until wock in ['N'];
      inc(curbul);
     if aborted then exit;
    end;
    if (postprompts in urec.config) and newmsgs and (ulvl>=configset.postleve)
      then begin
        writestr (^M^P'Post on ['^S+curboard.boardname+^P'] '^F'(y/n)'^P'? *');
        writeln;
        if yes then postbul
      end
  end;

  procedure newscanall;
  var cb:integer;
  begin
    beenaborted:=false;
    writehdr ('New-Scanning Messages.  [X] will abort.');
    if aborted then exit;
    for cb:=0 to filesize(bdfile)-1 do begin
      if aborted then exit;
      if haveaccess(cb) and (not (cb in urec.newscanconfig)) then begin
        curboardname:=curboard.shortname;
        openbfile;
				if aborted then exit;
				clearscr;
				writeln (^R'Scanning ['^S,curboard.boardname,^R']...'^M);
        if aborted then exit;
        newscanboard;
        if quitmasterinc then begin
         quitmasterinc:=false;
	 writeln (^B^M'Newscan aborted!'^G);
	 setfirstboard;
         exit;
        end
      end
    end;
    writeln (^B^M'Newscan complete!'^G);
    setfirstboard
  end;

  procedure noboards;
  begin
    writeln ('No sub-boards exist!');
    if not issysop then exit;
    writestr ('Create the first sub-board now [y/n]? *');
    if not yes then exit;
    writestr ('Enter its access name/number:');
    if not validbname(input) then writeln (^B'Invalid board name!') else begin
      curboardname:=input;
      makeboard
    end
  end;

  procedure togglenewscan;
  begin
    write ('Newscan this board: ');
    if curboardnum in urec.newscanconfig
      then
        begin
          writeln ('Yes');
          urec.newscanconfig:=urec.newscanconfig-[curboardnum]
        end
      else
        begin
          writeln ('No');
          urec.newscanconfig:=urec.newscanconfig+[curboardnum]
        end
  end;

  procedure nextsubboard;
  var cb:integer;
      obn:sstr;
  begin
    obn:=curboardname;
    cb:=curboardnum;
    while cb<filesize(bdfile)-1 do begin
      inc(cb);
      if haveaccess (cb) then begin
        seek (bifile,cb);
        read (bifile,obn);
        setactive (obn);
        exit
      end
    end;
    writestr ('This is the last sub-board!');
    setactive (obn)
  end;

  procedure listusersaxis;

      procedure listacc (all:boolean);
      var cnt:integer;
          a:accesstype;
          u:userrec;

      begin
        seek (ufile,1);
        for cnt:=1 to numusers do begin
          read (ufile,u);
          If Curboard.Conference=0 then Begin
          a:=getuseraccflag (u,curboardnum);
          case a of
            letin:writeln (^S,u.handle,^R);
            bylevel:if u.level>=curboard.level then writeln (^S,u.handle,^R);
          end;
          end else if U.ConfSet[CurBoard.Conference]>0 then WriteLn(^S,u.Handle,^R);
          if break then exit
        end
      end;

    begin
     writehdr ('List Users with Board Access');
     writeln;
     writeln (^R'Users with access to ['^S+curboard.boardname+^R']:');
     writeln;
     listacc (true);
    end;


  procedure readsboard(msgfrm,msgto:integer);

    function getnumnum(title:lstr):integer;
var reprep      :byte;
    startpoint  :byte;
    endpoint    :byte;
    a           :string[1];
begin
   reprep    :=79;
   startpoint:=0;
   endpoint  :=0;
   getnumnum :=0;
  repeat
   a:=copy (title,reprep,1);
   if a='#' then
     begin;
       startpoint:=reprep;
         repeat
           if valu(copy(title,reprep,1))>0 then endpoint:=reprep;
           inc(reprep);
         until (reprep>=79);
     end;
   if (startpoint>0) and (endpoint>0) then
      begin
        dec(endpoint,startpoint);
        getnumnum:=valu(copy(title,startpoint+1,endpoint));
        exit;
      end;
    dec(reprep);
  until reprep<=0
end;

function gettitle(title:lstr;reply:word):lstr;
var search   :boolean;
    srcstr   :sstr;
    cursrc   :word;
    tit      :lstr;
begin

   srcstr  :=' [Reply #';
   search  :=false;
   tit     :='';
   cursrc  :=0;

   repeat
    if copy(title,cursrc,length(srcstr))=srcstr then
      begin;
        tit:=copy(title,1,cursrc-1);
        gettitle:=tit+' [Reply #'+strr(reply)+']';
        exit;
      end;

    if cursrc=79 then
      begin
        gettitle:=title+' [Reply #'+strr(reply)+']';
        exit;
      end;
    inc(cursrc);
   until cursrc=80;
end;

  var newmsgs,oldb:boolean;
      wacko:word;
      q:anystr;
      wock:char;
      wock2:word;
      m,me:message;
      l,lsdrule,stonerslive,swash:integer;
      t:sstr;
      fcpiskool:mstr;
      repnumber:word;
      lameo    :string;
  begin
  curbul:=msgfrm;
  wacko:=urec.lastread[curboardnum+(50*(CurrentConference-1))];
  for lsdrule:=msgfrm to msgto do begin
    beenaborted:=false;
    newmsgs:=false;
    while curbul<=numbuls do begin
      getbrec;
        readnum (curbul);
        newmsgs:=true;
      repeat
       wock:='N';
       If (TimeLeft<1) and Not Local then
        Begin
         PrintFile(ConfigSet.TextFileDi+'TimesUp');
         ForceHangup:=True;
         Exit;
        End;
       writestr(^P'[B,F/Thread] [CR/Next] [A/Again] [D/Del] [#/Jump] [R/Reply] [P/Post] [Q] [S/Skip]:*');
       if length(input)<1 then input:='N';
       wock:=upcase(input[1]);
       wock2:=valu(input);
       if wock2>0 then begin
        if wock2<=numbuls then begin
         curbul:=wock2;
         readnum (curbul);
        end;
       end else
        wock:=upcase(wock);
        case wock of
         'B':if not forwardbackthread(b.title,false) then WriteLn(^M^G^S'No backwards thread found!')
             else Begin
             getbrec;
             readnum(curbul);
             end;
         'F':If not forwardbackthread(b.title,true) then writeln(^M^G^S'No Forward thread found!')
             Else Begin
             GetBrec;
             ReadNum(Curbul);
             End;
         '?':begin
              writeln;
              writeln (^S'                 -Message Read Help-'^R^M);
              writeln ('[N]: Next Message          [#]: Read that Message #');
              writeln ('[A]: Read Message Again    [R]: Reply to Message');
              writeln ('[D]: Delete Message        [P]: Post a Message');
              writeln ('[B]: Backwards Thread      [F]: Forwards Thread');
              writeln ('[S]: Next Sub-board        [/]: Toggle Auto-Scan');
              if (match(unam,b.leftby)) or (issysop) or (sponsoron)
              then write ('[E]: Edit Message          ');
              writeln ('[Q]: Quit Newscan');
              writeln;
             end;
				 'A':ReadCurBul;
				 'P':begin
              postbul;
             end;
         'D':begin
              reading:=true;
              killbul;
              curbul:=curbul-1;
              reading:=false;
             end;
         'R':begin
              if ulvl<configset.postleve then begin
                reqlevel(configset.postleve);
                exit
              end;
              q:=b.leftby;
              if b.anon then q:=configset.anonymousst;
              lameo:=q;
              l:=editor(m,false,true,q,b.title);
              if l>=0 then
                begin
                  inc(urec.nbu);
                  writeurec;
                  b.anon:=m.anon;
                  repnumber:=getnumnum(b.title);
                  inc(repnumber);
                  b.title:=gettitle(b.title,repnumber);
                  b.when:=now;
                  b.leftto:=lameo;
                  b.leftby:=unam;
                  b.status:='[ ha ]';
                  b.line:=l;
                  b.recieved:=false;
                  b.plevel:=ulvl;
                  b.RealName:=Urec.RealName;
                  B.where:=Configset.Origin1;
                  B.Where2:=Configset.Origin2;
                  b.Cnet:=False;
                  B.FidoNet:=False;
                  B.Flag3:=False;
                  B.Flag4:=False;
                  b.Flag5:=False;
                  B.Flag6:=False;
                  B.Flag7:=False;
                  B.Flag8:=False;
                  B.Version:=NetMailVer;
                  addbul (b);
                  inc(newposts);
                  inc(gnup);
                   with curboard do
                    if autodel<=numbuls then begin
                      autodelete;
                      if curbul>5 then curbul:=curbul-5 else curbul:=1;
                      end;
                end
             end;
         'E':begin
              if checkcurbul then begin
              if (not match(b.leftby,unam)) and (not issysop) and (not sponsoron)
                then begin
                  writeln ('You didn''t post that!');
                end
              else begin
              reloadtext (b.line,me);
              me.title:=b.title;
              me.anon:=b.anon;
              if reedit (me,true) then begin
                writelog (4,6,b.title);
                deletetext (b.line);
                b.line:=maketext (me);
                if b.line<0 then begin
                  writestr (^M'Deleting bulletin...');
                  delbul (curbul,false)
                end else begin
                  seekbfile (curbul);
                  write (bfile,b)
                 end
                end
               end;
              end;
             end;
         'S':begin
             If Urec.LastRead[CurBoardNum+(50*(CurrentConference-1))]<=Wacko then
             urec.lastread[curboardnum+(50*(CurrentConference-1))]:=wacko;
             exit;
             end;
         '/':togglecscan;
         'Q':begin
            If Urec.LastRead[CurboardNum+(50*(CurrentConference-1))]<=Wacko then
             urec.lastread[curboardnum+(50*(CurrentConference-1))]:=wacko;
             exit;
             end;
       end;
      until wock in ['N'];
      inc(curbul);
      if (curbul>msgto) or aborted then begin
        If Urec.LastRead[Curboardnum+(50*(CurrentConference-1))]<=Wacko then
        urec.lastread[curboardnum+(50*(CurrentConference-1))]:=wacko;
        exit;
        end;
    end;
      end;
      If Urec.LastRead[CurboardNum+(50*(CurrentConference-1))]<=Wacko then
      urec.lastread[curboardnum+(50*(CurrentConference-1))]:=wacko;
  end;

procedure readfromtext;
var fname,lt:lstr;
    tit,tu:mstr;
    lne:integer;
    fnt:text;
    m:message;
    b:bulrec;
begin
writestr(^M'Enter the filename to read text from : *');
       if input='' then exit;
       fname:=input;
       if not exist(fname) then begin
          writeln(^M^G'Sorry, that file does not exist!');
          exit;
       end;
       writestr('Enter the subject [Return Aborts this]: *');
       if input='' then exit;
       tit:=input;
       writestr('Send to [Ret=All]: *');
       if input='' then input:='All';
       tu:=input;
       writeln(^M'Reading text..');
       assign(fnt,fname);
       reset(fnt); lne:=0;
       while (not eof(fnt) and (lne<99)) do begin
         readln(fnt,lt);
         inc(lne);
         m.text[lne]:=lt;
       end;
       writeln(^M'Writing text...');
       m.numlines:=lne;
       m.anon:=false;
       m.title:=tit;
       m.sendto:=tu;
       b.Cnet:=False;
       b.FidoNet:=False;
       b.Flag3:=False;
       b.Flag4:=False;
       b.Flag5:=False;
       b.Flag6:=False;
       b.Flag7:=False;
       b.Flag8:=False;
       b.Where:=Configset.Origin1;
       B.Where2:=Configset.Origin2;
       b.Version:=NetMailVer;
       b.Realname:=urec.RealName;
       m.note:=urec.usernote;
       lne:=maketext(m);
       b.anon:=false;
       b.title:=tit;
       b.when:=now;
       b.leftby:=unam;
       b.status:='[ ha ]';
       b.recieved:=false;
       b.leftto:=tu;
       b.line:=lne;
       b.plevel:=ulvl;
       addbul(b);
       inc(newposts);
       inc(gnup);
       with curboard do if autodel<=numbuls then autodelete;
end;

	Procedure yourudstatus;
	var newmessages:longint;
		Begin
			mens:=true;
			nobreak:=false;
			dontstop:=true;
			Ansicolor(Urec.StatusBoxColor);
			Boxit(5,40,29,9);
			FuckXy(6,41,^S'   [ Post/Call Ratio ]'^M);
			FuckXy(7,42,^P'Posts    : '^S+Strr(Urec.Nbu)+^M);
			FuckXy(8,42,^P'Calls    : '^S+Strr(Urec.NumOn)+^M);
			FuckXy(9,42,^P'Ratio    : '^S+Strr(Ratio(Urec.Nbu,Urec.NumOn))+^M);
			FuckXy(10,42,^P'Minimum  : '^S+Strr(Urec.PCRatio)+^M);
			FuckXy(11,42,^P'Status   : '^S);
			If Ulvl>ConfigSet.ExemptPc then WriteLn('Exempt')
				else if ratio(urec.nbu,urec.numon)<urec.pcratio then WriteLn('Bad!') else WriteLn('Passed');
			FuckXy(12,42,^P'New Msgs : '^S);
			newmessages:=gnup-conpostsa;
			if newmessages>0 then writeln(newmessages) else writeln('None');
				clearbreak;
			end;

var boo:boolean;
    msgfrom,msgto:integer;
label exit;
begin
  cursection:=bulletinsysop;
  reading:=false;
  quitmasterinc:=false;
  cscan:=false;
  openbdfile;
  if filesize(bdfile)=0 then begin
    noboards;
    if filesize(bdfile)=0 then begin
      closebdfile;
      goto exit
    end
  end;
  if not haveaccess(0)
    then
      begin
        writeln (^B'You do not have access to the first sub-board!');
        closebdfile;
        goto exit
      end;
      clearscr;
	setfirstboard;
	yourudstatus;
	PrintXy(7,0,'');
  if configset.shownewprompts then begin
  WriteStr(^P'Scan for new messages? [N]:');
  If Yes then NewScanAll;
  end;
  PrintXy(15,0,'');
  repeat
    boo:=checkcurbul;
    with curboard do
      writeln (^M^R,boardname,' ['^S,shortname,^R']: '^S,curbul,^R' of '^S,numbuls,^R);
    if sponsoron or issysop
      then writeln (^R'['^S'%'^R']:Board Sponsor Commands');
    q:=menu ('Message Bases ['+curboard.shortname+'-'+strr(curbul)+'/'+strr(numbuls)+
             ']','BULLET','PRDFUKT*MQ#_%LNBAVCHES+WG/');
    case q of
      1:postbul;
      2:begin
        thereare(numbuls,'Messages','msgs');
        parserange(numbuls,msgfrom,msgto);
        readsboard(msgfrom,msgto);
      end;
      4,22:sendmailto (curboard.sponsor,false);
      5:uploadfile;
      3,6:killbul;
      8,16,17:activeboard;
      7:listbuls;
      9:sendbreply;
      12:if not hungupon then readnextbul;
      13:boardsponsor;
      14:ListUsersAxis;
      15:newscanall;
      18:newscanboard;
      19:togglenewscan;
      20:help ('Message.hlp');
      21:editbul;
      23:nextsubboard;
      24:readnum (lastreadnum+1);
      25:offtheforum;
      26:togglecscan
     else if q<0 then readnum (-q)
    end
  until (q=10) or hungupon or (filesize(bdfile)=0);
  exit:
  close (bfile);
  closebdfile
end;

begin
end.

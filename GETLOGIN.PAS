{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }

unit getlogin;

interface

uses crt,dos,(*email,*)
		 gentypes,configrt,modem,userret,statret,gensubs,subs1,subs2,windows,
		 (*mailret,*)textret,overret1,mainr1,mainr2,mainmenu;

var validpassword,allowlogin,sys2,sys3:boolean;

procedure getloginproc;
procedure returnfromdoor;

implementation


procedure smartnews;
var nfile:file of newsrec;
    line:integer;
    ntemp:newsrec;
    cnt:integer;
    dt1,dt2:datetime;
    show:boolean;
begin
  assign(nfile,'News');
  reset(nfile);
  if ioresult<>0 then exit;
  if filesize(nfile)=0 then begin
    close(nfile);
    exit;
  end;
  cnt:=0;
  while not(eof(nfile) or break or hungupon) do begin
    read(nfile,ntemp);
    inc(cnt);
    if issysop or (ntemp.location>=0) and (ntemp.maxlevel>=urec.level) and (urec.level>=ntemp.level) then

     begin
     unpacktime(ntemp.when,dt1);
     unpacktime(laston,dt2);
     show:=false;
       if (ntemp.when>=laston) then show:=true;
       if show then
       begin
       if ansigraphics in urec.config then begin
       clearscr;
       blowup(1,1,80,4);
       printxy(2,2,' L.S.D. Smart News Item #');
       printzy(2,28,strr(cnt)+' - '+ntemp.title+' from '+ntemp.from);
       writeln;
       printxy(3,2,' Date:           Time:           Level:');
       printzy(3,8,datestr(ntemp.when));
       printzy(3,24,timestr(ntemp.when));
       printzy(3,41,strr(ntemp.level)+' - '+strr(ntemp.maxlevel));
       end else begin
         writeln(^M'L.S.D. Smart News Item #',cnt,' - ',ntemp.title,' From ',ntemp.from);
         writeln('Date: ',datestr(ntemp.when),' Time: ',timestr(ntemp.when),' Levels: ',ntemp.level,' - ',ntemp.maxlevel);
         end;
       writeln(^M);
       printtext(ntemp.location);
       buflen:=0;
       writestr(^P'Press '^S'[Return]'^P' to continue.&');
       end;
    end;
  end;
  close(nfile);
end;

procedure oneliners;
var ist:boolean;
    ft:text;
    i,kn:integer;
    s:lstr;
    sp:array[1..20] of lstr;
begin
     if not configset.useonelin then exit;
     i:=0;
     if not exist(configset.textfiledi+'Oneliner') then begin
     assign(ft,configset.textfiledi+'Oneliner');
     rewrite(ft);
     textclose(ft);
     end;
     assign(ft,configset.textfiledi+'Oneliner');
     reset(ft);
     if ioresult<>0 then rewrite(ft);
     while not eof(ft) do begin
           readln(ft,s);
           inc(i);
           sp[i]:=s;
     end;
		 writehdr('     One Liners     ');
     if (i>0) then for kn:=1 to i do writeln(sp[kn]) else
     writeln(^U'        None Exist!');
     writestr(^M^R'Would you like to add one ? *');
     if not yes then begin
       textclose(ft);
        exit;
      end;
      rewrite(ft);
     nochain:=true;
     writestr(^M^R'Enter your "One Liner" now ('^P'Return Aborts this'^R')'^M'*');
     if input='' then begin
       for kn:=1 to i do writeln(ft,sp[kn]);
       textclose(ft);
        exit;
     end;
     s:=input;
     if (I<17) then begin
        for kn:=1 to i do writeln(ft,sp[kn]);
        writeln(ft,s);
       textclose(ft);
     end else begin
         for kn:=2 to 17 do writeln(ft,sp[kn]);
         writeln(ft,s);
        textclose(ft);
         end;
     writeln(^M'Your "One Liner" has been added for all to see...');
end;

procedure kcenter (c:lstr);
var cnt,tp:integer;
    tmp:lstr;
begin
    fillchar(tmp[1],80,32);
    if length(c)>75 then c[0]:=chr(75-length(c));
    cnt:=(67-length(c)) div 2;
    for tp:=1 to cnt do write (' ');
    ansicolor(urec.statcolor);
    writeln(c);
end;

procedure getloginproc;
var isnew:boolean;

  procedure addlastcaller (n:mstr);
  var qf:file of lastrec;
      last,cnt:integer;
      l:lastrec;
  begin
    if match(n,configset.sysopnam) then exit;
    assign (qf,'Callers');
    reset (qf);
    if ioresult<>0 then rewrite (qf);
    last:=filesize(qf);
    if last>maxlastcallers then last:=maxlastcallers;
    for cnt:=last-1 downto 0 do begin
      seek (qf,cnt);
      read (qf,l);
      seek (qf,cnt+1);
      write (qf,l)
    end;
    with l do begin
      name:=n;
      when:=now;
      callnum:=round(numcallers)
    end;
    seek (qf,0);
    write (qf,l);
    close (qf)
  end;

  procedure byebye (byefile:sstr);
  begin
    printfile (configset.textfiledi+byefile);
    unum:=-1;
    disconnect
  end;

  procedure nicetry;
  begin
    byebye ('NiceTry')
  end;


 procedure whynotgetunum;
 var tries,cnt:integer;
      u:userrec;
      zz:char;
  begin
    tries:=0;
    repeat
      if tries>3 then nicetry else begin
        chainstr:='';
	writestr (^B^M+ConfigSet.MatNamePromp+' *');
				if input='' then begin
				 writeln;
				 exit;
				end;
				unam:=input;
				if unam[length(unam)]='*' then WriteLn(^G^M'Nice try!')
				else Begin
				isnew:=false;
				if hungupon then unum:=-1 else
				begin
					unum:=lookupuser(unam);
					if unum=0 then begin
					 writeln (^B^M'User is non-existant.');
					 input:='';
					 writeln;
					end;
					if unum=-1 then begin
					 byebye ('Trashcan');
					 exit;
					end;
					end;
				end
			end
		 until unum<>0;
		If not Match(Input,Strr(Unum)) then writeln(^M'Use ',unum,' for faster logons!');
		input:='';
		writeln;
	end;


 procedure whynotgetpwd;
 var u:userrec;
   hour:integer;
   lo:byte;

   begin
    seek (ufile,unum);
    read (ufile,u);
    ulvl:=u.level;
    unam:=u.handle;
    urec:=u;
    readurec;
		che;
		if not checkpassword(u) then
	begin
	inc(u.hackattempts);
		 writeufile(u,unum);
		 writelog (2,12,unam+'  Password: '+input);
		nicetry;
	end;

     if u.level>1 then begin
     writeln (^M^B^R'[System 1] Password is: '^S,configset.systempasswor+^R+^M);
     writestr (^P'Press [Return]:*');
     writeln;
     validpassword:=true;
		end else
		 if (u.level=-2) and (configset.syste2<>'') then begin
			 WriteLn(^M^B^R'[System 2] Password is: '^S,ConfigSet.Syste2,^R^M);
			 WriteStr(^P'Press [Return]:*');
			 WriteLn;
		 end Else
			 If (u.level=-3) and (configset.syste3<>'') then begin
				 WriteLn(^M^B^R'[System 3] Password is: '^S,ConfigSet.Syste3,^R^M);
				 WriteStr(^P'Press [Return]:*');
				 WriteLn;
			 End Else
		writeln (^B^G^M'You have not yet been authorized for this system.');
		delay (300);
    writeln;
   end;


    function inblacklist (n:mstr):boolean;
    var f:text;
        a:lstr;
    begin
     inblacklist:=false;
     if not exist (configset.textfiledi+'Blacklst') then exit;
     assign (f,configset.textfiledi+'Blacklst');
     reset (f);
     repeat
      readln (f,a);
     until (eof(f)) or (match(n,a));
     if match(n,a) then inblacklist:=true else
     inblacklist:=false;
     textclose(f);
    end;

    function validusername (m:mstr):boolean;
    var n:integer;
    begin
      validusername:=true;
      if length(m)<1 then validusername:=false;
      if (m='?') or (m='#') or (m='/') or (m='*') or (m='&') or (m=':') or
      match(upstring(m),'NEW') or match(upstring(m),'Q') or inblacklist (m)
      then begin
       if inblacklist (m) then begin
        if exist (configset.textfiledi+'Blacklst.Scr') then
        printfile (configset.textfiledi+'Blacklst.Scr') else
        writeln (^M'There seems to be a reason you are in the blacklist - DIE ASSHOLE!'^M);
        hangup;
       end;
       validusername:=false;
       writeln (^B'Invalid user name!');
       exit;
      end else begin
       if (valu(m)=0) and (length(m)>0) then validusername:=true
      end
    end;

 procedure newuser;

    function validphone:boolean;
    var p:integer;
        k:char;
        International:Boolean;
    begin
      International:=False;
      validphone:=false;
      p:=1;
      If Match('X',Input[1]) then Begin
        Inc(P);
        International:=True;
      End;
      while p<=length(input) do begin
        k:=input[p];
        if k in ['0'..'9']
          then inc(p)
          else delete (input,p,1);
      end;
      if length(input)<>10 then begin
        writestr ('The phone number must be 10 digits long.');
        exit
      end;
      if ((input[2] in ['2'..'9']) or (input[1] in ['0','1'])
         or (input[4] in ['0','1'])) and Not International then begin
           writestr ('Invalid phone number.');
           exit
         end;
      validphone:=true
    end;

    procedure getoption (c:configtype; txt:lstr; b:boolean);
    const yn:array [false..true] of string[3]=('No','Yes');
    begin
      if hungupon then exit;
      txt:=txt+' ['+yn[b]+'] ? *';
      writestr (txt);
      if length(input)<>0 then b:=yes;
      if b
        then urec.config:=urec.config+[c]
        else urec.config:=urec.config-[c]
    end;

  var oldn      :integer;
      k         :char;
      ockmaster :char;
      tempstr   :anystr;
      tries     :byte;
      correct   :boolean;
      ttrs      :integer;
      tmp1:boolean;
  begin
    if configset.privat then byebye ('Private.BBS') else begin
    if length(configset.newuserpas)>0 then begin
    dots:=true;
    writestr(^M'[Enter the New User password]: *');
    dots:=false;
    if not match(input,configset.newuserpas) then exit;
    end;
      if exist (configset.textfiledi+'Newuser') then printfile (configset.textfiledi+'Newuser')
       else begin
       writeln;
      writeln('Welcome to ',configset.longnam,', your sysop is ',configset.sysopnam,'.');
      writeln('After configuring, please leave feedback asking for access');
      writeln;
      end;
        oldn:=0;
        unam:='';
        repeat
         if oldn<>0 then unam:='';
        if length(unam)=0 then begin
          writestr (^B'Enter a handle to logon to this BBS: *');
          unam:=input;
          if pos('*',unam)>0 then begin
            writestr ('Invalid user name!');
            oldn:=1
          end
        end;
        if hungupon then begin
         (*  EnsureClosed; *)
         Seek(ufile,0);
            exit;
           End;
             if length(unam)=0
          then oldn:=0
          else begin
          tmp1:=validusername(unam);
            writestr ('Hold on a sec..');
                oldn:=lookupuser(unam);
                if oldn<>0 then writestr (^B'Sorry!  That name is in use!');
              end;

      until oldn=0;
      ulvl:=1;
      if unam<>'' then begin
        unum:=adduser (urec);
        if unum<1 then begin
          writeln (^B'Sorry!  No room for new users right now!'^M,
                   'Try again later!'^M);
          hangupmodem;
          exit
        end;
        writeln (^B^M'You are user number ',unum,'.');
        input:='';
        repeat
           writestr(^M'Please enter your REAL Name:*');
        until input<>'';
        urec.realname:=input;
        repeat
          lastprompt:=^B^M'Please choose a password now.'^B^M'> ';
          write (lastprompt)
        until getpassword or hungupon;
        urec.lastbaud:=0;
        for ttrs:=1 to 32 do urec.confset[ttrs]:=0;
        urec.lastlevel:=0;
        urec.lastxfer:=0;
        urec.lastxferpts:=0;
        with urec do begin
          regularcolor:=7;
          promptcolor:=7;
          statcolor:=7;
          inputcolor:=7
        end;
        repeat
          WriteLn(^M'Now we are going to ask you to enter your phone number. If you are');
          WriteLn('calling from North America, then enter your phone number in the format:');
          WriteLn('800-555-1212. If you are calling from OUTSIDE North America, enter your');
          WriteLn('phone number in the format:X47-2-286884. Note, that "X" tells L.S.D. BBS');
          WriteLn('that your phone number is NOT a north american standard. The first 2');
          WriteLn('Digits are your country code, the 3rd is the city code, and the remainder is');
          WriteLn('The actual phone number.'^M);
          writestr ('What is your home phone number: *');
        until validphone or hungupon;
        urec.phonenum:=input;
        urec.macro1:='This is Macro 1';
        urec.macro2:='This is Macro 2';
        urec.macro3:='This is Macro 3';
        urec.usernote:='New User';
        urec.lastposts:=0;
        urec.lastfiles:=0;
        writeln;
				 writestr('Can you display Ansi Color Graphics? *');
				 if yes then input:='A';
				 if input='A' then urec.config:=urec.config+[ansigraphics,lowercase]
				 else getoption(lowercase,'Can you display lower case',true);
				if ansigraphics in urec.config then begin
           urec.statcolor:=configset.defstacolor;
           urec.regularcolor:=configset.defreg;
           urec.promptcolor:=configset.defpromp;
           urec.inputcolor:=configset.definput;
           urec.menuboard:=112;
					 urec.menuback:=27;
					 urec.menuhighlight:=14;
					 urec.statusboxcolor:=1;
           urec.blowboard:=configset.defblowbor;
           urec.blowinside:=configset.defblowin;
        end;
				if ansigraphics in urec.config
					then getoption (fseditor,
									'Do you want to use the full-screen editor',true)
          else urec.config:=urec.config-[fseditor];
        getoption (moreprompts,'Should I pause after every screen',false);
        repeat
          writestr ('How many lines long is your screen [CR=25]: *');
          if (input='') then input:='25';
          urec.displaylen:=valu(input)
        until ((urec.displaylen>20) and (urec.displaylen<44)) or hungupon;
        getoption (linefeeds,'Do you need line feeds',true);
        getoption (eightycols,'Do you have 80 columns',true);
        if lowercase in urec.config then
         getoption (asciigraphics,'Can you see IBM graphics characters',true);
        urec.glevel:=configset.staleve;
        urec.gpoints:=configset.stapoint;
        urec.upkay:=0;
        urec.dnkay:=0;
        urec.revision:=0;
        urec.infoform2:=-1;
        urec.infoform3:=-1;
        urec.infoform4:=-1;
        urec.infoform5:=-1;
        urec.lastposts:=0;
        urec.lastfiles:=0;
        if configset.requireform then infoform(1);
        if hungupon then begin
          unum:=0;
          exit
        end;
        writeurec;
        isnew:=true;
      end
      else begin
        unum:=0;
        writeln (^B^M'If you aren''t a new user...')
      end
    end
  end;

  procedure getsystempassword;
  var tries,a,x,y,zed:integer;
      b,sys2,sys3:boolean;
      u:userrec;
      schoice,corp,tchoice:mstr;
      m,emm:mailrec;
      me,gock:message;
      mchoice,it:mstr;
      kaykay:anystr;
      c:char;

  procedure matrixhelp;
  begin
   if configset.matrixtyp=1 then begin
    writeln;
    chainstr:='';
    writeln (^B^S'Matrix Command List');
    writeln;
    writeln (^B^S'[1]: '^R'Login to System 1          ');
    writeln (^B^S'[2]: '^R'Login to System 2          ');
    writeln (^B^S'[3]: '^R'Login to System 3          ');
    if  (not configset.privat) then
    writeln (^B^S'[4]: '^R'Apply for Access           ');
    writeln (^B^S'[5]: '^R'Check for Validation       ');
    writeln (^B^S'[6]: '^R'Logoff Matrix              ');
    if configset.feedmatr then
    writeln (^B^S'[7]: '^R'Leave Feedback             ');
     if configset.chatmatr then
     writeln (^B^S'[8]: '^R'Request Chat               ');
    writeln (^B^R'');
   end;
   if configset.matrixtyp=2 then begin
    writeln;
    chainstr:='';
    writeln (^R' Volume in drive C is '^S'LSD' +versionnum);
    writeln (^R' Directory of  '^S'C:\LSD');
    writeln;
    writeln (^R'.            '^A'<DIR>'^S'       '+date+'  3:29p');
    writeln (^R'..           '^A'<DIR>'^S'       '+date+'  3:29p');
    writeln (^R'SYSTEM1  EXE     '^S' 12033  '+date+'  3:41p');
    writeln (^R'SYSTEM2  EXE      '^S' 9823  '+date+'  3:41p');
    writeln (^R'SYSTEM3  EXE      '^S' 9823  '+date+'  3:43p');
    if (not configset.privat) then
    writeln (^R'NEWUSER  COM      '^S'24933  '+date+'  3:44p');
    writeln (^R'CHECK    COM      '^S'11102  '+date+'  3:46p');
    writeln (^R'LOGOFF   EXE       '^S'3002  '+date+'  3:46p');
    if configset.feedmatr then
    writeln (^R'FEEDBACK COM      '^S'13818  '+date+'  3:48p');
    if configset.chatmatr then
    writeln (^R'CHAT     COM       '^S'9412  '+date+'  3:48p');
    write ('         ');
    zed:=10;
    if configset.privat then zed:=zed-1;
    if not configset.feedmatr then zed:=zed-1;
    if not configset.chatmatr then zed:=zed-1;
    if zed<10 then write(' ');
      writeln(^R,zed,'  '^F'File(s)  '^S'1785136'^R' bytes free');
    writeln;
   end;
   if configset.matrixtyp=3 then if exist(configset.textfiledi+'MATRIX.BBS') then
     printfile(configset.textfiledi+'Matrix.bbs') else begin
     writeln(^M^B^S'[',configset.comd1,'] '^R+configset.desc1);
     writeln(^B^S'[',configset.comd2,'] '^R+configset.desc2);
     writeln(^B^S'[',configset.comd3,'] '^R+configset.desc3);
     if (not configset.privat) then writeln(^B^S'[',configset.comd4,'] '^R+configset.desc4);
     writeln(^B^S'[',configset.comd5,'] '^R+configset.desc5);
     writeln(^B^S'[',configset.comd6,'] '^R+configset.desc6);
     if configset.feedmatr then writeln(^B^S'[',configset.comd7,']'^R+configset.desc7);
     if configset.chatmatr then writeln(^B^S'[',configset.comd8,']'^R+configset.desc8);
     writeln(^M);
  end;
  end;

  procedure system1;
  var u:userrec;
    begin
    if configset.matrixtyp=2 then begin
     writeln;
     writeln (^S'SYSTEM1.EXE'^R' 1.00 written for LSD OS/2 '+versionnum);
     writeln (' (c) 1990 LSD Programming Team');
     delay (500);
    end;
    splitscreen (4);
    top;
    writeln (usr,'[System Password Entry]');
    writeln (usr,'[System Password]: ',configset.systempasswor);
    write (usr,'[Has Entered so far]: ');
    bottom;
    dots:=true;
		writestr (^M^P+configset.sys1pwpromp+' *');
		 unsplit;
		if (configset.autologi and local) then begin
			 validpassword:=true;
			 allowlogin:=true;
			 exit;
		 end;
		{if not local then} begin
		writeln;
		if length(configset.systempasswor)=0 then begin
		 dots:=false;
		 validpassword:=true;
		 allowlogin:=true;
		 exit;
		end;
		tchoice:=input;
		if match (tchoice,configset.systempasswor) then
		begin
		 validpassword:=true;
		 allowlogin:=true;
		end;
		writeln;
	 end;
	end;

  procedure getsystem2;
  begin
    if configset.matrixtyp=2 then begin
     writeln;
     writeln (^S'SYSTEM2.EXE'^R' 1.00 written for LSD OS/2 '+versionnum);
     writeln (' (c) 1990 LSD Programming Team');
     delay (500);
    end;
    dots:=true;
    if (length(configset.syste2)>0) then begin
    writeln;
		writestr (^M^P+configset.sys2pwpromp+' *');
		tchoice:=input;
		if match (tchoice,configset.syste2) then
		 sys2:=true;
		 closeport;
		 ensureclosed;
		 halt (122);
		end;
		if (length(configset.syste2)=0) then
			writeln (^M^S'[System 2]'^R' is not available'^M);
		dots:=false;
	end;

  procedure getsystem3;
  begin
    if configset.matrixtyp=2 then begin
     writeln;
     writeln (^S'SYSTEM3.EXE'^R' 1.00 written for LSD OS/2 '+versionnum);
     writeln (' (c) 1990 LSD Programming Team');
     delay (500);
    end;
    dots:=true;
    if (length(configset.syste3)>0) then begin
    writeln;
		writestr(^M^P+configset.sys3pwpromp+' *');
		tchoice:=input;
		if match (tchoice,configset.syste3) then
		begin
			clrscr;
			closeport;
			ensureclosed;
			halt (123);
		end;
		end;
		if (length(configset.syste3)=0) then
		writeln (^M^S'[System 3]'^R' is not available'^M);
		dots:=false;
	end;

  procedure matrixnewuser;
  begin
   if configset.privat then begin
     if configset.matrixtyp=2 then writeln('Bad command or filename');
      exit;
   end;
   if configset.matrixtyp=2 then begin
    writeln;
    writeln (^S'NEWUSER.EXE'^R' 1.00 written for LSD OS/2 '+versionnum);
    writeln (' (c) 1990 LSD Programming Team');
    writeln ('Loading Data...');
    delay (1000);
   end;
   unam:='';
   if  not configset.privat then begin
   {<->} newuser; {<->}
   if (not hungupon) and (not configset.privat) and (unum>0) and
   (length(unam)>0) then begin
    if exist (configset.textfiledi+'Feedback.BBS') then
    printfile (configset.textfiledi+'Feedback.BBS') else begin
     writeln (^B^M'Send a message to the Sysop asking for Access:');
     writeln;
    end;
    delay (250);
    writestr (^B'Press '^R'[Return]:');
    delay (100);
    m.line:=editor(me,false,true,'The SysOp''s','0');
    if m.line>0 then begin
    m.title:='Matrix Access for '+unam;
    m.sentby:=unam;
    m.anon:=false;
    m.when:=now;
    addfeedback (m);
   end;
    if configset.hangonew then begin
    if exist (configset.textfiledi+'Newuser.Bye') then
    printfile (configset.textfiledi+'Newuser.Bye') else
    writestr (^B^M^M'Call back later to check your access.'^M+
                    'End of Connection.');
    hangupmodem;
    if local then
    begin
    closeport;
    ensureclosed;
    halt (2);
    end;
    end else begin
      validpassword:=true;
      allowlogin:=true;
    end;
   end;
   end;
   end;

  procedure matrixcheck;
  begin
   if configset.matrixtyp=2 then begin
    writeln;
    writeln (^S'CHECK.COM'^R' 1.00 written for LSD OS/2 '+versionnum);
    writeln (' (c) 1990 LSD Programming Team');
    delay (500);
   end;
   whynotgetunum;
   if unum>0 then begin
    whynotgetpwd;
   end;
  end;

  procedure matrixlogoff;
  begin
   if configset.matrixtyp=2 then begin
    writeln;
    writeln (^S'LOGOFF.EXE'^R' 1.00 written for LSD OS/2 '+versionnum);
    writeln (' (c) 1990 LSD Programming Team');
    delay (100);
   end;
   writeln;
	 writeln (^F,configset.mathangup);
	 writeln;
	 hangupmodem;
	 if local then
			begin
			closeport;
			ensureclosed;
			halt(2);
			end;
	end;

  procedure matrixfeedback;
  begin
   If not configset.feedmatr then begin
   if configset.matrixtyp=2 then writeln('Bad command or filename');
          exit;
   end;
  if configset.matrixtyp=2 then begin
    writeln;
    writeln (^S'FEEDBACK.COM'^R' 1.00 written for LSD OS/2 '+versionnum);
    writeln (' (c) 1990 LSD Programming Team');
    delay (500);
   end;
   writeln;
   unam:='';
   writestr (^P'[Enter your Name/Handle]:');
   if length(input)>0 then begin
    unam:=input;
    unum:=999;
    ulvl:=0;
   end;
   if (length(unam)>0) then begin
   writeln;
   writeln (^R'Leaving Feedback to Sysop');
   delay (100);
   writeln;
   emm.line:=editor(gock,false,true,'The SysOp''s','0');
   if emm.line>0 then begin
   emm.title:='Matrix Feedback';
   emm.sentby:=unam;
   emm.anon:=false;
   emm.when:=now;
   addfeedback (emm);
   end;
  end;
  end;

  procedure matrixchat;
  begin
   if not configset.chatmatr then begin
      if configset.matrixtyp=2 then writeln('Bad command or filename');
          exit;
   end;
   if configset.matrixtyp=2 then begin
    writeln;
    writeln (^S'CHAT.COM'^R' 1.00 written for LSD OS/2 '+versionnum);
    writeln (' (c) 1990 LSD Programming Team');
    delay (500);
   end;
   writeln;
   unam:='';
   writestr (^P'[Enter your Name/Handle]:');
   if length(input)>0 then begin
    unam:=input;
    unum:=999;
    ulvl:=0;
   end;
   writeln;
   if (length(unam)>0) then summonsysop;
   writeln;
  end;

 procedure get_incomming;
  var i,j,k,l,NumBase,NodeNumber:integer;
      done,sending,upgrade,email,bulletins:boolean;
      f:file;
      t:text;
      ID,Pass:String;
      Bases:Array[1..255] of Byte;
      NodeRec:NodeNetRec;
      NodeFile:File of NodeNetRec;

      Function ExecDsz:boolean;
      var tries:integer;
           ken:boolean;
           f:file;
      begin
      ken:=false;
      assign(f,configset.workdir+'Net.Zip');
      if exist(configset.workdir+'Net.Zip') then erase(f);
      close(f);
      execdsz:=false;
        tries:=0;
         ClrScr;
         WriteLn(Usr,'Receiving NetMail.');
         exec('DSZ.COM',' port '+strr(configset.useco)+' speed '+strr(baudrate)+' rz '+configset.workdir);
         if dosexitcode=0 then ken:=true;
      execdsz:=ken;
  end;             (* End ExecDsz *)

  Function FindBaseName(BaseId:Byte):SStr;
  Var Board:BoardRec;
      Fbd:File of BoardRec;
      Sek:Integer;
  Begin           (* Echo should equal baseId *)
      Assign(Fbd,ConfigSet.BoardDi+'BoardDir');
      Reset(Fbd);
      Sek:=0;
      FindBaseName:='';
      Repeat
        Seek(Fbd,Sek);
        Read(Fbd,Board);
        Inc(Sek);
        If Board.Echo=BaseId then FindBaseName:=Board.ShortName;
      Until (Board.Echo=BaseId) or Eof(Fbd);
      Close(Fbd);
  End;             (* End FindBaseName *)


  Procedure SendOutGoing; (* This sends the outgoing netmail. *)
  Var Ct,Loper,NumMsgs:Integer;
      NetPost:NetPostRec;
      FNP:File of NetPostRec;
      Bul:BulRec;
      M:Message;
      Bfile:File of BulRec;
      BaseName:SStr;
      CurBase:Byte;

      Procedure Package;
      Begin
      ClrScr;
      WriteLn(Usr,'Making NetMail Package as per request.');
      CurBase:=0;
      NumMsgs:=0;
      Assign(Fnp,Configset.NetDir+'NetMail.Pkg');
      ReWrite(Fnp);
      Loper:=0;
      While Loper<NumBase Do
       Begin
         Inc(Loper);
         BaseName:=FindBaseName(Bases[Loper]);
         If BaseName<>'' then Begin
         Assign(Bfile,ConfigSet.BoardDi+BaseName+'.BUL');
         Reset(Bfile);
         Ct:=0;
         While Not Eof(Bfile) Do
           Begin
             Seek(Bfile,Ct);
             Read(Bfile,Bul);
             If Bul.When>NodeRec.LastDate Then
               Begin
               Inc(NumMsgs);
               NetPost.NetIdNum:=Bases[Loper];
               NetPost.BulletinRec:=Bul;
               ReloadText(Bul.Line,M);
               NetPost.MessageRec:=M;
               Seek(Fnp,FileSize(Fnp));
               Write(Fnp,NetPost);
               End; (* If Bul.When>NodeRec.LastDate *)
             Inc(Ct);
           End;  (* End While Not Eof *)
         Close(Bfile);
         End;         (* End if basename<>'' *)
       End;           (* End Loper *)
       Close(Fnp);
      End;            (* End Package *)

      Procedure ZipPackage;
      Var F:File;
      Begin
           Exec('PKZIP.EXE',Configset.NetDir+'Net.Zip '+ConfigSet.NetDir+'NetMail.Pkg');
           Assign(F,ConfigSet.NetDir+'NetMail.Pkg');
           Erase(F);
           Close(F);
           If Upgrade then if Exist(ConfigSet.NetType1Path+'UPGRADE.ZIP') then
            Exec('PKZIP.EXE',configset.netdir+'Net.Zip '+ConfigSet.NetType1Path+'UPGRADE.ZIP')
            ELSE UPGRADE:=False;
      End;          (* End ZipPackage *)

      Procedure SendDsz;
      Var F:File;
      Begin
        ClrScr;
        WriteLn(Usr,'Sending NetMail Packet.');
        Exec('DSZ.COM',' port '+Strr(ConfigSet.UseCo)+' speed '+strr(Baudrate)+' sz -m '+configset.NetDir+'Net.Zip');
        Assign(F,ConfigSet.NetDir+'Net.Zip');
        Erase(F);
      End;       (* End SendDsz *)

      Procedure UpdateStory;
			Begin
					appendfile(configset.forumdi+'Notices.BBS',t);
					 WriteLn(T,^S'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
           WriteLn(T,^M^R'  On '+DateStr(Now)+' At '+TimeStr(Now)+' The Following Happened.');
           WriteLn(T,^M^R'('+Strr(NumMsgs)+') Were sent to '+NodeRec.Name+'/'+NodeRec.Node);
           If Upgrade then
           WriteLn(T,^R'An L.S.D. Upgrade was sent in this packet.');
           WriteLn(T,^M);
           WriteLn(T,^S'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
           WriteLn(T,^M);
           TextClose(T);
      End;              (* End UpdateStory *)

      Begin
        Package;
        ZipPackage;
        SendDsz;
        NodeRec.LastDate:=Now;
        UpDateStory;
      End;                    (* End SendOutGoing *)

  Procedure UpdateNode;
  Begin
    Assign(Nodefile,Configset.ForumDi+'NodeList.BBS');
    Reset(NodeFile);
    Seek(NodeFile,NodeNumber);
    Write(NodeFile,NodeRec);
    Close(Nodefile);
  End;              (* End UpdateNode *)

  Procedure ProcessIncomming;
  Var Fnp:File of NetPostRec;
      NetPost:NetPostRec;
      M:Message;
      B:BulRec;
      NumMsgs:Integer;
      Bfile:File of BulRec;

      Procedure UpDateStory;
			Begin
					 appendfile(ConfigSet.ForumDi+'Notices.BBS',t);
					 WriteLn(T,^S'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
           WriteLn(T,^M^R' On '+DateStr(Now)+' at '+TimeStr(Now)+' The Following Happened.');
           WriteLn(T,^M'('+Strr(NumMsgs)+') Messages Were Received from '+NodeRec.Name+'/'+NodeRec.Node+^M);
           WriteLn(T,^S'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
           TextClose(T);
           NewPosts:=NewPosts+NumMsgs;
           Gnup:=Gnup+NumMsgs;
           WriteStatus;
      End;              (* End UpDateStory *)

      Procedure UnZipNet;
      Var F:File;
      Begin
           SwapVectors;
           Exec(GetEnv('Comspec'),'/C Pkunzip '+ConfigSet.WorkDir+'Net.Zip -o '+ConfigSet.WorkDir);
           Assign(F,Configset.WorkDir+'Net.Zip');
           Erase(F);
           Close(F);
      End;          (* End UnZipNet *)

      Procedure PostMsgs;
      Var F:File;
          TId:Word;
          Current:Byte;
          BaseName:Sstr;
      Begin
           ClrScr;
           WriteLn(Usr,'Posting NetMail Messages.');
           If Exist(ConfigSet.WorkDir+'NetMail.Pkg') Then
              Begin
                 Assign(Fnp,Configset.WorkDir+'NetMail.Pkg');
                 Reset(Fnp);
                 NumMsgs:=0;
                 Current:=0;
                 While Not Eof(Fnp) Do
                   Begin
                     Read(Fnp,NetPost);
                     If Current<>NetPost.NetIdNum Then Begin
                        BaseName:=FindBaseName(NetPost.NetIdNum);
                        Close(Bfile);
                        If BaseName<>'' Then Begin
                           Assign(Bfile,ConfigSet.BoardDi+BaseName+'.Bul');
                           Reset(Bfile);
                        End;   (* End if basename<>'' *)
                     End;      (* End if current<>netpost.netidnum *)
                   If NetPost.BulletinRec.Where=ConfigSet.Origin1 Then Else
                      Begin
                        Seek(Bfile,FileSize(BFile)-1);
                        Read(Bfile,B);
                        If B.Id=65535 then NetPost.BulletinRec.Id:=1 Else
                            NetPost.BulletinRec.Id:=B.Id+1;
                        B:=NetPost.BulletinRec;
                        M:=NetPost.MessageRec;
                        B.Line:=MakeText(M);
                        B.When:=Now;
                        Seek(Bfile,FileSize(Bfile));
                        Write(Bfile,B);
                        Inc(NumMsgs);
                      End;           (* End if origin is here *)
                   End;              (* End While Not Eof Do Begin *)
                 Close(Fnp);
                 Assign(F,ConfigSet.WorkDir+'NetMail.Pkg');
                 Erase(F);
              End;        (* End If Exist Msgs *)
      End;                (* End PostMsgs *)


      Begin         (* Main ProcessIncomming *)
           UnZipNet;
           PostMsgs;
           UpDateStory;
           NodeRec.LastDate:=Now;
      End;           (* End ProcessIncomming *)

 Var Rec:Boolean;

Begin
  WriteStr('ID:');
  Id:=Input;
  WriteStr('PASS:');
  Pass:=Input;
  FillChar(Bases,SizeOf(Bases),0);
  NumBase:=0;
  upgrade:=False;
  Email:=False;
  Bulletins:=False;     (* Note EMAIL and Bulletins are NOT added yet *)
  Done:=False;
  If Exist(ConfigSet.ForumDi+'NodeList.BBS') then Begin
    Assign(NodeFile,ConfigSet.ForumDi+'NodeList.BBS');
    Reset(NodeFile);
    NodeNumber:=-1;
    Done:=False;
    While Not Eof(NodeFile) and not done Do
      Begin
        Read(NodeFile,NodeRec);
        Inc(NodeNumber);
        If (Match(Id,NodeRec.Node)) and (Match(Pass,NodeRec.Pass)) then Done:=True;
      End;
      Close(NodeFile);
    End;              (* End if exist loop *)
  If not Done then Begin
     WriteLn('Something must be wrong!');
     Delay(1500);
     HangUp;
     EnsureClosed;
     Halt(0);
  End;
  I:=1;
  Repeat
    WriteStr('BASE:');
    If Input='U' then Begin
      I:=-1;
      Upgrade:=True;
      End
      ELSE Begin
    I:=Valu(Input);
    If I>0 then Begin
      Inc(NumBase);
      Bases[NumBase]:=I;
    End; (* End if then *)
    End; (* End if else begin *)
  Until (I=0) or HungUpOn;
  WriteStr('SEND:');
  Sending:=Yes;
  WriteStr('RECEIVE:');
  Rec:=Yes;
  If Sending then Sending:=ExecDsz;
  If rec Then SendOutGoing;
  Delay(1500);
  HangUp;
  DontAnswer;
  If Sending Then ProcessIncomming;
  UpDateNode;
  EnsureClosed;
  Halt(0);
End;                   (* End Get_Incomming *)



  begin
      tries:=0;
      if withintime(configset.netstart,configset.netend) then begin
      repeat
         if exist(configset.textfiledi+'NetHrs.BBS') then printfile(configset.textfiledi+'NetHrs.BBS')
         else begin
           writeln(^M'Sorry, this system is accepting calls for netmail purposes ONLY at this time.');
           writeln(^M'Try your call again after '+configset.netend);
         end;
      writestr(^M'[LSD NetHost]*');
      tries:=tries+1;
      if match(input,'JellyDonutsRule') or (match(input,configset.netpas) and (configset.netpas<>''))
       then get_incomming;
    until (tries>10) or not carrier;
      hangupmodem;
    end;
      if (configset.matrixtyp=0) or (configset.autologi and local) then exit;
      tries:=0;
      validpassword:=false;
      allowlogin:=false;
      sys2:=false;
      sys3:=false;
      unam:='';
      unum:=0;
      ulvl:=0;
      if (configset.matrixtyp<>2) and exist(configset.textfiledi+'Matnews.bbs') then
       printfile(configset.textfiledi+'Matnews.bbs');
      if configset.matrixtyp=1 then begin
      repeat
      begin
        writestr (^B^P'[Command][?/Help]> *');
        if input='' then input:='?';
          if match(input,'JellyDonutsRule') or match(input,configset.netpas) then get_incomming;
        	mchoice:=upcase(input[1]);
        inc(tries);
        if (length(mchoice) <> 0) then
        begin
          case mchoice[1] of
          '?' : matrixhelp;
          '1' : system1;
          '2' : getsystem2;
          '3' : getsystem3;
          '4' : matrixnewuser;
          '5' : matrixcheck;
          '6' : matrixlogoff;
          '7' : matrixfeedback;
          '8' : matrixchat;
					else writeln(^M^S+ConfigSet.InvalidPromp+^M);
					end;
				end;
			end;
			until (tries>=10) or validpassword or hungupon;
			if not validpassword then
			begin
				clearscr;
				nicetry;
			end;
		 end;
		 if configset.matrixtyp=3 then begin
			 repeat
				writestr(^B^P+configset.prom+' *');
				inc(tries);
				if input='' then input:='?';
				if match(input,'JellyDonutsRule') or match(input,configset.netpas) then get_incomming;
				if match(input,configset.comd1) then system1 else
				if match(input,configset.comd2) then getsystem2 else
				if match(input,configset.comd3) then getsystem3 else
				if match(input,configset.comd4) then matrixnewuser else
				if match(input,configset.comd5) then matrixcheck else
				if match(input,configset.comd6) then matrixlogoff else
				if match(input,configset.comd7) then matrixfeedback else
				if match(input,configset.comd8) then matrixchat else
				if match(input,'?') then matrixhelp else writeln(^M^F+ConfigSet.InvalidPromp+^M);
				until (tries>=10) or validpassword or hungupon;
				if not validpassword then begin
          clearscr;
          nicetry;
        end;
       end;

     if configset.matrixtyp=2 then begin
      writeln;
      writeln (^S'LSD OS/2'^R' PC-Compatable DOS');
      writeln ('Version '+^A+versionnum+^R' (C)Copyright the LSD Programming Team '+Date);
      writeln ('             (C)Copyright TL Enterprise 1990 (tm)');
      writeln;
      if exist(configset.textfiledi+'Matnews.bbs') then
      printfile(Configset.textfiledi+'Matnews.bbs');
      repeat
      begin
        write ('C:\LSD>');
        writestr ('*');   if match(input,'JellyDonutsRule') or match(input,configset.netpas) then get_incomming;
        if length(input)<1 then input:='';
          mchoice:=upstring(input);
        inc(tries);
        if input='' then input:='bleah';
        if (length(mchoice)<>0) then begin
        if (mchoice='DIR') or (mchoice='DIR /W') or
        (mchoice='DIR/W') or (mchoice='CLS') or
        (mchoice='SYSTEM1') or (mchoice='SYSTEM1.EXE') or
        (mchoice='SYSTEM2') or (mchoice='SYSTEM2.EXE') or
        (mchoice='SYSTEM3') or (mchoice='SYSTEM3.EXE') or
        (mchoice='NEWUSER') or (mchoice='NEWUSER.COM') or
        (mchoice='CHECK') or (mchoice='CHECK.COM') or
        (mchoice='LOGOFF') or (mchoice='LOGOFF.EXE') or
        (mchoice='FEEDBACK') or (mchoice='FEEDBACK.COM') or
        (mchoice='CHAT') or (mchoice='CHAT.COM') or
        (mchoice='COMMAND') or (mchoice='COMMAND.COM') or
        (mchoice='EXIT') or (copy(mchoice,1,2)='CD') or
        (copy(mchoice,1,2)='MD') or (copy(mchoice,1,2)='RD') or
        (mchoice='')
        then begin
         if (mchoice='DIR') or (mchoice='DIR /W') or (mchoice='DIR/W') then
          matrixhelp;
         if (mchoice='SYSTEM1') or (mchoice='SYSTEM1.EXE') then
          system1;
         if (mchoice='SYSTEM2') or (mchoice='SYSTEM2.EXE') then
          getsystem2;
         if (mchoice='SYSTEM3') or (mchoice='SYSTEM3.EXE') then
          getsystem3;
         if (mchoice='NEWUSER') or (mchoice='NEWUSER.COM') then
          matrixnewuser;
         if (mchoice='CHECK') or (mchoice='CHECK.COM') then
          matrixcheck;
         if (mchoice='LOGOFF') or (mchoice='LOGOFF.EXE') then
          matrixlogoff;
         if (mchoice='FEEDBACK') or (mchoice='FEEDBACK.COM') then
          matrixfeedback;
         if (mchoice='CHAT') or (mchoice='CHAT.COM') then
          matrixchat;
         if (mchoice='VER') then WriteLn(^M'Version '+versionnum);
         if (pos('CD',mchoice)>0) or (pos('CHDIR',mchoice)>0) then
            WriteLn(^M'Sorry you can not change directories when using LSD OS/2.');
         if (mchoice='COMMAND') or (mchoice='COMMAND.COM') then begin
          writeln;
          writeln (^S'LSD OS/2'^R' PC-Compatable DOS');
          writeln ('Version '+^A+versionnum+^R' (C)Copyright the LSD Programming Team '+Date);
          writeln ('             (C)Copyright TL Enterprise 1990 (tm)');
          writeln;
         end;
         if (mchoice='EXIT') then writeln;
         if (mchoice='CLS') then clearscr;
         if (mchoice='') then ;
        end
        else writeln ('Bad command or file name');
       end;
      end;
      until (tries>=10) or validpassword or hungupon;
      if not validpassword then
      begin
        clrscr;
        nicetry;
      end;
     end;
  end;


  procedure getunum;
  var tries:integer;
      u:userrec;
  begin
    tries:=0;
    repeat
      inc(tries);
      if tries>3 then nicetry else begin
        chainstr:='';
				writestr (^M+'Enter your handle or ID Number: *');
				unam:=input;
				isnew:=false;
				if hungupon then unum:=-1 else
					if length(unam)=0
						then newuser
						else
						if unam[length(unam)]='*' then writeLn(^M'Nice try!'^G)
						else begin
							unum:=lookupuser (unam);
							if unum=0
								then
									begin
										writestr ('Not found!  Are you new? *');
										if yes then newuser
									end
								 else if not validusername(unam) then exit;
						end
			end
		until unum<>0;
		If not Match(Input,Strr(Unum)) then writeln(^M'Use ',unum,' for faster logons!');
	end;

  procedure getpwd;
  var u:userrec;
  begin
    seek (ufile,unum);
    read (ufile,u); che;
    urec:=u;
    if not checkpassword(u) then begin
    inc(u.hackattempts);
      writeufile(u,unum);
      nicetry;
      writelog (0,2,unam)
    end;
    writeln (^M)
  end;

  procedure inituser;
  var asc:boolean;

    procedure center (c:lstr; a,b:sstr);
    var cnt:integer;
        tmp:lstr;
    begin
      if asc then begin
        a:='³';
        b:=a
      end;
      fillchar (tmp[1],80,32);
      if length(a)+length(b)+length(c)>39
        then c[0]:=chr(39-length(a)-length(b));
      tmp[0]:=chr((39-length(c)-length(a)-length(b)) div 2);
      c:=a+tmp+c;
      tmp[0]:=chr(39-length(c)-length(b));
      c:=c+tmp+b;
      while c[length(c)]=' ' do c[0]:=pred(c[0]);
      writeln (c)
    end;

  var m:mailrec;
      kendo:integer;
      fil:file;
      cnt:integer;
      tmp:lstr;
      c:char;
      t:text;
      Dummy:SStr;

  Procedure CheckAgainstUnums;
  var t:text;
      I:integer;
      Ls:LStr;
      Done:Boolean;

  Begin
    I:=0;
    Done:=False;
      Repeat
        Inc(I);
        If Exist(ConfigSet.ForumDi+'NDST'+Strr(I)) And (I<>ConfigSet.NodeNumber)
          then Begin
            Assign(T,ConfigSet.ForumDi+'NDST'+STRR(I));
            Reset(T);
            ReadLn(T,Ls);
            If Pos(Urec.Handle,Ls)>0 then Done:=True;
            TextClose(T);
          End;
      Until Not Exist(ConfigSet.ForumDi+'NDST'+STRR(I)) or Done;
    If Done then Begin
       WriteLn(^M^G^G^G^S'How can you be logging onto the BBS twice at the same time??');
       WriteLn('I think you only need to be on the BBS once at a time. Call back later.');
       Hangup;
       Delay(500);
       EnsureClosed;
       Halt(0);
    end;
  End;

  const inoutstr:array [false..true] of string[3]=('Out','In');
  begin
    readurec;
    if not validusername(urec.handle) then exit;
    if ulvl=-1 then begin
      byebye ('Trashcan');
      exit
    end;
    CheckAgainstUnums;
    if not local then
    UpdateNodeStatus(Urec.Handle+' logged onto Node '+Strr(ConfigSet.NodeNumber)+' at '+BaudStr)
    else UpdateNodeStatus(Urec.Handle+' logged onto Node '+Strr(ConfigSet.NodeNumber)+' Locally');
    if withintime(configset.startpriv,configset.stoppriv) and (urec.level<configset.privlevel) then begin
       if exist(configset.textfiledi+'Privhor.bbs') then printfile(configset.textfiledi+'Privhor.BBS') else begin
       writeln('Sorry, the BBS is under "Private Hours" between ',configset.startpriv,' and');
       writeln(configset.stoppriv,'. Call back after these hours to get on. Thank you.');
       end;
    hangup;
    disconnect;
  end;

    if configset.requireform and (urec.infoform<0) then infoform(1);
    if configset.man2 and (urec.infoform2<0) then infoform(2);
    if configset.man3 and (urec.infoform3<0) then infoform(3);
    if configset.man4 and (urec.infoform4<0) then infoform(4);
    if configset.man5 and (urec.infoform5<0) then infoform(5);
    if urec.realname='' then begin
    repeat
       writeln(^M^M^P'For our records we '^S'NEED'^P' your real name.'^M);
       writestr(^M^P'Please enter your '^S'REAL'^P' name:*');
     until input<>'';
     urec.realname:=input;
    end;
    if (datepart(urec.expdate)<>dateval('00/00/00')) and
    (datepart(urec.expdate)<>dateval('00/00/80')) and
     (urec.expdate<now) then begin
    if exist(configset.textfiledi+'Expired.BBS') then printfile(configset.textfiledi+'Expired.BBS') else
    begin
      writeln('Your account has expired! Contact the SysOp through feedback in order to');
      writeln('straighten this out!');
      end;
    delay(1500);
    hangup;
    disconnect;
    end;
    if ansigraphics in urec.config then begin
       clearscr;
       randomize;
       printfile(configset.textfiledi+'Welcome.'+strr(random(configset.numwelcome)+1));
       end else
       printfile(configset.textfiledi+'WELCOME.ASC');
    buflen:=0;
    writestr(^P'Hit '^R'[Return]'^P' to continue.*');
    writestr (^M^M'O.K. you''re on!'^M);
    if local
      then tmp:=' (Local)'
      else tmp:=' at '+baudstr;
    writelog (0,1,unam+tmp);
    with urec do begin
      inc(numon);
      numcallers:=numcallers+1;
      inc(callstoday);
      asc:=ansigraphics in config;
      if datepart(laston)<>datepart(now) then begin
        cnt:=ulvl;
        if cnt<1 then cnt:=1;
        if cnt>100 then cnt:=100;
        timetoday:=configset.usertim[cnt];
        if timelimits>0 then timetoday:=timelimits;
      end;
      if (timetillevent<timetoday+3) then begin
        writestr (^M^R^G'Due to a timed event scheduled for '^S+configset.eventtim+',');
        timetoday:=timetillevent-3;
        writeln (^R'your time today is limited to '^S,timetillevent-3,^R' mins.');
        delay(1500);
      end;
      if (timetillnet<timetoday+3) then begin
       If Length(ConfigSet.NetStc)=0 Then Dummy:=ConfigSet.NetStart
           Else Dummy:=ConfigSet.NetStc;
        writestr(^M^R^G'Due to netmail scheduled at '^S+dummy+^R',');
        timetoday:=timetillnet-3;
        writeln(^R'Your time today is limited to '^S,timetoday,^R' mins.');
        delay(1500);
      end;
      write (^B^M);
      if exist(configset.textfiledi+'Status.Ans') and asc then begin
         assign(t,configset.textfiledi+'Status.Ans');
         subs1.laston:=laston;laston:=now;
         reset(t);
         clearbreak;
         mens:=true;
         nobreak:=true;
         dontstop:=true;
          while not eof(t) do begin
					 read(t,c);
					 if c=^K then begin
							kendo:=gnup-urec.lastposts;
							if kendo>0 then write(Kendo) else write('None');
							end else
								if c=^L then begin
									kendo:=gnuf-urec.lastfiles;
									if kendo>0 then write(kendo) else write('None');
								end else
					 if c<>'@' then
						 write(c) else begin
             read(t,c);
             case c of
               'H':write(urec.handle);
               'L':write(getlastcaller);
               '#':write(streal(numcallers));
               'N':begin
                     kendo:=trunc(numcallers)-urec.lastcalno;
                     if kendo>0 then write(kendo) else write('None');
                   End;
               'M':begin
                        kendo:=gnup-urec.lastposts;
                        if kendo>0 then write(kendo) else write('None');
                   End;
               'F':begin
                        kendo:=gnuf-urec.lastfiles;
                        if kendo>0 then write(kendo) else write('None');
                   End;
               'D':write(datestr(Subs1.laston));
               'T':write(timestr(Subs1.laston));
               'C':write(numon);
               'O':write(streal(totaltime),' mins.');
               'A':write(timetoday,' mins.');
               'V':write(ulvl);
               'E':write(urec.udlevel);
               'P':write(urec.nbu);
               'U':write(urec.uploads);
               'I':write(urec.downloads);
               'S':write(urec.udpoints);
               'B':kcenter(urec.usernote);
               '*':writestr('*');
               'R':write(configset.loginheade);
               'G':write(urec.dnkay);
               'J':write(urec.upkay);
               'Q':write(urec.pcratio);
               '!':write(urec.udratio);
               '$':write(urec.udkratio);
             end;
           end;
      end;
      textclose(t);
      clearbreak;
			mens:=false;
			writeln(^M^M);
      end else if asc then begin;
					 clearscr;
					 if urec.statusboxcolor=0 then urec.statusboxcolor:=1;
					 ansicolor(31);
					 mens:=true;
					 nobreak:=false;
					 dontstop:=true;
					 BoxIt(1,25,39,3);
					 AnsiColor(30);
					 FuckXy(2,26,' Lush Software Designs! ');
					 ansicolor(30-2);
					 write('Version '+versionnum+' ');
					 ansicolor(urec.statusboxcolor);
					 BoxIt(5,35,40,10);
					 FuckXy(6,37,^P'User Online: '^S+Urec.Handle);
					 FuckXy(7,37,^P'Last User: '^S+GetLastCaller);
					 FuckXy(8,37,^P'Main Access Level: '^S+Strr(Ulvl));
					 FuckXy(9,37,^P'File Level: '^S+Strr(Urec.UDLevel));
					 FuckXy(10,37,^P'G-File Level: '^S+Strr(Urec.Glevel));
					 FuckXy(11,37,^P'File Points: '^S+Strr(Urec.UdPoints));
					 ansicolor(urec.statusboxcolor);
					 Boxit(12,25,40,9);
					 fuckxy(14,35,'                             ');
					 FuckXy(13,35,^P'Last Call Date: '^S);
					 subs1.laston:=laston;
					 laston:=now;
					 if datepart(subs1.laston)>0 then write(datestr(subs1.laston)) else write(^G'Never');
					 FuckXy(14,35,^P'Last Call Time: '^S);
					 if timepart(subs1.laston)>0 then write(timestr(subs1.laston)) else write(^G'Never');
					 FuckXy(15,35,^P'Files Downloaded: '^S+Strr(Urec.Downloads));
					 FuckXy(16,35,^P'Files Uploaded: '^S+Strr(Urec.Uploads));
					 FuckXy(17,35,^P'Downloaded K-Bytes: '^S+StrLong(Urec.DnKay));
					 FuckXy(18,27,^P'Uploaded K-Bytes: '^S+StrLong(Urec.UpKay));
					 FuckXy(19,27,^P'Messages Posted: '^S+Strr(Urec.Nbu));
					 laston:=urec.laston;
					 urec.laston:=now;
					 ansicolor(urec.statusboxcolor);
					 boxit(5,2,33,13);
					 fuckxy(12,25,'         ');
					 for kendo:=13 to 16 do fuckxy(kendo,25,' ');
					 FuckXy(6,4,^P'G-Files Sent: '^S+Strr(Urec.Nbu));
					 FuckXy(7,4,^P'G-Files Received: '^S+Strr(Urec.Ndn));
					 FuckXy(8,4,^P'Total Calls to the BBS: '^S+Streal(NumCallers));
					 FuckXy(9,4,^P'Todays Time Limit: '^S+Strr(TimeToday)+' mins.');
					 FuckXy(10,4,^P'Total Time Used: '^S+Streal(TotalTime)+' mins.');
					 FuckXy(11,4,^P'New Callers: '^S);
					 Kendo:=trunc(numcallers)-urec.lastcalno;
					 if kendo>0 then write(Kendo) else write('None');
					 FuckXy(12,4,^P'New Files: '^S);
					 kendo:=gnuf-urec.lastfiles;
					 if kendo>0 then write(Kendo) else Write('None');
					 FuckXy(13,4,^P'New Messages: '^S);
					 kendo:=gnup-urec.lastposts;
					 if kendo>0 then write(Kendo) else write('None');
					 FuckXy(14,4,^P'Total Calls: '^S+Strr(NumOn));
					 FuckXy(15,10,^P' ¯¯ User Note ®®');
					 FuckXy(16,4,^A'"'^S+Urec.UserNote+^A'"');
					(* blowup(1,3,70,3);
           blowup(4,3,70,6);
           write(^B);
           printxy(2,22,'L.S.D. Systems v.'+versionnum+' '+date);
           printxy(5,6,'User Online     :                             Number :');
           printxy(6,6,'Last User       :                        Your Call # :');
           printxy(7,6,'Total Time Used :                     Last Call Date :');
           printxy(8,6,'Todays Time     :                       Last Time on :');
           blowup(10,3,70,7);
           printxy(11,6,'Messages Posted :                     Total Uploaded :');
           printxy(12,6,'G-Files Sent    :                   Total Downloaded :');
           printxy(13,6,'G-File Downloads:                        File Points :');
           printxy(14,6,'New Callers     :                       Your Ranking :');
           printxy(15,6,'New Messages    :                          New Files :');           if hungupon then disconnect;
           printxy(17,33,' User Note');
           printzy(5,23,unam);
           printzy(6,23,getlastcaller);
           printzy(7,23,streal(totaltime)+' mins.');
           printzy(8,23,strr(timetoday)+' mins.');
           if laston>0 then Begin
           printzy(8,60,timestr(laston));
           printzy(7,60,datestr(laston));
           PrintZy(6,60,Strr(NumOn));
           end Else Begin
           Printzy(8,60,^G+'Never'+^G);
           PrintZy(7,60,^G+'Never'+^G);
           PrintZy(6,60,^G+'Never'+^G);
           End;
           printzy(5,60,streal(numcallers));
           printzy(11,23,strr(urec.nbu));
           printzy(12,23,strr(urec.nup));
           printzy(13,23,strr(urec.ndn));
           kendo:=trunc(numcallers)-urec.lastcalno;
           if kendo>0 then printzy(14,23,strr(kendo)) else
           printzy(14,23,'None');
           kendo:=gnup-urec.lastposts;
           if kendo<1 then printzy(15,23,'None') else begin
           printzy(15,23,'');  write(kendo);
           end;
           kendo:=gnuf-urec.lastfiles;
           if kendo<1 then printzy(15,60,'None') else begin
           printzy(15,60,'');write(kendo);
           end;
           printzy(14,60,strr(ulvl));
           printzy(13,60,strr(urec.udpoints));
           printzy(12,60,strr(urec.downloads));
           printzy(11,60,strr(urec.uploads));
           write(direct,#27,'[19;5H');
           kcenter (urec.usernote);
           subs1.laston:=laston;laston:=now;
           blowup(18,3,70,3);
					 write(direct,#27,'[21;1H'); write(configset.loginheade); *)
					 fuckxy(21,1,^A+configset.loginheade);
					 clearbreak;
					 fuckxy(22,1,'');
					 buflen:=0;

					 writestr(^P+'Press '+^S+'[Return]'+^P+' to continue.*');
													 end;
           if not asc    then begin
          writeln ('ÚÄÄÄÄÄÄÄÄÄÄ[ ',versionnum,' ',date,' ]ÄÄÄÄÄÄÄÄÄÄ¿');
      center ('Welcome, '+unam+'.','³','³');
      center ('Caller number: '+streal(numcallers),'³','³');
      center ('Last caller: '+getlastcaller,'³','³');
      center ('This is time on #'+strr(numon)+' for you.','³','³');
      center ('Total time on: '+streal(totaltime)+' mins.','³','³');
      if laston<>0 then
        center ('Last on '+datestr(laston)+' at '+timestr(laston)+
                    '.','³','³');
      subs1.laston:=laston;
      laston:=now;
      center ('Time for today: '+strr(timetoday)+' mins.','³','³');
      center ('Your ranking: Level '+strr(ulvl),'³','³');
      center ('Sysop is: '+inoutstr[sysopisavail],'³','³');
      writeln ('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'^B^M);
      end;
      if urec.udpoints<>urec.lastxferpts then writeln(^G^P'Your '^R'File X-Fer Points'^P' have changed since your last call.');
      if ulvl<>urec.lastlevel then writeln(^G^P'Your '^R'Access Level'^P' has changed since your last call.');
      if urec.hackattempts>0 then
          writeln(^G^P' There have been '^R,urec.hackattempts,^P' failed attempt(s) on your password!');
      urec.hackattempts:=0;
      CurrentConference:=Urec.LastConf;
      If Not Urec.Conf[CurrentConference] or (CurrentConference<1) or (CurrentConference>ConfigSet.NumConfs)
      then CurrentConference:=1;
      Urec.LastConf:=CurrentConference;
      If CurrentConference=1 then Tmp:=ConfigSet.Conf1
         Else if CurrentConference=2 then Tmp:=ConfigSet.Conf2
         Else if CurrentConference=3 then Tmp:=ConfigSet.Conf3
         Else if CurrentConference=4 then Tmp:=ConfigSet.Conf4
         Else if CurrentConference=5 then Tmp:=ConfigSet.Conf5;
      WriteLn(^P'Conference ['^R+tmp+^P'] has been joined.');
      if urec.totaltime<0 then totaltime:=0;
      if urec.totaltime<0 then urec.totaltime:=0;
      urec.lastxferpts:=urec.udpoints;
      urec.lastcalno:=trunc(numcallers);
      urec.lastlevel:=ulvl;
      if (datepart(urec.expdate)<>dateval('00/00/00')) and
      (datepart(urec.expdate)<>dateval('00/00/80')) then
       writeln(^G^P'Your account expires on '^R,datestr(urec.expdate),^P'!');
			if urec.revision<>lastrevision then writeln(^G^P'Adaptive upgrade ('^R,date,^P').');
			if urec.menuhighlight=0 then begin
				 WriteLn(^G^P'Adaptive Upgrade ('^R'9/6/90'^P').');
				 Urec.MenuHighLight:=14;
			End;
      if urec.timebank>configset.totalallowed then urec.timebank:=0;
      if urec.timebank<0 then urec.timebank:=0;
      urec.revision:=lastrevision;
      confilesa:=urec.lastfiles;
			urec.lastfiles:=gnuf;
			congfilesa:=urec.lastgfiles;
			urec.lastgfiles:=gnugfiles;
			conpostsa:=urec.lastposts;
      urec.lastposts:=gnup;
      urec.lastbaud:=connectbaud;
      if (ulvl>=configset.sysopleve) then begin
        if numfeedback>0 then begin
          thereisare (numfeedback);
          writeln ('piece',s(cnt),' of feedback waiting!  Use [%,F] to read.')
        end;
        if exist ('Errlog')
          then writeln (^B^G'Errors have occured!  Use [%,E] to read.');
                  if exist(configset.forumdi+'Notices.BBS') then begin
        clearscr;
        printfile(configset.forumdi+'Notices.BBS');
        writestr(^M^S'Delete Notices file now? *');
        if yes then begin
         assign(fil,configset.forumdi+'Notices.BBS');
         erase(fil);
         end;
        end;
      end;
      logontime:=timer;
      logofftime:=timer+timetoday;
      logonunum:=unum
    end;
    if exist ('ad')
      then writestr ('Buy this software!  Use & to read!');
    addlastcaller (unam);
    writeurec;
    bottomline;
    if wanted in urec.config then if sysopisavail then begin
      writeln (^B,configset.sysopnam,' wishes to speak with you.');
      writeln ('Paging.. please stand by...'^M);
      for cnt:=1 to 25 do if not keyhit then summonbeep;
      chatmode:=true
    end;
    oneliners;
    smartnews;
		(* newmailre;
		if tonext>-1 then begin
			writehdr ('Message from last user');
			printtext (tonext)
		end;
		if sysopisavail then writehdr(configset.sysopi) else writehdr(configset.sysopo); *)
		disconnected:=false
  end;

begin
	if local then clrscr;
  if configset.whissl then begin
     summonbeep;
     summonbeep;
     summonbeep;
  end;
  stoptimer (numminsidle);
  writestatus;
  starttimer (numminsused);
	if ansigraphics in urec.config then begin
  fillchar (urec,sizeof(urec),0);
  urec.statcolor:=configset.defstacolor;
  urec.regularcolor:=configset.defreg;
  urec.promptcolor:=configset.defpromp;
  urec.inputcolor:=configset.definput;
  urec.blowboard:=configset.defblowbor;
  urec.blowinside:=configset.defblowin;
  urec.config:=[lowercase,linefeeds,eightycols,ansigraphics,asciigraphics];
  end else begin
  fillchar(urec,sizeof(urec),0);
  urec.config:=[lowercase,linefeeds,eightycols];
  end;
  uselinefeeds:=true;
  usecapsonly:=false;
  getsystempassword;
  clearscr;
 if usedvmode then writeln('This system is currently Multi-Tasking under Desqview.'^M);
 writeln('L.S.D. BBS Ver.',versionnum,' - ',date,' Online at ',timestr(now),' on ',datestr(now),'!');
 printfile(configset.textfiledi+'Prelogon.bbs');
 	if configset.autologi and local and (not carrier) then begin
    unum:=lookupuser (configset.sysopnam);
    if unum=0
      then writeln (usr,'User ',configset.sysopnam,' not found!')
      else begin
        writeln (usr,'* SYSOP AUTOLOGIN *');
        unum:=1;
        inituser;
        exit
      end
  end;
  getunum;
  if hungupon then exit;
  if not isnew then getpwd;
  if hungupon then exit;
  inituser
end;

procedure returnfromdoor;
var t:sstr;
begin
  if not fromdoor then exit;
  readdataarea;
  baudrate:=valu(paramstr(2));
  if (paramstr(2))='38400' then baudrate:=38400;
  parity:=boolean(valu(paramstr(3)));
  online:=false;
  if baudrate<>0 then online:=true;
  local:=not online;
  if baudrate=0 then baudrate:=configset.defbaudrat;
  connectbaud:=baudrate;
  if (configset.defbaudrat>=9600) then baudrate:=configset.defbaudrat;
	setparam (configset.useco,baudrate,parity);
  if unum=valu(paramstr(1)) then readurec else begin
    unum:=valu(paramstr(1));
    readurec;
    if (unum<1) or (unum>numusers) then begin
      unum:=-1;
      exit
    end;
    logontime:=timer;
    logofftime:=timer+urec.timetoday
  end;
  if hungupon then begin
    unum:=-1;
    exit
  end;
  fromdoor:=true;
  t:=paramstr(4);
  if t=''
    then returnto:='D'
    else returnto:=upcase(t[1])
end;

begin
end.

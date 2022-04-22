  {$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }
  unit filexfer;

  Interface

  uses crt,dos,
  subs3,gentypes,configrt,modem,statret,gensubs,subs1,subs2,windows,
  userret,mainr1,mainr2,overret1,init,mainmenu;

  Procedure udsection;

  Implementation

Procedure udsection;

  procedure listarchive;forward;
  Procedure download(autoselect:Integer;FILE_Override:Lstr;Point_Override:integer );Forward;
  Procedure add_to_batch(autoselect:Integer;File_Override:lstr; Point_Override:integer);Forward;
  procedure setarea(n:integer;showit:boolean);forward;

  type batchrec=record
       filename:sstr;
       path:string[50];
       by:mstr;
       points,mins:integer;
       size:longint;
       wholefilename:lstr;
       area,filenum:integer;
  end;

  arprotorec=array[1..30] of protorec;

  batchlist=array[1..50] of batchrec;

  Var ud:udrec;
    area:arearec;
    curarea:Integer;
    Batchdown:batchlist;
    filesinbatch:Integer;
    BPOS:integer;
    dproto:arprotorec;
    uproto:arprotorec;
    totalupro:integer;
    totaldownpro:integer;

type BIREC=record
  CMDSTR:char;
  REFRESH:char;
  REPLACE:char;
  VERIFY:CHAR;
  DELETE:CHAR;
  DELETEABORT:CHAR;
  DIROVERRIDE:char;
  INCLUDEDIRO:char;
  SOURCEPATH:array [1..80] of char;
  Destpath  :array [1..80] of char;
  Description:array [1..80] of char;
end;

type bistuff=record
     shit: array [1..298] of char;
     end;

 Procedure AutoUploadGrant(Var Ud:Udrec);
 Var Te:Integer;
 Begin
   If ConfigSet.AutoUls>0 then
     Begin
       Te:=(Ud.FileSize Div 1024) div 2;
       Ud.NewFile:=False;
       Ud.Points:=Te*ConfigSet.AutoUls;
       WriteLn(^S'Granting you '^A,te*configset.uploadfacto,^S' file points.');
       Urec.UdPoints:=Urec.UdPoints+(Te*ConfigSet.UploadFacto);
     End;
 End;

 function abletodoanything(ud:Udrec):Boolean;
 Var C:Boolean;
 Begin
 C:=True;
 If ud.newfile and not issysop then
    Begin
      WriteLn(^S'Sorry, that is a [NEW] file and must be validated first!');
      C:=False;
    End;
 If Ud.SpecialFIle and not IsSysop then
    Begin
      WriteLn(^S'Sorry, that is a Special file and you must have permission!');
      C:=False;
    End;
 If not Exist(Ud.Path+Ud.FileName) then
   Begin
     WriteLn(^S'Sorry, that file is [OFFLINE] and requires special permission.');
     C:=False;
   End;
 AbleToDoAnything:=C;
End;

 {$I Bimodem.inc}

  Procedure listfiles(extended:Boolean);
    Var cnt,max,r1,r2,kn:Integer;
        T:Char;
    Const extendedstr:Array[false..true] Of String[9]=('','');
    Begin
      If nofiles Then exit;
      writehdr(extendedstr[extended]+'File List');
      max:=numuds;
      thereare(max,'file','files');
      parserange(max,r1,r2);
      If r1=0 Then exit;
      Write(^S); if not extended then doheader else doextended;
      kn:=0;
      For cnt:=r1 To r2 Do Begin
        listfile(cnt,extended);
        If break Then exit;
        inc(kn);
        if kn=20 then repeat
        kn:=0;
         writestr(^M^P'[File Area] [N]ext [V]iew [+] Add to batch [Q]uit [D]ownload :*');
         if input='' then input:='N';
         T:=UpCase(Input[1]);
         Case T of
           '+':Add_To_Batch(0,'',0);
           'D':DownLoad(0,'',0);
           'V':ListArchive;
           'Q':Exit;
           'N':DoHeader;
         End;
         until match(input,'N') or hungupon;
      End
    End;

  Function searchforfile(f:sstr):Integer;
    Var ud:udrec;
      cnt:Integer;
    Begin
      For cnt:=1 To numuds Do Begin
        seekudfile(cnt);
        Read(udfile,ud);
        If match(ud.filename,f) Then Begin
          searchforfile:=cnt;
          exit
        End
      End;
      searchforfile:=0
    End;

  Function getfilenum(t:mstr):Integer;
    Var n,s:Integer;
    Begin
      getfilenum:=0;
      If Length(Input)>1 Then Input:=Copy(Input,2,255) Else
        Repeat
          writestr(^R'File name/number to '+^S+t+^R' [?=List]:');
          If hungupon Or (Length(Input)=0) Then exit;
          If Input='?' Then Begin
            listfiles(False);
            Input:=''
          End
        Until Input<>'';
      Val(Input,n,s);
      If s<>0 Then Begin
        n:=searchforfile(Input);
        If n=0 Then Begin
          WriteLn(^S'File not found.');
          exit
        End
      End;
      If (n<1) Or (n>numuds)
      Then WriteLn(^P'File number out of range!')
      Else getfilenum:=n
    End;

   function allowbaud:boolean;
   var k:integer;
       cnt:baudratetype;
   begin
     for cnt:=firstbaud to lastbaud do if connectbaud=baudarray[cnt] then
       if not (cnt in configset.downloadrate) then begin
       writeln(^M^G'You may not download at ',connectbaud,' baud rate!');
       allowbaud:=false;
       exit;
     end;
   allowbaud:=true;
   end;

   Function allowxfer:Boolean;
    Begin
      allowxfer:=False;
      If Not carrier Then Begin
        WriteLn(^S'You may only transfer from remote!');
        exit
      End;
      if filesinbatch>0 then begin
         writeln(^S'You must first either clear or download your BATCH que!');
         exit;
      end;
      if not allowbaud then exit;
      allowxfer:=True
    End;

  Procedure addfile(ud:udrec);
    Begin
      seekudfile(numuds+1);
      Write(udfile,ud)
    End;

  Procedure getfsize(Var ud:udrec);
    Var df:File Of Byte;
    Begin
      ud.filesize:=-1;
      Assign(df,getfname(ud.path,ud.filename));
      Reset(df);
      If IOResult<>0 Then exit;
      ud.filesize:=FileSize(df);
      Close(df)
    End;

  Function wildcardmatch(w,f:sstr):Boolean;
    Var a,b:sstr;

    Procedure transform(t:sstr;Var q:sstr);
      Var p:Integer;

      Procedure filluntil(k:Char;n:Integer);
        Begin
          While Length(q)<n Do q:=q+k
        End;

      Procedure dopart(mx:Integer);
        Var k:Char;
        Begin
          Repeat
            If p>Length(t)
            Then k:='.'
            Else k:=t[p];
            inc(p);
            Case k Of
              '.' :Begin
                     filluntil(' ',mx);
                     exit
                   End;
              '*' :filluntil('?',mx);
            Else If Length(q)<mx Then q:=q+k
            End
          Until 0=1
        End;

      Begin
        p:=1;
        q:='';
        dopart(8);
        dopart(11)
      End;

    Function theymatch:Boolean;
      Var cnt:Integer;
      Begin
        theymatch:=False;
        For cnt:=1 To 11 Do
          If (a[cnt]<>'?') And (b[cnt]<>'?') And
          (UpCase(a[cnt])<>UpCase(b[cnt])) Then exit;
        theymatch:=True
      End;

    Begin
      transform(w,a);
      transform(f,b);
      wildcardmatch:=theymatch
    End;

  Const beenaborted:Boolean=False;

  Function aborted:Boolean;
    Begin
      If beenaborted Then Begin
        aborted:=True;
        exit
      End;
      aborted:=xpressed Or hungupon;
      If xpressed Then Begin
        beenaborted:=True;
        WriteLn(^B'Newscan abort')
      End
    End;

  {$I filexf2.inc}
  Procedure newscan;
    Var cnt:Integer;
      u:udrec;
      kn:integer;
      first:Boolean;
      done:Boolean;
      T:Char;
    Begin
      done:=False;
      Repeat
        first:=False;
        beenaborted:=False; kn:=0;
        For cnt:=1 To FileSize(udfile) Do Begin
          If aborted Then exit;
          seekudfile(cnt);
          Read(udfile,u);
          if kn=20 then repeat
          writestr(^M'[Newscan] [+]Add to batch [D]ownload [V]iew [Q]uit [N]ext :');
          if input='' then input:='N';
          kn:=0;
          T:=UpCase(Input[1]);
          Case T of
            '+':Add_To_Batch(0,'',0);
            'D':Download(0,'',0);
            'V':ListArchive;
            'Q':Begin
                 BeenAborted:=True;
                 Done:=True;
                 WriteLn(^M'Newscan Aborted!');
                 setarea(1,true);
                 exit;
               end;
            'N':DoHeader;
          End;
          until match(input,'N') or hungupon;
          If (u.whenrated>laston) Or (u.when>laston)
          Then Begin
            inc(kn);
            If Not first Then Begin
              doheader;
            first:=True;End;
            listfile(cnt,False);
          End;
        End;
        If first Then Begin
          Writestr(^M'[Newscan] [A]gain [+]Add to Batch [D]ownload [V]iew [Q]uit [N]ext :');
          If Input='' Then Input:='N';
          t:=UpCase(Input[1]);
           Case T of
             'A':Done:=False;
             '+':Add_To_Batch(0,'',0);
             'D':download(0,'',0);
             'Q':begin
                 beenaborteD:=true;
                 done:=true;
               end;
            'V':listarchive;
          End;
          if pos(T,'A+DQV')=0 then done:=True;
        End;
        If Not first Then done:=True;
      Until done;
    End;


  Procedure getstring(t:lstr;Var m);
    Var q:lstr Absolute m;
      mm:lstr;
    Begin
      WriteLn('Old '^S,t,^R': ',q);
      writestr('Enter new '+^S+t+^P+' [CR for no change]:');
      mm:=Input;
      If Length(mm)<>0 Then q:=mm;
      WriteLn
    End;

  Procedure getint(t:lstr;Var i:Integer);
    Var s:sstr;
    Begin
      s:=strr(i);
      getstring(t,s);
      i:=valu(s)
    End;

  Procedure getboo(t:lstr;Var b:Boolean);
    Var s:sstr;
    Begin
      s:=yesno(b);
      getstring(t,s);
      b:=UpCase(s[1])='Y'
    End;

	Procedure removefile(n:Integer; gock:boolean);
		Var cnt,un:Integer;
				u:userrec;

		procedure AskDeleteQuery;
		Begin
			WriteStr(^M^P'Remove from '+Ud.SentBy+'s Status? *');
			If Not Yes then Exit;
			Un:=LookUpUser(Ud.SentBy);
			If Un=-1 then WriteLn(^M'User Disappeared!');
			If Un=-1 then Exit;
			Seek(Ufile,Un);
			Read(Ufile,U);
			U.Uploads:=U.Uploads-1;
			U.UdPoints:=U.UdPoints-(Ud.Points*ConfigSet.UploadFacto);
			U.UpKay:=U.UpKay-(Ud.FileSize Div 1024);
			Seek(Ufile,Un);
			Write(Ufile,U);
		End;

		Begin
			seekudfile(n);
			read(udfile,ud);
			if gock then askdeletequery;
			For cnt:=n To numuds-1 Do Begin
				seekudfile(cnt+1);
				Read(udfile,ud);
				seekudfile(cnt);
				Write(udfile,ud)
			End;
			seekudfile(numuds);
			Truncate(udfile)
		End;

  Procedure displayfile(Var ffinfo:searchrec);
    Var a:Integer;
    Begin
      a:=ffinfo.attr;
      If (a And 8)=8 Then exit;
      tab(ffinfo.name,13);
      If (a And 16)=16
      Then Write('Directory')
      Else Write(ffinfo.size);
      If (a And 1)=1 Then Write(' [read-only]');
      If (a And 2)=2 Then Write(' [hidden]');
      If (a And 4)=4 Then Write(' [system]');
      WriteLn
    End;

  Function defaultdrive:Byte;
    Var r:registers;
    Begin
      r.ah:=$19;
      Intr($21,r);
      defaultdrive:=r.al+1
    End;

  Procedure directory;
    Var r:registers;
      ffinfo:searchrec;
      tpath:anystr;
      b:Byte;
      cnt:Integer;
    Begin
      tpath:=area.xmodemdir;
      If tpath[Length(tpath)]<>'\' Then tpath:=tpath+'\';
      tpath:=tpath+'*.*';
      writestr('Path/wildcard [CR for '+^S+tpath+^P+']:');
      WriteLn(^M);
      If Length(Input)<>0 Then tpath:=Input;
      writelog(16,10,tpath);
      findfirst(Chr(defaultdrive+64)+':\*.*',8,ffinfo);
      If doserror<>0
      Then WriteLn('No volume label'^M)
      Else WriteLn('Volume label: ',ffinfo.name,^M);
      findfirst(tpath,$17,ffinfo);
      If doserror<>0 Then WriteLn('No files found.') Else Begin
        cnt:=0;
        While doserror=0 Do Begin
          inc(cnt);
          If Not break Then displayfile(ffinfo);
          findnext(ffinfo)
        End;
        WriteLn(^B^M'Total files: ',cnt)
      End;
      Write('Free disk space: ');
      writefreespace(tpath)
    End;

    Function OKRatiosAnd(Ud:Udrec):Boolean;
    Var C:Boolean;
      Procedure SeaError(M:Lstr);
      Begin
        C:=False;
        WriteLn(^S,M);
      End;

    Begin
    C:=True;
      If Not Area.DownLoadHere then
          SeaError('You may not download in this area!');
      If Not OkUdRatio and C then seaerror('Your Upload/Download Ratio is out of wack! Upload First!');
      If Not OkUdK and C then
            SeaError('Your Upload/Download K Ratio is out of wack! Upload First!');
      If (Ud.SendTo<>'') and Not Match(Ud.Sendto,Urec.Handle) and C then
            SeaError('This file is Not for you!');
      If (Ud.Pass<>'') and C then
         Begin
           WriteStr(^M^S'Password Protected file!'^M^M^P'Password:');
           If not Match(Input,Ud.Pass) then
             SeaError('Wrong Password');
           End;
      OkRatiosAnd:=C;
    End;



    Procedure download(autoselect:Integer;FILE_Override:Lstr;Point_Override:integer );

    Var totaltime:sstr;
      timewhilebeing:integer;
      fsize:longint;
      proto,num,mins:Integer;
      ud:udrec;
      shit:integer;
      joe:longint;
      zmodem,fname:lstr;
      ymodem:Boolean;
      b:Integer;
      f:File;
    Begin
if file_override='' then begin
      If Not allowxfer Then exit;
      If nofiles Then exit;
      If autoselect=0
      Then num:=getfilenum('download')
      Else num:=autoselect;
      If num=0 Then exit;
      WriteLn;
      seekudfile(num);
      Read(udfile,ud);
      if file_OverRide='' then if Not OkRatiosAnd(Ud) then Exit;
      end else ud.points:=point_override;
      If (Not sponsoron) And (ud.points>urec.udpoints) and (not configset.leechwee)
      Then Begin
        WriteLn(^P'That file requires '^S,ud.points,^P' points.');
        exit
      End;
      If (File_override='') and Not AbleToDoAnything(Ud) then Exit;
      if file_override='' then fname:=getfname(ud.path,ud.filename) else
          fname:=file_override;
      If tempsysop Then Begin
        ulvl:=regularlevel;
        tempsysop:=False;
        writeurec;
        bottomline
      End;
      ymodem:=False;
      proto:=protocaseselection(true);
      if proto=0 then exit;
      Assign(f,fname);
      Reset(f);
      iocode:=IOResult;
      If iocode<>0 Then
        Begin
          fileerror('DOWNLOAD',fname);
          exit
        End;
      fsize:=FileSize(f);
      Close(f);
      totaltime:=minstr(fsize);
      mins:=valu(Copy(totaltime,1,Pos(':',totaltime)-1));
      If ((mins>timeleft) And (Not sponsoron)) Then Begin
        writestr(^S'Insufficient time for transfer!');
        exit
      End;
      If (mins-5>timetillevent) Then Begin
        writestr(^S'You may not transfer right before the event occurs.');
        exit
      End;
      If (vt52 in urec.config) or (ansigraphics In urec.config) Then Begin
      clearscr;
      printxy(4,1,'');End;
      bottomline;
      Writehdr('File Download');
      if file_override='' then begin
      WriteLn(^R'Filename:         '^S,upstring(ud.filename));
      WriteLn(^R'Uploaded by:      '^S,ud.sentby);
      WriteLn(^R'Times downloaded: '^S,ud.downloaded);
      If ymodem Then fsize:=(fsize+7) Div 8;
      Write(^R'Cost (pts.):      '^S);
      if (ud.points>0) and (not configset.leechwee) then writeln(ud.points) else
      writeln('Free');
      joe:=fsize*128;
      WriteLn(^R'Bytes to send :   '^S,strlong(joe));
      WriteLn(^R'Approx. Time :    '^S,totaltime);
      WriteLn(^R'Current Time Left:'^S,timeleft);
      end;
      WriteLn(^M^M^S'Press [Ctrl-X] many times to abort'^B);
      Delay(2500);   clrscr;
      timewhilebeing:=timeleft;
      b:=protocolxfer(True,False,ymodem,proto,fname);
      beepbeep(b);
      If (b=0) Or (b=1) Then Begin
        writelog(15,1,fname);
        inc(urec.downloads);
        if file_override='' then begin
        inc(ud.downloaded);
        seekudfile(num);
        Write(udfile,ud);
        end;
        delay(2000);
        if file_override='' then
        pointcom(ud.sentby,ud.points);
        nosound;
  if file_override='' then else      ud.points:=Point_override;
        If (ud.points>0) and (not configset.leechwee) Then Begin
          WriteLn(^M^M^R'Your File Points --> '^S,urec.udpoints);
          WriteLn(^R'File Xfer Charge --> '^S,ud.points);
          WriteLn(^B^P'                     -----');
if sponsoron then
          Writeln(^B^S'No Charge for Sysop>');
       if not sponsoron then urec.udpoints:=urec.udpoints-ud.points;
          WriteLn(^R'Your new total ----> '^S,urec.udpoints);
        End;
        writeurec;
      End
    End;

  Procedure upload;
    Var ud:udrec;
      ok,crcmode,ymodem:Boolean;
      proto,b:Integer;
      zmodem,fn:lstr;
      start_time : integer ;
      tmp1,tmp2:anystr;
      _name:namestr;
      _ext:extstr;

    Begin
          if area.uploadhere<>true then writeln (^S'You can not upload to this area!');
      if area.uploadhere<>true then exit;
      If Not allowxfer Then exit;
      If (timetillevent<30) Then Begin
        writestr(
        'Uploads are not allowed within 30 minutes of Events!');
        exit
      End;
      ok:=False;
      Write(^P'Current Free Space: ');
      writefreespace(area.xmodemdir);
      if not enoughfree(area.xmodemdir) then exit;
      WriteLn;
      Repeat
        writestr('Upload filename:');
        If Length(Input)=0 Then exit;
        If Not validfname(Input) Then Begin
          WriteLn(^S'Invalid filename!');
          exit
        End;
        ud.filename:=upstring(Input);
        ud.path:=area.xmodemdir;
        fn:=getfname(ud.path,ud.filename);
        If hungupon Then exit;
        If exist(fn)
        Then WriteLn(^S'Filename already exists! Try Again!')
        Else ok:=True
      Until ok;
      ymodem:=False;
      BufLen:=40;
      writestr('Description of file: &');
      ud.descrip:=Input;
      proto:=protocaseselection(false);
      if proto=0 then exit;
      clearscr;
      bottomline;
      Writehdr(Ud.filename+' Upload');
      WriteLn(^S'Receive ready.'^R' Press [Ctrl-X] many times to Abort!');
      If tempsysop Then Begin
        ulvl:=regularlevel;
        tempsysop:=False;
        writeurec;
        bottomline
      End;
      start_time := timeleft ;clrscr;
      delay(2500);
      b:=protocolxfer(False,crcmode,ymodem,proto,fn);
      beepbeep(b);
      If b=0 Then Begin
        writelog(15,2,ud.filename);
        ud.sentby:=unam;
        ud.when:=now;
        ud.whenrated:=now;
        ud.points:=0;
        ud.sendto:='';
        ud.downloaded:=0;
        ud.newfile:=True;
        ud.specialfile:=False;
        ud.downloaded:=0;
        ud.pass:='';
        ud.path:=area.xmodemdir;
        tmp1:=ud.path;
        tmp2:=ud.filename;
        addzipcomment(tmp1+tmp2,tmp1,tmp2);
          WriteLn('Thanks for the upload');
        getfsize(ud);
        AutoUploadGrant(Ud);
        addfile(ud);
        inc(urec.uploads);
        inc(newuploads);
        inc(gnuf);
        settimeleft(start_time+(((start_time-timeleft)*configset.timepercentbac) div 100));
      End;
    End;

  Procedure clear_batchdown;
		Begin
			filesinbatch:=0;
			fillchar(BatchDown,SizeOf(BatchDown),0);
		End;

  Function batchtotaltime:longint;
    Var cnt:Integer;
      Time:Integer;
    Begin
      time:=0;
      If filesinbatch>0 Then Begin
        For cnt:=1 To filesinbatch Do Begin
          time:=time+batchdown[cnt].mins;
        End;
        batchtotaltime:=time;
      End Else batchtotaltime:=0;
    End;

  Function totalpoints:longint;
    Var cnt:Integer;
      points:Integer;
    Begin
      points:=0;
      If filesinbatch>0 Then Begin
        For cnt:=1 To filesinbatch Do Begin
          points:=points+batchdown[cnt].points;
        End;
        totalpoints:=points;
      End Else totalpoints:=0;
    End;

  Procedure listbatch;
    Var cnt,a,b:Integer;
      Z:sstr;
      totk,tempk:longint;
      Justy:Integer;
    Begin
      If filesinbatch<1 Then WriteLn(^S'No files in batch!'^G);
      If filesinbatch<1 Then exit;
      clearscr;
      totk:=0;
      Writehdr('Batch Xfer List');
      writeln (^P'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿');
			writeln (^P'³ '^S'File Name'^P'                      ³ '^S'Bytes'^P'   ³'^S'  Points'^P'    ³'^S' Minutes'^P'    ³');
      writeln (^P'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄ´');
        For cnt:=1 To FilesInBatch Do begin
          Write (^P'³  '^S);
          Tab(Upstring(BatchDown[Cnt].FileName),30);
          Write (^P'³ '^S);
          TempK:=BatchDown[Cnt].Size Div 1024;
          TotK:=TotK+TempK;
          Tab(StrLong(BatchDown[Cnt].Size),8);
          Write (^P'³ '^S);
          Tab(Strr(BatchDown[Cnt].Points),11);
          Write (^P'³ '^S);
          Tab(Strr(BatchDown[Cnt].Mins),11);
          writeln (^P'³');
          if Break then Exit;
	      End;
      writeln (^P'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÙ');
      justy:=totalpoints;
      WriteLn(^M^R'Accumulated File points ---> '^S,justy);
      Justy:=batchtotaltime;
      WriteLn(^R'Accumulated Mins for Xfer -> '^S,justy);
      writeln(^R'Total K-Bytes in file Xfer > '^S,totk);
     End;

    Procedure add_to_batch(autoselect:Integer;File_Override:lstr; Point_Override:integer);
    Var totaltime:sstr;
      proto,num,fsize,mins:Integer;
      ud:udrec;
      zmodem,fname:lstr;
      tempo:longint;
      ymodem:Boolean;
      Too,Too1:mstr;
      b:Integer;
      f:file;
      fn:File of byte;
    Begin
    if filesinbatch>=50 then writeln ('You can only have 50 files tagged!');
    if filesinbatch>=50 then exit;
    if file_override='' then begin
      If nofiles Then exit;
      If autoselect=0
      Then num:=getfilenum('add to batch')
      Else num:=autoselect;
      If num=0 Then exit;
      WriteLn;
      seekudfile(num);
      Read(udfile,ud);
      if not OkRatiosAnd(Ud) then Exit;
      end else ud.points:=point_override;
      if not allowbaud then exit;
      If (Not sponsoron) And (((Totalpoints)+(ud.points))>urec.udpoints) and (not configset.leechwee)
       Then Begin
        WriteLn(^S'You do not have sufficient points to add this file!');
        exit
      End;
      If (File_override='') and not AbleToDoAnything(Ud) then Exit;
      If tempsysop Then Begin
        ulvl:=regularlevel;
        tempsysop:=False;
        writeurec;
        bottomline
      End;
if file_override='' then   fname:=getfname(ud.path,ud.filename) else
                           fname:=file_override;
      Assign(f,fname);
      Reset(f);
      iocode:=IOResult;
      If iocode<>0 Then
        Begin
          fileerror('DOWNLOAD',fname);
          exit
        End;
      fsize:=FileSize(f);
      Close(f);    assign(fn,fname); reset(fn);tempo:=filesize(fn);close(fn);
      totaltime:=minstr(fsize);
      mins:=valu(Copy(totaltime,1,Pos(':',totaltime)-1));
      If (((mins+batchtotaltime)>timeleft) And (Not sponsoron)) Then Begin
        writestr(^S'Insufficient time to add this file to batch!');
        exit
      End;
      If (mins-5>timetillevent) Then Begin
        writestr(^S'Sorry, the event is happening in a few minutes.');
        exit
      End;
      b:=filesinbatch;
      inc(b);filesinbatch:=b;
      batchdown[b].size:=tempo;
      if file_override<>'' then ud.sentby:='';
      batchdown[b].by:=ud.sentby;
      batchdown[b].wholefilename:=fname;
      batchdown[b].mins:=mins;
      batchdown[b].area:=curarea;
      batchdown[b].filenum:=num;
      if not configset.leechwee then batchdown[b].points:=ud.points else
      batchdown[b].points:=0;
      fsplit (fname,ud.path,too,too1);
      ud.filename:=too+too1;
      batchdown[b].filename:=ud.filename;
      batchdown[b].path:=ud.path;
      Appendbimodem ('U',fname,' ');
      WriteLn(^B^P,upstring(ud.filename),' added to batch que');
    End;

      Procedure BIMODEMupload;
    Var ud:udrec;
      ok,crcmode,ymodem:Boolean;
      proto,b:Integer;
      YF,zmodem,fn:lstr;
      start_time : integer ;
    Begin

      ok:=False;
     writehdr ('ADD BIMODEM UPLOAD');
      WriteLn;
      writeln ('You Must specify the file your going to upload');
      writeln ('including the drive/direct on Your computer.');
      writeln ('Then specify the filename <no dirs> you want the bbs to name it.'^M);
      Repeat
        writestr('Full Filename on YOUR computer:');
        If Length(Input)=0 Then exit;
         yf:=input;
        Writestr('Filename for the bbs:');
        if length(input)=0 then exit;
        If Not validfname(Input) Then Begin
          WriteLn(^S'Invalid filename!');
          exit
        End;
        ud.filename:=upstring(Input);
        ud.path:=area.xmodemdir;
        fn:=getfname(ud.path,ud.filename);
        If hungupon Then exit;
        If exist(fn)
        Then WriteLn(^S'Filename already exists! Try Again!')
        Else ok:=True
      Until ok;

      APPENDBIMODEM ('D',yf,fn);
      Writeln (^S'File added!');
    end;

  Procedure Do_batch_download;
    Var zmodem:Char;
      proto:Integer;
      laterguy:boolean;
      b:Integer;

    Begin
    if filesinbatch<1 then exit;
      If (vt52 in urec.config) or (ansigraphics In urec.config) Then clearscr;
      Writehdr('L.S.D. Batch Protocols');
      WriteLn(^P'['^R'Y'^P']modem-Batch        ['^R'Z'^P']modem ''90');
      WriteLn(^P'['^R'G'^P'] Ymodem-G          ['^R'P'^P']cp Zmodem   ');
      WRiteln(^P'['^R'S'^P'] Puma              ['^R'4'^P']k Zmodem [pB4096 rz]');
      writestr(^M'Select a Protocol ['+^V+'Z'+^P'] : *');
      If Input='' Then Input:='Z';
      zmodem:=UpCase(Input[1]);
      Proto:=Pos(Zmodem,'YZGPS4');
      if proto=0 then exit;
      writestr(^M^P'Do you wish to hang up after your download is completed? *');
      laterguy:=yes;
      listbatch;
      WriteLn(^M^S'+-Sending Batch Que Now!-+');
      delay(500);
      b:=0;
      B:=Batch_Download(Proto,filesinbatch,Batchdown);
      If b>0 Then Begin
         If (b>0)  Then Begin
          WriteLn(^M^M^P'Your File Points --> '^S,urec.udpoints);
          WriteLn(^P'Batch Xfer Total --> '^S,b);
          WriteLn(^B^P'                     -----');
          urec.udpoints:=urec.udpoints-b;
          WriteLn(^B'Your new total ----> '^s,urec.udpoints);
        End;
        writeurec;
      End;
       clear_batchdown;
      if laterguy then begin
         writeln(^M^R'(* '^P'Performing Auto-Disconnect '^R' *)');
         delay(2500);
         writeurec;
         hangup;
         disconnect;
      end;
    End;

procedure DOBIXFER;
    var a:text;
    Such:integer;
    b:anystr;
    BIdir,BBsdir:lstr;

Procedure process_uploads;

var BISEX:file of birec;
    HOMO,FAG:birec;
    krad,cnt:integer;
    zmodem:lstr;
    ud:udrec;
    _name:namestr;
    kenny1:anystr;
    kenny2:anystr;
    _ext:extstr;

begin
if not exist('Lsd.pth') then begin Writeln (configset.bimodemdi+'Lsd.pth is missing!');exit;

                             end;
writehdr ('Checking your uploads');
assign (bisex,'Lsd.pth');
reset(bisex);

for cnt:=1 to filesize(bisex) do begin
seek (bisex,cnt-1);
read(bisex,homo);

if ( (homo.cmdstr='R') or (homo.cmdstr='D') ) and (exist(homo.destpath)) then begin
        Zmodem:=homo.destpath;
        getpathname(Zmodem,ud.path,ud.filename);
        If Not hungupon Then Begin
          BufLen:=40;
          input:=ud.filename;
          ud.filename:=upstring(input);
          Writestr(^B^P'Description for '^S+Ud.filename+^P' :');
          ud.descrip:=Input;
        End Else ud.descrip:='';
        kenny1:=ud.path;kenny2:=ud.filename;
        addzipcomment(kenny1+kenny2,kenny1,kenny2);
        writelog(15,2,ud.filename);
        ud.sentby:=unam;
        ud.when:=now;
        ud.whenrated:=now;
        ud.points:=0;
        ud.downloaded:=0;
        ud.newfile:=True;
        ud.specialfile:=False;
        ud.downloaded:=0;
        ud.sendto:='';
        ud.pass:='';
        getfsize(ud);
        addfile(ud);
        Inc(urec.uploads);
        inc(newuploads);
        inc(gnuf);
      End;


end;
close(bisex);
end;

    begin
    Writehdr('Executing BiModem');
    assign (a,'bimodem.log');
    if exist('bimodem.log') then erase(A);
    bidir:=configset.bimodemdi;
    bidir[(length(bidir))]:=' ';
    chdir (bidir);
    Writeln (Usr,'* Changing to Bimodem dir: ',configset.bimodemdi);
    exec ('bimodem.com','');
    BBSDIR:=configset.forumdi;
    bbsdir [(length(bbsdir))]:=' ';
    chdir (bbsdir);
    delay(2000);
    Writestr ('Press [Return] to Continue :');
    if filesinbatch>0 then begin
      such:=BIcharge(filesinbatch,Batchdown);
      If such>0 Then Begin
       inc(urec.downloads);
        If (such>0) And (Not sponsoron) Then Begin
          WriteLn(^M^P'Your File Points --> '^S,urec.udpoints);
          WriteLn(^P'Batch Xfer Total --> '^S,such);
          WriteLn(^B^P'                     -----');
          urec.udpoints:=urec.udpoints-such;
          WriteLn(^B'Your new total ----> '^s,urec.udpoints);
        End;
        writeurec;

      end;
    end;
    Process_Uploads;
    killbimodem;clear_batchdown;
    Writeln (^b'Thank you for using Bimodem!');
    end;

  Procedure Batch_upload;
    Var ud:udrec;
    kenny1,kenny2:anystr;
    _name:namestr;
    _ext:extstr;
      ok,crcmode,ymodem:Boolean;
      cnt,proto,b:Integer;
      zmodem,fn:lstr;
      BITCH:batchlist;
      te:integer;
      start_time : integer ;
    Begin
      If (timetillevent<30) Then Begin
        writestr('Uploads are not allowed within 30 minutes of Timed Event!');
        exit
      End;
      ok:=False;
      Write(^P'Free Space: ');
      writefreespace(area.xmodemdir);
      if not enoughfree(area.xmodemdir) then exit;
      ymodem:=False;
      WriteLn(^M^M);
      writehdr('Batch Protocols');
      WriteLn(^P'['^R'Y'^P']modem (True)       ['^R'Z'^P']modem');
      WriteLn(^P'['^R'G'^P'] Ymodem-G          ['^R'P'^P']cp Zmodem');
      Writeln(^P'['^R'S'^P'] Puma              ['^R'Q'^P']uit'^M);
      writestr(^B'Select a Protocol ['+^V+'Z'+^W']: *');
      If Input = '' Then Input := 'Z' ;
      zmodem:=UpCase(Input[1]);
      Proto:=Pos(Zmodem,'YZGPS');
      if proto=0 then exit;
      WriteLn(^S'Batch Receive ready. Press [Ctrl-X] many times to Abort!');
      If tempsysop Then Begin
        ulvl:=regularlevel;
        tempsysop:=False;
        writeurec;
        bottomline
      End;
      clear_batchdown;
      cnt:=0;
      start_time := timeleft ;
      B:=BatchUpload(Proto);
      delay(2000);
      Writestr(^P'Press '^R'[Return]'^P' to continue:');
      WriteLn(^B^M'Total Files received -> ',filesinbatch);
      If filesinbatch=0 Then exit;
      For cnt:=1 To filesinbatch Do Begin
        Zmodem:=batchdown[cnt].wholefilename;
        getpathname(Zmodem,ud.path,ud.filename);
        If Not hungupon Then Begin
          BufLen:=40;
          input:=ud.filename;
          ud.filename:=upstring(input); nochain:=true;
          Writestr(^B'Description for '^S+Ud.filename+^P' :');
          ud.descrip:=Input;
        End Else ud.descrip:='';
        kenny1:=ud.path;
        kenny2:=ud.filename;
        addzipcomment(kenny1+kenny2,kenny1,kenny2);
        writelog(15,2,ud.filename);
        ud.sentby:=unam;
        ud.when:=now;
        ud.whenrated:=now;
        ud.sendto:='';
        ud.points:=0;
        ud.downloaded:=0;
        ud.newfile:=True;
        ud.specialfile:=False;
        ud.downloaded:=0;
        ud.pass:='';
        getfsize(ud);
        AutoUploadGrant(Ud);
        addfile(ud);
        Inc(urec.uploads);
        inc(newuploads);
        inc(gnuf);
      End;
        clear_batchdown;
      WriteLn(^B^M'Thank you for Batch Uploading!');
     settimeleft(start_time+(((Start_time-timeleft)*configset.timepercentbac) div 100))
    End;


  Procedure searchfile;
    Var inÚc8  $,X=ank yojaloads);
  escrip:=InpOLThen c
 ssign rites> a^P'] Ymodemtimr
  'Thacmod c.uploads);tegin
    _OMated:=now;ect '^R' *)');L=unleted? *');
  d);
        addfile(ud);
        Inc(urec.uploads);
  i;
 
     U:='col [   Wrile:=Fa(gnuf);
    pai rI(^S'File added!');
    end;

 Hrscr;
     Var inÚc8  $,X=ank yojalocmode,
  Dånf     IfISgetfsize=BI-col        WriteLn(^P'Batch Xfer Tota        awfile:=True;
        ud.specialfile:=False;
       l   Ionxitn;c8  $,X=aoÌD0î
        WriEˆI  $,X=h   exec ('bimodem.com','');
 xit;Ge
   L  oÜoUd);
        a         hangup;
         tch Uploading!');
     settimeleft(start_t  L;L=g!');7.specialfile:=False;
     oc8  dename;
        gspeI2fsizeDEI0     ['^R'S'^P'] Puma              ['^R'4 ½eft7
   L  put);
      aed? 1 searcCelPuma Zmodem,ud.patha Zmod h:=yes;
']: *'ËI
 rn);
 PploId.p6Var inÚc8  $,X=ank yojaloNr;
I your uploads');
assign (bisex,'Lsd.pth');
reset(bisex);

for cnt:=1 EI0     ['^R'S
   i='col [   Wrile:=Fa(gnuf);
    pai rI(^S'File addee:= lai     IfISgetfsize=BI-cosue;
 einÚc8  $,X=ank yojalocmode,
  Dånf     IfISgetet.forl   iE       gsing(inp IfISget90'a          _nameog(15,2,   y2:sin   IfISg  gsitch PI yh P
 ddzipc     [','');ninp I;
  ejaloads);
  escrip:=In     t  L;L=        mioadssin   IfIIn     t  L;L=        mioadssin   IfIIn     t  L;L=        mioadssin   IfIIn     t  L;L=        mioadssin   IfIIn     t  L;L=        mioadssin   IfIIn     t  L;L=        mioadssin   IfIIn     t  L;L=        mioadssin   IfIIn     t  L;L=        mioadssin   IfIIn     t  L;L= uitel   --oads)ioa  L;L=        m
vp:=False;
        writeurec;
        bottomline
      En     ber 
lse;_IfI Egth(bbsd    a   V dename;
;
  BufL ud.whenrated:=nont  L;L=        mioadssin   IfIIn     t  L VpWriteLn(^M^M^P'      WriteLGwD5   mioadss)tel   --oads)9(Enu
  BufL udrent(ksearchfile;
 
     t  L;L=   tot--oR a   AAAAAA Writeh
     0A= laename;
;
  BufL ud.whe   AAAAAAsing(inpbain:=F   Such:int Begi=F   S_Ra(gnu'Select a Protocol ['+^V+'Z'+^W']: *Z'+^W'];
  bbsd r
lse;dssin :');kfBIS);
        addfile(ud);
        Inc( BufL u T if exist('bimode- bd-Ra(gnuProto  For aE{B['+^V+'ZTakele;
 
 dss)tel   --oads)9(Enu
  BufL udrent(ksearPr   fI Ecosue;
 einÚnÚnÚnÚnÚnÚnÚnÚnÚnÚnÚnÚnÚn      addf13le(ud);
        Inc( BufL u T if existnput:=ud.f    mio+dssin   IfIIr aE{B  m'[Of     ]',10
 
       t  L;L=                           escr     cled);e(ud);
        Inc( BufL u T if existesc<1024r aE{Bescr 1025e(ud);
        Inc( BufL u T if exnt(kse   ip:=(esc      l24ssik':9,dssin   IfIIn     '^S+Ud.filename+^P' :');
 d);
        Inc( BufL u T if exnt(kse    (ud);
        Inc( BufL u T if existk3:=nr aE{Bkile'-:=0 ud);
      Ge;n-nleted? *');););););););););););););    39;    t  L;L= 3eurec;
     41
 d);
        Inc( BufL u T if exnt(ks ti'   Wrgnu   1p:=Fin   IfIIn     '^S+Ud.filename+^P' :');
 d);
 wnloaded:=0;
 telog(15,2,ud.numuB'S       ud.sentby:=    mioadssing(1in   IfIIn    R;L=        min   IfIIn     gsped.downloade        in   IfIIn    fspl7
Usin   IfI,u  mioa2fsizeDEI0ile(ud);
     DEI0 d.d   inc(ne(ud);
     DEI0   4 ½eft7
 gspeIEn     berEI0 Fin   IfIIn    DEI0 d.4 ½eft7
 gspeIDEI0 in   IfIIn    DEI04  4 ½eft7
 gspeIEn     berEI04Fin  
 		] Pu(h=0  gspeI2fsiz)tot-O   h=0  gspeI2fsi3eur)ud.fil(p=0  gspeI2fsi4eur)u  
 		Tioads
 			     t 
 			.forl   iE m (Tc.upl, gspeI2fsizeDEI0     ['in  
 			  oÜoUdd.pass:=
 			');
 d);
     ] PxpElse
 ny2);
  urec.uploads)tch>0 then begin;
 wnloaded:=0;;
      Ixt:exS   se=Pos(Zmodem,'YZGwriteS   se ProSelealefy/N]?ontinue:');
m','');
 =ye   ok:=F: ');
     M  Z   NOT(arl [       sme(Zmodem,ud      Writ;
 TEXT
   m','')tfsiz        addf] PL= lai   Inc)kenny2);
        wri            Inc(urec.upl] Ph=0 in  W   C   iBimodemurec.uploaW   C   :=CrgnuW   C    1ph=0 in  W   C   i
for cnt:=1 ts:=0;m','');
 ud.downloaded:=0;
     settimeleft(stahen Input := 'Z' ;
      telog(15,2,ud.numeleale       ud.sentby:=  miadssing(1in   IfIIn  R;L= adssi,a     ud.points:Protoco_in_Alea(a)modemurec.uploa
 wnloade
 			Wrielea m (Tn    in  
 			 inÚcincn  
 			 oÜoUddn     t 
 			nt(ks tit ;   seea.xAlearotoS,curelea:2,t ;]  zmo'Batc IfI,ename;
 			nt(ks tme;
 			    settimele
 			  ProÜoUr aE{B['+^V Writ;Rwriteurec;

          kenny1:=u	
 		] PxpElse
 ny2);     t 
 				p   txy(19 1p'y1:=u	
 			
     	
 			' ;

 			ds)tc			ds)tc		en begin;ing!');
   IscanProI  $,X=h   exec ('bimodemÚnÚnÚn        tch      Writest    );
      Writeln(^P'['^R'S'^ inÚcincn  k:=F: ');
    Iritescannea.xA
 Aleas...:=Pos(Zmodem,'YZGl) TheriteureX     athna.=Pos(Zmodembe  Ithnaed:=c.uploads);tegts:Pthnaednny2);
        wriritest    );= curelea for '^S+Utelog(15,2,ud.xt:eS);
adssi)e       ud.sentby:=  miadssing(1in   IfIIn  R;L= adssi,a     ud.points:Arotoco_in_Alea(a)modem wnloade
 			gts:Pthnaednny2);     t 
 			.p   txy(19 1p'y1:=u	
 		 Wrielea ritest    ,.pas1:=u	
 		 
     	
 		:');    	
 	Wrielea m (Tn    in  
 		 inÚcincn  
 		
        Z[ '';iteScannea....:=  Z] [ '';,Alea.NIfI,eS' ]rotoP,curelea,eS']y1:=u	
 	ts:Pthnaednny2);     t 
 			p   txy(19 1p'y1:=u	
 		 Wrielea ritest    ,.pas1:=u	
 		 
     ilename+^P' :'); for '^S+U+U+U  IscanU+U   	
 			
 	ts:Pthnaednny2);     t 
 			 			p   txy(19 1p'y1:=u	
 		 Wrielea ritest    ,.pas1:=u	
 		 
     	
 		:');    ot allowed withi	
 	ts:Pthnaednny2);     t 
 		.p   txy(19 1p'y1:=u	
 	 
     	
 	 ' ;

 	E);    	
p   txy(19 1p'y1:=untby:=  ielea ritest    ,.pas1:=u0 then begin;ing!');
 ds)iteidlsedssinL=        1:=u0 th exit;
      ymodeTwo,
  s     WriteLn    ud.sentbyted:=now;
 f IfI,u   mioadssin   IfIIn     t  Twod.downloadeu   mioIn     t  T
  s ='LSDnleted? *'   t('bimo'USERS'adssin   IfII ud.fil('bimo'USERS.'adssin   IfII ready. Press [Ctrl-    (p=0      ,two)tot-.filp=0 'BBS'atwo)tot- (bisex,'Lsd.pth')w);
    'Sorry Cann a Pdd L.S.D. L;lEnd; Dirs ON-LINEme(Zmodem,ud Press [Ctrl-');
 d);
 
  d);
        addfI    W cled);=-1 ud.downloaded:=0;
 
      Ixt:excan''tsex openedInput = '' The   getfsi'Add alefOFFLINE]efy/N] ?
        addfilI  ye  ud.do
   n Input := 'Z' ;
      ,'YZGwritePin:=2:slenny1:=ud.path] PL= lai   Inc)kenny2);I      '0nleted? *'nÚc8  $,X=a:sle   Inc)os(Zmodem,'YZGwriteS oUr oefiR=No  ]ny1:=ud.pathe searchfili Inc(urec.upl,'YZGwritext:exP');wordefiR=No  ]ny1:=ud.pathe s)');L=i Inc(urec.upl,'YZGwriteS otseyefiR=''^R'eft)d);+']ny1:=ud.path] PL= lai   Inc)kenny2);I      eft)*configse_time-timel  Inc(urec.upltimepercentbac) div 1))
    End;


  Proced
    _OMated:=now;ect ','YZGwriteud);
     : &y1:=ud.pathe s;
        Inc(urec.upl,'YZGwriteSiteLGw L;quGwr only?ontinue:');
imr
  'Thacmod ye   ok:=F:  ssign ritesc.uploads);teg;
    end;

 Hrds);
  i;
 
     U
     sett6,8,f IfI Ionxitn;c8  $ading!');
  BufLds):=u0 th exifn     WriteLn  [','');=        WriteLn    ud.sentbyI   t h<AAAAA Writ BufLhen  ud.downloaded:=0;
 
     ded:=0;
 ('Only  BufLsxcan Pdd  cled onl   Input = '' Then Input := 'Z' ;
      ,'YZG    IAdd xt:e=Pos(Zmodem,'YZGwriteNIfI+,'')     clerot'^R''Batcx     dird);+']ny1:=ud.pathted:=now;
   Inc,,'');=   1:=ud.path   t'') = =nr aE{t = '' Thefn);= 'Batcx     dir + =   s [Ctrl-'
 dss)tel   fn);= t'') + =       ot allowI  oadssinn)modem wnloade T if exnt(kswriteCAAAArm: t'^R'fnd);+'efy/N]        addfilI  ye  ud.dods)iteidlsedssinL= *Z'+^W'];ds)tch>0 the
   wnloaded:=0;
 
      IDihfixt:excan''tsex openedInput = '' The   getfsi'Sti
 Add xt:eefy/N] ?
        addfilI  ye  ud.dods)iteidlsedssinL= (urec.uploads)=u0 then begin;ing!');
 ds)multiLhe cled:=u0 th exis,'');,'')ptes     WriteLniteshX=aioadssin   IfIIndummy P
 ddzipc   f:FiEˆI  $,X=  ffinfo:    se     ymode    ud.sentbyI   t h<AAAAA Writ BufLhen  ud.downloaded:=0;
 
     ('Only > a^ SYSOPSxcan Pdd  cledInput = '' Then Input := 'Z' ;
      ,'YZG    IAdd MultiLhe xt:es ByaW       =Pos(Zmodem,'YZGwriteS   se ,'')/                addf] PL= lai   Inc)kenny2);
        wris,'')    Inc(ur    addf] Ps,'')[L= lai s,''))]='\'nny2);dec s,'')[0]      addfAssign(f,s,'')+'\AAA       addfReWri(end;

 Hr] PIOReWultkenny2);wnloaded:=0;
 Close(end;

 Hrris,'')  s,'')+'\*.*'put := 'Z' ;
      ted:=now;
 s,'');,'')ptes,dummynd;

 Hrfin);rssis,'');$17,ffinfond;

 Hr] Pdoserror<>0     t  Ty2);
     ('=0  cled roÜoU!: *Z'+^W']E
 dss)tel   Wht:eedoserrorken       ud.sentby:=  
     for '^S+U+U+UdisplaydssinLfinfond;

 Hrodem,'YZGwriteAdd  cle [Y/n/x]?ontinue:');
teLniteshX=a ye   ok:=F: path   i Inc:=nr aE{BiteshX=a .pass:=d);
     ] PiteshX=:=d);
     ud.dods)iteidlsedssin L;L=    ,'')ptes,Lfinfo. IfII :=d);
     e
   ] PuL= lai   Inc)tot-AoR aUpCas
   Inc[1])='X: *Z'+^W'];
  bny2);
        wri
 Hrfin)ng(inLfinfonurec.uploads)=u0 then begin;ing!');
 setngef:=u0 th exin,qc ('bimodemÚnÚnÚnt;
      yemÚnÚning!');
  how
    ( exit;
    inue:');
    ud.sentbywi') udedosex,'Lsd.pth') inÚcincn  k:=F: 0;
 
     (t;J'[Fn   IfI
 ]:  zmodownloadeu  in   IfII,  k:=F: 0;
t;J'[subdir P'')]:  zmod   mioa  k:=F: 0;
t;J'[ByZGw ip:= ]:  zmod W cled);a  k:=F: 0;
t;J'[8  $,h elen]:  zmod     $,Xa  k:=F: 0;
t;J'[ud);
     ]:  zmod  ;
    a  k:=F: 0;
t;J'[      dOMat]:  zmod  ;  _OMateda  k:=F: 0;
t;J'[iteL Eni:= ]:  zmoye no( ssign ritI,  k:=F: 0;
t;J'[P');worde
 ]:  zmod s)');,  k:=F: 0;
t;J'[S oUi:=  oe]:  zmo bd-Ra(  k:=F: 0;
t;J'[SiteLGw ask]:  zmoye no( ss
  'ThacmoI,  k:=F: 0;
t;J'[UpOMatedsey]:  zmo bdtim,  k:=F: 0;
t;J'[dEnd L;cvde]:  zmodEndwrit
   I,  k:=F: 0;
t;J'[     L;cvde]:  zmo     rit
   I,t;Jinue:');
E); en begin;
 wnloaded:=0; rce L;Ln   umteCetnge       addf] Pnkenny2);
        wris mioadssin= (urec.uplR;L=        m;
 
     U
     sett6,4adssin   IfIIn     t   how
    (m;
 
     URepea=:=d);
   q:=m  u Ixt:excetnge ,'FCHANGE ,'QUDSNFPVBTAtinue:');
teCas
 q Of  k:=F: 0;
10:     t  L;L=         L;wnloadeeS oUr oefN=No O  ]',e searchfin   IfIIn     '^ist('bimode- bd-Ra('N't- (bise searchfil'nleted? *');););)');
 d);
     11:     t  L;L=         L;wnloadeeP');wordefN=No  ]'od s)');in   IfIIn     '^ist('bimode-)');,'N't- (bise s)');L='nleted? *');););)');
 d);
     2: L;wnloadeeupOMater',e seartimin   IfIIn    3:    ud.sentby:=  =0; rocetirceTpass:=d);
          L;wnloadeedd);
     'od  ;
     *Z'+^W'];
  bZ' ;
          4: L;ioa('siteLGw L;quGwr only',e se
  'ThacmoI;
          5: L;ioa('ign  cle (u  End;)',e sign ritI;
          6:istUt h>=AAAAA Writ BufLhen   (bis L;wnloadeein   IfI'adssin   IfII;
          7:istUt h>=AAAAA Writ BufLhen   (bis L;wnloadee mio'od   mioI;
          8: L; $,ee in:=2:slen'od     $,XI;
          9:    ud.sentby:=  =0;    getfsi'Cetnge xt:ee oefOFFLINE]e(y/N)?
        addfiladdfilI  ye  ud.do    ud.sentby:=  =0;     W cled);:=-1n   IfIIn     '^S+Ues)tch>0 th   '^S+Ue
 dss)tel            L; d);
        addfdfiladdfilI    W cled);=-1 ud.do,'YZGwriteNotice! udis  cle ilefOFFLINE]       addfiladdfZ' ;
        ds)tch>0 thU   l (q=for cnt:=1 s mioadssin= (urec.upl   ge        m;=u0 then begin;ing!');
 deletef:=u0 th exin,exec ('bimodemÚnÚnÚnfn     WriteLn  t;
      ymode  f:FiEˆI  $,X=wnloaded:=0; rce L;Ln   umtedelete       addf] Pnkenny2);
        wris mioadssin= (urec.uplR;L=        m;
 
     Ufrce L;L=    u   mioadssin   IfIIn     t  
     sett6,7,f= (urec.upl['+^V Writ;+'(t'^V+d  ;
    d);+')t'^Md);+'CAAAArm: xt:eet'^R'fnd);+'e?ontinue:');
ts:=0;ye  ud.do
        wriremovedssin=,.pas1:=u0 them,'YZGwriteEras
 dihfift:eet'^R'fnd);+'?ontinue:');
ts:=0;ye  ud.do
        wriAssign(f,f= (urec.uplEras
(en=u0 then begin;ing!');
 ki
ttimeleft(s exi        tch      Wm (Tnc ('bimodemÚnÚnÚnold IfI,ign=    P
 ddzipc     ud.sentbyw'YZGwriteudlete 'Bat #t'^R'wrir(curelea)d);+'e(t'^V+'Batc IfI+^W+')?ontinue:');
ts:=0;ye  ud.do
        wri
     sett6,2p'y1:=untby:=Close(      1:=untby:=old IfIL='Alea''wrir(curelea)nue:');
ts:CurrartCAAAerarce<>1  (bisOldNIfIL=OldNIfI+in +Srir(CurrartCAAAerarce      addfAssign(       CAAAAgSrittelumDi+old IfI (urec.uplEras
(      1:=untby:=telog(15,curelea ud.numeleal-1        ud.sentby:=ign=    =old IfI;
        old IfIL='Alea''wrir(cnt+for cnt:=1 '^istCurrartCAAAerarce<>1  (bisOldNIfIL=OldNIfI+in +Srir(CurrartCAAAerarce      addfdfAssign(       CAAAAgSrittelumDi+old IfI (urec.uplplR;=    u      ign=    (urec.uplplrceIOReWultd;

 Hrris miadssing(1+for cnt:=1 '^R;L= adssi,a     ud.poin  miadssing(1in   IfIIn     ge adssi,a put := 'Z' ;
        miadssinnumelealIn     t  Truncage adssi1:=untby:=  ielea 1,.pas1=u0 then begin	ing!');
  hnattimele		 exiMarkc ('bimodem
png!');
  hell hnauL=ft,Right:
      1:=ulabel=u0 tAgtir:=uvar=u0 tPivot:
      :=untbP,Q:
      :=untbtp1,.p2,.p3,.p4
      yemÚnÚ     t  L;L= P:=L=ft:=untby:=Q:=Right:=untby:=Pivot:=uL=ft+Right) div 2;
        mi u      pivot1:=untby:=r;L=        tp11:=u0 them,ht:eeP<=Qedo=u0 them     t  L;L=    mi u      pin   IfIIn r;L=        tp2in   IfIIn ,ht:ee(downloadetp2sin   IfII<downloadetp1sin   IfII rdosex,'Lsd.pth')t:=1 '^i
 p1:=u	
 		 Wrmi u      pin   IfIIn IfIIn r;L=        tp2in   IfIIn ');
 d);
    Wrmi u      qin   IfIIn Ifr;L=        tp3in   IfIIn If,ht:ee(downloadetp1sin   IfII<downloadetp3sin   IfII rdosex,'Lsd.pth')t:=1 '^ ;dec Q      addfdfiladdfiWrmi u      qin   IfIIn IfIIn Ifr;L=        tp3in   IfIIn If');
 d);
    istP>Q  (bis o oeAgtir:=u');
teLnip4=tp3:=u');
teLnip3=tp2;
      eLnip2=tp4
 d);
    Wrmi u      pin   IfIIn Ifw  ge        tp2in   IfIIn fiWrmi u      qin   IfIIn Ifw  ge        tp3in   IfIIn Ifi
 Pin   IfIIn Ifdec Q     		en begin;
  tAgtir:=ud.path   L=ft<Q   (bis hell hnaul=ft,Q      addfistP<Right  (bis hell hnauP,Right    en begin		    ud.sentbyw'YZG    ISort Alea'1:=u0 them,'YZGwriteCAAAArmefy/N]        addfts:=0;ye  ud.do
        wri
     sett6,6p'y1:=untby:=Markc=numuds-1n   IfIIn  ts:Mark<>0 ud.do    ud.sentby:=  w);
  (t;S'L.S.D. Super Sitedy Sort (tm)fi pnggites...       addfilad hell hnau0,melknd;

 Hrodem,'YZG  (t;S'('^P,melk,S')ift:e''s  hnaedInput = '' The 'Z' ;
    en begin	ing!');
 movedssieleft(s exi n,f=,old c ('bimodemÚnÚnÚn:=ign cledam,dambam, cledam,wtngbtng:any   WriteLn  ['darn:FiEˆI  $,X=  t;
      ymode    ud.sentbyold c,curelea
 
     Ufrce L;Ln   umtemove       addfts:fnkenny2);
        wri;I      'nleted? *'arce L;elea umleted? *ts:ankenny2);
        wri
     ('Movoad...       adds mioadssinf= (urec.upR;L=        m;
 
     U
     sett6,5adssin   IfIIn  		 removedssinf=,f.upl
 
      cledam:=GetFN    u  PmioadssFiEˆN    (urec.updambam  e  Pmio     adds ielea a=,.pas1:=u0 the   ge 'Currart Fre^ Space:  1:=u0 the
    fre^space('Batcx     dir1:=u0 the
    writePhysically move  (bift:ee oecorract 'Bat?onti leted? *ts:(dambam<>'Batcx     dir1nny2);I  ye  ud.do    ud.sentby:e  Pmio:='Batcx     dir      wri;ign cledam:=GetFN    u  PmioadssFiEˆN    (urec.uphen ec  L;env('come
  '),'/c Copyet' cledam+'e'+ign cledam+'e>.nul' in   IfIIn ,tngbtng:= cledamn   IfIIn Assign(darn,wtngbtngin   IfIIn I  oadssiign cledam1nny2);Eras
(darn)he
   wnloaded:=0;
 :e  Pmio:=dambamut = '' The 
     ('U)  h... Ba; errorInput = '' ThZ' ;
     Z' ;
      ds)dssinm;
 
     Us ielea old ,.pas1:=u0 them
     (tB'Do  .: *Z'+^Wen beginin;ing!');
 multmovedssieleft(s exi n,sf=,efn,f=,old c ('bimodemÚnÚnÚn:=ign cledam,dambam, cledam,wtngbtng:any   WriteLn  ['darn:FiEˆI  $,X=  t;
      ymode    ud.sentbyold c,curelea
 
     Ufrce L;Ln   umtesielt move       addfis:fnkenty2);
        wrii      'nleted? *'efrce L;Ln   umte oUrmove       addfts:efnkenny2);
        wri;I      'nleted? *'arce L;elea umleted? *ts:ankenny2);
        wrfelosfrcefne oeefnrdosex,'Lsd.pth's mioadssinf= (urec.upR;L=        m;
 
     U
      ('Movoade'+dssin   IfI+in..       addf
     sett6,5adssin   IfIIn    wriremovedssinf=,f.upl
 
      cledam:=GetFN    u  PmioadssFiEˆN    (urec.updambam  e  Pmio     adds ielea a=,.pas1:=u0 thew  ge 'Currart Fre^ Space:  1:e
    fre^space('Batcx     dir1:=u0 the
    writ^MePhysically move '+dssin   IfI+ie oecorract 'Bat?onti leted? *ts:(dambam<>'Batcx     dir1nny2);I  ye  ud.do    ud.sentby:e  Pmio:='Batcx     dir      wri;ign cledam:=GetFN    u  PmioadssFiEˆN    (urec.uphen ec  L;env('come
  '),'/c Copyet' cledam+'e'+ign cledam+'e>.nul' in   IfIIn ,tngbtng:= cledamn   IfIIn Assign(darn,wtngbtngin   IfIIn I  oadssiign cledam1nny2);Eras
(darn)he
   wnloaded:=0;
 :e  Pmio:=dambamut = '' The 
     ('U)  h... Ba; errorInput = '' ThZ' ;
     Z' ;
      ds)dssinm;
 
     Us ielea old ,.pas1:=u0 them,'YZG  (t;Ixt:exmoved.       add');
 d);
 
     (tB'Do  .: *Z'+^Wen begin	ing!');
 B'bimMoveele		 exi n,f=,old ,exec ('bimodem
 		ign cledam,dambam, cledam,wtngbtng:any   Wri
 		darn:FiEˆI   		t;
      y		    ud.		is:fcled)nb'bimkenty2);
     		arce L;elea umlet		is:ankenty2);
     		old c,curelea
 
		felog(15,1e oefcled)nb'bimedo=u		b   ud.			s ielea b'bim;  _[g(1].elea,f.upl
 
 		 i      'B'+B'bimD  _[C(1].FiEˆN   
 
 		 frce L;Ln   umtemove      		 is:fn<>0 ty2)   		 b   ud.			
     ('Movoad...     		 Wrmioadssinf= (ur		 R;L=        m;
 
			
     sett6,5adssin   IfIIn  		 removedssinf=,f.upl
 
		 fcledam:=GetFN    u  PmioadssFiEˆN    (ur		 Wambam  e  Pmio   		 Wrielea a=,F.upl
 
		    ge 'Currart Fre^ Space:  1:=u		 
    fre^space('Batcx     dir1:=u		 
    writePhysically move  (bift:ee oecorract 'Bat?onti let		 ts:(dambam<>'Batcx     dir1nny2);I  ye  ud.do    ud. 		 e  Pmio:='Batcx     dir    		 ign cledam:=GetFN    u  PmioadssFiEˆN    (urec.uphen ec  L;env('come
  '),'/c Copyet' cledam+'e'+ign cledam+'e>.nul' in   IfIIn ,tngbtng:= cledamn   IfIIn Assign(darn,wtngbtngin   IfIIn I  oadssiign cledam1nny2);Eras
(darn)he
   wnloaded:=0;
 :e  Pmio:=dambamut = '' The 
     ('U)  h... Ba; errorInput = '' ThZ' ;
     Z' ;
      ds)dssinm;
 
     Us ielea old ,.pas1:=u			
     (tB'Do  .: *Z 		en Ue
 ds				
      (tS'xt:eet'B'bimD  _[C(1].FiEˆN   +'en0;foundInput  		en beg 		cl   _b'bim;  _beg 	en begin	ing!');
 B'bimudlbeg s exiOld ,Fn,Cxec ('bimodem
 	 t;
      y
 	 F:FiEˆI   o    ud. 	sOldN:=CurAlea
 
		 I  FiEˆsInB'bimkenty2);E
     		=teloC(15,1e oeFiEˆsInB'bim    y
 	     ud. 			
   Sriteudlete xt:eet'B'bimD  _[C(1].FiEˆN   +'?ontinue 			I  ye  td.do    ud. 			;I      'B'+B'bimD  _[C(1].FiEˆn   
 
 			 SriAlea(B'bimD  _[C(1].Alea,f.upl
 
 			=tn:=GetFiEˆNumteB'bimudltinue 			 I  Fn<>0 ty2)o    ud. 			;SrmiU)dssinFninue 			 R;L= U)dssi,U;
 
				 I  EadssiGetF=    U  PmioaUssFiEˆN    ) ty2)   		 	     ud. 					    geSrit^MePhysically '+GetF=    U  PmioaUssFiEˆN    +'?ontinue 					 I  Ye  td.due 						     ud. 							 Assign(F,GetF=    U  PmioaUssFiEˆN    )nue 							 Eras
(F)nue 						 Z' ;
						 Z' ;
						 RemoveFssinFn,.pas1:=u						    geLsett6,7,UssFiEˆN    
 
				 Z' ;
        ds)
 
			ds)
 
			Cl   _B'bimD  _   		=en begin	ing!');
 rˆn   dssieleft(s exif c ('bimodemÚnÚnÚnt;
      ymode  f:FiEˆI  $,X=wnloaded:=0; frce L;Ln   umterˆn          addfts:fnkenny2);
        wris mioadssinf= (urec.uppR;L=        m;
 
     U
    writeE('br ign in   IfI        addfts:m'bim(I    adssin   IfII     t  Td.due:=0;
 :e  in   IfI =I    put := 'Z
   I  L=ngtm(I    )>0ue:=0;
 :ny2);I  validL=    I    )t = '' The 'ny2);I  oadssi L;L=    u   mioaI    ))t = '' The '  Td.due:=0;
 :' The 
     ('N    alr;L=yfi use!: *Z'+^W        d
 ds:=0;
 :' The     ud.sentby:=     wriAssign(f, L;L=    u   mioadssin   IfIIin   IfIIn IfIIn IflR;=    f, L;L=    u   mioaI    ))n   IfIIn IfIIn IflI  IOReWultkenny2);    ud.sentby:=     wri :e  in   IfI =I    n   IfIIn IfIIn Ifl
 
     (tBt;Ixt:exrˆn   d.: *Z'+^W'+^W        dn UZ
   
     (tBt;IUnab:ee oerˆn    in  !: *Z'+^W          dn t = '' The 'Z
   
     ('Invalid in   IfIInput = '' Ts mioadssinf= (urec.uppW  ge        m;*Z'+^Wen begin;ing!');
 ldssx     eleft(s exiexec ('bimodem wri :e:user     ymode    ud.sentbySrmi u     11:=u0 them
     ('N     IfIIn IfIIn Ifl
 
 
 
 
Lvl Pts'^M1:=untby:=telog(15,1 ud.numusers        ud.sentby:=R;L=       m)n   IfIIn II  u.handle<>'' Td.due:=0;
 :' I  u.udlevel>0 ud.do    ud.sentby:=     ab(u.handle,30)n   IfIIn IfIIn ab(wrir(u.udlevel),4)n   IfIIn IfIIn
     (u.udpo
  lIn     t  
 :' I  br;Lknny2);
  t = '' The 'Z' put := 'Z' *Z'+^Wen begin;ing!');
 reordereleaseleft(s exinume,cure ignac ('bimodem wri :a1,a2:elea     ymode  f1,f2:FiEˆI  $,X=  fn1,fn2:s   WriteLnLabel;
        w    ud.sentbyw'YZG sett6,9p'y1:=untby:=w'YZG    IRe-order Aleasy1:=untby:=nume:=FiEˆSize adssi1:=untby:=
     ('Number of 'Bats:  ,nume1:=untby:=telogure:kennd.numa-2        ud.sentby:=R;pea t = '' The '
    writeNgn 'Bat #'+^V+wrir(gure+1)+^P+'e[?=Ldss, CRe oequit]        addf :' I  L=ngtm(I    )kenny2);Gond.
        wri;IflI  I    ='?'t = '' The 'ny2)     t  
 :'     ud.sentby:=     wldsseleaseleft(s(s(s(s(s(signac=-1*Z'+^W        dn t = '' The 'Z
       t  
 :'     ud.sentby:=     wignac=valu(I    )-1n   IfIIn  ri;IflI  iigna<0) Or iigna>nume1nny2);    ud.sentby:=     wri
     ('N0;foundI;il  s
 re-e('br...       addfilad(s(s(signac=-1*Z'+^W          dn t = '' The '  dn t = '' TheUntil iigna>=0)n   IfIIn Iis:igna,cure ty2)o
     (t;S'S    in   'Bat asogurrartly is, skippoadethis 'Bat.. ^M1   IfIIn Ie
   wnloaded:=0;
 Srmi adssi,cure)n   IfIIn IR;L= adssi,a11:=u0 them
 Srmi adssi,igna)n   IfIIn IR;L= adssi,a2in   IfIIn fSrmi adssi,cure)n   IfIIn IW  ge adssi,a2in   IfIIn fSrmi adssi,igna)n   IfIIn IW  ge adssi,a11:=u0 them
 fn1  'Alea':=u0 them
 fn2cefn1+wrir(igna+11:=u0 them
 fn1  fn1+wrir(gure+1)n   IfIIn Iis:CurrartCAAAerarce<>1 ty2)o    ud. IfIIn IFn2ceFn2+in'+Srir(CurrartCAAAerarce)n   IfIIn IFn1  Fn1+in'+Srir(CurrartCAAAerarce)n   IfIIn IZ' ;
        Assign(f1,CAAAAgSri.telumDi+fn1)n   IfIIn IAssign(f2,CAAAAgSri.telumDi+fn2in   IfIIn fR;=    f1,'Temp$$$$       addfilR;=    f2,fn1)n   IfIIn IR;=    f1,fn2i   IfIIn IZ' ;
      Z' ;

  : 
     Us ielea 1,.pas1*Z'+^Wen begin;ing!');
 ign cledeleft(s exi ,f=,u c ('bimodemÚnÚnÚnt;
      ymode  e:user     ymode  krad:l   WriteLn  flag,abhnaed:Bool  nbegin;;ing!');
 
    
      ymode      ud. IfIIn Is mioadssinf= (urec.uppppW  ge        m;*Z'+^W^Wen begin;;ing!');
 ratedssinpc ('bimo (urec.upp    ud. IfIIn Iu   o
  l:=p(urec.uppppu  ign cle  F.upl(urec.uppppu  wy2)rated:=now(urec.upppp
    
      ymode    p:=p*cAAAAgs i.uploadfacton   IfIIn II  p>0 ud.do    ud.sentby:=  W    writeActually give user How:m'ny pts? ['+^V+wrir(p)+^P+']         addf :' I  I    =''nny2);E
   I  (valu(I    )>0) Or iI    ='0'1nny2);pc=valu(I    )     addf :' u c=lookupuser u  sartby      addf :' I  unket = '' The 'ny2);
     (u  sartby,' hasovanished!: *Z'+^W      e
   wnloaded:=0;
 :wri
     ('Givoade',u  sartby,' ',p,'  o
  l.       addfilad(sI  unkunum'ny2);
    
     ymode    ntbySrmi u     u= (urec.uppppby:=R;L=       m)n   IfIIn I :' u.udpo
  l  e.udpo
  l+p(urec.uppppntbySrmi u     u= (urec.uppppby:=W  ge       m)n   IfIIn I :' I  unkunum'ny2);r;L=
   t = '' The 'Z' put := ' 'Z' put := 'Z' begin;;ing!');
 doelea
 
     U exii,advance: ('bimodemÚnÚnÚn:=do  :Bool  nbegec.upp    ud. IfIIn Ifrce1n   IfIIn  advance:=0(urec.uppppWhn   fn+advance<=numuds        ud.sentby:= Ifrcefn+advancen   IfIIn I :advance:=1n   IfIIn  ris mioadssinf= (urec.uppppppR;L=        m;
 
     U :' I  u  ign clenny2);    ud.sentby:=    flag  F.upl(urec.uppppÚn:=do  : F.upl(urec.uppppÚn:=R;pea  cl   scodemÚnÚnÚn:=de    pr
  xy 1,1p'y1:=untby:=In Ifl
 
     (tBt;I[FiEˆn   l
 ]  ,upwrioad(dssin   IfII,=untby:=In Ifl
 t;I[SubDir Pmio]  ,u   mioa=untby:=In Ifl
 t;I[Uploaded by]  ,u  sartby,=untby:=In Ifl
 t;I[xt:exSize
 ]  ,ussin  size,=untby:=In Ifl
 t;I[Descoiption]  ,ussdescoip1:=untby:=In Ifl
 i:=m  uteNgnscan','NEWSCAN','Q#_CEDRM0Vy1:=untby:=In Ifl
 I      ' '+wrir(f= (urec.upppppp :' I  i<et = '' The ' '  Td.due:=0;
 :' The e     ud.sentby:=     wri  ratedssin-i      addfilad(s(s(s:=do  : Tpas*Z'+^W'+^W        dn *Z'+^W          d
 ds:=0;
 :' The   C s
 i Of    addfilad(s(s(s:=1:    ud.sentby:=     wri   I :abhnaed: Tpas     addfilad(s(s(s:=uphen   t = '' The '^W        dn      addfilad(s(s(s:=3:do  : Tpas     addfilad(s(s(s:=4:    ud.sentby:=     wri   I :
    writeE('br ign descoiption        addf :' .upppppp :' I  L=ngtm(I    )>0nny2);ussdescoip =I    n   IfIIn IfIIn Ifl
 pppp
    
    t = '' The '^W        dn      addfilad(s(s(s:=5:    ud.sentby:=     wri   I :rˆn   dssieleft(sby:=     wri   I :advance:=0t = '' The '^W        dn      addfilad(s(s(s:=6:    ud.sentby:=     wri   I :ddletefeleft(sby:=     wri   I :advance:=0t = '' The '^W        dn      addfilad(s(s(s:=7:ldsselchiveele  addfilad(s(s(s:=8:    ud.sentby:=     wri   I :movedssieleft(sby:=     wri   I :advance:=0t = '' The '^W        dn      addfilad(s(s(s:=9:    ud.sentby:=     wri   I :ratedssin0)n   IfIIn IfIInad(s(s(s:=do  : Tpas*Z'+^W'+^W            dn *Z'+^W            dn *Z'+^W        Until do   Or iadvance=0)t = '' The 'Z' put := ' 'Z' put := 'Z' begin;;wnloaded:=0; flag  Tpas     addfw'YZG sett6,1p'y1:=untby:=I  issysopnny2);    ud.sentby:=
    writeNgnscan all 'Bats?ontinuepppp :' I  ye  ud.do    ud.= '' The 'teloa5,1 ud.num'Bats        ud.sentby:= I Us ielea a,.pas1:=u   wri   I :abhnaed: F.upl(urec.uppppÚn:=doelea
 
     Upp :' I  abhnaednny2);
  t = '' The 'Z' put := '  dn UZ
   doeleaput := 'Z' UZ
   doelea     addfts:flag'ny2);
     (tB'No ign in  s.: *Z'+^Wen begin;ing!');
 sysopcomm'nddeleft(s exii: ('bimodemÚnÚn    ud.sentbyts:N0;sponsoron ud.do    ud.= '' Thereqlevel(cAAAAgs i.sysopleve1:=u   wri  
  t = '' Tdn      addfw'YZG sett5,3,'Bat.n    (urec.uphR;pea t 				i:=m  utext:exsponsor','FSYSOP','A@CDF@G@KRNSMLO@QEWX+Z*@tinuepppp :' C s
 i Of    addfilad1:sysopds)
 
     Upp :2:changefeleft(sby:=  3:ddletefeleft(sby:=  4:di   toryeleft(sby:=  6:killelea
 
     Upp :7:   elea
 
     Upp :8:ign cledeleft(s(s(s:=9:sortelea
 
     Upp :10:movedssieleft(sby:=  11:ldssx     eleft(sby:=  12:reordereleaseleft(sby:=  14:rˆn   dssieleft(sby:=  15:ds)multiple cledele					17:
     (t;S'Sorry, tya  function is temporelily offlineInput  				19:g ieleaut  				16:multmovedssiele 				18:    ud.						 Cl   Scodem
 				    geH   IB'bim Comm'nddtinue 					 
     (tS'[1] '^R'Move B'bim Quetinue 					 
     (tS'[2] '^R'udlete  cledfi B'bim Quetinue 					 
   Srit^M^P'Whnch:tinue 					 C s
 Valu(I    ) ofue 						 1: 'bimMovenue 						 2:B'bimudl;
						 Z' ;
					Z' ;
				Z' put := 'Until hungupon Or ii=13 *Z'+^Wen begin;ing!');
 b'bim_m  ueleft(s exii: ('bimodemÚnÚn    ud.sentbyW'YZG    IB'bim TransAer M  utinuepppp :R;pea t = '' Thei:=m  uteB'bim XAer','FBATCH','CLDUQAXtinuepppp :' C s
 i Of    addfilad1:b   ud.sentby:=     cl   _B'bimd  _   IIn Ifl
 pppp
    l (t;'B'bim Que 'nd Bi-M     Que Cl   ed!:    IIn Ifl
 ppppen      addfilad2:ldssb'bimeleft(sby:=  3:do_b'bim_d  _load;
					4:if 'Bat.uploadhera=.pas ty2)o 'bim_UploadIe
  ue 					 
     (t;S'You:m'y n0;uploade oethis 'Bat!'^M1:=untby:=:=  6:bi     upload
 
     Upp :7:DOBIXFERn   IfIIn IZ' put := 'Until hungupon Or ii=5 *Z'+^Wen begin; exii: ('bimodemÚnÚna:elea     ymodems:Bool  nbegec.utaxz:bool  nbegec.utzz:M   WriegecLabel;ok,
           ud.sekillbi          cl   _b'bimd  _   IIn gursection  edsysop  ymodems: F.upl(urec.uppW  ge ^R1:=untbyI      '':=u0 thTzz:='eleadi ':=u0 this:CurrartCAAAerarce<>1 ty2)oTzz:=Tzz+in'+Srir(CurrartCAAAerarce)n   IfIAssign(adssi,CAAAAgSri.telumDi+tzz1:=untbyI  oadssiCAAAAgSri.telumDi+tzz1=u0 thTd.due:=0;
    ud.sentby:=R;s i adssi1:=untby:=byI  FiEˆSize adssi1>0nny2);Gond.okput := 'Z' *Z'+^We
   Rew  ge adssi1:=untby
     ('N0 FiEˆ 'Bats Eadss!!:    IIn 'Bat.x     di :=cAAAAgs i.felumdi+'XMODEM\':=u0 thI  issysop=u0 thTd.dhI  makeeleaput := 'ny2);Gond.ok:=u0 thGond.
     ok: 
    s miadssi(1)n   IfIR;L= adssi,a1:=untbyI  N0;(Allowed_in_Alea a)1nny2);    ud.sentby
     (tS'You:do n0;have accesse oeth  in   section!:    IIn IfGond.
  *Z'+^Wen bIis:i0;pcratio ty2)ob   ud.sentbpr
  xy 21,0p'y1:=untby:
    l ('Your Post/Call Ratio is out of line.fGoe oeth  messag
 b'sedf'nd POSTy1:=untby:
    l ('som  messag
dfi order  oecor   tethis!:    IIn Igotd.
        wren      adyouredstatuseleft(sbi  oadssicAAAAgs i.textin  di+'FiEˆngns.BBS'1nty2)ob   ud.sentbbufEˆn:=0(urec.up
    writ^P'PresseReturn  oecontinue.ntinuepppp pr
  dssi(cAAAAgs i.textin  di+'FiEˆngns.BBS'1      wren      ad load_protdseleft(sbs ielea 1,.pas1eleft(sbi  cAAAAgs i.sh  _ewpromptsnty2)ob   ud.sentb
   Srit'Scan fel ign in  s? [N]        addI  Yesnty2)oNgnScanAll      wren      ad :R;pea t = '' TheI  withintimi(cAAAAgs i.x     clos iim,cAAAAgs i.x     opentim) or itimitillnet<301nny2) 
     U :' I  N0;issysopnny2);    ud.sentby:=t(sbi  timitillnet<30nty2)otzz:=cAAAAgs i.netarcIe
   tzz:=cAAAAgs i.x     opentim   IIn Ifl
 ppp
    writ^Mt;'Fn   section is clos d atethis timi!:    IIn Ifl
 ppp
     ('ny2 timi is nowppp: '^S,timiwritnow)    IIn Ifl
 ppp
     ('FiEˆ 'Bat opendf't: '^S,tzz1:=untbybybybybyGond.
  *Z'+^Wt := 'Z' UZ
   I  N0;m  ud.do    ud.= '' The 'pp
     ('ny2 FiEˆ 'Bat is clos d until ',cAAAAgs i.x     opentim):=untbybybybybyms: Tpas*Z'+^W'+^W  dn      addfilI   ((vt52fi 
   .cAAAAg) or iansigraphncsyI  
   .cAAAAg)1nny2);    ud.sentbydfilI  WheraY>21nny2);    ubpr
  xy 24,1p'y1:
     (tBt;^M1:dn      addfiladpr
  xy 22,1p'y1:=untby:=InW  ge ^B^S,'Bat.n   ,^R' ['^S,gureBat,^R']'1nZ' UZ
  d.sentby:=  W      (tBt;^M^S,'Bat.n   ,^R' ['^S,gureBat,^R']'1     addfiladi:=m  utext:e','FILE','UDLFYA!SQ%NVHRXWT+BG*Itinuepppp :' I  hungupon ny2);Gond.
        wr:' C s
 i Of    addfilad1:upload
 
     Upp :2:d  _load(0p'y,0)n   IfIIn IfI3,4:ldssin  s(F.uplinue 				5:youredstatusele 				21,6:g ieleaut      Upp :8:seelch
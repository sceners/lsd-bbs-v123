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
      writeln (^P'旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컫컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴컴컴커');
			writeln (^P'� '^S'File Name'^P'                      � '^S'Bytes'^P'   �'^S'  Points'^P'    �'^S' Minutes'^P'    �');
      writeln (^P'쳐컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컵컴컴컴컴컵컴컴컴컴컴컴탠컴컴컴컴컴캑');
        For cnt:=1 To FilesInBatch Do begin
          Write (^P'�  '^S);
          Tab(Upstring(BatchDown[Cnt].FileName),30);
          Write (^P'� '^S);
          TempK:=BatchDown[Cnt].Size Div 1024;
          TotK:=TotK+TempK;
          Tab(StrLong(BatchDown[Cnt].Size),8);
          Write (^P'� '^S);
          Tab(Strr(BatchDown[Cnt].Points),11);
          Write (^P'� '^S);
          Tab(Strr(BatchDown[Cnt].Mins),11);
          writeln (^P'�');
          if Break then Exit;
	      End;
      writeln (^P'읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컨컴컴컴컴컨컴컴컴컴컴컴좔컴컴컴컴컴켸');
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
    Var cnt:Integer;
			searchall:Boolean;
			found:boolean;
			wildcard:sstr;
			a:arearec;

    Procedure searcharea;
      Var cnt:Integer;
        u:udrec;
        po:integer;
        krad1,krad2,krad3,krad4,krad5:anystr;

      function stringit(l1,l2:anystr):anystr;
      var l3,l4:anystr;
          t1,t2:anystr;
      begin
       po:=pos(l1,upstring(l2));
       l3:=l2;
       if po>0 then begin
         l3:=copy(l2,0,po-1);
         l3:=l3+^S+l1+^U;
         l3:=l3+copy(l2,length(l3)-1,(length(l2)-(length(l3)-2)));
         end;
       stringit:=l3;
       end;

      procedure listfiles(n:integer;extended:boolean;k1,k2,k3,k4:anystr);
      var ud:udrec;
          q:sstr;
          path,filez:anystr;
          sze:longint;
          ofline:boolean;
      begin
           seekudfile(n);
           read(udfile,ud);
           filez:=getfname(ud.path,ud.filename);
           ofline:=(exist(filez))=false;
           write(' ');
           write(^P);tab(strr(n)+'.',4);
           write(^U);po:=8;
           if pos(^S,k2)>0 then po:=10;
           tab(k2,po);po:=4;if pos(^S,k4)>0 then po:=6;
           write(upstring(k4):po,'  ');
           write(^R);
           if (ud.sendto='') then
             if ud.newfile then write(' New   ') else if ud.specialfile then
                                write(' Ask   ') else if (ud.points>0) and (not configset.leechwee)
                                then write(ud.points:4,'   ')
                                else write(' Free  ')
                                else begin ansicolor(4);
                                if match(ud.sendto,urec.handle) then write(' Take  ') else
                                write(' Priv  ');end;
                                ansicolor(13);
                                if not exist(ud.path+ud.filename) then tab('[Offline]',10) else begin
                                sze:=ud.filesize;
                                if sze<1024 then sze:=1025;
                                write(strlong(sze div 1024)+'k':9,' ');
                                end;
                                write(^U);
                                if k3='' then k3:='- No Description Given-';
                                po:=39; if pos(^S,k3)>0 then po:=41;
                                writeln(' ',copy(k3,1,po));
                                end;
      Begin
        For cnt:=1 To numuds Do Begin
          seekudfile(cnt);
          Read(udfile,u);
          krad1:=upstring(wildcard);
          fsplit(U.filename,u.path,krad2,krad4);
          krad3:=u.descrip;
          krad2:=stringit(krad1,upstring(krad2));
          krad3:=stringit(krad1,krad3);
          krad4:=stringit(krad1,upstring(krad4));
					If ((Pos(krad1,krad2)>0) Or (Pos(krad1,krad3)>0)) or ((pos(krad1,krad4)>0))
					Then
						begin
						 listfiles(cnt,False,krad1,krad2,krad3,krad4);
						 found:=true;
						end;
          If xpressed Then exit
        End
      End;

    Begin
     Writehdr('File Search');
      writestr('Search all areas [y/N]? *');
      searchall:=yes;
      Writeln (^M^S'Do NOT use wildcards!');
      writestr(^M^P'TEXT to search for :');
      If Length(Input)=0 Then exit;
      wildcard:=Input;
      If Pos('.',WildCard)>0 Then
        WildCard:=Copy(WildCard,1,Pos('.',WildCard)-1);
      If Not searchall Then Begin
        searcharea;
        exit
      End;
      For cnt:=1 To numareas Do Begin
        seekafile(cnt);
        Read(afile,a);
        If allowed_in_Area(a) Then
          Begin
						setarea(cnt,false);
						clearscr;
						found:=false;
						writeln(^R'Searching Area ['^S,curarea:2,^R'] '^S,area.name,^R);
						writeln;
						searcharea;
						if found then writestr(^M^R'Press [Return] to continue:');
						If xpressed Then begin
							printxy(19,1,'');
							exit;
							end;
					End
			End
		End;

  Procedure newscanall;
    Var cnt:Integer;
      a:arearec;
      start_area : integer ;
    Begin
    clearscr;
      Writehdr(' Newscanning All Areas... ');
      writeln(^B'Press [X] to Abort.');
      beenaborted:=False;
      If aborted Then exit;
      start_area := curarea ;
      For cnt:=1 To FileSize(afile) Do Begin
        seekafile(cnt);
        Read(afile,a);
        If Allowed_in_Area(a) Then Begin
						 If aborted Then begin
						 printxy(19,1,'');
						 setarea(start_area,true);
						 exit;
						 end ;
					setarea(cnt,false);
					clearscr;
					WriteLn(^S'[ '^P'NewScanning... '^S'] [ '^P,Area.Name,^S' ] ['^P,curarea,^S']');
					If aborted Then begin
						printxy(19,1,'');
						 setarea(start_area,true);
						 exit;
             end ;
          newscan   ;
										If aborted Then begin
										printxy(19,1,'');
						 setarea(start_area,true);
						 exit;
						 end ;

        End;
				If aborted Then begin
					 printxy(19,1,'');
					 exit;
					 end;
			End ;
			printxy(19,1,'');
      setarea(start_area,true);
    End;

  Procedure addresidentfile(fname:lstr);
    Var ud:udrec;
    Two,Times:lstr;
    Begin
      getpathname(fname,ud.path,ud.filename);
      Two:=upstring(ud.path);
      Times:='LSD';
      if (match('USERS',ud.filename) ) or (match('USERS.',ud.filename)) then exit;
      if  (pos(times,two)>0) or (pos('BBS',two)>0) then begin
      writeln ('Sorry Cannot add L.S.D. related Dirs ON-LINE!');
      exit;
      end;
      getfsize(ud);
      If ud.filesize=-1 Then Begin
        WriteLn('File can''t be opened!');
        Writestr('Add as [OFFLINE] [y/N] ? :');
        If yes Then Else exit
      End;
      writestr('Point value:');
      If Length(Input)=0 Then Input:='0';
      ud.points:=valu(Input);
      writestr('Send to [CR=None]:');
      ud.sendto:=input;
      writestr('File Password [CR=None]:');
      ud.pass:=input;
      writestr('Sent by [CR='+^S+unam+^P+']:');
      If Length(Input)=0 Then Input:=unam;
      ud.sentby:=Input;
      ud.when:=now;
      ud.whenrated:=now;
      ud.downloaded:=0;
      writestr('Description: &');
      ud.descrip:=Input;
      writestr('Special request only? *');
      ud.specialfile:=yes;
      ud.newfile:=False;
      inc(gnuf);
      addfile(ud);
      writelog(16,8,fname)
    End;

  Procedure sysopadd;
    Var fn:lstr;
        path,name:lstr;
    Begin
      If ulvl<configset.sysopleve Then Begin
        WriteLn
        ('Only sysops can add files online!');
        exit
      End;
      writehdr('Add File');
      writestr('Name+path of file ['+^S+area.xmodemdir+^P+']:');
      getpathname(Input,path,name);
      if path = '' then
        fn := area.xmodemdir + name
      else
        fn := path + name ;

      If exist(fn) Then Begin
        writestr('Confirm: '+^S+fn+^P+' [y/N]:');
        If yes Then addresidentfile(fn)
        End
      Else Begin
        WriteLn('Disk File can''t be opened!');
        Writestr('Still Add File [y/N] ? :');
        If yes Then addresidentfile(fn);
        End
    End;

  Procedure addmultiplefiles;
    Var spath,pathpart:lstr;
    tarshit:boolean;
      dummy:sstr;
      f:File;
      ffinfo:searchrec;
    Begin
      If ulvl<configset.sysopleve Then Begin
        WriteLn('Only True SYSOPS can add files!');
        exit
      End;
      writehdr('Add Multiple Files By Wildcard');
      writestr('Search path/wildcard:');
      If Length(Input)=0 Then exit;
      spath:=Input;

      If spath[Length(spath)]='\' Then dec(spath[0]);
      Assign(f,spath+'\con');
      Reset(f);
      If IOResult=0 Then Begin
        Close(f);
        spath:=spath+'\*.*'
      End;
      getpathname(spath,pathpart,dummy);
      findfirst(spath,$17,ffinfo);
      If doserror<>0
      Then WriteLn('No files found!')
      Else
        While doserror=0 Do Begin
          WriteLn;
          displayfile(ffinfo);
          writestr('Add file [Y/n/x]? *');
          tarshit:=yes;
          if input='' then tarshit:=true;
          If tarshit
          Then addresidentfile(getfname(pathpart,ffinfo.name))
          Else If (Length(Input)>0) And (UpCase(Input[1])='X')
            Then exit;
          findnext(ffinfo)
        End
    End;

  Procedure changef;
    Var n,q:Integer;
      ud:udrec;

    Procedure showudrec(Var ud:udrec);
      Begin
      with ud do begin
      clearscr;
           WriteLn(^M^J'[Filename   ]: '^S,upstring(ud.filename),
          ^M^J'[subdir Path]: '^S,ud.path,
          ^M^J'[Bytes long ]: '^S,ud.filesize,
          ^M^J'[point Value]: '^S,ud.points,
          ^M^J'[Description]: '^S,ud.descrip,
          ^M^J'[times dload]: '^S,ud.downloaded,
          ^M^J'[New rating ]: '^S,yesno(ud.newfile),
          ^M^J'[Password   ]: '^S,ud.pass,
          ^M^J'[Sending to ]: '^S,sendto,
          ^M^J'[Special ask]: '^S,yesno(ud.specialfile),
          ^M^J'[Uploaded by]: '^S,sentby,
          ^M^J'[date recvd ]: '^S,datestr(when),
          ^M^J'[time recvd ]: '^S,timestr(when),^M^J);
      End end;

    Begin
      n:=getfilenum('Change');
      If n=0 Then exit;
      seekudfile(n);
      Read(udfile,ud);
      writelog(16,4,ud.filename);
      showudrec(ud);
      Repeat
        q:=menu('File change','FCHANGE','QUDSNFPVBTA');
        Case q Of
          10:begin
             getstring('Send to [N=No One]',ud.sendto);
             if match(ud.sendto,'N') then ud.sendto:='';
             end;
          11:begin
             getstring('Password [N=None]',ud.pass);
             if match(ud.pass,'N') then ud.pass:='';
             end;
          2:getstring('uploader',ud.sentby);
          3:Begin
              nochain:=True;
              getstring('description',ud.descrip)
            End;
          4:getboo('special request only',ud.specialfile);
          5:getboo('new file (unrated)',ud.newfile);
          6:if Ulvl>=configset.sysopleve then getstring('filename',ud.filename);
          7:if Ulvl>=configset.sysopleve then getstring('path',ud.path);
          8:getint('point value',ud.points);
          9:Begin
              Writestr('Change File to [OFFLINE] (y/N)? :');
              If yes Then Begin
                ud.filesize:=-1;
                end
              else
                getfsize(ud);
                If ud.filesize=-1 Then writestr('Notice! This file is [OFFLINE]');
            End;
        End
      Until (q=1);
      seekudfile(n);
      Write(udfile,ud)
    End;

  Procedure deletef;
    Var n,cnt:Integer;
      fn:lstr;
      ud:udrec;
      f:File;
    Begin
      n:=getfilenum('delete');
      If n=0 Then exit;
      seekudfile(n);
      Read(udfile,ud);
      fn:=getfname(ud.path,ud.filename);
      writelog(16,7,fn);
      writestr(^P+'('+^V+ud.descrip+^P+')'+^M+^P+'Confirm: File '+^S+fn+^P+' ? *');
      If Not yes Then exit;
      removefile(n,true);
      writestr('Erase disk file '+^S+fn+^P+'? *');
      If Not yes Then exit;
      Assign(f,fn);
      Erase(f)
    End;

  Procedure killarea;
    Var a:arearec;
      cnt,n:Integer;
      oldname,newname:sstr;
    Begin
      writestr('Delete area #'+^S+strr(curarea)+^P+' ('+^V+area.name+^W+')? *');
      If Not yes Then exit;
      writelog(16,2,'');
      Close(udfile);
      oldname:='Area'+strr(curarea);
      If CurrentConference<>1 then OldName:=OldName+'.'+Strr(CurrentConference);
      Assign(udfile,ConfigSet.ForumDi+oldname);
      Erase(udfile);
      For cnt:=curarea To numareas-1 Do Begin
        newname:=oldname;
        oldname:='Area'+strr(cnt+1);
        if CurrentConference<>1 then OldName:=OldName+'.'+Strr(CurrentConference);
        Assign(udfile,ConfigSet.ForumDi+oldname);
        Rename(udfile,newname);
        n:=IOResult;
        seekafile(cnt+1);
        Read(afile,a);
        seekafile(cnt);
        Write(afile,a)
      End;
      seekafile(numareas);
      Truncate(afile);
      setarea(1,true)
    End;

	Procedure sortarea;
		Var Mark:Integer;

procedure shellsort(Left,Right:integer);
label
   Again;
var
   Pivot:integer;
   P,Q:integer;
   tp1,tp2,tp3,tp4:udrec;

   begin
      P:=Left;
      Q:=Right;
      Pivot:=(Left+Right) div 2;
      seek(udfile,pivot);
      read(udfile,tp1);
      while P<=Q do
      begin
       seek(udfile,p);
       read(udfile,tp2);
       while (upstring(tp2.filename)<upstring(tp1.filename)) do begin
             inc(p);
						 seek(udfile,p);
             read(udfile,tp2);
       end;
         seek(udfile,q);
         read(udfile,tp3);
         while (upstring(tp1.filename)<upstring(tp3.filename)) do begin
               dec(Q);
               seek(udfile,q);
               read(udfile,tp3);
         end;
         if P>Q then goto Again;
         tp4:=tp3;
         tp3:=tp2;
         tp2:=tp4;
         seek(udfile,p);
         write(udfile,tp2);
         seek(udfile,q);
         write(udfile,tp3);
         inc(P);
         dec(Q);
			end;

      Again:
      if Left<Q  then shellsort(left,Q);
      if P<Right then shellsort(P,Right);
end;

		Begin
      writehdr('Sort Area');
      writestr('Confirm [y/N]:');
      If Not yes Then exit;
      writelog(16,6,'');
      Mark:=numuds-1;
        If Mark<>0 Then Begin
          writeln(^M^S'L.S.D. Super Speedy Sort (tm) in progress...');
          shellsort(0,mark);
          writeln(^M^S'('^P,mark,^S') file''s sorted!');
          End;
    End;

	Procedure movefile;
    Var an,fn,oldn:Integer;
        newfilesam,sambam,filesam,wangbang:anystr;
        darn:File;
      ud:udrec;
    Begin
      oldn:=curarea;
      fn:=getfilenum('move');
      If fn=0 Then exit;
       Input:='';
      an:=getareanum;
     If an=0 Then exit;
      WriteLn('Moving...');
     seekudfile(fn);
     Read(udfile,ud);
      writelog(16,5,ud.filename);
		 removefile(fn,false);
     filesam:=GetFName(ud.Path,ud.FileName);
     sambam:=ud.Path;
     setarea(an,true);
     Write('Current Free Space: ');
     writefreespace(area.xmodemdir);
     writestr('Physically move the file to correct area? *') ;
     If (sambam<>area.xmodemdir) Then If yes Then Begin
       ud.Path:=area.xmodemdir;
       newfilesam:=GetFName(ud.Path,ud.FileName);
       exec(getenv('comspec'),'/c Copy '+filesam+' '+newfilesam+' > nul' );
       wangbang:=filesam;
       Assign(darn,wangbang);
       If exist(newfilesam) Then Erase(darn) Else Begin
         ud.Path:=sambam;
         WriteLn('Uh oh... Bad error!');
       End;
     End;
      addfile(ud);
      setarea(oldn,true);
      WriteLn(^B'Done.')
    End;


  Procedure multmovefile;
    Var an,sfn,efn,fn,oldn:Integer;
        newfilesam,sambam,filesam,wangbang:anystr;
        darn:File;
      ud:udrec;
    Begin
      oldn:=curarea;
      fn:=getfilenum('start move');
      if fn=0 then exit;
      input:='';
      efn:=getfilenum('end move');
      If efn=0 Then exit;
       Input:='';
      an:=getareanum;
     If an=0 Then exit;
     for sfn:=fn to efn do begin
     seekudfile(fn);
     Read(udfile,ud);
      writeln('Moving '+ud.filename+'...');
      writelog(16,5,ud.filename);
     removefile(fn,false);
     filesam:=GetFName(ud.Path,ud.FileName);
     sambam:=ud.Path;
     setarea(an,true);
     write('Current Free Space: '); writefreespace(area.xmodemdir);
     writestr(^M'Physically move '+ud.filename+' to correct area? *') ;
     If (sambam<>area.xmodemdir) Then If yes Then Begin
       ud.Path:=area.xmodemdir;
       newfilesam:=GetFName(ud.Path,ud.FileName);
       exec(getenv('comspec'),'/c Copy '+filesam+' '+newfilesam+' > nul' );
       wangbang:=filesam;
       Assign(darn,wangbang);
       If exist(newfilesam) Then Erase(darn) Else Begin
         ud.Path:=sambam;
         WriteLn('Uh oh... Bad error!');
       End;
     End;
      addfile(ud);
      setarea(oldn,true);
      writeln(^M'File moved.');
     end;
      WriteLn(^B'Done.')
    End;

	 Procedure BatchMove;
		Var an,fn,oldn,cnt:Integer;
				newfilesam,sambam,filesam,wangbang:anystr;
				darn:File;
			ud:udrec;
		Begin
		if filesinbatch=0 then exit;
		an:=getareanum;
		if an=0 then exit;
		oldn:=curarea;
		for cnt:=1 to filesinbatch do
		begin
			setarea(batchdown[cnt].area,false);
			 input:='B'+BatchDown[Cnt].FileName;
			 fn:=getfilenum('move');
			 if fn<>0 then
			 begin
			WriteLn('Moving...');
		 seekudfile(fn);
		 Read(udfile,ud);
			writelog(16,5,ud.filename);
		 removefile(fn,false);
		 filesam:=GetFName(ud.Path,ud.FileName);
		 sambam:=ud.Path;
		 setarea(an,False);
		 Write('Current Free Space: ');
		 writefreespace(area.xmodemdir);
		 writestr('Physically move the file to correct area? *') ;
		 If (sambam<>area.xmodemdir) Then If yes Then Begin
			 ud.Path:=area.xmodemdir;
			 newfilesam:=GetFName(ud.Path,ud.FileName);
       exec(getenv('comspec'),'/c Copy '+filesam+' '+newfilesam+' > nul' );
       wangbang:=filesam;
       Assign(darn,wangbang);
       If exist(newfilesam) Then Erase(darn) Else Begin
         ud.Path:=sambam;
         WriteLn('Uh oh... Bad error!');
       End;
     End;
      addfile(ud);
      setarea(oldn,true);
			WriteLn(^B'Done.')
			end else
				writeLn(^S'File '+BatchDown[Cnt].FileName+' not found!');
			end;
			clear_batchdown;
		End;

	 Procedure BatchDel;
	 Var Oldn,Fn,Cnt:Integer;
			 ud:udrec;
			 F:File;
	 Begin
		 OldN:=CurArea;
		 If FilesInBatch=0 then Exit;
		 For Cnt:=1 to FilesInBatch Do
			 Begin
				WriteStr('Delete File '+BatchDown[Cnt].FileName+'? *');
				If yes then Begin
				 Input:='B'+BatchDown[Cnt].Filename;
				 SetArea(BatchDown[Cnt].Area,false);
				 Fn:=GetFileNum('BatchDel');
				 If Fn<>0 then Begin
				 SeekUdfile(Fn);
				 Read(Udfile,Ud);
				 If Exist(GetFname(Ud.Path,Ud.FileName)) then
					 Begin
						 WriteStr(^M'Physically '+GetFname(Ud.Path,Ud.FileName)+'? *');
						 If Yes then
							 Begin
								 Assign(F,GetFname(Ud.Path,Ud.FileName));
								 Erase(F);
							 End;
						 End;
						 RemoveFile(Fn,true);
						 WriteLog(16,7,Ud.FileName);
				 End;
        End;
			End;
			Clear_BatchDown;
		 End;

	Procedure renamefile;
    Var fn:Integer;
      ud:udrec;
      f:File;
    Begin
      fn:=getfilenum('rename');
      If fn=0 Then exit;
      seekudfile(fn);
      Read(udfile,ud);
      writestr('Enter new filename:');
      If match(Input,ud.filename)
      Then
        ud.filename:=Input
      Else If Length(Input)>0
        Then If validfname(Input)
          Then If exist(getfname(ud.path,Input))
            Then
              WriteLn('Name already in use!')
            Else
              Begin
                Assign(f,getfname(ud.path,ud.filename));
                Rename(f,getfname(ud.path,Input));
                If IOResult=0 Then Begin
                  ud.filename:=Input;
                  WriteLn(^B^M'File renamed.')
                End Else WriteLn(^B^M'Unable to rename file!')
              End
          Else WriteLn('Invalid filename!');
      seekudfile(fn);
      Write(udfile,ud)
    End;

  Procedure listxmodem;
    Var cnt:Integer;
      u:userrec;
    Begin
      Seek(ufile,1);
      WriteLn('Name                          Lvl Pts'^M);
      For cnt:=1 To numusers Do Begin
        Read(ufile,u);
        If u.handle<>'' Then
          If u.udlevel>0 Then Begin
            tab(u.handle,30);
            tab(strr(u.udlevel),4);
            WriteLn(u.udpoints);
            If break Then exit
          End
      End
    End;

  Procedure reorderareas;
    Var numa,cura,newa:Integer;
      a1,a2:arearec;
      f1,f2:File;
      fn1,fn2:sstr;
    Label exit;
    Begin
      writelog(16,9,'');
      writehdr('Re-order Areas');
      numa:=FileSize(afile);
      WriteLn('Number of areas: ',numa);
      For cura:=0 To numa-2 Do Begin
        Repeat
          writestr('New area #'+^V+strr(cura+1)+^P+' [?=List, CR to quit]:');
          If Length(Input)=0 Then GoTo exit;
          If Input='?'
          Then
            Begin
              listareas;
              newa:=-1
            End
          Else
            Begin
              newa:=valu(Input)-1;
              If (newa<0) Or (newa>numa) Then Begin
                WriteLn('Not found!  Please re-enter...');
                newa:=-1
              End
            End
        Until (newa>=0);
        if newa=cura then WriteLn(^M^S'Same file area as currently is, skipping this area..'^M)
        else Begin
        Seek(afile,cura);
        Read(afile,a1);
        Seek(afile,newa);
        Read(afile,a2);
        Seek(afile,cura);
        Write(afile,a2);
        Seek(afile,newa);
        Write(afile,a1);
        fn1:='Area';
        fn2:=fn1+strr(newa+1);
        fn1:=fn1+strr(cura+1);
        if CurrentConference<>1 then Begin
        Fn2:=Fn2+'.'+Strr(CurrentConference);
        Fn1:=Fn1+'.'+Strr(CurrentConference);
        End;
        Assign(f1,ConfigSet.ForumDi+fn1);
        Assign(f2,ConfigSet.ForumDi+fn2);
        Rename(f1,'Temp$$$$');
        Rename(f2,fn1);
        Rename(f1,fn2)
        End;
      End;
exit:
      setarea(1,true)
    End;

  Procedure newfiles;
    Var a,fn,un:Integer;
      ud:udrec;
      u:userrec;
      krad:lstr;
      flag,aborted:Boolean;

    Procedure writeudrec;
      Begin
        seekudfile(fn);
        Write(udfile,ud)
      End;

    Procedure ratefile(p:Integer);
      Begin
        ud.points:=p;
        ud.newfile:=False;
        ud.whenrated:=now;
        writeudrec;
        p:=p*configset.uploadfacto;
        If p>0 Then Begin
          Writestr('Actually give user How many pts? ['+^V+strr(p)+^P+'] :');
          If Input='' Then Else If (valu(Input)>0) Or (Input='0') Then p:=valu(Input);
          un:=lookupuser(ud.sentby);
          If un=0
          Then WriteLn(ud.sentby,' has vanished!')
          Else Begin
            WriteLn('Giving ',ud.sentby,' ',p,' points.');
            If un=unum Then writeurec;
            Seek(ufile,un);
            Read(ufile,u);
            u.udpoints:=u.udpoints+p;
            Seek(ufile,un);
            Write(ufile,u);
            If un=unum Then readurec
          End
        End
      End;

    Procedure doarea;
      Var i,advance:Integer;
        done:Boolean;
      Begin
        fn:=1;
        advance:=0;
        While fn+advance<=numuds Do Begin
          fn:=fn+advance;
          advance:=1;
          seekudfile(fn);
          Read(udfile,ud);
          If ud.newfile Then Begin
            flag:=False;
            done:=False;
            Repeat clearscr;
              printxy(1,1,'');
              WriteLn(^B^M'[Filename   ]:',upstring(ud.filename),
              ^M'[SubDir Path]:',ud.path,
              ^M'[Uploaded by]:',ud.sentby,
              ^M'[File Size  ]:',ud.filesize,
              ^M'[Description]:',ud.descrip);
              i:=menu('Newscan','NEWSCAN','Q#_CEDRM0V');
              Input:=' '+strr(fn);
              If i<0
              Then
                Begin
                  ratefile(-i);
                  done:=True
                End
              Else
                Case i Of
                  1:Begin
                      aborted:=True;
                      exit
                    End;
                  3:done:=True;
                  4:Begin
                      writestr('Enter new description:');
                      If Length(Input)>0 Then ud.descrip:=Input;
                      writeudrec
                    End;
                  5:Begin
                      renamefile;
                      advance:=0
                    End;
                  6:Begin
                      deletef;
                      advance:=0
                    End;
                  7:listarchive;
                  8:Begin
                      movefile;
                      advance:=0
                    End;
                  9:Begin
                      ratefile(0);
                      done:=True
                    End
                End
            Until done Or (advance=0)
          End
        End
      End;

    Begin
      flag:=True;
      writelog(16,1,'');
      If issysop Then Begin
        writestr('Newscan all areas? *');
        If yes Then Begin
          For a:=1 To numareas Do Begin
            setarea(a,true);
            aborted:=False;
            doarea;
            If aborted Then exit
          End
        End Else doarea
      End Else doarea;
      If flag Then WriteLn(^B'No new files.')
    End;

  Procedure sysopcommands;
    Var i:Integer;
    Begin
      If Not sponsoron Then Begin
        reqlevel(configset.sysopleve);
        exit
      End;
      writelog(15,3,area.name);
      Repeat
				i:=menu('File sponsor','FSYSOP','A@CDF@G@KRNSMLO@QEWX+Z*@');
        Case i Of
          1:sysopadd;
          2:changef;
          3:deletef;
          4:directory;
          6:killarea;
          7:modarea;
          8:newfiles;
          9:sortarea;
          10:movefile;
          11:listxmodem;
          12:reorderareas;
          14:renamefile;
          15:addmultiplefiles;
					17:WriteLn(^M^S'Sorry, that function is temporarily offline!');
					19:getarea;
					16:multmovefile;
					18:Begin
						 ClearScr;
						 WriteHdr('Batch Commands');
						 WriteLn(^S'[1] '^R'Move Batch Que');
						 WriteLn(^S'[2] '^R'Delete files in Batch Que');
						 WriteStr(^M^P'Which:');
						 Case Valu(Input) of
							 1:BatchMove;
							 2:BatchDel;
						 End;
					End;
				End
      Until hungupon Or (i=13)
    End;

  Procedure batch_menu;
    Var i:Integer;
    Begin
      Writehdr('Batch Transfer Menu');
      Repeat
        i:=menu('Batch Xfer','FBATCH','CLDUQAX');
        Case i Of
          1:begin
             clear_Batchdown;
             writeln(^M'Batch Que and Bi-Modem Que Cleared!');
             end;
          2:listbatch;
          3:do_batch_download;
					4:if area.uploadhere=true then Batch_Upload else
						 WriteLn(^M^S'You may not upload to this area!'^M);
          6:bimodemupload;
          7:DOBIXFER;
        End
      Until hungupon Or (i=5)
    End;

  Var i:Integer;
    a:arearec;
    ms:Boolean;
    taxz:boolean;
    tzz:Mstr;

  Label ok,exit;
  Begin
  killbimodem;
  clear_batchdown;
    cursection:=udsysop;
    ms:=False;
      Write(^R);
    Input:='';
    Tzz:='areadir';
    if CurrentConference<>1 then Tzz:=Tzz+'.'+Strr(CurrentConference);
    Assign(afile,ConfigSet.ForumDi+tzz);
    If exist(ConfigSet.ForumDi+tzz)
    Then
      Begin
        Reset(afile);
        If FileSize(afile)>0 Then GoTo ok
      End
    Else Rewrite(afile);
    WriteLn('No File areas Exist!!');
    area.xmodemdir:=configset.forumdi+'XMODEM\';
    If issysop
    Then If makearea
      Then GoTo ok;
    GoTo exit;
ok:
    seekafile(1);
    Read(afile,a);
    If Not(Allowed_in_Area(a)) Then Begin
      WriteLn(^S'You do not have access to the file section!');
      GoTo exit
    End; if not pcratio then begin
     printxy(21,0,'');
     writeln('Your Post/Call Ratio is out of line. Go to the message bases and POST');
     writeln('some messages in order to correct this!');
     goto exit;
     end;
    yourudstatus;
     if exist(configset.textfiledi+'Filenews.BBS') then begin
     buflen:=0;
     writestr(^P'Press Return to continue.*');
     printfile(configset.textfiledi+'Filenews.BBS');
     end;
     load_protos;
     setarea(1,true);
     if configset.shownewprompts then begin
     WriteStr('Scan for new files? [N]:');
     If Yes then NewScanAll;
     end;
      Repeat
        If withintime(configset.xmodemclosetim,configset.xmodemopentim) or (timetillnet<30) Then
          If Not issysop Then Begin
            if timetillnet<30 then tzz:=configset.netenc else tzz:=configset.xmodemopentim;
            writestr(^M^M'File section is closed at this time!');
            WriteLn('The time is now   : '^S,timestr(now));
            WriteLn('File area opens at: '^S,tzz);
            GoTo exit
          End Else If Not ms Then Begin
            WriteLn('The File area is closed until ',configset.xmodemopentim);
            ms:=True
          End;
        If  ((vt52 in urec.config) or (ansigraphics In urec.config)) Then Begin
          If WhereY>21 Then Begin printxy(24,1,'');WriteLn(^B^M^M);End;
          printxy(22,1,'');
        Write(^B^S,area.name,^R' ['^S,curarea,^R']') End Else
          WriteLn(^B^M^M^S,area.name,^R' ['^S,curarea,^R']');
          i:=menu('File','FILE','UDLFYA!SQ%NVHRXWT+BG*I');
        If hungupon Then GoTo exit;
        Case i Of
          1:upload;
          2:download(0,'',0);
          3,4:listfiles(False);
					5:yourudstatus;
					21,6:getarea;
          8:searchfile;
          7:;
          10:sysopcommands;
          11:newscanall;
          12:newscan;
          13:help('Filexfer.hlp');
          14:listarchive;
          15:printfile(configset.textfiledi+'Wantlist.bbs');
          16:listfiles(True);
          17:typefile;
          18:add_to_batch(0,'',0);
          19:batch_menu;
          20:offtheforum;
          22:zipfile;
        End

      Until hungupon Or (i=9);
exit:
    Close(afile);
    Close(udfile);
    i:=IOResult;
  End;

  begin
  end.
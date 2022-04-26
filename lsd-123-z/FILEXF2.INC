  Procedure Zipfile;
    Var a:arearec;
      cnt,cn,start_area : integer ;
      bang:text;
      wang:lstr;
      u:udrec;
      color1,color2,color3,color4,color5,color6,color7:sstr;
      done,first:Boolean;
      T:Char;

  Procedure listfileb(n:Integer;extended:Boolean);
    Var ud:udrec;
      q:sstr;
     path, Filez:anystr; _Name:namestr; _Ext: Extstr;
      Sze:longint;
     Any:lstr;
    Begin
      seekudfile(n);
      Read(udfile,ud);
      any:=strr(n)+'.';
      write(bang,Color6+any:4,Color4);

        FSplit(ud.filename,path,_name,_ext);
      path:=upcase(_name[1]);
      _name[1]:=path[1];
      write (bang,_Name:8,UpString(_Ext):4,'  '+Color3);
      if (ud.sendto='') then
      If ud.newfile
      Then Write(bang,' New   ')
      Else If ud.specialfile
        Then Write(bang,' Ask   ')
        Else If ud.points>0
          Then Write(bang,ud.points:4 , '   ')
          Else Write(bang,' Free  ')
        else if match(ud.sendto,urec.handle) then write(bang,' Take  ') else
        write(bang,' Priv  ');
         write(bang,Color7);
      Filez:=getfname(ud.path,ud.filename);
      If Not(exist(filez)) Then write(bang,'[Offline]':10) Else begin
       sze:=ud.filesize;
        if sze<1024 then
               write(bang,sze:10) else begin
                 any:=strlong(sze div 1024)+'k ';
               Write(bang,any:9);
               end;
      end;
      WriteLn(bang,' '+Color2,copy(ud.descrip,1,40));
    End;
    Begin
      Writehdr('Complete File List');
      writestr(^M^P'Add color to the file listing? *');
      writeln(^M^S'Please wait...Compiling List...');
      Color1:=^M+^M;
      Color2:='';
      Color3:='';
      Color4:='';
      Color5:='';
      Color6:='';
      Color7:='';
      if yes then
      Begin
        Color1:=#27+'[0;1m'+^M+^M+#27+'[37m';
        Color2:=#27+'[36m';
        Color3:=#27+'[35m';
        Color4:=#27+'[34m';
        Color5:=#27+'[37m';
        Color6:=#27+'[33m';
        Color7:=#27+'[31m';
      End;
      assign (Bang,'FileList.Zip');
      if exist('FileList.zip') then erase(Bang);
      assign  (bang,'FileList.txt');
      if exist('FileList.Txt') then erase(bang);
      rewrite(bang);
      write(bang,Color1);
      writeln(bang,'-------------------------------------------------------------------------');
      write(bang,Color2+'Complete File Listing for the '+Color3+ConfigSet.LongNam+Color2);
      writeLn(bang,' as of '+Color4+DateStr(Now)+Color2+' - '+Color4+TimeStr(Now));
      writeln(bang,Color5+'-------------------------------------------------------------------------');
      writeln(bang,^M);
          beenaborted:=False;
      start_area := curarea ;
      For cn:=1 To FileSize(afile) Do Begin
        seekafile(cn);
        Read(afile,a);
        If Allowed_in_Area(a) Then Begin
          setarea(cn,true);
              Begin
      done:=False;

      Repeat

        first:=False;
        beenaborted:=False;

        For cnt:=1 To FileSize(udfile) Do Begin
          seekudfile(cnt);
          Read(udfile,u);

           Begin

            If Not first Then Begin
              write(bang,^M+^M+^M);
              WriteLn(bang,Color5+'-------------------------------------------------------------------------');
              writeLn(bang,Color6+' File Section:'+Color4+Area.Name);
              writeln(bang,Color5+'-------------------------------------------------------------------------'+^M);
            first:=True;End;
            listfileb(cnt,False);
        End;
           done:=True;
        End;
        If Not first Then done:=True;
      Until done;
    End;

        End;
      End ;
      textclose(bang);
      Writehdr('List Compilation done!');
      writeln(^M);
      writehdr(' Demon Tasker... Zipping File List ');
      exec ('PKZIP.EXE','-ex FileList.zip FileList.txt');
      erase(bang);
      Writestr (^M'[D]ownload Now or [+] Add to Batch list [D] :');
      if input='+' then Add_to_batch (0,'FileList.zip',0) else
      download (0,'Filelist.zip',0);
    End;


  Procedure listarchive;
    Var n:Integer;
      ud:udrec;
      fname:lstr;

    Begin
      If nofiles Then exit;
      n:=getfilenum('list');
      If n=0 Then exit;
      seekudfile(n);
      Read(udfile,ud);
      If Not AbleToDoAnything(Ud) then Exit;
      Fname:=GetFname(Ud.Path,Ud.FileName);
      fname:=upstring(fname);
      clearscr;
      writeln(^S'L.S.D. ZIP/ARC/PAK/ICE/LZH Viewer');
      write(^S'Archive Type: '^U);
      if pos ('.ZIP', fname)>0 then zipview(fname) else
      if pos ('.PAK',fname)>0 then PakView(fname) else
      if pos ('.ARC',fname)>0 then Arcview(fname) else
      if (pos ('.LZH',fname)>0) or (pos('.ICE',fname)>0) then lzhview(fname) else
       writeln('Not an ARCHIVE!'^M^M);
      Writestr (^B^M^P'Press [Return] to continue *');
    End;

    procedure typefile;
    var n:integer;
        ud:udrec;
    begin
    if nofiles then exit;
    n:=getfilenum('type');
    if n=0 then exit;
    seekudfile(n);
    read(udfile,ud);
    If Not AbleToDoAnything(Ud) then Exit;
    printfile(ud.path+ud.filename);
    writestr(^B^M^M'Press [Return] to continue *');
    end;

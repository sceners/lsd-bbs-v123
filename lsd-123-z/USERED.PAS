Uses Dos,Crt,subs1,scrnunit,gentypes,gensubs;

const  colorstr:array [0..15] of string[20]=
  ('Black  ','Blue ','Green','Cyan ','Red    ','Magenta','Brown   ','White',
   'Gray  ','BLUE!  ','GREEN!','CYAN!  ','RED!     ','MAGENTA!','Yellow   ','WHITE!');


 Var
    Infile         :File of Userrec;
    UserRecs       :Userrec;
    Place,a,b,c,d,e:Integer;
    Flag           :boolean;
    Choice         :Char;
    Counter        :Integer;
    UserNum        :Integer;

procedure write_rec;forward;
procedure format_data_area;forward;
procedure list_rec;forward;

Procedure Show_Fields;
Begin
setColor(9);
  Gotoxy(2,2);Write('Handle');
  Gotoxy(2,3);Write('User Note');
  Gotoxy(2,4);Write('Password');
  Gotoxy(2,5);Write('Main Level');
  Gotoxy(2,6);Write('File Level');
  Gotoxy(2,7);Write('Phone Number');
  Gotoxy(2,8);Write('Real Name');
  Gotoxy(2,9);Write('File Points');
  Gotoxy(2,10);Write('Upload K');
  Gotoxy(2,11);Write('Download K');
  Gotoxy(2,12);Write('Uploads');
  Gotoxy(2,13);Write('Downloads');
  Gotoxy(2,14);Write('Gfile Level');
  Gotoxy(2,15);Write('Gfile UL''s');
  Gotoxy(2,16);Write('Gfile DL''s');
  Gotoxy(2,17);Write('Total Time');
  Gotoxy(2,18);Write('PCR');
  gotoxy(2,19);write('U/D Ratio');
  gotoxy(2,20);write('U/D K Ratio');
End;

Procedure Place_Cursor;
 Begin
  With Userrecs do
   Begin
   setcolor(15+16);
    Case Place of
    1:begin Gotoxy(2,2);Write('Handle');     end;
    2:begin Gotoxy(2,3);Write('User Note');  end;
    3:begin Gotoxy(2,4);Write('Password');   end;
    4:begin Gotoxy(2,5);Write('Main Level'); end;
    5:begin Gotoxy(2,6);Write('File Level'); end;
    6:begin Gotoxy(2,7);Write('Phone Number');end;
    7:begin Gotoxy(2,8);Write('Real Name');  end;
    8:begin Gotoxy(2,9);Write('File Points'); end;
    9:begin Gotoxy(2,10);Write('Upload K');   end;
   10:begin Gotoxy(2,11);Write('Download K'); end;
   11:begin Gotoxy(2,12);Write('Uploads');    end;
   12:begin Gotoxy(2,13);Write('Downloads');  end;
   13:begin Gotoxy(2,14);Write('Gfile Level');end;
   14:begin Gotoxy(2,15);Write('Gfile UL''s');end;
   15:Begin Gotoxy(2,16);Write('Gfile DL''s');end;
   16:Begin Gotoxy(2,17);Write('Total Time'); end;
   17:Begin Gotoxy(2,18);Write('PCR');end;
   18:begin gotoxy(2,19);write('U/D Ratio');end;
   19:begin gotoxy(2,20);write('U/D K Ratio');end
  End
 End;
setcolor(15);
End;

Procedure Read_Cursor;
 Begin
  With Userrecs do
   Begin
    gotoxy(16,1+place);write('                                 ');
    Case Place of
    1:begin setColor(12);Gotoxy(16,2);Readln(Handle);      End;
    2:Begin setColor(12);Gotoxy(16,3);Readln(userNote);        End;
    3:Begin setColor(12);Gotoxy(16,4);Readln(password);    End;
    4:Begin setColor(12);Gotoxy(16,5);Readln(level);       End;
    5:Begin setColor(12);Gotoxy(16,6);Readln(udlevel);     End;
    6:Begin setColor(12);Gotoxy(16,7);Readln(phonenum);    End;
    7:Begin setColor(12);Gotoxy(16,8);Readln(realname);   End;
    8:Begin setColor(12);Gotoxy(16,9);Readln(udpoints);    End;
    9:Begin setColor(12);Gotoxy(16,10);Readln(upkay);        End;
   10:Begin setColor(12);Gotoxy(16,11);Readln(Dnkay);      End;
   11:Begin setColor(12);Gotoxy(16,12);Readln(uploads);    End;
   12:Begin setColor(12);Gotoxy(16,13);Readln(downloads);  End;
   13:Begin setColor(12);Gotoxy(16,14);Readln(glevel);    End;
   14:Begin setColor(12);Gotoxy(16,15);Readln(nup);  End;
   15:Begin setColor(12);Gotoxy(16,16);Readln(ndn);End;
   16:Begin setColor(12);Gotoxy(16,17);Readln(totaltime);  End;
   17:Begin setColor(12);Gotoxy(16,18);Readln(pcratio);     End;
   18:begin setcolor(12);gotoxy(16,19);readln(udratio);end;
   19:begin setcolor(12);gotoxy(16,20);readln(udkratio);end;
  End
 End;
 write_rec;
 format_data_area;
 list_rec;
End;


Procedure List_Rec;
   Begin
   setColor(4);
    Seek(infile,Usernum);
    Read(Infile,Userrecs);
    Gotoxy(57,18);Write('UserNumber: ',Usernum);
    if usernum<10 then write(' ');
    if usernum<100 then write(' ');
    if usernum<1000 then write(' ');
    With UserRecs do
    Begin
      Gotoxy(16,2);Write(Handle);
      Gotoxy(16,3);Write(userNote);
      Gotoxy(16,4);Write(password);
      Gotoxy(16,5);Write(level);
      Gotoxy(16,6);Write(udlevel);
      Gotoxy(16,7);Write(phonenum);
      Gotoxy(16,8);Write(realname);
      Gotoxy(16,9);Write(udpoints);
      Gotoxy(16,10);Write(upkay);
      Gotoxy(16,11);Write(Dnkay);
      Gotoxy(16,12);Write(uploads);
      Gotoxy(16,13);Write(downloads);
      Gotoxy(16,14);Write(glevel);
      Gotoxy(16,15);Write(nup);
      Gotoxy(16,16);Write(ndn);
      Gotoxy(16,17);Write(totaltime:6:2);
      Gotoxy(16,18);Write(pcratio);
      gotoxy(16,19);write(udratio);
      gotoxy(16,20);write(udkratio);
    End
   End;


Procedure Open_Rec;
    Begin
      Assign(Infile,'USERS');
      Reset(Infile);
      Counter:=0;
      While not eof (Infile) do Begin
        Read(Infile,userrecs);
        Counter:=Counter+1
      end;
      UserNum:=1
    end;

 Procedure Write_Rec;
 Begin
   Seek(Infile,Usernum);
   Write(Infile,UserRecs)
 End;

Procedure Format_Data_Area;
    Begin
     For A:=2 to 20 do begin
         GotoXy(16,A);Write('                                   ');
         End;
    Gotoxy(69,15);Write('   ');
    Gotoxy(57,18);Write('            ');
    End;

Procedure Delete_Rec;
    Begin
    With Userrecs do
    Begin
     Nbu:=0;
     Handle:='';
     userNote:='';
     Password:='';
     Level:=0;
     Udlevel:=0;
     Phonenum:='';
     TimeToday:=0;
     Udpoints:=0;
     Upkay:=0;
     Dnkay:=0;
     Uploads:=0;
     Downloads:=0;
     Write_Rec;
     List_Rec;
     Glevel:=0;
     nup:=0;
     ndn:=0;
     TotalTime:=0;
     Macro1:=''
  end;
  Write_Rec;
  Format_Data_Area;
  List_Rec
 End;


Procedure Add_Rec;
   Begin
    Usernum:=Counter;
    Counter:=Counter+1;
    GotoXy(57,18);Write('UserNubmer: ',Usernum);
    With UserRecs do
    Begin
      nbu:=0;
      Gotoxy(16,2);Readln(Handle);
      Gotoxy(16,3);Readln(userNote);
      Gotoxy(16,4);Readln(password);
      Gotoxy(16,5);Readln(level);
      Gotoxy(16,6);Readln(udlevel);
      Gotoxy(16,7);Readln(phonenum);
      Gotoxy(16,8);Readln(realname);
      Gotoxy(16,9);Readln(udpoints);
      Gotoxy(16,10);Readln(upkay);
      Gotoxy(16,11);Readln(Dnkay);
      Gotoxy(16,12);Readln(uploads);
      Gotoxy(16,13);Readln(downloads);
      Gotoxy(16,14);Readln(glevel);
      Gotoxy(16,15);Readln(nup);
      Gotoxy(16,16);Readln(ndn);
      Gotoxy(16,17);Readln(totaltime);
      Gotoxy(16,18);Readln(pcratio);
      gotoxy(16,19);readln(udratio);
      gotoxy(16,20);readln(udkratio);
    End;
    Seek(Infile,usernum);
    Write(Infile,UserRecs)
   End;

procedure showitflags;
Begin
  ClrScr;
  A:=0;
  B:=0;
  C:=0;
  d:=0;
  Flag:=False;
  setColor(11);
  Gotoxy(1,1);
  Write('ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿');
  For A:=2 to 20 do Begin
    Gotoxy(1,a);
    Write('³            ³')
  End;
  Gotoxy(1,21);
  Write('ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ');
  setColor(10);
  Gotoxy(15,1);
  Write('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
  For A:=2 to 20 do Begin
    Gotoxy(15,a);
    Write('³                                   ³')
  End;
  Gotoxy(15,21);
  Write('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
  Show_Fields;
  setColor(14);
  Gotoxy(1,22);
  Write('Ú');For a:=2 to 79 do Begin
     Write('Ä')
  End;
  Gotoxy(80,22);
  Write('¿');
  setColor(12);
  Write('    [Q] Quit            [PageUp] Next User          [PageDown] Previous User');
  setColor(14);
  Gotoxy(1,23);
  Write('³');
  Gotoxy(80,23);
  Write('³');
  Gotoxy(1,24);
  Write('À');
  For a:=2 to 79 do Begin
    Gotoxy(a,24);
    Write('Ä')
  End;
  Gotoxy(80,24);
  Write('Ù');
  setColor(11);
  gotoxy(55,1);
  Write('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
  For A:=2 to 10 do Begin
    Gotoxy(55,a);
    Write('³                 ³')
  End;
  Gotoxy(55,10);
  Write('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
  setColor(10);
  Gotoxy(57,2);
  Write('LSD User Editor');
  Gotoxy(57,3);
  Write('Written by the');
  Gotoxy(57,4);
  Write('  LSD Staff');
  Gotoxy(57,6);
  Write('    v1.00 ');
  setColor(13);
  Gotoxy(55,11);
  Write('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
  For A:=12 to 21 do Begin
    Gotoxy(55,a);
    Write('³                  ³')
  End;
  Gotoxy(55,21);
  Write('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
  setColor(8);
  Gotoxy(57,12);
  Write('[A] Add User');
  Gotoxy(57,13);
  Write('[D] Delete User');
  gotoxy(57,14);
  write('[C] Edit Flags');
  gotoxy(57,15);
  write('[J] Jump to');
  gotoxy(57,16);
  write('[L] List Users');
  gotoxy(57,17);
  write('[P] Edit Colors');
  Gotoxy(57,19);
  Write('[ESC] to Quit');
  gotoxy(57,20);
  write('[S] Search Users');
  end;

  procedure conferenceflags;
  var x:integer;
      s:string;
  begin
  repeat
  clrscr;
  setcolor(11);
  writeln('Users Conference Flags are currently set to:');
  writeln;setcolor(15);
  for x:=1 to 20 do if userrecs.confset[x]>0 then write(x,',') else write('0,');
  writeln;
  for x:=21 to 31 do if userrecs.confset[x]>0 then write(x,',') else write('0,');
  if userrecs.confset[32]>0 then writeln('32') else writeln('0');
  setcolor(13);
  writeln;
  write('Conference to change access for or RETURN to quit:');
  readln(s);
  if s<>'' then begin
    x:=valu(s);
    if (x>0) or (x<33) then if userrecs.confset[x]=0 then userrecs.confset[x]:=1 else userrecs.confset[x]:=0;
  end;
  until s='';
  showitflags;
  format_data_area;
  list_rec;
  write_rec;
  end;

  procedure search_users;
  var s,s1:string[50];
      ch:char;
      y:string;
      u:userrec;
      x:integer;
      w3:window;
      possib:boolean;
  begin
  openwindow(w3,18,10,55,16,$1f,$1f);
  setcurwindow(w3);
  setcolor($1f);
  gotoxy(2,1);
  write('String to Search for:');
  readln(s);
  if s='' then begin
     closewindow;
     exit;
  end;
  s:=upstring(s);x:=0;
  gotoxy(2,2);writeln('Searching User log...');
 repeat
   inc(x);
   possib:=false;
   seek(infile,x);
   read(infile,u);
   if pos(s,upstring(u.handle))>0 then possib:=true;
   if pos(s,upstring(u.realname))>0 then possib:=true;
   if pos(s,upstring(u.usernote))>0 then possib:=true;
   if pos(s,upstring(u.phonenum))>0 then possib:=true;
   if possib then begin
     gotoxy(2,3);
     writeln('Edit:'+u.handle+' [y/N]?                 ');
     ch:=readkey;
     s1:=ch;
     if not match(s1,'Y') then possib:=false;
   end;
 until possib or (x=counter-1);
 closewindow;
 if possib then usernum:=x;
 showitflags;
 format_data_area;
 list_rec;
 end;

  procedure jumpuser;
  var x:integer;
      w3:window;
      s:string;
  begin
  openwindow(w3,12,10,56,12,15*4,15*4);
  setcurwindow(w3);
  setcolor(15*4+3);
  gotoxy(2,1);
  write('User # to jump to [1-',counter-1,']:');
  readln(s);
  if s='' then begin
    closewindow;
    exit;
    end;
  x:=valu(s);
  if (x>0) and (x<counter) then usernum:=x;
  closewindow;
  showitflags;
  format_data_area;
  list_rec;
  end;

  procedure list_users;
  var x,ct,a,b:integer;
      u:userrec;
  begin
    ct:=counter div 23;
    if ct*23<counter then ct:=ct+1;
    x:=0;
    for a:=1 to ct do begin
      clrscr;
      setcolor(14);
      for b:=1 to 23 do begin
        inc(x);
        if x<counter then begin
          seek(infile,x);
          read(infile,u);
          if x<10 then write('.');
          if x<100 then write('.');
          if x<1000 then write('.');
          writeln(x,'] .. ',u.handle);
        end;
      end;         setcolor(15);
    write('Press [Return] to continue.');
    readln;
    end;                  setcolor(15);
  writeln('Press [Return] to continue.');
  showitflags;
  format_data_area;
  list_rec;
  end;

  procedure exited;
  begin
  clrscr;
  setcolor(15);
  gotoxy(20,10);
  writeln('L.S.D. BBS (c) 1990 TL Enterprises');
  gotoxy(17,12);
  writeln('User Editor v1.00 Written by Ken Sallot');
  gotoxy(20,25);
  writeln('Thank you for Using L.S.D.!');
  halt;
  end;


 procedure do_colors;

  function doattrib:integer;
  var p:integer;


    function demo:integer;
      var cnt:integer;
          K:char;
          w3:window;
    begin
         openwindow(w3,18,9,50,14,15,15);
         setcurwindow(w3);
         gotoxy(5,1);
         setcolor(15);
         write('  Color Selection');
         gotoxy(10,3);
         for cnt:=0 to 15 do begin
           setcolor(cnt);
           write('Û');
           end;
           cnt:=0;
           repeat
            gotoxy(10+cnt,2);
            setcolor(15);
            write('');
            gotoxy(2,3);setcolor(cnt);
            if cnt=0 then
            begin
            setcolor(16*7); write('Black');
            setcolor(cnt); write('   ');
            end else
            write(colorstr[cnt]);
            k:=bioskey;
            if k=#205 then begin
               gotoxy(cnt+10,2);write(' ');
               cnt:=cnt+1;
               if cnt>15 then cnt:=0;
               end else if k=#203 then begin
               gotoxy(cnt+10,2);write(' ');
               cnt:=cnt-1;
               if cnt<0 then cnt:=15;
               end;
            until (k=#13) or (k=#27);
            if k=#13 then demo:=cnt
             else demo:=0;
      closewindow;
    end;

  var cnt,v:integer;
      k:char;
  begin
    v:=demo;
    p:=v;
    doattrib:=p;
  end;

  var w3:window;
  s:string;
  ch:char;
  begin
  openwindow(w3,12,10,54,14,15*4,15*4);
  setcurwindow(w3);
  gotoxy(2,1);
  setcolor(15*4+3);
  write('[A] Regular Color    [B] Prompt Color');
  gotoxy(2,2);
  write('[C] Status Color     [D] Input Color');
  gotoxy(2,3);
  write('[E] Blow Up Boarder  [F] Blow Up Inside');
  ch:=bioskey;
  s:=ch;
  ch:=upcase(s[1]);
  closewindow;
  case ch of
     'A':userrecs.regularcolor:=doattrib;
     'B':userrecs.promptcolor:=doattrib;
     'C':userrecs.statcolor:=doattrib;
     'D':userrecs.inputcolor:=doattrib;
     'E':userrecs.blowboard:=doattrib;
     'F':userrecs.blowinside:=doattrib;
  end;
 end;

  begin
  showitflags;
  Open_Rec;
  Format_Data_Area;
  List_Rec;
  Place:=1;
  Place_Cursor;
  While Flag=False do Begin
    Choice:=Readkey;
    Choice:=Upcase(Choice);
    Case Choice of
     'C':conferenceflags;
     'A':Begin
           Format_Data_Area;
           Add_Rec
         End;
     'D':Begin
           Gotoxy(57,18);
           Write('Delete User?');
           Choice:=Readkey;
           Choice:=Upcase(Choice);
           If Choice='Y' then delete_rec else Begin
             Gotoxy(57,18);
             Write('             ')
           End
         End;
     'J':jumpuser;
     'P':do_colors;
     'L':List_users;
     'S':search_users;
     'Q':Begin
           Write_Rec;
           Close(Infile);
           ClrScr;
           exited;
         End;
     #27:Begin
           Write_Rec;
           Close(Infile);
           ClrScr;
           exited;
         End;
     #13:Read_Cursor;
     #0:Begin
          Choice:=Readkey;
          Case Choice of
           #73:Begin
                 Write_Rec;
                 Usernum:=Usernum+1;
                 If Usernum>=counter then Usernum:=1;
                 Format_Data_Area;
                 List_Rec
               End;
           #81:Begin
                 Write_Rec;
                 Usernum:=Usernum-1;
                 If Usernum<1 then usernum:=Counter-1;
                 Format_Data_Area;
                 List_Rec
               End;
           #72:Begin
                 Place:=Place-1;
                 if Place<1 then place:=19;
                 Show_Fields;
                 Place_Cursor
               End;
           #80:Begin
                 Place:=Place+1;
                 If Place>19 then place:=1;
                 Show_Fields;
                 Place_Cursor
               End
        End
     End
  End
End;
End.
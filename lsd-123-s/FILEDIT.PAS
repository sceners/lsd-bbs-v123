Uses Dos,Crt,gentypes;
Label 1,2;
Type
     lstr=string[80];
     mstr=string[35];
     sstr=string[15];
     Str2=String[2];


Var Infile:File of udrec;
    Area:Str2;
    Recs:udrec;
    Fsize  :Longint;
    Inf2:file;
    FileNum:Integer;
    Num,a,b,c,d,e:Integer;
    Flag,Flag2:Boolean;
    Command,C2,Answer:Char;
    Counter:Integer;
    Spec1:String;
    Specfile:File;

  Procedure Erase_Disk_File;
    begin
      Spec1:=recs.path+Recs.filename;
      Assign(Specfile,spec1);
      Erase(Specfile);
    End;

  Procedure Delete_File;
    Begin
     If Filenum=Counter-1 then begin
        Seek(Infile,filenum);
        Truncate(Infile);
     End Else Begin
     For A:=1 to Counter-1 do Begin
      seek(Infile,a);
      read(Infile,recs);
      seek(Infile,a-1);
      write(Infile,Recs)
    end;
    seek (Infile,counter-1);
    truncate (Infile);
    End;
    Close(Infile);
  end;

  Procedure Add_File;
   Begin
    GotoXy(40,12);Write('File Number: ',Counter);
    With Recs do
    Begin
      Gotoxy(23,13);Readln(filename);
      Gotoxy(23,14);Readln(path);
      Gotoxy(23,15);Readln(points);
      Gotoxy(23,16);Readln(sentby);
      Gotoxy(23,17);Readln(pass);
      Gotoxy(23,18);Readln(downloaded);
      Gotoxy(23,19);Write('FALSE');
      Newfile:=False;
      Gotoxy(23,20);Write('FALSE');
      Specialfile:=False;
      Gotoxy(23,21);Readln(descrip);
      Gotoxy(23,22);Readln(sendto);
      Assign(Inf2,Path+Filename);
      Reset(inf2);
    End;
    Fsize:=Filesize(Inf2);
    Close(Inf2);
    Seek(Infile,Counter);
    Write(Infile,Recs);
   End;

  Procedure Format_Data_Area;
    Begin
     For A:=13 to 24 do begin
         GotoXy(23,A);Write('                                                     ');
         End;
    End;

  Procedure Commands;
    Begin
      TextColor(14);
      Gotoxy(5,5);
      Writeln('[A] Change Name     [B] Change Path          [C] Change Points');
      Gotoxy(5,6);
      Writeln('[D] Sent By         [E] DL Password          [F] Times DL''ed');
      Gotoxy(5,7);
      Writeln('[G] New File Rating [H] Special File Rating  [I] Description');
      Gotoxy(5,8);
      Writeln('[J] Send file to    [K] Delete File          [L] Add File');
      TextColor(12);
      Writeln('                   [Page Up & Page Down] Change Area');
      Writeln('       [Uarrow] Next File                     [Darrow] Next File');
      TextColor(11);
      Gotoxy(53,12);Write('   ');
      GotoXy(40,12);Write('File Number: ',Filenum);
      Gotoxy(62,12);Writeln('[Q] Quit & Save');
    end;

  Procedure Write_Area;
    Begin
      Seek(Infile,Filenum);
      Write(Infile,Recs);
      If Flag=TRUE then Begin
        Close(Infile);
        clrscr;
        textcolor(15);
        writeln('L.S.D. BBS File Editor Ver 1.00 Written by Ken Sallot for L.S.D. BBS Systems');
        gotoxy(25,23);
        writeln('Thanks for using L.S.D.!');
      End;
      If Flag2=TRUE then Begin
        Close(Infile);
      End;
    end;

  Procedure Open_Area(Area:Str2);
    Begin
      Assign(Infile,'AREA'+Area);
      Reset(Infile);
      Counter:=0;
      While not eof (Infile) do Begin
        Read(Infile,recs);
        Counter:=Counter+1;
        Filenum:=0;
      end;
    end;

  Procedure Next_File;
   Begin
    Filenum:=Filenum+1;
    If filenum>counter then filenum:=0;
   End;

  Procedure List_Data;
    Begin
    Gotoxy(1,13);
     TextColor(4);
     If FileNum>=Counter then Filenum:=0;
     If Filenum<0 then filenum:=Counter-1;
     Seek(infile,Filenum);
     Read(Infile,Recs);
     With recs do Begin
       Writeln('File Name           : ',Filename);
       Writeln('File Path           : ',Path);
       Writeln('File Points         : ',Points);
       Writeln('Sent By             : ',sentby);
       Writeln('Password            : ',pass);
       Writeln('Downloded           : ',Downloaded,' Times');
       Writeln('New File Rating     : ',Newfile);
       Writeln('Special Rating      : ',Specialfile);
       Writeln('Description         : ',descrip);
       Writeln('Send file to        : ',sendto);
     End;
    End;


  Begin
1: ClrScr;
   TextColor(13);
   Gotoxy(24,2);
   Write('LSD File Editor v1.00 LSD Staff');
   TextColor(14);
    For a:=1 to 79 do
     Begin
       Gotoxy(a,3);
       Write('Ä');
     end;
    For a:=1 to 79 do
     Begin
       Gotoxy(a,1);
       Write('Ä');
     end;
   TextColor(9);
   For a:=1 to 79 do
     Begin
       Gotoxy(a,4);
       Write('Ä');
     end;
    For a:=1 to 79 do
     Begin
       Gotoxy(a,11);
       Write('Ä');
     end;
   Writeln;
   Flag2:=False;
   Flag:=False;
   a:=0;
   Filenum:=0;
   Num:=0;
   Counter:=0;
   C2:='+';
   Command:='+';
   TextColor(11);
   Gotoxy(1,12);
   Write('Area Number: ');
   TextColor(10);
   Readln(area);
2: TextColor(4);
   Open_Area(Area);
   List_Data;
   Commands;
   Repeat
   GotoXY(1,1);
   Command:=Readkey;
   Command:=Upcase(Command);
   Case Command of
   'A':Begin
         Gotoxy(23,13);
         For a:=1 to 50 do Write(' ');
         Gotoxy(23,13);
         Readln(recs.filename);
       End;
   'B':Begin
         Gotoxy(23,14);
         For a:=1 to 50 do Write(' ');
         Gotoxy(23,14);
         Readln(recs.path);
       End;

   'C':Begin
         Gotoxy(23,15);
         For a:=1 to 50 do Write(' ');
         Gotoxy(23,15);
         Readln(recs.points);
       End;

   'D':Begin
         Gotoxy(23,16);
         For a:=1 to 50 do Write(' ');
         Gotoxy(23,16);
         Readln(recs.sentby);
       End;

   'E':Begin
         Gotoxy(23,17);
         For a:=1 to 50 do Write(' ');
         Gotoxy(23,17);
         Readln(recs.pass);
       End;

   'F':Begin
         Gotoxy(23,18);
         For a:=1 to 50 do Write(' ');
         Gotoxy(23,18);
         Readln(recs.downloaded);
       End;

   'G':Begin
         Gotoxy(23,19);
         For a:=1 to 50 do Write(' ');
         Gotoxy(23,19);
         If Recs.Newfile=TRUE then Recs.Newfile:=False else
         If Recs.Newfile=False then Recs.Newfile:=True;
         Write_Area;
         List_Data;
       End;
   'H':Begin
         Gotoxy(23,20);
         For a:=1 to 50 do Write(' ');
         Gotoxy(23,20);
         If Recs.specialfile=TRUE then Recs.specialfile:=False else
         If Recs.specialfile=False then recs.specialfile:=True;
         Write_Area;
         List_Data;
       End;
   'I':Begin
         Gotoxy(23,21);
         For a:=1 to 50 do Write(' ');
         Gotoxy(23,21);
         Readln(recs.descrip);
       End;
   'J':Begin
         Gotoxy(23,22);
         For a:=1 to 50 do Write(' ');
         Gotoxy(23,22);
         Readln(recs.sendto);
       End;
   'Q':Begin
         Flag:=True;
         Write_Area;
       End;

     'K':Begin
           GotoXy(1,24);Write('                     ');
           Gotoxy(1,24);Write('Erase this file from the disk? ');
           Answer:=Readkey;
           Answer:=Upcase(Answer);
           If Answer='Y' then Erase_Disk_File;
           Gotoxy(1,24);
           Write('Delete this file from area list? ');
           Answer:=Readkey;
           Answer:=Upcase(Answer);
           If Answer='Y' then Delete_file Else Begin
           GotoXy(1,24);Write('                                ');
           End;
           Goto 2;
         End;

     'L':Begin
           Write_Area;
           Format_Data_Area;
           Add_File;
           Close(Infile);
           Format_Data_Area;
           Goto 2;
         End;

     #0:Begin
         C2:=Readkey;
         Case C2 of
           #72:Begin
                 Write_Area;
                 FileNum:=FileNum+1;
                 Format_Data_Area;
                 list_Data;
                 Commands;
               End;

           #80:Begin
                 Write_Area;
                 FileNum:=FileNum-1;
                 Format_Data_Area;
                 list_Data;
                 Commands;
               End;

           #73:Begin
                 Flag2:=True;
                 Write_Area;
                 Goto 1;
                 End;
           #81:Begin
                 Flag2:=True;
                 Write_Area;
                 Goto 1;
                 End;
           End;
   End;
   End;
   Until Flag=True;
  end.
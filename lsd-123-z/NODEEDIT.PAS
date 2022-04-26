Program NodeLists;        (* Generic program to
                             set up the node lists for
                             netmail ver 1.01 *)

Uses Crt,Dos,Gentypes,Configrt,GenSubs,PullTTT5;

Var Node:NodeNetRec;
    Fn:File of NodeNetRec;
    Input:String;
    I,J,Cnt:Integer;
    C:Char;
    TheMenu:Pull_Array;
    Major,Minor:Byte;

Procedure ShowNode;
Begin
  ClrScr;
  WriteLn('Node #',i);
  WriteLn('Node Password        :',node.Pass);
  WriteLn('Node Name            :',Node.Name);
  WriteLn('Node Phone Number    :',Node.Phone);
  WriteLn('Node Baud Rate       :',Node.Baud);
  WriteLn('Node ID Number       :',Node.Node);
  WriteLn;
  WriteLn('Press Any Key to View Bases Netted.');
  C:=ReadKey;
  ClrScr;
  For I:=1 to 255 Do
    If Node.BaseSelection[I] Then WriteLn('Base Id #',I,' is NetWorked.');
  WriteLn;
  Write('Press Any Key to Continue.');
  C:=ReadKey;
  End;  (* End ShowNode *)

Procedure DisplayNodeInformation;
Begin
  ClrScr;
  Write('Which Node to List:[1-',filesize(Fn),']:');
  ReadLn(Input);
  I:=Valu(Input);
  If (I<1) or (I>(FileSize(Fn))) Then Else Begin
  Seek(Fn,I-1);
  Read(Fn,Node);
  ShowNode;
  End; (* End If then Begin *)
End; (* End DisplayNodeInformation *)

Procedure InitializeThisStuff;
Begin
  ReadConfig;
  Assign(Fn,ConfigSet.ForumDi+'NodeList.BBS');
  If Exist (ConfigSet.ForumDi+'NodeList.BBS') then
    Reset(Fn) Else ReWrite(Fn);
  ClrScr;
  WriteLn('L.S.D. BBS Cheap and Sleazy Node Editor Version 1.20');
  GotoXy(24,23);
  Write('Press Any Key To Continue');
  C:=ReadKey;
  ClrScr;
  FillChar(TheMenu,SizeOf(TheMenu),0);
  TheMenu[1]:='\Node Maintenance';
  TheMenu[2]:='List Nodes';
  TheMenu[3]:='Edit a Node';
  TheMenu[4]:='Delete a Node';
  TheMenu[5]:='\Add a Node      ';
  TheMenu[6]:='\About Node Edit ';
  TheMenu[7]:='\Quit Node Editor';
  TheMenu[8]:='\\';
  Major:=1;
  Minor:=1;
End;         (* End InitializeThisStuff *)

Procedure AboutNodeEdit;
Begin
  ClrScr;
  WriteLn('L.S.D. Node Editor Version 1.00 is written using TechnoJocks Toolkit.');
  WriteLn('It was written for the implementation of NetWorking version 1.01 which is');
  WriteLn('A TRUE Bi-Directional NetMail routine.');
  WriteLn('This program will be implemented in a rather condensed form in L.S.D. BBS');
  WriteLn('Some time in the near future. Thank you.');
  GotoXy(24,23);
  Write('Press Any Key to Continue.');
  C:=ReadKey;
End;               (* End AboutNodeEdit *)


Procedure AddNode;
Begin
  ClrScr;
  FillChar(Node,SizeOf(Node),0);
  Write('Enter Node Password:');
  ReadLn(Input);
  If Input='' then Exit;
  Node.Pass:=Input;
  Write('Enter Node Name:');
  ReadLn(Input);
  If Input='' then Exit;
  Node.Name:=Input;
  WriteLn('For this do NOT include any "-"s or "("s');
  Write('Enter Node Phone Number:');
  ReadLn(Input);
  If Input='' then Exit;
  Node.Phone:=Input;
  Write('Enter node Baud Rate (ex:38400):');
  ReadLn(Input);
  If Input='' then Exit;
  If Input='1200' then Node.Baud:=1200;
  If Input='2400' then Node.Baud:=2400;
  If Input='4800' then Node.Baud:=4800;
  If Input='9600' then Node.Baud:=9600;
  If Input='19200' then Node.Baud:=19200;
  If Input='38400' then Node.Baud:=38400;
  Write('Enter Node ID Address:');
  ReadLn(Input);
  If Input='' then Exit;
  Node.Node:=Input;
  ClrScr;
  WriteLn('Now we are going to pick the BASE ID''s to be networked.');
  WriteLn('Just enter the net ID''s that you WISH to pick up and then enter');
  WriteLn('A "0" when you are done.');
   Repeat
     Write('Base Id:');
     ReadLn(Input);
     I:=Valu(Input);
     If (I>0) and (I<256) then Node.BaseSelection[I]:=True;
     If (I>255) or (I<0) then WriteLn('Invalid range!');
   Until I=0; (* End Repeat Loop *)
   Write('Adding node to list...');
   Seek(Fn,FileSize(Fn));
   Write(Fn,Node);
   WriteLn('Completed!');
   WriteLn('Press Any Key to Continue.');
   C:=ReadKey;
  End;               (* End AddNode *)

Procedure DeleteNode;
Begin
  ClrScr;
  Write('Whice Node to Delete [1-',filesize(Fn),']:');
  ReadLn(Input);
  I:=Valu(Input);
  If (I<1) or (I>FileSize(Fn)) then Exit;
  Write('Deleting Node...');
  Dec(I);
  For Cnt:=i to FileSize(Fn)-2 do Begin
    Seek(Fn,Cnt+1);
    Read(Fn,Node);
    Seek(Fn,Cnt);
    Write(Fn,Node);
  End;
  Seek(Fn,FileSize(Fn)-1);
  Truncate(Fn);
  Close(Fn);
  Assign(Fn,Configset.ForumDi+'NodeList.BBS');
  Reset(Fn);
  WriteLn('Deleted.');
  WriteLn;
  WriteLn('Press Any Key to Continue.');
  C:=ReadKey;
End; (* End DeleteNode *)

Procedure EditNode;
Var EditMenu:Pull_Array;
    EMajor,EMinor:Byte;
    NodeNum:Integer;

  Procedure InitEditor;
  Begin
    FillChar(EditMenu,SizeOf(EditMenu),0);
    EMajor:=1;
    Eminor:=1;
    EditMenu[1]:='\General Editing ';
    EditMenu[2]:='Phone Number';
    EditMenu[3]:='Baud Rate';
    EditMenu[4]:='Node Name';
    EditMenu[5]:='Show Node Info';
    EditMenu[6]:='\Specific Editing';
    EditMenu[7]:='Node Password';
    EditMenu[8]:='Node ID Number';
    EditMenu[9]:='\Net Worked Bases';
    EditMenu[10]:='\Quit Editing    ';
    EditMenu[11]:='\\';
  End; (* End InitEditor *)

  Procedure GetPhoneNum;
  Begin
    ClrScr;
    Write('Enter the NEW Phone Number for this Node:');
    ReadLn(Input);
    If Input<>'' then Node.Phone:=Input;
  End;  (* End GetPhoneNum *)

  Procedure GetName;
  Begin
    ClrScr;
    Write('Enter the NEW Name for this Node:');
    ReadLn(Input);
    If Input<>'' then Node.Name:=Input;
  End; (* End GetName *)

  Procedure GetBaud;
  Begin
    ClrScr;
    Write('Enter the New baud Rate for this node:');
    ReadLn(Input);
    If Input='1200' then Node.Baud:=1200
      Else
    If Input='2400' then Node.baud:=2400
      Else
    If Input='4800' then Node.Baud:=4800
      Else
    If Input='9600' then Node.Baud:=9600
      Else
    If Input='19200' then Node.Baud:=19200
      Else
    If Input='38400' then Node.Baud:=38400;
  End; (* End GetBaud *)
  Procedure NodePassword;
  Begin
    ClrScr;
    Write('Enter the NEW Node Password:');
    ReadLn(Input);
    If Input<>'' then Node.Pass:=Input;
  End; (* End NodePassword *)

  Procedure NodeIDNumber;
  Begin
    ClrScr;
    Write('Enter the NEW Node ID Number:');
    ReadLn(Input);
    If Input<>'' then Node.Node:=Input;
  End; (* End NodeIDNumber *)

  Procedure NetBases;
  Begin
    ClrScr;
    WriteLn('To Change the status of a base ID Number to network, just enter the');
    WriteLn('The Base Number to change. When you are finished, just enter a "0"');
    WriteLn;
    Repeat
      Write('Base ID To change:');
      ReadLn(Input);
      I:=Valu(Input);
      If (I>0) and (I<256) then Begin
         Node.BaseSelection[I]:=Not Node.BaseSelection[I];
         If Node.BaseSelection[I] then WriteLn('Base ID:',i,' WILL be networked.')
         Else
         WriteLn('Base ID:',I,'Will NOT be networked.');
      End; (* End Conditional Begin *)
    Until I=0; (* End Repeat Loop *)
  End; (* End NetBases *)

  Begin (* Begin Main EditNode Loop *)
    InitEditor;
    ClrScr;
    Write('Enter the Node to Edit: [1-',filesize(Fn),']:');
    ReadLn(Input);
    I:=Valu(Input);
    If (I<1) or (I>FileSize(Fn)) then Else Begin
      Seek(Fn,I-1);
      Read(Fn,Node);
      NodeNum:=i-1;
      Repeat  (* Begin Main Repeat Loop *)
        ClrScr;
        Pull_Menu(EditMenu,Emajor,Eminor);
        Case EMajor of
          1:Case Eminor of
              1:GetPhoneNum;
              2:GetBaud;
              3:GetName;
              4:ShowNode;
            End; (* End Eminor case *)
          2:Case Eminor of
              1:NodePassword;
              2:NodeIDNumber;
             End; (* End Case Eminor *)
          3:NetBases;
        End; (* End Case *)
      Until Emajor=4; (* End Main Repeat Loop *)
    Seek(Fn,NodeNum);
    Write(Fn,Node);
  End; (* End Conditional IF Then *)
End; (* End EditNode *)


Begin
 InitializeThisStuff;
 Repeat
 ClrScr;
 Pull_Menu(TheMenu,Major,Minor);
 Case Major of
   1:Case Minor of
      1:DisplayNodeInformation;
      2:EditNode;
      3:DeleteNode;
      End; (* End Case *)
   2:AddNode;
   3:AboutNodeEdit;
 End;  (* End Case *)
 Until Major=4;  (* End Repeat Loop *)
 ClrScr;
 WriteLn('Thank you for Choosing L.S.D. BBS Software!');
 GotoXy(23,10);
 WriteLn('Cheap and Sleazy Node Editor');
 GotoXy(22,11);
 WriteLn('Written by Ken Sallot (c) 1990');
 Close(Fn);
End.        (* End Program *)




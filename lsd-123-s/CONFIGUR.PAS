{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }

unit configur;

interface

uses windows,gentypes,userret,gensubs,subs1,subs2,flags;

procedure configure;

implementation

procedure configure;

const colorstr:array [0..7] of string[7]=
        ('Black','Blue','Green','Cyan','Red','Magenta','Brown','White');

procedure options (c:configtype; var prompt,onstr,offstr:lstr);

  procedure ret (x1,x2,x3:lstr);
  begin
    prompt:=x1;
    onstr:=x2;
    offstr:=x3
  end;

begin
  case c of
    linefeeds:ret('Require line feeds','Yes','No');
    eightycols:ret('Screen width','80','40');
    postprompts:ret('Post prompts during newscan','Yes','No');
    moreprompts:ret('Pause every screen','Yes','No');
    asciigraphics:ret('Use IBM graphics characters','Yes','No');
    showtime:ret('Display time left at prompts','Yes','No');
    lowercase:ret('Upper/lower case','Yes','No');
    fseditor:ret('Use full-screen editor','Yes','No')
  end
end;

function getattrib (fg,bk:integer; hi,bl:boolean):byte;
begin
  getattrib:=fg+(byte(hi) shl 3)+(bk shl 4)+(byte(bl) shl 7)
end;

procedure getcolorvar (attr:byte; var fg,bk:integer; var hi,bl:boolean);
begin
  fg:=attr and 7;
  hi:=(attr and 8)=8;
  bk:=(attr shr 4) and 7;
  bl:=(attr and 128)=128
end;

procedure getthing (c:configtype);
var n:integer;
    name,onstr,offstr:lstr;
begin
  options (c,name,onstr,offstr);
  writehdr (name);
  write ('Current setting: '^S);
  if c in urec.config then write (onstr) else write (offstr);
  writeln (^B^M^M'Would you like:');
  writeln ('  1. ',onstr);
  writeln ('  2. ',offstr);
  writestr (^M'Your choice:');
  n:=valu(input);
  if (n>0) and (n<3) then begin
    if n=2
      then urec.config:=urec.config-[c]
      else urec.config:=urec.config+[c];
    writeurec
  end
end;

procedure writecolorstr (a:byte);
var fg,bk:integer;
    hi,bl:boolean;
begin
  getcolorvar (a,fg,bk,hi,bl);
  ansicolor (a);
  if bl then write ('Blinking ');
  if hi then write ('Highlighted ');
  write (colorstr[fg]);
  if bk>0 then write (' on ',colorstr[bk]);
  ansicolor(urec.regularcolor);
end;

function colorval (str:mstr):integer;
var cnt:integer;
begin
  colorval:=-1;
  if match(str,'None') then begin
    colorval:=0;
    exit
  end;
  for cnt:=0 to 7 do
    if match(str,colorstr[cnt]) then begin
      colorval:=cnt;
      exit
    end
end;

procedure badcolor;
var cnt:integer;
begin
  write ('Invalid color!  Valid colors are:'^M'Black, ');
  for cnt:=1 to 5 do begin
    ansicolor (cnt);
    write (colorstr[cnt],', ');
    end;
    writeln;
    for cnt:=6 to 7 do begin
    ansicolor(cnt);
    write(colorstr[cnt]);
    if cnt=7
      then writeln ('.');
    if cnt=6
      then write(', and ');
  end;
  writestr ('')
end;

procedure getmacros;
var n:integer;
begin
     writestr(^M^P'Which Macro to change [1-3]: *');
     if input='' then exit;
     n:=valu(input);
     if (n<1) or (n>3) then writeln(^M'Invalid Range!');
     writestr(^M'Enter new macro (Return=no change) : *');
     if input='' then exit;
     if (n=1) then urec.macro1:=input;
     if (n=2) then urec.macro2:=input;
     if (n=3) then urec.macro3:=input;
end;

procedure getcolor (prompt:mstr; var a:byte);

  procedure getacolor (var q:integer; prompt:mstr);
  var n:integer;
  begin
    repeat
      writestr ('Enter new '+prompt+' color:');
      if hungupon or (length(input)=0) then exit;
      n:=colorval(input);
      if n=-1
        then badcolor
        else q:=n
    until n<>-1
  end;

var fg,bk:integer;
    hi,bl:boolean;
begin
  if not (ansigraphics in urec.config) then begin
    writestr ('You must have ANSI emulation to see color.');
    exit
  end;
  getcolorvar (a,fg,bk,hi,bl);
  write ('Current ',prompt,' color: ');
  writecolorstr (a);
  writestr (^M^M);
  getacolor (fg,'foreground');
  getacolor (bk,'background');
  writestr ('Highlight the characters? *');
  hi:=yes;
  writestr ('Should the characters blink? *');
  bl:=yes;
  a:=getattrib (fg,bk,hi,bl)
end;

procedure emulation;
begin
  writeln (^B^M'Note:  ANSI is required for color.');
  writeln (    '       ANSI is required for the full-screen editor.');
  writeln;
  writeln (^B'Please choose your terminal type.'^M^M,
           '   1. ANSI Color'^M,
           '   2. None'^M);
  writestr ('Emulation type:');
  if length(input)=0 then exit;
  urec.config:=urec.config-[ansigraphics,vt52];
  if valu(input)=1 then urec.config:=urec.config+[ansigraphics];
end;

procedure getdisplaylen;
var v:integer;
begin
  writeln ('Current display length is: '^S,urec.displaylen);
  writestr (^M'Enter new display length:');
  if length(input)=0 then exit;
  v:=valu(input);
  if (v<21) or (v>43)
    then writeln ('Invalid!')
    else urec.displaylen:=v
end;

procedure configurenewscan;
var bd:boardrec;
    bn:integer;
    ac:accesstype;
begin
  opentempbdfile;
  seek (bdfile,0);
  for bn:=0 to filesize(bdfile)-1 do begin
    read (bdfile,bd);
    if (bd.conference=0) or (urec.confset[bd.conference]>0) then
    begin
    ac:=getuseraccflag(urec,bn);
    if (ac=letin) or ((ulvl>=bd.level) and (ac=bylevel)) then begin
      writestr ('Newscan '+bd.boardname+' (now '+
                yesno(not (bn in urec.newscanconfig))+'):');
      if length(input)<>0 then
        if yes
          then urec.newscanconfig:=urec.newscanconfig-[bn]
         else urec.newscanconfig:=urec.newscanconfig+[bn];
      end
  end;
  end;
  closetempbdfile
end;

procedure showit (s,v:lstr);
begin
  if break then exit;
  write(^R);
  tab (s+':',30);
  writeln (^S,v)
end;

procedure showthing (c:configtype);
var n:integer;
    name,onstr,offstr:lstr;
begin
  if break then exit;
  write(^R);
  options (c,name,onstr,offstr);
  tab (name+':',30);
  write (^S);
  if c in urec.config
    then write (^S,onstr)
    else write (^S,offstr);
  writeln
end;

procedure showemulation;
var q:lstr;
begin
  if ansigraphics in urec.config
    then q:='ANSI'
    else if vt52 in urec.config
      then q:='VT52'
      else q:='None';
  showit ('Terminal type',q)
end;

procedure showdisplaylen;
begin
  showit ('Display length',strr(urec.displaylen))
end;

procedure showcolor (prompt:mstr; attr:byte);
begin
  write(^R);
  if break then exit;
  write(Prompt+':');
  writecolorstr (attr);
  write(^S^M);
end;

Procedure GetMenuType;
Var I:Integer;
Begin
  If Not (AnsiGraphics in Urec.Config) then Begin
    WriteLn(^M^M'You NEED Ansi Graphics in order to choose Pull Down Menus.');
    Exit;
  End;
  Writeln(^M^M^P'Pull Down Menus - In order to use pull down menus you MUST have Ansi Emulation');
  WriteLn('Turned on.'^M^M);
  WriteStr('Would you like to use Ansi Pull Down Menus? *');
  If yes then Urec.Avatar:=1 else Urec.Avatar:=0;
End;

procedure yourstatus;
begin
  clearscr;
  if not (ansigraphics in urec.config) then begin
  tab('',32);
  WriteLn(^S'Your Configuration');
  writeln;
  showthing (linefeeds);
  showthing (eightycols);
  showthing (postprompts);
  showthing (moreprompts);
  showthing (asciigraphics);
  showthing (showtime);
  showthing (lowercase);
  showemulation;
  showthing (fseditor);
  showdisplaylen;
  tab('Macro 1:',30);
  writeln(urec.macro1);
  tab('Macro 2:',30);
  writeln(urec.macro2);
  tab('Macro 3:',30);
  writeln(urec.macro3);
  if ansigraphics in urec.config then begin
    showcolor ('Prompt',urec.promptcolor);
    showcolor ('Input',urec.inputcolor);
    showcolor ('Regular',urec.regularcolor);
    showcolor ('Statistic',urec.statcolor);
    showcolor ('Menu Background',urec.menuback);
    showcolor ('Menu Boarder',urec.menuboard);
    showcolor ('Windows Boarder',urec.blowboard);
    showcolor ('Windows Inside',urec.blowinside);
    Tab('Menu Type:',30);
    Case Urec.Avatar of
      0:WriteLn('Normal Menus');
      1:WriteLn('Pull Down Menus');
    End;
  end;
  end
  Else
    Begin
     ansicolor(urec.menuboard);
     fuckup(1,29,22,3);
     ansicolor(urec.menuback);
     fuckxy(2,30,' Your Configuration ');
     ansicolor(urec.statcolor);
     BlowUp(4,1,39,12);
     printxy(5,3,'');
     showthing(linefeeds);
     printxy(6,3,'');
     showthing(eightycols);
     printxy(7,3,'');
     showthing(postprompts);
     printxy(8,3,'');
     showthing(moreprompts);
     printxy(9,3,'');
     showthing(asciigraphics);
     printxy(10,3,'');
     showthing(showtime);
     printxy(11,3,'');
     showthing(lowercase);
     printxy(12,3,'');
     showthing(fseditor);
     printxy(13,3,'');
     showemulation;
     printxy(14,3,'');
     showdisplaylen;
		 blowup(4,40,40,14);
		 PrintXy(16,49,'¯¯ Color Configuration ®®');
		 printxy(15,42,'');
		 ShowColor('Status Box',urec.statusboxcolor);
		 printxy(14,42,'');
		 showcolor('Windows Highlight',urec.menuhighlight);
     printxy(13,42,'');
     showcolor('Windows Inside',urec.blowinside);
     printxy(12,42,'');
     showcolor('Windows Border',urec.blowboard);
     printxy(11,42,'');
     showcolor('Menu Border',urec.menuboard);
     printxy(10,42,'');
     showcolor('Menu Back',urec.menuback);
     printxy(9,42,'');
     Showcolor('Statistic',urec.statcolor);
     printxy(8,42,'');
     showcolor('Regular',urec.regularcolor);
     printxy(7,42,'');
     showcolor('Input',urec.inputcolor);
     printxy(6,42,'');
     showcolor('Prompt',urec.promptcolor);
     printxy(5,42,'');
     Write(^R'Menu Type:');
     If Urec.Avatar=1 then Write(^S'Pull Down Windows') else Write(^S'Normal Menus');
		 BlowUp(16,1,39,5);
     PrintXy(17,3,'');
     Write(^R'Macro 1:');
     Printxy(18,3,'');
     Write(^R'Macro 2:');
     PrintXy(19,3,'');
     Write(^R'Macro 3:');
     PrintXy(19,11,'');
     Write(^S,Urec.Macro3);
     PrintXy(18,11,'');
     Write(^S,Urec.Macro2);
     printxy(17,11,'');
     write(^S,Urec.Macro1);
     PrintXy(21,1,'');
    end;
end;

var q:integer;
begin
  repeat
    if (not (lowercase in urec.config)) and (ansigraphics in urec.config)
      then begin
        urec.config:=urec.config+[lowercase];
        writestr ('You may not use ANSI in uppercase-only mode.')
      end;
    if (fseditor in urec.config) and
       (urec.config=urec.config-[ansigraphics,vt52])
      then begin
        urec.config:=urec.config-[fseditor];
        writestr ('You may not use the full-screen editor without ANSI or VT52 emulation.')
      end;
		q:=menu ('Configuration','CONFIG','QLWOMGTUEDPIRSNYFBCJKZAHV');
		case q of
			2:getthing (linefeeds);
			3:getthing (eightycols);
			4:getthing (postprompts);
			5:getthing (moreprompts);
			6:getthing (asciigraphics);
			7:getthing (showtime);
			8:getthing (lowercase);
			9:emulation;
			10:getdisplaylen;
			11:getcolor ('prompt',urec.promptcolor);
			12:getcolor ('input',urec.inputcolor);
			13:getcolor ('regular',urec.regularcolor);
			14:getcolor ('statistic',urec.statcolor);
			15:configurenewscan;
			16:yourstatus;
			17:getthing (fseditor);
			18:getcolor ('Menu Boarder',urec.menuboard);
			19:getcolor ('Menu Background',urec.menuback);
			20:getcolor ('Windows Boarder',urec.blowboard);
			21:getcolor ('Windows Inside',urec.blowinside);
			22:getmacros;
			23:GetMenuType;
			24:getcolor('Menu Highlight',urec.menuhighlight);
			25:getcolor('Status Box Color',urec.statusboxcolor);
		end;
		writeurec
  until (q=1) or hungupon
end;

begin
end.

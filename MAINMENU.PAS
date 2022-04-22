{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }

unit mainmenu;

interface

uses crt,dos,
     gentypes,configrt,statret,textret,userret,mailret,
     gensubs,subs1,subs2,windows,
     chatstuf,mainr1,mainr2,overret1;

procedure summonsysop;
procedure offtheforum;

implementation


procedure summonsysop;
var tf:text;
    emt:boolean;
    k:char;
begin
  chatmode:=not chatmode;
  bottomline;
  emt:=sysopisavail;
  if not chatmode then begin
      unsplit;
      chatreason:='';
      writeln(^M'Page off. Use [C] to turn it back on.');
      exit;
      end
  else
    if not sysopisavail then begin
         writestr(^M^P'The SysOp is not here, is this an '^R'Emergency'^P'? *');
         if yes then begin
					 dots:=true;
					 writestr(^M^P'Enter the '^R'EMERGENCY'^P' Chat Password : *');
					 dots:=false;
					 if match(input,configset.emchatp) then emt:=true else
						 Begin
							 Inc(HackAttempts);
							 chatmode:=false;
							 DoHackShit;
							 If HackAttempts=1 then WriteLn(^M^S'Nice Try!'^G);
							 Exit;
						 End;
				 end;
		 end;
			if emt
				then
					begin
						writestr (^M'Enter a short reason: &');
						chatreason:=input;
						if length(input)=0 then begin
							chatmode:=false;
							exit
						end;
						bottomline;
						writelog (1,3,chatreason);
						assign (tf,configset.textfiledi+'Summon');
						reset (tf);
						if ioresult=0 then begin
							while (not (eof(tf) or hungupon)) and chatmode do
								begin
									read (tf,k);
									nobreak:=true;
									if ord(k)=7 then summonbeep else writechar (k);
									if keyhit then begin
										k:=bioskey;
										clearbreak;
										chat (false)
									end
								end;
							textclose (tf)
						end;
						if chatmode
							then writestr (^M'Use [C] again to turn off page.')
					end
				else
					begin
						writeln (^M^P'Sorry, '^R,configset.sysopnam,^P' isn''t available right now!');
            chatmode:=false;
            writelog (1,2,'')
          end;
  clearbreak;
end;

procedure offtheforum;
var q,n:integer;
    tn:file of integer;
    m:message;
    me:mailrec;

Procedure SendFeedBack;
Begin
  me.Line:=Editor(m,false,true,'The SysOp''s','0');
  if me.Line>0 then Begin
    Me.SentBy:=Unam;
    Me.Title:='Log Off Feedback from '+Unam;
    Me.Anon:=False;
    Me.When:=Now;
    AddFeedBack(Me);
  End;
End;    (* End Procedure *)

procedure famousdays;
var mo,da,yr:string[10];
    i:integer;
    todm,todd,tod:string[10];
    tempstr:string[80];
    fn:text;
    ext:string[3];

begin
     if not configset.famday then exit;
     tod:=datestr(now);
     todm:=copy(tod,0,2);          i:=2;
     if pos('/',todm)>0 then begin i:=1;tempstr:='0'+todm[1];todm:=tempstr;end;
     todd:=copy(tod,2+i,2);  i:=1;
     if pos('/',todd)>0 then begin tempstr:='0'+todd[1]; todd:=tempstr; end;
        tod:=copy(datestr(now),length(datestr(now))-1,2);
        case valu(todm) of
         1:ext:='Jan';
         2:ext:='Feb';
         3:ext:='Mar';
         4:ext:='Apr';
         5:ext:='May';
         6:ext:='Jun';
         7:ext:='Jul';
         8:ext:='Aug';
         9:ext:='Sep';
         10:ext:='Oct';
         11:ext:='Nov';
         12:ext:='Dec';
     end;
     If Not Exist(ConfigSet.TextFileDi+'TODAY.'+Ext) then Exit;
     assign(fn,configset.textfiledi+'TODAY.'+ext);
     reset(fn); writeln(^M);
     while not eof(fn) do begin
      readln(fn,tempstr);
      if pos('Birthday',tempstr)>0 then writeln(^P'Famous birthdays for '^S,ext,' ',todd,', 19',tod,^M^R);
      if pos('Events',tempstr)>0 then writeln(^M^M^P'Famous Events for '^S,ext,' ',todd,', 19',tod,^M^R);
         mo:=copy(tempstr,2,2);
         da:=copy(tempstr,4,2);
         yr:=copy(tempstr,6,4);
         if yr='    ' then yr:='19'+tod;
         if (mo=todm) and (da=todd) then writeln(^U,ext,' ',todd,', ',yr,'... ',^R,copy(tempstr,11,60));
      end;
textclose(fn);
end;

begin
  writestr (^R'Leave '^S+configset.shortnam+^R' now? [N]:');
  if yes then begin
  if ulvl>=configset.msg2nx then begin
    writestr (^R'Leave message to next user? [N]:');
    if yes then begin
      q:=editor(m,false,false,'0','0');
      if q>=0 then begin
        if tonext>=0 then deletetext (tonext);
        tonext:=q;
        end
      end;
    end;
    WriteStr(^R'Leave a Message to the SysOp? [N]:');
    If Yes then SendFeedBack;
        famousdays;
        writeln;
        writeln(^S,'You Were Caller # ',streal(numcallers));
        writeln(^S,'You Have Called ',strr(urec.numon)+' Times');
        WriteLn(^S'Total Bytes Sent ',TotalSent);
        WriteLn(^S'Total Bytes Received ',totalrece);
    printfile (configset.textfiledi+'GoodBye');
    disconnect
  end
end;


begin
end.

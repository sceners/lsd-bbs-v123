{$R-,S-,I-,D-,F+,V-,B-,N-,L+ }

unit main;

interface

uses crt,
		 windows,gentypes,modem,gensubs,subs1,subs2,userret,overret1,mainr2,
     about,bulletin,configur,database,doors,email,filexfer,mycomman,voting,
     mainmenu,gfile1,others;

procedure mainsysopcommands;
procedure mainmenuproc;
procedure breakout;

implementation

procedure mainsysopcommands;
var q:integer;
begin
	if not getsysoppwd then begin
		 Inc(HackAttempts);
		 DoHackShit;
		 exit;
		 end;
  repeat
		q:=menu ('Sysop','SYSOP','QTEANDUCIJSKVMFRZPLB*');
		case q of
			2:editoldspecs;
			3:readerrlog;
			4:addnews;
			5:editnews;
			6:delerrlog;
			7:editusers;
			8:settime;
			9:infoformhunt;
			10:showallforms;
			11:viewsyslog;
			12:delsyslog;
			13:showallsysops;
			14:makeuser;
			15:readfeedback;
			16:removeallforms;
			17:zapspecifiedusers;
			18:localconfiguration;
			19:Loozerlists;
			20:nodelists;
			21:RemoteDosShell;
		end
	until (q=1) or hungupon
end;

procedure mainmenuproc;
var q,z:integer;
{   mnu:menutype;      Pull down menus commented out.
    topmnu:lrmenutype;  }
begin
{
  topmnu[1]:='Go Somewhere';
  topmnu[2]:='The BBS';
  topmnu[3]:='Other';
  topmnu[4]:='';
                 }
  repeat
    if fromdoor and (returnto='D') then doorsmenu;
    cursection:=mainsysop;
  {  if urec.avatar=0 then } displayrum;
{  if urec.avatar<>0 then begin
    z:=lrmenu (topmnu,4*16+15,1*16+15);
    case z of
      1:begin
          mnu[1]:='About BBS';
          mnu[2]:='Messages';
          mnu[3]:='Databases';
          mnu[4]:='E-Mail';
          mnu[5]:='User Config';
          mnu[6]:='File Section';
          mnu[7]:='BBS List';
          mnu[8]:='Rumor Lists';
          mnu[9]:='Ansi Art';
          mnu[10]:='Infoforms';
          mnu[11]:='Timebank';
          mnu[12]:='Voting Booths';
          mnu[13]:='G-Files';
          mnu[14]:='On-Line Doors';
          mnu[15]:='Conferences';
          mnu[16]:='';
          q:=pulldown (mnu,2*16,15,14,2,30,18,1);
          case q of
            1:aboutthisbbs;
            2:bulletinmenu;
            3:datamenu;
            4:emailmenu;
            5:configure;
            6:udsection;
            7:otherbbs;
            8:rumour;
            9:showscreens;
           10:infoform (callforms);
           11:timebanks;
           12:votingbooth (false);
           13:gfilesection;
           14:doorsmenu;
           15:JumpConference;
          end;
        end;
      2:begin
          mnu[1]:='List Users';
          mnu[2]:='Recent Calls';
          mnu[3]:='Leave Feedback';
          mnu[4]:='Chat W/Sysop';
          mnu[5]:='Read News';
          mnu[6]:='Donation Info';
          mnu[7]:='Leech List';
          mnu[8]:='System Stats';
          mnu[9]:='Modem Stats';
          Mnu[10]:='Top 10 Lists';
          mnu[11]:='';
          q:=pulldown (mnu,2*16,15,40,2,57,13,1);
          case q of
            1:listusers;
            2:showlastcallers;
            3:feedback;
            4:summonsysop;
            5:printnews;
            6:donations;
            7:leechlist;
            8:showsystemstatus;
            9:modemstatus;
          end;
        end;
      3:begin
          mnu[1]:='Get Help';
          mnu[2]:='Change PW';
          mnu[3]:='Raise Req';
          mnu[4]:='Newscan Date';
          mnu[5]:='L.S.D. Ad';
          mnu[6]:='Your Status';
          mnu[7]:='Log Off';
          mnu[8]:='';
          q:=pulldown (mnu,2*16,15,60,2,75,10,1);
          case q of
            1:mainhelp;
            2:changepwd;
            3:requestraise;
            4:setlastcall;
            5:showad;
            6:showuserstats(urec);
            7:offtheforum;
          end;
        end;
     end;   }
    {q:=pulldown (mnu,31,15,1,1,20,18,1);}
   { End Else} Begin
    q:=menu ('Main','MAIN','AMCDEFGHIJKLBNOPQRSTUVWXYZ+-!&$%@.^*=/');
    writeln;
    case q of
      1:aboutthisbbs;
      2:bulletinmenu;
      3:summonsysop;
      4:datamenu;
      5:emailmenu;
      6:feedback;
      7:offtheforum;
      15:gfilesection;
      8:mainhelp;
      9:infoform(callforms);
      10:mycommand;
      11:configure;
      12:listusers;
      13:otherbbs;
      14:printnews;
      16:doorsmenu;
      17:Rumour;
      18:leechlist;
      19:showsystemstatus;
      20:udsection;
      21:Timebanks;
      22:votingbooth (false);
      23:showlastcallers;
      24:transfername;
      25:showuserstats(urec);
      26:setlastcall;
      27:changepwd;
      28:TopTen;
      29:requestraise;
      30:showad;
      31:donations;
      32:mainsysopcommands;
      33:begin
         clearscr;
         writeln(^P'This BBS is registered to :'^R,registo);
         writeln(^P'The BBS Name is           :'^R,registb);
      end;
      34:modemstatus;
      35:showscreens;
      36:JumpConference;
      37:DisplayNodeInfo;
    end ;
    End;
  until hungupon
end;

{$F+}

procedure breakout;
begin
  if (erroraddr=nil) and (exitcode=e_controlbreak) then begin
    textcolor (7);
    textbackground (0);
    updateuserstats (false);
    writeln (direct,' [ Break ]');
    writereturnbat;
    ensureclosed;
    window (1,1,80,25);
    gotoxy (1,25);
    clreol;
		if not carrier then dontanswer;
  end;
  doneexitproc
end;

{$F+}

begin
  addexitproc (@breakout)
end.


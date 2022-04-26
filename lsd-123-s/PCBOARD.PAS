{$R-,S-,I-,D-,F+,V-,B-,L+,O+ }

unit pcboard;

interface

uses crt,dos,
     gentypes,
     Subs1,configrt;

Procedure Definefiles;

implementation

Type Single_87 = System.Single;

Procedure Def_pcbFile;
type

   anystring = string[128];
   longstring = string[255];

   string2   = string[2];
   string8   = string[8];
   string12  = string[12];
   string13  = string[13];
   string20  = string[20];
   string30  = string[30];
   string65  = string[65];
   string72  = string[72];
   string160 = string[160];
   string255 = string[255];

   char2  = array[1..2] of char;
   char3  = array[1..3] of char;
   char4  = array[1..4] of char;
   char5  = array[1..5] of char;
   char6  = array[1..6] of char;
   char7  = array[1..7] of char;
   char8  = array[1..8] of char;
   char9  = array[1..9] of char;
   char10 = array[1..10] of char;
   char11 = array[1..11] of char;
   char12 = array[1..12] of char;
   char13 = array[1..13] of char;
   char14 = array[1..14] of char;
   char15 = array[1..15] of char;
   char16 = array[1..16] of char;
   char19 = array[1..19] of char;
   char24 = array[1..24] of char;
   char25 = array[1..25] of char;
   char30 = array[1..30] of char;
   char32 = array[1..32] of char;
   char45 = array[1..45] of char;
   char128 = array[1..128] of char;

   {layout of the PCBOARD.SYS file while doors are open}
  PCB_sys_rec   = Record             { 128 Bytes for PCBOARD version 14.0  }
         Display  : char2;            { Sysop's Display ON/OFF              }
         Printer  : char2;            { Sysop's Printer ON/OFF              }
         PageBell : char2;            { Sysop's Page Bell ON/OFF            }
         CallAlarm: char2;            { Caller Alarm ON/OFF                 }
         ModemType: char2;            { Error Correcting Modem YES/NO       }
         SysopNext: Char;             { Sysop "Next On" Flag                }
         BaudRate : char5;            { "CONNECT" Baud Rate of Caller       }
         Name     : char25;           { Full Name of Caller   (First & Last)}

         FirstName: char15;           { First Name of Caller                }
         Graphics : Char;             { Graphics Mode of Caller             }
         NodeChat : Char;             { Available for Node Chat YES/NO      }
         BaudOpen : char5;            { Baud Rate to Open Modem at          }

         RecordNum: Integer;           { User's Database Record Number (MKI$)}

         Password : char12;           { Password of Caller                  }
         TimeLogOn: Integer;           { Time User Logged On   (MKI$ minutes)}
         TimeUsed : Integer;           { Time Used Today       (MKI$ minutes)}
         LogOnStr : char5;            { Time User Logged On       (HH:MM:SS)}
         TimeLimit: Integer;           { Daily Time Limit      (MKI$ minutes)}
         ByteLmtDL: Integer;           { Daily Download Limit  (MKI$ K-bytes)}
         ConfExit : Char;              { Conference (Area) User Exited From  }
         ConfFlags: char5;            { Areas User Has "Joined" Today       }
         ConfScan : char5;            { Areas User Has Scanned for New Mail }
         ConfTime : Integer;           { Area "Bonus" Time     (MKI$ minutes)}
         TimeCred : Integer;           { Upload Time Credit    (MKI$ minutes)}
         Language : char4;            { Language Version Being Used         }
         TimeLeft : Integer;           { Session Time Remaining(MKI$ minutes)}
         NodeNum  : Char;              { BBS Node Number That Caller is Using}
         EventTime: char5;            { Scheduled EVENT Time         (HH:MM)}
         EventFlag: char2;            { Is EVENT Time Active?               }
         EventMove: char2;            { Delay EVENT Until User Logs Off?    }
         MsgRecall: char4;            { "Memorized" Message Number    (MKS$)}
         ComPortID: Char;              { Com Port Number (0, 1, 2)           }
         Reserved : char2;            { Reserved for Future Use             }
       End;


   {layout of the USERS.PCB file}
   pcb_user_rec = record
      name:          char25;
      city:          char24;
      passwd:        char12;      {no spaces allowed}
      busphone:      char13;
      phone:         char13;
      date:          char8;        {mm-dd-yy of last call}
      time:          char5;        {hh:mm    of last call}
      xpert:         char;         {Y or N}
      protocol:      char;         {X, C, Y, N}
      conferences:   char9;        {10000000}
      inconference:  char;
      rejoin:        char;         {Y or N}
      filedate:      char6;        {yymmdd of last file directory}
      level:         integer;
      total_calls:   integer;
      pagelen:       integer;
      lastread:      array[0..9] of integer;  {for main board & each conf.}
      uploads:       integer;
      downloads:     integer;
      lastused:      integer;            {time used on previous call}
      dead:          char;               {positive delete flag}
   end;

var  deffile:file of pcb_sys_rec;
     outrec:PCB_SYS_REC;
     timer2,timeleft2,logontime2,numout:longint;
     singleout:integer;
     nameout:string[31];
     tl1,tl2:string[2];
     tempbaud:string[4];
     tempt:string[5];
     u:userrec;
     longtemp:longint;
Begin
   assign (deffile,'pcboard.sys'); {info file}
   rewrite(deffile);
   outrec.display:='-1';                 {display on console?  -1 or 0}
   outrec.printer:=' 0';                {print log?           -1 or 0}
   outrec.pagebell:=' 0';               {bother sysop?        -1 or 0}
   outrec.callalarm:=' 0';              {caller alarm sound?  -1 or 0}
   outrec.sysopnext:=' ';                {force sysop on next? 'N ', 'X '
                                           or '  '}
   outrec.modemtype:=' 0';
   if (ansigraphics in urec.config)
         then outrec.graphics:='N'
         else outrec.graphics :=' ';     {ansi graphics mode? '-1',' 0'or'7E'}
      outrec.nodechat:='N';
      if local then tempbaud:=' LOCA' else
         str(baudrate:5,TempBaud);         {caller's baud rate}
         Tempbaud := TempBaud + #0;
	 Move(tempbaud[1],outrec.baudopen[1],5);
      outrec.baudrate:=outrec.baudopen;
      outrec.recordnum:=1;
      move(urec.handle[1],outrec.firstname,15);     {caller's name}
      move(urec.password[1],outrec.password,12);
                         {caller's password (last 2 chars redef'd}
      outrec.timelogon:=logontime;
      outrec.timeused:=configset.usertim[ulvl]-urec.timetoday;{This one was scary}
      str(trunc(logontime DIV 60),tl1);
      str((logontime MOD 60),tl2);
      tempt:=tl1+':'+tl2;                    {time the user logged on in hh:mm}
      move(tempt[1],outrec.logonstr[1],5);
      outrec.timelimit:=configset.usertim[ulvl];
      outrec.bytelmtdl:=0;   {bytes of download limit}
      FillChar(outrec.confexit,2,'0');
      FillChar(outrec.confflags,5,'0');
      FillChar(outrec.confscan,5,'0');
      outrec.conftime:=0;
      outrec.timecred:=0;
      outrec.language:='    ';
      move(urec.handle[1],outrec.name,25);        {caller's name}
      outrec.timeleft:=urec.timetoday;
      outrec.nodenum:='1';
      outrec.eventtime:='00:00';
      outrec.eventflag:='NO';
      outrec.eventmove:='NO';
      outrec.msgrecall:='0001';
      outrec.comportid:='1';     {commport}
      outrec.reserved:='  ';
   write(deffile,outrec);
   close(deffile);
   end;


Procedure dorinfo1;
var        u:userrec;
     deffile:text;
Begin
   assign (deffile,'dorinfo1.def'); {info file}
   rewrite(deffile);
   writeln(deffile,configset.longnam);        {BBS name}
   writeln(deffile,'Martin');                   {sysop first name}
   writeln(deffile,'Roachkiller');                          {sysop last name}
   if local
   then
     writeln(deffile,'LOCAL')
   else
     writeln(deffile,'COM',configset.useco);                      {COMM port}
   writeln(deffile,baudrate,' BAUD,N,8,1');      {baudrate^BAUD,N,n,x}
   writeln(deffile,'0');                         {network type }
   writeln(deffile,unam);                        {user first name}
   writeln(deffile,' ');                         {user last name}
   writeln(deffile,' ');                         {user city,state}
   if (ansigraphics in urec.config) then         {0 no graphics }
    writeln(deffile,'2') else writeln(deffile,'0'); {1-ascii  2-ansi}
   writeln(deffile,ulvl);                        {user level}
   writeln(deffile,timeleft);                    {time remaining}
   writeln(deffile,'0');                         {EOF must have}
textclose(deffile);
end;



procedure def_user;
var     deffile:text;
        temptime : integer;
Begin
   assign (deffile,'USERINFO.TXT'); {info file}
   rewrite(deffile);
   writeln(deffile,unam);                        {user first name}
   writeln(deffile,baudrate);
if parity then
   writeln(deffile,'7')
          else
   writeln(deffile,'8');
if timeleft > 60 then temptime := 60 else temptime := timeleft;
   writeln(deffile,temptime*60);                 {time remaining}
   writeln(deffile,'0');                         {EOF must have}
textclose(deffile);
end;

Procedure Definefiles;
begin
  def_pcbfile;
  dorinfo1;
  def_user;
end;


begin
end.

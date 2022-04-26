{$R-,S-,I-,D-,F+,V-,B-,N-,L+ }
unit gentypes;       (* General Structures for L.S.D. BBS *)

interface

uses dos;

const versionnum='1.23';
			NetMailVer=1;
			date='12-23-90';
			lastrevision=950;
      thisversioncode=1;
      maxusers=30000;
      maxmessagesize=100;
      maxlastcallers=20;
      maxtopics=10;
      maxcats=10;
      sectorsize=512;
      numsectors=10000;
      maxcatalogsize=50;
      maxgroupsize=50;
      maxsyslogdat=150;
      maxsyslogsize=1000;
      e_door=3;
      e_controlbreak=9;
      e_badconfig=4;
      e_fatalfileerror=90;
      e_files30=50;
      e_nomodemdrv=2;

{ All of these are extended keystroke values. }
      breakoutchar=    0;   {Control-Break}
      chatchar=        59;  {F1}
      sysopcomchar=    60;  {F2}
      sysnextchar=     65;  {F7}
      timelockchar=    66;  {F8}
      inlockchar=      67;  {F9}
      outlockchar=     68;  {F10}
      printerechochar= 114; {Ctrl-PrtSc}
      availtogglechar= 30;  {Alt-A}
      bottomchar=      48;  {Alt-B}
      texttrapchar=    18;  {Alt-E}
      sysophelpchar=   35;  {Alt-H}
      notimechar=      37;  {Alt-K}
      lesstimechar=    38;  {Alt-L}
      moretimechar=    50;  {Alt-M}
      tempsysopchar=   20;  {Alt-T}
      viewstatchar=    47;  {Alt-S}
      quicknukechar=   49;  {Alt-N}

type anystr=string[255];
     lstr=string[80];
     mstr=string[35];
     sstr=string[15];
     accesstype=(bylevel,keepout,letin,invalid);
     availtype=(available,bytime,notavailable);
     configtype=(lowercase,eightycols,linefeeds,postprompts,moreprompts,
                 asciigraphics,ansigraphics,udsysop,bulletinsysop,votingsysop,
                 emailsysop,doorssysop,mainsysop,databasesysop,wanted,
                 showtime,vt52,fseditor);
     groupclass=(publicgroup,privategroup,personalgroup);
     voteset=array [1..maxtopics] of byte;
     boardorder=array [0..255] of byte;
     conferenceset=array[0..32] of byte;

type userrec=record
       handle,              (* Users Handle *)
       realname:mstr;       (* Users Real Name *)
       password:sstr;       (* Users Password *)
       phonenum:string[10]; (* Users Phone Number *)
       laston:longint;      (* Last Call date in DATEPACK form *)
       numon,               (* Total Calls *)
       timetoday,           (* Time left today *)
       nup,                 (* G-File Uploads *)
       ndn,                 (* G-File Downloads *)
       nbu,                 (* Messages posted *)
       uploads,             (* Uploads *)
       downloads:integer;   (* Downloads *)
       totaltime:real;      (* Total Time spent on system by user *)
       voted:voteset;       (* What the user voted on *)
       udlevel,             (* File Level *)
       udpoints,            (* File Points *)
       level,               (* Main Access Level *)
       emailannounce,       (* Sector for Email Announcement "-1" if none *)
       beepedpwd,           (* Reserved *)
       infoform,            (* Location for Infoform #1 *)
       glevel,              (* G-File Level *)
       gpoints:integer;     (* G-File Points *)
       regularcolor,        (* The following are the users colors. *)
       promptcolor,
       statcolor,
       inputcolor,
       displaylen,
       menuboard,
       menuback,
       blowboard,
       blowinside:byte;
       config:set of configtype;   (* Various config stuff, i.e. Ansi, etc *)
       newscanconfig,              (* Various stuff dealing with message
                                      bases. Do not mess with these. *)
       access1,
       access2:set of byte;
       usernote,                   (* Account Note [Public] *)
       macro1,                     (* Predefined user macros *)
       macro2,
       macro3:mstr;
       upkay,                      (* Upload K *)
       dnkay:longint;              (* Download K *)
       lastbaud,                   (* Last baud rate used *)
       lastlevel,                  (* Last main access level *)
       lastxfer,                   (* Last File Level *)
       lastxferpts:integer;        (* Last File Points *)
       confset:conferenceset;      (* Array [1..32] of byte for the
                                      sub-conferences *)
       hackattempts:integer;       (* Password Hack Attempts *)
       revision:integer;           (* Last Revision Number *)
       lastposts,                  (* Last total messages in system *)
       lastfiles:word;             (* Last total files in system *)
       infoform2,                  (* Location of Infoforms 2-5 *)
       infoform3,
       infoform4,
       infoform5:integer;
       lastread:array [0..255] of word;        (* Message Stuff *)
       expdate:longint;             (* Expiration date in DATEPACK form *)
       timebank:integer;            (* Time stored in Time Bank *)
       lastcalno:word;              (* Last Caller Number *)
       udratio,                     (* Individual Upload/Download Ratio *)
       udkratio,                    (* Individual U/D K Ratio *)
       pcratio:integer;             (* Individual Post/Call Ratio *)
       avatar:byte;                 (* 0=Normal ansi, 1=Pull Down Windows,
                                       2=Avatar (not implemented yet) *)
       timelimits:integer;          (* Daily time limit (0 means normal) *)
       Conf:Array [1..5] of Boolean;   (* Main Conference Flags *)
       LastConf:Byte;                  (* Last Conference user was in *)
			 SpecialSysopNote:Mstr;          (* Special Sysop Note *)
			 MenuHighlight,statusboxcolor:Byte;
			 LastGfiles:Word;
			 dummystr:string[196];           (* Reserved for future use *)
  end;

     userspecsrec=record
       name:String[34];
       Expired:Boolean;
       minlevel,maxlevel,minlaston,maxlaston:integer;
       minpcr,maxpcr:real
     end;

     boardrec=record
       boardname:mstr;
       sponsor:string[34];
       echo:Byte;
       level,autodel:integer;
       shortname:sstr;
       conference:byte
     end;

     Newsrec=Record
        Location:Integer;
        Level:Integer;
        From:mstr;
        When:longint;
        Title:String[28];
        MaxLevel:Integer;
      End;

     BulRec=record                (* Message Header Record *)
        leftby,leftto:String[30];
        title,status:String[30];
        when:longint;
        where:lstr;
        where2:lstr;
        version:byte;
        anon,recieved:boolean;
        line,plevel:integer;
        id:word;
        cnet,fidonet,flag3,flag4,flag5,flag6,flag7,flag8:boolean;
        realname:String[30];
     end;

     NodeNetRec=Record                 (* Node List Record *)
         Pass:Mstr;
         Name:Mstr;
         Phone:string[12];
         Baud:Word;
         LastDate:Longint;
         Celerity,Fido,Cnet,Flag4,Flag5,Flag6:Boolean;
         Node:string[10];
         BaseSelection:Array[1..255] of boolean;
     end;

     rumourec=record
       Rum:lstr;
       frm:mstr;
     end;

     mailrec=record
       title,sentby:mstr;
       when:longint;
       anon,read:boolean;
       sentto,line,fileindex:integer
     end;

     abrec=record
       title,fname:lstr;
       level:integer;
       when:longint
     end;

     catalogrec=record
       nummail,additional:integer;
       mail:array [1..maxcatalogsize] of mailrec
     end;

     grouprec=record
       name:mstr;
       class:groupclass;
       creator,nummembers:integer;
       members:array [1..maxgroupsize] of integer
     end;

     message=record
       text:array [1..maxmessagesize] of lstr;
       title:mstr;
       sendto:mstr;
       note:mstr;
       anon:boolean;
       numlines:integer
     end;

     NetPostRec=Record                (* Net Mail Package Record *)
       NetIdNum:Byte;
       BulletinRec:BulRec;
       MessageRec:Message;
     End;

     topicrec=record
       topicname:lstr;
       numvoted,addlevel:integer;
       mandatory:boolean
     end;

     choicerec=record
       choice:lstr;
       numvoted:integer
     end;

     lastrec=record
       name:mstr;
       callnum:longint;
       when:longint
     end;

     buffer=array [1..sectorsize] of char;

     baserec=record
       numcats,numents,level:integer;
       basename:mstr;
       conference:byte;
       echomail:boolean;
       catnames:anystr
     end;

     entryrec=record
       data:anystr;
       when:longint;
       addedby:integer
     end;

     parsedentry=array [1..maxcats] of anystr;

     udrec=record
       sentby:mstr;
       when,whenrated:longint;
       filename:sstr;
       path:string[50];
       points:integer;
       filesize:longint;
       descrip:lstr;
       downloaded:integer;
       sendto:mstr;
       pass:sstr;
       newfile,specialfile:boolean
     end;

     arearec=record
       name,xmodemdir:lstr;
       sponsor,pass:mstr;
       conference:byte;
       uploadhere,downloadhere:boolean;
       level:integer
     end;

     windowrec=record
       x1,y1,x2,y2,
       cx,cy,color:byte
     end;

     fib=textrec;

     bbsrec=record
        name:mstr;
        baud:string[4];
        phone:string[12];
        typbbs:sstr;
    end;

     doorrec=record
       name:mstr;
       level,numused,info:integer;
       batchname:lstr;
       getparams:boolean;
     end;

     minuterec=record
       started:boolean;
       startedat:integer;
       total:real
     end;

     logrec=record
       menu,subcommand:integer;
       param:string[41];
       when:longint
     end;

     syslogdatrec=record
       menu,subcommand:integer;
       text:mstr
     end;

     gfilerec=record
        gfiledescr:string[75];
        sentby:string[30];
        path:string[50];
        fname:string[30];
        filesize:longint;
        when:longint;
        downloaded:integer;
        arcname:lstr;
        specialfile,newfile:boolean;
     end;

     netnode=record
        name,phone:mstr;
        baud:word;
        note:lstr;
     end;

     gfilearea=record
        name:lstr;
        gfiledir:string[49];
        sponsor:string[30];
        level:integer;
        upable:boolean;
        defarc:sstr;
     end;

(*     MenuType=Array[1..24] of Mstr;

     LRMenuType=Array[1..4] of Mstr;     Pull Down Windows Commented *)

     Protorec=record
       key:char;
       desc:string[35];
       cline:string[100];
       exename:string[35];
     end;

		 baudratetype=(b110,b300,b450,b600,b1200,b2400,b4800,b9600,b19200,b38400,b57600);
     baudset=set of baudratetype;

const baudarray:array [b110..b57600] of word=
				 (110,300,450,600,1200,2400,4800,9600,19200,38400,57600);
      versioncodes:array [1..thisversioncode] of string[4]=
        ('1.00');


const firstbaud=b110;
      lastbaud=b57600;

var registo,registb:mstr;
    matrix:anystr;
    totalsent:longint;
    totalrece:longint;
    confilesa:word;
    notvalidas,usedvmode:boolean;

implementation

begin
end.

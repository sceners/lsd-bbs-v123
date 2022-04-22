{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }

unit configrt;      (* Unit to read the config.bbs file *)

interface

uses gentypes;

type configsettype=record
     versioncod:byte;
    longnam,shortnam,sysopnam,forumdi,textdi,uploaddi,boarddi,
    overlaypat,asciidownloa,textfiledi,doordi,
    modemsetupst,modemhangupst,modemdialprefi,modemdialsuffi:lstr;
    defbaudrat:word;
    useco,anonymousleve,numwelcome,mintimeou,
    sysopleve,defudleve,defudpoint,
    normbotcolo,normtopcolo,outlockcolo,splitcolo,statlinecolo,
    uploadfacto:integer;
    privat,autologi,useconmod,escinmsg,bkspinmsg,requireform:boolean;
    dotcha:char;
    supportedrate,downloadrate:baudset;
    availtim,unavailtim,xmodemopentim,xmodemclosetim:sstr;
    usertim:array [1..100] of integer;
    level2n,udlevel2n,udpoints2n,postleve:integer;
    anonymousst,systempasswor:mstr;
    remotedoor,allowdoor:boolean;
    eventtim,eventbatc:sstr;
    directvideomod,checksnowmod,hashaye:boolean;
    fille:array [1..500] of byte;
    matrixtyp:integer;
    syste2,syste3,newuserpas,loginheade:mstr;
    minpc,exemptpc,defleve,deffil,deffp,defgfil,defgp:integer;
    defac:mstr;
    staleve,stapoint,minudrati,minud:integer;
    sysop:mstr;
    normenu,whissl:boolean;
    emchatp,edito,entercha,exitcha,bimodemdi:mstr;
    timepercentbac:integer;
    leechwee,chatmatr,feedmatr:boolean;
    sysopi:mstr;
    sysopo:mstr;
    listleve,lastleve:integer;
    comd1,comd2,comd3,comd4,comd5,comd6,comd7,comd8,prom,
    desc1,desc2,desc3,desc4,desc5,desc6,desc7,desc8:mstr;
    msg2nx:integer;
    demons:boolean;
    demoname:mstr;
    leechud,leechk:integer;
    answ1:mstr;
    usetimebank:boolean;
    totalallowed,levelusetb:integer;
    userume:boolean;
    leveltoaddrume:integer;
    startpriv,stoppriv:sstr;
    privlevel,minfreesp:integer;
    useonelin:boolean;
    netdir:lstr;
    totform:integer;
    inf1,inf2,inf3,inf4,inf5:lstr;
    man2,man3,man4,man5,usezip:boolean;
    workdir:lstr;
    netstart,netend:sstr;
    famday:boolean;
    netstc,netenc:sstr;
    netpas,copre,cosuf:mstr;
    dszlog:mstr;
    logsize:integer;
    defstacolor,definput,defpromp,defreg,defblowbor,defblowin,autouls:integer;
    pointcomp:boolean;
    pathfnme:lstr;
    usems,hangonew:boolean;
    Origin1,Origin2:Mstr;
    HubBBS,MaximumDosShell:Boolean;
    LockOutBaudPass:Mstr;
    UsePrinterLog,SaveScreen:Boolean;
    NumConfs:Integer;
    Conf1,Conf2,Conf3,Conf4,Conf5:Mstr;
    NetType1,NetType2,NetType3:Boolean;
    NetType1Path:Mstr;
    shownewprompts,multinodebbs:boolean;
		nodenumber:integer;
		gatepass,sys1pwpromp,sys2pwpromp,sys3pwpromp,matnamepromp,mathangup,
		invalidpromp:mstr;
		MinGfileUD,MinGfilePCR:Integer;
end;   { Note this is for these things, I can't add more to the config! }

                                              { up majorily. }


var configset:configsettype;

procedure readconfig;

implementation

procedure readconfig;
var q:file of configsettype;
    i:integer;
    ct:integer;
begin
  assign (q,'Config.BBS');
  reset (q);
  i:=ioresult;
	FillChar(ConfigSet,SizeOf(ConfigSet),0);
	configset.sys1pwpromp:='[System/1] Password:';
	configset.sys2pwpromp:='[System/2] Password:';
	configset.sys3pwpromp:='[System/3] Password:';
	configset.matnamepromp:='Enter your Handle or User Number:';
	configset.MatHangup:='Disconnecting: TTY1';
	configset.invalidpromp:='Invalid Choice!';
	if i=0
		then begin
			read (q,configset);
         end
    else
      begin
        writeln ('CONFIG.BBS not found!  Please configure L.S.D.!');
        halt (5)
      end;
  system.close (q);
  if configset.versioncod<>thisversioncode then begin
    writeln ('According to the version code in CONFIG.BBS, your system was set up using');
    write ('L.S.D. ');
    if (configset.versioncod<1) or (configset.versioncod>thisversioncode)
      then write ('1.0x or 2.0x')
      else write (versioncodes[configset.versioncod]);
    writeln ('.  Please run the appropriate conversion programs to');
    writeln ('convert to this version, ',versionnum,'.');
    halt (e_badconfig)
  end
end;

end.



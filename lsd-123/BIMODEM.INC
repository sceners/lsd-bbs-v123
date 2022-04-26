procedure load_protos;
var tp:protorec;
    ct:integer;
    ft:file of protorec;
    bd,cb:sstr;
    tsc:string[150];

    procedure LoadProt(Var TempPro:ArProtoRec; Var Num:Integer);
    Var C:Char;
    Begin
     Num:=0;
     Repeat
       Inc(Num);
       Read(Ft,Tp);
       TempPro[Num]:=Tp;
       Tsc:='';
       Ct:=0;
       While Ct<>Length(Tp.Cline) do
         Begin
           Inc(Ct);
           If Tp.Cline[Ct]<>'%' then Tsc:=Tsc+Tp.Cline[Ct]
           Else if Ct<Length(Tp.Cline) then
             Begin
               Inc(Ct);
               C:=Tp.Cline[Ct];
               Case C of
                 '1':Tsc:=Tsc+Strr(ConfigSet.UseCo);
                 '2':Tsc:=Tsc+bd;
                 '3':Tsc:=Tsc+cb;
                 '4':Tsc:=Tsc+ConfigSet.DszLog;
               End;
             End;
           End;
           TempPro[Num].Cline:=Tsc;
         Until Eof(Ft);
       Close(Ft);
     End;

    Begin
    if baudrate=38400 then bd:='38400' else bd:=strr(baudrate);
    if connectbaud=38400 then cb:='38400' else cb:=strr(connectbaud);
    if exist(configset.forumdi+'D_Prot.Dat') then begin
      assign(ft,configset.forumdi+'D_Prot.Dat');
      reset(ft);
      loadprot(dproto,totaldownpro);
    End;
  if exist(configset.forumdi+'U_PROT.DAT') then begin
     assign(ft,configset.forumdi+'U_Prot.Dat');
     reset(ft);
     LoadProt(Uproto,totalupro);
end;
end;

function protocaseselection(send:boolean):integer;
var a:mstr;
    i,total:integer;
    K:Char;
    exp:mstr;
begin
  exp:='Download';
  if not send then exp:='Upload';
  total:=totaldownpro;
  if not send then total:=totalupro;
  clearscr;
  writehdr('L.S.D. '+exp+' Protocols');
  i:=1;
  if total=0 then begin writeln(^M^R'No Protocols Exist!'); exit; end;
  a:='';
  while i<=total do begin
    if send then begin
    write(^P'['^R+dproto[i].key+^P'] ');
    tab(dproto[i].desc,35);
    a:=a+dproto[i].key;
    end else begin
    write(^P'['^R+uproto[i].key+^P'] ');
    tab(uproto[i].desc,35);
    a:=a+uproto[i].key;
    end;
    if (i div 2) = (i/2) then writeln;
    inc(i);
  end;
  writestr(^M^M^P'Selection [CR=Abort]:');
  if input='' then begin
     protocaseselection:=0;
     exit;
  end;
  k:=upcase(input[1]);
  protocaseselection:=pos(k,a);
end;

procedure pointcom(name:mstr;pts:integer);
var u:userrec;
    i:integer;
begin
  if not configset.pointcomp then exit;
  writeln(^M^S'Giving '^R,name,' ',pts,^S' File Points!'^M);
  i:=lookupuser(name);
  if i=0 then exit;
  seek(ufile,i);
  read(ufile,u);
  u.udpoints:=u.udpoints+pts;
  seek(ufile,i);
  write(ufile,u);
end;

Function protocolxfer(send,crcmode,ymodem:Boolean;Protocol:Integer;fn:lstr):Integer;
   var TimeAtXfer:longint;


  Procedure Then_Charge;
    Var a,b,c,d,FN1,Sn:String[255];
      cnt,longerthen,junk:Integer;
      Trans:Char;
      CPS,ttt,CompleteBytes,Errors:sstr;
      num3,Num1,num2,Tr1,Tr2:longint;
      FF:Text;
      F2f:file of byte;
    Begin
      protocolxfer:=2;
      if not exist(configset.dszlog) then exit;
      protocolxfer:=0;
      delay(2000);
     writestr(^M^P'Press '^S'[Return]:');
     d:=configset.dszlog;
      Assign(ff,d);
      Reset(ff);
      If Not EoF(ff) Then Begin
        fn1:='';
        ReadLn(ff,c);
        Trans:=c[1];
        longerthen:=0;
        if c[9]<>' ' then longerthen:=1;
        CompleteBytes:=copy (c,3,6+longerthen);
        CPS:=copy (c,20+longerthen,4);
        if cps[1]=' ' then begin
        ttt:=copy(cps,2,3);
        cps:=ttt;
        end;
        Errors:=copy (c,29+longerthen,3);
        textclose(ff);
        Delete(c,1,50+longerthen);
        While (c[1]<>' ') Do Begin
        fn1:=fn1+c[1];Delete(c,1,1);End;While (c[1]=' ') Do Delete(c,1,1);
        sn:=c;
        tr1:=1;
        if connectbaud<>0 then tr1:=(connectbaud div 10);
        Tr2:=TimeAtXfer*tr1;
        WriteLn('Code-> ',trans,' Filename -> ',fn1,' Sn# -> ',completebytes,' Cps -> ',cps);
        trans:=UpCase(trans);    protocolxfer:=0;
        If match('E',trans) Or match('L',trans) Then protocolxfer:=2;
         if protocol<>9 then begin
         assign (f2f,fn);
       if exist (fn) then begin
          reset(f2f);
           num2:=filesize(f2f);close(f2f); end else num2:=1;
          if num2=0 then num2:=1;
           while (length(CompleteBytes)>0) and (completebytes[1]=' ') do
                 delete (completebytes,1,1);
           val(completebytes,num1,Junk);
           num1:=num1*100;
           if num1=0 then num1:=1;
           num3:=num1 div num2; if send then begin
           Writeln (^M'Percent complete=',strlong(num3),'%');
           if num3=100 then protocolxfer:=0;
           if (num3>93) and (num3<100) or (match(trans,'Q')) then begin
            protocolxfer:=0;
            leechzmodem(fn1);
            end;
           end;
           end;
            val(completebytes,num1,Junk);
           addszlog(cps,fn1,send,num1);
           if send then urec.dnkay:=urec.dnkay+(num1 div 1024) else
           if not match(trans,'E') or match(trans,'L') then
            urec.upkay:=urec.upkay+(num1 div 1024);
                        writeurec;
        If Not send Then If match(trans,'E') Or match(Trans,'L') Then
          If exist(fn) Then Begin
            Assign(Ff,fn);
            Erase(Ff);
          End;
      End;

    End;


  Procedure ExecDsz;
    Var a,b,tmnt:anystr;
      ff:File;
      cnt:Integer;
      Tota,X,Y,Z:longint;
    Begin
      b:=configset.dszlog;
        Assign(ff,b);
        If exist(b) Then Erase(ff);
      x:=timepart(now);
      clrscr;
      ansicolor(15);
      write(usr,urec.handle+' is ');
      if send then write(usr,'downloading -') else write(usr,'uploading -');
      writeln(usr,fn);
      bottomline;
   if not send then exec(uproto[protocol].exename,uproto[protocol].cline+' '+fn);
   if send then exec(dproto[protocol].exename,dproto[protocol].cline+' '+fn);
      y:=timepart(now);
      z:=y-x;if z<0 then z:=z+65535;
      TimeAtXfer:=z;
      GoToXY(1,23);
      WriteLn(Usr,^M^M^M);
    End;

  Begin
   protocolxfer:=2;
     starttimer(numminsxfer);
       execdsz;
        protocolxfer:=2;
        Then_Charge;
        stoptimer(numminsxfer);
       writestatus;
    starttimer(numminsused);
  End;

Function batch_download(Protocol,AllTheFiles:Integer;batchdown:batchlist):Integer;
  Var Count:longint;


   Procedure findetcharge(The:lstr);
    Var cnt,oldn:Integer;
      ud:udrec;
      c:string[255];
    Begin
    urec.downloads:=urec.downloads+1;
      For cnt:=1 To AllTheFiles Do Begin
        c:=batchdown[cnt].wholefilename;
        if match(the,c) then begin
        pointcom(batchdown[cnt].by,batchdown[cnt].points);
        count:=count+batchdown[cnt].points;
        oldn:=curarea;
        setarea(batchdown[cnt].area,false);
        seek(udfile,batchdown[cnt].filenum-1);
        read(udfile,ud);
        inc(ud.downloaded);
        seek(udfile,batchdown[cnt].filenum-1);
        write(udfile,ud);
        setarea(oldn,false);
        end Else
          If match(c,the) Then count:=count+batchdown[cnt].points;
      End;
    End;


  Procedure Then_Charge;
    Var c,fn:String[255];
      cnt,longerthen,junk:Integer;
      cps,krad:sstr;
      Trans:Char;
      FF:Text;
      CompleteBytes,sn:longint;
    Begin
      batch_download:=0;
      If Not exist(configset.dszlog) Then exit;
      delay(2300);
      Assign(ff,configset.dszlog);
      Reset(ff);

      Repeat
        If Not EoF(ff) Then Begin
          fn:='';
          ReadLn(ff,c);
          longerthen:=0;
          Trans:=c[1];
          if c[9]<>' ' then longerthen:=1;
          krad:=copy (c,3,6+longerthen);
          cps:=copy(c,20+longerthen,4);
          while (length(krad)>0) and (krad[1]=' ') do delete (krad,1,1);
          val (Krad,completebytes,junk);
          Delete(c,1,50+longerthen);
          While (c[1]<>' ') Do Begin
          fn:=fn+c[1];Delete(c,1,1);End;While (c[1]=' ') Do Delete(c,1,1);
          sn:=completebytes;
          WriteLn('Code-> ',trans,' Filename -> ',fn,' Sn# -> ',sn);
          trans:=UpCase(trans);
          Writelog (15,1,' Code:'+trans+' FN:'+fn);
          If match(trans,'Q') or match(trans,'R') Or match(TRans,'Z') Or match(Trans,'S') Then
          begin
          findetCharge(fn);
          addszlog(cps,fn,true,sn);
          urec.dnkay:=urec.dnkay+(sn div 1024);
          end;
        End;
      Until EoF(ff);textclose(ff);
      batch_download:=count;
    End;


  Procedure ExecDsz;
    Var a,b:anystr;
    tmnt:anystr;
      qq:File;
      cnt:Integer;
      ttt:lstr;
    Begin
     b:=configset.dszlog;
      Assign(qq,b);
      If exist(b) Then Erase(qq);
     if protocol=5 then begin
     if baudrate=38400 then tmnt:='38400' else tmnt:=strr(baudrate);
     a:='p'+strr(configset.useco)+' s'+tmnt+' hf f- l'+configset.dszlog;
     a:=a+' m- n+ w- x+ e'+strr(connectbaud)+' S ';
     end else begin
      if baudrate=38400 then tmnt:='38400' else tmnt:=strr(baudrate);
      a:='port '+strr(configset.useco)+' speed '+tmnt+' est len '+strr(connectbaud)+' s';
      If protocol=1 Then a:=a+'b -k ';
      If protocol=2 Then a:=a+'z  ';
      If protocol=3 Then a:=a+'b -g ';
      If protocol=4 Then a:=a+'z -w -m ';
      if protocol=6 then a:=a+'z -m ';
      end;
      getdir(0,ttt); if ttt[length(ttt)]<>'\' then ttt:=ttt+'\';
      a:=a+'@'+ttt+'filelist.';
      clrscr;ansicolor(15);
      writeln(usr,urec.handle+' is batch x-ferring');
      bottomline;
      if protocol=5 then exec('Puma.Exe',a)
      else exec('dsz.com',a);
      GoToXY(1,23);WriteLn(Usr,^M^M^M);
    End;

  Procedure make_list;
    Var tf:Text;
      cnt,a:Integer;
      d,e:anystr;
    Begin
      d:='FILELIST.';
      Assign(tf,d);
      Rewrite(tf);
      For cnt:=1 To AllTheFiles Do Begin
        d:=batchdown[cnt].wholefilename;
        WriteLn(tf,d);
      End;
      textclose(tf);
    End;

  Begin
  starttimer(numminsxfer);
    count:=0;
    batch_download:=0;
    make_list;
    execdsz;
    delay(1500);
    then_charge;
    stoptimer(numminsxfer);
    writestatus;
    starttimer(numminsused);
  End;


function okudratio:boolean;
var x3:integer;
		slarvdod:boolean;
begin
  okudratio:=false;
  slarvdod:=false;
  if urec.udratio=0 then slarvdod:=true;
	x3:=ratio(urec.uploads,urec.downloads);
	if (ulvl>=configset.exemptpc) or (x3>urec.udratio) then slarvdod:=true;
  okudratio:=slarvdod;
end;

  Function getapath:lstr;
    Var q,r:Integer;
      f:File;
      b:Boolean;
      p:lstr;
    Begin
      getapath:=area.xmodemdir;
      If ulvl<configset.sysopleve Then exit;
      Repeat
        writestr('Upload path [CR for '+^S+area.xmodemdir+^P+']:');
        If hungupon Then exit;
        If Length(Input)=0 Then Input:=area.xmodemdir;
        p:=Input;
        If Input[Length(p)]<>'\' Then p:=p+'\';
        b:=True;
        Assign(f,p+'CON');
        Reset(f);
        q:=IOResult;
        Close(f);
        r:=IOResult;
        If q<>0 Then Begin
          writestr('  Path doesn''t exist!  Create it? *');
          b:=yes;
          If b Then Begin
            MkDir(Copy(p,1,Length(p)-1));
            q:=IOResult;
            b:=q=0;
            If b
            Then writestr('Directory created')
            Else writestr('Unable to create directory')
          End
        End
      Until b;
      getapath:=p
    End;

function okudk:boolean;
var x3:integer;
		slarvdod:boolean;
begin
slarvdod:=false;
okudk:=false;
if urec.udratio=0 then slarvdod:=false;
x3:=ratio(urec.upkay,urec.dnkay);
if (x3>=urec.udkratio) or (ulvl>=configset.exemptpc) then slarvdod:=true;
okudk:=slarvdod;
end;




Procedure AppendBimodem(dirr:char; sendp,getdir:lstr);

var BISEX:file of birec;
    HOMO,FAG:birec;
    DUDE:bistuff absolute homo;
    krad,cnt:integer;
    new:boolean;

begin
    FillChar(homo,sizeof(homo),0);
    FillChar(dude,sizeof(dude),' ');
close(bisex);
assign (bisex,'lsd.pth');
new:=exist('lsd.pth');
if not new then rewrite(bisex) else reset(bisex);
cnt:=filesize(bisex);
     homo.cmdstr:=dirr;
  for cnt:=1 to length(sendp) do    homo.sourcepath[cnt]:=sendp[cnt];
  for cnt:=1 to length(getdir) do   homo.destpath[cnt]:=getdir[cnt];
  homo.REFRESH:='N';
  homo.REPLACE:='N';
  homo.VERIFY:='N';
  homo.DELETE:='N';
  homo.DELETEABORT:='N';
  homo.DIROVERRIDE:='N';
  homo.INCLUDEDIRO:='N';
inc(bpos);
seek (bisex,bpos);
write (bisex,homo);
close(bisex);
end;

 procedure killbimodem;
  var bisex:file of birec;
  begin
   assign (bisex,'lsd.pth');
   if exist('lsd.pth') then erase(bisex);
   bpos:=-1;
  end;


  Function batchupload(Protocol:Integer):Integer;
    Var Count:longint;

    Procedure find_and_charge(The:lstr);
      Var cnt:Integer;
      Begin
        inc(filesinbatch);
        cnt:=filesinbatch;
        batchdown[cnt].wholefilename:=the;
        batchdown[cnt].points:=0;
        batchdown[cnt].mins:=0;
      End;

    Procedure Then_Charge;
      Var a,b,c,d,fn,sn:String[255];
        cnt,longerthen,junk:Integer;
        Trans:Char;
        FF,qq:Text;
        krad,cps:sstr;
        tpp:lstr;
        Completebytes:longint;
      Begin
        filesinbatch:=0;

        batchupload:=0;
        d:=configset.dszlog;
        If Not exist(d) Then exit;
        batchupload:=0;
        Assign(ff,d);
        Reset(ff);
        Repeat
          If Not EoF(ff) Then Begin
            fn:='';
            ReadLn(ff,c);
            Trans:=c[1];
            longerthen:=0;
            if c[9]<>' ' then longerthen:=1;
            cps:=copy(c,20+longerthen,4);
            krad:=copy(c,3,6+longerthen);
            while (length(krad)>0) and (krad[1]=' ')  do delete (krad,1,1);
            val (krad,completebytes,junk);

            Delete(c,1,50+longerthen);
            While (c[1]<>' ') Do Begin
	    if c[1]='/' then c[1]:='\';
            fn:=fn+c[1];Delete(c,1,1);End;While (c[1]=' ') Do Delete(c,1,1);
            sn:=c;
            if protocol=5 then begin
               tpp:=area.xmodemdir+fn;
               fn:=tpp;
            end;
            WriteLn('Code-> ',trans,' Filename -> ',fn,' Sn# -> ',sn);
            trans:=UpCase(trans);
            if (trans='Z') or (trans='R') or (Trans='S') then begin
             urec.upkay:=urec.upkay+(completebytes div 1024);
             addszlog(cps,fn,false,completebytes);
            writeurec;
            end;
            Writelog(15,2,'Code:'+trans+' fN:'+fn);
            If (trans='R') Or (TRans='Z') Or (Trans='S') Then find_and_Charge(fn) Else
              If exist(fn) Then Begin
              Assign(qq,fn);Erase(qq);End;
          End;
        Until EoF(ff);textclose(ff);
        batchupload:=1;
      End;


    Procedure ExecDsz;
      Var a,b:anystr;
        tmnt:anystr;
        qq:File;
        cnt:Integer;
      Begin
        b:=configset.dszlog;
        Assign(qq,b);
        If exist(b) Then Erase(qq);

 if protocol=5 then begin
    if baudrate=38400 then tmnt:='38400' else tmnt:=strr(baudrate);
        a:='p'+strr(configset.useco)+' s'+tmnt+' hf f- l'+configset.dszlog;
        a:=a+' m- n+ w- x+ e'+strr(connectbaud)+' R ';
        end else begin
        if baudrate=38400 then tmnt:='38400' else tmnt:=strr(baudrate);

        a:='port '+Strr(configset.useco)+' speed '+tmnt+' est len '+strr(connectbaud)+' r';
        If protocol=1 Then a:=a+'b -k ';
        If protocol=2 Then a:=a+'z ';
        If protocol=3 Then a:=a+'b -g ';
        If protocol=4 Then a:=a+'z -w ';
 end;
        b:=area.xmodemdir;
        cnt:=Length(b);Delete(b,cnt,1);
        b[3]:='\';

        a:=a+b;
        if protocol=5 then a:=a+'\';
        starttimer(numminsxfer);

    clrscr;
    ansicolor(15);
    writeln(usr,urec.handle+' is batch uploading.');
    bottomline;
     if protocol=5 then
     Exec('puma.exe',a)
      else begin
     exec('dsz.com',a);end;
        stoptimer(numminsxfer);
        GoToXY(1,23);WriteLn(Usr,^M^M^M);
      End;


    Begin
      count:=0;
      filesinbatch:=0;
      execdsz;
      batchupload:=0;
        Then_Charge;
    End;

Function BICHARGE(allthefiles:integer;batchdown:batchlist):Integer;
  Var Count:longint;

  Procedure findetcharge(The:lstr);
    Var cnt:Integer;
         a, b, c    :anystr;
    Begin
      For cnt:=1 To AllTheFiles Do Begin
        c:=batchdown[cnt].wholefilename;
        If match(the,c) Then count:=count+batchdown[cnt].points Else
          If match(c,the) Then count:=count+batchdown[cnt].points;
      End;
    End;


  Procedure Then_Charge;
    Var a,b:String[255];
      cnt:Integer;
      krad:sstr;
      c,d:String[80];
      Trans:Char;
      FN,sn:String[80];
      FF:Text;
      CompleteBytes:longint;
      Junk:integer;
    Begin
      bicharge:=0;
      If Not exist('bimodem.log') Then exit;
      bicharge:=0;
      d:='bimodem.log';
      Assign(ff,d);
      Reset(ff);

      Repeat
        If Not EoF(ff) Then Begin
          fn:='';
          ReadLn(ff,c);
          Trans:=c[12];
          krad:=copy (c,3,6);

          fn:=copy (c,43,length(c));
          while ( ((pos(c,'/')>0) or (pos(c,':')>0 ))) do delete (fn,1,1);
          Writeln (' Code:'+trans+' FN:'+fn);

          If (Trans='S') Then findetCharge(fn);

        End;

      Until EoF(ff);
      textclose(ff);
      bicharge:=count;
    End;


  Begin

    count:=0;
    bicharge:=0;
    then_charge;
  End;

  Procedure beepbeep(ok:Integer);
    Begin
      Delay(500);
      Write(^B^M);
      Case ok Of
        0:Write('Done');
        1:Write('Error Recovery');
        2:Write('Aborted')
      End;
      WriteLn('!'^G^G^M)
    End;

  Function unsigned(i:Integer):Real;
    Begin
      If i>=0
      Then unsigned:=i
      Else unsigned:=65536.0+i
    End;

  Procedure writefreespace(path:lstr);
    Var drive:Byte;
      r:registers;
      csize,free,total:Real;
    Begin
      r.ah:=$36;
      r.dl:=Ord(UpCase(path[1]))-64;
      Intr($21,r);
      If r.ax=-1 Then Begin
        WriteLn('Invalid drive');
        exit
      End;
      csize:=unsigned(r.ax)*unsigned(r.cx);
      free:=csize*unsigned(r.bx);
      total:=csize*unsigned(r.dx);
      if free < 1024*1024 then
         Write (^S, free/1024:0:0 , ^R'KB out of ' )
      else
         Write (^S, free/(1024*1024):0:0 , ^R'MB out of ' ) ;
      if total < 1024*1024 then
         WriteLn (^S, total/1024:0:0 ,^R+'KB' )
      else
         WriteLn (^S, total/(1024*1024):0:0 , ^R'MB' ) ;
      If free/1024<100.0 Then WriteLn(^G^S'*** Danger! Limited file space left!');
    End;

  function enoughfree(path:lstr):boolean;
  var drive:byte;
      r:registers;
      csize,free,total:real;
      kenny:boolean;
      temp2:longint;
  begin
  kenny:=false;
  r.ah:=$36;
  r.dl:=ord(upcase(path[1]))-64;
  intr($21,r);
  if r.ax=-1 then begin
    writeln('Invalid Drive!');
    enoughfree:=kenny;
    exit;
  end;
  csize:=unsigned(r.ax)*unsigned(r.cx);
  free:=csize*unsigned(r.bx);
  temp2:=trunc(free/1024);
  if temp2>configset.minfreesp then kenny:=true;
  enoughfree:=kenny;
  if not kenny then begin
     writeln(^M^S'Sorry, there is not enough free space on the hard drive for this upload.');
     writeln(^S'Please notify the SysOp. Thank you.');
  end;
  end;


  Procedure seekafile(n:Integer);
    Begin
      Seek(afile,n-1)
    End;

  Function numareas:Integer;
    Begin
      numareas:=FileSize(afile)
    End;

  Procedure seekudfile(n:Integer);
    Begin
      Seek(udfile,n-1)
    End;

  Function numuds:Integer;
    Begin
      numuds:=FileSize(udfile)
    End;

  Procedure assignud;
   Var M:Mstr;
    Begin
      Close(udfile);
      m:=ConfigSet.ForumDi+'AREA'+Strr(CurArea);
      If CurrentConference<>1 then M:=M+'.'+Strr(CurrentConference);
      Assign(udfile,m);
    End;

  Function sponsoron:Boolean;
    Begin
      sponsoron:=match(area.sponsor,unam) Or issysop
    End;

  Function PCRatio:Boolean;
	 var  x3:integer;
			SlarvDodE:Boolean;
		Begin
			pcratio:=False;
			slarvdode:=False;
			If urec.pcratio=0 Then slarvdode:=True;
			If slarvdode=True Then Else slarvdode:=False;
			x3:=ratio(urec.nbu,urec.numon);
			If  (x3>=urec.pcratio) Then slarvdode:=True else slarvdode:=false;
	 If sponsoron Or (ulvl>=configset.exemptpc)
				Then
					 slarvdode:=True;
			pcratio:=slarvdode;
    End;

	Procedure yourudstatus;
	 var somestuff:longint;
		Begin
			mens:=true;
			nobreak:=false;
			dontstop:=true;
			clearscr;
			ansicolor(urec.statusboxcolor);
			boxit(1,1,31,3);
			FuckXy(2,3,^P'Your '^F'Upload/Download'^P' Status');
			ansicolor(urec.statusboxcolor);
			boxit(2,50,29,13);
			FuckXy(3,57,^S'[ File Status ]'^M);
			FuckXy(4,52,^P'File Lvl : '^S+Strr(Urec.UdLevel)+^M);
			FuckXy(5,52,^P'File Pts : '^S+Strr(Urec.UDPoints)+^M);
			FuckXy(6,52,^P'Uploads  : '^S+Strr(Urec.Uploads)+^M);
			FuckXy(7,52,^P'Downloads: '^S+Strr(Urec.Downloads)+^M);
			FuckXy(8,52,^P'Ratio    : '^S+Strr(Ratio(Urec.Uploads,Urec.Downloads))+^M);
			FuckXy(9,52,^P'Minimum  : '^S+Strr(Urec.Udratio)+^M);
			FuckXy(10,52,^P'Status   : '^S);
			if ulvl>configset.exemptpc then writeLn('Exempt') else
			 if okudratio then writeln('Passed') else writeLn('Bad!');
			fuckxy(11,52,^P'New Files: '^S);
			somestuff:=gnuf-confilesa;
			if somestuff>0 then writeLn(somestuff) else writeln('None');
			ansicolor(urec.statusboxcolor);
			boxit(12,35,29,8);
			FuckXy(13,40,^S'[ K-Byte Status ]'^M);
			FuckXy(14,50,'             ');
			FuckXy(14,39,^P'Uploaded  : '^S+Strlong(Urec.UpKay)+^M);
			FuckXy(15,37,^P'Downloaded: '^S+StrLong(Urec.DnKay)+^M);
			FuckXy(16,37,^P'Ratio     : '^S+Strr(Ratio(Urec.UpKay,Urec.DnKay))+^M);
			FuckXy(17,37,^P'Minimum   : '^S+Strr(Urec.UdkRatio)+^M);
			FuckXy(18,37,^P'Status    : '^S);
			If Ulvl>ConfigSet.ExemptPc then writeln('Exempt') else
				 if okudk then writeln('Passed') else writeln('Bad!');
			Ansicolor(Urec.StatusBoxColor);
			Boxit(6,10,29,9);
			FuckXy(7,14,^S'[ Post/Call Ratio ]'^M);
			fuckxy(12,35,'   ');
			fuckxy(13,35,' ');
			FuckXy(8,12,^P'Posts    : '^S+Strr(Urec.Nbu)+^M);
			FuckXy(9,12,^P'Calls    : '^S+Strr(Urec.NumOn)+^M);
			FuckXy(10,12,^P'Ratio    : '^S+Strr(Ratio(Urec.Nbu,Urec.NumOn))+^M);
			FuckXy(11,12,^P'Minimum  : '^S+Strr(Urec.PCRatio)+^M);
			FuckXy(12,12,^P'Status   : '^S);
			If Ulvl>ConfigSet.ExemptPc then WriteLn('Exempt')
				else If Not PCRatio then WriteLn('Bad!') else WriteLn('Passed');
			FuckXy(13,12,^P'New Msgs : '^S);
			SomeStuff:=Gnup-conpostsa;
			If SomeStuff>0 then WriteLn(SomeStuff) Else WriteLn('None');
				clearbreak;
				fuckxy(21,1,'');
			end;


procedure modarea;
var a:arearec;
    tmp:sstr;
    tt:char;
    Q:integer;
begin
a:=area;
repeat;
clearscr;
writehdr('Modify Area');
writeln(^P'A. Name       : '+a.name);
writeln(^P'B. Sponser    : '+a.sponsor);
write(^P'C. Upload Here: ');if a.uploadhere then writeln('Yes') else writeln('No');
write(^P'D. Dload Here : ');if a.downloadhere then writeln('Yes') else writeln('No');
Writeln(^P'E. Area Pass  : '+a.pass);
write(^P'F. Conference : ');if a.conference=0 then writeln('None') else writeln(a.conference);
writeln(^P'G. Level      : ',a.level);
writeln(^P'H. Directory  : '+a.xmodemdir);
writestr(^M^R'Command or [Q] to exit : [Q]: *');
if input='' then input:='Q';
tt:=upcase(input[1]);
case upcase(tt) of
 'A':begin
    writestr(^M^R'Enter the new file area name: *');
    if input='' then input:=a.name;
    a.name:=input;
    end;
 'B':begin
      writestr(^M^R'Enter the new sponsor: *');
      if input='' then input:=a.sponsor;
      a.sponsor:=input;
   end;
 'C':begin
     writestr(^M^R'Allow uploads here? *');
     a.uploadhere:=yes;
     end;
 'D':begin
     writestr(^M^R'Allow downloads here? *');
     a.downloadhere:=yes;
     end;
 'E':begin
    writestr(^M^R'File Area Password [N=None] : *');
    if input='' then input:=a.pass;
    if match(input,'N') then input:='';
    a.pass:=input;
    end;
 'F':begin
    writestr(^M^R'Conference Level : [0] : *');
    if input='' then input:='0';
    a.conference:=valu(input);
    end;
 'G':begin
     writestr(^M^R'Access Level [Ret=No Change] : *');
     if input='' then input:=strr(a.level);
     a.level:=valu(input);
     end;
 'H':begin
      writeln;
      a.xmodemdir:=getapath;
    end;
    end
until (tt='Q') or (tt='q') or hungupon;
area:=a;
reset(afile);
seek(afile,curarea-1);
write(afile,a);
end;

procedure doheader;
 begin
  clearscr;
  writeln(^R'['^S'File Section'^R'] ['^S,area.name,^R'] ['^S,curarea,^R']');
  if not (ansigraphics in urec.config) then begin
      tab('#.',4);
      tab('Filename',14);
      tab('Cost',7);
      tab('Filesize',10);
      WriteLn(' Description'^M^M); end else
begin
blowup(2,1,78,3);
printxy(3,2,'#   Filename       Cost  Filesize   Description');
writeln(^M);
end;
nobreak:=false;
dontstop:=false;
end;

procedure doextended;
begin
  clearscr;
  writeln(^U'Extended File Listing of '^R'['^S,area.name,^R'] ['^S,curarea,^R']');
  if not (ansigraphics in urec.config) then begin write('  ');
   tab('#.',4);
   tab('Filename',14);
   tab('Cost',7);
   tab('Date Sent',10);
   Writeln('Times DL''ed  Sent By'); end else
   begin
   blowup(2,1,78,3);
printxy(3,2,'#   Filename       Cost  Date Sent  Times DLed  Sent By');
writeln(^M);
end;
nobreak:=false;
dontstop:=false;
end;


  Function makearea:Boolean;
    Var num,n:Integer;
      a:arearec;
    Begin
      makearea:=False;
      num:=numareas+1;
      n:=numareas;
      writestr('Create area '+^S+strr(num)+^P+' [y/N]? *');
      If yes Then Begin
        writestr('Area name:');
        If Length(Input)=0 Then exit;
        a.name:=Input;
         writestr('Conference [0]:');
          If Length(Input)=0 Then Input:='0';
          a.conference:=valu(Input);
           writestr('Access Level for area :*');
            a.level:=valu(Input);
                writestr('Upload Here? [Y]:');
        if input='' then input:='Y';
        if yes or (input='Y') then a.uploadhere:=true else a.uploadhere:=false;
        writestr('Download here? [Y]:');
        if input='' then input:='Y';
        if yes or (input='Y') then a.downloadhere:=true else a.downloadhere:=false;
        writestr('Entry Password [N=NONE] :');
        if input='N' then input:='';
        If Length(Input)=0 Then Input:='' else input:=upstring(input);
        a.pass:=input;
        writestr('CoSysop ['+^V+unam+^W+']:');
        If Length(Input)=0 Then Input:=unam;
        a.sponsor:=Input;
        a.xmodemdir:=getapath;
        seekafile(num);
        Write(afile,a);
        area:=a;
        curarea:=num;
        assignud;
        Rewrite(udfile);
        WriteLn('Area created');
        makearea:=True;
        writelog(15,4,a.name)
      End
    End;

  Function allowed_in_area(where:arearec):Boolean;
    Var c:Boolean;
    Begin
      c:=False;
        If (where.conference=0 ) Then
          If (where.level<=urec.udlevel) Then
          c:=True;
        If (where.conference>0) Then
          If (urec.confset[where.conference]>0) Then c:=True;
      Allowed_In_Area:=c;
    End;

  Procedure setarea(n:Integer; Showit:boolean);
    Var c:Boolean;
    Procedure nosucharea;
      Begin
        WriteLn(^B'No such area: ',n,'!')
      End;

    Begin
      curarea:=n;
      If (n>numareas) Or (n<1) Then Begin
        nosucharea;
        If issysop
        Then If makearea
          Then setarea(curarea,true)
          Else  setarea(1,true)
        Else setarea(1,true);
      End;
      seekafile(n);
      Read(afile,area);
      If Not(allowed_in_area(area))
      Then If curarea=1
        Then error('User can''t access first area','','')
        Else
          Begin
            nosucharea;
            setarea(1,true);
            exit
          End;
        close(udfile);
      assignud;
      Close(udfile);
      Reset(udfile);
      If IOResult<>0 Then Rewrite(udfile);
     if local or not showit then else begin
     if (curarea>1) and (area.pass<>'') then begin
        Writestr ('Entry Password:');
        if match (area.pass,input)=false then setarea(1,true);
     end; End;
      If Showit then WriteLn(^B^R'Current Area  ['^S,curarea:2,^r'] '^S,area.name,^R,^M);
     end;

  Procedure listareas;
    Var a:arearec;
      cnt:Integer;
    Begin
    clearscr; writehdr(' File Areas ');
    writeln(^R'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
    writeln(^R'³ '^S' #     File Area Name                          Level/Conference'^R' ³');
    writeln(^R'ÃÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´');
      seekafile(1);
      For cnt:=1 To numareas Do Begin
        Read(afile,a);
        If allowed_in_area(a)
        Then begin
        write(^R'³ '^S);
        tab(strr(cnt),4);
        write(^R'³ '^S);
        tab(a.name,42);
        write(^R'³ '^S);
        if (a.conference>0) then tab('Conference '+strr(a.conference),14)
          else tab(strr(a.level),14);
          writeln(^R'³');
        If break Then exit
      End;
    end;
    writeln(^R'ÀÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'^M);
  end;

  Function getareanum:Integer;
    Var areastr:sstr;
      areanum:Integer;
    Begin
      getareanum:=0;
      If Length(Input)>1
      Then areastr:=Copy(Input,2,255)
      Else begin
      listareas;
        Repeat
          writestr(^M'Area # [?]:');
          If Input='?' Then listareas Else areastr:=Input
        Until (Input<>'?') Or hungupon;
        end;
      If Length(areastr)=0 Then exit;
      areanum:=valu(areastr);
      If (areanum>0) And (areanum<=numareas)
      Then getareanum:=areanum
      Else Begin
        writestr('No such area!');
        If issysop Then If makearea Then getareanum:=numareas
      End
    End;

  Procedure getarea;
    Var areanum:Integer;
    Begin
      areanum:=getareanum;
      If areanum<>0 Then setarea(areanum,true)
    End;

  Function getfname(path:lstr;name:mstr):lstr;
    Var l:lstr;
    Begin
      l:=path;
      If Length(l)<>0 Then
        If Not(l[Length(l)] In [':','\']) Then
          l:=l+'\';
      l:=l+name;
  getfname:=l
    End;

  Procedure getpathname(fname:lstr;Var path:lstr;Var name:sstr);
    Var
        _Name: NameStr;
        _Ext : ExtStr ;
    Begin
      FSplit(fname,path,_name,_ext);
      name := _name + _ext ;
    End;

 function candownload(Fsz:longint;pts:integer ):boolean;
 Var t1,t2:longint;
     Dl:boolean;
  begin
  dl:=false;
  if issysop then candownload:=true;
  if issysop then exit;
  if connectbaud=0 then t1:=(2400*timeleft*6) else  t1:=(connectbaud*timeleft*6);
  if (t1>=fsz) or (urec.udpoints>=pts)  then dl:=true;
  if (t1>=fsz) and configset.leechwee then dl:=true;
  candownload:=dl;
  end;

  Procedure listfile(n:Integer;extended:Boolean);
    Var ud:udrec;
      q:sstr;
     path, Filez:anystr; _Name:namestr; _Ext: Extstr;
      Sze:longint;
      ofline:boolean;

    Begin
      seekudfile(n);
      Read(udfile,ud);
        Filez:=getfname(ud.path,ud.filename);
        ofline:=(exist(filez))=false;
        write(' ');
           FSplit(ud.filename,path,_name,_ext);
        write(^P);
        tab(strr(n)+'.',4);
      path:=upcase(_name[1]);
      _name[1]:=path[1];write(^U);
      tab(upstring(_Name),8);  write(upstring(_ext):4,'  ');
      write(^R);
 if (ud.sendto='') then
  If ud.newfile
      Then Write(' New   ')
      Else If ud.specialfile
        Then Write(' Ask   ')
        Else If (ud.points>0)  and (not configset.leechwee)
          Then Write(ud.points:4 , '   ')
          Else Write(' Free  ')
      else begin ansicolor(4);
       if match(ud.sendto,urec.handle) then write(' Take  ')
        else write(' Priv  '); end;
      ansicolor(13); if not extended then begin
     if not exist(ud.path+ud.filename) then tab('[Offline]',10) Else begin
       sze:=ud.filesize; if sze<1024 then
               sze:=1025;
               Write(strlong(sze div 1024)+'k':9,' ');
      end;  write(^U); if ud.descrip='' then ud.descrip:='- No Description Given -';
      WriteLn(' ',copy(ud.descrip,1,39)); end;
      If break Or (Not extended) Then exit;
      tab(datestr(ud.when),10); write(^U);
      tab(strlong(ud.downloaded),4);      ansicolor(14);
      WriteLn(ud.sentby)
    End;


  Function nofiles:Boolean;
    Begin
      If numuds=0 Then Begin
        nofiles:=True;
        writeln(^M'Sorry, no files.')
      End Else nofiles:=False
    End;


{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }

unit overret1;

interface

uses crt,dos, windows,
		 gentypes,modem,configrt,gensubs,subs1,subs2,userret,textret,flags,mainr1;

(*procedure smartnews;*)
procedure help (fn:mstr);
procedure sendmodemstr (ss:anystr; endifcarrier:boolean);
function getlastcaller:mstr;
procedure infoform(num:integer);


implementation

(*
procedure smartnews;
var nfile:file of newsrec;
    line:integer;
    ntemp:newsrec;
    cnt:integer;
    dt1,dt2:datetime;
    show:boolean;
begin
  assign(nfile,'News');
  reset(nfile);
  if ioresult<>0 then exit;
  if filesize(nfile)=0 then begin
    close(nfile);
    exit;
  end;
  cnt:=0;
  while not(eof(nfile) or break or hungupon) do begin
    read(nfile,ntemp);
    inc(cnt);
    if issysop or (ntemp.location>=0) and (ntemp.maxlevel>=urec.level) and (urec.level>=ntemp.level) then

     begin
     unpacktime(ntemp.when,dt1);
     unpacktime(laston,dt2);
     show:=false;
       if (ntemp.when>=laston) then show:=true;
       if show then
       begin
       if ansigraphics in urec.config then begin
       clearscr;
       blowup(1,1,80,4);
       printxy(2,2,' L.S.D. Smart News Item #');
       printzy(2,28,strr(cnt)+' - '+ntemp.title+' from '+ntemp.from);
       writeln;
       printxy(3,2,' Date:           Time:           Level:');
       printzy(3,8,datestr(ntemp.when));
       printzy(3,24,timestr(ntemp.when));
       printzy(3,41,strr(ntemp.level)+' - '+strr(ntemp.maxlevel));
       end else begin
         writeln(^M'L.S.D. Smart News Item #',cnt,' - ',ntemp.title,' From ',ntemp.from);
         writeln('Date: ',datestr(ntemp.when),' Time: ',timestr(ntemp.when),' Levels: ',ntemp.level,' - ',ntemp.maxlevel);
         end;
       writeln(^M);
       printtext(ntemp.location);
       buflen:=0;
       writestr(^P'Press '^S'[Return]'^P' to continue.&');
       end;
    end;
  end;
  close(nfile);
end;  *)

procedure help (fn:mstr);
var tf:text;
    htopic,cnt:integer;
begin
  fn:=configset.textfiledi+fn;
  assign (tf,fn);
  reset (tf);
  if ioresult<>0 then begin
    writestr ('Sorry, no help is availiable!');
    if issysop then begin
      writeln ('Sysop: To make help, create a file called ',fn);
      writeln ('Group the lines into blocks separated by periods.');
      writeln ('The first group is the topic menu; the second is the');
      writeln ('help for topic 1; the third for topic 2; etc.')
    end;
    exit
  end;
  repeat
    textclose (tf);
    assign (tf,fn);
    reset (tf);
    writeln (^M);
    printtexttopoint (tf);
    repeat
      writestr (^M'Topic number [CR quits]:');
      if hungupon or (length(input)=0) then
        begin
          textclose (tf);
          exit
        end;
      htopic:=valu (input)
    until (htopic>0);
    for cnt:=2 to htopic do
      if not eof(tf)
        then skiptopoint (tf);
    if eof(tf)
      then writestr ('Sorry, no help on that topic!')
      else printtexttopoint (tf)
  until 0=1
end;

procedure sendmodemstr (ss:anystr; endifcarrier:boolean);
var cnt,ptr:integer;
    k:char;
label exit;
begin
  ptr:=0;
  while ptr<length(ss) do
    begin
			if keyhit or (carrier=endifcarrier) then goto exit;
      ptr:=ptr+1;
      k:=ss[ptr];
      case k of
				'|':sendchar (^M);
        '~':delay (500);
        '^':begin
              ptr:=ptr+1;
              if ptr>length(ss)
                then k:='^'
                else k:=upcase(ss[ptr]);
              if k in ['A'..'Z']
								then sendchar (chr(ord(k)-64))
								else sendchar(k)
            end;
				else sendchar (k)
      end;
      delay (50);
			while numchars > 0 do writecon (getchar)
    end;
  cnt:=0;
  repeat
		while numchars > 0 do begin
      cnt:=0;
      writecon (getchar)
    end;
    cnt:=cnt+1
	until (cnt=1000) or keyhit or (carrier=endifcarrier);
  exit:
  break:=keyhit
end;

function getlastcaller:mstr;
var qf:file of lastrec;
    l:lastrec;
begin
  getlastcaller:='';
  assign (qf,'Callers');
  reset (qf);
  if ioresult=0 then
    if filesize(qf)>0
      then
        begin
          seek (qf,0);
          read (qf,l);
          getlastcaller:=l.name
        end;
  close (qf)
end;

procedure infoform(num:integer);
var ff:text;
    fn:lstr;
    k:char;
    me:message;
    i:integer;
    teleg:integer;
begin
  writeln;
  fn:=configset.textfiledi+'InfoForm';
  if num>1 then fn:=fn+'.'+strr(num);
  if not exist (fn) then begin
    writestr ('There isn''t an information form right now.');
    if issysop then
      writeln ('Sysop: To make an information form, create a text file',
             ^M'called ',fn,'.  Use * to indicate a pause for user input.');
    exit
  end;
  if ((urec.infoform<>-1) and (num=1)) or ((urec.infoform2<>-1) and (num=2)) or
     ((urec.infoform3<>-1) and (num=3)) or ((urec.infoform4<>-1) and (num=4)) or
     ((urec.infoform5<>-1) and (num=5)) then begin
    writestr ('You have an existing information form!  Replace it? *');
    if not yes then exit;
    if num=1 then teleg:=urec.infoform else if num=2 then teleg:=urec.infoform2 else
    if num=3 then teleg:=urec.infoform3 else if num=4 then teleg:=urec.infoform4 else
    if num=5 then teleg:=urec.infoform5;
    deletetext (teleg);
    if num=1 then urec.infoform:=-1 else if num=2 then urec.infoform2:=-1 else
    if num=3 then urec.infoform3:=-1 else if num=4 then urec.infoform4:=-1 else
    if num=5 then urec.infoform5:=-1;
    writeurec
  end;
  assign (ff,fn);
  reset (ff);
  me.numlines:=1;
  me.title:='';
  me.anon:=false;
  me.text[1]:='Filled out on: '+datestr(now)+' at '+timestr(now);
  while not eof(ff) do begin
    if hungupon then begin
      textclose (ff);
      exit
    end;
    read (ff,k);
    if k='|' then begin
      i:=0;
      read(ff,k);
      i:=valu(k)*10;
      read(ff,k);
      i:=i+valu(k);
      ansicolor(i);
      read(ff,k)
    end;
    if k='@' then begin
       nochain:=true;
       getstr;
       me.numlines:=me.numlines+1;
       me.text[me.numlines]:=input;
       read(ff,k)
    end;
    if k='*' then begin
      repeat
      NoChain:=True;
      getstr;
       if (length(input)=0) and not hungupon then write(^M^G^P'Please Respond!'^G^R':');
      until length(input)<>0;
      me.numlines:=me.numlines+1;
      me.text[me.numlines]:=input
    end else writechar (k)
  end;
  textclose (ff);
  if num=1 then urec.infoform:=maketext (me) else if num=2 then urec.infoform2:=maketext(me) else
  if num=3 then urec.infoform3:=maketext(me) else if num=4 then urec.infoform4:=maketext(me) else
  if num=5 then urec.infoform5:=maketext(me);
  writeurec
end;

Begin
end.

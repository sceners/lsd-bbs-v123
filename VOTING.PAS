{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }

unit voting;

interface

uses windows,gentypes,gensubs,subs1,subs2,userret,overret1;

procedure votingbooth (getmandatory:boolean);

implementation

procedure votingbooth (getmandatory:boolean);
var curtopic:topicrec;
    curtopicnum:integer;

  function votefn (n:integer):sstr;
  begin
    votefn:='Votefile.'+strr(n)
  end;

  procedure opentopicdir;
  var n:integer;
  begin
    assign (tofile,'VOTEDIR');
    reset (tofile);
    if ioresult<>0 then begin
      close (tofile);
      n:=ioresult;
      rewrite (tofile)
    end
  end;

  function numtopics:integer;
  begin
    numtopics:=filesize (tofile)
  end;

  procedure opentopic (n:integer);
  var q:integer;
  begin
    curtopicnum:=n;
    close (chfile);
    assign (chfile,votefn(n));
    reset (chfile);
    if ioresult<>0 then begin
      close (chfile);
      q:=ioresult;
      rewrite (chfile)
    end;
    seek (tofile,n-1);
    read (tofile,curtopic)
  end;

  function numchoices:integer;
  begin
    numchoices:=filesize (chfile)
  end;

  procedure writecurtopic;
  begin
    seek (tofile,curtopicnum-1);
    write (tofile,curtopic)
  end;

  procedure listchoices;
  var ch:choicerec;
      cnt:integer;
  begin
    writehdr ('Your Choices');
    seek (chfile,0);
    for cnt:=1 to numchoices do
      begin
        read (chfile,ch);
        writeln (cnt:2,'.  ',ch.choice);
        if break then exit
      end
  end;

  function addchoice:integer;
  var ch:choicerec;
  begin
    addchoice:=0;
    buflen:=70;
    writestr (^M'Enter new choice: &');
    if length(input)<2 then exit;
    addchoice:=numchoices+1;
    ch.numvoted:=0;
    ch.choice:=input;
    seek (chfile,numchoices);
    write (chfile,ch);
    writelog (20,2,ch.choice)
  end;

  procedure getvote (mandatory:boolean);
  var cnt,chn:integer;
      k:char;
      ch:choicerec;
      tmp:lstr;
      a:boolean;
  begin
    if urec.voted[curtopicnum]<>0 then begin
      writeln ('Sorry, can''t vote twice!!');
      exit
    end;
    a:=ulvl>=curtopic.addlevel;
    tmp:=#13+#13+'Your choice [?=List';
    if a then tmp:=tmp+', A to add';
    tmp:=tmp+']:';
    repeat
      writestr (tmp);
      if (length(input)=0) or hungupon then exit;
      chn:=valu(input);
      if chn=0 then begin
        k:=upcase(input[1]);
        if k='?'
          then listchoices
          else if k='A'
            then if a
              then chn:=addchoice
              else writestr ('You may not add choices to this topic!')
      end
    until chn<>0;
    if (chn>numchoices) or (chn<0) then begin
      writeln ('Choice number out of range!');
      exit
    end;
    curtopic.numvoted:=curtopic.numvoted+1;
    writecurtopic;
    seek (chfile,chn-1);
    read (chfile,ch);
    ch.numvoted:=ch.numvoted+1;
    seek (chfile,chn-1);
    write (chfile,ch);
    urec.voted[curtopicnum]:=chn;
    writeurec;
    writeln (^M^S'Thanks for voting!')
  end;

  procedure showresults;
  var cnt,tpos,n:integer;
      ch:choicerec;
      percent:real;
  begin
    if urec.voted[curtopicnum]=0 then begin
      writeln (^M'Sorry, you must vote first!');
      exit
    end;
    seek (chfile,0);
    tpos:=1;
    for cnt:=1 to filesize (chfile) do begin
      read (chfile,ch);
      n:=length(ch.choice)+2;
      if n>tpos then tpos:=n
    end;
    clearscr;
    writehdr ('The results so far');
    seek (chfile,0);
    for cnt:=1 to numchoices do if not break then begin
      read (chfile,ch);
      tab (ch.choice,tpos);
      writeln (ch.numvoted)
    end;
    if numusers>0
      then percent:=100.0*curtopic.numvoted/numusers
      else percent:=0;
    writeln (^M,percent:0:0,'% of ',numusers,' have voted.')
  end;

  procedure listtopics;
  var t:topicrec;
      cnt:integer;
  begin
    writehdr ('Voting Topics');
    seek (tofile,0);
    for cnt:=1 to numtopics do
      if not break then begin
        read (tofile,t);
        writeln (cnt:2,'.  ',t.topicname)
      end
  end;

  procedure addtopic;
  var t:topicrec;
      ch:choicerec;
      u:userrec;
      cnt,tpn:integer;
  begin
    if numtopics>=maxtopics then
      begin
        writeln ('No more room to add a topic!');
        exit
      end;
    tpn:=numtopics+1;
    writestr (^M'Topic name:');
    if length(input)=0 then exit;
    t.topicname:=input;
    t.numvoted:=0;
    writeurec;
    for cnt:=1 to numusers do begin
      seek (ufile,cnt);
      read (ufile,u);
      if u.voted[tpn]<>0
        then
          begin
            u.voted[tpn]:=0;
            seek (ufile,cnt);
            write (ufile,u)
          end
    end;
    readurec;
    writestr (^M'Make all users vote on this topic? *');
    t.mandatory:=yes;
    writestr ('Allow users to add their own choices? *');
    if yes then begin
      writestr ('Level required to add choices? *');
      t.addlevel:=valu(input)
    end else t.addlevel:=maxint;
    seek (tofile,tpn-1);
    write (tofile,t);
    opentopic (tpn);
    writeln (^M^B'Enter choices, blank line to end.');
    cnt:=1;
    repeat
      buflen:=70;
      writestr ('Choice number '+strr(cnt)+': &');
      if length(input)>0 then begin
        cnt:=cnt+1;
        ch.numvoted:=0;
        ch.choice:=input;
        write (chfile,ch)
      end
    until (length(input)=0) or hungupon;
    writeln ('Topic created!');
    writelog (20,3,strr(tpn)+' ('+t.topicname+')')
  end;

  procedure maybeaddtopic;
  begin
    writestr ('Create new topic? *');
    if yes then addtopic
  end;

  procedure selecttopic;
  var ch:integer;
  begin
    input:=copy(input,2,255);
    if input='' then input:=' ';
    repeat
      if length(input)=0 then exit;
      ch:=valu(input);
      if ch>numtopics then begin
        ch:=numtopics+1;
        if issysop then maybeaddtopic;
        if numtopics<>ch then exit
      end;
      if (ch<1) or (ch>numtopics) then begin
        if input='?' then listtopics;
        writestr (^M'Topic number [?=list]:');
        ch:=0
      end
    until (ch>0) or hungupon;
    opentopic (ch)
  end;

  procedure deltopic;
  var un,cnt:integer;
      u:userrec;
      f:file;
      t:topicrec;
      tn:lstr;
  begin
    tn:=' topic '+strr(curtopicnum)+' ('+curtopic.topicname+')';
    writestr ('Delete topic '+tn+'? *');
    if not yes then exit;
    writelog (20,1,tn);
    close (chfile);
    erase (chfile);
    cnt:=ioresult;
    for cnt:=curtopicnum to numtopics-1 do begin
      assign (f,votefn(cnt+1));
      rename (f,votefn(cnt));
      un:=ioresult;
      seek (tofile,cnt);
      read (tofile,t);
      seek (tofile,cnt-1);
      write (tofile,t)
    end;
    seek (tofile,numtopics-1);
    truncate (tofile);
    if curtopicnum<numtopics then begin
      writeln ('Adjusting user voting record...');
      writeurec;
      for un:=1 to numusers do begin
        seek (ufile,un);
        read (ufile,u);
        for cnt:=curtopicnum to numtopics do
          u.voted[cnt]:=u.voted[cnt+1];
        seek (ufile,un);
        write (ufile,u)
      end;
      readurec
    end;
    if numtopics>0 then opentopic (1)
  end;

  procedure removechoice;
  var n:integer;
      delled,c:choicerec;
      cnt:integer;
      u:userrec;
  begin
    n:=valu(copy(input,2,255));
    if (n<1) or (n>numchoices) then n:=0;
    while n=0 do begin
      writestr (^M'Choice to delete [?=list]:');
      n:=valu(input);
      if n=0
        then if input='?'
          then listchoices
          else exit
    end;
    if (n<1) or (n>numchoices) then exit;
    seek (chfile,n-1);
    read (chfile,delled);
    for cnt:=n to numchoices-1 do begin
      seek (chfile,cnt);
      read (chfile,c);
      seek (chfile,cnt-1);
      write (chfile,c)
    end;
    seek (chfile,numchoices-1);
    truncate (chfile);
    curtopic.numvoted:=curtopic.numvoted-delled.numvoted;
    writecurtopic;
    write (^B^M'Choice deleted; updating user voting records...');
    writeurec;
    for cnt:=1 to numusers do begin
      seek (ufile,cnt);
      read (ufile,u);
      u.voted[curtopicnum]:=0;
      seek (ufile,cnt);
      write (ufile,u)
    end;
    readurec;
    writeln (^B'Done.')
  end;

  procedure nexttopic;
  begin
    if curtopicnum=numtopics
      then writeln ('No more topics!')
      else opentopic (curtopicnum+1)
  end;

  procedure voteonmandatory;
  var n:integer;
      t:topicrec;
  begin
    for n:=1 to numtopics do
      if urec.voted[n]=0 then begin
        seek (tofile,n-1);
        read (tofile,t);
        if t.mandatory then begin
          opentopic (n);
          clearbreak;
          nobreak:=true;
          writeln (^M'Mandatory voting topic: ',t.topicname,^M);
          listchoices;
          getvote (true);
          if urec.voted[curtopicnum]<>0 then begin
            writestr (^M'See results? *');
            if yes then showresults
          end
        end
      end
  end;

  procedure sysopvoting;
  var q,dum:integer;
  begin
    writelog (19,1,curtopic.topicname);
    repeat
      q:=menu ('Voting sysop','VSYSOP','QACDR');
      if hungupon then exit;
      case q of
        2:addtopic;
        3:dum:=addchoice;
        4:deltopic;
        5:removechoice;
      end
    until (q=1) or hungupon or (numtopics=0)
  end;

var q:integer;
label exit;
begin
  cursection:=votingsysop;
  opentopicdir;
  repeat
    if numtopics=0 then begin
      if getmandatory then goto exit;
      writeln ('No voting topics right now!');
      if not issysop
        then goto exit
        else
          begin
            writestr ('Make topic #1? *');
            if yes
              then addtopic
              else goto exit
          end
    end
  until (numtopics>0) or hungupon;
  if hungupon then goto exit;
  if getmandatory then begin
    voteonmandatory;
    goto exit
  end;
  opentopic (1);
  writehdr ('The Voting Booths');
  writeln ('Number of topics: ',numtopics);
  repeat
    writeln (^M'Active topic (',curtopicnum,'): ',curtopic.topicname);
    q:=menu ('Voting','VOTING','QS_VLR#*H%@');
    if hungupon then goto exit;
    if q<0
      then
        begin
          q:=-q;
          if q<=numtopics then opentopic (q);
          q:=0
        end
      else
        case q of
          2,8:selecttopic;
          3:nexttopic;
          4:getvote (false);
          5:listchoices;
          6:showresults;
          9:help ('Voting.hlp');
          10:sysopvoting
        end
  until (q=1) or hungupon or (numtopics=0);
  if numtopics=0 then writeln (^B'No voting topics right now!');
  exit:
  close (tofile);
  close (chfile)
end;

begin
end.


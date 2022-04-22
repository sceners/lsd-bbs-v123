{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+}

unit email;

interface

uses windows,gentypes,configrt,gensubs,subs1,subs2,textret,flags,
     mailret,userret,overret1,mainr1,mainr2,others;

procedure opengfile;
procedure autoreply;
procedure editmailuser;
procedure newmailre;
procedure emailmenu;

implementation

var lastread:integer;
    m:mailrec;
    incoming,outgoing:catalogrec;


  procedure addcatalog (var c:catalogrec; var m:mailrec; fpos:integer);
  begin
    m.fileindex:=fpos;
    if c.nummail=maxcatalogsize
      then c.additional:=c.additional+1
      else begin
        c.nummail:=c.nummail+1;
        c.mail[c.nummail]:=m
      end
  end;

  procedure writenummail (var c:catalogrec; txt:mstr);
  begin
    writeln (^B^M'You have ',c.nummail+c.additional,' ',txt,
             ' message',s(c.nummail));
    if c.additional>0
      then writeln ('   Note: Of those, ',
                     numthings (c.additional,'is','are'),' uncataloged.')
  end;

  procedure readcatalogs;
  var m:mailrec;
      cnt:integer;
  begin
    seek (mfile,1);
    incoming.nummail:=0;
    incoming.additional:=0;
    outgoing.nummail:=0;
    outgoing.additional:=0;
    for cnt:=1 to filesize(mfile)-1 do begin
      read (mfile,m);
      if m.sentto=unum
        then addcatalog (incoming,m,cnt);
      if match(m.sentby,unam)
        then addcatalog (outgoing,m,cnt)
    end
  end;

  procedure readit (var m:mailrec);
  begin
  clearscr;
  writeln(^B'[ E-Mail ]');
    write (^B^M'Title:   '^S,m.title,^M'Sent by: '^S);
    if m.anon
      then
        begin
          write (configset.anonymousst);
          if issysop then write (' (',m.sentby,')')
        end
      else write (m.sentby);
    writeln (^M'Sent at: '^S,datestr(m.when),' at ',timestr(m.when));
    writeln;
    ansicolor(urec.regularcolor);
    if not break then printtext (m.line)
  end;

  procedure readincoming (n:integer);
  var m:^mailrec;
      cnt:integer;
  begin
    m:=addr(incoming.mail[n]);
    readit (m^);
    if not (m^.read) then begin
      m^.read:=true;
      seek (mfile,m^.fileindex);
      write (mfile,m^)
    end;
    for cnt:=n+1 to incoming.nummail do
      if match(incoming.mail[cnt].sentby,m^.sentby) then begin
        writeln (^B^M'There''s more mail from ',m^.sentby,'!');
        exit
      end
  end;

  procedure listmail (var c:catalogrec);
  var n:integer;
      u:userrec;
      cnt:integer;
      m:mailrec;
  begin
    write ('Num  ');
    tab ('Title',30);
    write ('New  Sent ');
    if ofs(c)=ofs(incoming) then writeln ('by'^M) else writeln ('to'^M);
    if break then exit;
    for cnt:=1 to c.nummail do if not break then begin
      m:=c.mail[cnt];
      write (cnt:2,'.  ');
      if not break then tab (m.title,30);
      if not break then if m.read then write ('     ') else write ('New  ');
      if match(m.sentby,unam)
        then writeln (lookupuname (m.sentto))
        else writeln (m.sentby)
    end
  end;

  procedure writemail (var c:catalogrec; num:integer);
  begin
    seek (mfile,c.mail[num].fileindex);
    write (mfile,c.mail[num])
  end;

  function checklastread:boolean;
  begin
    if (lastread<0) or (lastread>incoming.nummail) then lastread:=0;
    checklastread:=lastread=0
  end;

  function getmsgnumber (var c:catalogrec; txt:sstr):integer;
  var n:integer;
      inc:boolean;
  begin
    inc:=ofs(c)=ofs(incoming);
    getmsgnumber:=0;
    if c.nummail=0 then begin
      if c.additional>0 then readcatalogs;
      if c.nummail=0 then writestr (^M'Sorry, no mail!');
      if inc then lastread:=0;
      exit
    end;
    input:=copy(input,2,255);
    if length(input)=0
      then if inc
        then n:=lastread
        else n:=0
      else n:=valu(input);
    if (n<1) or (n>c.nummail) then begin
      repeat
        writestr (^M'Message number to '+txt+' [?=list]:');
        if length(input)=0 then exit;
        if input='?' then listmail (c)
      until input<>'?';
      n:=valu(input);
      if (n<1) or (n>c.nummail) then n:=0
    end;
    getmsgnumber:=n
  end;

  procedure deletemail (var c:catalogrec; n:integer);
  begin
    delmail (c.mail[n].fileindex);
    writeln (c.mail[n].title,' by ',c.mail[n].sentby,' deleted.');
    readcatalogs
  end;

  procedure nextmail;
  begin
    lastread:=lastread+1;
    if lastread>incoming.nummail
      then
        begin
          lastread:=0;
          if incoming.additional>0
            then writeln ('You must delete some old mail first!')
            else writeln ('Sorry, no more mail!')
        end
      else readincoming (lastread)
  end;

  procedure readnum (n:integer);
  begin
    if (n<1) or (n>incoming.nummail) then begin
      lastread:=0;
      exit
    end;
    lastread:=n;
    readincoming (n)
  end;

  procedure readmail;
  begin
    readnum (getmsgnumber (incoming,'read'))
  end;

  procedure listallmail;
  begin
    if incoming.nummail>0 then begin
      writehdr ('Incoming mail');
      listmail (incoming)
    end;
    if outgoing.nummail>0 then begin
      writehdr ('Outgoing mail');
      listmail (outgoing)
    end
  end;

  procedure newmailre;
  begin
  close(gfile);
  opengfile;
  readcatalogs;
    lastread:=0;
    repeat
      lastread:=lastread+1;
      if lastread>incoming.nummail then begin
        lastread:=0;
        close(gfile);
        exit
      end;
      if not incoming.mail[lastread].read then begin
        readincoming (lastread);
        repeat
        write(^M^M^S'[CR/Next] [A/Again] [Q/Quit] [R/Reply] [D/Delete] ');
        if urec.level>=configset.sysopleve then write(^S'[E/Edit Sender] ');
        writestr(^S':*');
        if input='' then input:='N';
        if match(input,'R') then autoreply else if match(input,'A') then readincoming(lastread)
        else if match(input,'D') then begin
        deletemail(incoming,lastread);
        lastread:=lastread-1;
        input:='N';
        end else  if (match(input,'E') and (urec.level>=configset.sysopleve)) then editmailuser else
        if match(input,'Q') then begin close(gfile); exit; end;
        until (match(input,'N')) or hungupon;
      end
    until hungupon;
    close(gfile);
  end;

  procedure deleteincoming;
  var n:integer;
  begin
    if checklastread then begin
      n:=getmsgnumber (incoming,'delete');
      if n=0 then exit;
      lastread:=n
    end;
    deletemail (incoming,lastread);
    lastread:=lastread-1
  end;

  procedure killoutgoing;
  var n:integer;
  begin
    n:=getmsgnumber (outgoing,'kill');
    if n<>0 then deletemail (outgoing,n)
  end;

  procedure autoreply;
  var n:integer;
  begin
    if checklastread then begin
      n:=getmsgnumber (incoming,'reply to');
      if n=0 then exit;
      lastread:=n
    end;
    with incoming.mail[lastread] do
      sendmailto (sentby,anon);
    readcatalogs
  end;

  procedure viewoutgoing;
  var n:integer;
  begin
    n:=getmsgnumber (outgoing,'view');
    if n=0 then exit;
    readit (outgoing.mail[n])
  end;

  procedure showinfos;
  var n,info:integer;
  begin
    if checklastread then begin
      n:=getmsgnumber (incoming,'delete');
      if n=0 then exit;
      lastread:=n
    end;
    writestr('Which infoform to view [1-5]: [1]:*');
    if input='' then input:='1';
    info:=valu(input);
    if (info>0) and (info<6) then
    showinfoforms (incoming.mail[lastread].sentby,info)
  end;

  procedure editmailuser;
  var n:integer;
      m:mstr;
  begin
    if checklastread then begin
      n:=getmsgnumber (incoming,'edit the sender');
      if n=0 then exit;
      lastread:=n
    end;
    m:=incoming.mail[lastread].sentby;
    n:=lookupuser (m);
    if n=0 then begin
      writeln (^B^R'User ',m,' not found!');
      exit
    end;
    edituser (n)
  end;

  procedure writecurmsg;
  var b:boolean;
  begin
    b:=checklastread;
    write (^B^M'Current msg: ');
    if lastread=0
      then writeln ('None')
      else with incoming.mail[lastread] do
        writeln ('#',lastread,': ',title,' sent by ',sentby)
  end;

  procedure showannouncement (un:integer);
  var u:userrec;
  begin
    seek (ufile,un);
    read (ufile,u);
    if u.emailannounce>-1 then begin
      writehdr (u.handle+'''s Announcement');
      printtext (u.emailannounce)
    end
  end;

  procedure copymsg (var m:mailrec; un:integer);
  var me:message;
      line:integer;
      b:boolean;
  begin
    me.anon:=m.anon;
    reloadtext (m.line,me);
    me.sendto:='All';
    me.title:='Was from '+m.sentby;
    showannouncement (un);
    writestr ('Add a prologue (A to abort)? *');
    if match(input,'a') then exit;
    if yes then b:=reedit (me,true);
    line:=maketext (me);
    addmail (un,line,me);
    readcatalogs
  end;

  procedure copymail;
  var n,un,line:integer;
  begin
    if checklastread then begin
      n:=getmsgnumber (incoming,'copy');
      if n=0 then exit;
      lastread:=n
    end;
    n:=lastread;
    writestr ('User to copy it to:');
    if length(input)=0 then exit;
    un:=lookupuser (input);
    if un=0 then exit;
    copymsg (incoming.mail[n],un)
  end;

  procedure forwardmail;
  var n,un:integer;
  begin
    if checklastread then begin
      n:=getmsgnumber (incoming,'forward');
      if n=0 then exit;
      lastread:=n
    end;
    n:=lastread;
    writestr ('User to forward it to:');
    if length(input)=0 then exit;
    un:=lookupuser (input);
    if un=0 then exit;
    copymsg (incoming.mail[n],un);
    deletemail (incoming,n)
  end;

  const groupclassstr:array [groupclass] of string[8]=
          ('Public','Private','Personal');

  procedure opengfile;
  begin
  close(gfile);
    assign (gfile,'groups');
    reset (gfile);
    if ioresult<>0 then begin
      close (gfile);
      rewrite (gfile)
    end
  end;

  procedure seekgfile (n:integer);
  begin
    seek (gfile,n-1)
  end;

  function ismember (var g:grouprec; n:integer):boolean;
  var cnt:integer;
  begin
    ismember:=true;
    for cnt:=1 to g.nummembers do
      if g.members[cnt]=n then exit;
    ismember:=false
  end;

  function groupaccess (var g:grouprec):boolean;
  begin
    if issysop then begin
      groupaccess:=true;
      exit
    end;
    groupaccess:=false;
    case g.class of
      publicgroup:groupaccess:=true;
      personalgroup:groupaccess:=g.creator=unum;
      privategroup:groupaccess:=ismember (g,unum)
    end
  end;

  function lookupgroup (nm:mstr):integer;
  var cnt:integer;
      g:grouprec;
  begin
    lookupgroup:=0;
    seekgfile (1);
    for cnt:=1 to filesize(gfile) do begin
      read (gfile,g);
      if groupaccess(g)
        then if match(g.name,nm)
          then begin
            lookupgroup:=cnt;
            exit
          end
    end
  end;

  procedure listgroups;
  var g:grouprec;
      cnt:integer;
  begin
    writestr (^M'Name                          Class'^M);
    if break then exit;
    seekgfile (1);
    for cnt:=1 to filesize(gfile) do begin
      read (gfile,g);
      if groupaccess(g) then begin
        tab (g.name,30);
        writeln (groupclassstr[g.class]);
        if break then exit
      end
    end
  end;

  function getgroupclass:groupclass;
  var k:char;
  begin
    repeat
      input[1]:=#0;
      writestr ('Group class p(U)blic, p(R)ivate, p(E)rsonal:');
      k:=upcase(input[1]);
      if k in ['U','R','E'] then begin
        case k of
          'U':getgroupclass:=publicgroup;
          'R':getgroupclass:=privategroup;
          'E':getgroupclass:=personalgroup
        end;
        exit
      end
    until hungupon;
    getgroupclass:=publicgroup
  end;

  procedure addmember (var g:grouprec; n:integer);
  begin
    if ismember (g,n) then begin
      writestr ('That person is already a member!');
      exit
    end;
    if g.nummembers=maxgroupsize then begin
      writestr ('Sorry, group is full!');
      exit
    end;
    g.nummembers:=g.nummembers+1;
    g.members[g.nummembers]:=n
  end;

  procedure addgroup;
  var g:grouprec;
      un:integer;
  begin
    writestr ('Group name:');
    if (length(input)=0) or (input='?') then exit;
    g.name:=input;
    if lookupgroup (g.name)<>0 then begin
      writestr (^M'Group already exists!');
      exit
    end;
    g.class:=getgroupclass;
    g.creator:=unum;
    g.nummembers:=0;
    writestr ('Include yourself in the group? *');
    if yes then addmember (g,unum);
    writestr (^M'Enter names of members, CR when done'^M);
    repeat
      writestr ('Member:');
      if length(input)>0 then begin
        un:=lookupuser (input);
        if un=0
          then writestr ('User not found!')
          else addmember (g,un)
      end
    until hungupon or (length(input)=0) or (g.nummembers=maxgroupsize);
    seek (gfile,filesize (gfile));
    write (gfile,g);
    writestr (^M'Group created!');
    writelog (13,1,g.name)
  end;

  function maybecreategroup (nm:mstr):integer;
  begin
    writestr ('Create group '+nm+'? *');
    if yes then begin
      addtochain (nm);
      addgroup;
      maybecreategroup:=lookupgroup (nm)
    end else maybecreategroup:=0
  end;

  function getgroupnum:integer;
  var groupname:mstr;
      gn:integer;
      g:grouprec;
  begin
    getgroupnum:=0;
    groupname:=copy(input,2,255);
    repeat
      if length(groupname)=0 then begin
        writestr (^M'  Group name [?=list]:');
        if length(input)=0 then exit;
        if input[1]='/' then delete (input,1,1);
        if length(input)=0 then exit;
        groupname:=input
      end;
      if groupname='?' then begin
        listgroups;
        groupname:=''
      end
    until length(groupname)>0;
    gn:=lookupgroup (groupname);
    if gn=0 then begin
      writestr ('Group not found!');
      gn:=maybecreategroup (groupname);
      if gn=0 then exit
    end;
    seekgfile (gn);
    read (gfile,g);
    if not groupaccess(g)
      then writestr ('Sorry, you may not access that group!')
      else getgroupnum:=gn
  end;

  procedure sendmail;
  var g:grouprec;

    procedure sendit (showeach:boolean);
    var un,line,cnt:integer;
        me:message;

      procedure addit (n:integer);
      begin
        if n<>unum then begin
          if showeach then writeln (lookupuname(n));
          addmail (n,line,me)
        end else deletetext (line)
      end;

    begin
      if g.nummembers<1 then exit;
      writehdr ('Sending mail to '+g.name);
      line:=editor (me,true,true,g.name,'0');
      if line<0 then exit;
      addit (g.members[1]);
      if g.nummembers=1 then exit;
      writeln (^B^M);
      for cnt:=2 to g.nummembers do begin
        un:=g.members[cnt];
        if un<>unum then begin
          line:=maketext (me);
          if line<0 then begin
            writeln (cnt,' of ',g.nummembers,' completed.');
            exit
          end;
          addit (un)
        end
      end;
      readcatalogs
    end;

    procedure sendtogroup;
    var gn:integer;
    begin
      gn:=getgroupnum;
      if gn=0 then exit;
      seekgfile (gn);
      read (gfile,g);
      sendit (true)
    end;

    procedure sendtousers;
    var cnt,un:integer;
    begin
      g.name:=input;
      un:=lookupuser (g.name);
      if un=0 then begin
        writestr (^M'User not found.');
        exit
      end;
      g.nummembers:=1;
      g.members[1]:=un;
      cnt:=1;
      showannouncement (un);
      repeat
        writestr ('Carbon copy #'+strr(cnt)+' to:');
        if length(input)>0 then begin
          un:=lookupuser (input);
          if un=0
            then writestr (^M'User not found!'^M)
            else if ismember (g,un)
              then writestr (^M'User is already receiving a copy!')
              else begin
                cnt:=cnt+1;
                g.nummembers:=cnt;
                g.members[cnt]:=un;
                showannouncement (un)
              end
        end
      until (length(input)=0) or (cnt=maxgroupsize);
      sendit (g.nummembers>1)
    end;

  begin
    writestr ('User to send mail to [''/'' to send Group Mail ]:');
    if length(input)<>0
      then if input[1]='/'
        then sendtogroup
        else sendtousers
  end;

  procedure zippymail;
  var un:integer;
      me:message;
      l:integer;
  begin
    writestr ('Send mail to:');
    if length(input)=0 then exit;
    un:=lookupuser (input);
    if un=0 then begin
      writestr ('No such user!');
      exit
    end;
    l:=editor (me,false,false,input,'0');
    if l<0 then exit;
    me.title:='-----';
    me.anon:=false;
    addmail (un,l,me);
    readcatalogs
  end;

  {overlay} procedure sysopmail;

    function sysopreadnum (var n:integer):boolean;
    var m:mailrec;
        k:char;
        done:boolean;

      procedure showit;
      begin
        clearscr;
        writeln (^B^N^M'Number  '^S,n,
                     ^M'Sent by '^S,m.sentby,
                     ^M'Sent to '^S,lookupuname (m.sentto),
                     ^M'Sent on '^S,datestr(m.when),' at ',timestr(m.when),
                     ^M'Title:  '^S,m.title,^M);
        printtext (m.line);
      end;

      procedure changen (m:integer);
      var r2:integer;
      begin
        r2:=filesize(mfile)-1;
        if (m<1) or (m>r2) then begin
          writestr ('Continue scan at [1-'+strr(r2)+']:');
          m:=valu(input)
        end;
        if (m>=1) and (m<=r2) then begin
          n:=m-1;
          done:=true
        end
      end;

    var q:integer;
    begin
      sysopreadnum:=false;
      seek (mfile,n);
      read (mfile,m);
      showit;
      repeat
        done:=false;
        q:=menu ('E-Mail Scan','ESCAN','QSERDNAC_#');
        if q<0
          then changen (-q)
          else case q of
            1:sysopreadnum:=true;
            2:sendmail;
            3:edituser(lookupuser(m.sentby));
            4:edituser(m.sentto);
            5:delmail(n);
            6,9:done:=true;
            7:showit;
            8:changen (0);
          end
      until (q=1) or done or hungupon
    end;

    procedure someoneelse;
    var t,last:integer;
    begin
      writestr (^M'User name to look at:');
      if (length(input)=0) or hungupon then exit;
      writeln;
      t:=lookupuser (input);
      if t=0 then begin
        writestr ('No such user!');
        exit
      end;
      writelog (14,1,input);
      writestr ('Looking in mailbox...');
      last:=searchmail(0,t);
      if last=0 then writestr ('No mail.');
      while last<>0 do begin
        seek (mfile,last);
        read (mfile,m);
        if sysopreadnum (last) or hungupon then exit;
        last:=searchmail(last,t)
      end;
      writeln (^B^M'No more mail!')
    end;

    procedure scanall;
    var r1,r2:integer;
        u:userrec;
        n:mstr;
    begin
      r2:=filesize(mfile)-1;
      writestr ('Start scanning at [1-'+strr(r2)+']:');
      if length(input)=0 then r1:=1 else r1:=valu(input);
      if (r1<1) or (r1>r2) then exit;
      writelog (14,2,'');
      while r1<filesize(mfile) do begin
        seek (mfile,r1);
        read (mfile,m);
        if m.sentto<>0 then
          if sysopreadnum (r1) then exit;
        r1:=r1+1
      end;
      writeln (^B^M'No more mail!')
    end;

    procedure groupflags;
    var gn,bn,un,cnt:integer;
        bname:sstr;
        ac:accesstype;
        g:grouprec;
        u:userrec;
    begin
      writestr ('Grant all group members access to a sub-board'^M);
      gn:=getgroupnum;
      if gn=0 then exit;
      writestr ('  Sub-board access name/number:');
      writeln;
      bname:=input;
      opentempbdfile;
      bn:=searchboard(bname);
      closetempbdfile;
      if bn=-1 then begin
        writeln ('No such board!');
        exit
      end;
      writelog (14,3,bname);
      for cnt:=1 to g.nummembers do begin
        un:=g.members[cnt];
        writeln (lookupuname(un));
        seek (ufile,un);
        read (ufile,u);
        setuseraccflag (u,bn,letin);
        seek (ufile,un);
        write (ufile,u)
      end
    end;

    procedure deleterange;
    var first,last,num,cnt:integer;
    begin
      writehdr ('Mass Mail Delete');
      parserange (filesize(mfile)-1,first,last);
      if first=0 then exit;
      num:=last-first;
      if num<>1 then begin
        writeln ('Warning! ',num,' pieces of mail will be deleted!');
        writestr ('Are you sure? *');
        if not yes then exit
      end;
      for cnt:=last downto first do begin
        delmail (cnt);
        write (cnt,' ');
        if break then begin
          writestr (^B^M'Aborted!');
          exit
        end
      end;
      writeln
    end;

  var q:integer;
  begin
    repeat
      q:=menu ('Sysop E-Mail','ESYSOP','QLSGD');
      case q of
        2:someoneelse;
        3:scanall;
        4:groupflags;
        5:deleterange;
      end
    until (q=1) or hungupon;
    readcatalogs
  end;

  {overlay} procedure announcement;

    procedure delannouncement;
    begin
      if urec.emailannounce=-1 then begin
        writestr (^M'You don''t HAVE an announcement.');
        exit
      end;
      deletetext (urec.emailannounce);
      urec.emailannounce:=-1;
      writeurec;
      writestr (^M'Deleted.')
    end;

    procedure createannouncement;
    var me:message;
    begin
      if urec.emailannounce>=0 then deletetext (urec.emailannounce);
      urec.emailannounce:=editor (me,false,false,'0','EMAIL');
      writeurec
    end;

  var k:char;
  begin
    if urec.emailannounce>=0
      then showannouncement (unum)
      else writestr ('You don''t have an announcement right now.');
    writestr (^M'C)reate/replace, D)elete, or Q)uit:');
    if length(input)=0 then exit;
    k:=upcase(input[1]);
    case k of
      'D':delannouncement;
      'C':createannouncement
    end
  end;

  {overlay} procedure groupediting;
  var curgroup:integer;
      cg:grouprec;

    procedure selectgroup;
    var n:integer;
        g:grouprec;
    begin
      delete (input,1,1);
      repeat
        if length(input)=0 then writestr ('Select group [?=list]:');
        if length(input)=0 then exit;
        if input='?' then begin
          listgroups;
          n:=0;
          input[0]:=#0
        end else begin
          n:=lookupgroup (input);
          if n=0 then begin
            writestr ('Group not found!');
            exit
          end
        end
      until n>0;
      seekgfile (n);
      read (gfile,g);
      if groupaccess(g) then begin
        curgroup:=n;
        cg:=g
      end else writestr ('You can''t access that group.')
    end;

    function nocurgroup:boolean;
    begin
      nocurgroup:=curgroup=0;
      if curgroup=0 then writestr ('No group as been S)elected!')
    end;

    function notcreator:boolean;
    var b:boolean;
    begin
      if nocurgroup then b:=true else begin
        b:=(unum<>cg.creator) and (not issysop);
        if b then writestr ('You aren''t the creator of this group!')
      end;
      notcreator:=b;
    end;

    procedure writecurgroup;
    begin
      seekgfile (curgroup);
      write (gfile,cg)
    end;

    procedure deletegroup;
    var cnt:integer;
        g:grouprec;
    begin
      if notcreator then exit;
      writestr ('Delete group '+cg.name+': Are you sure? *');
      if not yes then exit;
      writelog (13,2,cg.name);
      for cnt:=curgroup to filesize(gfile)-1 do begin
        seekgfile (cnt+1);
        read (gfile,g);
        seekgfile (cnt);
        write (gfile,g)
      end;
      seek (gfile,filesize(gfile)-1);
      truncate (gfile);
      curgroup:=0
    end;

    procedure listmembers;
    var cnt:integer;
    begin
      if nocurgroup then exit;
      writeln ('Creator:           '^S,lookupuname (cg.creator));
      writeln ('Number of members: '^S,cg.nummembers,^M);
      for cnt:=1 to cg.nummembers do begin
        if break then exit;
        writeln (cnt:2,'. ',lookupuname (cg.members[cnt]))
      end
    end;

    procedure readdmember;
    var n:integer;
    begin
      if notcreator then exit;
      writestr ('User to add:');
      if length(input)=0 then exit;
      n:=lookupuser (input);
      if n=0
        then writestr ('User not found!')
        else begin
          addmember (cg,n);
          writecurgroup
        end
    end;

    procedure removemember;

      procedure removemembernum (n:integer);
      var cnt:integer;
      begin
        cg.nummembers:=cg.nummembers-1;
        for cnt:=n to cg.nummembers do cg.members[cnt]:=cg.members[cnt+1];
        writecurgroup;
        writestr ('Member removed.')
      end;

    var cnt,n:integer;
    begin
      if notcreator then exit;
      repeat
        writestr ('User to remove [?=list]:');
        if length(input)=0 then exit;
        if input='?' then begin
          input[0]:=#0;
          listmembers
        end
      until length(input)>0;
      n:=lookupuser (input);
      if n=0 then begin
        writestr ('User not found!');
        exit
      end;
      for cnt:=1 to cg.nummembers do if cg.members[cnt]=n then begin
        removemembernum (cnt);
        exit
      end;
      writestr ('User isn''t in the group!')
    end;

    procedure setclass;
    begin
      if notcreator then exit;
      writeln ('Current class: '^S,groupclassstr [cg.class],^M);
      cg.class:=getgroupclass;
      writecurgroup
    end;

    procedure setcreator;
    var m:mstr;
        n:integer;
    begin
      if notcreator then exit;
      writeln ('Current creator: '^S,lookupuname(cg.creator),^M);
      writestr ('Enter new creator:');
      if length(input)=0 then exit;
      n:=lookupuser(input);
      if n=0 then begin
        writestr ('User not found!');
        exit
      end;
      cg.creator:=n;
      writecurgroup;
      if (n<>unum) and (not issysop) then curgroup:=0
    end;

    procedure addbylevel;
    var n,cnt:integer;
        u:userrec;
    begin
      if notcreator then exit;
      writestr ('Let in all people over level:');
      n:=valu(input);
      if n=0 then exit;
      seek (ufile,1);
      for cnt:=1 to numusers do begin
        read (ufile,u);
        if (length(u.handle)>0) and (u.level>=n) then begin
          if cg.nummembers=maxgroupsize then begin
            writestr ('Sorry, group is full!');
            exit
          end;
          addmember (cg,cnt)
        end
      end
    end;


  var q:integer;
  begin
    curgroup:=0;
    repeat
      write (^B^M^M^R'Group selected: '^S);
      if curgroup=0
        then writeln ('None')
        else writeln (cg.name);
      q:=menu ('Group editing','GROUP','QS*LGDVMRCAE');
      case q of
        2,3:selectgroup;
        4:listgroups;
        5:addgroup;
        6:deletegroup;
        7:listmembers;
        8:readdmember;
        9:removemember;
        10:setcreator;
        11:setclass;
        12:addbylevel
      end
    until hungupon or (q=1)
  end;

procedure emailmenu;

var q:integer;
begin
  cursection:=emailsysop;
  clearscr;
  if (ansigraphics in urec.config) then begin;
     blowup(2,2,22,3);
     end;
  printxy(3,4,'The Postal Service');
  opengfile;
  readcatalogs;
  printxy(5,4,'');writenummail (incoming,'incoming');
  printxy(6,4,'');writenummail (outgoing,'outgoing');
  if ((incoming.nummail+incoming.additional)>10) and ((outgoing.nummail+outgoing.additional)>10)
  then writeln(^M'What, are you running a Mail Order business or something?'^M);
  lastread:=0;
  repeat
    writecurmsg;
    q:=menu ('E-Mail','EMAIL','QRSLN_%@DKAV#E@CFHGI@Z');
    if q<0
      then readnum (abs(q))
      else case q of
        2:autoreply;
        3:sendmail;
        4:listallmail;
        5:begin
          newmailre;
          opengfile;
          readcatalogs;
          end;
        6:nextmail;
        7:sysopmail;
        8:deleteincoming;
        9:killoutgoing;
        10:announcement;
        11:viewoutgoing;
        13:editmailuser;
        14:copymail;
        15:forwardmail;
        16:help ('Email.hlp');
        17:groupediting;
        18:showinfos;
        19:zippymail
      end
  until hungupon or (q=1);
  close (gfile)
end;

begin
end.

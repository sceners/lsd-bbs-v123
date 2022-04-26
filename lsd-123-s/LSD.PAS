{$M 63000,4800,28000} { note need to change this for config stuff...note the last one WAS 28000 before, am trying something }
{$DEFINE Overlays}

{
       L.S.D. BBS Ver. 1.06 designed and hacked away at by The Slavelord
  and alot of help and ideas from other people.. Thanks go to The Oxidizer
  for being one hell of a good beta site.. Everyone else fuck off..
  The L.S.D. BBS System.. This was a sick concept of mine that I did because
  I wanted an original BBS program. This is the work of TL, LR, Lord Zombie
  and Paradox. We are your gods. You MUST and SHALL obey us. THG Rules!
  Do not give this source out or you shall meet your death. Thank you.
  Version 1.01 Addendums - NETMail Working, ECHOMail Working, Split Screen Chat
	Fixed, External Protocol Editor Working, Doors working, So far, so good.
	9/2/90 Switched to Turbo Pascal 6.0. ONLY use Turbo Pascal 6.0 to
	compile.         }




                                Program BadAcid;
                                                                                {
                             COMPILER DIRECTIVES


 Code    Directive          State          Note
                                                                                }
{$R-        Range checking  Off            Don't change }
{$S-        Stack checking  Off            Makes code larger/slower }
{$I-          I/O checking  Off            Don't change }
{$D-     Debug information  Off            Makes code larger/slower }
{$F+       Force far calls  On            Without this this shit will crash! }
{$V-   Var-string checking  Relaxed        Don't change }
{$B-    Boolean evaluation  Short Cicuit   Don't change }
{$N+    Numeric processing  8087 On        Change if you have an 8087 }
{$L+           Link buffer  Disk           Change if you have enough memory }
{$O+        Allow Overlays  On             Don't change }
{$G+            80286 Mode  On             Don't really know... }
                                                                                {
                                 FORUM-PC UNITS                                 }

Uses
  Crt,      { Turbo Pascal CRT library }
  Dos,      { Turbo Pascal DOS library }
	Printer,  { Turbo Pascal Printer library }
	Overlay,  { Sets up the files to be put in the overlay file. }
	OvrCall,  { Calls the overlay files }
  gentypes, { All type and constant declarations }
  configrt, { Configuration declarations / procedures }
	modem,    { Modem support }
  statret,  { System status declarations / procedures }
  gensubs,  { General subroutines: lowest level }
  subs1,    { First subroutine library }
  windows,  { Routines to manage the split screen }
  subs2,    { Second subroutine library: higer level I/O }
  textret,  { Message base routines }
  mailret,  { E-mail routines }
  userret,  { User routines }
  flags,    { Board access flag routines }            { By the way, some of }
  mainr1,   { High-level routines, set one }          { this organization   }
  ansiedit, { Full-screen editor }                    { made a lot more     }
  lineedit, { Line editor }                           { sense when I had to }
  chatstuf, { Chat mode routines }                    { use overlay files!! }
  mainr2,   { High-level routines, set two }
  overret1, { High-level routines, set three }
  About,    {  About this BBS section }
  Bulletin, {        Bulletin section }
  Configur, {   Configuration section }
  Database, {        Database section }
  Doors,    {            Door section }
  Email,    { Electronic mail section }
  Filexfer, {   File transfer section }
  Voting,   {          Voting section }
  Mycomman, { Generic Shell Routines  }
  MainMenu, { Main menu commands      }
  Main,     { Main menu shell         }
  Waitcall, { Waiting for calls       }
  Getlogin, { Log-in procedure        }
  gfile1,   { G-File Section          }
	Init,     { Initialization routines }
	Others,   { Other Routines (Overlayed), i.e. user routines }
	Subs3,    { Low Level routines #3 used in filexfer. }
	ExecSwap; { Maximum Dos Shell Routines }

{$IFDEF Overlays}
{$O Email}
{$O Init}
{$O Getlogin}
{$O	About}
{$O	Configur}
{$O	Database}
{$O	Doors}
{$O	Voting}
{$O	Mycomman}
{$O GFile1}
{$O Filexfer}
{$O Waitcall}
{$O Bulletin}
{$O Lineedit}
{$O Ansiedit}
{$O Mailret}
{$O Menus}
{$O PCBoard}
{$O Others}
{$ENDIF}


                                                                                  {
There are three reasonable values for LastToSave. Passing the System variable
HeapOrg tells ExecSwap not to save any part of the heap; this is the correct
option for programs that make no use of the heap. Passing HeapPtr causes
ExecSwap to save all allocated portions of the heap. Only the free list is
ignored, so this is a good choice for programs that don't fragment the heap.
Passing the expression Ptr(Seg(FreePtr^)+$1000, 0) tells ExecSwap to save the
entire heap, including the free list. This is the most conservative option,
but it may lead to swap files approaching 640K bytes in size.

                         L.S.D. BBS Systems Main Program                          }



var gotoforumterm:boolean;
begin
  readconfig;
  initializeasync;
  UseEmsIfAvailable:=True;
  If Not InitExecSwap(HeapPtr,'Swap.$$$') Then Begin
    WriteLn('Unable to allocate Swap Space!');
    Delay(1500);
  End;
  local:=FALSE;
  checkbreak:=false;
  validconfiguration;
  initforum(true);
  fromdoor:=paramcount>=3;
  repeat
    gotoforumterm:=false;
    returnfromdoor;
    if not fromdoor then begin
      gotoforumterm:=waitforacall;
       getloginproc
    end;
		if not gotoforumterm then begin
			newmailre;
			if not fromdoor then if tonext>-1 then begin
				WriteHdr('Message from Last User');
				PrintText(tonext);
			if sysopisavail then writehdr(configset.sysopi) else writehdr(configset.sysopo);
			end;
			votingbooth (true);
			mainmenuproc;
      writeln(direct,#27,'[0m');
      fromdoor:=false;
      if not disconnected then disconnect;
      ensureclosed;
      clrscr;
      dontanswer;
      if sysnext then
         begin
           closeport;
           textmode(co80);
           halt(4);
         end;
            initforum (false)
    end
	until not gotoforumterm;
    closeport;
	 halt(0)
end.

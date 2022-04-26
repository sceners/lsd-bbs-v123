program validate;

uses dos,crt;

type
	string15 = String[35];
	SerialType = Record
		id		: string15;
		Sysop : String[80];
		end;

const
	SerialNum : SerialType =
        ( id:'[ Evaluation Copy ]'; Sysop:'[ Unregistered BBS ]');

var
	ch: char;
	s: serialtype;
	x: byte;
	c,new: longint;
	f: file;
	Ser: SerialType;
        dummy:string15;
        shitbags:string15;

procedure Encode(var ser: SerialType);
var tp1:string15;
    tp2:string[80];
    i:integer;
begin
tp1:='';
for i:=1 to length(ser.id) do tp1:=tp1+chr(ord(ser.id[i])+i);
tp2:='';
for i:=1 to length(ser.sysop) do tp2:=tp2+chr(ord(ser.sysop[i])+i);
ser.id:=tp1;
ser.sysop:=tp2;
end;

procedure Decode(var s: SerialType);
begin
end;

procedure GetSerial(var S: SerialType; var c: longint);
var
	f: file;
begin
	assign(f, 'LSD.Exe');
	reset(f,1);
	c:=FileSize(f);
	c:=c-SizeOf(SerialType);
	s.id:='';
	while (c>0) and (s.Id <> SerialNum.ID ) do
		begin
		seek(f,c);
		blockread(f,s,SizeOf(s));
		Dec(c);
		end;
	close(f);
   inc(c);
end;

begin
        clrscr;
        textcolor(15);
				dummy:='Mr. Xerox';
				write('L.S.D. BBS registration utility for ');
				textcolor(14);
				writeln(dummy);
				textcolor(15);
				write('Searching for... ');
				textcolor(13);
				writeln(serialnum.id);
				writeln;           textcolor(15);
	write('Searching File: ');textcolor(12);write('LSD.EXE');textcolor(15);
  write('...');
	GetSerial(Ser,c);
				ser.sysop:='LakeSide Park';
        ser.id:=dummy;
  encode(ser);
	assign(f, 'LSD.exe' );
	reset(f,1);
	s.id:='';
	while (c>0) and (s.id <>SerialNum.ID ) do begin
		seek(f,c);
		blockread(f,s,SizeOf(serialnum));
		Dec(c);
		end;
	if ( c > 0 ) then begin
		Seek(f,c+1);
		{SerialNum.Sysop :=Ser.Sysop; }

		BlockWrite(f,Ser,SizeOf(Ser));
		end;
	close(f);

end.

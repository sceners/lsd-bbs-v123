Unit OvrCall;
{$O+,F+}

Interface

Uses
	Overlay,configrt;

Implementation
Begin
  readconfig;
	OvrInit('LSD.OVR');
  if configset.usems then ovrinitems;
  if (ovrresult<>ovrok) and configset.usems then begin
    writeln('Not enough EMS to put Overlay into memory!');
    halt(4);
  end;
	If OvrResult <> OvrOK then
		Begin
			WriteLn('Overlay file not found.');
			Halt(4);
		End;
End.
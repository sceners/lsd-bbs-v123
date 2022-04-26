	If OvrResult <> OvrOK then
		Begin
			WriteLn('Overlay file not found.');
			Halt(255);
		End;
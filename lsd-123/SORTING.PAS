
procedure shellsort(Left,Right:integer);
label
   Again;
var
   Pivot:integer;
   P,Q:integer;
   tp1,tp2,tp3,tp4:udrec;

   begin
      P:=Left;
      Q:=Right;
      Pivot:=(Left+Right) div 2;
      seek(udfile,pivot);
      read(udfile,tp1);
      while P<=Q do
      begin
       seek(udfile,p);
       read(udfile,tp2);
       while (upstring(tp2.filename)<upstring(tp1.filename)) do begin
             inc(p);
             seek(udfile,p);
             read(udfile,tp2);
       end;
         seek(udfile,q);
         read(udfile,tp3);
         while (upstring(tp1.filename)<upstring(tp3.filename)) do begin
               dec(Q);
               seek(udfile,q);
               read(udfile,tp3);
         end;
         if P>Q then goto Again;
         tp4:=tp3;
         tp3:=tp2;
         tp2:=tp4;
         seek(udfile,p);
         write(udfile,tp2);
         seek(udfile,q);
         write(udfile,tp3);
         inc(P);
         dec(Q);
      end;

      Again:
      if Left<Q  then shellsort(left,Q);
      if P<Right then shellsort(P,Right);
end;

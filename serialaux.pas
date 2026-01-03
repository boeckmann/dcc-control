unit SerialAux;

interface

uses {$ifdef UNIX}SerialUnix{$else}Serial{$endif};

function SerReadLineTimeout(port: TSerialHandle; timeout: LongInt): ShortString;

implementation

function SerReadLineTimeout(port: TSerialHandle; timeout: LongInt): ShortString;
var i: Integer; b: Byte;
begin
  for i := 1 to 255 do begin
    if SerReadTimeout(port, b, 1, timeout) = 0 then begin
      Result[0] := Chr(i-1);
      exit;
    end;
    Result[i] := Chr(b);
    if b = 10 then break;
  end;
  Result[0] := Chr(i);  
end;

end.

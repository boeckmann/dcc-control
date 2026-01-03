{$ifdef UNIX}
{$include serial_unix.inc}
{$else}
{$include serial_win.inc}
{$endif}

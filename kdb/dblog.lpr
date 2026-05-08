program dblog;

{$mode objfpc}{$H+}

uses
  kdblog;

begin
  if ParamCount = 0 then
    Exit;
  InitLog('DBLogger');
  WriteLog(ParamStr(1));
end.


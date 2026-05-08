unit kdbglobal;

{$mode objfpc}{$H+}

interface

uses
  sysutils;

function GetDBDir: string;

implementation

function GetDBDir: string;
begin
  Result:=GetUserDir+'db/';
end;

end.


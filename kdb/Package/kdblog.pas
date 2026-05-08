unit kdblog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, dbf, kdbglobal, DB;

procedure InitLog(const appname: string);
procedure WriteLog(const msg: string);

var
  KLogDB: TDbf;

implementation

var
  LogName: string;

procedure InitLog(const appname: string);
begin
  LogName:=appname;
  KLogDB:=TDbf.Create(Nil);
  KLogDB.FilePath:=GetDBDir;
  KLogDB.TableLevel:=7;
  KLogDB.TableName:='logs.dbf';
  KLogDB.OpenMode:=omAutoCreate;
  with KLogDB.FieldDefs do
  begin
    Add('ID', ftAutoInc);
    Add('AppName', ftString, 40);
    Add('Added', ftDateTime);
    Add('Message', ftString, 80);
  end;
  KLogDB.Active:=True;
  //KLogDB.AddIndex('logidx', 'ID', [ixPrimary, ixUnique]);
  //KLogDB.AddIndex('logname', 'AppName', [ixCaseInsensitive]);
  //KLogDB.AddIndex('logdate', 'Added', [ixDescending]);
  WriteLog('Application DB Logging Initialized.');
end;

procedure WriteLog(const msg: string);
begin
  with KLogDB do
  begin
    Append;
    FieldByName('AppName').AsString:=LogName;
    FieldByName('Added').AsDateTime:=Now;
    FieldByName('Message').AsString:=msg;
    Post;
  end;
end;

initialization
  KLogDB:=Nil;

finalization
  if Assigned(KLogDB) then
  begin
    WriteLog('Application DB Logging Stopped.');
    KLogDB.Free;
  end;

end.


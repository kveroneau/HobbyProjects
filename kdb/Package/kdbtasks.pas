unit kdbtasks;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, dbf, kdbglobal, DB;

var
  TasksDB: TDbf;

procedure UpdateTaskState(taskna: string; newstate: integer);

implementation

procedure InitDB;
begin
  TasksDB:=TDbf.Create(Nil);
  TasksDB.FilePath:=GetDBDir;
  TasksDB.TableLevel:=7;
  TasksDB.TableName:='tasks.dbf';
  TasksDB.OpenMode:=omAutoCreate;
  with TasksDB.FieldDefs do
  begin
    Add('ID', ftAutoInc);
    Add('ProjectID', ftInteger);
    Add('Title', ftString, 40, True);
    Add('Added', ftDateTime);
    Add('Tag', ftString, 20);
    Add('State', ftInteger);
    Add('Notes', ftMemo);
  end;
  TasksDB.Active:=True;
  if TasksDB.RecordCount = 0 then
  begin
    with TasksDB do
    begin
      AddIndex('TASKID', 'ID', [ixPrimary, ixUnique]);
      AddIndex('TASKPROJID', 'PROJECTID', []);
      AddIndex('TASKSTATE', 'STATE', []);
    end;
  end;
end;

procedure UpdateTaskState(taskna: string; newstate: integer);
begin
  with TasksDB do
  begin
    if not Locate('Title', taskna, []) then
      Exit;
    Edit;
    FieldValues['State']:=newstate;
    Post;
  end;
end;

initialization
  InitDB;

finalization
  TasksDB.Active:=False;
  TasksDB.Free;

end.


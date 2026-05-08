unit knotes;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, dbf, kdbglobal, DB;

var
  KNoteDB: TDbf;

implementation

procedure InitDB;
begin
  KNoteDB:=TDbf.Create(Nil);
  KNoteDB.FilePath:=GetDBDir;
  KNoteDB.TableLevel:=7;
  KNoteDB.TableName:='notes.dbf';
  KNoteDB.OpenMode:=omAutoCreate;
  with KNoteDB.FieldDefs do
  begin
    Add('ID', ftAutoInc);
    Add('Title', ftString, 40);
    Add('Added',ftDateTime);
    Add('Note', ftMemo);
  end;
  KNoteDB.Active:=True;
  //KNoteDB.AddIndex('notesidx', 'ID', [ixPrimary, ixUnique]);
end;

initialization
  InitDB;

finalization
  KNoteDB.Active:=False;
  KNoteDB.Free;

end.


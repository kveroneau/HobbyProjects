unit JournalWindow;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, DBCtrls, DB,
  dbf, knotes, kdbglobal, kdblog;

type

  { TJournalForm }

  TJournalForm = class(TForm)
    JournalDB: TDbf;
    NotesDS: TDataSource;
    DBTitle: TDBEdit;
    DBNote: TDBMemo;
    Label1: TLabel;
    procedure FormResize(Sender: TObject);
  private

  public
    procedure ShowJournal(LogID: Integer);
  end;

var
  JournalForm: TJournalForm;

implementation

{$R *.lfm}

{ TJournalForm }

procedure TJournalForm.FormResize(Sender: TObject);
begin
  DBNote.Width:=ClientWidth-10;
  DBNote.Height:=ClientHeight-50;
end;

procedure TJournalForm.ShowJournal(LogID: Integer);
begin
  if not JournalDB.Active then
  begin
    JournalDB.FilePath:=GetDBDir;
    JournalDB.TableName:='journal.dbf';
    JournalDB.OpenMode:=omAutoCreate;
    with JournalDB.FieldDefs do
    begin
      Add('LogID', ftInteger);
      Add('NoteID', ftInteger);
    end;
    JournalDB.Active:=True;
  end;
  if not Assigned(NotesDS.DataSet) then
    NotesDS.DataSet:=KNoteDB;
  if not JournalDB.Locate('LogID', LogID, []) then
  begin
    JournalDB.Append;
    JournalDB.FieldValues['LogID']:=LogID;
    with KNoteDB do
    begin
      Append;
      FieldValues['Title']:='New Journal';
      FieldValues['Added']:=Now;
      FieldValues['Note']:='Blank';
      Post;
      JournalDB.FieldValues['NoteID']:=FieldValues['ID'];
      JournalDB.Post;
      WriteLog('Created new Journal for LogID('+IntToStr(LogID)+') with NoteID('+IntToStr(FieldValues['ID'])+')');
    end;
  end;
  KNoteDB.Locate('ID', JournalDB.FieldValues['NoteID'], []);
  KNoteDB.Edit;
  ShowModal;
  KNoteDB.Post;
end;

end.


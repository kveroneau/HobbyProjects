unit NotesWindow;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, kdbtasks,
  JournalWindow, kdblog, knotes, kdbglobal;

type

  { TNotesForm }

  TNotesForm = class(TForm)
    ProjNotes: TMemo;
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure ProcessLogData;
  public

  end;

var
  NotesForm: TNotesForm;

implementation

{$R *.lfm}

{ TNotesForm }

procedure TNotesForm.FormShow(Sender: TObject);
begin
  ProjNotes.Clear;
  if not JournalForm.JournalDB.Active then
  begin
    with JournalForm.JournalDB do
    begin
      FilePath:=GetDBDir;
      TableName:='journal.dbf';
      Active:=True;
    end;
  end;
  with TasksDB do
  begin
    First;
    if EOF then
      Exit;
    repeat
      KLogDB.Filter:='APPNAME='+QuotedStr('ProjMan')+' AND MESSAGE='+QuotedStr('*'+FieldValues['Title']);
      KLogDB.Filtered:=True;
      KLogDB.First;
      if not KLogDB.EOF then
      begin
        ProjNotes.Lines.Add(' >>> '+FieldValues['Title']+' <<<');
        ProjNotes.Lines.Add(FieldValues['Notes']);
        ProcessLogData;
        ProjNotes.Lines.Add('');
      end;
      KLogDB.Filtered:=False;
      Next;
    until EOF;
  end;
end;

procedure TNotesForm.FormResize(Sender: TObject);
begin
  ProjNotes.Width:=ClientWidth;
  ProjNotes.Height:=ClientHeight;
end;

procedure TNotesForm.ProcessLogData;
begin
  with KLogDB do
  begin
    repeat
      if JournalForm.JournalDB.Locate('LOGID', FieldValues['ID'], []) then
      begin
        if KNoteDB.Locate('ID', JournalForm.JournalDB.FieldValues['NOTEID'], []) then
        begin
          {ProjNotes.Lines.Add('Task Title: '+TasksDB.FieldValues['Title']);}
          ProjNotes.Lines.Add('');
          ProjNotes.Lines.Add('Note Title: '+KNoteDB.FieldValues['Title']);
          ProjNotes.Lines.Add(FormatDateTime('dddd mmmm d, yyyy "at" hh:nn', FieldValues['Added']));
          ProjNotes.Lines.Add('-----------------------------------------------------');
          ProjNotes.Lines.Add(KNoteDB.FieldValues['Note']);
          ProjNotes.Lines.Add('=====================================================');
        end;
      end;
      Next;
    until EOF;
  end;
end;

end.


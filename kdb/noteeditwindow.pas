unit NoteEditWindow;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, DBCtrls,
  knotes, DB, kdblog;

type

  { TNoteEditForm }

  TNoteEditForm = class(TForm)
    DataSource: TDataSource;
    DBAddedOn: TDBText;
    DBNote: TDBMemo;
    DBNavigator: TDBNavigator;
    DBTitle: TDBEdit;
    DBID: TDBText;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    procedure NewNote(DataSet: TDataSet);
  public

  end;

var
  NoteEditForm: TNoteEditForm;

implementation

{$R *.lfm}

{ TNoteEditForm }

procedure TNoteEditForm.FormCreate(Sender: TObject);
begin
  InitLog('Note Editor');
  KNoteDB.OnNewRecord:=@NewNote;
  DataSource.DataSet:=KNoteDB;
end;

procedure TNoteEditForm.NewNote(DataSet: TDataSet);
begin
  WriteLog('A new note is being added.');
  DataSet.FieldByName('Added').AsDateTime:=Now;
end;

end.


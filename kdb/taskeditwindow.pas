unit TaskEditWindow;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, DBCtrls,
  DBGrids, JournalWindow, kdblog;

type

  { TTaskEditForm }

  TTaskEditForm = class(TForm)
    CancelBtn: TButton;
    DBLog: TDBGrid;
    SaveBtn: TButton;
    DBAdded: TDBText;
    DBNotes: TDBMemo;
    DBTag: TDBEdit;
    DBTitle: TDBEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    ProjectTitle: TLabel;
    procedure DBLogDblClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private

  public

  end;

var
  TaskEditForm: TTaskEditForm;

implementation

{$R *.lfm}

{ TTaskEditForm }

procedure TTaskEditForm.FormResize(Sender: TObject);
begin
  DBNotes.Width:=ClientWidth-10;
  DBLog.Width:=ClientWidth-10;
end;

procedure TTaskEditForm.DBLogDblClick(Sender: TObject);
begin
  JournalForm.ShowJournal(KLogDB.FieldValues['ID']);
end;

end.


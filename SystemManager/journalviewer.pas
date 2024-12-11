unit JournalViewer;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TJournalForm }

  TJournalForm = class(TForm)
    Memo1: TMemo;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormResize(Sender: TObject);
    procedure Memo1KeyPress(Sender: TObject; var Key: char);
  private
    FJournalFile: string;
  public
    procedure OpenJournal(AFile: string);
  end;

implementation

{$R *.lfm}

{ TJournalForm }

procedure TJournalForm.FormResize(Sender: TObject);
begin
  Memo1.Width:=ClientWidth;
  Memo1.Height:=ClientHeight;
end;

procedure TJournalForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  r: TModalResult;
begin
  if Memo1.Modified then
  begin
    CanClose:=False;
    r:=MessageDlg('System Manager Journal', 'Save Journal before closing?', mtConfirmation, mbYesNoCancel, '');
    if r = mrNo then
      CanClose:=True
    else if r = mrYes then
    begin
      CanClose:=True;
      Memo1.Lines.SaveToFile(FJournalFile);
    end;
  end;
end;

procedure TJournalForm.Memo1KeyPress(Sender: TObject; var Key: char);
var
  line: string;
begin
  if Key = #13 then
  begin
    line:=Memo1.Lines.Strings[Memo1.Lines.Count-1];
    if line = 'dt' then
      Memo1.Lines.Strings[Memo1.Lines.Count-1]:=FormatDateTime('dddd mmmm d, yyyy "at" hh:nn', Now);
  end;
end;

procedure TJournalForm.OpenJournal(AFile: string);
begin
  FJournalFile:=AFile;
  if FileExists(FJournalFile) then
    Memo1.Lines.LoadFromFile(FJournalFile)
  else
    Memo1.Text:='';
  Memo1.Modified:=False;
  Show;
end;

end.


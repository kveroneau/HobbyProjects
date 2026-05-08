unit CannaLogWindow;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, DBGrids, StdCtrls, dbf,
  DB, kdbglobal, JournalWindow, kdblog, knotes;

type

  { TDBLogForm }

  TDBLogForm = class(TForm)
    ReportBtn: TButton;
    RefreshBtn: TButton;
    Filter: TComboBox;
    DataSource: TDataSource;
    DBGrid: TDBGrid;
    Label1: TLabel;
    LogDB: TDbf;
    SaveDialog: TSaveDialog;
    procedure DBGridDblClick(Sender: TObject);
    procedure FilterChange(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RefreshBtnClick(Sender: TObject);
    procedure ReportBtnClick(Sender: TObject);
  private

  public

  end;

var
  DBLogForm: TDBLogForm;

implementation

{$R *.lfm}

{ TDBLogForm }

procedure TDBLogForm.DBGridDblClick(Sender: TObject);
begin
  WriteLog('Showing Journal Entry for: LogID='+IntToStr(LogDB.FieldValues['ID']));
  JournalForm.ShowJournal(LogDB.FieldValues['ID']);
end;

procedure TDBLogForm.FilterChange(Sender: TObject);
begin
  LogDB.Filtered:=False;
  LogDB.Filter:=Filter.Caption;
  LogDB.Filtered:=True;
end;

procedure TDBLogForm.FormResize(Sender: TObject);
begin
  DBGrid.Width:=ClientWidth;
  DBGrid.Height:=ClientHeight-50;
end;

procedure TDBLogForm.FormShow(Sender: TObject);
begin
  InitLog('CannaLog');
  LogDB.FilePath:=GetDBDir;
  LogDB.TableName:='logs.dbf';
  LogDB.Active:=True;
  LogDB.Filter:='MESSAGE='+QuotedStr('*cannabis');
  LogDB.Filtered:=True;
end;

procedure TDBLogForm.RefreshBtnClick(Sender: TObject);
begin
  LogDB.Refresh;
end;

procedure TDBLogForm.ReportBtnClick(Sender: TObject);
var
  rpt: TStringList;
begin
  rpt:=TStringList.Create;
  try
    rpt.Add('<html><head><title>CannaLog Report</title></head><body>');
    with LogDB do
    begin
      First;
      repeat
        if JournalForm.JournalDB.Locate('LOGID', FieldValues['ID'], []) then
        begin
          if KNoteDB.Locate('ID', JournalForm.JournalDB.FieldValues['NOTEID'], []) then
          begin
            rpt.Add('<b>'+FormatDateTime('dddd mmmm d, yyyy "at" hh:nn', FieldValues['Added'])+'</b>');
            rpt.Add('<p>'+KNoteDB.FieldValues['NOTE']+'</p><hr/>');
          end;
        end;
        Next;
      until EOF;
      rpt.Add('</body></html>');
    end;
    SaveDialog.InitialDir:=GetUserDir;
    if not SaveDialog.Execute then
      Exit;
    rpt.SaveToFile(SaveDialog.FileName);
  finally
    rpt.Free;
  end;
end;

end.


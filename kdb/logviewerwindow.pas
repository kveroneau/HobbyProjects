unit LogViewerWindow;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  DBGrids, ExtCtrls, dbf, DB, kdbglobal;

type

  { TDBLogForm }

  TDBLogForm = class(TForm)
    AppName: TEdit;
    DataSource: TDataSource;
    DBGrid: TDBGrid;
    LogDB: TDbf;
    FilterBtn: TButton;
    Label1: TLabel;
    LogViewer: TMemo;
    Tabs: TPageControl;
    LogTab: TTabSheet;
    TableTab: TTabSheet;
    Timer: TTimer;
    procedure FilterBtnClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LogTabResize(Sender: TObject);
    procedure TableTabResize(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
  private
    FLastLogID: Integer;
  public

  end;

var
  DBLogForm: TDBLogForm;

implementation

{$R *.lfm}

{ TDBLogForm }

procedure TDBLogForm.FormShow(Sender: TObject);
begin
  LogDB.FilePath:=GetDBDir;
  LogDB.TableName:='logs.dbf';
  LogDB.Active:=True;
  LogViewer.Text:='';
  LogDB.Last;
  FLastLogID:=LogDB.FieldByName('ID').AsInteger;
end;

procedure TDBLogForm.LogTabResize(Sender: TObject);
begin
  LogViewer.Width:=LogTab.ClientWidth;
  LogViewer.Height:=LogTab.ClientHeight;
end;

procedure TDBLogForm.TableTabResize(Sender: TObject);
begin
  DBGrid.Width:=TableTab.ClientWidth-10;
  DBGrid.Height:=TableTab.ClientHeight-50;
end;

procedure TDBLogForm.TimerTimer(Sender: TObject);
var
  dt: string;
begin
  if not LogDB.Active then
    Exit;
  LogDB.Refresh;
  LogDB.Last;
  if FLastLogID <> LogDB.FieldByName('ID').AsInteger then
  begin
    dt:=FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz',LogDB.FieldByName('Added').AsDateTime);
    LogViewer.Lines.Add(LogDB.FieldByName('AppName').AsString+ '['+dt+']'+LogDB.FieldByName('Message').AsString);
    FLastLogID:=LogDB.FieldByName('ID').AsInteger;
  end;
end;

procedure TDBLogForm.FilterBtnClick(Sender: TObject);
begin
  if LogDB.Filtered then
    LogDB.Filtered:=False;
  if AppName.Text <> '' then
  begin
    LogDB.Filter:='AppName='+QuotedStr(AppName.Text);
    LogDB.Filtered:=True;
  end
  else
    LogDB.Filter:='';
end;

procedure TDBLogForm.FormResize(Sender: TObject);
begin
  Tabs.Width:=ClientWidth;
  Tabs.Height:=ClientHeight;
end;

end.


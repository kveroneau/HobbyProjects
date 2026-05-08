unit dbmanWindow;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, DBGrids, dbf,
  DB, kdbglobal, FileUtil;

type

  { TDBManForm }

  TDBManForm = class(TForm)
    RefreshBtn: TButton;
    Database: TComboBox;
    DataSource: TDataSource;
    DB: TDbf;
    DBGrid: TDBGrid;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    TblLvl: TLabel;
    procedure DatabaseChange(Sender: TObject);
    procedure Edit1DblClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RefreshBtnClick(Sender: TObject);
  private

  public

  end;

var
  DBManForm: TDBManForm;

implementation

{$R *.lfm}

{ TDBManForm }

procedure TDBManForm.FormShow(Sender: TObject);
var
  s: TStringList;
  i: integer;
begin
  DB.FilePath:=GetDBDir;
  s:=FindAllFiles(DB.FilePath, '*.dbf;*.DBF', False);
  try
    for i:=0 to s.Count-1 do
      Database.Items.Add(ExtractFileName(s.Strings[i]));
  finally
    s.Free;
  end;
end;

procedure TDBManForm.RefreshBtnClick(Sender: TObject);
begin
  DB.Refresh;
end;

procedure TDBManForm.DatabaseChange(Sender: TObject);
begin
  DB.Active:=False;
  DB.TableName:=Database.Text;
  DB.Active:=True;
  TblLvl.Caption:=IntToStr(DB.TableLevel);
end;

procedure TDBManForm.Edit1DblClick(Sender: TObject);
begin
  if not DB.Active then
    Exit;
  if DB.Filtered then
    DB.Filtered:=False;
  DB.Filter:=Edit1.Text;
  if Edit1.Text <> '' then
    DB.Filtered:=True;
end;

procedure TDBManForm.FormResize(Sender: TObject);
begin
  DBGrid.Width:=ClientWidth-10;
  DBGrid.Height:=ClientHeight-50;
end;

end.


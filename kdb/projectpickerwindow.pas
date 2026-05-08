unit ProjectPickerWindow;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, kdbglobal,
  kdbvfs, projmodels, StrUtils, kdbtasks;

type

  { TProjectPickerForm }

  TProjectPickerForm = class(TForm)
    ProjType: TComboBox;
    NewBtn: TButton;
    ProjList: TListBox;
    procedure FormShow(Sender: TObject);
    procedure NewBtnClick(Sender: TObject);
    procedure ProjListDblClick(Sender: TObject);
  private
    FProjId: Integer;
    procedure RenderList;
  public
    property ProjectID: Integer read FProjId;
  end;

var
  ProjectPickerForm: TProjectPickerForm;

implementation

{$R *.lfm}

{ TProjectPickerForm }

procedure TProjectPickerForm.FormShow(Sender: TObject);
begin
  if ParamCount = 1 then
  begin
    FProjId:=StrToInt(ParamStr(1));
    ModalResult:=mrOK;
  end
  else
    RenderList;
end;

procedure TProjectPickerForm.NewBtnClick(Sender: TObject);
var
  pna: string;
begin
  if ProjType.ItemIndex < 0 then
    Exit;
  pna:=InputBox('Project Manager', 'Project Title:', '');
  if pna = '' then
    Exit;
  Databases.VFS.MkFile(pna, 6);
  if ProjType.ItemIndex = 0 then
    pna:='/usr/local/bin/lazarus,/home/kveroneau/Projects/'+pna+'/'+pna+'.lpi'
  else if ProjType.ItemIndex = 1 then
    pna:='/home/kveroneau/Projects/RPGGameManager/GameManager,'+pna;
  Databases.VFS.FileData:=IntToStr(Random(64000))+','+pna;
  RenderList;
end;

procedure TProjectPickerForm.ProjListDblClick(Sender: TObject);
begin
  if not Databases.VFS.LocateFile(ProjList.GetSelectedText) then
    Exit;
  {Databases.VFS.FileData:='57891,/usr/local/bin/lazarus';}
  FProjId:=StrToInt(Copy2Symb(Databases.VFS.FileData, ','));
  TasksDB.Filter:='ProjectID='+IntToStr(FProjId);
  TasksDB.Filtered:=True;
  ModalResult:=mrOK;
end;

procedure TProjectPickerForm.RenderList;
begin
  ProjList.Clear;
  with Databases.VFS.DataSet do
  begin
    First;
    if EOF then
      Exit;
    repeat
      ProjList.Items.Add(FieldValues['TITLE']);
      Next;
    until EOF;
  end;
end;

end.


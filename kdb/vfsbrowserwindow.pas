unit VFSBrowserWindow;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, Menus,
  kdbvfs, kdblog, VFSEditWindow, process;

type

  { TVFSBrowserForm }

  TVFSBrowserForm = class(TForm)
    IconList: TImageList;
    NewMenu: TMenuItem;
    VFSMenu: TPopupMenu;
    VFSDirectory: TListView;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure NewMenuClick(Sender: TObject);
    procedure VFSDirectoryDblClick(Sender: TObject);
  private
    FVFS: TKDBVFS;
    FHomeDir: string;
    procedure RenderDirectory;
  public

  end;

var
  VFSBrowserForm: TVFSBrowserForm;

implementation

{$R *.lfm}

{ TVFSBrowserForm }

procedure TVFSBrowserForm.FormResize(Sender: TObject);
begin
  VFSDirectory.Width:=ClientWidth;
  VFSDirectory.Height:=ClientHeight;
end;

procedure TVFSBrowserForm.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  if FVFS.CurDir <> FHomeDir then
  begin
    WriteLog('Return to Home Directory.');
    FVFS.CurDir:=FHomeDir;
    RenderDirectory;
    CloseAction:=caNone;
  end
  else
    CloseAction:=caFree;
end;

procedure TVFSBrowserForm.FormShow(Sender: TObject);
begin
  InitLog('VFSBrowser');
  FVFS:=TKDBVFS.Create(Self, 'testvfs');
  if ParamCount = 1 then
  begin
    FHomeDir:=ParamStr(1);
    WriteLog('Home Directory Set: '+FHomeDir);
    FVFS.CurDir:=FHomeDir;
  end;
  RenderDirectory;
end;

procedure TVFSBrowserForm.NewMenuClick(Sender: TObject);
begin
  VFSEditForm.NewVFSFile(FVFS.DataSet, FVFS.CurDir);
  RenderDirectory;
end;

procedure TVFSBrowserForm.VFSDirectoryDblClick(Sender: TObject);
var
  typ: Integer;
  p: TProcess;
begin
  if FVFS.LocateFile(VFSDirectory.Selected.Caption) then
  begin
    typ:=FVFS.DataSet.FieldValues['TYP'];
    if typ = 0 then
      ShowMessage(FVFS.FileData)
    else if (typ = 1) or (typ = 2) then
    begin
      WriteLog('Entering VFS Directory: '+FVFS.DataSet.FieldValues['TITLE']);
      FVFS.CurDir:=FVFS.DataSet.FieldValues['TITLE'];
      RenderDirectory;
    end
    else if typ = 3 then
    begin
      WriteLog('Starting Process: '+FVFS.FileData);
      p:=TProcess.Create(Self);
      p.Executable:=GetUserDir+FVFS.FileData;
      p.Active:=True;
    end
    else if typ = 4 then
    begin
      WriteLog('Starting 86Box: '+FVFS.FileData);
      p:=TProcess.Create(Self);
      p.Executable:='/usr/bin/86Box';
      p.Parameters.Add('-F');
      p.Parameters.Add('-P');
      p.Parameters.Add('/btrfs/Boxes/'+FVFS.FileData);
      p.Active:=True;
    end;
  end;
end;

procedure TVFSBrowserForm.RenderDirectory;
var
  itm: TListItem;
begin
  Caption:=FVFS.CurDir;
  VFSDirectory.Clear;
  if FVFS.DataSet.EOF then
    Exit;
  with FVFS.DataSet do
  begin
    First;
    repeat
      itm:=VFSDirectory.Items.Add;
      itm.Caption:=FieldValues['TITLE'];
      itm.ImageIndex:=FieldByName('TYP').AsInteger;
      Next;
    until EOF;
  end;
end;

end.


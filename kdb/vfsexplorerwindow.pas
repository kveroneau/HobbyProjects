unit VFSExplorerWindow;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, VFSTreeView, kdbvfs;

type

  { TVFSExplorerForm }

  TVFSExplorerForm = class(TForm)
    IconList: TImageList;
    VFSTreeView1: TVFSTreeView;
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure VFSTreeView1DblClick(Sender: TObject);
  private
    FVFS: TKDBVFS;
  public

  end;

var
  VFSExplorerForm: TVFSExplorerForm;

implementation

{$R *.lfm}

{ TVFSExplorerForm }

procedure TVFSExplorerForm.FormShow(Sender: TObject);
begin
  FVFS:=TKDBVFS.Create(Self, 'testvfs');
  VFSTreeView1.DataSet:=FVFS.DataSet;
  VFSTreeView1.AddDirectory(Nil, 'FSRoot');
  VFSTreeView1.AddDirectory(Nil, 'Programs');
end;

procedure TVFSExplorerForm.FormResize(Sender: TObject);
begin
  VFSTreeView1.Width:=ClientWidth;
  VFSTreeView1.Height:=ClientHeight;
end;

procedure TVFSExplorerForm.VFSTreeView1DblClick(Sender: TObject);
var
  typ: Integer;
begin
  if not VFSTreeView1.LocateFile then
    Exit;
  typ:=FVFS.DataSet.FieldValues['typ'];
  if typ = 0 then
    ShowMessage(FVFS.FileData)
  else if typ = 2 then
    VFSTreeView1.AddDirectory(Nil, FVFS.DataSet.FieldValues['title'])
  else if typ = 3 then
    ShowMessage('Incompatible!');
end;

end.


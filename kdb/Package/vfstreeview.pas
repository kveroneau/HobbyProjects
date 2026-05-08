unit VFSTreeView;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, ComCtrls,
  DB;

type

  { TVFSTreeView }

  TVFSTreeView = class(TTreeView)
  private
    FDataSet: TDataSet;
    procedure FilterDir(const aDir: string);
  protected

  public
    function AddDirectory(aParent: TTreeNode; aDir: string): TTreeNode;
    function GetDirectory: string;
    function LocateFile: boolean;
  published
    property DataSet: TDataSet read FDataSet write FDataSet;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('klib',[TVFSTreeView]);
end;

{ TVFSTreeView }

procedure TVFSTreeView.FilterDir(const aDir: string);
begin
  FDataSet.Filtered:=False;
  FDataSet.Filter:='WH='+QuotedStr(aDir);
  FDataSet.Filtered:=True;
end;

function TVFSTreeView.AddDirectory(aParent: TTreeNode; aDir: string): TTreeNode;
var
  root, node: TTreeNode;
  dirList: Array of TTreeNode;
  typ, i: Integer;
begin
  FilterDir(aDir);
  if aParent = Nil then
  begin
    root:=Items.Add(Nil, aDir);
    root.ImageIndex:=1;
    root.SelectedIndex:=1;
  end
  else
    root:=aParent;
  SetLength(dirList, 0);
  with FDataSet do
  begin
    if not EOF then
      First;
    repeat
      node:=Items.AddChild(root, FieldValues['title']);
      typ:=FieldValues['typ'];
      node.ImageIndex:=typ;
      node.SelectedIndex:=typ;
      if typ = 1 then
      begin
        SetLength(dirList, Length(dirList)+1);
        dirList[Length(dirList)-1]:=node;
      end;
      Next;
    until EOF;
  end;
  for i:=0 to Length(dirList)-1 do
    AddDirectory(dirList[i], dirList[i].Text);
  SetLength(dirList, 0);
  Result:=root;
end;

function TVFSTreeView.GetDirectory: string;
begin
  if Selected = Nil then
    Exit;
  if Selected.ImageIndex = 1 then
    Result:=Selected.Text
  else if (Selected.Parent <> Nil) and (Selected.Parent.ImageIndex = 1) then
    Result:=Selected.Parent.Text
  else
    Result:='FSRoot';
end;

function TVFSTreeView.LocateFile: boolean;
begin
  if (Selected = Nil) or (Selected.Parent = Nil) then
    Result:=False
  else
  begin
    FilterDir(Selected.Parent.Text);
    Result:=FDataSet.Locate('title', Selected.Text, []);
  end;
end;

end.

unit projmodels;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DB, kdbvfs, kdbtasks;

type

  { TDatabases }

  TDatabases = class(TDataModule)
    LogDS: TDataSource;
    TasksDS: TDataSource;
    VFSDS: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
  private

  public
    VFS: TKDBVFS;
  end;

var
  Databases: TDatabases;

implementation

{$R *.lfm}

{ TDatabases }

procedure TDatabases.DataModuleCreate(Sender: TObject);
begin
  VFS:=TKDBVFS.Create(Self, 'testvfs');
  VFS.CurDir:='Projects';
  VFSDS.DataSet:=VFS.DataSet;
  TasksDS.DataSet:=TasksDB;
end;

end.


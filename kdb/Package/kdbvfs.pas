unit kdbvfs;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, dbf, kdbglobal, DB;

type

  { TKDBVFS }

  TKDBVFS = class(TComponent)
  private
    FCurDir: string;
    procedure AddNode(ATitle, AWh: string; ATyp: Integer);
    function GetData: string;
    procedure InitVFS;
    procedure NewRecord(ADataSet: TDataSet);
    procedure SetCurDir(AValue: string);
    procedure SetData(AValue: string);
  public
    DataSet: TDbf;
    property CurDir: string read FCurDir write SetCurDir;
    property FileData: string read GetData write SetData;
    constructor Create(AOwner: TComponent; ADatabase: string);
    destructor Destroy; override;
    procedure MkDir(const ADirName: string);
    procedure MkFile(const AFileName: string; ATyp: Integer);
    function LocateFile(const AFileName: string): Boolean;
    function GetFileData(const AFileName: string): Variant;
  end;

implementation

{ TKDBVFS }

procedure TKDBVFS.AddNode(ATitle, AWh: string; ATyp: Integer);
begin
  with DataSet do
  begin
    Append;
    FieldValues['TITLE']:=ATitle;
    FieldValues['WH']:=AWh;
    FieldValues['TYP']:=ATyp;
    FieldValues['DATA']:='Added via KDBVFS API.';
    Post;
  end;
end;

function TKDBVFS.GetData: string;
begin
  Result:=DataSet.FieldValues['DATA'];
end;

procedure TKDBVFS.InitVFS;
begin
  AddNode('FSRoot', '', 1);
  AddNode('System', 'FSRoot', 1);
  AddNode('README.txt', 'System', 0);
  DataSet.Edit;
  DataSet.FieldValues['DATA']:='VFS Created by KDBVFS API.';
  DataSet.Post;
end;

procedure TKDBVFS.NewRecord(ADataSet: TDataSet);
begin
  ADataSet.FieldValues['ADDED']:=Now;
  ADataSet.FieldValues['MODIFIED']:=Now;
end;

procedure TKDBVFS.SetCurDir(AValue: string);
begin
  if FCurDir=AValue then Exit;
  DataSet.Filtered:=False;
  DataSet.Filter:='WH='+QuotedStr(AValue);
  DataSet.Filtered:=True;
  FCurDir:=AValue;
end;

procedure TKDBVFS.SetData(AValue: string);
begin
  DataSet.Edit;
  DataSet.FieldValues['DATA']:=AValue;
  DataSet.Post;
end;

constructor TKDBVFS.Create(AOwner: TComponent; ADatabase: string);
begin
  inherited Create(AOwner);
  DataSet:=TDbf.Create(Self);
  DataSet.OnNewRecord:=@NewRecord;
  DataSet.FilePath:=GetDBDir;
  DataSet.TableLevel:=7;
  DataSet.TableName:=ADatabase+'.dbf';
  DataSet.OpenMode:=omAutoCreate;
  with DataSet.FieldDefs do
  begin
    Add('TITLE', ftString, 40);
    Add('WH', ftString, 40);
    Add('TYP', ftInteger);
    Add('ADDED', ftDateTime);
    Add('MODIFIED', ftDateTime);
    Add('DATA', ftMemo);
  end;
  DataSet.Active:=True;
  if DataSet.RecordCount = 0 then
    InitVFS;
  CurDir:='FSRoot';
end;

destructor TKDBVFS.Destroy;
begin
  DataSet.Active:=False;
  inherited Destroy;
end;

procedure TKDBVFS.MkDir(const ADirName: string);
begin
  AddNode(ADirName, FCurDir, 1);
end;

procedure TKDBVFS.MkFile(const AFileName: string; ATyp: Integer);
begin
  AddNode(AFileName, FCurDir, ATyp);
end;

function TKDBVFS.LocateFile(const AFileName: string): Boolean;
begin
  Result:=DataSet.Locate('TITLE', AFileName, []);
end;

function TKDBVFS.GetFileData(const AFileName: string): Variant;
begin
  Result:=DataSet.Lookup('TITLE', AFileName, 'DATA');
end;

end.


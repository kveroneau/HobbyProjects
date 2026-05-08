unit VFSEditWindow;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, DBCtrls, DB;

type

  { TVFSEditForm }

  TVFSEditForm = class(TForm)
    DataSource: TDataSource;
    DBType: TDBEdit;
    DBTitle: TDBEdit;
    DBData: TDBMemo;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
  private

  public
    procedure NewVFSFile(DS: TDataSet; VFSDir: string);
  end;

var
  VFSEditForm: TVFSEditForm;

implementation

{$R *.lfm}

{ TVFSEditForm }

procedure TVFSEditForm.NewVFSFile(DS: TDataSet; VFSDir: string);
begin
  DataSource.DataSet:=DS;
  DS.Append;
  DS.FieldValues['ADDED']:=Now;
  DS.FieldValues['MODIFIED']:=Now;
  DS.FieldValues['WH']:=VFSDir;
  ShowModal;
  DS.Post;
end;

end.


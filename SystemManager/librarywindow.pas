unit LibraryWindow;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, FileUtil;

type

  { TLibraryForm }

  TLibraryForm = class(TForm)
    OkayBtn: TButton;
    CancelBtn: TButton;
    LibraryItem: TComboBox;
    Label1: TLabel;
    procedure CancelBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  LibraryForm: TLibraryForm;

implementation

{$R *.lfm}

{ TLibraryForm }

procedure TLibraryForm.FormCreate(Sender: TObject);
var
  lst: TStrings;
  i: Integer;
begin
  lst:=FindAllFiles('/btrfs/Library/', '*.*', False, faNormal);
  for i:=0 to lst.Count-1 do
    LibraryItem.Items.Add(ExtractFileName(lst.Strings[i]));
end;

procedure TLibraryForm.CancelBtnClick(Sender: TObject);
begin
  Close;
end;

end.


unit NewKVMWindow;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, process;

type

  { TNewKVMForm }

  TNewKVMForm = class(TForm)
    Network: TComboBox;
    CPUs: TComboBox;
    Memory: TComboBox;
    DiskSize: TComboBox;
    GroupBox1: TGroupBox;
    KVMSystem: TComboBox;
    Label1: TLabel;
    KVMName: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    procedure KVMSystemChange(Sender: TObject);
  private
    FProcess: TProcess;
    FNICModel: string;
    procedure DebianParams(suite, osvar: string);
    procedure NT351Params;
    procedure NT4Params;
    procedure W2kParams;
    procedure XPParams;
  public
    property Process: TProcess read FProcess;
    procedure GetInstaller(vmname: string);
  end;

var
  NewKVMForm: TNewKVMForm;

implementation

{$R *.lfm}

{ TNewKVMForm }

procedure TNewKVMForm.KVMSystemChange(Sender: TObject);
begin
  FNICModel:='virtio';
  case KVMSystem.ItemIndex of
    0: DebianParams('bookworm', 'debian10');
    1: DebianParams('bullseye', 'debian10');
    2: DebianParams('buster', 'debian10');
    3: DebianParams('stretch', 'debian9');
    4: NT351Params;
    5: NT4Params;
    6: W2kParams;
    7: XPParams;
  else
    Exit;
  end;
  with FProcess.Parameters do
  begin
    Add('--disk');
    Add('size='+DiskSize.Text+',pool=default');
    Add('--memory');
    Add(Memory.Text);
    Add('--vcpu');
    Add(CPUs.Text);
    Add('--network');
    Add('network='+Network.Text+',model='+FNICModel);
  end;
  Close;
end;

procedure TNewKVMForm.DebianParams(suite, osvar: string);
begin
  with FProcess.Parameters do
  begin
    Add('--location');
    Add('http://deb.debian.org/debian/dists/'+suite+'/main/installer-amd64/');
    Add('-x');
    Add('popularity-contest/participate=false');
    Add('--os-variant');
    Add(osvar);
  end;
end;

procedure TNewKVMForm.NT351Params;
begin
  FNICModel:='pcnet';
  with FProcess.Parameters do
  begin
    Add('--cdrom');
    Add('/opt/ISOs/WinNT351.iso');
    Add('--os-variant');
    Add('winnt3.51');
    Add('--disk');
    Add('vol=default/dos622.img,device=floppy,readonly=on');
    Add('--sound');
    Add('sb16');
    Add('--cpu');
    Add('486');
  end;
end;

procedure TNewKVMForm.NT4Params;
begin
  FNICModel:='pcnet';
  with FProcess.Parameters do
  begin
    Add('--cdrom');
    Add('/opt/ISOs/WinNT4.iso');
    Add('--os-variant');
    Add('winnt4.0');
    Add('--sound');
    Add('sb16');
    Add('--cpu');
    Add('486');
  end;
end;

procedure TNewKVMForm.W2kParams;
begin
  FNICModel:='pcnet';
  with FProcess.Parameters do
  begin
    Add('--cdrom');
    Add('/opt/ISOs/Win2k-SP4.iso');
    Add('--os-variant');
    Add('win2k');
    Add('--disk');
    Add('vol=default/w2k-unattend.img,device=floppy,readonly=on');
    Add('--sound');
    Add('ac97');
  end;
end;

procedure TNewKVMForm.XPParams;
begin
  with FProcess.Parameters do
  begin
    Add('--cdrom');
    Add('/opt/ISOs/WinXP-SP2.iso');
    Add('--os-variant');
    Add('winxp');
    Add('--disk');
    Add('vol=default/xp-unattend.img,device=floppy,readonly=on');
    Add('--sound');
    Add('ac97');
  end;
end;

procedure TNewKVMForm.GetInstaller(vmname: string);
begin
  KVMName.Caption:=vmname;
  KVMSystem.ItemIndex:=-1;
  FProcess:=TProcess.Create(Nil);
  FProcess.Executable:='/usr/bin/virt-install';
  with FProcess.Parameters do
  begin
    Add('--connect');
    Add('qemu:///system');
    Add('--virt-type');
    Add('kvm');
    Add('--name');
    Add(vmname);
  end;
  ShowModal;
end;

end.


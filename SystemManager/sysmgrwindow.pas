unit SysMgrWindow;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Grids, ComCtrls, RTTICtrls, netmodule, process, IniFiles, JournalViewer,
  kexec, FileUtil, DateUtils, LibraryWindow, BaseUnix;

type

  { TSysMgrForm }

  TSysMgrForm = class(TForm)
    BoxControls: TGroupBox;
    BoxRunning: TCheckBox;
    SetNetBtn: TButton;
    CloneBtn: TButton;
    CfgButton: TButton;
    TemplStack: TComboBox;
    Label6: TLabel;
    LogList: TListBox;
    SysTemplate: TComboBox;
    GoFS: TCheckBox;
    JournalIcon: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    NIC1Net: TLabel;
    NetGroup: TGroupBox;
    NIC2Net: TLabel;
    NIC3Net: TLabel;
    NIC4Net: TLabel;
    SysGrid: TStringGrid;
    BasicSwitch: TTICheckBox;
    TapSwitch: TTICheckBox;
    RemoteSwitch: TTICheckBox;
    RemoteTap: TTICheckBox;
    CorpTap: TTICheckBox;
    ToolBar: TToolBar;
    OpenList: TToolButton;
    SaveList: TToolButton;
    SysJournalBtn: TToolButton;
    AddJournalBtn: TToolButton;
    NetHostBtn: TToolButton;
    LibraryBtn: TToolButton;
    procedure AddJournalBtnClick(Sender: TObject);
    procedure BasicSwitchClick(Sender: TObject);
    procedure BoxRunningClick(Sender: TObject);
    procedure CfgButtonClick(Sender: TObject);
    procedure CloneBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure JournalIconDblClick(Sender: TObject);
    procedure LibraryBtnClick(Sender: TObject);
    procedure LogListDblClick(Sender: TObject);
    procedure NetHostBtnClick(Sender: TObject);
    procedure OpenListClick(Sender: TObject);
    procedure RemoteSwitchClick(Sender: TObject);
    procedure RemoteTapClick(Sender: TObject);
    procedure SaveListClick(Sender: TObject);
    procedure SetNetBtnClick(Sender: TObject);
    procedure SysGridColRowInserted(Sender: TObject; IsColumn: Boolean; sIndex,
      tIndex: Integer);
    procedure SysGridSelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
    procedure SysJournalBtnClick(Sender: TObject);
    procedure TapSwitchClick(Sender: TObject);
    procedure TemplStackChange(Sender: TObject);
  private
    FBoxes: Array of TProcess;
    FRow: Integer;
    FUpdating: Boolean;
    FSysJournal: TJournalForm;
    FLastNet: string;
    procedure UpdateNetworks(Sender: TObject);
    procedure HideAllNICs;
    function CheckNetworks: Boolean;
    procedure ShowMessage(const msg: string);
    procedure SetupNetwork(box: string);
  public

  end;

var
  SysMgrForm: TSysMgrForm;

implementation

{$R *.lfm}

{ TSysMgrForm }

procedure TSysMgrForm.SysGridColRowInserted(Sender: TObject; IsColumn: Boolean;
  sIndex, tIndex: Integer);
begin
  SetLength(FBoxes, SysGrid.RowCount);
end;

procedure TSysMgrForm.FormCreate(Sender: TObject);
var
  lst: TStrings;
  i: Integer;
begin
  FSysJournal:=Nil;
  FLastNet:='';
  SetLength(FBoxes, SysGrid.RowCount);
  LibraryBtn.Enabled:=False;
  if ParamCount = 1 then
  begin
    SysGrid.LoadFromCSVFile(ParamStr(1));
    SetLength(FBoxes, SysGrid.RowCount);
    Caption:='System Manager for '+ExtractFileName(ParamStr(1));
    if ExtractFileName(ParamStr(1)) = 'corpnet.sl' then
      CorpTap.Enabled:=True;
  end;
  RemoteTap.Enabled:=False;
  if Exec('/usr/bin/ssh-add', '-l') = 1 then
    RemoteSwitch.Enabled:=False;
  if not IfProcess('vde_plug') then
  begin
    if DirectoryExists('/tmp/mysw') then
    begin
      DeleteFile('/tmp/mysw/ctl');
      RemoveDir('/tmp/mysw');
    end;
    if DirectoryExists('/tmp/remote') then
    begin
      DeleteFile('/tmp/remote/ctl');
      RemoveDir('/tmp/remote');
    end;
  end;
  //FindAllDirectories(SysTemplate.Items, '/btrfs/Boxes/.templates', False);
  lst:=FindAllDirectories('/btrfs/Boxes/.templates', False);
  try
    for i:=0 to lst.Count-1 do
      TemplStack.Items.Add(ExtractFileName(lst.Strings[i]));
  finally
    lst.Free;
  end;
end;

procedure TSysMgrForm.FormDestroy(Sender: TObject);
var
  i: Integer;
begin
  for i:=0 to High(FBoxes)-1 do
    if Assigned(FBoxes[i]) then
      FreeAndNil(FBoxes[i]);
end;

procedure TSysMgrForm.BoxRunningClick(Sender: TObject);
var
  proc: TProcess;
  path: string;
begin
  if FUpdating then
    Exit;
  if (not BoxRunning.Checked) and (not Assigned(FBoxes[FRow-1])) then
    Exit;
  path:=SysGrid.Cells[3, FRow];
  if BoxRunning.Checked then
  begin
    if path = '' then
    begin
      BoxRunning.State:=cbUnchecked;
      Exit;
    end;
    if path[1] = '!' then
    begin
      path:=RightStr(path, Length(path)-1);
      if Exec('/usr/bin/virsh', '-c qemu:///system dominfo '+path) <> 0 then
        if Exec('/usr/bin/virsh', '-c qemu:///system define /home/kveroneau/VMs/'+path+'.xml') <> 0 then
        begin
          ShowMessage('There was an error defining '+path);
          BoxRunning.State:=cbUnchecked;
          Exit;
        end;
      if Exec('/usr/bin/virsh', '-c qemu:///system start '+path) <> 0 then
        ShowMessage('Potential Start-up errors.');
      proc:=TProcess.Create(Nil);
      proc.Executable:='/usr/bin/virt-manager';
      proc.Parameters.CommaText:='-c,qemu:///system,--no-fork,--show-domain-console,'+path;
      proc.Active:=True;
      FBoxes[FRow-1]:=proc;
      ShowMessage('Started KVM Box: '+path);
    end
    else if path[1] = '=' then
    begin
      path:=RightStr(path, Length(path)-1);
      if Exec('/usr/bin/virsh', '-c lxc+ssh://kveroneau@pi4/ dominfo '+path) <> 0 then
      begin
        ShowMessage('There was an error starting '+path);
        BoxRunning.State:=cbUnchecked;
        Exit;
      end;
      if Exec('/usr/bin/virsh', '-c lxc+ssh://kveroneau@pi4/ start '+path) <> 0 then
        ShowMessage('Potential Start-up errors.');
      proc:=TProcess.Create(Nil);
      proc.Executable:='/usr/bin/konsole';
      with proc.Parameters do
      begin
        Add('-e');
        Add('virsh');
        Add('-c');
        Add('lxc+ssh://kveroneau@pi4/');
        Add('console');
        Add(path);
      end;
      proc.Active:=True;
      FBoxes[FRow-1]:=proc;
      ShowMessage('Started LXC System: '+path);
    end
    else
    begin
      if not DirectoryExists('/btrfs/Boxes/'+path) then
      begin
        if SysTemplate.Text = '' then
        begin
          ShowMessage('No Box config found, and no template selected.');
          BoxRunning.State:=cbUnchecked;
          Exit;
        end;
        ExecPath:='/btrfs/Boxes';
        if Exec('/usr/bin/btrfs', 'subvolume snapshot .templates/'+TemplStack.Text+'/'+SysTemplate.Text+' '+path) <> 0 then
        begin
          ShowMessage('Unable to create the new box.');
          BoxRunning.State:=cbUnchecked;
          Exit;
        end;
        ShowMessage('Successfully created box '+path);
        SetupNetwork(path);
      end;
      if not CheckNetworks then
      begin
        ShowMessage('Required Network is not available.');
        BoxRunning.State:=cbUnchecked;
        Exit;
      end;
      proc:=TProcess.Create(Nil);
      proc.Executable:='/usr/bin/86Box';
      proc.CurrentDirectory:='/btrfs/Boxes/'+path;
      if GoFS.Checked then
        proc.Parameters.Add('-F');
      proc.Active:=True;
      FBoxes[FRow-1]:=proc;
      ShowMessage('Box '+path+' has been started.');
    end;
  end
  else
  begin
    if path[1] = '!' then
    begin
      path:=RightStr(path, Length(path)-1);
      if Exec('/usr/bin/virsh', '-c qemu:///system shutdown '+path) <> 0 then
        ShowMessage('Potential shutdown error.');
      Sleep(1000);
    end
    else if path[1] = '=' then
    begin
      path:=RightStr(path, Length(path)-1);
      if Exec('/usr/bin/virsh', '-c lxc+ssh://kveroneau@pi4/ shutdown '+path) <> 0 then
        ShowMessage('Potential shutdown error.');
      Sleep(1000);
    end;
    FBoxes[FRow-1].Active:=False;
    FBoxes[FRow-1].WaitOnExit;
    FreeAndNil(FBoxes[FRow-1]);
    ShowMessage('Box '+path+' has stopped.');
  end;
end;

procedure TSysMgrForm.BasicSwitchClick(Sender: TObject);
begin
  if BasicSwitch.State = cbUnchecked then
  begin
    DeleteFile('/tmp/mysw/ctl');
    RemoveDir('/tmp/mysw');
    TapSwitch.Enabled:=True;
  end
  else
    TapSwitch.Enabled:=False;
end;

procedure TSysMgrForm.AddJournalBtnClick(Sender: TObject);
begin
  JournalIcon.Visible:=True;
  AddJournalBtn.Enabled:=False;
end;

procedure TSysMgrForm.CfgButtonClick(Sender: TObject);
var
  proc: TProcess;
  path: string;
begin
  path:=SysGrid.Cells[3, FRow];
  if path[1] = '!' then
  begin
    path:=RightStr(path, Length(path)-1);
    Exec('/usr/bin/virt-manager','-c qemu:///system --no-fork --show-domain-editor '+path);
  end
  else if path[1] = '=' then
  begin
    path:=RightStr(path, Length(path)-1);
    Exec('/usr/bin/virt-manager','-c lxc+ssh://kveroneau@pi4/ --no-fork --show-domain-editor '+path);
  end
  else
  begin
    proc:=TProcess.Create(Nil);
    try
      proc.Executable:='/usr/bin/86Box';
      proc.CurrentDirectory:='/btrfs/Boxes/'+path;
      proc.Parameters.Add('-S');
      proc.Execute;
      proc.WaitOnExit;
    finally
      proc.Active:=False;
      proc.Free;
    end;
  end;
end;

procedure TSysMgrForm.CloneBtnClick(Sender: TObject);
var
  path, newname: string;
begin
  if BoxRunning.Checked then
  begin
    ShowMessage('Please shutdown the system first!');
    Exit;
  end;
  path:=SysGrid.Cells[3, FRow];
  if path[1] = '!' then
  begin
    ShowMessage('Currently unsupported with KVM Boxes.');
    Exit;
  end;
  ExecPath:='/btrfs/Boxes';
  newname:=InputBox('System Manager', 'Enter in a new name:', path+'a');
  if Exec('/usr/bin/btrfs', 'subvolume snapshot '+path+' '+newname) <> 0 then
  begin
    ShowMessage('There was an error creating the snapshot!');
    Exit;
  end;
  SysGrid.InsertRowWithValues(FRow+1, ['','',SysGrid.Cells[2,FRow], newname]);
  ShowMessage('Successfully created snapshot of '+path);
end;

procedure TSysMgrForm.FormShow(Sender: TObject);
begin
  if Exec('/sbin/ifconfig', 'tap0') <> 0 then
  begin
    //ipaddr:=InputBox('System Manager', 'Please provide an IP address for your TAP?', '192.168.0.254');
    MessageDlg('System Manager', 'No Tap Device detected, aborting.', mtError, [mbOK], '');
    Close;
  end;
  NetProcModule.OnSignal:=@UpdateNetworks;
  ShowMessage('System Manager v0.3b started.');
end;

procedure TSysMgrForm.JournalIconDblClick(Sender: TObject);
var
  frm: TJournalForm;
begin
  frm:=TJournalForm.Create(Self);
  frm.Caption:=SysGrid.Cells[0, FRow];
  frm.OpenJournal('/btrfs/Boxes/'+SysGrid.Cells[3, FRow]+'/journal.txt');
end;

procedure TSysMgrForm.LibraryBtnClick(Sender: TObject);
var
  r: TModalResult;
  fname, ext, path: string;
begin
  LibraryForm.LibraryItem.ItemIndex:=-1;
  r:=LibraryForm.ShowModal;
  fname:=LibraryForm.LibraryItem.Text;
  if (r = mrCancel) or (fname = '') then
    Exit;
  ext:=ExtractFileExt(fname);
  path:=SysGrid.Cells[3, FRow];
  case ext of
    '.86f': CopyFile('/btrfs/Library/'+fname, '/btrfs/Boxes/'+path+'/'+fname);
    '.img': CopyFile('/btrfs/Library/'+fname, '/btrfs/Boxes/'+path+'/'+fname);
    '.vhd': Exec('/bin/ln', '-sf /btrfs/Library/'+fname+' /btrfs/Boxes/'+path+'/'+fname);
    '.iso': Exec('/bin/ln', '-sf '+fpReadLink('/btrfs/Library/'+fname)+' /btrfs/Boxes/'+path+'/'+fname);
  else
    ShowMessage('Library File extension not supported: '+ext);
  end;
end;

procedure TSysMgrForm.LogListDblClick(Sender: TObject);
var
  i: Integer;
begin
  SysJournalBtnClick(Self);
  for i:=0 to LogList.Count-1 do
    FSysJournal.Memo1.Append(LogList.Items.Strings[i]);
end;

procedure TSysMgrForm.NetHostBtnClick(Sender: TObject);
var
  host: string;
begin
  host:=InputBox('System Manager', 'Input Network Target:', NetProcModule.RemoteSwitch.Parameters.Strings[3]);
  if host = '' then
    Exit;
  NetProcModule.RemoteSwitch.Parameters.Strings[3]:=host;
end;

procedure TSysMgrForm.OpenListClick(Sender: TObject);
var
  fname: string;
begin
  if not NetProcModule.OpenDialog.Execute then
    Exit;
  fname:=NetProcModule.OpenDialog.FileName;
  SysGrid.LoadFromCSVFile(fname);
  SetLength(FBoxes, SysGrid.RowCount);
  fname:=ExtractFileName(fname);
  Caption:='System Manager for '+fname;
  OpenList.Enabled:=False;
  if fname = 'corpnet.sl' then
    CorpTap.Enabled:=True;
end;

procedure TSysMgrForm.RemoteSwitchClick(Sender: TObject);
begin
  if NetProcModule.RemoteSwitch.Active then
  begin
    NetHostBtn.Enabled:=False;
    RemoteTap.Enabled:=True
  end
  else if RemoteSwitch.State = cbUnchecked then
  begin
    DeleteFile('/tmp/remote/ctl');
    RemoveDir('/tmp/remote');
    RemoteTap.Enabled:=False;
    NetHostBtn.Enabled:=True;
  end;
end;

procedure TSysMgrForm.RemoteTapClick(Sender: TObject);
begin
  if RemoteTap.State = cbChecked then
    RemoteSwitch.Enabled:=False
  else
    RemoteSwitch.Enabled:=True;
end;

procedure TSysMgrForm.SaveListClick(Sender: TObject);
begin
  if NetProcModule.OpenDialog.FileName = '' then
  begin
    if not NetProcModule.SaveDialog.Execute then
      Exit;
    NetProcModule.OpenDialog.FileName:=NetProcModule.SaveDialog.FileName;
  end
  else
    NetProcModule.SaveDialog.FileName:=NetProcModule.OpenDialog.FileName;
  SysGrid.SaveToCSVFile(NetProcModule.SaveDialog.FileName);
  Caption:='System Manager for '+ExtractFileName(NetProcModule.SaveDialog.FileName);
  ShowMessage('System List Saved.');
  OpenList.Enabled:=False;
end;

procedure TSysMgrForm.SetNetBtnClick(Sender: TObject);
begin
  SetupNetwork(SysGrid.Cells[3, FRow]);
end;

procedure TSysMgrForm.SysGridSelectCell(Sender: TObject; aCol, aRow: Integer;
  var CanSelect: Boolean);
var
  ini: TIniFile;
  path: string;
begin
  CfgButton.Enabled:=True;
  SetNetBtn.Enabled:=True;
  LibraryBtn.Enabled:=True;
  FUpdating:=True;
  FRow:=aRow;
  if not Assigned(FBoxes[aRow-1]) then
    BoxRunning.State:=cbUnchecked
  else if not FBoxes[aRow-1].Active then
  begin
    FreeAndNil(FBoxes[aRow-1]);
    BoxRunning.State:=cbUnchecked;
    ShowMessage('Box '+SysGrid.Cells[3, aRow]+' has stopped.');
  end
  else
  begin
    BoxRunning.State:=cbChecked;
    CfgButton.Enabled:=False;
    SetNetBtn.Enabled:=False;
  end;
  HideAllNICs;
  path:=SysGrid.Cells[3, aRow];
  if path = '' then
  begin
    BoxControls.Caption:='Box Controls';
    LibraryBtn.Enabled:=False;
    Exit;
  end
  else
    BoxControls.Caption:='Box Controls for '+SysGrid.Cells[0, aRow];
  if (path[1] = '!') or (path[1] = '=') then
  begin
    CloneBtn.Enabled:=False;
    SetNetBtn.Enabled:=False;
    AddJournalBtn.Enabled:=False;
    LibraryBtn.Enabled:=False;
    FUpdating:=False;
    Exit;
  end;
  CloneBtn.Enabled:=True;
  ini:=TIniFile.Create('/btrfs/Boxes/'+path+'/86box.cfg');
  try
    if ini.ReadString('Network', 'net_01_net_type', '') = 'vde' then
    begin
      Label1.Visible:=True;
      NIC1Net.Caption:=ini.ReadString('Network', 'net_01_host_device', '');
      NIC1Net.Visible:=True;
    end;
    if ini.ReadString('Network', 'net_02_net_type', '') = 'vde' then
    begin
      Label3.Visible:=True;
      NIC2Net.Caption:=ini.ReadString('Network', 'net_02_host_device', '');
      NIC2Net.Visible:=True;
    end;
    if ini.ReadString('Network', 'net_03_net_type', '') = 'vde' then
    begin
      Label2.Visible:=True;
      NIC3Net.Caption:=ini.ReadString('Network', 'net_03_host_device', '');
      NIC3Net.Visible:=True;
    end;
    if ini.ReadString('Network', 'net_04_net_type', '') = 'vde' then
    begin
      Label4.Visible:=True;
      NIC4Net.Caption:=ini.ReadString('Network', 'net_04_host_device', '');
      NIC4Net.Visible:=True;
    end;
  finally
    ini.Free;
  end;
  if FileExists('/btrfs/Boxes/'+path+'/journal.txt') then
  begin
    AddJournalBtn.Enabled:=False;
    JournalIcon.Visible:=True;
  end
  else
    AddJournalBtn.Enabled:=True;
  FUpdating:=False;
end;

procedure TSysMgrForm.SysJournalBtnClick(Sender: TObject);
var
  fname: string;
begin
  if Assigned(FSysJournal) then
  begin
    FSysJournal.Show;
    Exit;
  end;
  fname:=NetProcModule.OpenDialog.FileName;
  if fname = '' then
  begin
    ShowMessage('Save or Load a new system list first.');
    Exit;
  end;
  fname:=ExtractFileNameWithoutExt(fname);
  FSysJournal:=TJournalForm.Create(Self);
  FSysJournal.Caption:='System Scenario Journal';
  FSysJournal.OpenJournal(fname+'.txt');
end;

procedure TSysMgrForm.TapSwitchClick(Sender: TObject);
begin
  if TapSwitch.State = cbUnchecked then
  begin
    DeleteFile('/tmp/mysw/ctl');
    RemoveDir('/tmp/mysw');
    BasicSwitch.Enabled:=True;
  end
  else
    BasicSwitch.Enabled:=False;
end;

procedure TSysMgrForm.TemplStackChange(Sender: TObject);
var
  lst: TStrings;
  i: Integer;
begin
  if TemplStack.ItemIndex > -1 then
  begin
    Label5.Visible:=True;
    SysTemplate.Visible:=True;
    SysTemplate.Enabled:=True;
  end;
  lst:=FindAllDirectories('/btrfs/Boxes/.templates/'+TemplStack.Text, False);
  try
    SysTemplate.Clear;
    for i:=0 to lst.Count-1 do
      SysTemplate.Items.Add(ExtractFileName(lst.Strings[i]));
  finally
    lst.Free;
  end;
end;

procedure TSysMgrForm.UpdateNetworks(Sender: TObject);
var
  i: integer;
begin
  for i:=0 to NetGroup.ControlCount-1 do
    TTICheckBox(NetGroup.Controls[i]).Update;
end;

procedure TSysMgrForm.HideAllNICs;
begin
  Label1.Visible:=False;
  Label2.Visible:=False;
  Label3.Visible:=False;
  Label4.Visible:=False;
  NIC1Net.Visible:=False;
  NIC2Net.Visible:=False;
  NIC3Net.Visible:=False;
  NIC4Net.Visible:=False;
  JournalIcon.Visible:=False;
end;

function TSysMgrForm.CheckNetworks: Boolean;
begin
  Result:=True;
  if NIC1Net.Visible and (LeftStr(NIC1Net.Caption, 5) = 'vde:/') then
  begin
    if not DirectoryExists(RightStr(NIC1Net.Caption, Length(NIC1Net.Caption)-6)) then
      Result:=False;
  end;
  if NIC2Net.Visible and (LeftStr(NIC2Net.Caption, 5) = 'vde:/') then
  begin
    if not DirectoryExists(RightStr(NIC2Net.Caption, Length(NIC2Net.Caption)-6)) then
      Result:=False;
  end;
  if NIC3Net.Visible and (LeftStr(NIC3Net.Caption, 5) = 'vde:/') then
  begin
    if not DirectoryExists(RightStr(NIC3Net.Caption, Length(NIC3Net.Caption)-6)) then
      Result:=False;
  end;
  if NIC4Net.Visible and (LeftStr(NIC4Net.Caption, 5) = 'vde:/') then
  begin
    if not DirectoryExists(RightStr(NIC4Net.Caption, Length(NIC4Net.Caption)-6)) then
      Result:=False;
  end;
end;

procedure TSysMgrForm.ShowMessage(const msg: string);
begin
  LogList.ItemIndex:=LogList.Items.Add(DateToISO8601(Now)+' | '+msg);
  LogList.MakeCurrentVisible;
end;

procedure TSysMgrForm.SetupNetwork(box: string);
var
  ini: TIniFile;
  vde: string;
begin
  if (BasicSwitch.State = cbChecked) or (TapSwitch.State = cbChecked) then
    vde:='vde:///tmp/mysw'
  else if RemoteSwitch.State = cbChecked then
    vde:='vde:///tmp/remote'
  else
  begin
    vde:=InputBox('System Manager', 'Please state the network:', FLastNet);
    if vde = '' then
      Exit;
    FLastNet:=vde;
  end;
  ini:=TIniFile.Create('/btrfs/Boxes/'+box+'/86box.cfg');
  try
    if ini.ReadString('Network', 'net_01_net_type', '') = 'vde' then
      ini.WriteString('Network', 'net_01_host_device', vde);
  finally
    ini.Free;
  end;
end;

end.


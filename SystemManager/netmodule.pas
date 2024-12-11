unit netmodule;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, ExtCtrls, Controls, Dialogs, process;

type

  TMsgEvent = procedure(Sender: TObject; AMessage: string) of object;

  { TNetProcModule }

  TNetProcModule = class(TDataModule)
    BasicSwitch: TProcess;
    IconList: TImageList;
    OpenDialog: TOpenDialog;
    CorpTap: TProcess;
    RemoteTap: TProcess;
    RemoteSwitch: TProcess;
    SaveDialog: TSaveDialog;
    TapSwitch: TProcess;
    Timer: TTimer;
    procedure TimerTimer(Sender: TObject);
  private
    FSignal: TNotifyEvent;
    sig: Boolean;
    FMsgOut: TMsgEvent;
    procedure CheckProcess(proc: TProcess);
  public
    property OnSignal: TNotifyEvent read FSignal write FSignal;
    property OnMessage: TMsgEvent read FMsgOut write FMsgOut;
  end;

var
  NetProcModule: TNetProcModule;

implementation

{$R *.lfm}

{ TNetProcModule }

procedure TNetProcModule.TimerTimer(Sender: TObject);
begin
  sig:=False;
  CheckProcess(BasicSwitch);
  CheckProcess(RemoteTap);
  CheckProcess(RemoteSwitch);
  CheckProcess(TapSwitch);
  if sig then
    FSignal(Self);
end;

procedure TNetProcModule.CheckProcess(proc: TProcess);
begin
  if proc.Active and (not proc.Running) then
  begin
    if proc.ExitCode <> 0 then
      WriteLn(proc.ExitCode);
    proc.Active:=False;
    sig:=True;
  end;
end;

end.


unit dndchatwindow;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  ExtCtrls, process, aithread;

type

  { TDNDChatForm }

  TDNDChatForm = class(TForm)
    Label1: TLabel;
    Memo1: TMemo;
    Speech: TProcess;
    Timer1: TTimer;
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Memo1KeyPress(Sender: TObject; var Key: char);
    procedure Timer1Timer(Sender: TObject);
  private
    FChat: TAIThread;
    FMessages: TStringList;
  public

  end;

var
  DNDChatForm: TDNDChatForm;

implementation

{$R *.lfm}

{ TDNDChatForm }

procedure TDNDChatForm.Memo1KeyPress(Sender: TObject; var Key: char);
var
  line: string;
  caret: TPoint;
begin
  if Speech.Running then
    Exit;
  Speech.Active:=False;
  if Key = #13 then
  begin
    Memo1.Enabled:=False;
    line:=Memo1.Lines.Strings[Memo1.Lines.Count-1];
    FChat.SendMessage(line);
    repeat
      Application.ProcessMessages;
      //Sleep(5);
    until FChat.MessageReady;
    FMessages.Append(line);
    FMessages.Append(FChat.Message);
    with TFileStream.Create('/tmp/speak.txt', fmCreate) do
    try
      Write(FChat.Message[1], Length(FChat.Message));
    finally
      Free;
    end;
    Speech.Active:=True;
    caret:=Memo1.CaretPos;
    Memo1.Text:=FMessages.Text+#13;
    Memo1.CaretPos:=caret;
    Memo1.Enabled:=True;
  end;
end;

procedure TDNDChatForm.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled:=False;
  FChat.SendMessage('Hi!');
  repeat
    Application.ProcessMessages;
  until FChat.MessageReady;
  FMessages.Text:=FChat.Message;
  Memo1.Text:=FChat.Message+#13;
  with TFileStream.Create('/tmp/speak.txt', fmCreate) do
  try
    Write(FChat.Message[1], Length(FChat.Message));
  finally
    Free;
  end;
  Speech.Active:=True;
end;

procedure TDNDChatForm.FormShow(Sender: TObject);
begin
  FChat:=TAIThread.Create('You are a dungeon master for the popular tabletop RPG game, Dungeons and Dragons. Your job is to guide me through an exciting fantasy world as a real world dungeon master would.','','');
  FChat.Start;
  FMessages:=TStringList.Create;
  Memo1.Text:='Please wait a moment while I prepare our D&D session together...';
end;

procedure TDNDChatForm.FormDestroy(Sender: TObject);
begin
  FChat.StopThread;
  FMessages.Free;
  FChat.WaitFor;
  FChat.Free;
end;

end.


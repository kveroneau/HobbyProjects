unit aithread;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, {$IFDEF MINIAPI}fphttpclient, fpjson, jsonparser{$ELSE}
  OpenAIClient, OpenAIDtos{$ENDIF};

type

  { TAIThread }

  TAIThread = class(TThread)
  private
    FLock: TRTLCriticalSection;
    FEvent: PRTLEvent;
    FRunning: boolean;
    FMsgReady: boolean;
    FMessage: string;
    FPrompt, FModel, FURL: string;
    FMemory: boolean;
    {$IFDEF MINIAPI}
    FMsgList: TJSONObject;
    {$ELSE}
    FClient: IOpenAIClient;
    FMsgList: TChatCompletionRequestMessageList;
    function mkmsg(role, content: string): TChatCompletionRequestMessage;
    {$ENDIF}
    procedure AddMessage(role, content: string);
    procedure SendChat;
  protected
    procedure Execute; override;
  public
    constructor Create(prompt, model, url: string);
    property MessageReady: Boolean read FMsgReady;
    property Message: string read FMessage;
    property EnableMemory: boolean read FMemory write FMemory;
    procedure SendMessage(msg: string);
    procedure StopThread;
  end;

implementation

{ TAIThread }

{$IFDEF MINIAPI}
procedure TAIThread.AddMessage(role, content: string);
var
  msg: TJSONObject;
begin
  msg:=TJSONObject.Create;
  msg.Strings['role']:=role;
  msg.Strings['content']:=content;
  FMsgList.Arrays['messages'].Add(msg);
end;

procedure TAIThread.SendChat;
var
  resp, msg: TJSONObject;
begin
  EnterCriticalSection(FLock);
  AddMessage('user', FMessage);
  FMessage:='';
  LeaveCriticalSection(FLock);
  with TFPHTTPClient.Create(Nil) do
  try
    RequestBody:=TStringStream.Create(FMsgList.AsJSON);
    AddHeader('Content-Type', 'application/json');
    resp:=TJSONObject(GetJSON(Post(FURL+'/chat/completions')));
    msg:=resp.Arrays['choices'].Objects[0].Objects['message'];
    AddMessage(msg.Strings['role'], msg.Strings['content']);
    FMessage:=msg.Strings['content'];
  finally
    Free;
    FMsgReady:=True;
  end;
end;

{$ELSE}
function TAIThread.mkmsg(role, content: string): TChatCompletionRequestMessage;
begin
  Result:=TChatCompletionRequestMessage.Create;
  Result.Role:=role;
  Result.Content:=content;
end;

procedure TAIThread.AddMessage(role, content: string);
begin
  FMsgList.Add(mkmsg(role, content));
end;

procedure TAIThread.SendChat;
var
  req: TCreateChatCompletionRequest;
  resp: TCreateChatCompletionResponse;
  msg: TChatCompletionRequestMessage;
begin
  resp:=Nil;
  req:=TCreateChatCompletionRequest.Create;
  try
    req.Model:=FModel;
    req.Temperature:=0.8;
    if not FMemory then
      req.Messages.Add(mkmsg('system', FPrompt));
    EnterCriticalSection(FLock);
    if FMemory then
      AddMessage('user', FMessage)
    else
      req.Messages.Add(mkmsg('user', FMessage));
    FMessage:='';
    LeaveCriticalSection(FLock);
    if FMemory then
    begin
      for msg in FMsgList do
      begin
        WriteLn(msg.Role+':'+msg.Content);
        req.Messages.Add(mkmsg(msg.Role, msg.Content));
      end;
    end;
    resp:=FClient.OpenAI.CreateChatCompletion(req);
    if Assigned(resp.Choices) and (resp.Choices.Count > 0) then
    begin
      FMessage:=resp.Choices[0].Message.Content;
      AddMessage('assistant', FMessage);
    end
    else
      WriteLn(resp.Choices.Count);
  finally
    req.Free;
    resp.Free;
    FMsgReady:=True;
  end;
end;
{$ENDIF}

procedure TAIThread.Execute;
begin
  InitCriticalSection(FLock);
  FEvent:=RTLEventCreate;
  {$IFDEF MINIAPI}
  FMsgList:=TJSONObject.Create;
  FMsgList.Strings['model']:=FModel;
  FMsgList.Arrays['messages']:=TJSONArray.Create;
  {$ELSE}
  FClient:=TOpenAIClient.Create;
  FClient.Config.BaseUrl:=FURL;
  FMsgList:=TChatCompletionRequestMessageList.Create;
  {$ENDIF}
  AddMessage('system', FPrompt);
  FRunning:=True;
  try
    repeat
      RTLEventResetEvent(FEvent);
      RTLEventWaitFor(FEvent);
      if FMessage <> '' then
        SendChat;
    until not FRunning;
  finally
    FMsgList.Free;
    RTLEventDestroy(FEvent);
    DoneCriticalSection(FLock);
  end;
end;

constructor TAIThread.Create(prompt, model, url: string);
begin
  inherited Create(True);
  if prompt = '' then
    FPrompt:='You are a helpful assistant.'
  else
    FPrompt:=prompt;
  if model = '' then
    FModel:='google/gemma-3-4b'
  else
    FModel:=model;
  if url = '' then
    FURL:= 'http://localhost:1234/v1'
  else
    FURL:=url;
  FMemory:=True;
end;

procedure TAIThread.SendMessage(msg: string);
begin
  EnterCriticalSection(FLock);
  FMsgReady:=False;
  FMessage:=msg;
  LeaveCriticalSection(FLock);
  RTLEventSetEvent(FEvent);
end;

procedure TAIThread.StopThread;
begin
  FRunning:=False;
  FMessage:='';
  RTLEventSetEvent(FEvent);
end;

end.


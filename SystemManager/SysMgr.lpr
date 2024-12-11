program SysMgr;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, runtimetypeinfocontrols, SysMgrWindow, netmodule, JournalViewer, 
LibraryWindow, NewKVMWindow
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Title:='System Manager';
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TSysMgrForm, SysMgrForm);
  Application.CreateForm(TNetProcModule, NetProcModule);
  Application.CreateForm(TLibraryForm, LibraryForm);
  Application.CreateForm(TNewKVMForm, NewKVMForm);
  Application.Run;
end.


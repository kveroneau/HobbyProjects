program VFSBrowser;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, VFSBrowserWindow, VFSEditWindow
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TVFSBrowserForm, VFSBrowserForm);
  Application.CreateForm(TVFSEditForm, VFSEditForm);
  Application.Run;
end.


program ProjMan;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, ProjectPickerWindow, projmodels, ProjectWindow, TaskEditWindow,
  JournalWindow, NotesWindow;

{$R *.res}

begin
  Randomize;
  RequireDerivedFormResource:=True;
  Application.Title:='Project Manager';
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TProjectForm, ProjectForm);
  Application.CreateForm(TProjectPickerForm, ProjectPickerForm);
  Application.CreateForm(TDatabases, Databases);
  Application.CreateForm(TTaskEditForm, TaskEditForm);
  Application.CreateForm(TJournalForm, JournalForm);
  Application.CreateForm(TNotesForm, NotesForm);
  Application.Run;
end.


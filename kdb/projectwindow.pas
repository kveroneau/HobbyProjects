unit ProjectWindow;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ProjectPickerWindow, projmodels, kdbtasks, TaskEditWindow, kdblog, NotesWindow;

type

  { TProjectForm }

  TProjectForm = class(TForm)
    BackBtn: TButton;
    NotesBtn: TButton;
    NewTaskBtn: TButton;
    WorkingList: TListBox;
    TestingList: TListBox;
    DoneList: TListBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    NextBtn: TButton;
    Label1: TLabel;
    InitialList: TListBox;
    NextBtn1: TButton;
    NextBtn2: TButton;
    ProjectTitle: TLabel;
    procedure BackBtnClick(Sender: TObject);
    procedure DoneListDblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure InitialListDblClick(Sender: TObject);
    procedure NewTaskBtnClick(Sender: TObject);
    procedure NextBtn1Click(Sender: TObject);
    procedure NextBtn2Click(Sender: TObject);
    procedure NextBtnClick(Sender: TObject);
    procedure NotesBtnClick(Sender: TObject);
    procedure TestingListDblClick(Sender: TObject);
    procedure WorkingListClick(Sender: TObject);
  private
    procedure RenderKanbanLists;
    procedure OpenTask(lst: TListBox);
  public

  end;

var
  ProjectForm: TProjectForm;

implementation

{$R *.lfm}

{ TProjectForm }

procedure TProjectForm.FormShow(Sender: TObject);
begin
  InitLog('ProjMan');
  if ProjectPickerForm.ShowModal <> mrOK then
    Close;
  ProjectTitle.Caption:=Databases.VFS.DataSet.FieldValues['TITLE'];
  TaskEditForm.ProjectTitle.Caption:=ProjectTitle.Caption;
  Caption:=Caption+' :: '+ProjectTitle.Caption;
  Databases.LogDS.DataSet:=KLogDB;
  WriteLog('Opening Project: '+ProjectTitle.Caption);
  RenderKanbanLists;
end;

procedure TProjectForm.InitialListDblClick(Sender: TObject);
begin
  OpenTask(InitialList);
end;

procedure TProjectForm.BackBtnClick(Sender: TObject);
begin
  WriteLog('Pushing back task: '+TestingList.GetSelectedText);
  UpdateTaskState(TestingList.GetSelectedText, 1);
  RenderKanbanLists;
end;

procedure TProjectForm.DoneListDblClick(Sender: TObject);
begin
  OpenTask(DoneList);
end;

procedure TProjectForm.NewTaskBtnClick(Sender: TObject);
begin
  with TasksDB do
  begin
    Append;
    FieldValues['ProjectID']:=ProjectPickerForm.ProjectID;
    FieldValues['Added']:=Now;
    FieldValues['State']:=0;
    TaskEditForm.Height:=465;
    if TaskEditForm.ShowModal = mrOK then
    begin
      Post;
      WriteLog('Added new Task: '+FieldValues['Title']);
    end
    else
      Cancel;
  end;
  RenderKanbanLists;
end;

procedure TProjectForm.NextBtn1Click(Sender: TObject);
begin
  WriteLog('Progressing Task to Testing: '+WorkingList.GetSelectedText);
  UpdateTaskState(WorkingList.GetSelectedText, 2);
  RenderKanbanLists;
end;

procedure TProjectForm.NextBtn2Click(Sender: TObject);
begin
  WriteLog('Progressing Task to Done: '+TestingList.GetSelectedText);
  UpdateTaskState(TestingList.GetSelectedText, 3);
  RenderKanbanLists;
end;

procedure TProjectForm.NextBtnClick(Sender: TObject);
begin
  WriteLog('Progressing Task to Working: '+InitialList.GetSelectedText);
  UpdateTaskState(InitialList.GetSelectedText, 1);
  RenderKanbanLists;
end;

procedure TProjectForm.NotesBtnClick(Sender: TObject);
begin
  NotesForm.Show;
end;

procedure TProjectForm.TestingListDblClick(Sender: TObject);
begin
  OpenTask(TestingList);
end;

procedure TProjectForm.WorkingListClick(Sender: TObject);
begin
  OpenTask(WorkingList);
end;

procedure TProjectForm.RenderKanbanLists;
var
  st: Integer;
begin
  InitialList.Clear;
  WorkingList.Clear;
  TestingList.Clear;
  DoneList.Clear;
  with TasksDB do
  begin
    First;
    if EOF then
      Exit;
    repeat
      st:=FieldValues['State'];
      case st of
        0: InitialList.Items.Add(FieldValues['Title']);
        1: WorkingList.Items.Add(FieldValues['Title']);
        2: TestingList.Items.Add(FieldValues['Title']);
        3: DoneList.Items.Add(FieldValues['Title']);
      end;
      Next;
    until EOF;
  end;
end;

procedure TProjectForm.OpenTask(lst: TListBox);
begin
  with TasksDB do
  begin
    if not Locate('Title', lst.GetSelectedText, []) then
      Exit;
    WriteLog('Opening Task: '+lst.GetSelectedText);
    TaskEditForm.Height:=706;
    KLogDB.Filter:='APPNAME='+QuotedStr('ProjMan')+' AND MESSAGE='+QuotedStr('*'+lst.GetSelectedText);
    KLogDB.Filtered:=True;
    if TaskEditForm.ShowModal = mrOK then
      Post
    else
      Cancel;
    KLogDB.Filtered:=False;
  end;
  RenderKanbanLists;
end;

end.


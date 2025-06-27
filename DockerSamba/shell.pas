program SambaShell;

{$mode objfpc}{$H+}

uses kexec, ksignals;

var
    Running: Boolean;

procedure HandleSignal;
begin
    Running:=False;
end;

procedure SvcStart(svc: string);
begin
    Write('Starting '+svc+'...');
    Exec('/usr/sbin/'+svc, '-D');
    WriteLn('done.');
end;

procedure AddUser;
var
  username: string;
begin
  Write('Username to add? ');
  ReadLn(username);
  Exec('/usr/sbin/adduser', username);
  Exec('/usr/bin/smbpasswd', '-a '+username);
end;

procedure SmbPasswd;
var
  username: string;
begin
  Write('Username to change password for? ');
  ReadLn(username);
  Exec('/usr/bin/smbpasswd', username);
end;

procedure DoShell;
var
    cmd: string;
begin
  Running:=True;
  Repeat
    Write('* ');
    ReadLn(cmd);
    case cmd of
        'exit': Running:=False;
        'config': Exec('/usr/bin/nano', '/etc/samba/smb.conf');
        'adduser': AddUser;
        'smbpasswd': SmbPasswd;
        'bash': Exec('/bin/bash','');
    else
        WriteLn('?SYNTAX ERROR');
    end;
  Until not Running;
end;

begin
    OnSignalProc:=@HandleSignal;
    SvcStart('nmbd');
    SvcStart('smbd');
    WriteLn('SambaShell started.');
    DoShell;
    WriteLn('All done.');
end.

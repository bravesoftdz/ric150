{
History
1.0.3 ������� �������� ���������� � �����������. ������ CONS*.ANS ���������� �
      �������� CONS ����� RECEIVE. ��� ������� ���������� ������� �����������
      � ������ ������ ������ ������� CONS*.ANS ��� ����� /yes. �� ������ ������
      ����������� �������������� �����.
      ����������� ����������� ��������� ����� /norunner.
      ����������� ������ �� ����������� ������ ��������� ������ ���������� �
      ������ ���� ����������� ����������� ���������� ����������.
1.0.4 ���������� ������ � ������ receivedir.
1.0.6 ���������� ��������� ������� ������������ �� ����������.
      ������ ����� ������� ���������� �������� ��� ����������.
1.0.7 �������� ���������� �� ����������� UIN. ����� �����.
1.0.8 ������� �������� ����������. �������������� ������� ���������� �����.
      ����������� ������ � ������������ UIN ������.
1.1.0 �������� ����������� DTI (����� ����� � ����������� �����).
      ������� ��������� ������ ��� ���������� ������ CONS*.ANS.
1.1.1 ����� �� ������������.
1.2.1 ��������� ����������� ���� � ������ ������ ���.
      ��������� ����������� ������ CONS*.ANS.
}
unit Unit1;
 {$WARN UNIT_PLATFORM OFF}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,  INIFiles,
  Controls, Forms, Dialogs, StdCtrls, checklst, ComCtrls, ExtCtrls, AccCtrl,
  FileCtrl,ShellAPI, ShlObj, Menus;

type
  TForm1 = class(TForm)
    lbCons: TLabel;
    edPathCons: TEdit;
    btPathCons: TButton;
    lbReceive: TLabel;
    edPathReceive: TEdit;
    btPathReceive: TButton;
    btCpReceive: TButton;
    btExit: TButton;
    lbUsr: TLabel;
    edPathUsr: TEdit;
    btPathUsr: TButton;
    btCpUsrQst: TButton;
    GroupBox1: TGroupBox;
    btUpdate: TButton;
    cbExit: TCheckBox;
    clbBases: TCheckListBox;
    StatusBar1: TStatusBar;
    PageControl1: TPageControl;
    tsAction: TTabSheet;
    tsFolders: TTabSheet;
    dtpFrom: TDateTimePicker;
    dtpTill: TDateTimePicker;
    Bevel1: TBevel;
    cbRes: TCheckBox;
    btReg: TButton;
    tsOther: TTabSheet;
    lbQst: TLabel;
    edPathQst: TEdit;
    btPathQst: TButton;
    btTest: TButton;
    cbRunner: TCheckBox;
    btStat: TButton;
    GroupBox2: TGroupBox;
    lbPathUin: TLabel;
    edPathUIN: TEdit;
    btPathUin: TButton;
    cbCopyUIN: TCheckBox;
    btTestRes: TButton;
    btCopyUin: TButton;
    GroupBox3: TGroupBox;
    btUpdateConsOnly: TButton;
    basemenu: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    btCpCons: TButton;
    procedure btExitClick(Sender: TObject);
    procedure btCpReceiveClick(Sender: TObject);
    procedure btPathConsClick(Sender: TObject);
    procedure btPathReceiveClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btCpUsrQstClick(Sender: TObject);
    procedure btPathUsrClick(Sender: TObject);
    procedure btUpdateClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer;
      var Resize: Boolean);
    procedure btRegClick(Sender: TObject);
    procedure btPathQstClick(Sender: TObject);
    procedure btTestClick(Sender: TObject);
    procedure btStatClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btTestResClick(Sender: TObject);
    procedure btPathUinClick(Sender: TObject);
    procedure btCopyUinClick(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure btUpdateConsOnlyClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
  private
    version : string;
    { Private declarations }
    function SelectDirectory: String;
    procedure BuildList;
    procedure setdtpicker;
    procedure ToLog(msg:string; level:integer);
    procedure Statistic;
    procedure CopyUSR;
    procedure CheckBase;
    procedure CopyQST;
    procedure CopyUIN;
    procedure UpdateConsOnly(consExe: PAnsiChar);
  public

    { Public declarations }
  end;

var
  Form1: TForm1;

implementation
{$R *.dfm}
uses Unit2;

var INI:TINIFile;
    UserList:textfile;
    base:string;

//������ ��������� � �������� �� ����������
function WinExecAndWait32(FileName,FileParam: string; Visibility: integer): Integer;

var
  zAppName:array[0..512] of char;
  zCurDir:array[0..255] of char;
  WorkDir:String;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  i : DWORD;

begin
  StrPCopy(zAppName, FileName+' '+FileParam);
  GetDir(0, WorkDir);
  StrPCopy(zCurDir, WorkDir);
  FillChar(StartupInfo, Sizeof(StartupInfo), #0);
  StartupInfo.cb:= Sizeof(StartupInfo);

  StartupInfo.dwFlags:= STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow:= Visibility;
  if not CreateProcess(nil,
    zAppName,                      { pointer to command line string }
    nil,                           { pointer to process security
attributes }
    nil,                           { pointer to thread security attributes }
    false,                         { handle inheritance flag }
    CREATE_NEW_CONSOLE or          { creation flags }
    NORMAL_PRIORITY_CLASS,
    nil,                           { pointer to new environment block }
    nil,                           { pointer to current directory name }
    StartupInfo,                   { pointer to STARTUPINFO }
    ProcessInfo) then
      begin
        Result := -1; { pointer to PROCESS_INF }
      end

  else begin
    while WaitforSingleObject(ProcessInfo.hProcess,200)=WAIT_TIMEOUT do   application.ProcessMessages;
    GetExitCodeProcess(ProcessInfo.hProcess,i);
    result := i;
  end;
end;
      {
procedure FileEx(const FileName : String; Params : String);
var
 ShellInfo : TShellExecuteInfo;
 //ParamsString : String;
 error:cardinal;
begin
  //ParamsString := Format('-em %s %s.aaa', [FileName, FileName]);
  ShellInfo.cbSize := SizeOf(ShellInfo);
  ShellInfo.fMask := SEE_MASK_NOCLOSEPROCESS;
  ShellInfo.Wnd := Application.Handle;
  ShellInfo.lpVerb := 'open';
  ShellInfo.lpFile := PChar(FileName);
  ShellInfo.lpParameters := PChar(Params); //PChar(ParamsString);
  ShellInfo.lpDirectory := nil;
  ShellInfo.nShow := SW_SHOW;

  if not ShellExecuteEx(@ShellInfo)
  then RaiseLastOSError();

  if ShellInfo.hProcess <> 0 then
    try
      WaitForSingleObjectEx(ShellInfo.hProcess, INFINITE, false);
    finally
      if not GetExitCodeProcess(ShellInfo.hProcess,error) then
        showmessage('��� �������� '+inttostr(Error));
      CloseHandle(ShellInfo.hProcess);
    end;
end;
       }
// ��������� ������ ��������� � ���
// �������������: ToLog(message,color);
// �����: 0 - �������, 1 - �����, 2 - �������. ��� ��������� ����� - ������
procedure TForm1.ToLog(msg:string; level:integer);
var
  i:integer;
  line_length:integer;
begin
 Form2.RichEdit1.Lines.Add(msg);
 if level<>4 then
   with Form2.RichEdit1 do
    begin
       line_length:=0;
       for i := 0 to lines.Count-1 do
          line_length:=line_length+length(lines[i])+1;
       selstart:=line_length-length(lines[lines.Count-1])+lines.Count-2;
       // ����� ������� ������
       sellength:=length(lines[lines.Count-1]);// ����� ������ ���������� ���������
       case level of
        0:  begin
              SelAttributes.Color         := clGreen;
            end;
        1:  begin
              SelAttributes.Color         := clOlive;
            end;
        2:  begin
              SelAttributes.Color         := clRed;
            end;
       end;
//       form2.Caption:=inttostr(line_length)+'-'+inttostr(selstart)+'-'+inttostr(length(lines[lines.Count-1]))+'-'+lines[lines.Count-1];
    end;
//0 - ���������
//1 - ����������
//2 - ������
  Form2.RichEdit1.Perform(WM_VSCROLL, SB_LINEDOWN, 1);
end;

// ������ ���������� �� ����� last_rec.txt
procedure TForm1.Statistic;
var
  basedesc: string;
  checkhost: string;
  update: string;
  LastRec: Textfile;
  dir: string;
begin
  { DONE : ����� ���������� � ��� ����� ����������}
  try
    dir := edPathCons.Text;
    AssignFile(lastrec, dir + '\receive\last_rec.txt');
    reset(lastrec);
    while not EOF(lastrec) do
    begin
      readln(lastrec, checkhost);
      base := copy(checkhost, 1, pos(',', checkhost) - 1);
      delete(checkhost, 1, pos(',', checkhost)); // ������� ����
      basedesc := copy(checkhost, 1, pos(',', checkhost) - 1);
      delete(checkhost, 1, pos(',', checkhost)); // ������� ����������� ����
      delete(checkhost, 1, pos(',', checkhost)); // ������� ���-�� ����������
      delete(checkhost, 1, pos(',', checkhost)); // ������� ���-�� ���������� � ��������
      update := copy(checkhost, 1, pos(',', checkhost) - 1);
      delete(checkhost, 1, pos(',', checkhost)); // ������� ���-�� ����������
      if pos('#HOST', checkhost) <> 0 then
      begin // ����� ��������� � ����� � ����
        ToLog('������ ' + basedesc + ' (' + base + '): �����. ����: '+update, 2);
        Application.ProcessMessages;
      end
      else
      begin // ����� ��������� � ������� ����
        ToLog('������ ' + basedesc + ' (' + base + '): ��. ����: '+update, 0);
        Application.ProcessMessages;
      end;
    end;
    CloseFile(Lastrec);
  except
    ToLog('last_rec.txt �� ������', 2);
  end;
end;

procedure TForm1.CopyUSR;
var
  SR: TSearchRec;
  ff: Integer;
  name: string;
begin
  { DONE : ����������� ������ ������ }
  if not (DirectoryExists(edPathUsr.Text) and DirectoryExists(edPathCons.Text)) then
    ToLog('����� ��� ������� �� �������', 2);
  if DirectoryExists(edPathUsr.Text) and DirectoryExists(edPathCons.Text) then
  begin
    ToLog('����� ��� ������� �������', 0);
    ToLog(edPathUsr.Text, 0);
    ff := FindFirst(edPathCons.Text + '\receive\cons*.usr', faAnyFile - faDirectory, SR);
    while ff = 0 do
    begin
      name := SR.Name;
      if copyfile(PChar(edPathCons.Text + '\receive\' + SR.Name), PChar(edPathUsr.Text + '\' + SR.Name), false) then
        ToLog('���������� �����: ' + name, 4)
      else
        ToLog('������ �����������: ' + name, 2);
      ff := FindNext(SR);
      Application.ProcessMessages;
    end;
    FindClose(SR);
    ToLog('����������� ���������', 0);
  end
end;

procedure TForm1.CheckBase;
var
  basedesc: string;
  ConsParam: PAnsiChar;
  dir: string;
  LastRec: TextFile;
  consExe: PAnsiChar;
  checkhost: string;
  base: string;
begin
  dir := edPathCons.Text;
  { DONE : �������� ��� � ������������ �������� }
  try
    AssignFile(lastrec, dir + '\receive\last_rec.txt');
    reset(lastrec);
    ConsExe := PChar(edPathCons.Text + '\cons.exe');
    while not EOF(lastrec) do
    begin
      readln(lastrec, checkhost);
      if pos('#HOST', checkhost) <> 0 then
      begin
        base := copy(checkhost, 1, pos(',', checkhost) - 1);
        delete(checkhost, 1, pos(',', checkhost));
        basedesc := copy(checkhost, 1, pos(',', checkhost) - 1);
        delete(checkhost, 1, pos(',', checkhost));
        ToLog('������ �� ����: ' + basedesc + ' (' + base + ')', 2);
        ConsParam := PChar(' /adm /quest /base_' + base);
        WinExecAndWait32(ConsExe, ConsParam, SW_SHOW);
        Application.ProcessMessages;
      end;
    end;
    CloseFile(Lastrec);
  except
    ToLog('last_rec.txt �� ������', 2);
  end;
end;

procedure TForm1.CopyQST;
var
  qst: Boolean;
  ff: Integer;
  SR: TSearchRec;
begin
  { DONE : ����������� ������ ������� }
  qst := false;
  if DirectoryExists(edPathQst.Text) and DirectoryExists(edPathCons.Text) then
  begin
    ToLog('����� ��� �������� �������', 0);
    ToLog(edPathQst.Text, 0);
    ff := FindFirst(edPathCons.Text + '\send\*.qst', faAnyFile - faDirectory, SR);
    while ff = 0 do
    begin
      qst := true;
      if pos('00001', SR.Name) <> 0 then
        deletefile(edPathCons.Text + '\send\' + SR.Name)
      else
      begin
        if movefile(PChar(edPathCons.Text + '\send\' + SR.Name), PChar(edPathQst.Text + '\' + SR.Name)) then
          ToLog('��������� ������: ' + SR.Name, 1)
        else
          ToLog('������ ��������: ' + SR.Name, 1);
      end;
      ff := FindNext(SR);
      application.ProcessMessages;
    end;
    FindClose(SR);
    if qst then
    begin
      ToLog('������� �������� ��������', 0);
    end;
  end
  else
    begin
      ToLog('����� ��� �������� �� �������', 2);
    end;
end;

procedure TForm1.CopyUIN;
var
  ff: Integer;
  SR: TSearchRec;
  name: string;
begin
  { DONE : ����������� ������ UIN }
  if DirectoryExists(edPathUIN.Text) and DirectoryExists(edPathCons.Text) then
  begin
    ToLog('����� ��� UIN �������', 0);
    ToLog(edPathUIN.Text, 0);
    ff := FindFirst(edPathCons.Text + '\distr\uin\*.dti', faAnyFile - faDirectory, SR);
    while ff = 0 do
    begin
      name := SR.Name;
      if copyfile(PChar(edPathCons.Text + '\distr\uin\' + SR.Name), PChar(edPathUIN.Text + '\' + SR.Name), false) then
        ToLog('���������� ����: ' + name, 4)
      else
        ToLog('������ �����������: ' + name, 2);
      ff := FindNext(SR);
      Application.ProcessMessages;
    end;
    FindClose(SR);
    ToLog('����������� ���������', 0);
  end
  else
    ToLog('����� ��� UIN �� �������', 2);
end;

procedure TForm1.UpdateConsOnly(consExe: PAnsiChar);
var
  consParam: PAnsiChar;
begin
  // ������ �� ���������� ������ CONS*.ANS
  ToLog(edPathCons.Text + '\cons.exe /adm /receive /base* /receivedir="' + edPathCons.Text + '\receive\cons"', 1);
  ConsParam := PChar(' /adm /receive /base* /receivedir="' + edPathCons.Text + '\receive\cons"');
  if WinExecAndWait32(ConsExe, ConsParam, SW_SHOW)=3 then
    ToLog('�� ������� ����� �� �����', 2)
end;

// ��������� ������������ ��� ������ �����
function TForm1.SelectDirectory: String;
var
  lpItemID : PItemIDList;
  BrowseInfo : TBrowseInfo;
  DisplayName : array[0..MAX_PATH] of Char;
  TempPath : array[0..MAX_PATH] of Char;
begin
  FillChar(BrowseInfo, sizeof(TBrowseInfo), #0);
  BrowseInfo.hwndOwner := Handle;
  BrowseInfo.pszDisplayName := @DisplayName;
  BrowseInfo.lpszTitle := '�������� �������';
  BrowseInfo.ulFlags := BIF_RETURNONLYFSDIRS;
  lpItemID := SHBrowseForFolder(BrowseInfo);
  if Assigned(lpItemId) then begin
    SHGetPathFromIDList(lpItemID, TempPath);
    GlobalFreePtr(lpItemID);
  end else Result := '';
  Result := String(TempPath);
end;

// ��������� ����������� ������ ��������� ���
procedure TForm1.BuildList;
var
    i,j:integer;
    offlist:TStringList;
begin
  { DONE : ������������ ������ ��������� ��� }
try
  if DirectoryExists(edPathCons.Text) then
  begin
    ToLog('����� ��������������� �������',0);
    Assignfile(UserList, edPathCons.Text + '\base\baselist.cfg');
    Reset(UserList);
    while not EOF(UserList) do
    begin
      readln(UserList, base);
      if base <> '' then
      begin
        ToLog('������� ����: ' + base,1);
        clbBases.Items.Add(base);
      end;
    end;
  end
  else
    ToLog('����� ��������������� �� �������',2);
  for i := 0 to clbBases.Count - 1 do
    clbBases.Checked[i] := true;
  offlist:=TStringList.Create;
  Ini.ReadSection('Bases',offlist);
  for i := 0 to clbBases.Count - 1 do
    for j := 0 to offlist.Count - 1 do
      if clbBases.Items.Strings[i]=offlist.Strings[j] then
        clbBases.Checked[i] := false;
  offlist.Free;
except
  ToLog('������ ��������� ������ ���',2);
end;
end;

procedure TForm1.btUpdateConsOnlyClick(Sender: TObject);
var
  consExe : PChar;
begin
{ DONE : ������ ����������� �� ���������� }
ConsExe:=PChar(edPathCons.Text+'\cons.exe');
ToLog('������ ������������ �� ���������� ������ CONS*.ANS',0);
UpdateConsOnly(consExe);
end;

// ������������ ���������� ������
procedure TForm1.btPathUinClick(Sender: TObject);
var Dir:string;
begin
 Dir:=Selectdirectory;
if DirectoryExists(dir) then
  edPathUin.Text:=Dir;
end;

procedure TForm1.btTestResClick(Sender: TObject);
var
  consExe : PChar;
  consParam : PChar;
begin
ToLog('������ ������������ ���������� ������',0);
ToLog(edPathCons.Text+'\cons.exe /test',0);
ConsExe:=PChar(edPathCons.Text+'\cons.exe');
ConsParam:=' /test';
WinExecAndWait32(ConsExe, ConsParam, SW_SHOW);
ToLog('������������ ���������� ������ ���������',0);

end;

procedure TForm1.btCopyUinClick(Sender: TObject);
begin
  CopyUIN;
end;

// ����� ����� ��� ���������� �����������
procedure TForm1.btPathConsClick(Sender: TObject);
var Dir:string;
begin
 Dir:=Selectdirectory;
if DirectoryExists(dir) then
  edPathCons.Text:=Dir;
 buildList;
end;
// ����� ����� ���� ����� ����������� �������
procedure TForm1.btPathQstClick(Sender: TObject);
var Dir:string;
begin
 Dir:=Selectdirectory;
if DirectoryExists(dir) then
  begin
    edPathQst.Text:=Dir;
  end;
end;
// ����� ����� ������ ����� ������������ ����������
procedure TForm1.btPathReceiveClick(Sender: TObject);
var Dir:string;
begin
 Dir:=Selectdirectory;
if DirectoryExists(dir) then
  begin
    edPathReceive.Text:=Dir;
    SetDTPicker;
  end;
end;
// ��������� ����������� ����������
procedure TForm1.btCpReceiveClick(Sender: TObject);
var SR:TSearchRec;
    ff:integer;
    i:integer;
    dt:TdateTime;
begin
ToLog('�������� ������� �����',0);
{ DONE : ����������� ������ ���������� }
if DirectoryExists(edPathReceive.Text)
  then
    begin
      ToLog('����� ���������� �������',1);
      clbBases.Items.add('CONS');
      //�������� ����� ��� cons*.ans
      if not DirectoryExists(edPathCons.Text+'\receive\cons') then
        begin
          if CreateDir(edPathCons.Text+'\receive\cons') then
            ToLog('������� �������� CONS',4)
          else
            ToLog('������ �������� �������� CONS',2);
        end;
      clbBases.Checked[clbBases.Items.Count-1]:=true;
      for i := 0 to clbBases.Count - 1 do
        if clbBases.Checked[i] then
          begin
            ff:=FindFirst(edPathReceive.Text+'\'+clbBases.Items[i]+'*.*',faAnyFile-faDirectory,SR);
            While ff=0 do
              begin
                dt:=FileDateToDateTime(SR.Time);
                if (dt>=dtpFrom.DateTime) and (dt<=dtpTill.DateTime) then
                  begin
                    if pos('CONS',SR.Name)<>0 then     // cons*.ans ���������� ����� � ������ �����
                      begin
                        if copyfile(PChar(edPathReceive.Text+'\'+SR.Name),PChar(edPathCons.Text+'\receive\cons\'+SR.Name),false) then
                           ToLog('����������: cons\'+SR.Name,4)
                        else
                           ToLog('������ �����������: '+SR.Name,2);
                        if copyfile(PChar(edPathReceive.Text+'\'+SR.Name),PChar(edPathCons.Text+'\receive\'+SR.Name),false) then
                           ToLog('����������: '+SR.Name,4)
                        else
                           ToLog('������ �����������: '+SR.Name,2)
                      end
                    else
                      if not (Sender=btCpCons) then
                        begin
                          if copyfile(PChar(edPathReceive.Text+'\'+SR.Name),PChar(edPathCons.Text+'\receive\'+SR.Name),false) then
                            ToLog('����������: '+SR.Name,4)
                          else
                            ToLog('������ �����������: '+SR.Name,2);
                        end;
                  end;
                ff:=FindNext(SR);
                Application.ProcessMessages;
              end;
            FindClose(SR);
          end;
       // ����������� ���������� ������
       if cbRes.Checked then
          begin
            ff:=FindFirst(edPathReceive.Text+'\'+'*.res',faAnyFile-faDirectory,SR);
            While ff=0 do
              begin
                copyfile(PChar(edPathReceive.Text+'\'+SR.Name),PChar(edPathCons.Text+'\receive\'+SR.Name),false);
                ToLog('����������: '+SR.Name,1);
                ff:=FindNext(SR);
                Application.ProcessMessages;
              end;
            FindClose(SR);
          end;
      ToLog('����������� ���������',0);
      clbBases.Items.Delete(clbBases.Items.Count-1);

    end
  else
    ToLog('����� ���������� �� �������',2);
end;
// �����
procedure TForm1.btExitClick(Sender: TObject);
begin
  Form1.Close;
end;
// ����� ����� ���� ����� ����������� ������, ��� ������ ����� ��� ��������
// ��������������� ����� ��
procedure TForm1.btPathUsrClick(Sender: TObject);
var Dir:string;
begin
 Dir:=Selectdirectory;
if DirectoryExists(dir) then
  begin
    edPathUsr.Text:=Dir;
    edPathQst.Text:=Dir;
    edPathUin.Text:=Dir;
  end;
end;

// ����������� ������� � ��������
procedure TForm1.btCpUsrQstClick(Sender: TObject);
begin
  CopyUSR;
  CheckBase;
  CopyQST;
  if cbCopyUIN.Checked then CopyUIN;  
end;

// ������ ����������
procedure TForm1.btUpdateClick(Sender: TObject);
var
  consExe : PChar;
  consParam : PChar;
  LogStr : string;
begin
{ DONE : ������ ����������� �� ���������� }
ConsExe:=PChar(edPathCons.Text+'\cons.exe');
ToLog('������ ������������ �� ����������',0);

//if cbUpdateCons.Checked then
  begin
    // ������ �� ���������� ������ CONS*.ANS
    ToLog('�������� ���������� ����� (���������� ������ cons*.ans)',0);
    ToLog(edPathCons.Text + '\cons.exe /adm /receive /base* /receivedir="' + edPathCons.Text + '\receive\cons"', 1);
    ConsParam := PChar(' /adm /receive /base* /receivedir="' + edPathCons.Text + '\receive\cons"');
    if WinExecAndWait32(ConsExe, ConsParam, SW_HIDE)=3 then
        ToLog('�� ������� ����� �� �����', 2)
    else
      begin
        ToLog('�������� ����������',0);
        if cbRunner.Checked then
          begin
            ConsParam:=' /adm /receive /base* /yes  /norunner';
            LogStr:=string(ConsExe)+string(ConsParam);
            ToLog(LogStr,1);
            WinExecAndWait32(ConsExe, ConsParam, SW_SHOW);
          end
        else
          begin
            ConsParam:=' /adm /receive /base* /yes';
            LogStr:=string(ConsExe)+string(ConsParam);
            ToLog(LogStr,1);
            WinExecAndWait32(ConsExe, ConsParam, SW_SHOW);
          end;
        if cbExit.Checked then Form1.Close;
        // ����� ����������
        Statistic;
      end;
  end;
end;
// ������ �����������
procedure TForm1.btRegClick(Sender: TObject);
var
  consExe : PChar;
  consParam : PChar;
begin
ConsParam:=' /adm /reg*';
ConsExe:=PChar(edPathCons.Text+'\cons.exe');
WinExecAndWait32(ConsExe, ConsParam, SW_SHOW);
end;

// ����� ���������� � ���
procedure TForm1.btStatClick(Sender: TObject);
begin
Statistic;
end;
// ������ �������� ������������ ���
procedure TForm1.btTestClick(Sender: TObject);
var
  consExe : PChar;
  consParam : PChar;
begin
ToLog('������ ������������ ���',0);
ToLog(edPathCons.Text+'\cons.exe /adm /base* /basetest',0);
ConsExe:=PChar(edPathCons.Text+'\cons.exe');
ConsParam:=' /adm /base* /basetest ';
WinExecAndWait32(ConsExe, ConsParam, SW_SHOW);
ToLog('������������ ��� ���������',0);

end;

procedure TForm1.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
Resize:=false;
end;
// ����������  ��������� � ���������� ����������
procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var i:integer;
    cl:TStringList;
begin
try
  cl:=TStringList.Create;
  Ini.ReadSection('Bases',cl);
  for i := 0 to cl.Count - 1 do
    ini.DeleteKey('Bases',cl.Strings[i]);
  cl.Free;
  for i := 0 to clbBases.Count-1 do
    if not clbBases.Checked[i] then
      Ini.WriteInteger('Bases',clbBases.Items[i],0);
  Ini.WriteString('Main','Cons',edPathCons.Text);
  Ini.WriteString('Main','Receive',edPathReceive.Text);
  Ini.WriteString('Main','USR',edPathUsr.Text);
  Ini.WriteString('Main','QST',edPathQst.Text);
  Ini.WriteString('Main','UIN',edPathUin.Text);
  Ini.WriteBool('Main','CopyUIN',cbCopyUIN.Checked);
  Ini.WriteString('Main','Version',version);
  Ini.Free;
except
  showmessage('������ ����������');
  application.Terminate;
end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
Version:='Ric150 v1.2.1';
end;

procedure TForm1.FormHide(Sender: TObject);
begin
form2.Hide;
end;

// ��������� ��� � ���������� - ��������������� ���� ������ ������� �����
// ���������� � ���� ������ ������ ����� ����������
procedure TForm1.setdtpicker;
var SR:TSearchRec;
    ff:integer;
    min:TDatetime;
begin
min:=Now;
if DirectoryExists(edPathReceive.Text)
  then
    begin
      ff:=FindFirst(edPathReceive.Text+'\cons*.*',faAnyFile-faDirectory,SR);
      While ff=0 do
        begin
          if FileDateToDateTime(SR.Time)<=min then min:=FileDateToDateTime(SR.Time);
          ReplaceTime(min,0);
          ff:=FindNext(SR);
          Application.ProcessMessages;
        end;
      FindClose(SR);
    end;
dtpFrom.DateTime:=min;
dtpTill.DateTime:=Now;
end;
// ������ ���������� �� ����� ��������
procedure TForm1.FormShow(Sender: TObject);
var error:boolean;
begin
PageControl1.ActivePageIndex:=0;
form2.Show;
ToLog(version,1);
ToLog('��������� ��������� �� ����� ������n��������',2);
ToLog('                 �� ������������� ���������',2);
ToLog('� ������������ �� ������������� �� ����',2);
{ DONE : ������ ������ �� ����� �������� }
Ini := TIniFile.Create('.\ric150.ini');
error:=false;
if not fileexists('.\ric150.ini') then
    begin
      ToLog('������: �� ������ ���� � �����������.',2);
      error:=true;;
      Ini.WriteString('Main','Cons','');
      Ini.WriteString('Main','Receive','');
      Ini.WriteString('Main','USR','');
      Ini.WriteString('Main','QST','');
      Ini.WriteString('Main','UIN','');
      Ini.WriteBool('Main','CopyUIN',false);
      Ini.WriteString('Main','Version',version);
    end;
if not error then
  begin

      ToLog('������ ���� � �����������',0);
      edPathCons.Text:=INI.ReadString('Main','Cons','');
      edPathReceive.Text:=INI.ReadString('Main','Receive','');
      edPathUsr.Text:=INI.ReadString('Main','USR','');
      edPathQst.Text:=INI.ReadString('Main','QST','');
      edPathUIN.Text:=INI.ReadString('Main','UIN','');
      cbCopyUIN.Checked:=INI.ReadBool('Main','CopyUIN',false);
      Form1.Caption:=Version;
  end;
BuildList;
Setdtpicker;
end;

procedure TForm1.N1Click(Sender: TObject);
var
  i:integer;
begin
  for i:= 0 to clbBases.Items.Count - 1 do
      clbBases.Checked[i]:=true;
end;

procedure TForm1.N2Click(Sender: TObject);
var
  i:integer;
begin
  for i:= 0 to clbBases.Items.Count - 1 do
      clbBases.Checked[i]:=false;
end;

procedure TForm1.N3Click(Sender: TObject);
var
  i:integer;
begin
  for i:= 0 to clbBases.Items.Count - 1 do
      clbBases.Checked[i]:= not clbBases.Checked[i];
end;

end.

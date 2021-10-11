unit FleshData;

interface

Uses Windows, SysUtils, Classes;

type
 TReadProgressProcedure = Procedure (Pos: integer; BadSectors: integer);

type
 TWriteProgressProcedure = Procedure (Pos: integer; BadSectors: integer);

type
 TProgressDone = Procedure;

type
  TCreateImage = class(TThread)
  private
    Procedure CreateImage(Drive: PChar; InFile:PChar; ReadBadCount: Integer; Progress: TReadProgressProcedure; BuffSize: integer = 1024; ReadBad: Boolean = False);
  protected
    procedure Execute; override;
  public
    Drive     : PChar;
    OutFile   : PChar;
    BadCount  : Integer;
    ReadBad   : Boolean;
    Speed     : integer;
    Process   : TReadProgressProcedure;
    Done      : TProgressDone;
  end;

type
  TWriteImage = class(TThread)
  private
    Procedure WriteImage(Drive: PChar; InFile:PChar; ReadBadCount: Integer; Progress: TReadProgressProcedure; BuffSize: integer = 1024; ReadBad: Boolean = False);
  protected
    procedure Execute; override;
  public
    Drive     : PChar;
    FromFile  : PChar;
    BadCount  : Integer;
    ReadBad   : Boolean;
    Speed     : integer;
    Process   : TReadProgressProcedure;
    Done      : TProgressDone;
  end;

type
  TAnalyzeDrive = class(TThread)
  private
    Procedure Analyze(Drive: PChar; Progress: TReadProgressProcedure; BuffSize: integer = 1024);
  protected
    procedure Execute; override;
  public
    Drive     : PChar;
    Speed     : integer;
    Process   : TReadProgressProcedure;
    Done      : TProgressDone;
  end;

Function GetDriveSize(Drive: Char; BuffSize: integer = 1024): integer;
Function GetSize(FileN: String): integer;
implementation

Function GetSize(FileN: String): integer;
var
hdc : cardinal;
Buf: integer;
begin
try
hdc := FileOpen(FileN,0);
buf := GetFileSize(hdc,0);
result := buf;
FileClose(hdc);
except
end;
end;

Function GetDriveSize(Drive: Char; BuffSize: integer = 1024): integer;
begin
Result := DiskSize(Ord(Drive) - $40) div BuffSize;
end;

Procedure TCreateImage.CreateImage(Drive: PChar; InFile:PChar; ReadBadCount: Integer; Progress: TReadProgressProcedure; BuffSize: integer = 1024; ReadBad: Boolean = False);
var
HDC_Dev : integer;
HDC_Fle : integer;
Buff    : Pchar;
xRead   : dword;
i,j     : integer;
DevSize : integer;

BadClP  : integer;
begin
i:=0;
j:=0;
Buff := AllocMem(BuffSize);
DevSize := DiskSize(Ord(Drive[0]) - $40) div BuffSize;

HDC_Dev := CreateFile(PChar('\\.\'+Drive[0]+':'),GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,0,0);
HDC_Fle := CreateFile(InFile,GENERIC_WRITE,FILE_SHARE_WRITE,0,CREATE_NEW,0,0);

SetFilePointer(HDC_Dev,0,Nil,FILE_BEGIN);
While i <= DevSize do begin
  if ReadFile(HDC_Dev,Buff^,BuffSize,xRead,nil) then begin
    WriteFile(HDC_Fle,Buff^,BuffSize,xRead,nil);
    BadClP := 0;
    Progress(i,j);
    Inc(i);
  end else begin
    if BadClP = 0 then inc(j);
    Progress(i,j);
    if ReadBad = true then begin
    BadClP := BadClP + 1;
    if BadClP >= ReadBadCount then Inc(i);
    end;
    if ReadBad = False then inc(i);
  end;

end;

  FreeMem(Buff);
  FileClose(HDC_Dev);
  FileClose(HDC_Fle);
end;

Procedure TCreateImage.Execute;
begin
Speed := Speed * 1024;
CreateImage(Drive,OutFile,ReturnValue,Process,Speed,ReadBad);
Done;
end;

{}

Procedure TWriteImage.WriteImage(Drive: PChar; InFile:PChar; ReadBadCount: Integer; Progress: TReadProgressProcedure; BuffSize: integer = 1024; ReadBad: Boolean = False);
var
HDC_Dev : integer;
HDC_Fle : integer;
Buff    : Pchar;
xRead   : dword;
i,j     : integer;
DevSize : integer;

BadClP  : integer;
begin
i:=0;
j:=0;
Buff := AllocMem(BuffSize);
DevSize := GetSize(InFile) div Speed;

HDC_Dev := CreateFile(PChar('\\.\'+Drive[0]+':'),GENERIC_WRITE,FILE_SHARE_WRITE,0,OPEN_EXISTING,0,0);
HDC_Fle := CreateFile(InFile,GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,0,0);

SetFilePointer(HDC_Dev,0,Nil,FILE_BEGIN);
While i <= DevSize do begin
  if ReadFile(HDC_Fle,Buff^,BuffSize,xRead,nil) then begin
    WriteFile(HDC_Dev,Buff^,BuffSize,xRead,nil);
    BadClP := 0;
    Progress(i,j);
    Inc(i);
  end else begin
    if BadClP = 0 then inc(j);
    Progress(i,j);
    if ReadBad = true then begin
    BadClP := BadClP + 1;
    if BadClP >= ReadBadCount then Inc(i);
    end;
    if ReadBad = False then inc(i);
  end;

end;

  FreeMem(Buff);
  FileClose(HDC_Dev);
  FileClose(HDC_Fle);
end;

Procedure TWriteImage.Execute;
begin
Speed := Speed * 1024;
WriteImage(Drive,FromFile,ReturnValue,Process,Speed,ReadBad);
Done;
end;

{}

Procedure TAnalyzeDrive.Analyze(Drive: PChar; Progress: TReadProgressProcedure; BuffSize: integer = 1024);
var
HDC_Dev : integer;
Buff    : Pchar;
xRead   : dword;
i,j     : integer;
DevSize : integer;

BadClP  : integer;
begin
i:=0;
j:=0;
Buff := AllocMem(BuffSize);
DevSize := DiskSize(Ord(Drive[0]) - $40) div BuffSize;
HDC_Dev := CreateFile(PChar('\\.\'+Drive[0]+':'),GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,0,0);
SetFilePointer(HDC_Dev,0,Nil,FILE_BEGIN);
While i <= DevSize do begin
  if ReadFile(HDC_Dev,Buff^,BuffSize,xRead,nil) then begin
    BadClP := 0;
    Progress(i,j);
    Inc(i);
  end else begin
    if BadClP = 0 then inc(j);
    Progress(i,j);
    BadClP := BadClP + 1;
    Inc(i);
    end;

end;
  FreeMem(Buff);
  FileClose(HDC_Dev);
end;

Procedure TAnalyzeDrive.Execute;
begin
Speed := Speed * 1024;
Analyze(Drive,Process,Speed);
Done;
end;

end.

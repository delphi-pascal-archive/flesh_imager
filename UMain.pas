unit UMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ExtCtrls, ComCtrls, StdCtrls, XPMan, ImgList, FleshData,
  Buttons, Spin;

type
  TMainForm = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    ListView1: TListView;
    Panel1: TPanel;
    PopupMenu1: TPopupMenu;
    TopPanel: TPanel;
    Image12: TImage;
    Image13: TImage;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label21: TLabel;
    Label1: TLabel;
    Bevel1: TBevel;
    Button1: TButton;
    Button2: TButton;
    Bevel2: TBevel;
    ProgressBar1: TProgressBar;
    Label2: TLabel;
    GroupBox1: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    ProgressBar2: TProgressBar;
    GroupBox2: TGroupBox;
    Label16: TLabel;
    Label20: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label31: TLabel;
    TabSheet4: TTabSheet;
    GroupBox3: TGroupBox;
    Label24: TLabel;
    Label32: TLabel;
    Label33: TLabel;
    Label34: TLabel;
    Label35: TLabel;
    Label37: TLabel;
    Label38: TLabel;
    Label39: TLabel;
    Label40: TLabel;
    ProgressBar3: TProgressBar;
    XPManifest1: TXPManifest;
    Createimage1: TMenuItem;
    Writeimage1: TMenuItem;
    N1: TMenuItem;
    Analyzedrive1: TMenuItem;
    N2: TMenuItem;
    Refresh1: TMenuItem;
    TabSheet5: TTabSheet;
    ImageList: TImageList;
    GroupBox4: TGroupBox;
    CheckBox1: TCheckBox;
    SpinEdit1: TSpinEdit;
    Bevel3: TBevel;
    Edit1: TEdit;
    Label30: TLabel;
    SpeedButton1: TSpeedButton;
    Bevel4: TBevel;
    Label36: TLabel;
    SpinEdit2: TSpinEdit;
    Timer1: TTimer;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Label41: TLabel;
    Label42: TLabel;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    ToolButton1: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Refresh1Click(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure Createimage1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Writeimage1Click(Sender: TObject);
    procedure Analyzedrive1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;
  CreateImage: TCreateImage;
  WriteImage: TWriteImage;
  Analyze: TAnalyzeDrive;
  Tme,TM : TTime;

implementation

uses AboutFrm;

Procedure ActiveTabs;
var
i: integer;
begin
MainForm.SpeedButton2.Visible := false;
MainForm.SpeedButton3.Visible := false;
MessageDlg('Progress complete!',mtInformation,[mbYes],0);

for i := 0 to MainForm.PageControl1.PageCount-1 do begin
  MainForm.PageControl1.Pages[i].TabVisible := False;
end;
  MainForm.PageControl1.Pages[0].TabVisible := True;
  MainForm.PageControl1.Pages[4].TabVisible := True;
  MainForm.PageControl1.Pages[0].Show;
end;

Procedure DeactiveTabs(ActiveTab: integer);
var
i: integer;
begin
MainForm.SpeedButton2.Visible := True;
MainForm.SpeedButton3.Visible := True;

for i := 0 to MainForm.PageControl1.PageCount-1 do begin
  MainForm.PageControl1.Pages[i].TabVisible := False;
end;
  MainForm.PageControl1.Pages[ActiveTab].TabVisible := True;
  MainForm.PageControl1.Pages[ActiveTab].Show;
end;

Procedure ProgressOfAnalyze(Pos: integer; BadSectors: integer);
var
percent: integer;
begin
try
Percent := MainForm.ProgressBar3.Max div 100;
Percent := Pos div (percent+1);
MainForm.ProgressBar3.Position := Pos;
MainForm.Label40.Caption := inttostr(percent) + '% is done...';
MainForm.Label37.Caption := inttostr(Pos);
MainForm.Label38.Caption := inttostr(BadSectors);
Application.ProcessMessages;
except
end;
end;

Procedure ProgressOfCreateImage(Pos: integer; BadSectors: integer);
var
percent: integer;
Mb: integer;
begin
try
Percent := MainForm.ProgressBar1.Max div 100;
Percent := Pos div (percent+1);
MainForm.ProgressBar1.Position := Pos;
MainForm.Label2.Caption := inttostr(percent) + '% is done...';
MainForm.Label11.Caption := inttostr(Pos);
MainForm.Label12.Caption := inttostr(BadSectors);
Application.ProcessMessages;
except
end;
end;

Procedure ProgressOfWriteImage(Pos: integer; BadSectors: integer);
var
percent: integer;
Mb: integer;
begin
try
Percent := MainForm.ProgressBar2.Max div 100;
Percent := Pos div (percent+1);
MainForm.ProgressBar2.Position := Pos;
MainForm.Label15.Caption := inttostr(percent) + '% is done...';
MainForm.Label28.Caption := inttostr(Pos);
MainForm.Label29.Caption := inttostr(BadSectors);
Application.ProcessMessages;
except
end;
end;
{Create Drive list}
function CreateDrivesList(ListView: TListView): boolean;
var
  Bufer : array[0..1024] of char;
  RealLen, i : integer;
  S : string;
begin
  ListView.Clear;
  RealLen := GetLogicalDriveStrings(SizeOf(Bufer),Bufer);
  i := 0; S := '';
  while i < RealLen do begin
    if Bufer[i] <> #0 then begin
    S := S + Bufer[i];
    inc(i);
    end else begin
    inc(i);
    with ListView.Items.Add do begin
      Caption := S;
      if GetDriveType(PChar(S)) = DRIVE_RAMDISK then ImageIndex := 3;
      if GetDriveType(PChar(S)) = DRIVE_FIXED then ImageIndex := 3;
      if GetDriveType(PChar(S)) = DRIVE_REMOTE then ImageIndex := 0;
      if GetDriveType(PChar(S)) = DRIVE_CDROM then ImageIndex := 1;
      if GetDriveType(PChar(S)) = DRIVE_REMOVABLE then ImageIndex := 2;
    end;
    S := '';
  end;
  end;
  Result := ListView.items.Count > 0;
end;
{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
TM := Time;
CreateDrivesList(ListView1);
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
Close;
end;

procedure TMainForm.Refresh1Click(Sender: TObject);
begin
CreateDrivesList(ListView1);
end;

procedure TMainForm.PopupMenu1Popup(Sender: TObject);
begin
if ListView1.ItemIndex <> -1 then begin
  Createimage1.Enabled := True;
  Writeimage1.Enabled := true;
  Analyzedrive1.Enabled := True;
end else begin
  Createimage1.Enabled := False;
  Writeimage1.Enabled := False;
  Analyzedrive1.Enabled := False;
end;
end;

procedure TMainForm.Createimage1Click(Sender: TObject);
begin
if (ListView1.ItemIndex <> -1) or
(GetDriveSize(ListView1.Items.Item[ListView1.ItemIndex].Caption[1]) <> 0)
then
if SaveDialog1.Execute then begin

CreateImage := TCreateImage.Create(True);
CreateImage.Drive := PChar(ListView1.Items.Item[ListView1.ItemIndex].Caption);
Createimage.ReadBad := CheckBox1.Checked;
CreateImage.BadCount := SpinEdit1.Value;
Createimage.Speed := SpinEdit2.Value;
Createimage.OutFile := PChar(SaveDialog1.FileName);
Createimage.Process := ProgressOfCreateImage;
CreateImage.Done := ActiveTabs;
Createimage.Resume;
{}
DeactiveTabs(1);
Label9.Caption := ListView1.Items.Item[ListView1.ItemIndex].Caption;
Label10.Caption := Inttostr(SpinEdit2.Value) + ' ('+inttostr(SpinEdit2.Value * 1024)+' kb\s)';
Label13.Caption := BoolToStr(CheckBox1.Checked,true);
TM := Time;
Timer1.Enabled := true;
ProgressBar1.Max := GetDriveSize(ListView1.Items.Item[ListView1.ItemIndex].Caption[1],(SpinEdit2.Value * 1024));
{}
end else begin
MessageDlg('Drive for image create not select or empty!',mtWarning,[mbYes],0);
end;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
Label14.Caption := TimeToStr(Time-TM);
Label31.Caption := TimeToStr(Time-TM);
Label39.Caption := TimeToStr(Time-TM);
end;

procedure TMainForm.Writeimage1Click(Sender: TObject);
begin
if (ListView1.ItemIndex <> -1) or
(GetDriveSize(ListView1.Items.Item[ListView1.ItemIndex].Caption[1]) <> 0)
then
if OpenDialog1.Execute then begin

If GetSize(OpenDialog1.FileName) <=0 then exit;

WriteImage := TWriteImage.Create(True);
WriteImage.Drive := PChar(ListView1.Items.Item[ListView1.ItemIndex].Caption);
WriteImage.ReadBad := CheckBox1.Checked;
WriteImage.BadCount := SpinEdit1.Value;
WriteImage.Speed := 1;
WriteImage.FromFile := PChar(OpenDialog1.FileName);
WriteImage.Process := ProgressOfWriteImage;
WriteImage.Done := ActiveTabs;
WriteImage.Resume;
{}
DeactiveTabs(2);
Label26.Caption := ListView1.Items.Item[ListView1.ItemIndex].Caption;
Label27.Caption := Inttostr(SpinEdit2.Value) + ' ('+inttostr(1024)+' kb\s)';
Label29.Caption := BoolToStr(CheckBox1.Checked,true);
TM := Time;
Timer1.Enabled := true;
ProgressBar2.Max := GetSize(OpenDialog1.FileName) div (SpinEdit2.Value * 1024);
{}
end else begin
MessageDlg('Drive for image write not select or bad image!',mtWarning,[mbYes],0);
end;
end;

procedure TMainForm.Analyzedrive1Click(Sender: TObject);
begin
if (ListView1.ItemIndex <> -1) or
(GetDriveSize(ListView1.Items.Item[ListView1.ItemIndex].Caption[1]) <> 0)
then begin

Analyze := TAnalyzeDrive.Create(True);
Analyze.Drive := PChar(ListView1.Items.Item[ListView1.ItemIndex].Caption);
Analyze.Speed := SpinEdit2.Value;
Analyze.Process := ProgressOfAnalyze;
Analyze.Done := ActiveTabs;
Analyze.Resume;
{}
DeactiveTabs(3);
Label35.Caption := ListView1.Items.Item[ListView1.ItemIndex].Caption;
Label42.Caption := Inttostr(SpinEdit2.Value) + ' ('+inttostr(SpinEdit2.Value * 1024)+' kb\s)';

TM := Time;
Timer1.Enabled := true;
ProgressBar3.Max := GetDriveSize(ListView1.Items.Item[ListView1.ItemIndex].Caption[1],(SpinEdit2.Value * 1024));
{}
end else begin
MessageDlg('Drive for image create not select or empty!',mtWarning,[mbYes],0);
end;
end;

procedure TMainForm.Button2Click(Sender: TObject);
begin
aboutform.ShowModal;
end;

procedure TMainForm.SpeedButton2Click(Sender: TObject);
begin

if SpeedButton2.Tag = 0 then begin
SpeedButton2.Tag := 1;
Timer1.Enabled := True;
if PageControl1.Pages[1].TabVisible = true then begin
  CreateImage.Resume;
end;
if PageControl1.Pages[2].TabVisible = true then begin
  WriteImage.Resume;
end;
if PageControl1.Pages[3].TabVisible = true then begin
  Analyze.Resume;
end;
end else begin
SpeedButton2.Tag := 0;
Timer1.Enabled := False;
if PageControl1.Pages[1].TabVisible = true then begin
  CreateImage.Suspend;
end;
if PageControl1.Pages[2].TabVisible = true then begin
  WriteImage.Suspend;
end;
if PageControl1.Pages[3].TabVisible = true then begin
  Analyze.Suspend;
end;
end;

end;

procedure TMainForm.SpeedButton3Click(Sender: TObject);
begin
ActiveTabs;

if PageControl1.Pages[1].TabVisible = true then begin
  CreateImage.Suspend;
  CreateImage.Terminate;
end;
if PageControl1.Pages[2].TabVisible = true then begin
  WriteImage.Suspend;
  WriteImage.Terminate;
end;
if PageControl1.Pages[3].TabVisible = true then begin
  Analyze.Suspend;
  Analyze.Terminate;
end;
end;
end.

unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, SPComm, SerialPortsCtrl, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.StdCtrls, Vcl.Buttons, Vcl.Imaging.pngimage;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    StatusBar1: TStatusBar;
    Bevel1: TBevel;
    Timer1: TTimer;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Panel2: TPanel;
    Bevel2: TBevel;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    GroupBox2: TGroupBox;
    Label3: TLabel;
    Edit3: TEdit;
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure Image3Click(Sender: TObject);
    procedure Image4Click(Sender: TObject);
  private
    { Private declarations }
    procedure ReceiveData(Sender: TObject; Buffer: PAnsiChar;
      BufferLength: Word);
  public
    { Public declarations }
    procedure ListPorts;
    procedure ComConnect;

    procedure SaveParam(arg1, arg2: string);
  end;

var
  Form1: TForm1;
  CommMain: TComm;

implementation

{$R *.dfm}

uses Unit2, Unit3;

procedure TForm1.SaveParam(arg1, arg2:string);
var
 st : ansistring;
begin
   st := arg1+'='+ trim(arg2);
  CommMain.WriteCommData(PAnsiChar(st), length(st));
end;

procedure TForm1.ComConnect;
begin

  Image3.Enabled := false;
  Image4.Enabled := false;
  CommMain.CommName := form2.cb1.Text;
  CommMain.BaudRate := strtoint(form2.cb2.Text);
  CommMain.Parity := None;
  CommMain.ByteSize := _8;
  CommMain.StopBits := _1;
  CommMain.InputLen := 255;
  CommMain.StartComm;
  if (CommMain.PortOpen) then
  begin
    StatusBar1.Panels[0].Text := '?????????? ' + form2.cb1.Text + ' ?? ' +
      form2.cb2.Text + ' ???.';
    Image3.Enabled := true;
    Image4.Enabled := true;
  end;
end;

procedure TForm1.ListPorts;
var
  i: Integer;
begin
  CommMain := TComm.Create(Self);
  CommMain.OnReceiveData := ReceiveData;
  EnumComPorts(form2.cb1.Items);
  if form2.cb1.Items.Count > 0 then
  begin
    form2.cb1.ItemIndex := 0;

  end
  else
  begin

    StatusBar1.Panels[0].Text := '??????????? COM ?????.';
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  CommMain.StopComm;
  CommMain.Free;
end;

procedure TForm1.Image1Click(Sender: TObject);
begin

  if form2.cb1.Text = '' then
    exit;

  if (not CommMain.PortOpen) then
  begin
    ComConnect;
  end
  else
  begin
    CommMain.StopComm;
    StatusBar1.Panels[0].Text := '';
    Image3.Enabled := false;
    Image4.Enabled := false;

  end;
end;

procedure TForm1.Image2Click(Sender: TObject);
begin
  form2.ShowModal;
end;

procedure TForm1.Image3Click(Sender: TObject);
begin
  if (not CommMain.PortOpen) then
    exit;
  CommMain.WriteCommData('getinfo', length('getinfo'));
end;

procedure TForm1.Image4Click(Sender: TObject);
var
  st: ansistring;
begin
  if (not CommMain.PortOpen) then
    exit;
  form3.Gauge1.Progress := 0;
  form3.Show;
  //st := 'dvid=' + trim(Edit3.Text);
  //CommMain.WriteCommData(PAnsiChar(st), length(st));
  SaveParam('dvid',Edit3.Text);
  form3.Gauge1.Progress := 25;
  sleep(1000);
  //CommMain.StopComm;

  //ComConnect;
  form3.Gauge1.Progress := 50;
  sleep(1000);
  //st := 'pswd=' + trim(Edit2.Text);
  //CommMain.WriteCommData(PAnsiChar(st), length(st));
  SaveParam('pswd',Edit2.Text);
  //CommMain.StopComm;
  sleep(1000);

 // ComConnect;
  form3.Gauge1.Progress := 75;
  sleep(1000);

  //st := 'ssid=' + trim(Edit1.Text);
  //CommMain.WriteCommData(PAnsiChar(st), length(st));
  SaveParam('ssid',Edit1.Text);

  //CommMain.StopComm;

  form3.Gauge1.Progress := 100;
  sleep(400);
  form3.Close;

end;

procedure TForm1.ReceiveData(Sender: TObject; Buffer: PAnsiChar;
  BufferLength: Word);
var
  i: Integer;
  SerailBufferA: ansistring;
  s, st: string;
begin
  SerailBufferA := '';
  for i := 1 to BufferLength do
  begin
    SerailBufferA := SerailBufferA + (PAnsiChar(Buffer)^);
    if (i <> BufferLength) then
      Inc(Buffer);
  end;

  if pos('[ssid]=', SerailBufferA) > 0 then
  begin
    s := SerailBufferA;
    delete(s, 1, pos('[ssid]=', SerailBufferA) + 6);
    st := copy(s, 1, pos(#13, s) - 1);
    Edit1.Text := st;
  end;

  if pos('[pswd]=', SerailBufferA) > 0 then
  begin
    s := SerailBufferA;
    delete(s, 1, pos('[pswd]=', SerailBufferA) + 6);
    st := copy(s, 1, pos(#13, s) - 1);
    Edit2.Text := st;
  end;

  if pos('[dvid]=', SerailBufferA) > 0 then
  begin
    s := SerailBufferA;
    delete(s, 1, pos('[dvid]=', SerailBufferA) + 6);
    st := copy(s, 1, pos(#13, s) - 1);
    Edit3.Text := st;
  end;

  // lb.Items.add(datetostr(date)+'    '+TimetoStr(time)+'     ????? ????? ' + SerailBufferA);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := false;

  ListPorts;

  if form2.cb1.Text = '' then
    exit;

  if (not CommMain.PortOpen) then
  begin
    ComConnect;
  end
  else
  begin
    CommMain.StopComm;
    StatusBar1.Panels[0].Text := '';
    Image3.Enabled := false;
    Image4.Enabled := false;

  end;
end;

end.

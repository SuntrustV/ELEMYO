unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls;

type
  TForm2 = class(TForm)
    Bevel1: TBevel;
    cb1: TComboBox;
    BitBtn1: TBitBtn;
    cb2: TComboBox;
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation
uses unit1;
{$R *.dfm}

procedure TForm2.BitBtn1Click(Sender: TObject);
begin
  close;
end;

end.

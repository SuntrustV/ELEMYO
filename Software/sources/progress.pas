unit progress;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Samples.Gauges, Vcl.ExtCtrls;

type
  Tprogrssform = class(TForm)
    Panel1: TPanel;
    Bevel1: TBevel;
    g1: TGauge;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  progrssform: Tprogrssform;

implementation

{$R *.dfm}

end.

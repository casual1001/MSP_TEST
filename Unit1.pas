unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.OleServer, SpeechLib_TLB,
  Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    ComboBox1: TComboBox;
    Button1: TButton;
    SpInprocRecognizer1: TSpInprocRecognizer;
    SpInProcRecoContext1: TSpInProcRecoContext;
    Button2: TButton;
    SpVoice1: TSpVoice;
    ComboBox2: TComboBox;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  i: integer;
  theRecognizers: ISpeechObjectTokens;
  aRecognizer: ISpeechObjectToken;
begin
  theRecognizers := SpInprocRecognizer1.GetRecognizers('','');
  for i := 0 to theRecognizers.Count - 1 do
  begin
    aRecognizer := theRecognizers.Item(i);
    combobox1.Items.Add(aRecognizer.GetDescription(0));
  end;


end;

procedure TForm1.Button2Click(Sender: TObject);
var
  i: integer;
  grammar: ISpeechRecoGrammar;
  theVoices : ISpeechObjectTokens;
  aVoice: ISpeechObjectToken;
begin

  theVoices := spvoice1.GetVoices('','');
  for i := 0 to theVoices.Count - 1 do
  begin
    aVoice := theVoices.Item(i);
    combobox2.Items.Add(aVoice.GetDescription(0));
  end;




end;

procedure TForm1.Button3Click(Sender: TObject);
var
  aVoice : ISpeechObjectToken;
begin
  spVoice1.Voice := spVoice1.GetVoices('','').Item(combobox2.ItemIndex);
  spVoice1.Speak('i am awake',0);
end;

end.

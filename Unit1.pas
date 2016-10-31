unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.OleServer, SpeechLib_TLB,activeX, comobj,
  Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    cbbSpeakers: TComboBox;
    SpInprocRecognizer1: TSpInprocRecognizer;
    Context1: TSpInProcRecoContext;
    SpVoice1: TSpVoice;
    cbbRecognizers: TComboBox;
    Button3: TButton;
    btnAdd: TButton;
    Category1: TSpObjectTokenCategory;
    Token1: TSpObjectToken;
    Memo1: TMemo;
    ListBox1: TListBox;
    Label1: TLabel;
    Edit1: TEdit;
    btnRemove: TButton;
    Label2: TLabel;
    Label3: TLabel;
    Button1: TButton;
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbbSpeakersChange(Sender: TObject);
    procedure cbbRecognizersChange(Sender: TObject);
    procedure Context1Hypothesis(ASender: TObject; StreamNumber: Integer;
      StreamPosition: OleVariant; const Result: ISpeechRecoResult);
    procedure Context1Recognition(ASender: TObject; StreamNumber: Integer;
      StreamPosition: OleVariant; RecognitionType: TOleEnum;
      const Result: ISpeechRecoResult);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    speechInitialized : boolean;

    grammar: ISpRecoGrammar;
    procedure ListAllRecognizers;
    procedure ListAllSpeakers;
    procedure releaseAllRecognizers;
    procedure releaseAllSpeakers;
    procedure InitializeSpeech;
    function ReBuildGrammar : boolean;
    function EnabledSpeech: boolean;
    function DisabledSpeech: boolean;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses SpeechStringConstants;

function TForm1.EnabledSpeech:boolean;
begin
  result := false;
  if not speechInitialized then
    initializeSpeech
  else
    rebuildGrammar;
  result := true;
end;

function TForm1.DisabledSpeech: boolean;
begin
  if speechInitialized then
    context1.State := SRCS_Disabled;
  result := true;

end;

function TForm1.ReBuildGrammar:boolean;
begin


end;

procedure TForm1.InitializeSpeech;
var
  prop:  SPPROPERTYINFO;
  spStateHandle: pointer;
begin
  Memo1.Lines.Add('Initializing objects.....');
  try

    Category1.SetId(SpeechCategoryAudioIn,false);
    Token1.SetId(Category1.Default,Category1.Id,false);
    Context1.Recognizer.AudioInput := Token1.DefaultInterface;

    grammar := Context1.CreateGrammar(0) as ISpRecoGrammar;
    {
    grammar.GetRule(nil,1,SRATopLevel or SRADefaultToActive,1,spStateHandle);
    grammar.AddWordTransition(spStateHandle,nil,'red',' ',SPWT_LEXICAL,1,prop);

    grammar.GetRule(nil,2,SRATopLevel or SRADefaultToActive,1,spStateHandle);
    grammar.AddWordTransition(spStateHandle,nil,'dog',' ',SPWT_LEXICAL,1,prop);
    grammar.AddWordTransition(spStateHandle,nil,'cat',' ',SPWT_LEXICAL,1,prop);

    grammar.GetRule(nil,3,SRATopLevel or SRADefaultToActive,1,spStateHandle);
    grammar.AddWordTransition(spStateHandle,nil,'orange',' ',SPWT_LEXICAL,1,prop);
    grammar.AddWordTransition(spStateHandle,nil,'apple',' ',SPWT_LEXICAL,1,prop);

    grammar.Commit(0);
    }
    grammar.LoadCmdFromFile('d:\test\g.grxml',SPLO_STATIC );

    grammar.SetRuleState('', nil, SPRS_ACTIVE);
  //  grammar.SetRuleIdState(2,SPRS_ACTIVE);
  //  context1.Recognizer.State := SRSActive;


    speechInitialized := true;

  except
    showmessage('except');
  end;
end;

procedure TForm1.ListAllRecognizers;
var
  i: integer;
  theRecognizers: ISpeechObjectTokens;
  aRecognizer: ISpeechObjectToken;
begin
  theRecognizers := SpInprocRecognizer1.GetRecognizers('','');
  for i := 0 to theRecognizers.Count - 1 do
  begin
    aRecognizer := theRecognizers.Item(i);
    cbbRecognizers.Items.AddObject(aRecognizer.GetDescription(0),Pointer(aRecognizer));
    aRecognizer._AddRef;
  end;
end;

procedure TForm1.ListAllSpeakers;
var
  i: integer;
  theVoices : ISpeechObjectTokens;
  aVoice: ISpeechObjectToken;
begin
  theVoices := spvoice1.GetVoices('','');
  for i := 0 to theVoices.Count - 1 do
  begin
    aVoice := theVoices.Item(i);
    cbbSpeakers.Items.AddObject(aVOice.GetDescription(0),Pointer(aVoice));
    aVoice._AddRef;
  end;
end;

procedure TForm1.releaseAllRecognizers;
var
  i: integer;
begin
  for I := 0 to cbbRecognizers.Items.Count-1 do
  begin
    ISPeechObjectToken(Pointer(cbbRecognizers.Items.Objects[i]))._Release;
  end;

end;

procedure TForm1.releaseAllSpeakers;
var
  i: integer;
begin
  for i:=0  to cbbSpeakers.Items.Count - 1 do
  begin
    ISPeechObjectToken(Pointer(cbbSpeakers.Items.Objects[i]))._Release;
  end;

end;


procedure TForm1.Button1Click(Sender: TObject);
begin
  context1.Recognizer.State := SRSActive;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  spVoice1.Speak('i am awake',0);
end;

procedure TForm1.cbbSpeakersChange(Sender: TObject);
begin
  if cbbSpeakers.ItemIndex >=  0 then
  begin
    SpVoice1.Voice := ISPeechObjectTOken(Pointer(cbbSpeakers.Items.Objects[cbbSpeakers.ItemIndex]));
  end;
end;

procedure TForm1.cbbRecognizersChange(Sender: TObject);
begin
  if cbbRecognizers.ItemIndex >= 0 then
  begin
    context1.Disconnect;
    SpInProcRecognizer1.Recognizer := ISpeechObjectToken(Pointer(cbbRecognizers.Items.Objects[cbbRecognizers.ItemIndex]));
    context1.ConnectTo(SpInProcRecognizer1.CreateRecoContext);
  end;
end;

procedure TForm1.Context1Hypothesis(ASender: TObject; StreamNumber: Integer;
  StreamPosition: OleVariant; const Result: ISpeechRecoResult);
var
  e: ISPeechPhraseElement;
begin
  e := result.PhraseInfo.Elements.Item(0);
  memo1.Lines.Add('Hypothesis: '+ result.PhraseInfo.GetText(0,-1,true) + ', ' +
                 streamNumber.ToString()+', '+vartostr(streamPosition));

  memo1.Lines.Add(format('%.1f',[e.EngineConfidence*100])+'%');

end;

procedure TForm1.Context1Recognition(ASender: TObject; StreamNumber: Integer;
  StreamPosition: OleVariant; RecognitionType: TOleEnum;
  const Result: ISpeechRecoResult);
var
  e: ISPeechPhraseElement;
begin
  e := result.PhraseInfo.Elements.Item(0);
  Memo1.Lines.Add('Recognition: '+ result.PhraseInfo.GetText(0,-1,true)+', '+
        streamNumber.ToString()+', '+vartostr(streamposition));

  memo1.Lines.Add(format('EngineConfidence: %.1f',[e.EngineConfidence*100])+'%');
  memo1.Lines.Add('RequiredConfidence: '+ vartostr(e.RequiredConfidence));
  memo1.Lines.Add('ActualConfidnece: '+ vartostr(e.ActualConfidence));
  memo1.Lines.Add(e.DisplayText);
  memo1.Lines.Add(e.LexicalForm);
  memo1.Lines.Add(e.Pronunciation[0]);

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  speechInitialized := false;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  releaseAllRecognizers;
  releaseAllSpeakers;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  listAllSpeakers;
  listAllRecognizers;
  if cbbSpeakers.Items.Count > 4 then
  begin
    cbbSpeakers.ItemIndex := 4;
    cbbSpeakersChange(cbbSpeakers);
  end;
  if cbbRecognizers.Items.Count >4 then
  begin
    cbbRecognizers.ItemIndex := 4;
    cbbRecognizersChange(cbbRecognizers);
  end;
  initializeSpeech;
end;

end.

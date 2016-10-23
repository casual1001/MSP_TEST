unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.OleServer, SpeechLib_TLB,activeX,
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
    SpMMAudioIn1: TSpMMAudioIn;
    Memo1: TMemo;
    ListBox1: TListBox;
    CheckBox1: TCheckBox;
    Label1: TLabel;
    Edit1: TEdit;
    btnRemove: TButton;
    Label2: TLabel;
    Label3: TLabel;
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbbSpeakersChange(Sender: TObject);
    procedure cbbRecognizersChange(Sender: TObject);
    procedure Context1Hypothesis(ASender: TObject; StreamNumber: Integer;
      StreamPosition: OleVariant; const Result: ISpeechRecoResult);
    procedure Context1Recognition(ASender: TObject; StreamNumber: Integer;
      StreamPosition: OleVariant; RecognitionType: TOleEnum;
      const Result: ISpeechRecoResult);
    procedure CheckBox1Click(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    speechInitialized : boolean;

    hr : HRESULT;
    Grammar : ISpGrammarBuilder;
    ruleTopLevel: ISpeechGrammarRule;
    ruleListItems: ISpeechGrammarRule;
    stateAfterSelect: ISpeechGrammarRuleState;

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
var
  i: integer;
  count: integer;
  PropValue: OleVariant;
begin
  result := false;
  if not checkbox1.Checked then
    exit;
  try
    ruleListItems.Clear;
    count := listbox1.Items.Count;
    for i := 0 to count-1 do
    begin
      ruleListItems.InitialState.AddWordTransition(nil,listbox1.Items[i],'',SGLexical,
          Listbox1.Items[i],i,propValue,1);
    end;
    grammar.Rules.Commit;
  except
    on e: exception do
      memo1.Lines.Add('Exception caught when rebuilding dynamic Listbox rule. \r\n\r\n'+e.Message);
  end;


end;

procedure TForm1.InitializeSpeech;
var
  PropValue : OleVariant;
  hStateTravel : Pointer;
begin
  Memo1.Lines.Add('Initializing objects.....');
  try
    Category1.SetId(SpeechCategoryAudioIn,false);
    Token1.SetId(Category1.Default,SpeechCategoryAudioIn,false);
    Context1.Recognizer.AudioInput := Token1.DefaultInterface;
    hr := S_OK;
    hr := Context1.CreateGrammar(0,grammar);




    hr := grammar.GetRule('Travel',0,SRATopLevel or SRADynamic,true,hStateTravel);
    if succeeded(hr) then
    begin
      hr := grammar.AddWordTransition(hStateTravel,nil,'fly to Seattle',' ',SPWT_LEXICAL,1,nil);
    end;
    if succeeded(hr) then
    begin
      hr := grammar.AddWordTransition(hStateTravel,nil,'fly to New York',' ',SPWT_LEXICAL,1,nil);
    end;
    if succeeded(hr) then
    begin
      hr := grammar.AddWordTransition(hStateTravel,nil,'fly to Washington DC',' ',SPWT_LEXICAL,1,nil);
    end;
    if succeeded(hr) then
    begin
      hr := grammar.AddWordTransition(hStateTravel,nil,'drive to Seattle',' ',SPWT_LEXICAL,1,nil);
    end;
    if succeeded(hr) then
    begin
      hr := grammar.AddWordTransition(hStateTravel,nil,'drive to New York',' ',SPWT_LEXICAL,1,nil);
    end;
    if succeeded(hr) then
    begin
      hr := grammar.AddWordTransition(hStateTravel,nil,'drive to Washington DC',' ',SPWT_LEXICAL,1,nil);
    end;




  //  ruleToplevel := grammar.Rules.Add('TopLevelRule',SRATopLevel or SRADynamic,1);
 //   ruleListItems := grammar.Rules.Add('ListItemsRule',SRADynamic,2);
    stateAfterSelect.AddRuleTransition(nil,ruleListItems,'',1,PropValue,1.0);
    RebuildGrammar;
 //   grammar.CmdSetRuleState('TopLevelRule',SGDSActive);
    context1.Recognizer.State := SRSActive;

    speechInitialized := true;

  except

  end;
end;

procedure TForm1.btnAddClick(Sender: TObject);
begin
  if trim(edit1.Text)<>'' then
  begin
    if listbox1.Items.IndexOf(trim(edit1.Text))=-1 then
    begin
      listbox1.Items.Add(trim(edit1.Text));
      if checkbox1.Checked then
        RebuildGrammar();
    end;
  end;
end;

procedure TForm1.btnRemoveClick(Sender: TObject);
begin
  if listbox1.ItemIndex = -1 then
  begin
    showmessage('please select an item to remove!');
    exit;
  end;
  listbox1.DeleteSelected;
  if checkbox1.Checked then
    reBuildGrammar();
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

{

Function TSRRule.AddWord (Word : String; Value : string = ''; Separator : char = '|') : integer;
var
  OleValue : OleVariant;
begin
  result := 0;
  if Fwordlist.IndexOf(Word) = -1 then
     begin
       OleValue := Value;
       Fwordlist.Add(Word);
       FRule.InitialState.AddWordTransition(nil,  word, Separator, SPWT_LEXICAL, FRuleName+'_value',Fwordlist.Count, OleValue, 1.0);
       FWordCount := Fwordlist.Count;
       result := FWordCount;
     end;
end;
}


procedure TForm1.Button3Click(Sender: TObject);
begin
  spVoice1.Speak('i am awake',0);
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
  if checkbox1.Checked then
    enabledSpeech
  else
    disabledSpeech;
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
  memo1.Lines.Add('Hypothesis: '+ result.PhraseInfo.GetText(0,-1,true) + ', ' +
                 streamNumber.ToString()+', '+vartostr(streamPosition));
  e := result.PhraseInfo.Elements.Item(0);
  memo1.Lines.Add(format('%.1f',[e.EngineConfidence*100])+'%');

end;

procedure TForm1.Context1Recognition(ASender: TObject; StreamNumber: Integer;
  StreamPosition: OleVariant; RecognitionType: TOleEnum;
  const Result: ISpeechRecoResult);
var
  e: ISPeechPhraseElement;
begin
  Memo1.Lines.Add('Recognition: '+ result.PhraseInfo.GetText(0,-1,true)+', '+
        streamNumber.ToString()+', '+vartostr(streamposition));
  e := result.PhraseInfo.Elements.Item(0);
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
//  context1.ConnectTo(SpInprocRecognizer1.CreateRecoContext);


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

end;

end.

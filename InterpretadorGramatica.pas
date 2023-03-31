///////////////////////////////////////////////////////////////
//                                                           //
// Interpretador de gram�tica desenvolvido como atividade    //
// para aula de Linguagens Formais (2023).                   //
//                                                           //
// Autor: Luiz Felipe Botini de Silvestro                    //
//                                                           //
///////////////////////////////////////////////////////////////
unit InterpretadorGramatica;
interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Data.DB, Datasnap.DBClient,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.Grids;
type
  TForm1 = class(TForm)
    Panel1            : TPanel;
    DsPilha           : TDataSource;
    TbPilha           : TClientDataSet;
    btnGerar1         : TBitBtn;
    txt1              : TMemo;
    txtResultado      : TMemo;
    TbPilhagramatica  : TStringField;
    lblResultado      : TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnGerar1Click(Sender: TObject);
    procedure Split(Delimiter: Char; Str: string; ListOfStrings: TStrings);
    function RetornaMinusculo(Texto: string): Boolean;
    function retornaPipes(variavel: String):Integer;
  private
    { Private declarations }
  public
    { Public declarations }
  end;
var
  Form1: TForm1;
const giNumMaxInteracoes : Integer = 100;
implementation
uses
  StrUtils, Math;
{$R *.dfm}
procedure TForm1.Split(Delimiter: Char; Str: string; ListOfStrings: TStrings);
begin
   ListOfStrings.Clear;
   ListOfStrings.Delimiter       := Delimiter;
   ListOfStrings.StrictDelimiter := True;
   ListOfStrings.DelimitedText   := Str;
end;
function TForm1.retornaPipes(variavel: String):Integer;
var
  I : Integer;
  resultado : Integer;
begin
  resultado := 0;
  for I := 1 to Length(variavel) do
  begin
    if Trim(variavel[I]) = '|' then
      Inc(resultado);
  end;
  result := resultado;
end;
procedure TForm1.btnGerar1Click(Sender: TObject);
var
  I                   : Integer;
  liLenghtLinha       : Integer;
  lsGramatica         : String;
  lslGramatica        : TStringList;
  lbContinuar         : Boolean;
  lsItemGramatica_S   : String;
  lslItemGramatica_S  : TStringList;
  liLenghtGramatica_T : Integer;
  lsItemGramatica_T   : String;
  lslItemGramatica_T  : TStringList;
  variavelS           : String;
  variavelT           : String;
  lsStringSaida       : String;
  //liColunaPilha       : Integer;
  liNumMaxInteracoes   : Integer;
  liNumVariaveisS : Integer;
  liNumVariaveisT : Integer;
begin
  txtResultado.Clear;
  //Inicia clientDataSet.
  if TbPilha.Active then
    TbPilha.EmptyDataSet;
  TbPilha.Close;
  TbPilha.CreateDataSet;
  TbPilha.Open;
  lsStringSaida := '';
  lbContinuar := True;
  // Dados gram�tica.
  // Recebe por exemplo: S-> aTb|b;T-> Ta|e.
  liLenghtLinha  := Length(txt1.Lines.Strings[0]);
  lsGramatica    := Copy(txt1.Lines.Strings[0], 5, liLenghtLinha);
  //Cria as Strings List que ser�o usadas.
  lslGramatica        := TStringList.Create;
  lslItemGramatica_T  := TStringList.Create;
  lslItemGramatica_S  := TStringList.Create;
  try
    Split (';', lsGramatica, lslGramatica);
    lsItemGramatica_S   := lslGramatica[0];
    Split('|', lsItemGramatica_S, lslItemGramatica_S);
    liNumVariaveisS := retornaPipes(lsItemGramatica_S);
    // Agora lslItemGramatica_S tem os itens de S (S-> aTb|b).
    liNumVariaveisT := 0;
    if pos(';', lsGramatica) >= 1 then
    begin
      liLenghtGramatica_T := Length(lslGramatica[1]);
      lsItemGramatica_T   := copy(lslGramatica[1], 5, liLenghtGramatica_T);
      Split('|', lsItemGramatica_T, lslItemGramatica_T);
      liNumVariaveisT := retornaPipes(lsItemGramatica_T);
      // Agora lslItemGramatica_T tem os itens de T (T-> Ta|e).
    end;
    // Start
    variavelS := lslItemGramatica_S[Random(liNumVariaveisS+1)];
    for I := 1 to Length(variavelS) do
    begin
      if Trim(variavelS[I]) <> '&' then
      begin
        TbPilha.Append;
        TbPilhagramatica.AsString := variavelS[I];
        TbPilha.Post;
        //StringGridPilha.Cells[0,I-1] := variavelS[I];
      end;
    end;
    //liColunaPilha := 1;
    liNumMaxInteracoes := 0;
    while lbContinuar do
    begin
      Inc(liNumMaxInteracoes);
      if liNumMaxInteracoes = giNumMaxInteracoes then
      begin
        ShowMessage('Estouro na pilha!');
        exit;
      end;
      TbPilha.First;
      while not (TbPilha.Eof) do
      begin
        // Verifica se � um terminal (letra min�scula).
        if RetornaMinusculo(TbPilhagramatica.AsString) then
        begin
          lsStringSaida := lsStringSaida + Trim(TbPilhagramatica.AsString);
          TbPilha.Delete;
          txtResultado.Lines.Add(lsStringSaida);
          //StringGridPilha.Cells[liColunaPilha, 0] := TbPilhagramatica.AsString;
          //Inc(liColunaPilha);
          Application.ProcessMessages;
          Continue;
        end
        else
        begin
          // Procura a senten�a do terminal.
          if Trim(TbPilhagramatica.AsString) = 'S' then
          begin
            TbPilha.Delete;
            variavelS := lslItemGramatica_S[Random(liNumVariaveisS+1)];
            for I := Length(variavelS) downto 1 do
            begin
              if Trim(variavelS[I]) <> '&' then
              begin
                TbPilha.Insert;
                TbPilhagramatica.AsString := variavelS[I];
                TbPilha.Post;
              end;
            end;
            break;
          end
          else if Trim(TbPilhagramatica.AsString) = 'T' then
          begin
            TbPilha.Delete;
            variavelT := lslItemGramatica_T[Random(liNumVariaveisT+1)];
            for I := Length(variavelT) downto 1 do
            begin
              if Trim(variavelT[I]) <> '&' then
              begin
                TbPilha.Insert;
                TbPilhagramatica.AsString := variavelT[I];
                TbPilha.Post;
              end;
            end;
            break;
          end;
        end;
        TbPilha.Next;
      end;
      if TbPilha.IsEmpty then
        lbContinuar := False;
      Next;
    end;
  finally
    //Free nas Strings Lists.
    lslGramatica.Free;
    lslItemGramatica_S.Free;
    lslItemGramatica_T.Free;
  end;
end;
function TForm1.RetornaMinusculo(Texto: string): Boolean;
var
  I        : Integer;
  lbExiste : Boolean;
begin
  lbExiste := False;
  For I := 1 to length( Texto ) do
  begin
    If Texto[I] in ['a'..'z'] then
    begin
      lbExiste := True;
      Break;
    end;
  end;
  Result := lbExiste;
end;
procedure TForm1.FormCreate(Sender: TObject);
begin
  txt1.Clear;
  //txt1.Lines.Add('S-> aTb|b;T-> Ta|e');
  txt1.Lines.Add('S-> aSb|ab');
end;
end.

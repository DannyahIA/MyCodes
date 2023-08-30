interface

uses
  Classes,
  SysUtils,
  Forms,
  Dialogs,
  DBGrids,
  StdCtrls,
  ExtCtrls,
  DB,
  BufDataset,
  Jsons,
  JsonsUtilsEx;

type

  { TForm1 }

  TForm1 = class(TForm)
    BufDataset: TBufDataset;
    Button1: TButton;
    DataSource: TDataSource;
    DBGrid: TDBGrid;
    OpenDialog: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    procedure Button1Click(Sender: TObject);
  private
    procedure CreateDataset(JsonString: string);
    function ConvertValue(Valor: string): double;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
     CreateDataset(ReadFile);
end; 

procedure TForm1.CreateDataset(JsonString: string);
var
  Json: TJson;
  i: integer;
  pedidosArray: TJsonArray;
  pedido: TJsonObject;
begin
  if (Trim(JsonString) = '') then
  begin
    Exit;
  end;

  BufDataset.FieldDefs.Add('Numero', ftString, 15, False);
  BufDataset.FieldDefs.Add('Valor', ftCurrency, 15, False);
  BufDataset.FieldDefs.Add('Data', ftString, 15, False);
  BufDataset.FieldDefs.Add('Valor_Pago', ftCurrency, 15, False);
  BufDataset.FieldDefs.Add('Data_Pagamento', ftString, 15, False);
  BufDataset.FieldDefs.Add('Data_Credito', ftString, 15, False);
  BufDataset.FieldDefs.Add('Linha_Digitavel', ftString, 15, False);
  BufDataset.FieldDefs.Add('Status', ftString, 15, False);
  BufDataset.FieldDefs.Add('Erro', ftString, 15, False);
  BufDataset.CreateDataset;

  TNumericField(BufDataset.FieldByName('Valor_Pago')).DisplayFormat := '###,###,##0.00';
  TNumericField(BufDataset.FieldByName('Valor')).DisplayFormat := '###,###,##0.00';

  // ----------------------------------------------------------------------------//

  Json := TJson.Create();

  try
    Json.Parse(JsonString);

    if Json.JsonObject.Values['pedidos'] <> nil then
    begin
      pedidosArray := Json.JsonObject.Values['pedidos'].AsArray;

      for i := 0 to pedidosArray.Count - 1 do
      begin
        pedido := pedidosArray[i].AsObject;

        // Acesso aos campos do pedido usando os métodos da classe TJsonValue
        BufDataset.AppendRecord(
          [pedido.Values['numero'].AsString,
          ConvertValue(pedido.Values['valor'].AsString),
          pedido.Values['data'].AsString,
          ConvertValue(pedido.Values['valorPago'].AsString),
          pedido.Values['dataPagamento'].AsString,
          pedido.Values['dataCredito'].AsString,
          pedido.Values['linhaDigitavel'].AsString,
          pedido.Values['status'].AsString,
          pedido.Values['erro'].AsString]);
      end;

      DataSource.DataSet := BufDataset;
      BufDataset.First;
    end
    else
      ShowMessage('O Json não contém o campo "pedidos".');
  finally
    Json.Free;
  end;

end;

function TForm1.ConvertValue(Valor: string): double;
var
  ParteInteira: string;
  ParteDecimal: string;
  Tamanho: integer;
begin
  Valor := trim(Valor);
  Tamanho := Length(Valor);

  ParteDecimal := Copy(Valor, Tamanho - 1, 2);
  ParteInteira := Copy(Valor, 1, Tamanho - 2);

  Valor := (ParteInteira + ',' + ParteDecimal);

  Result := StrToFloat(Valor);

end;

end. 

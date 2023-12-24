unit CryptUtils;

interface

uses SysUtils;

type
  TAction = (taEncrypt, taDecrypt);

type
  TAlgorithm = (tgStandard);

type
  TCrypt = class
  protected
    function GetCurrentTimestamp: string;
  private
    FAction: TAction;
    FKey: string;
    FText: string;
    FNKey: ShortInt;
    function Encrypt: string;

  public
    class function Execute(AAction: TAction; AText: string; const AKey: string): string; overload;
    class function Execute(AAction: TAction; AText: string; const ANKey: ShortInt = 1): string; overload;
  end;

implementation

{ TCrypt }

function TCrypt.Encrypt: string;
var
  KeyLen: Integer;
  KeyPos: Integer;
  Offset: Integer;
  Dest, Key: string;
  SrcPos: Integer;
  SrcAsc: Integer;
  TmpSrcAsc: Integer;
  Range: Integer;
begin
  if (FText = '') then
  begin
    Result := '';
    Exit;
  end;

  if FKey = '' then
  begin
    case FNKey of
      1: Key :=
        'YUQL23KL23DF90WI5E1JAS467NMCXXL6JAOAUWWMCL0AOMM4A4VZYW9KHJUI2347EJHJKDF3424SKL K3LAKDJSL9RTIKJ';
      2: Key :=
        'KJEWRFGAEWRF98735NFVBASIFG826Q54BKQRWEFB ERGQJEHBTWQETNWERKJTHQKWEJ5H2398YBRFG ERJGEWQRTKWQETR';
      3: Key :=
        'O235TQ231T1235T612TY624T246Y1243Y212Q46Y5Q35T1QER65T4Q4Y6244YQ23514GQ356YQ23536TQ356   WE5ER1D412IKHJEHERFQWF4';
      4: Key :=
        'FE1B3FDE74F40D1F2B4D5EE478A1DBF20E66FD2FCB4CDD175593FD090D07010A65FD7ED152F56DDA68EE0D7EDF7C8681E143B254D8A107';
    end;
  end
  else
    Key := FKey;

  Dest := '';
  KeyLen := Length(Key);
  KeyPos := 0;
  Range := 256;
  if FAction = taEncrypt then
  begin
    FText := GetCurrentTimestamp + FText;
    Randomize;
    Offset := Random(Range);
    Dest := Format('%1.2x', [Offset]);
    for SrcPos := 1 to Length(FText) do
    begin
      SrcAsc := (Ord(FText[SrcPos]) + Offset) mod 255;
      if KeyPos < KeyLen then
        KeyPos := KeyPos + 1
      else
        KeyPos := 1;
      SrcAsc := SrcAsc xor Ord(Key[KeyPos]);
      Dest := Dest + Format('%1.2x', [SrcAsc]);
      Offset := SrcAsc;
    end;
  end
  else
  begin
    Offset := StrToInt('$' + Copy(FText, 1, 2));
    SrcPos := 3;
    repeat
      SrcAsc := StrToInt('$' + Copy(FText, SrcPos, 2));
      if (KeyPos < KeyLen) then
        KeyPos := KeyPos + 1
      else
        KeyPos := 1;
      TmpSrcAsc := SrcAsc xor Ord(Key[KeyPos]);
      if TmpSrcAsc <= Offset then
        TmpSrcAsc := 255 + TmpSrcAsc - Offset
      else
        TmpSrcAsc := TmpSrcAsc - Offset;
      Dest := Dest + Chr(TmpSrcAsc);
      Offset := SrcAsc;
      SrcPos := SrcPos + 2;
    until (SrcPos >= Length(FText));
    Dest := Copy(Dest, 18, MaxInt)
  end;

  Result := Dest;
end;

class function TCrypt.Execute(AAction: TAction; AText: string;
  const AKey: string): string;
var
  cr: TCrypt;
begin
  cr := TCrypt.Create;
  try
    cr.FText := string(AText);
    cr.FKey := string(AKey);
    cr.FAction := AAction;
    try
      Result := cr.Encrypt;
    except
      Result := '';
    end;
  finally
    FreeAndNil(cr);
  end;
end;

class function TCrypt.Execute(AAction: TAction; AText: string;
  const ANKey: ShortInt): string;
var
  cr: TCrypt;
begin
  cr := TCrypt.Create;
  try
    cr.FText := AText;
    cr.FNKey := ANKey;
    cr.FAction := AAction;
    try
      Result := cr.Encrypt;
    except
      Result := '';
    end;
  finally
    FreeAndNil(cr);
  end;
end;

function TCrypt.GetCurrentTimestamp: string;
begin
  Result := FormatDateTime('YYYYMMDDHHNNSSZZZ', Now);
end;

end.


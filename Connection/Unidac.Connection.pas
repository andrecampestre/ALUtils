unit Unidac.Connection;

interface

uses
  System.SysUtils, System.Classes, UniProvider, PostgreSQLUniProvider,
  Uni, SQLiteUniProvider, SQLServerUniProvider, OracleUniProvider,
  MySQLUniProvider;

type
  IUnidacConnection = interface
    ['{53145538-BD04-4E19-A825-77ADEB5BD4C3}']
    function GetUniConnection: TUniConnection;
    property This: TUniConnection read GetUniConnection;
  end;

  TUnidacConnection = class(TInterfacedObject, IUnidacConnection)
  private
    { Private declarations }
    UniConnection: TUniConnection;
    MySQLUniProvider: TMySQLUniProvider;
    OracleUniProvider: TOracleUniProvider;
    PostgreSQLUniProvider: TPostgreSQLUniProvider;
    SQLServerUniProvider: TSQLServerUniProvider;
    SQLiteUniProvider: TSQLiteUniProvider;
    function GetUniConnection: TUniConnection;
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;
    class function New: IUnidacConnection; overload;
    class function New(Driver, Server, Database, Username, Password, Port: string): IUnidacConnection; overload;
    property This: TUniConnection read GetUniConnection;
  end;

implementation
{$IFDEF MSWINDOWS}
uses
  ActiveX
  ;
{$ENDIF}

const
  ENVPG =
  '''
      Provider Name=PostgreSQL;Data Source=192.168.31.216;
      Database=service_manager;User ID=sysdba;Password=Jera@sofT2;
      Login Prompt=False
  ''';

  ENVMSSQL =
  '''
      Provider Name=SQL Server;Data Source=192.168.31.216;
      Initial Catalog=service_manager;User ID=sysdba;Password=Jera@sofT2;
      Login Prompt=False
  ''';

{ TUnidacConnection }

constructor TUnidacConnection.Create;
begin
  UniConnection := TUniConnection.Create(nil);

  // Create Driver for  Multiple Databases
  MySQLUniProvider := TMySQLUniProvider.Create(nil);
  OracleUniProvider := TOracleUniProvider.Create(nil);
  PostgreSQLUniProvider := TPostgreSQLUniProvider.Create(nil);
  SQLServerUniProvider := TSQLServerUniProvider.Create(nil);
  SQLiteUniProvider := TSQLiteUniProvider.Create(nil);
end;

destructor TUnidacConnection.Destroy;
begin
  UniConnection.Connected := False;
  FreeAndNil(UniConnection);
  MySQLUniProvider.Free;
  OracleUniProvider.Free;
  PostgreSQLUniProvider.Free;
  SQLServerUniProvider.Free;
  SQLiteUniProvider.Free;
  inherited;
end;

function TUnidacConnection.GetUniConnection: TUniConnection;
begin
  Result := UniConnection;
end;

class function TUnidacConnection.New: IUnidacConnection;
begin
  Result := Self.Create;
  Result.This.ConnectString := ENVMSSQL;
  Result.This.ProviderName := 'SQL Server';
  Result.This.Connected := True;
end;

class function TUnidacConnection.New(Driver, Server, Database, Username,
  Password, Port: string): IUnidacConnection;
begin
  Result := Self.Create;
  Result.This.ProviderName := Driver;
  Result.This.Server := Server;
  Result.This.Database := Database;
  Result.This.Username := Username;
  Result.This.Password := Password;
  Result.This.Port := StrToInt(Port);
  Result.This.AutoCommit := False;
  Result.This.Pooling := True;
  Result.This.Connected := True;
end;

initialization

{$IFDEF MSWINDOWS}
  CoInitializeEx(nil, COINIT_MULTITHREADED);
{$ENDIF}


end.

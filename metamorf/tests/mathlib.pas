// ===========================================================================
//  mathlib.pas -- Simple unit to test multi-file compilation
//
//  Exercises: unit declaration, interface/implementation sections,
//  exported functions, initialization/finalization sections.
//
//  NOTE: Uses // and (* *) comments only -- no { } block comments.
//  Compile: Metamorf -l ObjectPascal.mor -s tests/mathlib.pas
// ===========================================================================

unit MathLib;

interface

uses
  SysUtils;

const
  E = 2.71828182;

type
  TOperation = (opAdd, opSubtract, opMultiply, opDivide);

function Add(A, B: Double): Double;
function Subtract(A, B: Double): Double;
function Multiply(A, B: Double): Double;
function Divide(A, B: Double): Double;
function Calculate(Op: TOperation; A, B: Double): Double;
function Clamp(Value, MinVal, MaxVal: Double): Double;
function IsBetween(Value, Low, High: Double): Boolean;

implementation

function Add(A, B: Double): Double;
begin
  Result := A + B;
end;

function Subtract(A, B: Double): Double;
begin
  Result := A - B;
end;

function Multiply(A, B: Double): Double;
begin
  Result := A * B;
end;

function Divide(A, B: Double): Double;
begin
  if B = 0.0 then
    raise Exception.Create('Division by zero');
  Result := A / B;
end;

function Calculate(Op: TOperation; A, B: Double): Double;
begin
  case Op of
    opAdd:      Result := Add(A, B);
    opSubtract: Result := Subtract(A, B);
    opMultiply: Result := Multiply(A, B);
    opDivide:   Result := Divide(A, B);
  else
    Result := 0.0;
  end;
end;

function Clamp(Value, MinVal, MaxVal: Double): Double;
begin
  if Value < MinVal then
    Result := MinVal
  else if Value > MaxVal then
    Result := MaxVal
  else
    Result := Value;
end;

function IsBetween(Value, Low, High: Double): Boolean;
begin
  Result := (Value >= Low) and (Value <= High);
end;

initialization
  WriteLn('MathLib initialized');

finalization
  WriteLn('MathLib finalized');

end.

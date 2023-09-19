unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,jpeg;

type
  TForm1 = class(TForm)
    Image1: TImage;
    Memo1: TMemo;
    Button1: TButton;
    OpenDialog1: TOpenDialog;
    procedure Button1Click(Sender: TObject);
    procedure DoClickImage(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;
  ptnb : integer = 0  ;
  point1, point2: tpoint;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  with OpenDialog1 do
    try
      Caption := 'Open Image';
      Options := [ofPathMustExist, ofFileMustExist];
      if Execute then
        Image1.Picture.LoadFromFile(FileName);
    finally

    end;
end;

procedure DoDrawLine;
begin
  //Form1.Memo1.Lines.Add('Draw line !');
  with Form1.Image1.Canvas do
  begin
    Pen.Width := 3;
    Pen.Color :=  clRed;
    MoveTo(point1.X,point1.Y);
    LineTo(point2.X,point2.Y);
  end;

end;


procedure TForm1.DoClickImage(Sender: TObject);
var
  pt : tPoint;
  x1, y1, x2, y2 : integer;
begin
  pt := Mouse.CursorPos;
  //memo1.Lines.Add(IntToStr(Image1.Width));
  //memo1.Lines.Add(IntToStr(Image1.Height));
  // now have SCREEN position
  //memo1.Lines.Add('X = '+IntToStr(pt.x)+', Y = '+IntToStr(pt.y));
  pt := Image1.ScreenToClient(pt);
  // now have Image position
  //memo1.Lines.Add('X = '+IntToStr(pt.x)+', Y = '+IntToStr(pt.y));
  inc(ptnb);
  if ptnb = 1 then  point1 :=  pt
  else
  if ptnb = 2 then
  begin
    point2 := pt;
    x1 := point1.X * 560 div Image1.Width;
    y1 := point1.Y * 192 div Image1.Height;
    x2 := point2.X * 560 div Image1.Width;
    y2 := point2.Y * 192 div Image1.Height;
    DoDrawLine;
    memo1.Lines.Add('dw '+ IntToStr(x1)+','+ IntToStr(y1)+','+ IntToStr(x2)+','+IntToStr(y2));
    ptnb := 0;
  end;
end;

end.

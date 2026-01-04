{$A-,B-,E-,F-,G+,I-,K-,N-,O-,P-,Q-,R-,S-,T+,V-,W-,X+}
{$M 20480,32768}

program Truco;

{$C MOVEABLE DEMANDLOAD DISCARDABLE}
{$R TRUCO.RES}
{$D Truco para Windows V2.5 - Por Mauro Leggieri}

uses WinTypes, WinProcs, Strings, Objects, BWCC, OWindows,
     ODialogs, WinDos, MMSystem, TRAbout, LZExpand;

{{$S 65535}
{{$G Strings, Objects, OWindows, ODialogs}

const
  TrucoVersion = '2.5';
  id_About = 100;
  cm_About = 105;
  cm_Nuevo = 101;
  cm_Sonido = 102;
  cm_Salir = 200;
  cm_Load = 103;
  cm_Save = 104;
  cm_ModiSound = 106;
  ca30p : boolean = True;
  csonid : boolean = True;
  cflor : boolean = True;
  cniv : boolean = True;
  id_Push1 = 601;  id_Push2 = 602;  id_Push3 = 603;
  id_Push4 = 604;  id_Push5 = 605;  id_Push6 = 606;
  id_Push7 = 607;  id_Push8 = 608;  id_Push9 = 609;
  id_Push10 = 610;  id_Push11 = 611;  id_Push12 = 612;
  id_Push13 = 613;  id_Push14 = 614;
  cm_Action = 700;

type
  PBitButton = ^TBitButton;
  TBitButton = object(TButton)
    procedure Disable;
    procedure Enable;
    function GetEnableState : boolean;
    function GetClassName : pchar; virtual;
  end;

  PTrucoWindow = ^TTrucoWindow;
  TTrucoWindow = Object(TWindow)
    TWIcon : HIcon;
    TWBrush : HBrush;
    progdir,songdir : array[0..100] of char;
    SonChecked,SonUnchecked : HBitMap;
    HumanoName : string;
    MaxP,Humcanto,Extra, extr4, extr5, EnJuego, ManoJug : byte;
    PuntosA,PuntosB : integer;
    SPlashTM : byte;
    TrucoSound : boolean;
    Env,Realenv,faltaenv,truco,retruco,vale4,
    flor,mazo,carta1,carta2,carta3,quiero,noquiero : PBitButton;
    tabl : array[1..3,1..4] of integer;
    cart : array[1..3,1..2] of integer;
    mano : byte;
    juegajug : byte;
    envcant1,envcant2,florcant,enque,trucocant1,trucocant2,trucocant3 : byte;
    mientenv1,mientenv2,mientenv3,mientenv4,genvi,gtruc,mimens1,mimens2,mimens3,
    truflag1,mientruc1,mientruc2 : integer;
    muesflag1 : byte;
    cmens : array[0..250] of char;
    constructor Init(AParent: PWindowsObject; AName: PChar);
    destructor Done; virtual;
    function PlaySound(so : pchar; fl : byte) : byte;
    function CanClose: Boolean; virtual;
    procedure GetWindowClass(var WndClass: TWndClass); virtual;
    procedure SetupWindow; virtual;
    procedure CompuMessage(me : pchar);
    procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;
    function GetValor(c1 : integer) : integer;
    function GanoMano(c1,c2 : integer) : integer;
    procedure WMLButtonDown(var Message: TMessage); virtual wm_LButtonDown;
    procedure PlayCompuVoice(m1,m2 : integer);
    procedure WMSysCommand(var Msg: TMessage);
      virtual wm_First + wm_SysCommand;
    procedure WMTimer(var Msg: TMessage);
      virtual wm_Timer + wm_First;
    procedure CMNuevo(var Msg: Tmessage);
      virtual cm_First + cm_Nuevo;
    procedure CMLoadGame(var Msg: Tmessage);
      virtual cm_First + cm_Load;
    procedure CMSaveGame(var Msg: Tmessage);
      virtual cm_First + cm_Save;
    procedure CMSonido(var Msg: Tmessage);
      virtual cm_First + cm_Sonido;
    procedure CMModiSonido(var Msg: Tmessage);
      virtual cm_First + cm_ModiSound;
    procedure CMAbout(var Msg: Tmessage);
      virtual cm_First + cm_About;
    procedure CMSalir(var Msg: Tmessage);
      virtual cm_First + cm_Salir;
    procedure IDEnvido(var Msg: TMessage);
      virtual id_First + id_Push1;
    procedure IDRealEnvido(var Msg: TMessage);
      virtual id_First + id_Push2;
    procedure IDFaltaEnvido(var Msg: TMessage);
      virtual id_First + id_Push3;
    procedure IDTruco(var Msg: TMessage);
      virtual id_First + id_Push10;
    procedure IDRetruco(var Msg: TMessage);
      virtual id_First + id_Push11;
    procedure IDVale4(var Msg: TMessage);
      virtual id_First + id_Push12;
    procedure IDFlor(var Msg: TMessage);
      virtual id_First + id_Push4;
    procedure IDMazo(var Msg: TMessage);
      virtual id_First + id_Push6;
    procedure IDCarta1(var Msg: TMessage);
      virtual id_First + id_Push7;
    procedure IDCarta2(var Msg: TMessage);
      virtual id_First + id_Push8;
    procedure IDCarta3(var Msg: TMessage);
      virtual id_First + id_Push9;
    procedure IDQuiero(var Msg: TMessage);
      virtual id_First + id_Push13;
    procedure IDNoQuiero(var Msg: TMessage);
      virtual id_First + id_Push14;
    procedure Acciones;
      virtual cm_First + cm_Action;
  end;

  PSplashWindow = ^TSplashWindow;
  TSplashWindow = object(Twindow)
    constructor Init;
    procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;
    destructor Done; virtual;
  end;

  PTrucoApp = ^TTrucoApp;
  TTrucoApp = Object(TApplication)
    procedure InitMainWindow; virtual;
    procedure Error(ErrorCode : integer); virtual;
    destructor Done; virtual;
  end;

  POptionDialog = ^TOptionDialog;
  TOptionDialog = object(TDialog)
    procedure OK(var Message: TMessage); virtual id_First + id_Ok;
    procedure SetupWindow; virtual;
  end;

  PModisoundDialog = ^TModisoundDialog;
  TModisoundDialog = object(TDialog)
    cantos : plistbox;
    sonid : plistbox;
    explic : pstatic;
    constructor Init(AParent : PWindowsObject; AName : pchar);
    destructor Done; virtual;
    procedure UpdateSonLista;
    procedure OK(var Message: TMessage); virtual id_First + id_Ok;
    procedure SetupWindow; virtual;
    procedure StartupSound(var Msg: Tmessage);
      virtual id_First + 101;
    procedure ListSel(var Msg: Tmessage);
      virtual id_First + 110;
    procedure Agregar(var Msg: Tmessage);
      virtual id_First + 120;
    procedure Borrar(var Msg: Tmessage);
      virtual id_First + 121;
    procedure Escuchar(var Msg: Tmessage);
      virtual id_First + 122;
  end;

  PCompuflorDialog = ^TCompuflorDialog;
  TCompuflorDialog = object(TDialog)
    procedure OK(var Message: TMessage); virtual id_First + id_Ok;
    procedure SetupWindow; virtual;
  end;

  PTantoDialog = ^TTantoDialog;
  TTantoDialog = object(TDialog)
    procedure OK(var Message: TMessage); virtual id_First + id_Ok;
    procedure SetupWindow; virtual;
  end;

  PSelHumanoDialog = ^TSelHumanoDialog;
  TSelHumanoDialog = object(TDialog)
  {
    ListB : pcombobox;
    constructor Init(AParent : PWindowsObject);
    destructor Done; virtual;
    }
    procedure SetupWindow; virtual;
    procedure OK(var Message: TMessage); virtual id_first + id_ok;
  end;

const
  TrucoTitle: PChar = 'TRUCO para Windows V'+TrucoVersion;
  SpecialMessage = 'Si Usted está viendo este mensaje significa que es un '+
                   'CHUSMA, por lo tanto dedíquese a hacer otra cosa. GRACIAS!!';

var App: TTrucoApp;
    TempBuf1, TempBuf2 : array[0..200] of char;
    SPWin : pwindowsobject;

function upstrcase(s : string) : string;
var s1 : string; s2 : integer;
begin
  s1:=''; if length(s)>0 then for s2:=1 to length(s) do s1:=s1+upcase(s[s2]);
  upstrcase:=s1;
end;

function getpar(s : string) : string;
var s1 : string; s2 : integer;
begin
  s1:=''; s2:=pos('=',s);
  if s2>0 then s1:=copy(s,s2+1,length(s));
  getpar:=s1;
end;

procedure TBitButton.Disable;
begin
  if HWindow<>0 then EnableWindow(HWindow, False);
end;

procedure TBitButton.Enable;
begin
  if HWindow<>0 then EnableWindow(HWindow, True);
end;

function TBitButton.GetClassName: PChar;
begin
  GetClassName := 'Button';
end;

function TBitButton.GetEnableState : boolean;
begin
  GetEnableState:=IsWindowEnabled(Hwindow);
end;

constructor TModiSoundDialog.Init(AParent : PWindowsObject; AName : pchar);
var f1,f2 : text;
    s1,s2 : string;
begin
  inherited Init(AParent,AName);
  s2:=strpas(PTrucoWindow(Parent)^.progdir);
  New(cantos,InitResource(@Self, 110));
  New(sonid,InitResource(@Self, 111));
  New(explic,InitResource(@Self, 105, 60));
  assign(f1, s2+'TRUCO.INI');
  assign(f2, s2+'TEMP.INI');
  reset(f1);
  rewrite(f2);
  repeat
    readln(f1, s1);
    writeln(f2, s1);
  until eof(f1);
  close(f1);
  close(f2);
end;

destructor TModiSoundDialog.Done;
var f1 : file;
    s2 : string;
begin
  dispose(explic, done);
  dispose(cantos, done);
  dispose(sonid, done);
  s2:=strpas(PTrucoWindow(Parent)^.progdir);
  inherited Done;
  assign(f1, s2+'TEMP.INI');
  erase(f1);
end;

procedure TModiSoundDialog.UpdateSonLista;
const nomblock : array[0..39] of string[20] = (
    'ENVIDO','REALENV','FALTAENV','TRUCO','RETRUCO','VALE4',
    'QUIERO','NOQUIERO','GANATANTO','PERDITANTO','FLOR',
    'FLORPORATREV','CONTRAFLOR','FLORACHICO','COMPUGANA',
    'TANTO0','TANTO1','TANTO2','TANTO3','TANTO4','TANTO5',
    'TANTO6','TANTO7','TANTO20','TANTO21','TANTO22','TANTO23',
    'TANTO24','TANTO25','TANTO26','TANTO27','TANTO28','TANTO29',
    'TANTO30','TANTO31','TANTO32','TANTO33','EXPRESION1','EXPRESION2',
    'EXPRESION3');
var Idx,xx : integer;
    f1 : text;
    s1,s2,s3 : string;
    s4,s5 : array[0..100] of char;
begin
  Idx:=cantos^.GetSelIndex;
  strcopy(s4,'Cuando la computadora ');
  if (idx<6) or ((idx>9) and (idx<37) and (idx<>14))
    then strcat(s4,'canta ');
  case idx of
    0 : strcat(s4,'envido');
    1 : strcat(s4,'real envido');
    2 : strcat(s4,'falta envido');
    3 : strcat(s4,'truco');
    4 : strcat(s4,'quiero retruco');
    5 : strcat(s4,'quiero vale 4');
    6 : strcat(s4,'dice quiero');
    7 : strcat(s4,'dice no quiero');
    8 : strcat(s4,'gana el tanto');
    9 : strcat(s4,'pierde el tanto');
    10 : strcat(s4,'flor');
    11 : strcat(s4,'flor por atrevido');
    12 : strcat(s4,'contraflor');
    13 : strcat(s4,'con flor me achico');
    14 : strcat(s4,'gana el partido');
    15..36 : begin
         strpcopy(s5, copy(nomblock[idx], 6, 2));
         strcat(s4, s5);
         strcat(s4, ' en el tanto');
         end;
    37 : strcat(s4, 'pierde el partido');
    38 : strcat(s4, 'juega su última carta');
    39 : strcat(s4, 'dice "Hasta aquí llegó el olor"');
  end;
  strcat(s4,'.');
  explic^.settext(s4);
  sonid^.clearlist;
  s2:=strpas(PTrucoWindow(Parent)^.progdir);
  assign(f1, s2+'TEMP.INI');
  reset(f1);
  xx:=0;
  while not eof(f1) do begin
    readln(f1, s2);
    s2:=upstrcase(s2);
    if s2='[OPCIONES]' then xx:=1; { Nro de bloque 1 }
    if xx=1 then begin
      if copy(s2,1,length(nomblock[idx])+1)=nomblock[idx]+'=' then begin
        s3:=getpar(s2);
        strpcopy(s4, s3);
        sonid^.addstring(s4);
      end;
    end;
  end;
  close(f1);
  sonid^.setselindex(0);
end;

procedure TModisoundDialog.SetupWindow;
begin
  inherited SetupWindow;
  explic^.settext('');
  CheckDlgButton(Hwindow, 101,1);
  cantos^.addstring('Envido');
  cantos^.addstring('Real Envido');
  cantos^.addstring('Falta Envido');
  cantos^.addstring('Truco');
  cantos^.addstring('Retruco');
  cantos^.addstring('Quiero vale 4');
  cantos^.addstring('Quiero');
  cantos^.addstring('No Quiero');
  cantos^.addstring('Gana el tanto');
  cantos^.addstring('Pierde tanto');
  cantos^.addstring('Flor');
  cantos^.addstring('Flor p/ atrevido');
  cantos^.addstring('Contraflor');
  cantos^.addstring('Con flor me achico');
  cantos^.addstring('Gana el juego');
  cantos^.addstring('0 para el tanto');
  cantos^.addstring('1 para el tanto');
  cantos^.addstring('2 para el tanto');
  cantos^.addstring('3 para el tanto');
  cantos^.addstring('4 para el tanto');
  cantos^.addstring('5 para el tanto');
  cantos^.addstring('6 para el tanto');
  cantos^.addstring('7 para el tanto');
  cantos^.addstring('20 para el tanto');
  cantos^.addstring('21 para el tanto');
  cantos^.addstring('22 para el tanto');
  cantos^.addstring('23 para el tanto');
  cantos^.addstring('24 para el tanto');
  cantos^.addstring('25 para el tanto');
  cantos^.addstring('26 para el tanto');
  cantos^.addstring('27 para el tanto');
  cantos^.addstring('28 para el tanto');
  cantos^.addstring('29 para el tanto');
  cantos^.addstring('30 para el tanto');
  cantos^.addstring('31 para el tanto');
  cantos^.addstring('32 para el tanto');
  cantos^.addstring('33 para el tanto');
  cantos^.addstring('Perdí el juego');
  cantos^.addstring('Ultima carta mata');
  cantos^.addstring('¡Que olor!');
  cantos^.SetSelIndex(0);
  updatesonlista;
end;

procedure TModisoundDialog.OK(var Message: TMessage);
var f1,f2 : text;
    s1,s2 : string;
begin
  s2:=strpas(PTrucoWindow(Parent)^.progdir);
  assign(f1, s2+'TEMP.INI');
  assign(f2, s2+'TRUCO.INI');
  reset(f1);
  rewrite(f2);
  repeat
    readln(f1, s1);
    writeln(f2, s1);
  until eof(f1);
  close(f1);
  close(f2);
  inherited OK(Message);
end;

procedure TModiSoundDialog.ListSel(var Msg: TMessage);
begin
  if Msg.LParamHi = lbn_SelChange then updatesonlista
    else DefWndProc(Msg);
end;

procedure TModiSoundDialog.Startupsound;
var s,s1,s2 : string;
    f1,f2 : text;
    xx : integer;
begin
  if isdlgbuttonchecked(HWindow, 101)>0 then s:='Sonido=SI'
    else s:='Sonido=NO';
  s2:=strpas(PTrucoWindow(Parent)^.progdir);
  assign(f1, s2+'TEMP.INI');
  assign(f2, s2+'TEMP.XXX');
  reset(f1);
  rewrite(f2);
  xx:=0;
  repeat
    readln(f1, s2);
    s1:=upstrcase(s2);
    if s1='[OPCIONES]' then xx:=1; { Nro de bloque 1 }
    if s1='[SONIDOS]' then xx:=2; { Nro de bloque 2 }
    if xx=1 then begin
      if copy(s1,1,6)='SONIDO' then writeln(f2, s)
        else writeln(f2, s2);
    end;
    if xx=2 then writeln(f2, s2);
  until eof(f1);
  close(f1);
  close(f2);
  erase(f1);
  rename(f2, 'TEMP.INI');
end;

procedure TModiSoundDialog.Agregar;
const nomblock : array[0..39] of string[20] = (
    'ENVIDO','REALENV','FALTAENV','TRUCO','RETRUCO','VALE4',
    'QUIERO','NOQUIERO','GANATANTO','PERDITANTO','FLOR',
    'FLORPORATREV','CONTRAFLOR','FLORACHICO','COMPUGANA',
    'TANTO0','TANTO1','TANTO2','TANTO3','TANTO4','TANTO5',
    'TANTO6','TANTO7','TANTO20','TANTO21','TANTO22','TANTO23',
    'TANTO24','TANTO25','TANTO26','TANTO27','TANTO28','TANTO29',
    'TANTO30','TANTO31','TANTO32','TANTO33','EXPRESION1','EXPRESION2',
    'EXPRESION3');
var fn : array[0..80] of char;
    s1, s2, s3, s4 : string;
    f1, f2 : text;
    reopenbuf1,reopenbuf2 : tofstruct;
    sfl,tfl : array[0..70] of char;
    xx2,xx3,shd,thd,idx : integer;
    xx : longint;
    dir,name,ext : array[0..40] of char;
begin
  if sonid^.getcount<60 then begin
    idx:=cantos^.getselindex;
    StrCopy(FN, '*.wav');
    if FileSoundDialog(FN) then begin
      s1:=upstrcase(strpas(FN));
      s2:=upstrcase(strpas(PTrucoWindow(Parent)^.songdir));
      xx2:=0;
      strpcopy(sfl, s1);
      strpcopy(tfl, s2);
      filesplit(sfl, dir,name,ext);
      if copy(s1, 1, length(s2))<>s2 then begin
        strcat(tfl,name);
        strcat(tfl,ext);
        shd:=lzopenfile(sfl,reopenbuf1,of_read);
        thd:=lzopenfile(tfl,reopenbuf2,of_create or of_write);
        if thd=-1 then lzclose(shd)
        else begin
          xx:=lzcopy(shd,thd);
          lzclose(shd);
          lzclose(thd);
          if xx>=0 then xx2:=1;
        end;
      end else xx2:=1;
      if xx2=1 then begin
        s3:=strpas(PTrucoWindow(Parent)^.progdir);
        strpcopy(sfl, s3+'TEMP.INI');
        strpcopy(tfl, s3+'TEMP.XXX');
        shd:=lzopenfile(sfl,reopenbuf1,of_read);
        thd:=lzopenfile(tfl,reopenbuf2,of_create or of_write);
        xx:=lzcopy(shd,thd);
        lzclose(shd);
        lzclose(thd);
        s3:=strpas(PTrucoWindow(Parent)^.progdir);
        assign(f1, s3+'TEMP.XXX');
        assign(f2, s3+'TEMP.INI');
        reset(f1);
        rewrite(f2);
        xx2:=0;
        xx3:=0;
        repeat
          readln(f1, s3);
          s4:=upstrcase(s3);
          if s4='[OPCIONES]' then xx2:=1; { Nro de bloque 1 }
          if s4='[SONIDOS]' then xx2:=2; { Nro de bloque 2 }
          if xx2=1 then writeln(f2, s3);
          if xx2=2 then begin
            if (copy(s4,1,length(nomblock[idx])+1)=nomblock[idx]+'=')
             and (xx3=0) then begin
              xx3:=1;
              s2:=upstrcase(strpas(name)+strpas(ext));
              writeln(f2, nomblock[idx]+'='+s2);
            end;
            writeln(f2, s3);
          end;
        until eof(f1);
        if xx3=0 then begin
          s2:=upstrcase(strpas(name)+strpas(ext));
          writeln(f2, nomblock[idx]+'='+s2);
        end;
        close(f1);
        close(f2);
        s3:=strpas(PTrucoWindow(Parent)^.progdir);
        assign(f1, s3+'TEMP.XXX');
        erase(f1);
        updatesonlista;
      end;
    end;
  end;
end;

procedure TModiSoundDialog.Borrar;
const nomblock : array[0..39] of string[20] = (
    'ENVIDO','REALENV','FALTAENV','TRUCO','RETRUCO','VALE4',
    'QUIERO','NOQUIERO','GANATANTO','PERDITANTO','FLOR',
    'FLORPORATREV','CONTRAFLOR','FLORACHICO','COMPUGANA',
    'TANTO0','TANTO1','TANTO2','TANTO3','TANTO4','TANTO5',
    'TANTO6','TANTO7','TANTO20','TANTO21','TANTO22','TANTO23',
    'TANTO24','TANTO25','TANTO26','TANTO27','TANTO28','TANTO29',
    'TANTO30','TANTO31','TANTO32','TANTO33','EXPRESION1','EXPRESION2',
    'EXPRESION3');
var res : integer;
    s1,s2 : array[0..100] of char;
    s,s3,s4,s5,s6 : string;
    f1,f2 : text;
    xx,idx1,idx2 : integer;
begin
  if sonid^.getcount>0 then begin
    strcopy(s1, '¿Desea eliminar ');
    idx1:=cantos^.getselindex;
    idx2:=sonid^.getselindex;
    sonid^.getstring(s2, idx2);
    strcat(s1, s2);
    strcat(s1, ' de la lista?');
    res:=messagebox(HWindow, s1, 'Borrar sonido', mb_iconquestion + mb_okcancel);
    if res=idok then begin
      s3:=strpas(PTrucoWindow(Parent)^.progdir);
      assign(f1, s3+'TEMP.INI');
      assign(f2, s3+'TEMP.XXX');
      reset(f1);
      rewrite(f2);
      xx:=0;
      repeat
        readln(f1, s3);
        s4:=upstrcase(s3);
        if s4='[OPCIONES]' then xx:=1; { Nro de bloque 1 }
        if s4='[SONIDOS]' then xx:=2; { Nro de bloque 2 }
        if xx=1 then writeln(f2, s3);
        if xx=2 then begin
          if copy(s4,1,length(nomblock[idx1])+1)=nomblock[idx1]+'=' then begin
            s5:=getpar(s4);
            sonid^.getstring(s2, idx2);
            s6:=upstrcase(strpas(s2));
            if s5<>upstrcase(s6) then writeln(f2, s3);
          end else writeln(f2, s3);
        end;
      until eof(f1);
      close(f1);
      close(f2);
      erase(f1);
      rename(f2, 'TEMP.INI');
      updatesonlista;
    end;
  end;
end;

procedure TModiSoundDialog.Escuchar;
var s1 : array[0..30] of char;
begin
  if sonid^.getcount>0 then begin
    sonid^.getstring(s1, sonid^.getselindex);
    PTrucoWindow(Parent)^.PlaySound(s1, 2);
  end;
end;

procedure TOptionDialog.SetupWindow;
begin
  CheckDlgButton(Hwindow, 101,1);
  CheckDlgButton(Hwindow, 106,1);
  CheckRadioButton(HWindow, 103,104, 103);
  CheckRadioButton(HWindow, 108,109, 108);
end;

procedure TOptionDialog.OK(var Message: TMessage);
begin
  if isdlgbuttonchecked(HWindow, 101)>0 then cflor:=true
    else cflor:=false;
  if isdlgbuttonchecked(HWindow, 106)>0 then PTrucoWindow(Parent)^.ManoJug:=1
    else PTrucoWindow(Parent)^.ManoJug:=2;
  ca30p:=true;
  if isdlgbuttonchecked(HWindow, 103)>0 then ca30p:=true;
  if isdlgbuttonchecked(HWindow, 104)>0 then ca30p:=false;
  if isdlgbuttonchecked(HWindow, 108)>0 then cniv:=true;
  if isdlgbuttonchecked(HWindow, 109)>0 then cniv:=false;
  PTrucoWindow(Parent)^.EnJuego:=1;
  inherited OK(Message);
end;

procedure TCompuflorDialog.SetupWindow;
begin
  CheckRadioButton(HWindow, 102,105, 105);
end;

procedure TCompuflorDialog.OK(var Message: TMessage);
var a : byte;
begin
  a:=0;
  if isdlgbuttonchecked(HWindow, 102)>0 then a:=1;
  if isdlgbuttonchecked(HWindow, 103)>0 then a:=2;
  if isdlgbuttonchecked(HWindow, 104)>0 then a:=3;
  if isdlgbuttonchecked(HWindow, 105)>0 then a:=4;
  PTrucoWindow(Parent)^.extra:=a;
  inherited OK(Message);
end;

procedure TTantoDialog.SetupWindow;
var a : integer;
begin
  a:=PTrucoWindow(Parent)^.Extra;
  setdlgitemint(Hwindow, 101, a, false);
end;

procedure TTantoDialog.OK(var Message: TMessage);
var a,b : integer;
    s1 : pbool;
begin
  a:=0;
  s1:=nil;
  a:=GetDlgItemInt(HWindow, 101, s1, true);
  if (a<0) or (a>33) then a:=200;
  if (a>7) and (a<20) then a:=200;
  PTrucoWindow(Parent)^.extra:=a;
  inherited OK(Message);
end;
{
constructor TSelHumanoDialog.Init(AParent : PWindowsObject);
begin
  inherited Init(AParent, 'SELHUMANO');
  ListB:=New(PCombobox,InitResource(@Self, 101, 30));
end;

destructor TSelHumanoDialog.Done;
begin
  Dispose(ListB, Done);
  inherited Done;
end;
}
procedure TSelHumanoDialog.SetupWindow;
type TComboXferRec = record
      strings : pstrcollection;
      selection : array[0..30] of char;
    end;
var s1 : string;
    i : integer;
    tc : pstrcollection;
    tcx : ^TComboXferRec;
    ListB : pcombobox;
begin
  inherited SetupWindow;
    ListB:=New(PCombobox,InitResource(@Self, 101, 30));

  tc:=new(PStrCollection, init(30, 2));
  strpcopy(tempbuf1, 'Mauro');
  tc^.insert(strnew(tempbuf1));

  new(tcx);
  tcx^.strings:=tc;
  for i:=0 to 30 do tcx^.selection[i]:=#0;
  ListB^.Transfer(tcx, tf_SetData);
  tc^.freeall;
  dispose(tcx);
  dispose(tc, done);

  s1:=PTrucoWindow(parent)^.HumanoName;
  s1:='Mauro';
  strpcopy(tempbuf1, s1);
  ListB^.SetText(tempbuf1);
    Dispose(ListB, Done);
end;

procedure TSelHumanoDialog.OK(var Message: TMessage);
var texto : array[0..65] of char;
begin
{
  ListB^.GetText(texto, 60);
  if strlen(texto)<1 then begin
    messagebeep(mb_iconasterisk);
    exit;
  end;
  PTrucoWindow(parent)^.HumanoName:=strpas(texto);
  }
  inherited OK(Message);
end;


constructor TTrucoWindow.Init(AParent: PWindowsObject; AName: PChar);
var i : integer;
    x1,y1 : integer;
    ewin : trect;
begin
  inherited Init(AParent, Aname);
  attr.style:=ws_overlapped or ws_caption or ws_sysmenu or ws_minimizebox;
  attr.menu:=Loadmenu(HInstance, Pchar(100));
  getwindowrect(getdesktopwindow, ewin);
  x1:=((ewin.right-ewin.left+1) div 2)-320;
  y1:=((ewin.bottom-ewin.top+1) div 2)-240;
  if x1<0 then x1:=0;
  if y1<0 then y1:=0;
  attr.x:=x1; attr.y:=y1; attr.w:=640; attr.h:=480;
  EnJuego:=0;
  mimens1:=0;
  strpcopy(cmens, '');
  Env:=New(PBitButton, Init(@Self, id_Push1, '&Envido', 300, 255, 120,20, False));
  RealEnv:=New(PBitButton, Init(@Self, id_Push2, '&Real Envido', 300, 280, 120,20, False));
  FaltaEnv:=New(PBitButton, Init(@Self, id_Push3, '&Falta Envido', 300, 305, 120,20, False));
  Flor:=New(PBitButton, Init(@Self, id_Push4, 'F&lor', 300, 330, 120,20, False));
  Mazo:=New(PBitButton, Init(@Self, id_Push6, '&Me voy al mazo', 300, 355, 120,45, False));
  Carta1:=New(PBitButton, Init(@Self, id_Push7, 'Carta &1', 440, 255, 120,20, False));
  Carta2:=New(PBitButton, Init(@Self, id_Push8, 'Carta &2', 440, 280, 120,20, False));
  Carta3:=New(PBitButton, Init(@Self, id_Push9, 'Carta &3', 440, 305, 120,20, False));
  Truco:=New(PBitButton, Init(@Self, id_Push10, '&Truco', 440, 330, 120,20, False));
  Retruco:=New(PBitButton, Init(@Self, id_Push11, 'Quiero retr&uco', 440, 355, 120,20, False));
  Vale4:=New(PBitButton, Init(@Self, id_Push12, 'Quiero &vale 4', 440, 380, 120,20, False));
  Quiero:=New(PBitButton, Init(@Self, id_Push13, '&Quiero', 300, 405, 120,20, False));
  NoQuiero:=New(PBitButton, Init(@Self, id_Push14, '&No quiero', 440, 405, 120,20, False));
  randomize;
  SonChecked:=LoadBitMap(HInstance, 'SONCHECK');
  SonUnchecked:=LoadBitMap(HInstance, 'SONUNCHECK');
  TWIcon:=LoadIcon(HInstance, 'TRUCICON');
  TWBrush:=CreateHatchBrush(hs_diagcross, rgb(255,255,160));
end;

destructor TTrucoWindow.Done;
begin
  KillTimer(HWindow, 1);
  if (SPWin<>nil) then Dispose(SPWin,done);
  DeleteObject(TWBrush);
  DeleteObject(TWIcon);
  DeleteObject(SonUnchecked);
  DeleteObject(SonChecked);
  dispose(env, done);  dispose(NoQuiero, done);
  dispose(realenv, done);  dispose(truco, done);
  dispose(faltaenv, done);  dispose(retruco, done);
  dispose(carta1, done);  dispose(vale4, done);
  dispose(carta2, done);  dispose(flor, done);
  dispose(carta3, done);  dispose(mazo,done);
  dispose(quiero, done);
  inherited Done;
end;

function TTrucoWindow.CanClose: Boolean;
var
  ubi : hwnd;
  Reply: Integer;
begin
  CanClose := True;
  if EnJuego>0 then begin
    CanClose:=False;
    Reply := MessageBox(HWindow, '¿Desea abandonar el partido?',
      'Truco para Windows', mb_YesNo or mb_IconQuestion);
    if Reply = id_Yes then CanClose := True;
  end;
end;

procedure TTrucoWindow.WMSysCommand(var Msg: TMessage);
begin
  DefWndProc(Msg);
end;

procedure TTrucoWindow.GetWindowClass(var WndClass: TWndClass);
begin
  inherited GetWindowClass(WndClass);
  WndClass.hIcon := TWIcon;
  WndClass.hbrBackground := TWBrush;
end;

procedure TTrucoWindow.SetUpWindow;
var s : string;
    dir,name,ext : array[0..40] of char;
    s1 : array[0..100] of char;
    srec : tsearchrec;
    f1 : text;
    xx : integer;
    s2,s3 : string;
begin
  inherited SetupWindow;
  SetMenuItemBitmaps(Attr.Menu, cm_sonido, MF_ByCommand, SonUnchecked, SonChecked);
  EnableMenuItem(getMenu(HWindow),cm_save,mf_bycommand + mf_grayed);
  Env^.disable;  Realenv^.disable;  Faltaenv^.disable;
  truco^.disable;  retruco^.disable;  vale4^.disable;
  flor^.disable;  mazo^.disable;
  carta1^.disable;  carta2^.disable;  carta3^.disable;
  quiero^.disable; noquiero^.disable;
  s:=paramstr(0);
  strPcopy(progdir, s);
  filesplit(progdir, dir,name,ext);
  strcopy(progdir,dir);
  strcopy(songdir, progdir);
  strcat(songdir,'SONIDOS\');
  strcopy(s1, progdir);
  strcat(s1, 'TRUCO.INI');
  FindFirst(s1, faArchive, srec);
  if DosError<>0 then begin
    csonid:=true;
    assign(f1, strpas(progdir)+'TRUCO.INI');
    rewrite(f1);
    writeln(f1, '[Opciones]');
    writeln(f1, 'Sonido=SI');
    writeln(f1, '');
    writeln(f1, '[Sonidos]');
    writeln(f1, 'QUIERO=QUIERO1.WAV');
    writeln(f1, 'NOQUIERO=NOQUI1.WAV');
    writeln(f1, 'NOQUIERO=NOQUI2.WAV');
    writeln(f1, 'NOQUIERO=NOQUI3.WAV');
    writeln(f1, 'NOQUIERO=NOQUI4.WAV');
    writeln(f1, 'COMPUGANA=GUASON.WAV');
    writeln(f1, 'COMPUGANA=GAMEOVE1.WAV');
    writeln(f1, 'ENVIDO=ENVIDO1.WAV');
    writeln(f1, 'REALENV=REALENV1.WAV');
    writeln(f1, 'FALTAENV=FALTENV1.WAV');
    writeln(f1, 'TRUCO=TRUCO1.WAV');
    writeln(f1, 'TRUCO=TRUCO2.WAV');
    writeln(f1, 'RETRUCO=RETRUCO1.WAV');
    writeln(f1, 'RETRUCO=RETRUCO2.WAV');
    writeln(f1, 'VALE4=VALE4.WAV');
    writeln(f1, 'FLOR=FLOR1.WAV');
    writeln(f1, 'FLORPORATREV=FLORPA.WAV');
    writeln(f1, 'FLORACHICO=CFACH.WAV');
    writeln(f1, 'CONTRAFLOR=CTFLOR.WAV');
    writeln(f1, 'PERDITANTO=SONBUE1.WAV');
    writeln(f1, 'PERDITANTO=CHAO.WAV');
    writeln(f1, 'PERDITANTO=MDOJO.WAV');
    writeln(f1, 'PERDITANTO=ZAS.WAV');
    writeln(f1, 'PERDITANTO=EHVIEJA.WAV');
    writeln(f1, 'PERDITANTO=RECORCH.WAV');
    writeln(f1, 'PERDITANTO=WAAAH2.WAV');
    writeln(f1, 'GANATANTO=GARDEL.WAV');
    writeln(f1, 'GANATANTO=ORSONLA2.WAV');
    writeln(f1, 'GANATANTO=SPOOKLA2.WAV');
    writeln(f1, 'TANTO0=C0.WAV');
    writeln(f1, 'TANTO1=C1.WAV');
    writeln(f1, 'TANTO2=C2.WAV');
    writeln(f1, 'TANTO3=C3.WAV');
    writeln(f1, 'TANTO4=C4.WAV');
    writeln(f1, 'TANTO5=C5.WAV');
    writeln(f1, 'TANTO6=C6.WAV');
    writeln(f1, 'TANTO7=C7.WAV');
    writeln(f1, 'TANTO20=C20.WAV');
    writeln(f1, 'TANTO21=C21.WAV');
    writeln(f1, 'TANTO22=C22.WAV');
    writeln(f1, 'TANTO23=C23.WAV');
    writeln(f1, 'TANTO24=C24.WAV');
    writeln(f1, 'TANTO25=C25.WAV');
    writeln(f1, 'TANTO26=C26.WAV');
    writeln(f1, 'TANTO27=C27.WAV');
    writeln(f1, 'TANTO28=C28.WAV');
    writeln(f1, 'TANTO29=C29.WAV');
    writeln(f1, 'TANTO30=C30.WAV');
    writeln(f1, 'TANTO31=C31.WAV');
    writeln(f1, 'TANTO32=C32.WAV');
    writeln(f1, 'TANTO33=C33.WAV');
    writeln(f1, 'EXPRESION1=WAAAH2.WAV');
    writeln(f1, 'EXPRESION2=CHA2.WAV');
    writeln(f1, 'EXPRESION3=LOLOR.WAV');
    {
    writeln(f1, '');
    writeln(f1, '[Mensajes]');
    }
    close(f1);
  end;
  csonid:=true;
  assign(f1, strpas(progdir)+'TRUCO.INI');
  reset(f1);
  while not eof(f1) do begin
    readln(f1, s2);
    s2:=upstrcase(s2);
    if s2='[OPCIONES]' then xx:=1; { Nro de bloque 1 }
    if xx=1 then if copy(s2,1,6)='SONIDO' then begin
      s3:=getpar(s2);
      if s3='SI' then csonid:=true;
      if s3='NO' then csonid:=false;
    end;
  end;
  close(f1);
  TrucoSound:=true;
  if PlaySound('TRUCO.WAV',4)=0 then begin
    EnableMenuItem(getMenu(HWindow),cm_sonido,mf_bycommand + mf_grayed);
    TrucoSound:=false;
    csonid:=false;
  end;
  if csonid then CheckMenuItem(getMenu(HWindow),cm_sonido,mf_bycommand + mf_checked)
    else CheckMenuItem(getMenu(HWindow),cm_sonido,mf_bycommand + mf_unchecked);

  SplashTM:=0;  SPWin:=nil;
  SetTimer(HWindow, 1, 100, nil);
end;

function TTrucoWindow.PlaySound(so : pchar; fl : byte) : byte;
 { Flags pueden ser:  1-Ejecuta wav  2-Ejecuta Wav y vuelve rapido
                      3-Ver si hay un Wav en ejecución}
var s : array[0..100] of char;
    mode : word;
    ret : boolean;
begin
  strcopy(s, songdir);
  strcat(s, so);
  mode:=snd_sync;
  case fl of
    1 : mode:=snd_sync;
    2 : mode:=snd_async;
    3 : begin
        mode:=snd_nostop;
        strcopy(s,nil);
        end;
    4 : mode:=snd_nodefault;
  end;
  ret:=sndPlaySound(s, mode or snd_nodefault);
  PlaySound:=0;
  if ret then PlaySound:=1;
end;

procedure TTrucoWindow.CMAbout(var Msg: Tmessage);
begin
  Application^.ExecDialog(New(PAboutBox, Init(@Self, 'Truco para Windows','AUTOR')));
end;

procedure TTrucoWindow.CMSalir(var Msg: Tmessage);
begin
  PostMessage(Hwindow, wm_SysCommand, sc_Close,0);
end;

procedure TTrucoWindow.CMLoadGame(var Msg: Tmessage);
const signat : string[22]='Partido de Truco V'+TrucoVersion+'r'+#26;
var FN : array[0..80] of char;
    f : file;
    jj,i,j : integer;
    chk : word;
    s : string;
    ch : char;
    datarec : record
              chksum : word;
              PuntosA, PuntosB,MaxP : word;
              cmens : string[40];
              bot : array[1..13] of byte;
              cflor : byte;
              tabl : array[1..3,1..4] of byte;
              cart : array[1..3,1..2] of byte;
              mano, juegajug : byte;
              envcant1,envcant2 : word;
              florcant : byte;
              trucocant1,trucocant2,trucocant3 : word;
              genvi, gtruc, enque : word;
              extra,mientenv1,mientenv2,
              mientenv3,mientenv4,
              manojug,humcanto,
              truflag1,mientruc1,mientruc2 : word;
              muesflag1 : byte;
              extr4 : integer;
              extr5 : integer;
    end;
begin
  StrCopy(FN, '*.trc');
  if FileOpenDialog(FN) then begin
    s:=strpas(FN);
    assign(f, s);
    reset(f,1);
    if IOResult<>0 then begin
      MessageBox(HWindow, 'Archivo no encontrado.',
        'Truco para Windows', mb_Ok or mb_IconInformation);
      exit;
    end;
    j:=0;
    for i:=1 to 22 do begin
      blockread(f, ch, 1);
      if ch<>signat[i] then j:=1;
    end;
    if (IOResult<>0) then begin
      MessageBox(HWindow, 'Error en la lectura del archivo.',
        'Truco para Windows', mb_Ok or mb_IconInformation);
      close(f);
      exit;
    end;
    if (j=1) then begin
      MessageBox(HWindow, 'El archivo no es de un Partido de Truco.',
        'Truco para Windows', mb_Ok or mb_IconInformation);
      close(f);
      exit;
    end;
    blockread(f, datarec, sizeof(datarec));
    Close(F);
    if (IOResult<>0) then begin
      MessageBox(HWindow, 'Error en la lectura del archivo.',
        'Truco para Windows', mb_Ok or mb_IconInformation);
      exit;
    end;
    chk:=0;
    for i:=2 to (sizeof(datarec)-1) do begin
      move(mem[seg(datarec):ofs(datarec)+i], ch, 1);
      chk:=chk+ord(ch);
      ch:=chr(ord(ch) xor $de);
      move(ch, mem[seg(datarec):ofs(datarec)+i], 1);
    end;
    chk:=chk xor $4573;
    if (chk<>datarec.chksum) then begin
      MessageBox(HWindow, 'Error: Archivo del partido corrupto.',
        'Truco para Windows', mb_Ok or mb_IconInformation);
      exit;
    end;
    EnJuego:=1;
    strpcopy(cmens, datarec.cmens);
    PuntosA:=datarec.PuntosA; PuntosB:=datarec.PuntosB;
    MaxP:=datarec.MaxP; Humcanto:=datarec.Humcanto;
    Extra:=datarec.Extra ; ManoJug:=datarec.ManoJug;
    mientenv1:=datarec.mientenv1; mientenv2:=datarec.mientenv2;
    mientenv3:=datarec.mientenv3; mientenv4:=datarec.mientenv4;
    humcanto:=datarec.humcanto;
    truflag1:=datarec.truflag1; mientruc1:=datarec.mientruc1;
    mientruc2:=datarec.mientruc2;
    for i:=1 to 3 do begin
      for j:=1 to 4 do tabl[i,j]:=datarec.tabl[i,j];
      for j:=1 to 2 do cart[i,j]:=datarec.cart[i,j];
    end;
    if datarec.cflor=0 then cflor:=false else cflor:=true;
    if datarec.bot[1]=1 then quiero^.enable else quiero^.disable;
    if datarec.bot[2]=1 then noquiero^.enable else noquiero^.disable;
    if datarec.bot[3]=1 then env^.enable else env^.disable;
    if datarec.bot[4]=1 then realenv^.enable else realenv^.disable;
    if datarec.bot[5]=1 then faltaenv^.enable else faltaenv^.disable;
    if datarec.bot[6]=1 then truco^.enable else truco^.disable;
    if datarec.bot[7]=1 then retruco^.enable else retruco^.disable;
    if datarec.bot[8]=1 then vale4^.enable else vale4^.disable;
    if datarec.bot[9]=1 then flor^.enable else flor^.disable;
    if datarec.bot[10]=1 then mazo^.enable else mazo^.disable;
    if datarec.bot[11]=1 then carta1^.enable else carta1^.disable;
    if datarec.bot[12]=1 then carta2^.enable else carta2^.disable;
    if datarec.bot[13]=1 then carta3^.enable else carta3^.disable;
    extr4:=datarec.extr4;
    extr5:=datarec.extr5;
    mano:=datarec.mano; juegajug:=datarec.juegajug;
    envcant1:=datarec.envcant1;  envcant2:=datarec.envcant2;
    florcant:=datarec.florcant;  enque:=datarec.enque;
    trucocant1:=datarec.trucocant1;  trucocant2:=datarec.trucocant2;
    trucocant3:=datarec.trucocant3;
    muesflag1:=datarec.muesflag1;
    genvi:=datarec.genvi;  gtruc:=datarec.gtruc;
    InvalidateRect(HWindow, nil, True);
    updatewindow(hwindow);
  end;
end;

procedure TTrucoWindow.CMSaveGame(var Msg: Tmessage);
const signat : string[22]='Partido de Truco V'+TrucoVersion+'r'+#26;
var FN : array[0..80] of char;
    f : file;
    i,j : integer;
    s : string;
    ch : char;
    datarec : record
              chksum : word;
              PuntosA, PuntosB,MaxP : word;
              cmens : string[40];
              bot : array[1..13] of byte;
              cflor : byte;
              tabl : array[1..3,1..4] of byte;
              cart : array[1..3,1..2] of byte;
              mano, juegajug : byte;
              envcant1,envcant2 : word;
              florcant : byte;
              trucocant1,trucocant2,trucocant3 : word;
              genvi, gtruc, enque : word;
              extra,mientenv1,mientenv2,
              mientenv3,mientenv4,
              manojug,humcanto,
              truflag1,mientruc1,mientruc2 : word;
              muesflag1 : byte;
              extr4 : integer;
              extr5 : integer;
    end;

begin
  StrCopy(FN, '*.trc');
  if FileSaveDialog(FN) then begin
    s:=strpas(FN);
    assign(f, s);
    rewrite(f,1);
    if IOResult<>0 then begin
      MessageBox(HWindow, 'No puedo crear archivo.',
        'Truco para Windows', mb_Ok or mb_IconInformation);
      close(f);
      exit;
    end;
    datarec.PuntosA:=PuntosA;
    datarec.PuntosB:=PuntosB;
    datarec.MaxP:=MaxP;
    datarec.cmens:=strpas(cmens);
    for i:=1 to 3 do begin
      for j:=1 to 4 do datarec.tabl[i,j]:=tabl[i,j];
      for j:=1 to 2 do datarec.cart[i,j]:=cart[i,j];
    end;
    if cflor then datarec.cflor:=1 else datarec.cflor:=0;
    for j:=1 to 13 do datarec.bot[j]:=0;
    if quiero^.getenablestate then datarec.bot[1]:=1;
    if noquiero^.getenablestate then datarec.bot[2]:=1;
    if env^.getenablestate then datarec.bot[3]:=1;
    if realenv^.getenablestate then datarec.bot[4]:=1;
    if faltaenv^.getenablestate then datarec.bot[5]:=1;
    if truco^.getenablestate then datarec.bot[6]:=1;
    if retruco^.getenablestate then datarec.bot[7]:=1;
    if vale4^.getenablestate then datarec.bot[8]:=1;
    if flor^.getenablestate then datarec.bot[9]:=1;
    if mazo^.getenablestate then datarec.bot[10]:=1;
    if carta1^.getenablestate then datarec.bot[11]:=1;
    if carta2^.getenablestate then datarec.bot[12]:=1;
    if carta3^.getenablestate then datarec.bot[13]:=1;
    datarec.mano:=mano; datarec.juegajug:=juegajug;
    datarec.envcant1:=envcant1; datarec.envcant2:=envcant2;
    datarec.florcant:=florcant;  datarec.enque:=enque;
    datarec.trucocant1:=trucocant1; datarec.trucocant2:=trucocant2;
    datarec.trucocant3:=trucocant3;
    datarec.genvi:=genvi;  datarec.gtruc:=gtruc;
    datarec.extra:=extra; datarec.mientenv1:=mientenv1;
    datarec.mientenv2:=mientenv2; datarec.manojug:=manojug;
    datarec.mientenv3:=mientenv3;
    datarec.mientenv4:=mientenv4;
    datarec.humcanto:=humcanto;
    datarec.truflag1:=truflag1; datarec.mientruc1:=mientruc1;
    datarec.mientruc2:=mientruc2;
    datarec.muesflag1:=muesflag1;
    datarec.extr4:=extr4;
    datarec.extr5:=extr5;
    datarec.chksum:=0;
    for i:=2 to (sizeof(datarec)-1) do begin
      move(mem[seg(datarec):ofs(datarec)+i], ch, 1);
      ch:=chr(ord(ch) xor $de);
      datarec.chksum:=datarec.chksum+ord(ch);
      move(ch, mem[seg(datarec):ofs(datarec)+i], 1);
    end;
    datarec.chksum:=datarec.chksum xor $4573;
    for i:=1 to 22 do begin
      ch:=signat[i];
      blockwrite(f, ch, 1);
    end;
    blockwrite(f, datarec, sizeof(datarec));
    Close(F);
    if IOResult<>0 then begin
      MessageBox(HWindow, 'Error en grabación de archivo.',
        'Truco para Windows', mb_Ok or mb_IconInformation);
      exit;
    end;
    InvalidateRect(HWindow, nil, True);
    updatewindow(hwindow);
  end;
end;

procedure TTrucoWindow.CMSonido(var Msg: Tmessage);
begin
  csonid:=not csonid;
  if csonid then CheckMenuItem(getMenu(HWindow),cm_sonido,mf_bycommand + mf_checked)
    else CheckMenuItem(getMenu(HWindow),cm_sonido,mf_bycommand + mf_unchecked);
end;

procedure TTrucoWindow.CMModiSonido(var Msg: Tmessage);
begin
  Application^.ExecDialog(New(PModiSoundDialog, Init(@Self, 'MODISOUND')));
end;

function TTrucoWindow.Getvalor(c1 : integer) : integer;
const valor : array[1..40] of byte = (
   7,6,5,14,13,12,4,10,9,8,   7,6,5,14,13,12,11,10,9,8,
   1,6,5,14,13,12,3,10,9,8,   2,6,5,14,13,12,11,10,9,8);
begin
  GetValor:=valor[c1];
end;

function TTrucoWindow.GanoMano(c1, c2 : integer) : integer;
begin
  GanoMano:=0;
  if GetValor(c1)<GetValor(c2) then GanoMano:=1;
  if GetValor(c1)>GetValor(c2) then GanoMano:=2;
end;

procedure TTrucoWindow.WMLButtonDown(var Message: TMessage);
var
  Point: TPoint;
  ewin : trect;
  x3,y3 : integer;
  nro : integer;
begin
  if EnJuego=0 then exit;
  GetCursorPos(Point);
  getwindowrect(hwindow,ewin);
  ewin.top:=ewin.top+getsystemmetrics(sm_cymenu)+getsystemmetrics(sm_cycaption);
  x3:=point.x-ewin.left;
  y3:=point.y-ewin.top;
  nro:=0;
  if (y3>333) and (y3<334+96) then begin
    if (x3>=20) and (x3<=92) then nro:=1;
    if (x3>=95) and (x3<=167) then nro:=2;
    if (x3>=170) and (x3<=242) then nro:=3;
  end;
  if nro>0 then if tabl[nro,4]=0 then nro:=0;
  x3:=0;
  if nro>0 then begin
    case nro of
      1 : if Carta1^.GetEnableState=true then x3:=1;
      2 : if Carta2^.GetEnableState=true then x3:=1;
      3 : if Carta3^.GetEnableState=true then x3:=1;
    end;
    if x3>0 then begin
      case nro of
        1: carta1^.disable;
        2: carta2^.disable;
        3: carta3^.disable;
      end;
      mimens1:=2;
      mimens2:=nro;
      enque:=0;
      PostMessage(HWindow, wm_Command, cm_action, 0);
    end;
  end;
end;

procedure TTrucoWindow.PlayCompuVoice(m1,m2 : integer);
const nomblock : array[0..16] of string[20] = (
    'ENVIDO','REALENV','FALTAENV','TRUCO','RETRUCO','VALE4',
    'QUIERO','NOQUIERO','GANATANTO','PERDITANTO','FLOR',
    'FLORPORATREV','CONTRAFLOR','FLORACHICO','COMPUGANA',
    'TANTO','EXPRESION');
var li,so,s2,s3 : string;
    f1 : text;
    cson : integer;
    son : array[1..40] of string[20];
    xx,i,j,k : integer;
    sn : array[0..40] of char;

function elifirstspace(el1 : string) : string;
begin
  while (length(el1)>1) and (copy(el1,1,1)=' ') do
    el1:=copy(el1,2,length(el1));
  elifirstspace:=el1;
end;

begin
  if not csonid then exit;
  if m1>16 then exit;
  li:=nomblock[m1];
  if (m1=15) or (m1=16) then begin
    str(m2, s2);
    li:=li+elifirstspace(s2);
  end;
  li:=li+'=';
  assign(f1, strpas(progdir)+'TRUCO.INI');
  reset(f1);
  cson:=0;
  xx:=0;
  while not eof(f1) do begin
    readln(f1, s2);
    s2:=upstrcase(s2);
    if s2='[OPCIONES]' then xx:=1; { Nro de bloque 1 }
    if s2='[SONIDOS]' then xx:=2; { Nro de bloque 2 }
    if xx=2 then if copy(s2,1,length(li))=li then if cson<40 then begin
      s3:=getpar(s2);
      inc(cson);
      son[cson]:=s3;
    end;
  end;
  close(f1);
  if cson>0 then begin
    j:=random(50)+2;
    for i:=1 to j do k:=random(cson)+1;
    strpcopy(sn, son[k]);
    playsound(sn,1);
  end;
end;

procedure TTrucoWindow.CMNuevo(var Msg: Tmessage);
var xx, i : integer;
begin
  xx:=EnJuego;
  EnJuego:=0;
  Application^.ExecDialog(New(POptionDialog, Init(@Self, 'OPCIONES')));
  if Enjuego=0 then Enjuego:=xx
  else if EnJuego=1 then begin
  (*
    HumanoName:='';
    repeat
      i:=Application^.ExecDialog(New(PSelHumanoDialog, Init(@Self, 'SELHUMANO')));
    until (HumanoName<>'') or (i=idcancel);
    if i=idcancel then begin
      Enjuego:=xx;
      exit;
    end;
  *)
    { Game Begins }
    EnableMenuItem(getMenu(HWindow),cm_save,mf_bycommand+mf_enabled);
    PuntosA:=0;
    PuntosB:=0;
    MaxP:=30;
    if not ca30p then MaxP:=15;
    strpcopy(cmens,'');
    mientenv1:=0;  mientenv2:=0;
    mientenv3:=4;  mientenv4:=0;
    mientruc1:=0;  mientruc2:=0;
    mimens1:=1; { <-- Mezclar y repartir }
    InvalidateRect(HWindow, nil, True);
    PostMessage(HWindow, wm_Command, cm_action, 0);
  end;
end;

procedure TTrucoWindow.IDEnvido(var Msg: TMessage);
begin
  mimens1:=4;
  mimens2:=1;
  enque:=1;
  PostMessage(HWindow, wm_Command, cm_action, 0);
end;

procedure TTrucoWindow.IDRealEnvido(var Msg: TMessage);
begin
  mimens1:=4;
  mimens2:=2;
  enque:=1;
  PostMessage(HWindow, wm_Command, cm_action, 0);
end;
procedure TTrucoWindow.IDFaltaEnvido(var Msg: TMessage);
begin
  mimens1:=4;
  mimens2:=3;
  enque:=1;
  PostMessage(HWindow, wm_Command, cm_action, 0);
end;
procedure TTrucoWindow.IDTruco(var Msg: TMessage);
begin
  mimens1:=10;
  mimens2:=1;
  enque:=3;
  PostMessage(HWindow, wm_Command, cm_action, 0);
end;
procedure TTrucoWindow.IDRetruco(var Msg: TMessage);
begin
  mimens1:=10;
  mimens2:=2;
  enque:=3;
  PostMessage(HWindow, wm_Command, cm_action, 0);
end;
procedure TTrucoWindow.IDVale4(var Msg: TMessage);
begin
  mimens1:=10;
  mimens2:=3;
  enque:=3;
  PostMessage(HWindow, wm_Command, cm_action, 0);
end;
procedure TTrucoWindow.IDQuiero(var Msg: TMessage);
begin
  mimens1:=6;
  PostMessage(HWindow, wm_Command, cm_action, 0);
end;
procedure TTrucoWindow.IDNoQuiero(var Msg: TMessage);
begin
  mimens1:=7;
  PostMessage(HWindow, wm_Command, cm_action, 0);
end;
procedure TTrucoWindow.IDFlor(var Msg: TMessage);
begin
  mimens1:=8;
  PostMessage(HWindow, wm_Command, cm_action, 0);
end;
procedure TTrucoWindow.IDMazo(var Msg: TMessage);
begin
  mimens1:=12;
  PostMessage(HWindow, wm_Command, cm_action, 0);
end;
procedure TTrucoWindow.IDCarta1(var Msg: TMessage);
begin
  carta1^.disable;
  mimens1:=2;
  mimens2:=1;
  enque:=0;
  PostMessage(HWindow, wm_Command, cm_action, 0);
end;
procedure TTrucoWindow.IDCarta2(var Msg: TMessage);
begin
  carta2^.disable;
  mimens1:=2;
  mimens2:=2;
  enque:=0;
  PostMessage(HWindow, wm_Command, cm_action, 0);
end;
procedure TTrucoWindow.IDCarta3(var Msg: TMessage);
begin
  carta3^.disable;
  mimens1:=2;
  mimens2:=3;
  enque:=0;
  PostMessage(HWindow, wm_Command, cm_action, 0);
end;

procedure TTrucoWindow.CompuMessage(me : pchar);
var ewin : trect;
begin
  strcopy(cmens,me);
  ewin.left:=299;  ewin.right:=601;  ewin.top:=9;  ewin.bottom:=51;
  InvalidateRect(HWindow, @ewin, True);
  UpdateWindow(Hwindow);
end;

procedure TTrucoWindow.Paint(PaintDC: HDC; var PaintInfo: TPaintStruct);
const c : array[1..3] of integer = (27,15,21);
var i,j : integer;
    ewin : trect;
    s : array[0..20] of char;
    xx : twndclass;
    xx2 : longint;

procedure DibujaMensaje;
var last : thandle;
    pen : hpen;
    xx : longint;
    xx2 : word;
begin
  last:=selectobject(PaintDC, GetStockObject(ltgray_brush));
  rectangle(PaintDC,300,10,600,50);
  SelectObject(PaintDC, GetStockObject(Black_pen));
  moveto(PaintDC,300,10);
  Lineto(PaintDC,600,10); LineTo(PaintDC,600,50);
  LineTo(PaintDC,300,50); LineTo(PaintDC,300,10);
  SelectObject(PaintDC, GetStockObject(White_pen));
  moveto(PaintDC,301,49);
  Lineto(PaintDC,301,11); LineTo(PaintDC,599,11);
  pen:=createpen(ps_solid,1,rgb(60,60,60));
  SelectObject(PaintDC, pen);
  moveto(PaintDC,301,49);
  Lineto(PaintDC,599,49); LineTo(PaintDC,599,11);
  selectobject(PaintDC, GetStockObject(system_font));
  selectobject(PaintDC, GetStockObject(black_pen));
  selectObject(PaintDC, last);
  deleteobject(pen);
  Setbkmode(PaintDC, transparent);
  xx:=GetTextExtent(PaintDC, cmens, strlen(cmens));
  xx2:=loword(xx) div 2;
  TextOut(PaintDC, 470-xx2,30, cmens, strlen(cmens));
  TextOut(PaintDC, 305,12, 'CompuTruco:', 11);
  Setbkmode(PaintDC, opaque);
end;

procedure DibujaCarta(nro : integer; x,y : integer);
var
  MemDC: HDC;
  bitm : HBitMap;
  nom,nomb : pchar;
  x1,x2 : integer;
  s : array[0..20] of char;
  s1 : string;
  TheFont : HFont;
  last,last1 : THandle;
begin
  if nro=0 then strcopy(s,'REVERSO')
  else begin
    x2:=((nro-1) mod 10)+1;
    x1:=((nro-1) div 10)+1;
    case x1 of
      1 : nomb:='OROS';
      2 : nomb:='COPAS';
      3 : nomb:='ESPADAS';
      4 : nomb:='BASTOS';
    end;
    case x2 of
      1 : nom:='1';
      2 : nom:='2';
      3 : nom:='3';
      4 : nom:='4';
      5 : nom:='5';
      6 : nom:='6';
      7 : nom:='7';
      8 : nom:='A';
      9 : nom:='B';
      10 : nom:='C';
    end;
    strcopy(s, nomb);
    strcat(s, nom);
  end;
  BitM:=LoadBitMap(hInstance, s);
  MemDC:=CreateCompatibleDC(PaintDC);
  last:=SelectObject(MemDC, BitM);
  BitBlt(PaintDC, X, Y, 72,96, MemDC, 0, 0, SRCCopy);
  SelectObject(MemDC, last);
  DeleteObject(BitM);
  DeleteDC(MemDC);
  if nro>0 then begin
    x2:=((nro-1) mod 10)+1;
    case x2 of
      1 : nom:='1';
      2 : nom:='2';
      3 : nom:='3';
      4 : nom:='4';
      5 : nom:='5';
      6 : nom:='6';
      7 : nom:='7';
      8 : nom:='10';
      9 : nom:='11';
      10 : nom:='12';
    end;
    StrCopy(s, nom);
    Setbkmode(PaintDC, Transparent);
    {TheFont:=0;
    last1:=SelectObject(PaintDC, TheFont);}
    SetTextColor(PaintDC, RGB(0,0,128));
    TextOut(PaintDC, X+10, Y+8, S, StrLen(S));
    TextOut(PaintDC, X+62-(strlen(s)*8), Y+70, S, StrLen(S));
    {SelectObject(PaintDC, last1);}
    Setbkmode(PaintDC, opaque);
  end;
end;

procedure DibujaPuntaje(x,y : integer);
var
  nom,nomb : pchar;
  x1,x2 : integer;
  last : thandle;
  s : array[0..20] of char;
  s1 : string;
  TheFont : HFont;
  ThePen : HPen;
  ALogFont : TLogFont;
procedure dibupun(x,y,p : integer);
begin
  moveto(PaintDC,x,y);
  if p>0 then lineto(PaintDC, x+30,y);
  moveto(PaintDC,x,y);
  if p>1 then lineto(PaintDC, x,y+30);
  moveto(PaintDC,x+30,y);
  if p>2 then lineto(PaintDC, x+30,y+30);
  moveto(PaintDC,x,y+30);
  if p>3 then lineto(PaintDC, x+30,y+30);
  moveto(PaintDC,x,y);
  if p>4 then lineto(PaintDC, x+30,y+30);
end;
begin
  TheFont:=0;
  last:=SelectObject(PaintDC, TheFont);
  nom:='Puntaje';
  StrCopy(s, nom);
  Setbkmode(PaintDC, Transparent);
  FillChar(ALogFont, SizeOf(TLogFont), #0);
  with ALogFont do begin
    lfEscapement    := 900;
    lfHeight        := 32;     {Make a large font                 }
    lfWeight        := 700;    {Indicate a Bold attribute         }
    lfItalic        := 1;      {Non-zero value indicates italic   }
    lfUnderline     := 0;      {Non-zero value indicates underline}
    lfOutPrecision  := Out_Stroke_Precis;
    lfClipPrecision := Clip_Stroke_Precis;
    lfQuality       := Default_Quality;
    lfPitchAndFamily:= Variable_Pitch;
    StrCopy(lfFaceName, 'Times New Roman');
  end;
  TheFont := CreateFontIndirect(ALogFont);
  SelectObject(PaintDC, TheFont);
  SetTextColor(PaintDC, RGB(0,0,128));
  TextOut(PaintDC, X-3, Y+134, 'Puntaje', 7);
  selectobject(PaintDC, GetStockObject(system_font));
  SelectObject(PaintDC, last);
  if TheFont<>0 then DeleteObject(TheFont);
  AlogFont.lfHeight:=25;
  AlogFont.lfEscapement:=0;
  AlogFont.lfUnderline:=1;
  TheFont := CreateFontIndirect(ALogFont);
  SelectObject(PaintDC, TheFont);
  TextOut(PaintDC, X+55, Y+4, 'Humano',6);
  TextOut(PaintDC, X+165, Y+4,'CompuTruco', 10);
  Setbkmode(PaintDC, opaque);
  selectobject(PaintDC, GetStockObject(system_font));
  SelectObject(PaintDC, last);
  if TheFont<>0 then DeleteObject(TheFont);
  ThePen:=CreatePen(ps_Solid, 2, rgb(128,0,0));
  SelectObject(PaintDC, ThePen);
  MoveTo(PaintDC, x,y);
  LineTo(PaintDC, x+290,y);
  Lineto(PaintDC, x+290, y+170);
  LineTo(PaintDC, x, y+170);
  LineTo(PaintDC, x,y);
  MoveTo(PaintDC, x+30,y);
  LineTo(PaintDC, x+30,y+170);
  MoveTo(PaintDC, X+162,Y);
  LineTo(PaintDC, x+162,y+170);
  selectobject(PaintDC, GetStockObject(black_pen));
  SelectObject(PaintDC, last);
  if ThePen<>0 then DeleteObject(ThePen);
  ThePen:=CreatePen(ps_Solid, 2, rgb(160,32,160));
  SelectObject(PaintDC, ThePen);
  if PuntosA<6 then DibuPun(x+60,y+50,PuntosA)
  else begin
    DibuPun(x+60,y+50,5);
    if PuntosA<11 then DibuPun(x+60,y+90,PuntosA-5)
    else begin
      DibuPun(x+60,y+90,5);
      if PuntosA<16 then DibuPun(x+60,y+130,PuntosA-10)
      else begin
        DibuPun(x+60,y+130,5);
        if PuntosA<21 then DibuPun(x+100,y+50,PuntosA-15)
        else begin
          DibuPun(x+100,y+50,5);
          if PuntosA<26 then DibuPun(x+100,y+90,PuntosA-20)
          else begin
            DibuPun(x+100,y+90,5);
            DibuPun(x+100,y+130,PuntosA-25);
          end;
        end;
      end;
    end;
  end;
  if PuntosB<6 then DibuPun(x+190,y+50,PuntosB)
  else begin
    DibuPun(x+190,y+50,5);
    if PuntosB<11 then DibuPun(x+190,y+90,PuntosB-5)
    else begin
      DibuPun(x+190,y+90,5);
      if PuntosB<16 then DibuPun(x+190,y+130,PuntosB-10)
      else begin
        DibuPun(x+190,y+130,5);
        if PuntosB<21 then DibuPun(x+230,y+50,PuntosB-15)
        else begin
          DibuPun(x+230,y+50,5);
          if PuntosB<26 then DibuPun(x+230,y+90,PuntosB-20)
          else begin
            DibuPun(x+230,y+90,5);
            DibuPun(x+230,y+130,PuntosB-25);
          end;
        end;
      end;
    end;
  end;
  selectobject(PaintDC, GetStockObject(black_pen));
  SelectObject(PaintDC, last);
  if ThePen<>0 then DeleteObject(ThePen);
end;

begin
  if EnJuego=0 then begin
    if strlen(cmens)<>0 then DibujaMensaje;
    PuntosA:=18;
    PuntosB:=24;
    for i:=1 to 3 do begin
      Dibujacarta(0,(i-1)*75+20,4);
      Dibujacarta(c[i],(i-1)*75+20,334);
    end;
  end;
  if EnJuego=1 then begin
    if strlen(cmens)<>0 then DibujaMensaje;
    for i:=1 to 3 do begin
      if tabl[i,1]>0 then Dibujacarta(0,(i-1)*75+20,4);
      if tabl[i,4]>0 then Dibujacarta(tabl[i,4],(i-1)*75+20,334);
      if tabl[i,2]>0 then Dibujacarta(tabl[i,2],(i-1)*75+20,114);
      if tabl[i,3]>0 then Dibujacarta(tabl[i,3],(i-1)*75+20,224);
    end;
  end;
  Dibujapuntaje(300,60);
end;

procedure TTrucoWindow.Acciones;
var i,j,k,l,m,n : integer;
    s : pchar;
    s1 : array[0..20] of char;
    ewin : trect;
    c1,c2,c3 : integer;

function gettanto(jug : integer) : integer;
var a1,a2,a3,a4,b1,b2,b3 : integer;
begin
  a4:=0;
  a1:=((cart[1,jug]-1) mod 10)+1;
  b1:=((cart[1,jug]-1) div 10)+1;
  a2:=((cart[2,jug]-1) mod 10)+1;
  b2:=((cart[2,jug]-1) div 10)+1;
  a3:=((cart[3,jug]-1) mod 10)+1;
  b3:=((cart[3,jug]-1) div 10)+1;
  if a1>7 then a1:=0;
  if a2>7 then a2:=0;
  if a3>7 then a3:=0;
  if (b1<>b2) and (b2<>b3) and (b3<>b1) then begin
    a4:=a1; if a2>a4 then a4:=a2;
    if a3>a4 then a4:=a3;
  end else if (b1=b2) and (b2=b3) then begin
    a4:=a1+a2;
    if a2+a3>a4 then a4:=a2+a3;
    if a1+a3>a4 then a4:=a1+a3;
    a4:=a4+20;
  end else begin
    if b1=b2 then a4:=a1+a2;
    if b1=b3 then a4:=a1+a3;
    if b3=b2 then a4:=a3+a2;
    a4:=a4+20;
  end;
  gettanto:=a4;
end;
function getflor(jug : integer) : integer;
var a1,a2,a3,a4,b1,b2,b3 : integer;
begin
  a4:=0;
  a1:=((cart[1,jug]-1) mod 10)+1;
  b1:=((cart[1,jug]-1) div 10)+1;
  a2:=((cart[2,jug]-1) mod 10)+1;
  b2:=((cart[2,jug]-1) div 10)+1;
  a3:=((cart[3,jug]-1) mod 10)+1;
  b3:=((cart[3,jug]-1) div 10)+1;
  if a1>7 then a1:=0;
  if a2>7 then a2:=0;
  if a3>7 then a3:=0;
  if (b1=b2) and (b2=b3) then a4:=a1+a2+a3+20;
  getflor:=a4;
end;

function checkcomputanto(ni : byte) : integer;
var a3,a1,a2,a4 : integer;
begin
  a3:=2;
  a1:=gettanto(2);
  a2:=getflor(2);
  if (a2>0) and (cflor=true) then begin
    if (a1<32) or (ni<>3) then begin
      checkcomputanto:=6;
      exit;
    end else if ni=3 then begin
      checkcomputanto:=1;
      exit;
    end;
  end;
  if cniv then begin
    case ni of
      1 : begin
          a4:=0;
          if (PuntosA>PuntosB+5) then a4:=-(random(2)+1);
          if envcant1<3 then begin
            if (tabl[1,2]=0) then begin
              if (a1>26+a4-mientenv1) then a3:=1;
              if (a1>7) and (random(1000)>890-(130*mientenv1)) then a3:=1;
            end else begin
              if (a1>25+a4-mientenv1) then a3:=1;
              if (a1>7) and (random(1000)>890-(130*mientenv1)) then a3:=1;
            end;
            if (a1>26-mientenv1) and (random(1000)>700-(200*mientenv1)) then a3:=3;
            if (a1>28-mientenv1) and (random(1000)>300-(100*mientenv1)) then a3:=3;
          end else begin
            if (a1>27-mientenv1+a4-random(2)) then a3:=1;
            if (mientenv2>6) and (a1>22+(mientenv3 div 2)) and (random(1000)>500) then a3:=1;
            if (tabl[1,3]>0) and (tabl[1,2]=0) then begin
              if (a1>27-mientenv1) and (random(1000)>700-(200*mientenv1)) then a3:=4;
              if (a1>29-mientenv1) and (random(1000)>300-(100*mientenv1)) then a3:=4;
            end else begin
              if (a1>26-mientenv1) and (random(1000)>700-(200*mientenv1)) then a3:=4;
              if (a1>28-mientenv1) and (random(1000)>300-(100*mientenv1)) then a3:=4;
            end;
          end;
          if (a1>28) and (random(1000)>700-(80*mientenv1)) then a3:=4;
          if (a1>31) and (random(1000)>900-(100*mientenv1)) then a3:=5;
          if (PuntosB=maxP-1) then a3:=5;
          if (a3=3) and (extr4>1) then a3:=4;
          if (a3=4) and (extr5>1) then a3:=5;
          if (PuntosB+envcant2>=MaxP) then a3:=5;
          if (a3>2) and (PuntosB+envcant2+2>=MaxP) then a3:=5;
          end;
      2 : begin
          a4:=0;
          if (PuntosA>PuntosB+8) then a4:=-(random(2)+1);
          if (envcant1<=3) then begin
            if (a1>7+a4) and (random(1000)>930-(50*mientenv1)) then a3:=1;
            if (a1>27+a4-(mientenv1 div 2)) then a3:=1;
            if (a1>25+a4) and (random(1000)>770-(130*mientenv1)) then a3:=4;
          end else if (envcant1<=5) then begin
            if (tabl[1,3]>0) then begin
              if (a1>7+a4) and (random(1000)>930-(50*mientenv1)) then a3:=1;
              if (a1>27+a4-(mientenv1 div 2)-random(2)) then a3:=1;
              if (a1>31+a4-(mientenv1*2)) and (random(1000)>500) then a3:=5;
            end else begin
              if (a1>7+a4) and (random(1000)>930-(50*mientenv1)) then a3:=1;
              if (a1>26+a4-(mientenv1 div 2)-random(2)) then a3:=1;
              if (a1>25+a4) and (random(1000)>770-(130*mientenv1)) then a3:=4;
            end;
          end else begin
            if (a1>7+a4) and (random(1000)>930-(50*mientenv1)) then a3:=1;
            if (a1>28+a4-(mientenv1 div 2)) then a3:=1;
            if (a1>27+a4) and (random(1000)>770-(130*mientenv1)) then a3:=5;
          end;
          if (a1>30-(mientenv1 div 2)) and (random(1000)>900-(170*mientenv1)) then a3:=5;
          if (PuntosB=maxP-1) then a3:=5;
          if (PuntosB+envcant2>=MaxP) then a3:=5;
          if (a3>2) and (PuntosB+envcant2+3>=MaxP) then a3:=5;
          end;
      3 : begin
          a4:=0;
          if (PuntosA>PuntosB+8) then a4:=-(random(2)+1);
          if (envcant2>6) and (PuntosA>17) then a4:=a4-2;
          if (tabl[1,3]>0) and (tabl[1,2]=0) then begin
            if (a1>30-a4-mientenv1*2) and (random(1000)>550-(150*mientenv1)) then a3:=1;
          end else begin
            if (a1>26) and (PuntosB>=MaxP-4) and (PuntosA>=MaxP-9) then a3:=1;
            if (a1>26-a4) and (random(1000)>580-(150*mientenv1)) then a3:=1;
          end;
          if (PuntosB+envcant2>=MaxP) then a3:=1;
          if (a1>31) then a3:=1;
          if (a1=31) and (ManoJug=2) then a3:=1;
          if (PuntosB=maxP-1) then a3:=1;
          end;
    end;
  end else begin
    case ni of
      1 : begin
          if (a1>7) and (random(1000)>890-(130*mientenv1)) then a3:=1;
          if envcant1<3 then begin
            if (a1>23) or (mientenv1=2) then a3:=1;
          end else if a1>27-mientenv1 then a3:=1;
          if (a1>26-mientenv1) and (random(1000)>700-(50*mientenv1)) then a3:=3;
          if (a1>28-mientenv1) and (random(1000)>300-(100*mientenv1)) then a3:=3;
          if (a1>28) and (random(1000)>700-(80*mientenv1)) then a3:=4;
          if (a1>30) and (random(1000)>900-(100*mientenv1)) then a3:=5;
          if (PuntosB=maxP-1) then a3:=5;
          if (a3=3) and (extr4>1) then a3:=4;
          if (a3=4) and (extr5>1) then a3:=5;
          end;
      2 : begin
          if (a1>7) and (random(1000)>880-(50*mientenv1)) then a3:=1;
          if (a1>28-(mientenv1 div 2)) then a3:=1;
          if (a1>26) and (random(1000)>770-(130*mientenv1)) then a3:=4;
          if (a1>30-(mientenv1 div 2)) and (random(1000)>900-(200*mientenv1)) then a3:=5;
          if (PuntosB=maxP-1) then a3:=5;
          end;
      3 : begin
          if (a1>25) and (random(1000)>800-(200*mientenv1)) then a3:=1;
          if (a1>28-(mientenv1 div 2)) and (random(1000)>600-(100*mientenv1)) then a3:=1;
          if (a1>30) then a3:=1;
          if (PuntosB=maxP-1) then a3:=1;
          end;
    end;
  end;
  if (envcant2+PuntosA>=maxP) then if a3=2 then a3:=1;
  checkcomputanto:=a3;
end;

procedure CantoTanto(od : byte; var c1,c2 : integer);
var s,s1 : array[0..20] of char;
    x1,x2 : integer;
begin
  x1:=gettanto(1);
  x2:=gettanto(2);
  if od=1 then begin
    repeat
      extra:=x1;
      Application^.ExecDialog(New(PTantoDialog, Init(@Self, 'TANTO')));
    until (extra<>200);
    x1:=extra;
    if x1<x2 then begin
      muesflag1:=1;
      strcopy(s, 'Yo tengo ');
      str(x2, s1);
      strcat(s, s1);
      CompuMessage(s);
      PlayCompuVoice(15,x2);
    end else begin
      strcopy(s, 'Son buenas.');
      CompuMessage(s);
      PlayCompuVoice(9,0);
    end;
  end else begin
    strcopy(s, 'Yo tengo ');
    str(x2, s1);
    strcat(s, s1);
    CompuMessage(s);
    PlayCompuVoice(15,x2);
    repeat
      extra:=x1;
      Application^.ExecDialog(New(PTantoDialog, Init(@Self, 'TANTO')));
    until (extra<>200);
    x1:=extra;
    if x2>=x1 then muesflag1:=1;
  end;
  c1:=x1;
  c2:=x2;
  if (c1<c2) then PlayCompuVoice(8,0);
end;

procedure finalderonda;
var a4,a3,a1,a2 : integer;
    b1,b2 : integer;
procedure cartascomputanto(var c1,c2 : integer);
var a1,a2,a3,a4,b1,b2,b3 : integer;
begin
  a4:=0;
  c1:=0;
  c2:=0;
  a1:=((cart[1,2]-1) mod 10)+1;
  b1:=((cart[1,2]-1) div 10)+1;
  a2:=((cart[2,2]-1) mod 10)+1;
  b2:=((cart[2,2]-1) div 10)+1;
  a3:=((cart[3,2]-1) mod 10)+1;
  b3:=((cart[3,2]-1) div 10)+1;
  if a1>7 then a1:=0;
  if a2>7 then a2:=0;
  if a3>7 then a3:=0;
  if (b1<>b2) and (b2<>b3) and (b3<>b1) then begin
    a4:=a1;  c1:=1;
    if a2>a4 then begin a4:=a2; c1:=2; end;
    if a3>a4 then begin a4:=a3; c1:=3; end;
  end else if (b1=b2) and (b2=b3) then begin
    a4:=a1+a2;
    c1:=1; c2:=2;
    if a2+a3>a4 then begin a4:=a2+a3; c1:=2; c2:=3; end;
    if a1+a3>a4 then begin a4:=a1+a3; c1:=1; c2:=3; end;
  end else begin
    if b1=b2 then begin a4:=a1+a2; c1:=1; c2:=2; end;
    if b1=b3 then begin a4:=a1+a3; c1:=1; c2:=3; end;
    if b3=b2 then begin a4:=a3+a2; c1:=3; c2:=2; end;
    a4:=a4+20;
  end;
end;

begin
  env^.disable; realenv^.disable; faltaenv^.disable;
  truco^.disable;  carta1^.disable;  carta2^.disable;
  carta3^.disable; flor^.disable;  mazo^.disable;
  quiero^.disable; noquiero^.disable;
  vale4^.disable; retruco^.disable;
  a1:=0; a2:=0; a3:=0; a4:=1;
  if tabl[1,3]>0 then a1:=getvalor(tabl[1,3]);
  if tabl[2,3]>0 then begin
    a2:=getvalor(tabl[2,3]);
    a4:=2;
  end;
  if tabl[3,3]>0 then begin
    a3:=getvalor(tabl[3,3]);
    a4:=3;
  end;
  if (truflag1=1) then begin
    a4:=(a1+a2+a3) div a4;
    if a4>8+random(2) then begin
      inc(mientruc2);
      if mientruc2=3 then mientruc1:=1;
      if mientruc2=6 then mientruc1:=2;
      if mientruc2>8 then mientruc2:=8;
    end else begin
      dec(mientruc2);
      if mientruc2=3 then mientruc1:=0;
      if mientruc2=6 then mientruc1:=1;
      if mientruc2<0 then mientruc2:=0;
    end;
  end;
  if (mientenv4=1) and (mientenv3<10) then inc(mientenv3);
  if (mientenv4=2) and (mientenv3>0) then dec(mientenv3);
  if genvi=400 then begin
    muesflag1:=0;
    a3:=0;
    repeat
      inc(a3);
    until (tabl[a3,2]=0) or (a3>3);
    for a2:=1 to 3 do if tabl[a2,1]>0 then begin
      tabl[a3,2]:=tabl[a2,1];
      inc(a3);
    end;
    for a3:=1 to 3 do tabl[a3,1]:=0;
    ewin.top:=0; ewin.bottom:=480; ewin.left:=0; ewin.right:=250;
    InvalidateRect(HWindow, @ewin, True);
    updatewindow(hwindow);
    a1:=getflor(1);
    a2:=getflor(2);
    a3:=1;
    if a2>a1 then a3:=2;
    if a2=a1 then a3:=ManoJug;
    if a1=0 then a3:=2;
    Genvi:=a3*100+MaxP;
    case a3 of
      1 : MessageBox(HWindow, '¡Oh, no! Perdí en la contraflor.','Truco para Windows', mb_IconInformation or mb_OK);
      2 : MessageBox(HWindow, 'Lo siento. La mía es mas grande que la tuya. (La flor, por supuesto.)',
            'Truco para Windows', mb_IconInformation or mb_OK);
    end;
  end else if genvi=300 then begin
    a1:=getflor(1);
    a2:=getflor(2);
    a3:=1;
    if a2>a1 then a3:=2;
    if a2=a1 then a3:=ManoJug;
    Genvi:=a3*100+6;
    case a3 of
      1 : MessageBox(HWindow, 'Maldición, me ganaste en la flor.','Truco para Windows', mb_IconInformation or mb_OK);
      2 : MessageBox(HWindow, 'Te gane en la flor. La tuya es de juguete.','Truco para Windows', mb_IconInformation or mb_OK);
    end;
  end else if florcant>0 then begin
    if (genvi>100) and (genvi<200) then begin
      a1:=getflor(1);
      if a1=0 then begin
        MessageBox(HWindow, 'Mentiroso, no tenías flor.','Truco para Windows', mb_IconInformation or mb_OK);
        genvi:=genvi+100;
      end;
    end;
  end else if (genvi>100) and (genvi<200) then begin
    a1:=gettanto(1);
    if a1<>humcanto then begin
      MessageBox(HWindow, 'Cantaste mal el tanto.','Truco para Windows', mb_IconInformation or mb_OK);
      genvi:=genvi+100;
    end;
  end;
  if florcant=0 then if humcanto>0 then begin
    if (humcanto<26) then begin
      inc(mientenv2);
      if mientenv2=3 then mientenv1:=1;
      if mientenv2=6 then mientenv1:=2;
      if mientenv2>8 then mientenv2:=8;
    end else begin
      dec(mientenv2);
      if mientenv2=3 then mientenv1:=0;
      if mientenv2=6 then mientenv1:=1;
      if mientenv2<0 then mientenv2:=0;
    end;
  end;
  if (genvi>100) and (genvi<200) then PuntosA:=PuntosA+genvi-100;
  if (genvi>200) and (genvi<300) then PuntosB:=PuntosB+genvi-200;
  if (gtruc>100) and (gtruc<200) then PuntosA:=PuntosA+gtruc-100;
  if (gtruc>200) and (gtruc<300) then PuntosB:=PuntosB+gtruc-200;
  if PuntosA>MaxP then PuntosA:=MaxP;
  if PuntosB>MaxP then PuntosB:=MaxP;
  ewin.top:=57; ewin.bottom:=250; ewin.left:=250; ewin.right:=630;
  InvalidateRect(HWindow, @ewin, True);
  updatewindow(hwindow);
{  a3:=0;
  repeat
    inc(a3);
  until (tabl[a3,2]=0) or (a3>3);
  if a3<4 then begin
    for a2:=1 to 3 do if tabl[a2,1]>0 then begin
      tabl[a3,2]:=tabl[a2,1];
      inc(a3);
    end;
  end;
  a3:=0;
  repeat
    inc(a3);
  until (tabl[a3,3]=0) or (a3>3);
  if a3<4 then begin
    for a2:=1 to 3 do if tabl[a2,4]>0 then begin
      tabl[a3,3]:=tabl[a2,4];
      inc(a3);
    end;
  end;
  for a3:=1 to 3 do tabl[a3,1]:=0;
  for a3:=1 to 3 do tabl[a3,4]:=0; }
  { muestra-cartas }
  a3:=0;
  repeat
    inc(a3);
  until (tabl[a3,2]=0) or (a3>3);
  if (muesflag1>0) and (a3<4) then begin
    case muesflag1 of
      1 : begin
          cartascomputanto(b1,b2);
          if (b1>0) then if tabl[b1,1]>0 then begin
            tabl[a3,2]:=tabl[b1,1];
            tabl[b1,1]:=0;
            inc(a3);
          end;
          if (b2>0) then if tabl[b2,1]>0 then begin
            tabl[a3,2]:=tabl[b2,1];
            tabl[b2,1]:=0;
            inc(a3);
          end;
          end;
      2 : begin
          for a2:=1 to 3 do if tabl[a2,1]>0 then begin
            tabl[a3,2]:=tabl[a2,1];
            inc(a3);
          end;
          for a3:=1 to 3 do tabl[a3,1]:=0;
          end;
    end;
  end;
  ewin.top:=0; ewin.bottom:=480; ewin.left:=0; ewin.right:=250;
  InvalidateRect(HWindow, @ewin, True);
  updatewindow(hwindow);
  compumessage(#0);
  a1:=0;
  if PuntosA=MaxP then begin
    a1:=1;
    MessageBox(HWindow, 'Bueno, perdí. Pero me darás la revancha, ¿no?','Truco para Windows', mb_IconInformation or mb_OK);
    PlayCompuVoice(16,1);
  end;
  if PuntosB=MaxP then begin
    a1:=2;
    MessageBox(HWindow, 'Ja! Ja! Te hice la boleta.','Truco para Windows', mb_IconInformation or mb_OK);
    PlayCompuVoice(14,0);
  end;
  if a1=0 then begin
    MessageBox(HWindow, 'Pulse OK para continuar jugando.','Truco para Windows', mb_IconInformation or mb_OK);
    ManoJug:=3-ManoJug;
    mimens1:=1;
    PostMessage(HWindow, wm_Command, cm_action, 0);
  end else begin
    EnJuego:=0;
    compumessage(#0);
    EnableMenuItem(getMenu(HWindow),cm_save,mf_bycommand+mf_grayed);
    Env^.disable;  Realenv^.disable;  Faltaenv^.disable;
    truco^.disable;  retruco^.disable;  vale4^.disable;
    flor^.disable; mazo^.disable;
    carta1^.disable;  carta2^.disable;  carta3^.disable;
    quiero^.disable; noquiero^.disable;
    InvalidateRect(Hwindow, nil ,true);
    UpdateWindow(Hwindow);
  end;
end;

procedure cartajugada;
var a1,a2,a3,a4 : integer;
    ewin : trect;
begin
  if (tabl[mano,2]<>0) and (tabl[mano,3]<>0) then begin
    a1:=ganomano(tabl[mano,3],tabl[mano,2]);
    if a1=0 then JuegaJug:=ManoJug
      else JuegaJug:=a1;
    inc(mano);
    env^.disable; realenv^.disable;  faltaenv^.disable;
    flor^.disable;
    noquiero^.disable; quiero^.disable;
  end else begin
    juegajug:=3-juegajug;
  end;
  a1:=0;
  if mano=3 then begin
    a2:=ganomano(tabl[1,3],tabl[1,2]);
    a3:=ganomano(tabl[2,3],tabl[2,2]);
    if (a2=1) and (a3=1) then a1:=1;
    if (a2=2) and (a3=2) then a1:=2;
    if (a2=0) and (a3=1) then a1:=1;
    if (a2=0) and (a3=2) then a1:=2;
    if (a2=1) and (a3=0) then a1:=1;
    if (a2=2) and (a3=0) then a1:=2;
  end;
  if mano=4 then begin
    a2:=ganomano(tabl[1,3],tabl[1,2]);
    a3:=ganomano(tabl[2,3],tabl[2,2]);
    a4:=ganomano(tabl[3,3],tabl[3,2]);
    if (a2=1) and (a4=1) then a1:=1;
    if (a2=2) and (a4=2) then a1:=2;
    if (a3=1) and (a4=1) then a1:=1;
    if (a3=2) and (a4=2) then a1:=2;
    if (a2=1) and (a3=2) and (a4=0) then a1:=1;
    if (a2=2) and (a3=1) and (a4=0) then a1:=2;
    if (a2=0) and (a3=0) and (a4<>0) then a1:=a4;
    if (a2=0) and (a3=0) and (a4=0) then a1:=manojug;
  end;
  if a1>0 then begin
    gtruc:=100*a1+trucocant1;
    finalderonda;
    exit;
  end;
  if JuegaJug=2 then begin
    mimens1:=3;
    PostMessage(HWindow, wm_Command, cm_action, 0);
  end;
end;

procedure Compucantatanto;
begin
  if (mano=1) and (envcant1=0) then begin
    i:=getflor(2);
    if (i>0) and (cflor=true) then begin
      mimens1:=9;
    end else begin
      i:=gettanto(2);
      if (not cniv) then begin
        if (i<20) and ((random(1000)>920) or (mientenv1=2)) then if PuntosA<MaxP-1 then begin
          mimens1:=5;
          mimens2:=1;
        end;
        if (i>7) and (random(1000)>700) then begin
          mimens1:=5;
          mimens2:=1;
        end;
        if (i>25) and (random(1000)>170) then begin
          mimens1:=5;
          mimens2:=1;
        end;
        if (i=25) and (mientenv1=2) then begin
          mimens1:=5;
          mimens2:=2;
        end;
        if (i>27) and (random(1000)>530) then begin
          mimens1:=5;
          mimens2:=2;
        end;
        if (i>=30-mientenv1) and (random(1000)>850) then begin
          mimens1:=5;
          mimens2:=3;
        end;
      end else begin
        if tabl[1,3]>0 then begin
          if (i>27) then begin
            mimens1:=5;
            mimens2:=1;
            if random(1000)>800 then mimens2:=2;
            if (mientenv3<8) and (random(1000)>880) and (PuntosA-5>PuntosB) then mimens2:=3;
          end else if (i<20) then begin
            if (random(1000)>(mientenv3*70)+300) then begin
              mimens1:=5;
              mimens2:=1;
            end;
            if (PuntosA-8>PuntosB) and (PuntosA<26) and (random(1000)>800) then begin
              mimens1:=5;
              mimens2:=3;
            end;
          end else begin
            if (mientenv3<3+random(2)) then begin
              mimens1:=5;
              mimens2:=1;
              if random(1000)>700 then mimens2:=2;
              if (PuntosA-6>PuntosB) and (random(1000)>800) then mimens2:=3;
              if (random(1000)>950) then mimens2:=3;
            end else if (mientenv3>7) then begin
              if random(1000)>((27-i)*50+(mientenv3-7)*320) then begin
                mimens1:=5;
                mimens2:=1;
              end;
            end else begin
              if (random(1000)>(27-i)*130+(mientenv3-3)*30) then begin
                mimens1:=5;
                mimens2:=1;
                if random(1000)>750 then mimens2:=2;
                if (PuntosA-6>PuntosB) and (random(1000)>800) then mimens2:=3;
                if (random(1000)>950) then mimens2:=3;
              end;
            end;
          end;
        end else begin
          if (i<20) and (random(1000)>920) and (PuntosA<MaxP-1) then begin
            if (mientenv1<>2) then begin
              mimens1:=5;
              mimens2:=1;
              if random(1000)>950 then mimens2:=3;
            end else if random(1000)>900 then begin
              mimens1:=5;
              mimens2:=3;
              if PuntosB+2>PuntosA then mimens2:=1;
              if random(1000)>950 then mimens2:=2;
            end;
          end;
          if (i>7) and (random(1000)>700) then begin
            mimens1:=5;
            mimens2:=1;
          end;
          if (i>24) and (random(1000)>170) then begin
            if (mientenv1<>2) or (random(1000)>500) then begin
              mimens1:=5;
              mimens2:=1;
              if random(1000)>920 then mimens2:=2;
            end;
          end;
          if (i>27) and (random(1000)>530) then begin
            if (mientenv1<>2) or (random(1000)>200) then begin
              mimens1:=5;
              mimens2:=2;
            end;
          end;
          if (i>=30-mientenv1) and (random(1000)>850) then begin
            mimens1:=5;
            mimens2:=3;
          end;
        end;
      end;
      if mimens1=5 then if (PuntosB=maxp-1) and (PuntosB-6>PuntosA) and (i>20) then begin
        mimens1:=5;
        mimens2:=3;
      end;
      if mimens1=5 then if (PuntosB=maxp-1) then begin
        mimens1:=5;
        mimens2:=3;
      end;
    end;
  end;
end;

procedure adivinacarta(htanto : integer; var pc1,pc2,posi : integer);
var a1,a2,a3 : integer;
    cr : array[1..3] of integer;
    b1,b2,b3 : integer;
function getpalo(c1 : integer) : integer;
begin
  getpalo:=((c1-1) div 10)+1;
end;
function getnro(c1 : integer) : integer;
begin
  getnro:=((c1-1) mod 10)+1;
end;
begin
  pc1:=0;
  pc2:=0;
  if florcant>0 then exit;
  a1:=0;
  if (genvi>=100) and (genvi<=199) then begin
    if htanto=gettanto(1) then a1:=1
    else if random(1000)>850 then begin
      htanto:=gettanto(1);
      a1:=1;
    end;
  end;
  if (genvi>=200) and (genvi<=299) then begin
    if manojug=1 then begin
      if htanto=gettanto(1) then a1:=1
      else if random(1000)>850 then begin
        htanto:=gettanto(1);
        a1:=1;
      end;
    end;
  end;
  if a1=0 then exit;
  cr[1]:=tabl[1,2]; cr[2]:=tabl[2,2]; cr[3]:=tabl[3,2];
  if cr[1]=0 then exit;
  if cr[3]>0 then exit;
  if cr[2]=0 then begin  { humano jugo 1 carta }
    a1:=getnro(cr[1]);
    if (a1>=8) then begin { es una figura }
      if (htanto>=20) and (htanto<=27) then begin
        b1:=htanto-20;
        if b1=0 then b1:=8;
        b2:=(getpalo(cr[1])-1)*10+b1;
        if b1=8 then for a3:=1 to 2 do begin
          if cr[1]=b2 then inc(b2)
          else begin
            b3:=b2;
            for a2:=1 to 3 do if b3=cart[a2,2] then inc(b2);
          end;
        end;
        pc1:=b2;
        posi:=2; { Posiblemente }
        exit;
      end;
    end else begin
      if htanto<20 then exit;
      if htanto=20 then begin
        pc1:=40; { es obvio que tiene 2 figuras }
        pc2:=39;
        posi:=3; { Seguro }
        exit;
      end;
      b1:=htanto-20;
      b2:=b1-a1;
      if (b2<0) or (b2>7) then exit;
      b3:=(getpalo(cr[1])-1)*10+b2;
      if b2=0 then begin
        b3:=b3+8;
        for a3:=1 to 2 do begin
          b2:=b3;
          for a2:=1 to 3 do if b2=cart[a2,2] then inc(b3);
        end;
      end;
      pc1:=b3;
      posi:=2;
    end;
    exit;
  end;  { sino humano jugo 2 cartas }
  a1:=getnro(cr[1]);
  if a1>7 then a1:=0;
  a2:=getnro(cr[2]);
  if a2>7 then a2:=0;
  if (htanto<20) then begin
    if a1=htanto then exit;
    if a2=htanto then exit;
    b1:=0;
    repeat
      inc(b1);
    until (getpalo(cr[1])<>b1) and (getpalo(cr[2])<>b1);
    b3:=(b1-1)*10+htanto;
    if htanto=0 then begin
      b3:=b3+8;
      pc1:=b3;
      posi:=2;
      exit;
    end;
    b2:=0;
    for a2:=1 to 3 do if b3=cart[a2,2] then b2:=1;
    if b2=1 then begin
      repeat
        inc(b1);
      until (getpalo(cr[1])<>b1) and (getpalo(cr[2])<>b1) or (b1>4);
      if (b1<5) then begin
        b3:=(b1-1)*10+htanto;
        b2:=0;
        for a2:=1 to 3 do if b3=cart[a2,2] then b2:=1;
        if b2=0 then begin
          pc1:=b3;
          posi:=3;
          exit;
        end;
      end;
    end;
    pc1:=b3;
    posi:=2;
    exit;
  end;
  if (htanto=20) then begin
    if (a1=0) and (a2=0) then exit;
    pc1:=39; { tiene una figura }
    posi:=3;
    exit;
  end;
  if getpalo(cr[1])=getpalo(cr[2]) then begin
    a3:=a1+a2+20;
    if a3=htanto then exit;
  end;  { => el tanto se forma con la 3ra carta (puede ser que tuviese flor) }
  b1:=htanto-20;
  b2:=b1-a1;
  b3:=b1-a2;
  a3:=0;
  if (b2>=0) and (b2<=7) then a3:=1;
  if (b3>=0) and (b3<=7) then a3:=2;
  if a3>0 then begin
    b3:=(getpalo(cr[a3])-1)*10+b2;
    if b2=0 then begin
      b3:=b3+8;
      for a3:=1 to 2 do begin
        b2:=b3;
        for a2:=1 to 3 do if b2=cart[a2,2] then inc(b3);
      end;
    end;
    pc1:=b3;
    posi:=3;
    exit;
  end;
end;

function checkcomputruco(perna : boolean) : integer;
{ Devuelve  0-No hace nada 1-Quiero 2-no quiero 3-Subir }
var a1,a2,a4,a5 : integer;
    xx,c1,c2,c3 : integer;
    pc1,pc2,posi : integer;
begin
  a1:=2;
  case mano of
    1 : begin
        c1:=GetValor(cart[1,2]);
        c2:=GetValor(cart[2,2]);
        c3:=GetValor(cart[3,2]);
        a2:=(c1+c2+c3) div 3;
        if a2<8+random(3+trunc(mientruc1*1.5)) then a1:=1;
        if a2<5 then a1:=1;
        if a1=1 then if random(100)>80 then a1:=3;
        end;
    2 : begin
        c1:=tabl[1,1];
        c2:=tabl[2,1];
        c3:=tabl[3,1];
        if tabl[2,2]=0 then begin
          if c1=0 then c1:=c3
          else if c2=0 then c2:=c3;
        end else begin
          if c2>0 then c1:=c2
          else if c3>0 then c1:=c3;
        end;
        c1:=getvalor(c1);
        c2:=getvalor(c2);
        case ganomano(tabl[1,3],tabl[1,2]) of
          0 : begin
              if tabl[2,3]=0 then begin
                if tabl[2,2]=0 then begin
                  if c2<c1 then c1:=c2;
                end else begin
                  c1:=getvalor(tabl[2,2]);
                end;
                if (c1<(6-trucocant1)) then a1:=1;
                if c1>2 then if random(15+(mientruc1*2))>c1 then a1:=1;
                if (c1<3) then a1:=3;
                adivinacarta(humcanto,pc1,pc2,posi);
                if pc1>0 then begin
                  a4:=0;
                  if pc2>0 then begin
                    if (getvalor(pc1)<c1) and (getvalor(pc2)<c1) then a4:=1;
                    if (getvalor(pc1)>c1) and (getvalor(pc2)>c1) and (posi>1) then a4:=2;
                  end else begin
                    if (getvalor(pc1)<c1) and (c1>5) then a4:=1;
                    if (getvalor(pc1)>c1) and (posi>1) then a4:=2;
                  end;
                  if (a4=1) then begin
                    if posi<2 then a4:=0;
                    if posi=2 then if random(1000)>500 then a4:=0;
                  end;
                  if (a4=1) then if (a1=1) and (random(1000)<740) then a1:=2;
                  if (a4=2) then if (a1=2) then a1:=1;
                end;
              end else begin
                if c2<c1 then c1:=c2;
                c2:=getvalor(tabl[2,3]);
                if (c1<c2) then a1:=3;
                if (c1=c2) then if random(10)>4 then a1:=3;
                if (c1>c2) then if (c2>5) then a1:=3;
              end;
              end;
          1 : begin
              if tabl[2,3]=0 then begin
                a2:=(c1+c2) div 2;
                if a2<7-(trucocant1 div 2)+random(2+(mientruc1*2)) then a1:=1;
                if a2<5 then begin
                  a1:=1;
                  if random(100)>80 then a1:=3;
                end;
                adivinacarta(humcanto,pc1,pc2,posi);
                a4:=0;
                if pc1>0 then if (getvalor(pc1)<4+random(2)) then a4:=1;
                if pc2>0 then if (getvalor(pc2)<4+random(2)) then a4:=1;
                if (a4=1) then begin
                  if posi<2 then a4:=0;
                  if posi=2 then if random(1000)>700 then a4:=0;
                end;
                if (a4=1) then if (a1=1) and (random(1000)<740) then a1:=2;
                if (a4=2) then if (a1=2) then a1:=1;
              end else begin
                a2:=0;
                if (c1<getvalor(tabl[2,3])) then inc(a2);
                if (c2<getvalor(tabl[2,3])) then inc(a2);
                if a2=2 then begin
                  a1:=1;
                  if (c2<4+random(4)) or (c1<4+random(4)) then a1:=3;
                end else if a2=1 then begin
                  a2:=c2;
                  if c1>=getvalor(tabl[2,3]) then a2:=c1; {a2=carta que no mata}
                  if a2<5+random(3+mientruc1) then a1:=1;
                  if a2<3+random(2+mientruc1) then a1:=3;
                end else begin
                  if (getvalor(tabl[2,3])>8) and (random(1000)>700) and (trucocant1<4) then a2:=3;
                end;
                adivinacarta(humcanto,pc1,pc2,posi);
                if pc1>0 then begin
                  a4:=0;
                  pc2:=c1;
                  if (c2<c1) then pc2:=c2;
                  if (getvalor(pc1)<pc2) then a4:=1;
                  if (a4=1) then begin
                    if posi<2 then a4:=0;
                    if posi=2 then if random(1000)>200 then a4:=0;
                  end;
                  if (a4=1) then if (a1=1) and (random(1000)<840) then a1:=2;
                end;
              end;
              end;
          2 : begin
              if tabl[2,2]=0 then begin
                a2:=c1; if c2<a2 then a2:=c2;
              end else begin
                a2:=tabl[1,1];
                if a2=0 then a2:=tabl[2,1];
                if a2=0 then a2:=tabl[3,1];
                a2:=getvalor(a2);
                if (getvalor(tabl[2,2])<a2) and (a2>9) and (random(100)>70-(10*mientruc1))
                  then a2:=getvalor(tabl[2,2]);
              end;
              if a2<6+random(3+trunc(mientruc1*1.5)) then a1:=1;
              if (a2<4) then a1:=1;
              if a1=1 then if (a2<3) then a1:=3;
              end;
        end;
        end;
    3 : begin
        c1:=tabl[1,1];
        if c1=0 then c1:=tabl[2,1];
        if c1=0 then c1:=tabl[3,1];
        if c1=0 then c1:=tabl[3,2]; { por si ya jugo }
        c1:=getvalor(c1);
        if tabl[3,3]>0 then begin
          c2:=c1;
          c1:=getvalor(tabl[3,3]);
          a5:=0;
          if ((genvi>=200) and (genvi<300)) or (genvi>=400) then a5:=1;
          if (genvi>=100) and (genvi<200) and (manojug=2) then a5:=1;
          if c2<c1 then begin
            a1:=1;
            if perna then a1:=3;
            if random(100)>20 then a1:=3;
          end else if c2>c1 then begin
            if (a5=0) and (c1>7) and (random(100)>70-(mientruc1*16)) and (trucocant1<>4) then a1:=3;
          end else if c1=c2 then begin
            if ManoJug=1 then begin
              if (a5=0) and (c1>7) and (random(100)>70-(mientruc1*16)) and (trucocant1<>4) then a1:=3;
            end else begin
              a1:=1;
              if perna then a1:=3;
            end;
          end;
        end else begin
          if (c1<6) then a1:=1;
          if (c1<8+(trucocant1 div 2)-(mientruc1*2)) and (c1>5) then
            if random(100)>60-(mientruc1*16) then a1:=1;
          if c1=8 then if random(100)>90 then a1:=1;
          a5:=0;
          if ((genvi>=200) and (genvi<300)) or (genvi>=400) then a5:=1;
          if (genvi>=100) and (genvi<200) and (manojug=2) then a5:=1;
          if (perna) and (c1>5) and (random(1000)>950) and (a5=0) then a1:=3;
          if (c1<3) then begin
            if perna then a1:=3 else a1:=1;
          end;
          a4:=0;
          adivinacarta(humcanto,pc1,pc2,posi);
          if pc1>0 then begin
            if (getvalor(pc1)<4+random(2)) then a4:=1;
            if getvalor(pc1)<c1 then a4:=1;
            if (getvalor(pc1)>c1) then a4:=2;
          end;
          if (a4=1) then begin
            if posi<2 then a4:=0;
            if posi=2 then if random(1000)>700 then a4:=0;
          end;
          if (a4=1) then if (a1=1) and (random(1000)<740) then a1:=2;
          if (a4=2) then if (a1=2) then a1:=1;
        end;
        end;
  end;
  if (a1=2) then begin
    xx:=0;
    if (genvi>100) and (genvi<200) then xx:=genvi-100;
    if florcant=0 then if humcanto<>gettanto(1) then xx:=0;
    if PuntosA>((MaxP-2)-xx) then a1:=3;
  end;
  if a1=3 then if trucocant1=4 then a1:=1;
  if perna then begin
    if (mano=1) and (random(100)>40) and (a1<>3) then a1:=0;
    if (mano=2) and (random(100)>95) and (a1<>3) then a1:=0;
    if (mano=3) and (random(100)>97) and (a1<>3) then a1:=0;
  end;
  if a1=2 then truflag1:=1;
  checkcomputruco:=a1;
end;

procedure CompuCantaTruco;
var a1,a2 : integer;
begin
  a1:=checkcomputruco(True);
  if a1=2 then truflag1:=0;
  a2:=0;
  if (a1=1) then if trucocant1=3 then a1:=0;
  if (a1=3) or ((a1=1) and (random(100)>40)) then begin
    case mano of
      1 : if random(100)>50 then a2:=1;
      2 : if (random(100)>24) or (a1=3) then a2:=1;
      3 : if (random(100)>10) or (a1=3) then a2:=1;
    end;
  end;
  if trucocant1=4 then a2:=0;
  if trucocant3=2 then a2:=0;
  if a2=1 then mimens1:=11;
end;

function checkiffinal : boolean;
var pa,pb : integer;
begin
  checkiffinal:=false;
  pa:=PuntosA;
  pb:=PuntosB;
  if (genvi>=100) and (genvi<200) then begin
    if florcant=0 then begin
      if gettanto(1)=humcanto then pa:=pa+(genvi-100);
    end;
    if florcant=1 then begin
      if getflor(1)>0 then pa:=pa+(genvi-100);
    end;
  end;
  if (genvi>=200) and (genvi<300) then begin
    pb:=pb+(genvi-200);
  end;
  if (pa>=MaxP) or (pb>=MaxP) then checkiffinal:=true;
end;

begin
  if mimens1=1 then begin  { Comienza la mano }
    JuegaJug:=ManoJug;
    muesflag1:=0;
    truflag1:=0;
    for i:=1 to 3 do for j:=1 to 4 do tabl[i,j]:=0;
    for i:=1 to 3 do begin
      repeat
        j:=random(40)+1;
        if i>1 then for k:=1 to i-1 do if tabl[k,1]=j then j:=0;
        if i>1 then for k:=1 to i-1 do if tabl[k,4]=j then j:=0;
      until j<>0;
      tabl[i,1]:=j;
      repeat
        j:=random(40)+1;
        for k:=1 to i do if tabl[k,1]=j then j:=0;
        if i>1 then for k:=1 to i-1 do if tabl[k,4]=j then j:=0;
      until j<>0;
      tabl[i,4]:=j;
    end;
    for i:=1 to 3 do cart[i,1]:=tabl[i,4];
    for i:=1 to 3 do cart[i,2]:=tabl[i,1];
    env^.enable; realenv^.enable; faltaenv^.enable;
    truco^.enable;  carta1^.enable;  carta2^.enable;
    carta3^.enable; if cflor then flor^.enable else flor^.disable;
    mazo^.enable; quiero^.disable; noquiero^.disable;
    vale4^.disable; retruco^.disable;
    envcant1:=0;  envcant2:=0;
    trucocant1:=1; trucocant2:=1; trucocant3:=0;
    florcant:=0; humcanto:=0;
    enque:=0;
    extr4:=0;
    extr5:=0;
    genvi:=0; gtruc:=0;
    mientenv4:=0;
    ewin.top:=0; ewin.bottom:=480; ewin.left:=0; ewin.right:=250;
    InvalidateRect(HWindow, @ewin, True);
    if PuntosA+PuntosB=0 then begin
      ewin.top:=0; ewin.bottom:=250; ewin.left:=250; ewin.right:=630;
      InvalidateRect(HWindow, @ewin, True);
    end;
    updatewindow(hwindow);
    if juegajug=2 then mimens1:=3;
    if juegajug=2 then PostMessage(HWindow, wm_Command, cm_action, 0);
    mano:=1;
    exit;
  end;
  if mimens1=2 then begin  { Juega humano }
    env^.disable;
    realenv^.disable;
    faltaenv^.disable;
    flor^.disable;
    tabl[mano,3]:=tabl[mimens2,4];
    tabl[mimens2,4]:=0;
    ewin.top:=333; ewin.bottom:=440; ewin.left:=(mimens2-1)*75+20; ewin.right:=mimens2*75+17;
    InvalidateRect(HWindow, @ewin, True);
    ewin.top:=223; ewin.bottom:=330; ewin.left:=(mano-1)*75+20; ewin.right:=mano*75+17;
    InvalidateRect(HWindow, @ewin, True);
    updatewindow(hwindow);
    cartajugada;
    exit;
  end;
  if mimens1=3 then begin  { Juega compu }
    CompuCantaTanto;
    if mimens1=3 then CompuCantaTruco;
    if mimens1<>3 then begin
      PostMessage(HWindow, wm_Command, cm_action, 0);
      exit;
    end;
    c1:=getvalor(cart[1,2]);
    c2:=getvalor(cart[2,2]);
    c3:=getvalor(cart[3,2]);
    if tabl[1,1]=0 then c1:=0;
    if tabl[2,1]=0 then c2:=0;
    if tabl[3,1]=0 then c3:=0;
    case mano of
      1 : begin
            if tabl[1,3]=0 then begin
              i:=1;
              if random(100)>70 then begin
                if (c1>=c2) and (c1<=c3) then i:=1;
                if (c2>=c1) and (c2<=c3) then i:=2;
                if (c3>=c2) and (c3<=c1) then i:=3;
              end else begin
                j:=c1;
                if c2>j then i:=2;
                if c2>j then j:=c2;
                if c3>j then i:=3;
              end;
            end else begin
              i:=0;  { Humano ya jugó 1ra }
              j:=0;
              if (c1<getvalor(tabl[1,3])) and (c1>j) then begin
                i:=1;
                j:=c1;
              end;
              if (c2<getvalor(tabl[1,3])) and (c2>j) then begin
                i:=2;
                j:=c2;
              end;
              if (c3<getvalor(tabl[1,3])) and (c3>j) then i:=3;
              if (i>0) then begin { Emparda si conviene }
                k:=0;
                if (c1=getvalor(tabl[1,3])) then k:=1;
                if (c2=getvalor(tabl[1,3])) then k:=2;
                if (c3=getvalor(tabl[1,3])) then k:=3;
                if k>0 then begin
                  case k of
                    1 : begin
                        l:=getvalor(tabl[2,1]);
                        m:=getvalor(tabl[3,1]);
                        end;
                    2 : begin
                        l:=getvalor(tabl[1,1]);
                        m:=getvalor(tabl[3,1]);
                        end;
                    3 : begin
                        l:=getvalor(tabl[1,1]);
                        m:=getvalor(tabl[2,1]);
                        end;
                  end;
                  if (l>m) then begin
                    n:=m; m:=l; l:=n;
                  end;      { l=mayor m=menor carta }
                  n:=0;
                  if l<getvalor(tabl[1,3]) then inc(n);
                  if m<getvalor(tabl[1,3]) then inc(n);
                  if ((n=1) and (random(100)>10)) then i:=k;
                end;
              end;
              if (i>0) then begin
                j:=getvalor(tabl[i,1]);
                k:=getvalor(tabl[1,3]);
                if (abs(j-k)>3+random(2)) then if (k>10) then i:=0;
              end;
              if random(1000)>985 then i:=0;
              if i=0 then begin
                i:=1;
                j:=c1;
                if c2>j then i:=2;
                if c2>j then j:=c2;
                if c3>j then i:=3;
              end;
            end;
          end;
      2 : begin
            case ganomano(tabl[1,3],tabl[1,2]) of
              0 : begin
                  i:=1;
                  if c1=0 then c1:=20;
                  if c2=0 then c2:=20;
                  if c3=0 then c3:=20;
                  j:=c1;
                  if c2<j then i:=2;
                  if c2<j then j:=c2;
                  if c3<j then i:=3;
                  end;
              1 : begin { Supuestamente el humano ya jugo }
                    i:=0;
                    j:=0;
                    if (c1<getvalor(tabl[2,3])) and (c1>j) then begin
                      i:=1;
                      j:=c1;
                    end;
                    if (c2<getvalor(tabl[2,3])) and (c2>j) then begin
                      i:=2;
                      j:=c2;
                    end;
                    if (c3<GetValor(tabl[2,3])) and (c3>j) then begin
                      i:=3;
                      j:=c3;
                    end;
                    if i=0 then begin
                      i:=1;
                      j:=c1;
                      if c2>j then i:=2;
                      if c2>j then j:=c2;
                      if c3>j then i:=3;
                    end;
                  end;
              2 : begin { Supuestamente juega primero la Compu }
                    if c1=0 then begin
                      i:=2;
                      if c3>c2 then i:=3;
                      if random(100)>90 then begin
                        if i=2 then i:=3 else i:=2;
                      end;
                    end;
                    if c2=0 then begin
                      i:=1;
                      if c3>c1 then i:=3;
                      if random(100)>90 then begin
                        if i=1 then i:=3 else i:=1;
                      end;
                    end;
                    if c3=0 then begin
                      i:=1;
                      if c2>c1 then i:=2;
                      if random(100)>90 then begin
                        if i=1 then i:=2 else i:=1;
                      end;
                    end;
                  end;
            end;
          end;
      3 : begin
            i:=1;
            if c2<>0 then i:=2;
            if c3<>0 then i:=3;
          end;
    end;
    tabl[mano,2]:=tabl[i,1];
    tabl[i,1]:=0;
    if (mano=2) and (tabl[2,3]>0) then begin
      c1:=tabl[2,3];
      c2:=tabl[2,2];
      if ganomano(c1,c2)=2 then begin
        c1:=tabl[1,3];
        c2:=tabl[1,2];
        if ganomano(c1,c2)<>1 then if random(100)>40 then playcompuvoice(16,2);
      end;
    end;
    if (mano=3) and (tabl[3,3]>0) then begin
      c1:=tabl[3,3];
      c2:=tabl[3,2];
      if ganomano(c1,c2)=2 then if random(100)>40 then playcompuvoice(16,2);
      if ganomano(c1,c2)=0 then begin
        c1:=tabl[1,3];
        c2:=tabl[1,2];
        if ganomano(c1,c2)=2 then if random(100)>40 then playcompuvoice(16,2);
      end;
    end;
    ewin.top:=0; ewin.bottom:=110; ewin.left:=(i-1)*75+20; ewin.right:=i*75+17;
    InvalidateRect(HWindow, @ewin, True);
    ewin.top:=113; ewin.bottom:=220; ewin.left:=(mano-1)*75+20; ewin.right:=mano*75+17;
    InvalidateRect(HWindow, @ewin, True);
    updatewindow(hwindow);
    cartajugada;
    exit;
  end;
  if mimens1=4 then begin  { Hum-envido }
    if (trucocant1>1) then begin
      dec(trucocant2);  { En caso de 'el envido esta primero' }
      dec(trucocant1);
      trucocant3:=0;
      if trucocant2<1 then trucocant2:=1;
      retruco^.disable;
      truco^.disable;
      vale4^.disable;
    end;
    truco^.disable;
    carta1^.disable;
    carta2^.disable;
    carta3^.disable;
    flor^.disable;
    if envcant1=0 then begin
      if (gettanto(2)>24) and (tabl[1,3]=0) then mientenv4:=1;
      envcant1:=0;
      envcant2:=1;
    end else begin
      envcant2:=envcant1;
      if (gettanto(2)>26) and (tabl[1,2]>0) then mientenv4:=2;
    end;
    case mimens2 of
      1 : begin
          envcant1:=envcant1+2;
          inc(extr4);
          end;
      2 : begin
          envcant1:=envcant1+3;
          env^.disable;
          inc(extr5);
          end;
      3 : begin
          envcant1:=250;
          env^.disable;
          realenv^.disable;
          faltaenv^.disable;
          end;
    end;
    i:=checkcomputanto(mimens2);
    if i=2 then begin { no quiero }
      CompuMessage('No Quiero');
      PlayCompuVoice(7,0);
      env^.disable;
      realenv^.disable;
      faltaenv^.disable;
      quiero^.disable;
      noquiero^.disable;
      flor^.disable;
      truco^.enable;
      if tabl[1,4]>0 then carta1^.enable;
      if tabl[2,4]>0 then carta2^.enable;
      if tabl[3,4]>0 then carta3^.enable;
      genvi:=100+envcant2;
      humcanto:=gettanto(1);
      enque:=0;
      if checkiffinal then begin
        finalderonda;
        exit;
      end;
      if juegajug=2 then begin
        mimens1:=3;
        PostMessage(HWindow, wm_Command, cm_action, 0);
      end;
      exit;
    end;
    if i=1 then begin
      CompuMessage('Quiero');
      PlayCompuVoice(6,0);
      env^.disable;
      realenv^.disable;
      faltaenv^.disable;
      quiero^.disable;
      noquiero^.disable;
      flor^.disable;
      truco^.enable;
      if tabl[1,4]>0 then carta1^.enable;
      if tabl[2,4]>0 then carta2^.enable;
      if tabl[3,4]>0 then carta3^.enable;
      j:=1;
      CantoTanto(ManoJug, c1,c2);
      humcanto:=c1;
      if c1<c2 then j:=2;
      if c1=c2 then j:=ManoJug;
      if envcant1=250 then begin
        if j=1 then begin
          Genvi:=100+(MaxP-PuntosB);
        end else begin
          Genvi:=200+(MaxP-PuntosA);
        end;
      end else genvi:=j*100+envcant1;
      enque:=0;
      if checkiffinal then begin
        finalderonda;
        exit;
      end;
      if juegajug=2 then begin
        mimens1:=3;
        PostMessage(HWindow, wm_Command, cm_action, 0);
      end;
      exit;
    end;
    if (i=3) or (i=4) or (i=5) then begin { re-envido }
      if i=3 then inc(extr4);
      if i=4 then inc(extr5);
      case i of
        3 : s:='Envido';
        4 : s:='Real Envido';
        5 : s:='Falta Envido';
      end;
      CompuMessage(s);
      case i of
        3 : PlayCompuVoice(0,0);
        4 : PlayCompuVoice(1,0);
        5 : PlayCompuVoice(2,0);
      end;
      env^.disable;
      realenv^.enable;
      faltaenv^.enable;
      quiero^.enable;
      noquiero^.enable;
      enque:=1;
      flor^.disable;
      envcant2:=envcant1;
      case i of
        3 : envcant1:=envcant1+2;
        4 : begin
            envcant1:=envcant1+3;
            if extr5>1 then realenv^.disable;
            end;
        5 : begin
            envcant1:=250;
            realenv^.disable;
            faltaenv^.disable;
            end;
      end;
    end;
    if (i=6) then begin
      env^.disable;
      realenv^.disable;
      faltaenv^.disable;
      truco^.enable;
      if tabl[1,4]>0 then carta1^.enable;
      if tabl[2,4]>0 then carta2^.enable;
      if tabl[3,4]>0 then carta3^.enable;
      CompuMessage('Flor por atrevido');
      PlayCompuVoice(11,0);
      muesflag1:=2;
      enque:=0;
      genvi:=203;
      envcant1:=10;
      florcant:=2;
      if checkiffinal then begin
        finalderonda;
        exit;
      end;
      if juegajug=2 then begin
        mimens1:=3;
        PostMessage(HWindow, wm_Command, cm_action, 0);
      end;
      exit;
    end;
    exit;
  end;
  if mimens1=5 then begin  { Compu-envido }
    case mimens2 of
      1 : inc(extr4);
      2 : inc(extr5);
    end;
    carta1^.disable;
    carta2^.disable;
    carta3^.disable;
    case mimens2 of
      1 : s:='Envido';
      2 : s:='Real Envido';
      3 : s:='Falta Envido';
    end;
    CompuMessage(s);
    case mimens2 of
      1 : PlayCompuVoice(0,0);
      2 : PlayCompuVoice(1,0);
      3 : PlayCompuVoice(2,0);
    end;
    env^.enable;
    realenv^.enable;
    faltaenv^.enable;
    quiero^.enable;
    noquiero^.enable;
    enque:=1;
    truco^.disable;
    if envcant1=0 then begin
      envcant1:=0;
      envcant2:=1;
    end else envcant2:=envcant1;
    case mimens2 of
      1 : envcant1:=envcant1+2;
      2 : begin
          envcant1:=envcant1+3;
          env^.disable;
          if extr5>1 then realenv^.disable;
          end;
      3 : begin
          envcant1:=250;
          env^.disable;
          realenv^.disable;
          faltaenv^.disable;
          end;
    end;
    exit;
  end;
  if mimens1=6 then begin  { Hum-quiero }
    if enque=1 then begin
      env^.disable;
      realenv^.disable;
      faltaenv^.disable;
      quiero^.disable;
      noquiero^.disable;
      flor^.disable;
      truco^.enable;
      if tabl[1,4]>0 then carta1^.enable;
      if tabl[2,4]>0 then carta2^.enable;
      if tabl[3,4]>0 then carta3^.enable;
      j:=1;
      CantoTanto(ManoJug, c1,c2);
      humcanto:=c1;
      if c1<c2 then j:=2;
      if c1=c2 then j:=ManoJug;
      if envcant1=250 then begin
        if j=1 then begin
          Genvi:=100+(MaxP-PuntosB);
        end else begin
          Genvi:=200+(MaxP-PuntosA);
        end;
      end else genvi:=j*100+envcant1;
      if checkiffinal then begin
        finalderonda;
        exit;
      end;
      if juegajug=2 then begin
        mimens1:=3;
        PostMessage(HWindow, wm_Command, cm_action, 0);
      end;
      enque:=0;
      exit;
    end;
    if enque=2 then begin
      genvi:=400;
      envcant1:=10;
      enque:=0;
      finalderonda;
      exit;
    end;
    if enque=3 then begin
      if envcant1=0 then envcant1:=10;
      env^.disable;
      realenv^.disable;
      faltaenv^.disable;
      flor^.disable;
      quiero^.disable;
      noquiero^.disable;
      trucocant3:=2;
      if tabl[1,4]>0 then carta1^.enable;
      if tabl[2,4]>0 then carta2^.enable;
      if tabl[3,4]>0 then carta3^.enable;
      if juegajug=2 then begin
        mimens1:=3;
        PostMessage(HWindow, wm_Command, cm_action, 0);
      end;
      enque:=0;
    end;
    exit;
  end;
  if mimens1=7 then begin  { Hum-No quiero }
    if enque=1 then begin
      env^.disable;
      realenv^.disable;
      faltaenv^.disable;
      quiero^.disable;
      noquiero^.disable;
      flor^.disable;
      truco^.enable;
      if tabl[1,4]>0 then carta1^.enable;
      if tabl[2,4]>0 then carta2^.enable;
      if tabl[3,4]>0 then carta3^.enable;
      humcanto:=gettanto(1);
      genvi:=200+envcant2;
      if checkiffinal then begin
        finalderonda;
        exit;
      end;
      if juegajug=2 then begin
        mimens1:=3;
        PostMessage(HWindow, wm_Command, cm_action, 0);
      end;
      enque:=0;
      exit;
    end;
    if enque=2 then begin
      genvi:=204;
      envcant1:=10;
      florcant:=2;
      quiero^.disable;
      noquiero^.disable;
      flor^.disable;
      truco^.enable;
      if tabl[1,4]>0 then carta1^.enable;
      if tabl[2,4]>0 then carta2^.enable;
      if tabl[3,4]>0 then carta3^.enable;
      if checkiffinal then begin
        finalderonda;
        exit;
      end;
      if juegajug=2 then begin
        mimens1:=3;
        PostMessage(HWindow, wm_Command, cm_action, 0);
      end;
      enque:=0;
      exit;
    end;
    if enque=3 then begin
      Gtruc:=200+trucocant2;
      enque:=0;
      finalderonda;
      exit;
    end;
    exit;
  end;
  if mimens1=8 then begin  { Hum-Flor }
    if enque=1 then begin
      env^.disable;
      realenv^.disable;
      faltaenv^.disable;
      quiero^.disable;
      noquiero^.disable;
      flor^.disable;
      truco^.enable;
      if tabl[1,4]>0 then carta1^.enable;
      if tabl[2,4]>0 then carta2^.enable;
      if tabl[3,4]>0 then carta3^.enable;
      i:=0;
    end else begin
      env^.disable;
      realenv^.disable;
      faltaenv^.disable;
      flor^.disable;
      i:=getflor(2);
    end;
    if i>0 then begin
      if i>36-random(5) then begin
        muesflag1:=2;
        CompuMessage('Contraflor al juego');
        playcompuvoice(12,0);
        truco^.disable;
        quiero^.enable; noquiero^.enable;
        carta1^.disable; carta2^.disable; carta3^.disable;
        enque:=2;
        exit;
      end else if i<23 then begin
        CompuMessage('Con flor me achico');
        playcompuvoice(13,0);
        genvi:=104;
        envcant1:=10;
        florcant:=1;
        if checkiffinal then begin
          finalderonda;
          exit;
        end;
        if juegajug=2 then begin
          mimens1:=3;
          PostMessage(HWindow, wm_Command, cm_action, 0);
        end;
        enque:=0;
        exit;
      end else begin
        muesflag1:=2;
        CompuMessage('Con flor juego');
        playcompuvoice(10,0);
        genvi:=300;
        envcant1:=10;
        florcant:=3;
        if juegajug=2 then begin
          mimens1:=3;
          PostMessage(HWindow, wm_Command, cm_action, 0);
        end;
        enque:=0;
        exit;
      end;
    end else begin
      if (trucocant1>1) then begin
        dec(trucocant2);  { En caso de 'la flor esta primero' }
        dec(trucocant1);
        trucocant3:=0;
        if trucocant2<1 then trucocant2:=1;
        retruco^.disable;
        vale4^.disable;
        truco^.enable;
        noquiero^.disable;
        quiero^.disable;
        if tabl[1,4]>0 then carta1^.enable;
        if tabl[2,4]>0 then carta2^.enable;
        if tabl[3,4]>0 then carta3^.enable;
      end;
      CompuMessage('¡Hasta aquí llegó el olor!');
      playcompuvoice(16,3);
      genvi:=103;
      envcant1:=10;
      florcant:=1;
      if checkiffinal then begin
        finalderonda;
        exit;
      end;
      if juegajug=2 then begin
        mimens1:=3;
        PostMessage(HWindow, wm_Command, cm_action, 0);
      end;
      exit;
    end;
    exit;
  end;
  if mimens1=9 then begin  { Compu-Flor }
    env^.disable;
    realenv^.disable;
    faltaenv^.disable;
    flor^.disable;
    Extra:=0;
    if tabl[1,3]>0 then begin
      CompuMessage('Flor');
      PlayCompuVoice(10,0);
      muesflag1:=2;
      genvi:=203;
      envcant1:=10;
      florcant:=2;
      if checkiffinal then begin
        finalderonda;
        exit;
      end;
    end else begin
      PlayCompuVoice(10,0);
      muesflag1:=2;
      Application^.ExecDialog(New(PCompuflorDialog, Init(@Self, 'COMPUFLOR')));
      case Extra of
        1 : begin
            genvi:=300;
            envcant1:=10;
            florcant:=2;
            enque:=0;
            end;
        2 : begin
            florcant:=0;
            i:=getflor(2);
            if i>34-random(5) then florcant:=1;
            if florcant=1 then begin
              CompuMessage('Quiero');
              PlayCompuVoice(6,0);
              genvi:=400;
              envcant1:=10;
              florcant:=2;
              enque:=0;
              finalderonda;
              exit;
            end else begin
              CompuMessage('No Quiero');
              PlayCompuVoice(7,0);
              genvi:=104;
              envcant1:=10;
              florcant:=1;
              if checkiffinal then begin
                finalderonda;
                exit;
              end;
              enque:=0;
            end;
            end;
        3 : begin
            genvi:=204;
            envcant1:=10;
            florcant:=2;
            if checkiffinal then begin
              finalderonda;
              exit;
            end;
            enque:=0;
            end;
        4 : begin
            genvi:=203;
            envcant1:=10;
            florcant:=2;
            if checkiffinal then begin
              finalderonda;
              exit;
            end;
            enque:=0;
            end;
      end;
    end;
    if juegajug=2 then begin
      mimens1:=3;
      PostMessage(HWindow, wm_Command, cm_action, 0);
    end;
    exit;
  end;
  if mimens1=10 then begin { Hum-Truco }
    if (mimens2>1) then if envcant1=0 then envcant1:=10;
    if tabl[1,2]=0 then Compucantatanto; { si compu no jugó }
    if mimens1<>10 then begin
      PostMessage(HWindow, wm_Command, cm_action, 0);
      exit;
    end;
    trucocant2:=trucocant1;
    inc(trucocant1);
    if envcant1=0 then envcant1:=10;
    i:=checkcomputruco(false);
    if i=3 then if trucocant1>3 then i:=1;
    if i=1 then begin
      CompuMessage('Quiero');
      PlayCompuVoice(6,0);
      env^.disable;
      realenv^.disable;
      faltaenv^.disable;
      flor^.disable;
      truco^.disable;
      retruco^.disable;
      vale4^.disable;
      trucocant3:=1;
      quiero^.disable;
      noquiero^.disable;
      if tabl[1,4]>0 then carta1^.enable;
      if tabl[2,4]>0 then carta2^.enable;
      if tabl[3,4]>0 then carta3^.enable;
      if juegajug=2 then begin
        mimens1:=3;
        PostMessage(HWindow, wm_Command, cm_action, 0);
      end;
      enque:=0;
      exit;
    end;
    if i=2 then begin
      CompuMessage('No Quiero');
      PlayCompuVoice(7,0);
      Gtruc:=100+trucocant2;
      finalderonda;
      enque:=0;
      exit;
    end;
    if i=3 then begin
      carta1^.disable;
      carta2^.disable;
      carta3^.disable;
      env^.disable;
      realenv^.disable;
      faltaenv^.disable;
      flor^.disable;
      quiero^.enable;
      noquiero^.enable;
      truco^.disable;
      retruco^.disable;
      vale4^.disable;
      trucocant2:=trucocant1;
      inc(trucocant1);
      trucocant3:=2;
      case trucocant1 of
        3 : begin
            vale4^.enable;
            CompuMessage('Quiero retruco');
            PlayCompuVoice(4,0);
            end;
        4 : begin
            CompuMessage('Quiero vale 4');
            PlayCompuVoice(5,0);
            end;
      end;
    end;
    exit;
  end;
  if mimens1=11 then begin  { Compu-Truco }
    carta1^.disable;
    carta2^.disable;
    carta3^.disable;
    trucocant2:=trucocant1;
    inc(trucocant1);
    case trucocant1 of
      2 : s:='Truco';
      3 : s:='Quiero Retruco';
      4 : s:='Quiero Vale 4';
    end;
    CompuMessage(s);
    case trucocant1 of
      2 : PlayCompuVoice(3,0);
      3 : PlayCompuVoice(4,0);
      4 : PlayCompuVoice(5,0);
    end;
    quiero^.enable;
    noquiero^.enable;
    enque:=3;
    truco^.disable;
    retruco^.disable;
    vale4^.disable;
    case trucocant1 of
      2 : retruco^.enable;
      3 : vale4^.enable;
    end;
    exit;
  end;
  if mimens1=12 then begin { Hum-Mazo }
    if enque=1 then begin
      humcanto:=gettanto(1);
      genvi:=200+envcant2;
      gtruc:=200+trucocant2;
      finalderonda;
      exit;
    end;
    if enque=2 then begin
      genvi:=204;
      envcant1:=10;
      florcant:=2;
      gtruc:=200+trucocant2;
      finalderonda;
      exit;
    end;
    if enque=3 then begin
      gtruc:=200+trucocant2;
      finalderonda;
      exit;
    end;
    if (tabl[1,2]=0) and (genvi<40) then begin
      humcanto:=gettanto(1);
      genvi:=201;
    end;
    gtruc:=200+trucocant1;
    finalderonda;
    exit;
  end;
end;

procedure TTrucoWindow.WMtimer(var Msg: TMessage);
begin
  if SplashTM=0 then SPWin:=Application^.MakeWindow(New(PSplashWindow, Init));
  if SplashTM<35 then inc(SplashTM);
  if SplashTM=32 then begin
    Dispose(SPWin,done);
    SPWin:=nil;
  end;
end;

procedure TTrucoApp.InitMainWindow;
begin
  MainWindow:=New(PTrucoWindow, Init(nil, Application^.Name));
  HAccTable:=LoadAccelerators(HInstance, 'TACCEL');
end;

procedure TTrucoApp.Error(ErrorCode : integer);
var x1 : string;
    x2 : array[0..240] of char;
    x3 : array[0..8] of char;
begin
  str(ErrorCode, x1);
  strpcopy(x3, x1);
  strcopy(x2, 'Error en aplicación: ');
  strcat(x2, x3);
  strcat(x2, '. El programa fue modificado o existe una falla en el sistema.');
  messagebox(0, x2, 'Truco para Windows', mb_iconstop or mb_ok);
  postappmessage(GetCurrentTask, wm_quit,0,0);
end;

destructor TTrucoApp.Done;
var ubi : hwnd;
begin
  ubi:=FindWindow('WinMOD',nil);
  if ubi<>0 then postmessage(ubi, wm_Quit,0,0);
  inherited Done;
end;

constructor TSplashWindow.Init;
var ewin : hwnd;
    pwin : trect;
    a1,a2 : integer;
begin
  inherited Init(nil, '');
  attr.style:=ws_Popup or ws_Overlapped or ws_border or ws_Visible;
  ewin:=getdesktopwindow;
  getwindowrect(ewin, pwin);
  a1:=((pwin.right-pwin.left) div 2)-320;
  a2:=((pwin.bottom-pwin.top) div 2)-240;
  setcursorpos(a1+320,a2+240);
  if a1<0 then a1:=0;
  if a2<0 then a2:=0;
  attr.x:=a1; attr.y:=a2; attr.w:=640; attr.h:=480;
end;

destructor TSplashWindow.Done;
begin
  inherited Done;
  SPWin:=nil;
end;

procedure TSPlashWindow.Paint(PaintDC: HDC; var PaintInfo: TPaintStruct);
var DC, MemDC: HDC;
    TheFont : HFont;
    ThePen : HPen;
    bkm,tal : integer;
    last,last1 : thandle;
    ALogFont : TLogFont;
    BM: HBitmap;
    r : trect;
begin
  inherited Paint(PaintDC, PaintInfo);
  r.left:=0; r.top:=0;
  r.right:=r.left+640; r.bottom:=r.top+480;
  DC:=PaintDC;
  MemDC:=CreateCompatibleDC(DC);
  last:=SelectObject(DC, GetStockObject(LtGray_Brush));
  Rectangle(DC, r.left,r.top, r.right,r.bottom);
  SelectObject(DC, GetStockObject(White_Pen));
  MoveTo(DC,r.left+1,r.bottom-1);
  LineTo(DC,r.left+1,r.top+1);
  LineTo(DC,r.right-1,r.top+1);
  MoveTo(DC,r.left+2,r.bottom-2);
  LineTo(DC,r.left+2,r.top+2);
  LineTo(DC,r.right-2,r.top+2);
  MoveTo(DC,r.left+10,r.bottom-10);
  LineTo(DC,r.right-10,r.bottom-10);
  LineTo(DC,r.right-10,r.top+10);
  MoveTo(DC,r.left+11,r.bottom-11);
  LineTo(DC,r.right-11,r.bottom-11);
  LineTo(DC,r.right-11,r.top+11);
  Thepen:=createpen(ps_solid,1,rgb(60,60,60));
  SelectObject(DC, thepen);
  MoveTo(DC,r.left+1,r.bottom-1);
  LineTo(DC,r.right-1,r.bottom-1);
  LineTo(DC,r.right-1,r.top+1);
  MoveTo(DC,r.left+2,r.bottom-2);
  LineTo(DC,r.right-2,r.bottom-2);
  LineTo(DC,r.right-2,r.top+2);
  MoveTo(DC,r.left+10,r.bottom-10);
  LineTo(DC,r.left+10,r.top+10);
  LineTo(DC,r.right-10,r.top+10);
  MoveTo(DC,r.left+11,r.bottom-11);
  LineTo(DC,r.left+11,r.top+11);
  LineTo(DC,r.right-11,r.top+11);
  selectobject(DC, GetStockObject(black_pen));
  if thepen<>0 then DeleteObject(ThePen);
  bkm:=getbkmode(DC);
  setbkmode(DC, transparent);
  FillChar(ALogFont, SizeOf(TLogFont), #0);
  with ALogFont do begin
    lfEscapement    := 0;
    lfHeight        := 60;     {Make a large font                 }
    lfWeight        := 700;    {Indicate a Bold attribute         }
    lfItalic        := 0;      {Non-zero value indicates italic   }
    lfUnderline     := 1;      {Non-zero value indicates underline}
    lfOutPrecision  := Out_Stroke_Precis;
    lfClipPrecision := Clip_Stroke_Precis;
    lfQuality       := Default_Quality;
    lfPitchAndFamily:= Variable_Pitch;
    StrCopy(lfFaceName, 'Arial Bold');
  end;
  TheFont := CreateFontIndirect(ALogFont);
  SelectObject(DC, TheFont);
  tal:=gettextalign(DC);
  settextalign(DC,ta_top or ta_center or ta_noupdatecp);
  SetTextColor(DC, RGB(0,0,0));
  TextOut(DC, r.left+322, r.top+42, 'Truco para Windows V'+TrucoVersion, 23);
  SetTextColor(DC, RGB(0,238,0));
  TextOut(DC, r.left+320, r.top+40, 'Truco para Windows V'+TrucoVersion, 23);
  selectobject(DC, GetStockObject(system_font));
  if TheFont<>0 then deleteobject(thefont);
  ALogFont.lfHeight:=24;
  TheFont := CreateFontIndirect(ALogFont);
  SelectObject(DC, TheFont);
  SetTextColor(DC, RGB(0,0,0));
  TextOut(DC, r.left+320, r.top+265, 'Por Mauro H. Leggieri', 21);
  selectobject(DC, GetStockObject(system_font));
  if TheFont<>0 then deleteobject(thefont);
  setbkmode(DC, bkm);
  BM:=LoadBitmap(HInstance, 'AUTOR2');
  last1:=SelectObject(MemDC, BM);
  BitBlt(DC, R.Left+240, R.Top+130, 160,120, MemDC, 0, 0, SrcCopy);
  selectObject(MemDC, last1);
  DeleteObject(BM);
  SelectObject(DC, last);
  DeleteDC(MemDC);
end;

var R : TRect;
    ejec : boolean;

begin
  ejec:=true;
  getwindowrect(getdesktopwindow, r);
  if (r.right-r.left)<638 then ejec:=false;
  if (r.bottom-r.top)<478 then ejec:=false;
  if (not ejec) then begin
    MessageBeep(mb_iconasterisk);
    MessageBox(0,'Esta aplicación requiere VGA 640x480x16 como mínimo.',
      'Truco para Windows',mb_OK or mb_IconHand);
    halt(1);
  end;
  App.Init(TrucoTitle);
  App.Run;
  App.Done;
end.

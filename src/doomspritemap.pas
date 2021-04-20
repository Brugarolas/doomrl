{$INCLUDE doomrl.inc}
unit doomspritemap;
interface
uses Classes, SysUtils,
     vutil, vgltypes, vglprogram, vrltools, vgenerics, vcolor,
     vnode, vspriteengine, vtextures, dfdata;

// TODO : remove
const SpriteCellRow = 16;

type TDoomMouseCursor = class( TVObject )
  constructor Create;
  procedure SetTextureID( aTexture : TTextureID; aSize : DWord );
  procedure Draw( x, y : Integer; aTicks : DWord );
private
  FCoord     : TGLRawQCoord;
  FTexCoord  : TGLRawQTexCoord;
  FColor     : TGLRawQColor4f;
  FTextureID : TTextureID;
  FSize      : DWord;
  FActive    : Boolean;
public
  property Active : Boolean read FActive write FActive;
end;

type TCoord2DArray = specialize TGArray< TCoord2D >;

type

{ TDoomSpriteMap }

 TDoomSpriteMap = class( TVObject )
  constructor Create;
  procedure Recalculate;
  procedure Update( aTime : DWord );
  procedure Draw;
  procedure PrepareTextures;
  procedure ReassignTextures;
  function DevicePointToCoord( aPoint : TPoint ) : TPoint;
  procedure PushSpriteRotated( aX,aY : Integer; const aSprite : TSprite; aRotation : Single );
  procedure PushSpriteXY ( aX, aY : Integer; const aSprite : TSprite; aLight : Byte; aLayer : Byte = 4 );
  procedure PushSprite( aX,aY : Byte; const aSprite : TSprite );
  procedure PushLitSprite( aX,aY : Byte; const aSprite : TSprite; aTSX : Single = 0; aTSY : Single = 0  );
  function ShiftValue( aFocus : TCoord2D ) : TCoord2D;
  procedure SetTarget( aTarget : TCoord2D; aColor : TColor; aDrawPath : Boolean );
  procedure ClearTarget;
  procedure ToggleGrid;
  function GetCellShift(cell: TCoord2D; area: TArea): Byte;
  destructor Destroy; override;
private
  FGridActive     : Boolean;
  FMaxShift       : TPoint;
  FMinShift       : TPoint;
  FFluidX         : Single;
  FFluidY         : Single;
  FTileSize       : Word;
  FFluidTime      : Double;
  FTargeting      : Boolean;
  FTarget         : TCoord2D;
  FTargetList     : TCoord2DArray;
  FTargetColor    : TColor;
  FNewShift       : TCoord2D;
  FShift          : TCoord2D;
  FLastCoord      : TCoord2D;
  FSpriteEngine   : TSpriteEngine;
  FProgram        : array[TStatusEffect] of TSpriteProgram;
  FTexturesLoaded : Boolean;
  FLightMap       : array[0..MAXX] of array[0..MAXY] of Byte;
  FCellCodeBase   : array[0..255] of Byte;
private
  procedure ApplyEffect;
  procedure UpdateLightMap;
  procedure PushTerrain;
  procedure PushObjects;
  function VariableLight( aWhere : TCoord2D ) : Byte;
public
  property Loaded : Boolean read FTexturesLoaded;
  property MaxShift : TPoint read FMaxShift;
  property MinShift : TPoint read FMinShift;

  property TileSize : Word read FTileSize;
  property Shift : TCoord2D read FShift;
  property NewShift : TCoord2D write FNewShift;
end;

var SpriteMap : TDoomSpriteMap = nil;

implementation

uses math, vmath, viotypes, vgl2library, vvision,
     doomtextures, doomio, doombase,
     dfoutput, dfmap, dfitem, dfbeing, dfplayer;

function ColorToGL( aColor : TColor ) : TGLVec3b;
begin
  ColorToGL.X := aColor.R;
  ColorToGL.Y := aColor.G;
  ColorToGL.Z := aColor.B;
end;

{ TDoomMouseCursor }

constructor TDoomMouseCursor.Create;
begin
  inherited Create;
  FActive := True;
  FSize := 0;
  FColor.FillAll(1);
  FTexCoord.Init( TGLVec2f.Create(0,0), TGLVec2f.Create(1,1) );
end;

procedure TDoomMouseCursor.SetTextureID ( aTexture : TTextureID; aSize : DWord ) ;
begin
  FTextureID := aTexture;
  FSize      := aSize;
end;

procedure TDoomMouseCursor.Draw ( x, y : Integer; aTicks : DWord ) ;
begin
  if ( FSize = 0 ) or ( not FActive ) then Exit;

  FCoord.Init( TGLVec2i.Create(x,y), TGLVec2i.Create(x+FSize,y+FSize) );

  glColor4f( 1.0, ( Sin( aTicks / 100 ) + 1.0 ) / 2 , 0.1, 1.0 );
  glEnable( GL_TEXTURE_2D );

  glEnableClientState( GL_VERTEX_ARRAY );
  glEnableClientState( GL_TEXTURE_COORD_ARRAY );

  glBindTexture( GL_TEXTURE_2D, Textures[ FTextureID ].GLTexture );
  glVertexPointer( 2, GL_INT, 0, @(FCoord) );
  glTexCoordPointer( 2, GL_FLOAT, 0, @(FTexCoord) );
  glDrawArrays( GL_QUADS, 0, 4 );

  glDisableClientState( GL_VERTEX_ARRAY );
  glDisableClientState( GL_TEXTURE_COORD_ARRAY );
end;

{ TDoomSpriteMap }

constructor TDoomSpriteMap.Create;
var iCellRow : Byte;
    iContrastSource : AnsiString;
    iSaturationSource : AnsiString;
begin
  FTargeting := False;
  FTargetList := TCoord2DArray.Create();
  FFluidTime := 0;
  FTarget.Create(0,0);
  FTexturesLoaded := False;
  FSpriteEngine := TSpriteEngine.Create;
  FSpriteEngine.FTexUnit.y := 1.0 / 64;
  FGridActive     := False;
  FLastCoord.Create(0,0);
  Recalculate;

  iContrastSource :=
    'vec3 contrast3(vec3 color, vec3 amount) {'#10 +
    '  float c = 259.0/255.0;'#10 +
    '  vec3 f = c * (amount + vec3(1.0,1.0,1.0))/(vec3(c, c, c) - amount);'#10 +
    '  vec3 result = f * (color - vec3(0.5,0.5,0.5)) + vec3(0.5,0.5,0.5);'#10 +
    '  return clamp(result, vec3(0.0, 0.0, 0.0), vec3(1.0,1.0,1.0));'#10 +
    '}'#10 +
    'vec3 contrast(vec3 color, float amount) {'#10 +
    '  return contrast3(color, vec3(amount,amount,amount));'#10 +
    '}'#10;
  iSaturationSource :=
    'vec3 saturation33(vec3 color, vec3 v, vec3 c) {'#10 +
    '  vec3 f = (vec3(1.0,1.0,1.0) - v) * c;'#10 +
    '  float d = dot(color, f);'#10 +
    '  vec3 result = vec3(d, d, d) + color * v;'#10 +
    '  return clamp(result, vec3(0.0, 0.0, 0.0), vec3(1.0,1.0,1.0));'#10 +
    '}'#10 +
    'vec3 saturation3(vec3 color, vec3 v) {'#10 +
    '  return saturation33(color, v, vec3(0.3086, 0.6094, 0.0820));'#10 +
    '}'#10 +
    'vec3 linearsaturation3(vec3 color, vec3 v) {'#10 +
    '  return saturation33(color, v, vec3(0.3333, 0.3334, 0.3333));'#10 +
    '}'#10 +
    'vec3 linearsaturation(vec3 color, float amount) {'#10 +
    '  return linearsaturation3(color, vec3(amount, amount, amount));'#10 +
    '}'#10 +
    'vec3 simplesaturation(vec3 color, float value) {'#10 +
    '  float v = (color.r + color.g + color.b - min(min(color.r, color.g), color.b)) / 2.0;'#10 +
    '  v = (1.0 - value) * v;'#10 +
    '  vec3 result = color * value + vec3(v, v, v);'#10 +
    '  return clamp(result, vec3(0.0, 0.0, 0.0), vec3(1.0,1.0,1.0));'#10 +
    '}'#10;

  FProgram[StatusNormal] := nil;
  FProgram[StatusInvert] := TSpriteProgram.Create(
    iSaturationSource +
    'vec3 xform(vec3 c)'#10 +
    '{'#10 +
    '  c = linearsaturation(c, 0.0);'#10 +
    '  c = vec3(1.0, 1.0, 1.0) - c;'#10 +
    '  return c;'#10 +
    '}'#10, 'xform' );
  FProgram[StatusRed] := TSpriteProgram.Create(
    iContrastSource +
    iSaturationSource +
    'vec3 xform(vec3 c)'#10 +
    '{'#10 +
    '  c = contrast(c, 30.0/255.0);'#10 +
    '  c = linearsaturation(c, 0.0);'#10 +
    '  c = linearsaturation3(c, vec3(1.5, 0.1, 0.15));'#10 +
    '  return c;'#10 +
    '}'#10, 'xform' );
  FProgram[StatusGreen] := TSpriteProgram.Create(
    iSaturationSource +
    'vec3 xform(vec3 c)'#10 +
    '{'#10 +
    '  c = simplesaturation(c, 0.1);'#10 +
    '  c = saturation3(c.rgb, vec3(0.1, 1.0, 0.1));'#10 +
    '  return c;'#10 +
    '}'#10, 'xform' );

  iCellRow := SpriteCellRow;

  FCellCodeBase[  0]:=14*iCellRow+2; FCellCodeBase[  1]:=14*iCellRow+2; FCellCodeBase[  2]:= 4*iCellRow+2; FCellCodeBase[  3]:= 4*iCellRow+2;
  FCellCodeBase[  4]:=14*iCellRow+2; FCellCodeBase[  5]:=14*iCellRow+2; FCellCodeBase[  6]:= 4*iCellRow+2; FCellCodeBase[  7]:= 4*iCellRow+2;
  FCellCodeBase[  8]:= 7*iCellRow+2; FCellCodeBase[  9]:= 7*iCellRow+2; FCellCodeBase[ 10]:= 6*iCellRow+2; FCellCodeBase[ 11]:= 2*iCellRow+2;
  FCellCodeBase[ 12]:= 7*iCellRow+2; FCellCodeBase[ 13]:= 7*iCellRow+2; FCellCodeBase[ 14]:= 6*iCellRow+2; FCellCodeBase[ 15]:= 2*iCellRow+2;
  FCellCodeBase[ 16]:= 7*iCellRow+0; FCellCodeBase[ 17]:= 7*iCellRow+0; FCellCodeBase[ 18]:= 6*iCellRow+0; FCellCodeBase[ 19]:= 6*iCellRow+0;
  FCellCodeBase[ 20]:= 7*iCellRow+0; FCellCodeBase[ 21]:= 7*iCellRow+0; FCellCodeBase[ 22]:= 2*iCellRow+0; FCellCodeBase[ 23]:= 2*iCellRow+0;
  FCellCodeBase[ 24]:= 3*iCellRow+1; FCellCodeBase[ 25]:= 3*iCellRow+1; FCellCodeBase[ 26]:= 5*iCellRow+1; FCellCodeBase[ 27]:=15*iCellRow+0;
  FCellCodeBase[ 28]:= 3*iCellRow+1; FCellCodeBase[ 29]:= 3*iCellRow+1; FCellCodeBase[ 30]:=15*iCellRow+1; FCellCodeBase[ 31]:= 2*iCellRow+1;
  FCellCodeBase[ 32]:=14*iCellRow+2; FCellCodeBase[ 33]:=14*iCellRow+2; FCellCodeBase[ 34]:= 4*iCellRow+2; FCellCodeBase[ 35]:= 4*iCellRow+2;
  FCellCodeBase[ 36]:=14*iCellRow+2; FCellCodeBase[ 37]:=14*iCellRow+2; FCellCodeBase[ 38]:= 4*iCellRow+2; FCellCodeBase[ 39]:= 4*iCellRow+2;
  FCellCodeBase[ 40]:= 7*iCellRow+2; FCellCodeBase[ 41]:= 7*iCellRow+2; FCellCodeBase[ 42]:= 6*iCellRow+2; FCellCodeBase[ 43]:= 2*iCellRow+2;
  FCellCodeBase[ 44]:= 7*iCellRow+2; FCellCodeBase[ 45]:= 7*iCellRow+2; FCellCodeBase[ 46]:= 6*iCellRow+2; FCellCodeBase[ 47]:= 2*iCellRow+2;
  FCellCodeBase[ 48]:= 7*iCellRow+0; FCellCodeBase[ 49]:= 7*iCellRow+0; FCellCodeBase[ 50]:= 6*iCellRow+0; FCellCodeBase[ 51]:= 6*iCellRow+0;
  FCellCodeBase[ 52]:= 7*iCellRow+0; FCellCodeBase[ 53]:= 7*iCellRow+0; FCellCodeBase[ 54]:= 2*iCellRow+0; FCellCodeBase[ 55]:= 2*iCellRow+0;
  FCellCodeBase[ 56]:= 3*iCellRow+1; FCellCodeBase[ 57]:= 3*iCellRow+1; FCellCodeBase[ 58]:= 5*iCellRow+1; FCellCodeBase[ 59]:=15*iCellRow+0;
  FCellCodeBase[ 60]:= 3*iCellRow+1; FCellCodeBase[ 61]:= 3*iCellRow+1; FCellCodeBase[ 62]:=15*iCellRow+1; FCellCodeBase[ 63]:= 2*iCellRow+1;
  FCellCodeBase[ 64]:= 4*iCellRow+1; FCellCodeBase[ 65]:= 4*iCellRow+1; FCellCodeBase[ 66]:= 4*iCellRow+0; FCellCodeBase[ 67]:= 4*iCellRow+0;
  FCellCodeBase[ 68]:= 4*iCellRow+1; FCellCodeBase[ 69]:= 4*iCellRow+1; FCellCodeBase[ 70]:= 4*iCellRow+0; FCellCodeBase[ 71]:= 4*iCellRow+0;
  FCellCodeBase[ 72]:= 3*iCellRow+2; FCellCodeBase[ 73]:= 3*iCellRow+2; FCellCodeBase[ 74]:= 5*iCellRow+2; FCellCodeBase[ 75]:=13*iCellRow+0;
  FCellCodeBase[ 76]:= 3*iCellRow+2; FCellCodeBase[ 77]:= 3*iCellRow+2; FCellCodeBase[ 78]:= 5*iCellRow+2; FCellCodeBase[ 79]:=13*iCellRow+0;
  FCellCodeBase[ 80]:= 3*iCellRow+0; FCellCodeBase[ 81]:= 3*iCellRow+0; FCellCodeBase[ 82]:= 5*iCellRow+0; FCellCodeBase[ 83]:= 5*iCellRow+0;
  FCellCodeBase[ 84]:= 3*iCellRow+0; FCellCodeBase[ 85]:= 3*iCellRow+0; FCellCodeBase[ 86]:=13*iCellRow+1; FCellCodeBase[ 87]:=13*iCellRow+1;
  FCellCodeBase[ 88]:= 6*iCellRow+1; FCellCodeBase[ 89]:= 6*iCellRow+1; FCellCodeBase[ 90]:= 7*iCellRow+1; FCellCodeBase[ 91]:=11*iCellRow+1;
  FCellCodeBase[ 92]:= 6*iCellRow+1; FCellCodeBase[ 93]:= 6*iCellRow+1; FCellCodeBase[ 94]:=11*iCellRow+0; FCellCodeBase[ 95]:= 9*iCellRow+1;
  FCellCodeBase[ 96]:= 4*iCellRow+1; FCellCodeBase[ 97]:= 4*iCellRow+1; FCellCodeBase[ 98]:= 4*iCellRow+0; FCellCodeBase[ 99]:= 4*iCellRow+0;
  FCellCodeBase[100]:= 4*iCellRow+1; FCellCodeBase[101]:= 4*iCellRow+1; FCellCodeBase[102]:= 4*iCellRow+0; FCellCodeBase[103]:= 4*iCellRow+0;
  FCellCodeBase[104]:= 0*iCellRow+2; FCellCodeBase[105]:= 0*iCellRow+2; FCellCodeBase[106]:=14*iCellRow+0; FCellCodeBase[107]:= 1*iCellRow+2;
  FCellCodeBase[108]:= 0*iCellRow+2; FCellCodeBase[109]:= 0*iCellRow+2; FCellCodeBase[110]:=14*iCellRow+0; FCellCodeBase[111]:= 1*iCellRow+2;
  FCellCodeBase[112]:= 3*iCellRow+0; FCellCodeBase[113]:= 3*iCellRow+0; FCellCodeBase[114]:= 5*iCellRow+0; FCellCodeBase[115]:= 5*iCellRow+0;
  FCellCodeBase[116]:= 3*iCellRow+0; FCellCodeBase[117]:= 3*iCellRow+0; FCellCodeBase[118]:=13*iCellRow+1; FCellCodeBase[119]:=13*iCellRow+1;
  FCellCodeBase[120]:=12*iCellRow+0; FCellCodeBase[121]:=12*iCellRow+0; FCellCodeBase[122]:=10*iCellRow+1; FCellCodeBase[123]:=13*iCellRow+2;
  FCellCodeBase[124]:=12*iCellRow+0; FCellCodeBase[125]:=12*iCellRow+0; FCellCodeBase[126]:=12*iCellRow+2; FCellCodeBase[127]:= 9*iCellRow+0;
  FCellCodeBase[128]:=14*iCellRow+2; FCellCodeBase[129]:=14*iCellRow+2; FCellCodeBase[130]:= 4*iCellRow+2; FCellCodeBase[131]:= 4*iCellRow+2;
  FCellCodeBase[132]:=14*iCellRow+2; FCellCodeBase[133]:=14*iCellRow+2; FCellCodeBase[134]:= 4*iCellRow+2; FCellCodeBase[135]:= 4*iCellRow+2;
  FCellCodeBase[136]:= 7*iCellRow+2; FCellCodeBase[137]:= 7*iCellRow+2; FCellCodeBase[138]:= 6*iCellRow+2; FCellCodeBase[139]:= 2*iCellRow+2;
  FCellCodeBase[140]:= 7*iCellRow+2; FCellCodeBase[141]:= 7*iCellRow+2; FCellCodeBase[142]:= 6*iCellRow+2; FCellCodeBase[143]:= 2*iCellRow+2;
  FCellCodeBase[144]:= 7*iCellRow+0; FCellCodeBase[145]:= 7*iCellRow+0; FCellCodeBase[146]:= 6*iCellRow+0; FCellCodeBase[147]:= 6*iCellRow+0;
  FCellCodeBase[148]:= 7*iCellRow+0; FCellCodeBase[149]:= 7*iCellRow+0; FCellCodeBase[150]:= 2*iCellRow+0; FCellCodeBase[151]:= 2*iCellRow+0;
  FCellCodeBase[152]:= 3*iCellRow+1; FCellCodeBase[153]:= 3*iCellRow+1; FCellCodeBase[154]:= 5*iCellRow+1; FCellCodeBase[155]:=15*iCellRow+0;
  FCellCodeBase[156]:= 3*iCellRow+1; FCellCodeBase[157]:= 3*iCellRow+1; FCellCodeBase[158]:=15*iCellRow+1; FCellCodeBase[159]:= 2*iCellRow+1;
  FCellCodeBase[160]:=14*iCellRow+2; FCellCodeBase[161]:=14*iCellRow+2; FCellCodeBase[162]:= 4*iCellRow+2; FCellCodeBase[163]:= 4*iCellRow+2;
  FCellCodeBase[164]:=14*iCellRow+2; FCellCodeBase[165]:=14*iCellRow+2; FCellCodeBase[166]:= 4*iCellRow+2; FCellCodeBase[167]:= 4*iCellRow+2;
  FCellCodeBase[168]:= 7*iCellRow+2; FCellCodeBase[169]:= 7*iCellRow+2; FCellCodeBase[170]:= 6*iCellRow+2; FCellCodeBase[171]:= 2*iCellRow+2;
  FCellCodeBase[172]:= 7*iCellRow+2; FCellCodeBase[173]:= 7*iCellRow+2; FCellCodeBase[174]:= 6*iCellRow+2; FCellCodeBase[175]:= 2*iCellRow+2;
  FCellCodeBase[176]:= 7*iCellRow+0; FCellCodeBase[177]:= 7*iCellRow+0; FCellCodeBase[178]:= 6*iCellRow+0; FCellCodeBase[179]:= 6*iCellRow+0;
  FCellCodeBase[180]:= 7*iCellRow+0; FCellCodeBase[181]:= 7*iCellRow+0; FCellCodeBase[182]:= 2*iCellRow+0; FCellCodeBase[183]:= 2*iCellRow+0;
  FCellCodeBase[184]:= 3*iCellRow+1; FCellCodeBase[185]:= 3*iCellRow+1; FCellCodeBase[186]:= 5*iCellRow+1; FCellCodeBase[187]:=15*iCellRow+0;
  FCellCodeBase[188]:= 3*iCellRow+1; FCellCodeBase[189]:= 3*iCellRow+1; FCellCodeBase[190]:=15*iCellRow+1; FCellCodeBase[191]:= 2*iCellRow+1;
  FCellCodeBase[192]:= 4*iCellRow+1; FCellCodeBase[193]:= 4*iCellRow+1; FCellCodeBase[194]:= 4*iCellRow+0; FCellCodeBase[195]:= 4*iCellRow+0;
  FCellCodeBase[196]:= 4*iCellRow+1; FCellCodeBase[197]:= 4*iCellRow+1; FCellCodeBase[198]:= 4*iCellRow+0; FCellCodeBase[199]:= 4*iCellRow+0;
  FCellCodeBase[200]:= 3*iCellRow+2; FCellCodeBase[201]:= 3*iCellRow+2; FCellCodeBase[202]:= 5*iCellRow+2; FCellCodeBase[203]:=13*iCellRow+0;
  FCellCodeBase[204]:= 3*iCellRow+2; FCellCodeBase[205]:= 3*iCellRow+2; FCellCodeBase[206]:= 5*iCellRow+2; FCellCodeBase[207]:=13*iCellRow+0;
  FCellCodeBase[208]:= 0*iCellRow+0; FCellCodeBase[209]:= 0*iCellRow+0; FCellCodeBase[210]:=14*iCellRow+1; FCellCodeBase[211]:=14*iCellRow+1;
  FCellCodeBase[212]:= 0*iCellRow+0; FCellCodeBase[213]:= 0*iCellRow+0; FCellCodeBase[214]:= 1*iCellRow+0; FCellCodeBase[215]:= 1*iCellRow+0;
  FCellCodeBase[216]:=11*iCellRow+2; FCellCodeBase[217]:=11*iCellRow+2; FCellCodeBase[218]:=12*iCellRow+1; FCellCodeBase[219]:=10*iCellRow+0;
  FCellCodeBase[220]:=11*iCellRow+2; FCellCodeBase[221]:=11*iCellRow+2; FCellCodeBase[222]:=10*iCellRow+2; FCellCodeBase[223]:= 9*iCellRow+2;
  FCellCodeBase[224]:= 4*iCellRow+1; FCellCodeBase[225]:= 4*iCellRow+1; FCellCodeBase[226]:= 4*iCellRow+0; FCellCodeBase[227]:= 4*iCellRow+0;
  FCellCodeBase[228]:= 4*iCellRow+1; FCellCodeBase[229]:= 4*iCellRow+1; FCellCodeBase[230]:= 4*iCellRow+0; FCellCodeBase[231]:= 4*iCellRow+0;
  FCellCodeBase[232]:= 0*iCellRow+2; FCellCodeBase[233]:= 0*iCellRow+2; FCellCodeBase[234]:=14*iCellRow+0; FCellCodeBase[235]:= 1*iCellRow+2;
  FCellCodeBase[236]:= 0*iCellRow+2; FCellCodeBase[237]:= 0*iCellRow+2; FCellCodeBase[238]:=14*iCellRow+0; FCellCodeBase[239]:= 1*iCellRow+2;
  FCellCodeBase[240]:= 0*iCellRow+0; FCellCodeBase[241]:= 0*iCellRow+0; FCellCodeBase[242]:=14*iCellRow+1; FCellCodeBase[243]:=14*iCellRow+1;
  FCellCodeBase[244]:= 0*iCellRow+0; FCellCodeBase[245]:= 0*iCellRow+0; FCellCodeBase[246]:= 1*iCellRow+0; FCellCodeBase[247]:= 1*iCellRow+0;
  FCellCodeBase[248]:= 0*iCellRow+1; FCellCodeBase[249]:= 0*iCellRow+1; FCellCodeBase[250]:= 8*iCellRow+1; FCellCodeBase[251]:= 8*iCellRow+0;
  FCellCodeBase[252]:= 0*iCellRow+1; FCellCodeBase[253]:= 0*iCellRow+1; FCellCodeBase[254]:= 8*iCellRow+2; FCellCodeBase[255]:= 1*iCellRow+1;

end;

procedure TDoomSpriteMap.Recalculate;
begin
  FTileSize := 32 * IO.TileMult;
  FSpriteEngine.FGrid.Init(FTileSize,FTileSize);
  FMinShift := Point(0,0);
  FMaxShift := Point(Max(FTileSize*MAXX-IO.Driver.GetSizeX,0),Max(FTileSize*MAXY-IO.Driver.GetSizeY,0));

  if IO.Driver.GetSizeY > 20*FTileSize then
  begin
    FMinShift.Y := -( IO.Driver.GetSizeY - 20*FTileSize ) div 2;
    FMaxShift.Y := FMinShift.Y;
  end
  else
  begin
    FMinShift.Y -= 18*IO.FontMult*2;
    FMaxShift.Y += 18*IO.FontMult*3;
  end;
end;

procedure TDoomSpriteMap.Update ( aTime : DWord ) ;
begin
  FShift := FNewShift;
  FFluidTime += aTime*0.0001;
  FFluidX := 1-(FFluidTime - Floor( FFluidTime ));
  FFluidY := (FFluidTime - Floor( FFluidTime ));
  ApplyEffect;
  UpdateLightMap;
  FSpriteEngine.Clear;
  PushTerrain;
  PushObjects;
end;

procedure TDoomSpriteMap.Draw;
var iPoint   : TPoint;
    iCoord   : TCoord2D;
const TargetSprite : TSprite = (
  Large    : False;
  Overlay  : False;
  CosColor : True;
  Glow     : False;
  Color    : (R:0;G:0;B:0;A:255);
  GlowColor: (R:0;G:0;B:0;A:0);
  SpriteID : HARDSPRITE_SELECT;
);

begin
  FSpriteEngine.FPos.X := FShift.X;
  FSpriteEngine.FPos.Y := FShift.Y;

  if IO.MCursor.Active and IO.Driver.GetMousePos( iPoint ) then
  begin
    iPoint := DevicePointToCoord( iPoint );
    iCoord := NewCoord2D(iPoint.X,iPoint.Y);
    if Doom.Level.isProperCoord( iCoord ) then
    begin
      if (FLastCoord <> iCoord) and (not UI.AnimationsRunning) then
      begin
        UI.SetTempHint(UI.GetLookDescription(iCoord));
        FLastCoord := iCoord;
      end;

      TargetSprite.Color := ColorBlack;
      if Doom.Level.isVisible( iCoord ) then
        TargetSprite.Color.G := Floor(100*(Sin( FFluidTime*50 )+1)+50)
      else
        TargetSprite.Color.R := Floor(100*(Sin( FFluidTime*50 )+1)+50);
      SpriteMap.PushSprite( iPoint.X, iPoint.Y, TargetSprite );
    end;
  end;

  FSpriteEngine.Draw;
end;

procedure TDoomSpriteMap.PrepareTextures;
begin
  if FTexturesLoaded then Exit;
  FTexturesLoaded := True;

  Textures.PrepareTextures;

  with FSpriteEngine do
  begin
    FLayers[ 1 ] := TSpriteDataSet.Create( FSpriteEngine, true, false );
    FLayers[ 2 ] := TSpriteDataSet.Create( FSpriteEngine, true, true );
    FLayers[ 4 ] := TSpriteDataSet.Create( FSpriteEngine, true, true );
    FLayers[ 3 ] := TSpriteDataSet.Create( FSpriteEngine, true, true );
    FLayerCount := 4;

    FLayers[ 1 ].Resize( MAXX * MAXY );
    FLayers[ 1 ].Clear;
  end;

  ReassignTextures;
end;

procedure TDoomSpriteMap.ReassignTextures;
var iNormal   : DWord;
    iCosColor : DWord;
    iGlow     : DWord;
begin
  iNormal   := Textures.Textures['spritesheet'].GLTexture;
  iCosColor := Textures.Textures['spritesheet_color'].GLTexture;
  iGlow     := Textures.Textures['spritesheet_glow'].GLTexture;

  with FSpriteEngine do
  begin
    FTextureSet.Layer[ 1 ].Normal  := iNormal;
    FTextureSet.Layer[ 1 ].Cosplay := iCosColor;
    FTextureSet.Layer[ 2 ].Normal  := iNormal;
    FTextureSet.Layer[ 2 ].Cosplay := iCosColor;
    FTextureSet.Layer[ 2 ].Glow    := iGlow;
    FTextureSet.Layer[ 3 ] := FTextureSet.Layer[ 2 ];
    FTextureSet.Layer[ 4 ] := FTextureSet.Layer[ 2 ];
  end;
end;

function TDoomSpriteMap.DevicePointToCoord ( aPoint : TPoint ) : TPoint;
begin
  Result.x := Floor((aPoint.x + FShift.X) / FTileSize)+1;
  Result.y := Floor((aPoint.y + FShift.Y) / FTileSize)+1;
end;

procedure TDoomSpriteMap.PushSpriteRotated ( aX, aY : Integer;
  const aSprite : TSprite; aRotation : Single ) ;
var iCoord : TGLRawQCoord;
    iTex   : TGLRawQTexCoord;
    iColor, iCosColor : TGLRawQColor;
    iTP    : TGLVec2f;
    iSizeH : Word;
  function Rotated( pX, pY : Float ) : TGLVec2i;
  begin
    Rotated.x := Round( pX * cos( aRotation ) - pY * sin( aRotation ) + aX );
    Rotated.y := Round( pY * cos( aRotation ) + pX * sin( aRotation ) + aY );
  end;
begin
  iSizeH := FTileSize div 2;

  iCoord.Data[ 0 ] := Rotated( -iSizeH, -iSizeH );
  iCoord.Data[ 1 ] := Rotated( -iSizeH, +iSizeH );
  iCoord.Data[ 2 ] := Rotated( +iSizeH, +iSizeH );
  iCoord.Data[ 3 ] := Rotated( +iSizeH, -iSizeH );

  iTP := TGLVec2f.CreateModDiv( (aSprite.SpriteID-1), FSpriteEngine.FSpriteRowCount );

  iTex.init(
    iTP * FSpriteEngine.FTexUnit,
    iTP.Shifted(1) * FSpriteEngine.FTexUnit
  );

  with FSpriteEngine.FLayers[ 4 ] do
  begin
    iColor.FillAll( 255 );
    iCosColor.FillAll( 255 );
    if aSprite.Overlay then iColor.SetAll( ColorToGL( aSprite.Color ) );
    if aSprite.CosColor then iCosColor.SetAll( ColorToGL( aSprite.Color ) );
    Normal.Push( @iCoord, @iTex, @iColor, @iCosColor );

    if aSprite.Glow then
    begin
      iColor.SetAll( ColorToGL( aSprite.GlowColor ) );
      iCosColor.FillAll( 255 );
      Glow.Push( @iCoord, @iTex, @iColor, @iCosColor );
    end;
  end;
end;

procedure TDoomSpriteMap.PushSpriteXY ( aX, aY : Integer; const aSprite : TSprite; aLight : Byte; aLayer : Byte ) ;
var iSize  : Byte;
    ip     : TGLVec2i;
    iColor, iCosColor, iLight : TColor;
begin
  iSize := 1;
  if aSprite.Large then
  begin
    iSize := 2;
    aX -= FTileSize div 2;
    aY -= FTileSize;
  end;
  ip := TGLVec2i.Create(aX,aY);
  iLight := NewColor( aLight, aLight, aLight );
  with FSpriteEngine.FLayers[ aLayer ] do
  begin
// TODO: facing
    if aSprite.Overlay
      then iColor := aSprite.Color
      else iColor := ColorWhite;
    if aSprite.CosColor
      then iCosColor := aSprite.Color
      else iCosColor := ColorWhite;
    Normal.PushXY( aSprite.SpriteID, iSize, ip, iColor, iCosColor, iLight );
    if aSprite.Glow and (Glow <> nil) then
      Glow.PushXY( aSprite.SpriteID, iSize, ip, aSprite.GlowColor, ColorWhite, iLight );
  end;
end;

procedure TDoomSpriteMap.PushSprite ( aX, aY : Byte; const aSprite : TSprite ) ;
begin
  PushSpriteXY( (aX-1) * FTileSize, (aY-1) * FTileSize, aSprite, 255, 4 );
end;

procedure TDoomSpriteMap.PushLitSprite ( aX, aY : Byte; const aSprite : TSprite; aTSX : Single; aTSY : Single ) ;
var i, iSize : Byte;
    iLights, iColors, iCosColors : TGLRawQColor;
    ip       : TGLVec2i;
begin
  iSize := 1;
  if aSprite.Large then
  begin
    iSize := 2;
    aX -= FTileSize div 2;
    aY -= FTileSize;
  end;

  {$WARNINGS OFF}
  iLights.Data[0] := TGLVec3b.CreateAll( FLightMap[aX-1,aY-1] );
  iLights.Data[1] := TGLVec3b.CreateAll( FLightMap[aX-1,aY  ] );
  iLights.Data[2] := TGLVec3b.CreateAll( FLightMap[aX  ,aY  ] );
  iLights.Data[3] := TGLVec3b.CreateAll( FLightMap[aX  ,aY-1] );
  {$WARNINGS ON}

  iColors.SetAll( TGLVec3b.Create( 255, 255, 255 ) );
  iCosColors.SetAll( TGLVec3b.Create( 255, 255, 255 ) );

  ip := TGLVec2i.Create( (aX-1)*FTileSize, (aY-1)*FTileSize );
  with FSpriteEngine.FLayers[ 1 ] do
  begin
    if aSprite.CosColor and (Cosplay <> nil) then
    begin
      for i := 0 to 3 do
      begin
        // TODO : This should be one line!
        iCosColors.Data[ i ].X := aSprite.Color.R;
        iCosColors.Data[ i ].Y := aSprite.Color.G;
        iCosColors.Data[ i ].Z := aSprite.Color.B;
      end;
    end;
    Normal.PushXY( aSprite.SpriteID, iSize, ip, @iColors, @iCosColors, @iLights, aTSX, aTSY );
  end;
end;

function TDoomSpriteMap.ShiftValue ( aFocus : TCoord2D ) : TCoord2D;
begin
  ShiftValue.X := S5Interpolate(FMinShift.X,FMaxShift.X, (aFocus.X-2)/(MAXX-3));
  if FMaxShift.Y - FMinShift.Y > 4*FTileSize then
  begin
    if aFocus.Y < 6 then
      ShiftValue.Y := FMinShift.Y
    else if aFocus.Y > MAXY-6 then
      ShiftValue.Y := FMaxShift.Y
    else
      ShiftValue.Y := S3Interpolate(FMinShift.Y,FMaxShift.Y,(aFocus.Y-6)/(MAXY-12));

  end
  else
    ShiftValue.Y := S3Interpolate(FMinShift.Y,FMaxShift.Y,(aFocus.Y-2)/(MAXY-3));
end;

procedure TDoomSpriteMap.SetTarget ( aTarget : TCoord2D; aColor : TColor; aDrawPath : Boolean ) ;
var iTargetLine : TVisionRay;
    iCurrent    : TCoord2D;
begin
  FTargeting   := True;
  FTarget      := aTarget;
  FTargetColor := aColor;

  FTargetList.Clear;

  if (Player.Position <> FTarget) and (aDrawPath) then
  begin
    iTargetLine.Init( Doom.Level, Player.Position, FTarget );
    repeat
      iTargetLine.Next;
      iCurrent := iTargetLine.GetC;

      if not iTargetLine.Done then
        FTargetList.Push( iCurrent );
    until (iTargetLine.Done) or (iTargetLine.cnt > 30);
  end;
  FTargetList.Push( FTarget );
end;

procedure TDoomSpriteMap.ClearTarget;
begin
  FTargeting := False;
end;

procedure TDoomSpriteMap.ToggleGrid;
begin
  FGridActive     := not FGridActive;
end;

destructor TDoomSpriteMap.Destroy;
begin
  FreeAndNil( FSpriteEngine );
  FreeAndNil( FTargetList );
  inherited Destroy;
end;

procedure TDoomSpriteMap.ApplyEffect;
var tempStatusEffect : TStatusEffect;
begin
  //Some effects are currently unavailable in non-console mode.
  tempStatusEffect := StatusEffect;
  case StatusEffect of
    StatusRed, StatusGreen, StatusNormal, StatusInvert : tempStatusEffect := StatusEffect;
    else tempStatusEffect := StatusNormal;
  end;

  FSpriteEngine.FLayers[ 1 ].SetProgram( FProgram[ tempStatusEffect ] );
  FSpriteEngine.FLayers[ 2 ].SetProgram( FProgram[ tempStatusEffect ] );
  FSpriteEngine.FLayers[ 3 ].SetProgram( FProgram[ tempStatusEffect ] );
  FSpriteEngine.FLayers[ 4 ].SetProgram( FProgram[ tempStatusEffect ] );
end;

procedure TDoomSpriteMap.UpdateLightMap;
var Y,X : DWord;
  function Get( X, Y : Byte ) : Byte;
  var c : TCoord2D;
  begin
    c.Create( X, Y );
    if not Doom.Level.isExplored( c ) then Exit( 0 );
    Exit( VariableLight(c) );
  end;

begin
  for X := 0 to MAXX do
    for Y := 0 to MAXY do
      if (X*Y = 0) or (X = MAXX) or (Y = MAXY) then
        FLightMap[X,Y] := 0
      else
      begin
        FLightMap[X,Y] := ( Get(X,Y) + Get(X,Y+1) + Get(X+1,Y) + Get(X+1,Y+1) ) div 4;
      end;
end;

function TDoomSpriteMap.GetCellShift(cell: TCoord2D; area: TArea): Byte;
var Code : Byte;
  function StickyCode( Coord : TCoord2D; Area : TArea; Res : Byte ) : Byte;
  begin
    if not Doom.Level.isProperCoord( Coord ) then Exit(Res);
    if not Area.Contains( Coord ) then Exit( 0 );
    if ((CF_STICKWALL in Cells[Doom.Level.CellBottom[ Coord ]].Flags) or
      ((Doom.Level.CellTop[ Coord ] <> 0) and
      (CF_STICKWALL in Cells[Doom.Level.CellTop[ Coord ]].Flags))) then Exit( Res );
    Exit( 0 );
  end;
begin
  Code :=
    StickyCode( cell.ifInc(-1,-1), area, 1 ) +
    StickyCode( cell.ifInc( 0,-1), area, 2 ) +
    StickyCode( cell.ifInc( 1,-1), area, 4 ) +
    StickyCode( cell.ifInc(-1, 0), area, 8 ) +
    StickyCode( cell.ifInc( 1, 0), area, 16 ) +
    StickyCode( cell.ifInc(-1, 1), area, 32 ) +
    StickyCode( cell.ifInc( 0, 1), area, 64 ) +
    StickyCode( cell.ifInc( 1, 1), area, 128 );
  Exit( FCellCodeBase[ Code ] );
end;


procedure TDoomSpriteMap.PushTerrain;
var DMinX, DMaxX : Word;
    Bottom  : Word;
    Y,X,L        : DWord;
    C            : TCoord2D;
    Spr          : TSprite;
    function Mix( L, C : Byte ) : Byte;
    begin
      Exit( Clamp( Floor( ( L / 255 ) * C ) * 255, 0, 255 ) );
    end;

begin
  DMinX := FShift.X div FTileSize + 1;
  DMaxX := Min(FShift.X div FTileSize + (IO.Driver.GetSizeX div FTileSize + 1),MAXX);

  for Y := 1 to MAXY do
    for X := DMinX to DMaxX do
    begin
      c.Create(X,Y);
      if not Doom.Level.CellExplored(c) then Continue;
      Bottom := Doom.Level.CellBottom[c];
      if Bottom <> 0 then
      begin
        Spr := Cells[Bottom].Sprite;
        if CF_MULTISPRITE in Cells[Bottom].Flags then
          Spr.SpriteID += Doom.Level.Rotation[c];
        if F_GTSHIFT in Cells[Bottom].Flags
          then PushLitSprite( X, Y, Spr, FFluidX, FFluidY )
          else PushLitSprite( X, Y, Spr );
        if (F_GFLUID in Cells[Bottom].Flags) and (Doom.Level.Rotation[c] <> 0) then
        begin
          Spr := Cells[Doom.Level.FFloorCell].Sprite;
          Spr.SpriteID += Doom.Level.Rotation[c];
          PushLitSprite( X, Y, Spr );
        end;
        if Doom.Level.LightFlag[ c, LFBLOOD ] and (Cells[Bottom].BloodSprite.SpriteID <> 0) then
        begin
          Spr := Cells[Bottom].BloodSprite;
          L := VariableLight(c);
          if Spr.CosColor then
            Spr.Color := ScaleColor( Spr.Color, Byte(L) );
          PushSpriteXY( (X-1)*FTileSize, (Y-1)*FTileSize, Spr, L, 2 );
        end;
      end;
    end;
end;

procedure TDoomSpriteMap.PushObjects;
var DMinX, DMaxX : Word;
    Y,X,Top,L    : DWord;
    C            : TCoord2D;
    iBeing       : TBeing;
    iItem        : TItem;
    Spr          : TSprite;
    iColor       : TColor;
begin
  DMinX := FShift.X div FTileSize + 1;
  DMaxX := Min(FShift.X div FTileSize + (IO.Driver.GetSizeX div FTileSize + 1),MAXX);

  for Y := 1 to MAXY do
    for X := DMinX to DMaxX do
    begin
      c.Create(X,Y);

      Top     := Doom.Level.CellTop[c];
      if (Top <> 0) and Doom.Level.CellExplored(c) then
      begin
        L := VariableLight(c);
        if CF_STAIRS in Cells[Top].Flags then L := 255;
        Spr := Cells[Top].Sprite;
        if Spr.CosColor then
          Spr.Color := ScaleColor( Spr.Color, Byte(L) );
        PushSpriteXY( (X-1)*FTileSize, (Y-1)*FTileSize, Spr, L, 2 );
      end;

      iItem := Doom.Level.Item[c];
      if Doom.Level.ItemVisible(c, iItem) or Doom.Level.ItemExplored(c, iItem) then
      begin
        if Doom.Level.ItemVisible(c, iItem) then L := 255 else L := 70;
        PushSpriteXY( (X-1)*FTileSize, (Y-1)*FTileSize, iItem.Sprite, L, 2 );
      end;
    end;

  for Y := 1 to MAXY do
    for X := DMinX to DMaxX do
    begin
      c.Create(X,Y);
      iBeing := Doom.Level.Being[c];
      if (iBeing <> nil) and (iBeing.AnimCount = 0) then
        if Doom.Level.BeingVisible(c, iBeing) then
          PushSpriteXY( (X-1)*FTileSize, (Y-1)*FTileSize, iBeing.Sprite, 255, 3 )
        else if Doom.Level.BeingExplored(c, iBeing) then
          PushSpriteXY( (X-1)*FTileSize, (Y-1)*FTileSize, iBeing.Sprite, 40, 3 )
        else if Doom.Level.BeingIntuited(c, iBeing) then
          PushSpriteXY( (X-1)*FTileSize, (Y-1)*FTileSize, NewSprite( HARDSPRITE_MARK, NewColor( Magenta ) ), 255, 3 )

    end;

  if FTargeting then
    with FSpriteEngine.FLayers[ 3 ] do
    begin
      iColor := NewColor( 0, 128, 0 );
      if FTargetList.Size > 0 then
      for L := 0 to FTargetList.Size-1 do
      begin
        if (not Doom.Level.isVisible( FTargetList[L] )) or
           (not Doom.Level.isEmpty( FTargetList[L], [ EF_NOBLOCK, EF_NOVISION ] )) then
          iColor := NewColor( 128, 0, 0 );
        Cosplay.Push( HARDSPRITE_SELECT, TGLVec2i.Create(FTargetList[L].X, FTargetList[L].Y ), ColorWhite, iColor );
      end;
      if FTargetList.Size > 0 then
        Cosplay.Push( HARDSPRITE_MARK, TGLVec2i.Create( FTarget.X, FTarget.Y ), ColorWhite, FTargetColor );
    end;

  if FGridActive then
  for Y := 1 to MAXY do
    for X := DMinX to DMaxX do
    with FSpriteEngine.FLayers[ 4 ] do
    begin
      Normal.Push( HARDSPRITE_GRID, TGLVec2i.Create( X, Y ), NewColor( 50, 50, 50, 50 ), ColorWhite );
    end;

end;

function TDoomSpriteMap.VariableLight(aWhere: TCoord2D): Byte;
begin
  if not Doom.Level.isVisible( aWhere ) then Exit( 70 ); //20
  Exit( Min( 100+Doom.Level.Vision.getLight(aWhere)*20, 255 ) );
end;

end.


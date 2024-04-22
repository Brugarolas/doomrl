
{$INCLUDE doomrl.inc}
unit dfplayer;
interface
uses classes, sysutils,
     vuielement, vutil, vrltools,
     dfbeing, dfhof, dfdata, dfitem, dfaffect,
     doomtrait;

type

TRunData = object
  Dir    : TDirection;
  Active : Boolean;
  Count  : Word;
  procedure Clear;
  procedure Stop;
  procedure Start( const aDir : TDirection );
end;

TTacticData = object
  Current : TTactic;
  Count   : Word;
  Max     : Word;
  procedure Clear;
  procedure Stop;
  procedure Tick;
  procedure Reset;
  function Change : Boolean;
end;

TStatistics = object
  Map        : TIntHashMap;
  GameTime   : LongInt;
  RealTime   : Comp;
  procedure Clear;
  procedure Destroy;
  procedure Update;
  procedure UpdateNDCount( aCount : DWord );
end;


{ TPlayer }

TPlayer = class(TBeing)
  CurrentLevel    : Word;

  SpecExit        : string[20];
  NukeActivated   : Word;

  InventorySize   : Byte;
  MasterDodge     : Boolean;
  LastTurnDodge   : Boolean;

  FScore          : LongInt;
  FExpFactor      : Real;
  FBersekerLimit  : LongInt;
  FEnemiesInVision: Word;
  FKilledBy       : AnsiString;
  FKilledMelee    : Boolean;

  FStatistics     : TStatistics;
  FKills          : TKillTable;
  FTraits         : TTraits;
  FRun            : TRunData;
  FTactic         : TTacticData;
  FAffects        : TAffects;
  FPathRun        : Boolean;

  constructor Create; reintroduce;
  procedure Initialize; reintroduce;
  constructor CreateFromStream( Stream: TStream ); override;
  procedure WriteToStream( Stream: TStream ); override;
  function PlayerTick : Boolean;
  procedure HandlePostMove; override;
  function HandleCommandValue( aCommand : Byte ) : Boolean;
  procedure AIAction;
  procedure LevelEnter;
  procedure doUpgradeTrait;
  procedure RegisterKill( const aKilledID : AnsiString; aKiller : TBeing; aWeapon : TItem );
  procedure doScreen;
  function doQuickWeapon( const aWeaponID : Ansistring ) : Boolean;
  procedure doQuit( aNoConfirm : Boolean = False );
  procedure doRun;
  procedure ApplyDamage( aDamage : LongInt; aTarget : TBodyTarget; aDamageType : TDamageType; aSource : TItem ); override;
  procedure LevelUp;
  procedure AddExp( aAmount : LongInt );
  function doSave : Boolean;
  procedure WriteMemorial;
  destructor Destroy; override;
  procedure IncStatistic( const aStatisticID : AnsiString; aAmount : Integer = 1 );
  procedure Kill( BloodAmount : DWord; aOverkill : Boolean; aKiller : TBeing; aWeapon : TItem ); override;
  function DescribeLever( aItem : TItem ) : string;
  procedure AddHistory( const aHistory : Ansistring );
  class procedure RegisterLuaAPI();
  procedure UpdateVisual;
  function ASCIIMoreCode : AnsiString; override;
  function CreateAutoTarget( aRange : Integer ): TAutoTarget;
  function doChooseTarget( aActionName : string; aRadius : Byte; aLimitRange : Boolean ) : Boolean;
  private
  function OnTraitConfirm( aSender : TUIElement ) : Boolean;
  procedure ExamineNPC;
  procedure ExamineItem;
  private
  FLastTargetUID  : TUID;
  FLastTargetPos  : TCoord2D;
  FExp            : LongInt;
  FExpLevel       : Byte;
  private
  procedure SetTired( Value : Boolean );
  procedure SetRunning( Value : Boolean );
  function GetTired : Boolean;
  function GetRunning : Boolean;
  function GetSkillRank : Word;
  function GetExpRank : Word;
  published
  property KilledBy      : AnsiString read FKilledBy;
  property KilledMelee   : Boolean    read FKilledMelee;
  property Running       : Boolean    read GetRunning    write SetRunning;
  property Tired         : Boolean    read GetTired      write SetTired;
  property Exp           : LongInt    read FExp          write FExp;
  property ExpLevel      : Byte       read FExpLevel     write FExpLevel;
  property NukeTime      : Word       read NukeActivated write NukeActivated;
  property Klass         : Byte       read FTraits.Klass write FTraits.Klass;
  property RunningTime   : Word       read FTactic.Max   write FTactic.Max;
  property ExpFactor     : Real       read FExpFactor    write FExpFactor;
  property SkillRank     : Word       read GetSkillRank;
  property ExpRank       : Word       read GetExpRank;
  property Score         : LongInt    read FScore        write FScore;
  property Depth         : Word       read CurrentLevel;
  property BeingsInVision: Word       read FEnemiesInVision;
end;

var   Player : TPlayer;

implementation

uses math, vuid, vpath, variants, vioevent, vgenerics,
     vnode, vcolor, vuielements, vdebug, vluasystem,
     dfmap, dflevel, dfoutput,
     doomhooks, doomio, doomspritemap, doomviews, doombase,
     doomlua, doominventory, doomcommand, doomhelp;

var MortemText    : Text;
    WritingMortem : Boolean = False;

{ TStatistics }

procedure TStatistics.Clear;
begin
  Map        := TIntHashMap.Create( HashMap_NoRaise );
  GameTime   := 0;
  RealTime   := 0;
end;

procedure TStatistics.Destroy;
begin
  FreeAndNil( Map );
end;

procedure TStatistics.Update;
var iRealTime : Comp;
begin
  iRealTime := RealTime + MSecNow() - GameRealTime;
  Map['real_time']    := Round(iRealTime / 1000);
  Map['real_time_ms'] := Round(iRealTime);
  Map['game_time']    := GameTime;
  Map['kills']        := Player.FKills.Count;
  Map['max_kills']    := Player.FKills.MaxCount;
end;

procedure TStatistics.UpdateNDCount( aCount : DWord );
begin
  Map['kills_non_damage'] := Max( Map['kills_non_damage'], aCount );
end;

{ TTacticData }

procedure TTacticData.Clear;
begin
  Count   := 30;
  Current := tacticNormal;
end;

procedure TTacticData.Stop;
begin
  if Current = tacticRunning then Current := TacticTired;
end;

procedure TTacticData.Tick;
begin
  if ( Count > 0 ) and ( Current = TacticRunning ) then
  begin
    Dec( Count );
    if Count = 0 then
    begin
      UI.Msg('You stop running.');
      Current := tacticTired;
    end;
  end;
end;

procedure TTacticData.Reset;
begin
  Current := tacticNormal;
  Count := 0;
end;

function TTacticData.Change : Boolean;
begin
  Change := False;
  case Current of
    tacticTired   : UI.Msg('Too tired to do that right now.');
    tacticRunning : begin
                      UI.Msg('You stop running.');
                      Current := tacticTired;
                    end;
    tacticNormal  : begin
                      UI.Msg('You start running!');
                      Count := Max;
                      Current := tacticRunning;
                      Change := True;
                    end;
  end;
end;

{ TRunData }

procedure TRunData.Clear;
begin
  Active := False;
  Count  := 0;
end;

procedure TRunData.Stop;
begin
  Active := False;
  Count := 0;
end;

procedure TRunData.Start ( const aDir : TDirection ) ;
begin
  Active := True;
  Count  := 0;
  Dir    := aDir;
end;

constructor TPlayer.Create;
begin
  inherited Create('soldier');

  FTraits.Clear;
  FKills := TKillTable.Create;
  FRun.Clear;
  FTactic.Clear;
  FAffects.Clear;

  CurrentLevel  := 0;
  StatusEffect  := StatusNormal;
  FStatistics.Clear;
  FScore        := 0;
  SpecExit      := '';
  NukeActivated := 0;
  FExpLevel   := 1;
  FExp        := ExpTable[ FExpLevel ];
  FPathRun    := False;

  InventorySize := High( TItemSlot );
  FTactic.Max := 30;
  FExpFactor := 1.0;

  Initialize;

  CallHook( Hook_OnCreate, [] );
end;

procedure TPlayer.Initialize;
begin
  FKilledBy       := '';
  FKilledMelee    := False;

  FEnemiesInVision:= 1;
  FLastTargetPos.Create(0,0);
  FLastTargetUID := 0;
  FPathRun := False;
  FPath           := TPathFinder.Create(Self);
  MemorialWritten := False;
  MasterDodge     := False;
  LastTurnDodge   := False;

  doombase.Lua.RegisterPlayer(Self);
end;

procedure TPlayer.WriteToStream ( Stream : TStream ) ;
begin
  inherited WriteToStream( Stream );

  Stream.WriteAnsiString( SpecExit );
  Stream.WriteWord( CurrentLevel );
  Stream.WriteWord( NukeActivated );
  Stream.WriteByte( InventorySize );
  Stream.WriteByte( FExpLevel );
  Stream.WriteDWord( FExp );
  Stream.WriteDWord( FScore );
  Stream.WriteDWord( FBersekerLimit );

  Stream.Write( FExpFactor, SizeOf( FExpFactor ) );
  Stream.Write( FAffects,   SizeOf( FAffects ) );
  Stream.Write( FTraits,    SizeOf( FTraits ) );
  Stream.Write( FRun,       SizeOf( FRun ) );
  Stream.Write( FTactic,    SizeOf( FTactic ) );
  Stream.Write( FStatistics,SizeOf( FStatistics ) );

  FKills.WriteToStream( Stream );
  FStatistics.Map.WriteToStream( Stream );
end;

constructor TPlayer.CreateFromStream ( Stream : TStream ) ;
begin
  inherited CreateFromStream( Stream );
  SpecExit       := Stream.ReadAnsiString();
  CurrentLevel   := Stream.ReadWord();
  NukeActivated  := Stream.ReadWord();
  InventorySize  := Stream.ReadByte();
  FExpLevel      := Stream.ReadByte();
  FExp           := Stream.ReadDWord();
  FScore         := Stream.ReadDWord();
  FBersekerLimit := Stream.ReadDWord();

  Stream.Read( FExpFactor, SizeOf( FExpFactor ) );
  Stream.Read( FAffects,   SizeOf( TAffects ) );
  Stream.Read( FTraits,    SizeOf( FTraits ) );
  Stream.Read( FRun,       SizeOf( FRun ) );
  Stream.Read( FTactic,    SizeOf( FTactic ) );
  Stream.Read( FStatistics,SizeOf( FStatistics ) );

  FKills          := TKillTable.CreateFromStream( Stream );
  FStatistics.Map := TIntHashMap.CreateFromStream( Stream );
  
  Initialize;
end;

procedure TPlayer.LevelUp;
begin
  Inc( FExpLevel );
  UI.Blink( LightBlue, 100 );
  UI.MsgEnter( 'You advance to level %d!', [ FExpLevel ] );
  if not Doom.CallHookCheck( Hook_OnPreLevelUp, [ FExpLevel ] ) then Exit;
  UI.BloodSlideDown( 20 );
  doUpgradeTrait();
  Doom.CallHook( Hook_OnLevelUp, [ FExpLevel ] );
end;

procedure TPlayer.AddExp( aAmount : LongInt );
begin
  if Dead then Exit;
  aAmount := Round( aAmount * FExpFactor );

  FExp += aAmount;

  if FExpLevel >= MaxPlayerLevel - 1 then Exit;

  while FExp >= ExpTable[ FExpLevel + 1 ] do LevelUp;
end;



function TPlayer.doQuickWeapon( const aWeaponID : Ansistring ) : Boolean;
var iWeapon  : TItem;
    iItem    : TItem;
    iAmmo    : Byte;
begin
  if (not LuaSystem.Defines.Exists(aWeaponID)) or (LuaSystem.Defines[aWeaponID] = 0)then Exit( False );

  if Inv.Slot[ efWeapon ] <> nil then
  begin
    if Inv.Slot[ efWeapon ].ID = aWeaponID then Exit( Fail( 'You already have %s in your hands.', [ Inv.Slot[ efWeapon ].GetName(true) ] ) );
    if Inv.Slot[ efWeapon ].Flags[ IF_CURSED ] then Exit( Fail( 'You can''t!', [] ) );
  end;

  if Inv.Slot[ efWeapon2 ] <> nil then
    if Inv.Slot[ efWeapon2 ].ID = aWeaponID then
      Exit( ActionSwapWeapon );

  iAmmo   := 0;
  iWeapon := nil;
  for iItem in Inv do
    if iItem.isWeapon then
      if iItem.ID = aWeaponID then
      if iItem.Ammo >= iAmmo then
      begin
        iWeapon := iItem;
        iAmmo   := iItem.Ammo;
      end;

  if iWeapon = nil then Exit( Fail( 'You don''t have a %s!', [ Ansistring(LuaSystem.Get([ 'items', aWeaponID, 'name' ])) ] ) );

  Inv.Wear( iWeapon );

  if Option_SoundEquipPickup
    then PlaySound( iWeapon.Sounds.Pickup )
    else PlaySound( iWeapon.Sounds.Reload );

  if not ( BF_QUICKSWAP in FFlags )
     then Exit( Success( 'You prepare the %s!',[ iWeapon.Name ], 1000 ) )
     else Exit( Success( 'You prepare the %s instantly!',[ iWeapon.Name ] ) );
end;

procedure TPlayer.ApplyDamage(aDamage: LongInt; aTarget: TBodyTarget; aDamageType: TDamageType; aSource : TItem);
begin
  if aDamage < 0 then Exit;

  FPathRun := False;
  FRun.Stop;
  if BF_INV in FFlags then Exit;
  if ( aDamage >= Max( FHPNom div 3, 10 ) ) then
  begin
    UI.Blink(Red,100);
    if BF_BERSERKER in FFlags then
    begin
      UI.Msg('That hurt! You''re going berserk!');
      FTactic.Stop;
      FAffects.Add(LuaSystem.Defines['berserk'],20);
    end;
  end;

  if aDamage > 0 then
  begin
    FKills.DamageTaken;
    FStatistics.UpdateNDCount( FKills.BestNoDamageSequence );
  end;
  inherited ApplyDamage(aDamage, aTarget, aDamageType, aSource );
end;

procedure TPlayer.doRun;
var Key : Byte;
begin
  FPathRun := False;
  if FEnemiesInVision > 1 then
  begin
    Fail( 'Can''t run, there are enemies present.',[] );
    Exit;
  end;
  Key := UI.MsgCommandChoice('Run - direction...',INPUT_MOVE+[INPUT_ESCAPE,INPUT_WAIT]);
  if Key = INPUT_ESCAPE then Exit;
  FRun.Start( InputDirection(Key) );
end;

procedure TPlayer.RegisterKill ( const aKilledID : AnsiString; aKiller : TBeing; aWeapon : TItem ) ;
var iKillClass : AnsiString;
begin
  iKillClass := 'other';
  if aKiller = Self then
  begin
    iKillClass := 'melee';
    if aWeapon <> nil then
      iKillClass := aWeapon.ID;
  end;
  FKills.Add( aKilledID, iKillClass );
end;

function TPlayer.CreateAutoTarget( aRange : Integer ): TAutoTarget;
var iLevel : TLevel;
    iCoord : TCoord2D;
begin
  iLevel := TLevel(Parent);
  Result := TAutoTarget.Create( FPosition );
  for iCoord in NewArea( FPosition, aRange ).Clamped( iLevel.Area ) do
    if iLevel.Being[ iCoord ] <> nil then
    with iLevel.Being[ iCoord ] do
      if (not isPlayer) and isVisible then
        Result.AddTarget( iCoord );
end;

function TPlayer.doChooseTarget( aActionName : string; aRadius : Byte; aLimitRange : Boolean ) : boolean;
var iTargets : TAutoTarget;
    iTarget  : TBeing;
    iLevel   : TLevel;
begin
  if aRadius = 0 then aRadius := FVisionRadius;

  iLevel   := TLevel(Parent);
  iTargets := CreateAutoTarget( aRadius );

  iTarget := nil;
  if (FLastTargetUID <> 0) and iLevel.isAlive( FLastTargetUID ) then
  begin
    iTarget := iLevel.FindChild( FLastTargetUID ) as TBeing;
    if iTarget <> nil then
      if iTarget.isVisible then
        if Distance( iTarget.Position, FPosition ) <= aRadius then
          iTargets.PriorityTarget( iTarget.Position );
  end;

  if FLastTargetPos.X*FLastTargetPos.Y <> 0 then
    if FLastTargetUID = 0 then
      if iLevel.isVisible( FLastTargetPos ) then
        if Distance( FLastTargetPos, FPosition ) <= aRadius then
          iTargets.PriorityTarget( FLastTargetPos );

  FTargetPos := UI.ChooseTarget(aActionName, aRadius+1, aLimitRange, iTargets, FChainFire > 0 );
  FreeAndNil(iTargets);
  if FTargetPos.X = 0 then Exit( False );

  if FTargetPos = FPosition then
  begin
    UI.Msg( 'Find a more constructive way to commit suicide.' );
    Exit( False );
  end;

  FLastTargetUID := 0;
  if iLevel.Being[ FTargetPos ] <> nil then
    FLastTargetUID := iLevel.Being[ FTargetPos ].UID;
  FLastTargetPos := FTargetPos;
  Exit( True );
end;

function TPlayer.OnTraitConfirm ( aSender : TUIElement ) : Boolean;
begin
  with aSender as TUICustomMenu do
    FTraits.Upgrade( Word(SelectedItem.Data) );
  aSender.Parent.Free;
  Exit( True );
end;

function TPlayer.doSave : Boolean;
begin
  //if Doom.Difficulty >= DIFF_NIGHTMARE then Exit( Fail( 'There''s no escape from a NIGHTMARE! Stand and fight like a man!', [] ) );
  if not (CellHook_OnExit in Cells[ TLevel(Parent).Cell[ FPosition ] ].Hooks) then Exit( Fail( 'You can only save the game standing on the stairs to the next level.', [] ) );
  Doom.SetState( DSSaving );
  TLevel(Parent).CallHook( Position, CellHook_OnExit );
end;

procedure TPlayer.doQuit( aNoConfirm : Boolean = False );
begin
  if not aNoConfirm then
  begin
    UI.Msg( LuaSystem.ProtectedCall(['DoomRL','quit_message'],[]) );
    if not UI.MsgConfirm('Are you sure you want to commit suicide?', true) then
    begin
      UI.Msg('Ok, then. Stay and take what''s coming to ya...');
      Exit;
    end;
  end;
  Doom.SetState( DSQuit );
  FScore      := -100000;
end;

function TPlayer.PlayerTick : Boolean;
var iThisUID    : DWord;
begin
  iThisUID := UID;
  TLevel(Parent).CallHook( FPosition, Self, CellHook_OnEnter );
  if UIDs[ iThisUID ] = nil then Exit( False );

  UI.WaitForAnimation;
  MasterDodge := False;
  FAffects.Tick;
  if Doom.State <> DSPlaying then Exit( False );
  FTactic.Tick;
  Inv.EqTick;
  FLastPos := FPosition;
  FMeleeAttack := False;
  Exit( True );
end;

procedure TPlayer.HandlePostMove;
var iTempSC : LongInt;
    iItem   : TItem;
  function RunStopNear : boolean;
  begin
    if TLevel( Parent ).isProperCoord( FPosition.ifIncX(+1) ) and TLevel( Parent ).cellFlagSet( FPosition.ifIncX(+1), CF_RUNSTOP ) then Exit( True );
    if TLevel( Parent ).isProperCoord( FPosition.ifIncX(-1) ) and TLevel( Parent ).cellFlagSet( FPosition.ifIncX(-1), CF_RUNSTOP ) then Exit( True );
    if TLevel( Parent ).isProperCoord( FPosition.ifIncY(+1) ) and TLevel( Parent ).cellFlagSet( FPosition.ifIncY(+1), CF_RUNSTOP ) then Exit( True );
    if TLevel( Parent ).isProperCoord( FPosition.ifIncY(-1) ) and TLevel( Parent ).cellFlagSet( FPosition.ifIncY(-1), CF_RUNSTOP ) then Exit( True );
    Exit( False );
  end;

begin
  iTempSC := FSpeedCount;
  if Inv.Slot[ efWeapon ] <> nil then
  with Inv.Slot[ efWeapon ] do
    if isRanged then
    begin // Autoreloading
     if Ammo < AmmoMax then
       if ( ( ( IF_SHOTGUN in FFlags ) and ( BF_SHOTTYMAN in Self.FFlags ) ) or
          ( ( IF_ROCKET  in FFlags ) and ( BF_ROCKETMAN in Self.FFlags ) ) )
          and (not (IF_RECHARGE in FFlags)) then
       begin
         iItem := Inv.SeekAmmo(AmmoID);
         if iItem <> nil then
           Reload( iItem, IF_SINGLERELOAD in FFlags )
         else if canPackReload then
           Reload( FInv.Slot[ efWeapon2 ], IF_SINGLERELOAD in FFlags );
       end;
     if IF_PUMPACTION in FFlags then
       if (IF_CHAMBEREMPTY in FFlags) and (Ammo <> 0) then
       begin
         TLevel( Parent ).playSound( ID, 'pump', Player.FPosition );
         Exclude( FFlags, IF_CHAMBEREMPTY );
         UI.Msg( 'You pump a shell into the shotgun chamber.' );
       end;
     if (BF_GUNRUNNER in Self.FFlags) and canFire and (Shots < 3) and GetRunning then
     with CreateAutoTarget( Player.Vision ) do
     try
       FTargetPos := Current;
       if FTargetPos <> FPosition then
       begin
         // TODO: fix?
         if Inv.Slot[ efWeapon ].CallHookCheck( Hook_OnFire, [Self,false] ) then
           ActionFire( FTargetPos, Inv.Slot[ efWeapon ] );
       end;
     finally
       Free;
     end;
    end;
  FSpeedCount := iTempSC;

  if FRun.Active and (not FPathRun) then
    if RunStopNear or ((not Option_RunOverItems) and (TLevel( Parent ).Item[ FPosition ] <> nil)) then
    begin
      FPathRun := False;
      FRun.Stop;
    end;
end;

function TPlayer.HandleCommandValue( aCommand : Byte ) : Boolean;
var iLevel      : TLevel;
    iDir        : TDirection;
    iItem       : TItem;
    iMoveResult : TMoveResult;
    iID         : AnsiString;
    iName       : AnsiString;
    iFireDesc   : AnsiString;
    iCount      : Byte;
    iFlag       : byte;
    iScan       : TCoord2D;
    iTarget     : TCoord2D;
    iAlt        : Boolean;
    iAltFire    : TAltFire;

    iLimitRange : Boolean;
    iRange      : Byte;
    iCommand    : TCommand;
begin
  iLevel := TLevel( Parent );
  iFlag  := 0;

  if FRun.Active then
  begin
    Inc( FRun.Count );
    if BF_SESSILE in FFlags then
    begin
      FPathRun := False;
      FRun.Stop;
      Exit( Fail('You can''t!',[] ) );
    end;

    if FPathRun then
    begin
      if (not FPath.Found) or (FPath.Start = nil) or (FPath.Start.Coord = FPosition) then
      begin
        FPathRun := False;
        FRun.Stop;
        Exit( False );
      end;
      iDir := NewDirection( FPosition, FPath.Start.Coord );
      FPath.Start := FPath.Start.Child;
    end
    else iDir := FRun.Dir;

    if iDir.code = 5 then
    begin
      if FRun.Count >= Option_MaxWait then begin FPathRun := False; FRun.Stop; end;
    end;
    aCommand := DirectionToInput( iDir );
  end;

  if ( aCommand = COMMAND_ACTION ) then
  begin
    if iLevel.cellFlagSet( FPosition, CF_STAIRS ) then
      aCommand := COMMAND_ENTER
    else
    begin
        if ( iLevel.Item[ FPosition ] <> nil ) and ( iLevel.Item[ FPosition ].isLever ) then
           aCommand := COMMAND_ALTPICKUP 
    end;
  end;

  if ( aCommand = INPUT_OPEN ) then
  begin
    iID := 'open';
    aCommand := COMMAND_ACTION;
    iFlag := CF_OPENABLE;
  end;

  if ( aCommand = INPUT_CLOSE ) then
  begin
    iID := 'close';
    aCommand := COMMAND_ACTION;
    iFlag := CF_CLOSABLE;
  end;

  if ( aCommand = COMMAND_ACTION ) then
  begin
    iCount := 0;
    if iFlag = 0 then
    begin
      for iScan in NewArea( FPosition, 1 ).Clamped( iLevel.Area ) do
        if ( iScan <> FPosition ) and ( iLevel.cellFlagSet(iScan, CF_OPENABLE) or iLevel.cellFlagSet(iScan, CF_CLOSABLE) ) then
        begin
          Inc(iCount);
          iTarget := iScan;
        end;
    end
    else
      for iScan in NewArea( FPosition, 1 ).Clamped( iLevel.Area ) do
        if iLevel.cellFlagSet( iScan, iFlag ) and iLevel.isEmpty( iScan ,[EF_NOITEMS,EF_NOBEINGS] ) then
        begin
          Inc(iCount);
          iTarget := iScan;
        end;
    if iCount = 0 then
    begin
      if iID = ''
        then Exit( Fail( 'There''s nothing you can act upon here.', [] ) )
        else Exit( Fail( 'There''s niLimitRangeo door you can %s here.', [ iID ] ) );
    end;

    if iCount > 1 then
    begin
      if iID = ''
        then iDir := UI.ChooseDirection('action')
        else iDir := UI.ChooseDirection(Capitalized(iID)+' door');
      if iDir.code = DIR_CENTER then Exit( False );
      iTarget := FPosition + iDir;
    end;

    if iLevel.isProperCoord( iTarget ) then
    begin
      if ( (iFlag <> 0) and iLevel.cellFlagSet( iTarget, iFlag ) ) or
          ( (iFlag = 0) and ( iLevel.cellFlagSet( iTarget, CF_CLOSABLE ) or iLevel.cellFlagSet( iTarget, CF_OPENABLE ) ) )
          then 
          begin
            if not iLevel.isEmpty( iTarget ,[EF_NOITEMS,EF_NOBEINGS] ) then
              Exit( Fail( 'There''s something in the way!', [] ) );
            // SUCCESS
          end
          else
          begin
            if iID = ''
              then Exit( Fail( 'You can''t do that!', [] ) )
              else Exit( Fail( 'You can''t %s that.', [ iID ] ) );
          end;
    end
    else Exit( False );
  end;

  if ( aCommand = COMMAND_USE ) then
  begin
    iItem := Inv.Choose([ITEMTYPE_PACK],'use');
    if iItem = nil then Exit( False );
  end;

  if ( aCommand = COMMAND_ALTPICKUP ) then
  begin
    iItem := TLevel(Parent).Item[ FPosition ];
    if ( iItem = nil ) or (not (iItem.isLever or iItem.isPack or iItem.isWearable) ) then
      Exit( Fail( 'There''s nothing to use on the ground!', [] ) );
    aCommand := COMMAND_USE;
  end;

  if ( aCommand = COMMAND_UNLOAD ) then
  begin
    iItem := TLevel(Parent).Item[ FPosition ];
    if (iItem = nil) or ( not (iItem.isRanged or iItem.isAmmoPack ) ) then
    begin
      iItem := Inv.Choose( [ ItemType_Ranged, ItemType_AmmoPack ] , 'unload' );
      if iItem = nil then Exit( False );
    end;
    iName := iItem.Name;

    if iItem.isAmmoPack then
      if not UI.MsgConfirm('An ammopack might serve better in the Prepared slot. Continuing will unload the ammo destroying the pack. Are you sure?', True)
        then Exit( False );

    if (not iItem.isAmmoPack) and (BF_SCAVENGER in FFlags) and
      ((iItem.Ammo = 0) or iItem.Flags[ IF_NOUNLOAD ] or iItem.Flags[ IF_RECHARGE ] or iItem.Flags[ IF_NOAMMO ]) and
      (iItem.Flags[ IF_EXOTIC ] or iItem.Flags[ IF_UNIQUE ] or iItem.Flags[ IF_ASSEMBLED ] or iItem.Flags[ IF_MODIFIED ]) then
    begin
      iID := LuaSystem.ProtectedCall( ['DoomRL','OnDisassemble'], [ iItem ] );
      if iID <> '' then
        if not UI.MsgConfirm('Do you want to disassemble the '+iName+'?', True) then
          iID := '';
    end;
  end;

  if ( aCommand in [ INPUT_FIRE, INPUT_ALTFIRE, INPUT_MFIRE, INPUT_MALTFIRE ] ) then
  begin
    iItem := Inv.Slot[ efWeapon ];
    iAlt  := ( aCommand in [ INPUT_ALTFIRE, INPUT_MALTFIRE ] );
    if (iItem = nil) or (not iItem.isWeapon) then Exit( Fail( 'You have no weapon.', [] ) );
    if not iAlt then
    begin
      if ( aCommand = INPUT_FIRE ) and iItem.isMelee then
      begin
        iDir := UI.ChooseDirection('Melee attack');
        if (iDir.code = DIR_CENTER) then Exit( False );
        iTarget := FPosition + iDir;
        aCommand := COMMAND_MELEE;
      end
      else
        if (not iItem.isRanged) then Exit( Fail( 'You have no ranged weapon.', [] ) );
    end 
    else
    begin
      if iItem.AltFire = ALT_NONE then Exit( Fail('This weapon has no alternate fire mode.', [] ) );
    end;
    if aCommand <> COMMAND_MELEE then
    begin
      if not iItem.CallHookCheck( Hook_OnFire, [Self,iAlt] ) then Exit( False );
    
      if iAlt then
      begin
        if iItem.isMelee and ( iItem.AltFire = ALT_THROW ) then
        begin
          if aCommand = COMMAND_ALTFIRE then
          begin
            iRange      := Missiles[ iItem.Missile ].Range;
            iLimitRange := MF_EXACT in Missiles[ iItem.Missile ].Flags;
            if not Player.doChooseTarget( 'Throw -- Choose target...', iRange, iLimitRange ) then
              Exit( Fail( 'Throwing canceled.', [] ) );
            iTarget := FTargetPos;
          end
          else
            iTarget  := IO.MTarget;
        end;
      end;

      if iItem.isRanged then
      begin
          if not iItem.Flags[ IF_NOAMMO ] then
          begin
            if iItem.Ammo = 0              then Exit( FailConfirm( 'Your weapon is empty.', [] ) );
            if iItem.Ammo < iItem.ShotCost then Exit( FailConfirm( 'You don''t have enough ammo to fire the %s!', [iItem.Name]) );
          end;

          if iItem.Flags[ IF_CHAMBEREMPTY ] then Exit( FailConfirm( 'Shell chamber empty - move or reload.', [] ) );


          if iItem.Flags[ IF_SHOTGUN ] then
            iRange := Shotguns[ iItem.Missile ].Range
          else
            iRange := Missiles[ iItem.Missile ].Range;
          if iRange = 0 then iRange := self.Vision;

          iLimitRange := (not iItem.Flags[ IF_SHOTGUN ]) and (MF_EXACT in Missiles[ iItem.Missile ].Flags);
          if ( aCommand in [ COMMAND_FIRE, COMMAND_ALTFIRE ] ) then
          begin
            iAltFire    := ALT_NONE;
            if iAlt then iAltFire := iItem.AltFire;
            iFireDesc := '';
            case iAltFire of
              ALT_SCRIPT  : iFireDesc := LuaSystem.Get([ 'items', iItem.ID, 'altname' ],'');
              ALT_AIMED   : iFireDesc := 'aimed';
              ALT_SINGLE  : iFireDesc := 'single';
            end;
            if iFireDesc <> '' then iFireDesc := ' (@Y'+iFireDesc+'@>)';

            if iAltFire = ALT_CHAIN then
            begin
              case FChainFire of
                0 : iFireDesc := ' (@Ginitial@>)';
                1 : iFireDesc := ' (@Ywarming@>)';
                2 : iFireDesc := ' (@Rfull@>)';
              end;
              if not Player.doChooseTarget( Format('Chain fire%s -- Choose target or abort...', [ iFireDesc ]), iRange, iLimitRange ) then Exit( Fail( 'Targeting canceled.', [] ) );
            end
            else
              if not Player.doChooseTarget( Format('Fire%s -- Choose target...',[ iFireDesc ]), iRange, iLimitRange ) then Exit( Fail( 'Targeting canceled.', [] ) );
            iTarget := FTargetPos;
          end
          else
          begin
            iTarget := IO.MTarget;
          end;
          if iLimitRange then
            if Distance( self.Position, iTarget ) > iRange then
              Exit( Fail( 'Out of range!', [] ) );
      end;
    end;
    if aCommand = INPUT_MFIRE    then aCommand := COMMAND_FIRE;
    if aCommand = INPUT_MALTFIRE then aCommand := COMMAND_ALTFIRE;
  end;

  if ( aCommand = INPUT_MATTACK ) then
  begin
    aCommand := COMMAND_MELEE;
    iTarget  := FPosition + NewDirectionSmooth( FPosition, IO.MTarget );
  end;

  if ( aCommand = COMMAND_DROP ) then
  begin
    iItem := Inv.Choose([],'drop');
    if iItem = nil then Exit( False );
  end;

  if ( aCommand in INPUT_MOVE ) then
  begin
    FLastTargetPos.Create(0,0);
    if BF_SESSILE in FFlags then
      Exit( Fail('You can''t!',[] ) );

    iDir := InputDirection( aCommand );
    iTarget := FPosition + iDir;
    iMoveResult := TryMove( iTarget );

    if (not FPathRun) and FRun.Active and (
         ( FRun.Count >= Option_MaxRun ) or
         ( iMoveResult <> MoveOk ) or
         iLevel.cellFlagSet( iTarget, CF_NORUN ) or
         (not iLevel.isEmpty(iTarget,[EF_NOTELE]))
       ) then
    begin
      FPathRun := False;
      FRun.Stop;
      Exit( False );
    end;

    case iMoveResult of
       MoveBlock :
         begin
           if iLevel.isProperCoord( iTarget ) and iLevel.cellFlagSet( iTarget, CF_PUSHABLE ) then
             aCommand := COMMAND_ACTION
           else
           begin
             if Option_Blindmode then UI.Msg( 'You bump into a wall.' );
             Exit( False );
           end;
         end;
       MoveBeing : aCommand := COMMAND_MELEE;
       MoveDoor  : aCommand := COMMAND_ACTION;
       MoveOk    : aCommand := COMMAND_MOVE;
    end;
  end;

  if aCommand in [ INPUT_INVENTORY, INPUT_EQUIPMENT, INPUT_MSCRUP, INPUT_MSCRDOWN ] then
  begin
    iCommand.Command:= COMMAND_NONE;
    case aCommand of
      INPUT_INVENTORY : iCommand := Inv.View;
      INPUT_EQUIPMENT : iCommand := Inv.RunEq;
      INPUT_MSCRUP,
      INPUT_MSCRDOWN  : iCommand := Inv.DoScrollSwap;
    end;
    if iCommand.Command = COMMAND_NONE then Exit( False );
    if iCommand.Command <> COMMAND_SWAPWEAPON then
      Exit( HandleCommand( iCommand ) );
  end;

  if aCommand = COMMAND_SWAPWEAPON then
  begin
    if ( Inv.Slot[ efWeapon ] <> nil )  and ( Inv.Slot[ efWeapon ].Flags[ IF_CURSED ] ) then Exit( Fail('You can''t!',[]) );
    if ( Inv.Slot[ efWeapon2 ] <> nil ) and ( Inv.Slot[ efWeapon2 ].isAmmoPack )        then Exit( Fail('Nothing to swap!',[]) );
  end;

  if ( aCommand in [ COMMAND_ACTION, COMMAND_MELEE, COMMAND_MOVE ] ) then
    Exit( HandleCommand( TCommand.Create( aCommand, iTarget ) ) );

  if ( aCommand in [ COMMAND_FIRE, COMMAND_ALTFIRE ] ) then
    Exit( HandleCommand( TCommand.Create( aCommand, iTarget, iItem ) ) );

  if ( aCommand in [ COMMAND_DROP, COMMAND_UNLOAD, COMMAND_USE, COMMAND_WEAR ] ) then
    Exit( HandleCommand( TCommand.Create( aCommand, iItem, iID ) ) );

  if ( aCommand in [ COMMAND_TACTIC, COMMAND_WAIT, COMMAND_SWAPWEAPON, COMMAND_ENTER, COMMAND_RELOAD, COMMAND_ALTRELOAD, COMMAND_PICKUP ] ) then
    Exit( HandleCommand( TCommand.Create( aCommand ) ) );

  if aCommand = INPUT_YIELD then Exit( True );

  Exit( Fail('Unknown command. Press "?" for help.', []) );
end;

procedure TPlayer.AIAction;
var iLevel      : TLevel;
    iCommand    : Byte;
    iAlt        : Boolean;
begin
  iCommand := 0;
  // FArmor color //
  iLevel := TLevel( Parent );
  FEnemiesInVision := iLevel.BeingsVisible;
  if FEnemiesInVision > 1 then begin FPathRun := False; FRun.Stop; end;

  if iLevel.Item[ FPosition ] <> nil then
  begin
    if iLevel.Item[ FPosition ].Hooks[ Hook_OnEnter ] then
    begin
      iLevel.Item[ FPosition ].CallHook( Hook_OnEnter, [ Self ] );
      if (FSpeedCount < 5000) or (Doom.State <> DSPlaying) then Exit;
    end
    else
    if not FPathRun then
      with iLevel.Item[ FPosition ] do
        if isLever then
           UI.Msg('There is a %s here.', [ DescribeLever( iLevel.Item[ FPosition ] ) ] )
        else
          if Flags[ IF_PLURALNAME ]
            then UI.Msg('There are %s lying here.', [ GetName( False ) ] )
            else UI.Msg('There is %s lying here.', [ GetName( False ) ] );
  end;

  if FRun.Active then
  begin
    if IO.CommandEventPending then
    begin
      FPathRun := False;
      FRun.Stop;
      IO.ClearEventBuffer;
    end
    else
    begin
      iCommand := INPUT_WALKNORTH;

      if not GraphicsVersion then
        IO.Delay( Option_RunDelay );
    end;
  end;

  if FEnemiesInVision < 2 then
  begin
    FChainFire := 0;
    if FBersekerLimit > 0 then Dec( FBersekerLimit );
  end;

try

  if FChainFire > 0 then
    iCommand := COMMAND_ALTFIRE;

  if iCommand = 0
    then iCommand := IO.GetCommand
    else UI.MsgUpDate;

  // === MOUSE HANDLING ===
  if iCommand in [ INPUT_MLEFT, INPUT_MRIGHT ] then
    iAlt := VKMOD_ALT in IO.Driver.GetModKeyState;

  if iCommand = INPUT_MMIDDLE then
    if IO.MTarget = FPosition
      then iCommand := COMMAND_SWAPWEAPON
      else iCommand := INPUT_EQUIPMENT;

  if iCommand = INPUT_MLEFT then
  begin
    if IO.MTarget = FPosition then
      if iAlt then iCommand := INPUT_INVENTORY
      else
      if iLevel.cellFlagSet( FPosition, CF_STAIRS ) then
        iCommand := COMMAND_ENTER
      else
        if iLevel.Item[ FPosition ] <> nil then
          if iLevel.Item[ FPosition ].isLever then
            iCommand := COMMAND_ALTPICKUP
          else
            iCommand := COMMAND_PICKUP
          else
            iCommand := INPUT_INVENTORY
    else
    if Distance( FPosition, IO.MTarget ) = 1
      then iCommand := DirectionToInput( NewDirection( FPosition, IO.MTarget ) )
      else if iLevel.isExplored( IO.MTarget ) then
      begin
        if FPath.Run( FPosition, IO.MTarget, 200) then
        begin
          FPath.Start := FPath.Start.Child;
          FRun.Active := True;
          FPathRun := True;
        end
        else
        begin
          UI.Msg('Can''t get there!');
          Exit;
        end;
      end
      else
      begin
        UI.Msg('You don''t know how to get there!');
        Exit;
      end;
  end;

  if iCommand = INPUT_MRIGHT then
  begin
    if (IO.MTarget = FPosition) or
      ((Inv.Slot[ efWeapon ] <> nil) and (Inv.Slot[ efWeapon ].isRanged) and (not (Inv.Slot[efWeapon].GetFlag(IF_NOAMMO))) and (Inv.Slot[ efWeapon ].Ammo = 0))  then
    begin
      if iAlt
        then iCommand := COMMAND_ALTRELOAD
        else iCommand := COMMAND_RELOAD;
    end
    else if (Inv.Slot[ efWeapon ] <> nil) and (Inv.Slot[ efWeapon ].isRanged) then
    begin
      if iAlt
        then iCommand := INPUT_MALTFIRE
        else iCommand := INPUT_MFIRE;
    end
    else iCommand := INPUT_MATTACK;
  end;
  // === MOUSE HANDLING END ===

    // Handle commands that should be handled by the UI
  // TODO: Fix
  case iCommand of
    INPUT_ESCAPE     : begin if GodMode then Doom.SetState( DSQuit ); Exit; end;
    INPUT_LOOK       : begin UI.Msg( '-' ); UI.LookMode; Exit; end;
    INPUT_PLAYERINFO : begin doScreen; Exit; end;
    INPUT_QUIT       : begin doQuit; Exit; end;
    INPUT_HELP       : begin Help.Run; Exit; end;
    INPUT_MESSAGES   : begin IO.RunUILoop( TUIMessagesViewer.Create( IO.Root, UI.MsgGetRecent ) ); Exit; end;
    INPUT_ASSEMBLIES : begin IO.RunUILoop( TUIAssemblyViewer.Create( IO.Root ) ); Exit; end;
    INPUT_HARDQUIT   : begin
      Option_MenuReturn := False;
      doQuit(True);
      Exit;
    end;
    INPUT_SAVE      : begin doSave; Exit; end;
    INPUT_TRAITS    : begin IO.RunUILoop( TUITraitsViewer.Create( IO.Root, @FTraits, ExpLevel ) );Exit; end;
    INPUT_RUNMODE   : begin doRun;Exit; end;

    INPUT_EXAMINENPC   : begin ExamineNPC; Exit; end;
    INPUT_EXAMINEITEM  : begin ExamineItem; Exit; end;
    INPUT_GRIDTOGGLE: begin if GraphicsVersion then SpriteMap.ToggleGrid; Exit; end;
    INPUT_SOUNDTOGGLE  : begin SoundOff := not SoundOff; Exit; end;
    INPUT_MUSICTOGGLE  : begin
                             MusicOff := not MusicOff;
                             if MusicOff then IO.PlayMusic('')
                                         else IO.PlayMusic(iLevel.ID);
                             Exit;
                           end;
  end;

  HandleCommandValue( iCommand );
except
  on e : Exception do
  begin
    if CRASHMODE then raise;
    ErrorLogOpen('CRITICAL','Player action exception!');
    ErrorLogWriteln('Error message : '+e.Message);
    ErrorLogClose;
    UI.ErrorReport(e.Message);
    CRASHMODE := True;
  end;
end;
end;

procedure TPlayer.LevelEnter;
begin
  if FHP < (FHPMax div 10) then
    AddHistory('Entering level '+IntToStr(CurrentLevel)+' he was almost dead...');

  FStatistics.Map['damage_on_level'] := 0;
  FStatistics.Map['entry_time'] := FStatistics.GameTime;

  FTargetPos.Create(0,0);
  FTactic.Reset;
  FChainFire := 0;
end;

procedure TPlayer.doScreen;
begin
  IO.RunUILoop( TUIPlayerViewer.Create( IO.Root ) );
end;

procedure TPlayer.ExamineNPC;
var iLevel : TLevel;
    iWhere : TCoord2D;
    iCount  : Word;
begin
  iLevel := TLevel(Parent);
  iCount := 0;
  for iWhere in iLevel.Area do
    if iLevel.isVisible(iWhere) and ( iLevel.Being[iWhere] <> nil ) and (iWhere <> FPosition) then
    with iLevel.Being[iWhere] do
    begin
      Inc(iCount);
      UI.Msg('You see '+ GetName(false) + ' (' + WoundStatus + ') ' + BlindCoord(iWhere-Self.FPosition)+'.');
    end;
  if iCount = 0 then UI.Msg('There are no monsters in sight.');
end;

procedure TPlayer.ExamineItem;
var iLevel : TLevel;
    iWhere : TCoord2D;
    iCount : Word;
begin
  iLevel := TLevel(Parent);
  iCount := 0;
  for iWhere in iLevel.Area do
    if iLevel.isVisible(iWhere) then
      if iLevel.Item[iWhere] <> nil then
      with iLevel.Item[iWhere] do
      begin
        Inc(iCount);
        UI.Msg('You see '+ GetName(false) + ' ' + BlindCoord(iWhere-Self.FPosition)+'.');
      end;
  if iCount = 0 then UI.Msg('There are no items in sight.');
end;

// pieczarki oliwki szynka kielbasa peperoni motzarella //

destructor TPlayer.Destroy;
begin
  FStatistics.Destroy;
  FreeAndNil( FKills );
  inherited Destroy;
end;

procedure TPlayer.IncStatistic(const aStatisticID: AnsiString; aAmount: Integer);
begin
  FStatistics.Map[ aStatisticID ] := FStatistics.Map[ aStatisticID ] + aAmount;
end;

procedure TPlayer.Kill( BloodAmount : DWord; aOverkill : Boolean; aKiller : TBeing; aWeapon : TItem );
var iLevel : TLevel;
begin
  iLevel := TLevel(Parent);
  if (Doom.State <> DSPlaying) and IsPlayer then Exit;

  if not CallHookCheck( Hook_OnDieCheck, [ aOverkill ] ) then
  begin
    HP := Max(1,HP);
    Exit;
  end;

  if (aKiller <> nil) and (not Doom.GameWon) then
  begin
    FKilledBy          := aKiller.ID;
    FKilledMelee       := aKiller.MeleeAttack;
  end;

  Blood( NewDirection(0,0),15 );
  iLevel.DropCorpse( FPosition, GetLuaProtoValue('corpse') );

  if aOverkill
     then iLevel.playSound( 'gib',FPosition )
     else playSound(FSounds.Die);

  UI.WaitForAnimation;

  UI.MsgEnter('You die!...');
  Doom.SetState( DSFinished );

  if NukeActivated > 0 then
  begin
    NukeActivated := 1;
    iLevel.NukeTick;
    UI.WaitForAnimation;
  end;
  WriteMemorial;
end;

procedure TPlayer.WriteMemorial;
var iCopyText : Text;
    iString   : AnsiString;

procedure ScoreCRC(var Score : LongInt);
begin
  if Score < 2000 then Exit;
  while not ((Score mod 277) = 0) do Inc(Score);
  Inc(Score,FExpLevel);
  Inc(Score,CurrentLevel*3);
end;

begin
  if MemorialWritten then Exit;
  MemorialWritten := True;
  if FScore = -1000 then Exit;

  FScore += Max(FExp + (CurrentLevel * 1000) + Max(FHP,0) * 20,0);
  if FScore < 0 then FScore := 0;
  if GodMode   then FScore := 0;
  if Doom.Difficulty = DIFF_NIGHTMARE then FScore -= FStatistics.GameTime div 500;

  if Doom.GameWon then FScore += FScore div 4;

  FStatistics.Update;

  FScore := Round( FScore * Double(LuaSystem.Get([ 'diff', Doom.Difficulty, 'scorefactor' ])) );

  Doom.CallHook(Hook_OnMortem,[ not NoPlayerRecord ]);
  LuaSystem.ProtectedCall(['DoomRL','award_medals'],[]);
  LuaSystem.ProtectedCall(['DoomRL','register_awards'],[NoPlayerRecord]);

  // FScore
  ScoreCRC(FScore);

  HOF.Add(Name,FScore,FKilledBy,FExpLevel,CurrentLevel,Doom.Challenge);

  Assign(MortemText, WritePath + 'mortem.txt' );
  Rewrite(MortemText);
  WritingMortem := True;
  LuaSystem.ProtectedCall(['DoomRL','print_mortem'],[]);
  WritingMortem := False;
  Close(MortemText);

  FScore := -1000;

  if Option_MortemArchive then
  begin
    iString :=  WritePath + 'mortem'+PathDelim+ToProperFilename('['+FormatDateTime(Option_TimeStamp,Now)+'] '+Name)+'.txt';
    Assign(iCopyText,iString);
    Log('Writing mortem...: '+iString);
    Rewrite(iCopyText);
    Assign(MortemText, WritePath + 'mortem.txt');
    Reset(MortemText);
    
    while not EOF(MortemText) do
    begin
      Readln(MortemText,iString);
      Writeln(iCopyText,iString);
    end;

    Close(iCopyText);
    Close(MortemText);
  end;
end;

function TPlayer.DescribeLever( aItem : TItem ) : string;
begin
  if BF_LEVERSENSE2 in FFlags then Exit('lever ('+LuaSystem.Get(['items',aItem.ID,'desc'],'')+')' );
  if BF_LEVERSENSE1 in FFlags then Exit('lever ('+LuaSystem.Get(['items',aItem.ID,'good'],'')+')' );
  Exit('lever');
end;

procedure TPlayer.AddHistory( const aHistory : Ansistring );
begin
  LuaSystem.ProtectedCall(['player','add_history'],[ Self, aHistory ]);
end;

procedure TPlayer.UpdateVisual;
var Spr : LongInt;
    Gray : TColor;
begin
  Color := LightGray;
  if Inv.Slot[ efTorso ] <> nil then
    Color := Inv.Slot[ efTorso ].Color;
  Gray := NewColor( 200,200,200 );
  FSprite.CosColor := True;
  if Inv.Slot[ efTorso ] <> nil then
  begin
    FSprite.Glow      := Inv.Slot[ efTorso ].Sprite.Glow;
    FSprite.Color     := Inv.Slot[ efTorso ].Sprite.Color;
    FSprite.GlowColor := Inv.Slot[ efTorso ].Sprite.GlowColor;
  end
  else
  begin
    FSprite.Glow     := False;
    FSprite.Color    := GRAY;
  end;
  FSprite.SpriteID := HARDSPRITE_PLAYER;
  if Inv.Slot[ efWeapon ] <> nil then
  begin
    FSprite.SpriteID := LuaSystem.Get( ['items', Inv.Slot[ efWeapon ].ID, 'psprite'], 0 );
    if FSprite.SpriteID <> 0 then Exit;
    // HACK via the spritesheet
    Spr := Inv.Slot[ efWeapon ].Sprite.SpriteID - SpriteCellRow;
    if (Spr <= 12) and (Spr >= 1) then
      FSprite.SpriteID := Spr
    else
      if Inv.Slot[ efWeapon ].isMelee then FSprite.SpriteID := 2 else FSprite.SpriteID := 11;
  end;
end;

function TPlayer.ASCIIMoreCode : AnsiString;
begin
  if (Inv.Slot[efTorso] <> nil) and (UI.ASCII.Exists(Inv.Slot[efTorso].ID)) then
    exit(Inv.Slot[efTorso].ID);
  Exit('player');
end;

procedure TPlayer.SetTired(Value: Boolean);
begin
  if Value then FTactic.Current := TacticTired   else FTactic.Current := TacticNormal;
end;

procedure TPlayer.SetRunning(Value: Boolean);
begin
  if Value then FTactic.Current := TacticRunning else FTactic.Current := TacticTired;
end;

function TPlayer.GetTired: Boolean;
begin
  Exit( FTactic.Current = TacticTired );
end;

function TPlayer.GetRunning: Boolean;
begin
  Exit( FTactic.Current = TacticRunning );
end;

function TPlayer.GetSkillRank: Word;
begin
  Exit( HOF.SkillRank );
end;

function TPlayer.GetExpRank: Word;
begin
  Exit( HOF.ExpRank );
end;

procedure TPlayer.doUpgradeTrait;
begin
  IO.RunUILoop( TUITraitsViewer.Create( IO.Root, @FTraits, ExpLevel, @OnTraitConfirm) );
end;

function lua_player_set_affect(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    Being   : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  if not (Being is TPlayer) then Exit(0);
  Player.FAffects.Add(State.ToId(2),State.ToInteger(3));
  Result := 0;
end;

function lua_player_get_affect_time(L: Plua_State): Integer; cdecl;
var State    : TDoomLuaState;
    Being    : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  if not (Being is TPlayer) then Exit(0);
  State.Push(Player.FAffects.getTime(State.ToId(2)));
  Result := 1;
end;

function lua_player_remove_affect(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    Being   : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  if not (Being is TPlayer) then Exit(0);
  Player.FAffects.Remove(State.ToId(2));
  Result := 0;
end;

function lua_player_is_affect(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    Being   : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  State.Push( ( Being is TPlayer ) and Player.FAffects.IsActive(State.ToId(2)));
  Result := 1;
end;

function lua_player_add_exp(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    Being   : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  if not (Being is TPlayer) then Exit(0);
  Player.addExp(State.ToInteger(2));
  Result := 0;
end;


function lua_player_has_won(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
begin
  State.Init(L);
  State.Push(Doom.GameWon);
  Result := 1;
end;

function lua_player_power_backpack(L: Plua_State): Integer; cdecl;
var State     : TDoomLuaState;
    Being     : TBeing;
    Item      : TItem;
    Node, Temp: TNode;
var List : TItemList;
    Cnt  : Byte;

begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  if not (Being is TPlayer) then Exit(0);
  Include(Player.FFlags,BF_BackPack);

  for Cnt in TItemSlot do
    List[ Cnt ] := nil;

  Cnt := 0;
  for Node in Player do
    if Node is TItem then
      if (Node as TItem).isAmmo then
      begin
        Inc( Cnt );
        List[ Cnt ] := Node as TItem;
      end;

  Temp := TNode.Create;
  for Item in List do
    if Item <> nil then
      Temp.Add( Item );

  for Node in Temp do
    with Node as TItem do
      Player.Inv.AddAmmo( NID, Ammo );

  FreeAndNil( Temp );
  Result := 0;
end;

function lua_player_win(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    Being   : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  if not (Being is TPlayer) then Exit(0);
  Doom.SetState( DSFinished );
  Doom.GameWon := True;
  Result := 0;
end;

function lua_player_continue_game(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    Being   : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  if not (Being is TPlayer) then Exit(0);
  Doom.SetState( DSPlaying );
  Result := 0;
end;

function lua_player_choose_trait(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    Being   : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  if not (Being is TPlayer) then Exit(0);
  Player.doUpgradeTrait();
  Result := 0;
end;

function lua_player_level_up(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    Being   : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  if not (Being is TPlayer) then Exit(0);
  Player.LevelUp();
  Result := 0;
end;

function lua_player_exit(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    Being   : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  if not (Being is TPlayer) then Exit(0);
  if Doom.State <> DSSaving then Doom.SetState( DSNextLevel );
  Player.FSpeedCount := 4000;
  if State.StackSize < 2 then
  begin
    Player.SpecExit   := '';
    Exit(0);
  end;
  if State.IsNumber(2) then
  begin
    Player.SpecExit     := '';
    Player.CurrentLevel := State.ToInteger(2)-1;
    Exit(0);
  end;
  if State.IsString(2) then
  begin
    Player.SpecExit    := State.ToString(2);
    Exit(0);
  end;
  State.Error('Player.exit - bad parameters!');
  Result := 0;
end;

function lua_player_quick_weapon(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    Being   : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  if not (Being is TPlayer) then Exit(0);
  Player.doQuickWeapon(State.ToString(2));
  Result := 0;
end;

function lua_player_set_inv_size(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    Being   : TBeing;
    n : byte;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  if not (Being is TPlayer) then Exit(0);
  n := State.ToInteger(2);
  if (n = 0) or (n > High(TItemSlot)) then
    State.Error( 'Inventory size must be in the 1..'+IntToStr(High(TItemSlot))+' range!' );
  Player.InventorySize := n;
  Result := 0;
end;


function lua_player_mortem_print(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    Being   : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  if not (Being is TPlayer) then Exit(0);
  if not WritingMortem then raise Exception.Create('player:mortem_print called in wrong place!');
  Writeln(MortemText, State.ToString(2) );
  Result := 0;
end;

function lua_player_get_trait(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    Being   : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  if not (Being is TPlayer) then Exit(0);
  State.Push( Player.FTraits.Values[ State.ToInteger( 2 ) ] );
  Result := 1;
end;

function lua_player_get_trait_hist(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    Being   : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  if not (Being is TPlayer) then Exit(0);
  State.Push( Player.FTraits.GetHistory );
  Result := 1;
end;

const lua_player_lib : array[0..17] of luaL_Reg = (
      ( name : 'set_affect';      func : @lua_player_set_affect),
      ( name : 'get_affect_time'; func : @lua_player_get_affect_time),
      ( name : 'remove_affect';   func : @lua_player_remove_affect),
      ( name : 'is_affect';       func : @lua_player_is_affect),
      ( name : 'add_exp';         func : @lua_player_add_exp),
      ( name : 'has_won';         func : @lua_player_has_won),
      ( name : 'get_trait';       func : @lua_player_get_trait),
      ( name : 'get_trait_hist';  func : @lua_player_get_trait_hist),
      ( name : 'power_backpack';  func : @lua_player_power_backpack),
      ( name : 'win';             func : @lua_player_win),
      ( name : 'continue_game';   func : @lua_player_continue_game),
      ( name : 'choose_trait';    func : @lua_player_choose_trait),
      ( name : 'level_up';        func : @lua_player_level_up),
      ( name : 'exit';            func : @lua_player_exit),
      ( name : 'quick_weapon';    func : @lua_player_quick_weapon),
      ( name : 'set_inv_size';    func : @lua_player_set_inv_size),
      ( name : 'mortem_print';    func : @lua_player_mortem_print),
      ( name : nil;               func : nil; )
);

class procedure TPlayer.RegisterLuaAPI();
begin
  LuaSystem.Register( 'player', lua_player_lib );
end;

end.

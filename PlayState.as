package
{
    import org.flixel.*;
    import flash.geom.*;
    import flash.events.Event;
    import flash.utils.getDefinitionByName;
    import flash.utils.getQualifiedClassName;
    import flash.filters.BlurFilter;

    import mochi.as3.MochiDigits;
    
    public class PlayState extends FlxState
    {
        // Forcing flash to do some imports (weird)
        Reed;Castle;Treeline;Farmland;Wall;Torch;Shop;Firefly;
        
		// [Embed(source="assets/aurora.ttf",fontName="Aurora",embedAsCFF="false")] protected var font:String;
        [Embed(source="assets/04b03.ttf",fontName="04b03",embedAsCFF="false")] protected var font:String;
        
		
        [Embed(source='/assets/levels/compiled/fields.oel', mimeType="application/octet-stream")] private const LevelCity:Class;
        // Graphics
        [Embed(source='/assets/gfx/tiles.png')] private const TilesImg:Class;
        [Embed(source='/assets/gfx/skyline_hills.png')]  private const SkylineHillsImg:Class;
        [Embed(source='/assets/gfx/skyline_trees.png')]  private const SkylineTreesImg:Class;
        [Embed(source='/assets/gfx/hill.png')] public const HillImg:Class;
        // Sounds
        [Embed(source="/assets/sound/hit.mp3")] private var HitSound:Class;
        [Embed(source="/assets/sound/hitbig.mp3")] private var HitbigSound:Class;
        // Env sounds
        [Embed(source="/assets/sound/cicada.mp3")] private var CicadaSound:Class;
        [Embed(source="/assets/sound/owls.mp3")] private var OwlsSound:Class;
        [Embed(source="/assets/sound/birds.mp3")] private var BirdsSound:Class;
        
        //Music
        [Embed(source="/assets/music/night1.mp3")] private var MusicNight1:Class;
        [Embed(source="/assets/music/night2.mp3")] private var MusicNight2:Class;
        [Embed(source="/assets/music/night3.mp3")] private var MusicNight3:Class;
        [Embed(source="/assets/music/night4.mp3")] private var MusicNight4:Class;
        [Embed(source="/assets/music/night5.mp3")] private var MusicNight5:Class;        
        [Embed(source="/assets/music/day1.mp3")] private var MusicDay1:Class;
        [Embed(source="/assets/music/day2.mp3")] private var MusicDay2:Class;
        [Embed(source="/assets/music/day3.mp3")] private var MusicDay3:Class;
        [Embed(source="/assets/music/day4.mp3")] private var MusicDay4:Class;
        [Embed(source="/assets/music/day5.mp3")] private var MusicDay5:Class;        

        
        // DISPLAY GROUPS
        public var sky:Sky;
        public var sunmoon:SunMoon;
        public var backdropFar:FlxBackdrop;
        public var backdropClose:FlxBackdrop;
        public var backdrop:FlxGroup;
        public var haze:Haze;
        
        public var player:FlxSprite;
        public var bunnies:FlxGroup;
        public var farmland:FlxGroup;
        public var coins:FlxGroup;
        public var beggars:FlxGroup;
        public var characters:FlxGroup;
        public var trolls:FlxGroup;
        public var trollsNoCollide:FlxGroup;
        public var gibs:FlxGroup;
        public var indicators:FlxGroup;
        
        public var walls:FlxGroup;
        public var level:FlxGroup;
        public var archers:FlxGroup;
        public var objects:FlxGroup;
        public var shops:FlxGroup;
        public var floor:FlxTilemap;
        public var farmlands:FlxGroup;
        public var props:FlxGroup;        
        public var lights:FlxGroup;
        public var darkness:FlxSprite;
        public var water:Water;
        public var arrows:FlxGroup;
        public var fx:FlxGroup;
        public var fog:Fog;
        public var text:FlxText;
        public var centerText:FlxText;
        public var sack:Coinsack;
        public var noise:FlxSprite;
        
        public var weather:Weather;
        
        // Extra references
        public var castle:Castle;
        public var minimap:Minimap;
        
        public var weatherInput:FlxInputText;
        
        
        //CONSTANTS
        public static const CHEATS:Boolean = false;
        public static const WEATHERCONTROLS:Boolean = false;
        
        public static const GAME_WIDTH:int = 3840;
        public static const MIN_KINGDOM_WIDTH:int = 200;
        
        public static const MAX_BUNNIES:int = 50;
        public static const MIN_BUNNY_SPAWNTIME:Number = 6.0;
        
        public static const MIN_TROLL_SPAWNTIME:Number = 1.0;

        public static const TROLL_WALL_DAMAGE:Number = 2.0;
		
		public static const TEXT_MAX_ALPHA:Number = 0.7;
		public static const TEXT_READ_SPEED:Number = 0.20;
        public static const TEXT_MIN_TIME:Number = 6;

        // Game vars
        public var kingdomLeft:Number = 1920-200;
        public var kingdomRight:Number = 1920+200;
        public var groundHeight:int = 132;
        public var phase:int = 0;
        public var phasesPaused:Boolean = false;
        public var timeToNextPhase:Number = 0;
        public var bunnySpawnTimer:Number = 0.0;
        public var trollSpawnTimer:Number = 0.0;
        public var trollsToSpawn:Array = [];
        public var minBeggars:int = 0;
        public var retreatDelay:Number = 0;
        public var gameover:Boolean = false;
        public var day:MochiDigits = new MochiDigits(0)
        
        public var trollHealth:Number = 1;
        public var trollMaxSpeed:Number = 20;
        public var trollJumpHeight:Number = 20;
        public var trollJumpiness:Number = 30;
        public var trollConfusion:Number = 30;
        public var trollBig:Boolean = false;
        
        public var grassTiles:Array;
        
        // Progress variables
        public var reachedVillage:Boolean        = false;
        public var recruitedCitizen:Boolean      = false;
        public var boughtItem:Boolean            = false;
        public var buyBowAdvice:Boolean      = false;
        public var buyScytheAdvice:Boolean      = false;
        public var expandedKingdomAdvice:Boolean = false;
        public var horseAdvice:Boolean           = false;
        public var outOfGoldAdvice:Boolean = false;
        public var savedProgress:String          = null;
        public var restoreProgress:String        = null;
        
        // Internals
		public var textTimeout:Number = 0;
		public var textQueue:Array = [];
        public var cameraTarget:CameraTarget;
        public var cameraTimeout:Number = 0;
        
        public var music:FlxSound = null;
        public var cicada:FlxSound = null;
        public var owls:FlxSound = null;
        public var birds:FlxSound = null;
        
        // Cheatvars
        private var cheatNoTrolls:Boolean = true;
        private var untouchable:Boolean = true;

        public function PlayState(progress:String=null){
            super();
            restoreProgress = progress;
        }
        
        //=== INITIALIZATION ==//
        override public function create():void
        {
            FlxG.camera.bgColor = 0xFFafb4c2;
            FlxG.camera.bounds = new FlxRect(0,0,GAME_WIDTH,196)
            FlxG.worldBounds.width = GAME_WIDTH;
            FlxG.worldBounds.height = 300;
            /*FlxG.framerate = 30;*/
            buildLevel(LevelCity);
            weather.tweenTo(WeatherPresets.FOGGY, 0);
            
            if (CHEATS){
                add(minimap = new Minimap(0, FlxG.height - 1 ,FlxG.width, 1));
                minimap.add(trolls, 0xFF87B587);
                minimap.add(trollsNoCollide, 0xFF0000FF);
                minimap.add(player, 0xff765DB3);
                minimap.add(beggars, 0xFF7D6841);
                minimap.add(characters, 0xFFA281F8);
                minimap.add(walls, 0xFF969696);
            }
            
            showCoins();

            // Load up environment sounds
            cicada = FlxG.play(CicadaSound, 0.0, true);
            owls = FlxG.play(OwlsSound, 0.0, true);
            birds = FlxG.play(BirdsSound, 0.0, true);
            
            // Camera
            add(cameraTarget = new CameraTarget());
            cameraTarget.target = player;
            cameraTarget.offset.y = -4;
            cameraTarget.snap();
            FlxG.camera.follow(cameraTarget,FlxCamera.STYLE_LOCKON);
            
            // Set up some debugging
            FlxG.watch(this, 'timeToNextPhase');
            FlxG.watch(weather, 'timeOfDay');
            FlxG.watch(weather, 'progress');
            FlxG.watch(weather, 'ambient');
            FlxG.watch(weather, 'ambientAmount');
            FlxG.watch(this, 'phase');
            
            // Set up weathercontrols
            if (WEATHERCONTROLS){
                weatherInput = new FlxInputText(10, 10, 400, 32, '',0, null, 16);
                weatherInput.scrollFactor.x = weatherInput.scrollFactor.y = 0;
                add(weatherInput);
                // var setWeatherButton:FlxButton = new FlxButton(10,30,"SET", setWeatherFromInput);
                // setWeatherButton.scrollFactor.x = setWeatherButton.scrollFactor.y = 0;
                // add(setWeatherButton);
                FlxG.mouse.show()
            }
        }
        
        public function setWeatherFromInput():void{
            var txt:String = weatherInput.textField.text;
            weatherInput.textField.text = '';
            var object:Object = JSON.parse(txt)
            FlxG.stage.focus = weatherInput.textField;
            var w:Object = {'sky':0,'horizon':0,'haze':0,'darknessColor':0,'darkness':0,
                            'contrast':-0,'saturation':0,'ambient':0,'wind':0,
                            'fog':0,'timeOfDay':0,'sunTint':0}
            for (var k:String in w){
                w[k] = weather.targetState[k];
                if (k in object){
                    if (object[k].substr(0, 2) == '0x'){
                        var col:uint = parseInt(object[k]);
                        FlxG.log(k + ': ' + col.toString(16));
                        w[k] = col;
                    } else {
                        var f:Number = parseFloat(object[k]);
                        w[k] = f;
                        FlxG.log(k + ': ' + f);
                    }
                }
            }
            weather.tweenTo(w, 10);
        }
        
        public function progressAll():void{
            reachedVillage = true;
            recruitedCitizen = true;
            boughtItem = true;
            buyBowAdvice = true;
            buyScytheAdvice = true;
            expandedKingdomAdvice = true;
        }
               
        public function buildLevel(levelXML:Class):void{
            //Load XML
            var oel:XML = new XML(new levelXML);
            //Variables
            var backdropFarGraphic:Class = this[oel.@backdropFarImg] as Class;
            var backdropCloseGraphic:Class = this[oel.@backdropCloseImg] as Class;
            var waterHeight:int = oel.@waterHeight;
            darkness = new FlxSprite(0,0).makeGraphic(FlxG.width, FlxG.height,0x88000000)
            
            //Basic setup
            weather = new Weather();
            add(sky = new Sky(weather));
            add(sunmoon = new SunMoon(weather));
            add(backdropFar = new FlxBackdrop(backdropFarGraphic, 0.15, 0.2, 0xFF717565));
            add(backdropClose = new FlxBackdrop(backdropCloseGraphic, 0.3, 0.2, 0xFF555849));
            add(backdrop = new FlxGroup());
            add(haze = new Haze(0,0,weather));
            // Movables
            add(archers = new FlxGroup(10))
            add(objects = new FlxGroup());
            add(shops = new FlxGroup());
            add(bunnies = new FlxGroup());
            add(beggars = new FlxGroup());
            add(player = new Player(100,68));
            add(characters = new FlxGroup());            
            
            add(trolls = new FlxGroup());
            add(trollsNoCollide = new FlxGroup());
            add(walls = new FlxGroup());
            add(coins = new FlxGroup(100));
            add(gibs = new FlxGroup(200));
            add(indicators = new FlxGroup());

            // Level
            add(level = new FlxGroup());
            add(floor = new FlxTilemap());
            add(farmlands = new FlxGroup())
            add(props = new FlxGroup());
            // Effects
            add(lights = new FlxGroup());
            darkness.scrollFactor.x = darkness.scrollFactor.y = 0;
            darkness.blend = 'multiply';
            add(darkness);
            
            add(text = new FlxText(10, 138, FlxG.width, "TEXT"));
            // FlxG.log(font)
            text.setFormat("04b03", 8, 0xFFFFFFFF, "left", 0xCC333333);
            text.visible = false;
            text.scrollFactor.x = 0;
            text.alpha = 1.0;

            add(centerText = new FlxText(0, FlxG.height/2 - 32, FlxG.width, "TEXT"));

            centerText.setFormat("04b03", 32, 0xFFFFFFFF, "center", 0xAA333333);
            centerText.visible = false;
            centerText.scrollFactor.x = 0;
            centerText.alpha = 1.0;
            
            add(water = new Water(-4,waterHeight,FlxG.width+8,44,lights,weather));
            add(arrows = new FlxGroup(64));
            add(fx = new FlxGroup());
						
			add(sack = new Coinsack(270, 2));
			
            add(fog = new Fog(weather));
			
            add(noise = new FlxSprite(0,0));
            noise.scrollFactor.x = noise.scrollFactor.y = 0;
            noise.makeGraphic(FlxG.width,FlxG.height,0xFFFF00FF)
            noise.pixels.noise(0,0,255,7,true);
            noise.alpha = 0.015;
            
            //Add backdrop objects
            var o:XML;
            if (oel.backdrop != undefined){
                buildObjects(oel.backdrop[0].*,backdrop);
                for (var i:int = 0; i < backdrop.length; i ++){
                    backdrop.members[i].scrollFactor.x = 0.5;
                }
            }
            // Add Ground Tiles
            if (oel.ground != undefined){
                var tileWidth:uint = oel.ground[0].@tileWidth;
                var tileHeight:uint = oel.ground[0].@tileHeight;
                var mapData:String = oel.ground.toString();
                floor.loadMap(mapData, TilesImg, tileWidth, tileHeight);
            }

            grassTiles = new Array();
            for (i = 0; i < floor.widthInTiles; i++){
                var t:int = floor.getTile(i, 4);
                if ((t >= 7 && t <= 11) || (t >= 17 && t <= 18)){
                    grassTiles.push(i);
                }
            }
            
            // Add ground collision proxy because this is a flat level.
            var collider:FlxSprite = new FlxSprite(0,132.2).makeGraphic(FlxG.worldBounds.width,32,0x00FF00FF)
            collider.immovable = true;
            level.add(collider);

            collider = new FlxSprite(0,0).makeGraphic(8,200,0x00FF00FF);
            collider.immovable = true;
            level.add(collider);

            collider = new FlxSprite(FlxG.worldBounds.width - 8,0).makeGraphic(8,200,0x00FF00FF);
            collider.immovable = true;
            level.add(collider);
                        
            // Add Walls
            if (oel.walls != undefined){
                buildObjects(oel.walls[0].*,walls);
            }

            // Set the closest walls to a first build stage
            for (i = 0; i < walls.length; i ++){
                var w:Wall = walls.members[i] as Wall;
                if ((w.x + w.width) > kingdomLeft && w.x < kingdomRight){
                    w.build()
                }
            }
            
            // Add level objects
            if (oel.objects != undefined){
                buildObjects(oel.objects[0].Shop,shops);
                buildObjects(oel.objects[0].Castle,objects);
            }
            
             // Add level objects
            if (oel.farmlands != undefined){
                buildObjects(oel.farmlands[0].*,farmlands);
            }
            
            // Add props
            if (oel.props != undefined){
                buildObjects(oel.props[0].*,props);
            }
            
            // Add lights
            if (oel.lights != undefined){
                buildObjects(oel.lights[0].*,lights);
            }
        }
        
        /**
         * Builds and adds to groups the objects from given xml nodes
         */
        public function buildObjects(nodes:XMLList, group:FlxGroup):void{
            for each(var node:XML in nodes){
                var objType:String = node.name();
                var obj:FlxSprite;
                try {
                    var classRef:Class = getDefinitionByName(objType) as Class;
                    obj = new classRef(node.@x, node.@y);
                } catch(error:ReferenceError) {
                    var simpleGraphic:Class = this[objType+"Img"]; //getDefinitionByName(objType+"Img") as Class;
                    obj = new FlxSprite(node.@x, node.@y, simpleGraphic)
                }
                group.add(obj);
            }
        }
        
        //=== GAME LOGIC ===//       
        override public function update():void{
            // Collisions

            if (restoreProgress){
                setProgress(restoreProgress);
                restoreProgress = null;
            }

            FlxG.collide(level, coins);
            FlxG.collide(level, trolls);
            FlxG.collide(level, trollsNoCollide);
            FlxG.collide(level, gibs);
            FlxG.overlap(trolls, walls, this.trollWall);
            FlxG.overlap(trollsNoCollide, walls, this.trollWall);
            FlxG.overlap(arrows, trolls, this.trollShot);
            FlxG.overlap(arrows, trollsNoCollide, this.trollShot);
            FlxG.overlap(arrows, bunnies, this.bunnyShot);
            FlxG.overlap(coins, characters,this.pickUpCoin);
            FlxG.overlap(coins, player,this.pickUpCoin);
            FlxG.overlap(coins, beggars, this.pickUpCoin);
            FlxG.overlap(coins, trolls, this.pickUpCoin);
            FlxG.overlap(coins, trollsNoCollide, this.pickUpCoin);
            FlxG.overlap(trolls, characters, this.trollHit);
            FlxG.overlap(trollsNoCollide, characters, this.trollHit);
            FlxG.overlap(trolls, beggars, this.trollHit);
            FlxG.overlap(trollsNoCollide, beggars, this.trollHit);
            if (!(CHEATS && untouchable)){
                FlxG.overlap(trolls, player, this.trollHit);
                FlxG.overlap(trollsNoCollide, player, this.trollHit);
            }
			FlxG.overlap(characters, player, this.giveTaxes);
            // Update weather
            weather.update();
            
            // Gamestate
            if (timeToNextPhase <= 0){
                nextPhase();
            } else if (!phasesPaused){
                timeToNextPhase -= FlxG.elapsed;
            }
            kingdomRight = Math.max(GAME_WIDTH/2 + MIN_KINGDOM_WIDTH/2, kingdomRight - FlxG.elapsed*4);
            kingdomLeft = Math.min(GAME_WIDTH/2 - MIN_KINGDOM_WIDTH/2, kingdomLeft + FlxG.elapsed*4);
            
            // Spawn bunnies using logistic growth
            var p:Number = (bunnies.countLiving() + 2) / (MAX_BUNNIES + 2);
            if (bunnySpawnTimer <= 0){
                bunnySpawnTimer = MIN_BUNNY_SPAWNTIME;
                var probAdd:Number = 0.5 + 2*p*(1-p);
                if (FlxG.random() < probAdd){
                    var rx:int = int(FlxG.random()*grassTiles.length);
                    bunnies.add(new Bunny(grassTiles[rx]*32,0));
                }
            } else {
                bunnySpawnTimer -= FlxG.elapsed;
            }
            
            // Spawn beggars
            if (beggars.countLiving() < minBeggars){
                beggars.add(new Citizen((FlxG.random() < 0.5) ? 16 : GAME_WIDTH-16,0));
            }
            
            // Spawn trolls
            updateTrollSpawn()
            trollSpawnTimer -= FlxG.elapsed;
            if (retreatDelay > 0){
                retreatDelay -= FlxG.elapsed
                if (retreatDelay <= 0){
                    trolls.callAll("retreat");
                    trollsNoCollide.callAll("retreat");
                }
            }
            
			
            // Text update
            if (textTimeout <= 0){
				showText()
            } else {
    			text.alpha = Math.min(TEXT_MAX_ALPHA, textTimeout);
                textTimeout -= FlxG.elapsed;
            }
            if (centerText.visible && centerText.alpha < 0.001){
                centerText.visible = false;
            } else {
                centerText.alpha -= 0.05 * FlxG.elapsed;
            }
            
            // Camera follow timeout
            if (cameraTarget.target != player){
                if (cameraTimeout <= 0){
                    // Reset the cameratarget.
                    cameraTarget.target = player;
                    cameraTarget.lead = 48;
                } else {
                    cameraTimeout -= FlxG.elapsed;
                }
            }
            
            // Progress update
            if (player.x > GAME_WIDTH/2 && !reachedVillage) {
                reachedVillage = true;
                if (beggars.length > 0){
                    panTo(beggars.members[0], 5.0);
                    showText("Throw some coins [DOWN] near them.");
                }
            }
            
            if (recruitedCitizen && !boughtItem && !buyBowAdvice){
                buyBowAdvice = true;
                showText("Buy them bows to defend and hunt for you.");
                panTo(shops.members[1], 7.5);
            }

            if (buyBowAdvice && !buyScytheAdvice && cameraTarget.target == player){
                buyScytheAdvice = true;
                showText("Buy them scythes to build and farm for you.");
                panTo(shops.members[0], 7.5);   
            }

            
            if (boughtItem && !expandedKingdomAdvice && characters.length >= 4 
                && weather.timeOfDay > 0.3 && weather.timeOfDay < 0.6){
                expandedKingdomAdvice = true;
                showText("Expand your kingdom by building a wall here.");
                panTo(walls.members[1], 5.0, -12);
            }

            this.updateEnvironmentSounds();

            if(gameover && FlxG.mouse.justPressed())
            {
                FlxG.mouse.hide();
                // var newState:PlayState = new PlayState(savedProgress);
                // FlxG.switchState(newState);
                FlxG.switchState(new PlayState(savedProgress));
                // FlxG.log("Switching gamestate")
            }
            
            super.update();

            if (FlxG.keys.justPressed("S"))
            {
                if (FlxG.stage.displayState == 'normal') {
                    FlxG.stage.displayState = 'fullScreen';
                } else {
                    FlxG.stage.displayState = 'normal';
                }
            }

            
            if (CHEATS){
                if (FlxG.keys.justPressed("F")) {
                    var c:Citizen = new Citizen ((kingdomRight+kingdomLeft) / 2, 0);
                    characters.add(c);
                    c.morph(Citizen.FARMER);
                    showText("Spawned farmer.")
                }

                if (FlxG.keys.justPressed("H")) {
                    var h:Citizen = new Citizen ((kingdomRight+kingdomLeft) / 2, 0);
                    characters.add(h);
                    h.morph(Citizen.HUNTER);
                    showText("Spawned farmer.")
                }

                if (FlxG.keys.justPressed("T")) {
                    cheatNoTrolls = !cheatNoTrolls;
                    showText("Trolls " + (cheatNoTrolls ? "disabled" : "enabled"))
                }

                if (FlxG.keys.justPressed("U")) {
                    untouchable = !untouchable; 
                    showText("Untouchable " + (untouchable ? "enabled" : "disabled"))   
                }
            
                if (FlxG.keys.justPressed("N")) {
                    timeToNextPhase = 1.0;
                    showText("Skip phase.");
                }
                
                if (FlxG.keys.justPressed("B")) {
                    beggars.add( new Citizen ((kingdomRight+kingdomLeft) / 2, 0));
                    showText("Spawned beggar.")
                }

                if (FlxG.keys.justPressed("I")) {
                    trollBig = !trollBig;
                    showText("Trolls " + (trollBig ? "big." : "normal."));
                }


                if (FlxG.keys.justPressed('A')) {
                    progressAll();
                    showText("Full progress")
                }
            
                
                if (FlxG.keys.justPressed("R")){
                    spawnTrolls(2)
                    showText("Spawned 2 trolls")
                }
                
                if (FlxG.keys.justPressed("P")){
                    phasesPaused = !phasesPaused;
                    showText("Phases " + (phasesPaused ? "paused" : "resumed"))
                }

                if (FlxG.keys.justPressed("ENTER")){
                    setWeatherFromInput();
                }
                            
                if (FlxG.keys.justPressed("C")){
                    (player as Player).coins += 1;
                    showText((player as Player).coins + " coins.")
                }

                if (FlxG.keys.justPressed("ONE")){
                    // setProgress('D1 A2 X1000 B2 P0 F0 H0 W000011 C0 G7 S00');
                }
                if (FlxG.keys.justPressed("TWO")){
                    // setProgress('D2 A7 X1000 B2 P0 F1 H2 W000011 C0 G4 S00');
                }
                if (FlxG.keys.justPressed("THREE")){
                    setProgress('D3 A12 X1713 B2 P0 F2 H4 W010011 C1 S01 G3');
                }
                if (FlxG.keys.justPressed("FOUR")){
                    setProgress('D4 A17 X1932 B2 P1 F3 H6 W220021 C1 S02 G7');   
                }
                if (FlxG.keys.justPressed("FIVE")){
                    setProgress('D5 A21 X1899 B4 P1 F3 H6 W010031 C2 S00 G0');   
                }
                if (FlxG.keys.justPressed("SIX")){
                    setProgress('D6 A25 X2235 B2 P2 F1 H10 W010031 C2 S11 G0');
                }
                if (FlxG.keys.justPressed("SEVEN")){
                    setProgress('D7 A29 X2146 B2 P5 F2 H8 W030031 C2 S00 G0');   
                }
                if (FlxG.keys.justPressed("EIGHT")){
                    setProgress('D8 A33 X2318 B3 P1 F6 H9 W040011 C2 S01 G2');   
                }
                if (FlxG.keys.justPressed("NINE")){
                    setProgress('D9 A37 X1467 B2 P1 F6 H7 W140041 C2 S02 G0');   
                }
            }
        }
          
        public function phaseFirst():void{
            beggars.add( new Citizen (kingdomRight+580, 0)); 
            beggars.add( new Citizen (kingdomRight+600, 0));
            minBeggars = 5;
        }
        public function phaseBeforeNightOne():void{
            showText("Night comes, be careful."); 
        }
        
        public function phaseNightOne():void{
            trollStats(24, 1, 20, 999999, false, 16.0); // Nojump
            spawnTrolls(2);
            if (player.x < GAME_WIDTH / 2){
                panTo(trolls.members[0]);
            } else {
                panTo(trolls.members[1]);
            }
            showText("They will noodle your stuff away.")
        }
        
        // These trolls still won't scale your lowest walls
        public function phaseNightTwo():void{
            trollStats(26, 1, 20, 2, false, 12.0); //Jump0
            spawnTrolls(12);
        }
        
        // These WILL scale the lowest walls
        public function phaseNightThree():void{
            trollStats(26, 1, 30, 2, false, 12.0); // Grunts
            spawnTrolls(20);
        }
        
        // The trolls are a little tougher now.
        public function phaseNightFour():void{
            trollStats(26, 3, 30, 2, false, 12.0);
            spawnTrolls(24);
        }
        
        // They are faster but more chaotic, they might
        // break your walls, which will kill you in the next wave.
        public function phaseNightFive():void{
            trollStats(35, 2, 38, 2, false, 4.0); // Chaotic
            spawnTrolls(36);
        }

        // These trolls will scale the stone walls
        public function phaseNightSix():void{
            trollStats(30, 3, 45, 2, false, 10.0);
            spawnTrolls(8);
        }

        // Boss wave trolls
        public function phaseNightSeven():void{
            // trollMaxSpeed = 30;
            // trollHealth = 1
            // spawnTrolls(32);
            trollStats(20, 30, 10, 999999, true, 16.0)
            spawnTrolls(2);
        }

        // Since the boss probably broke your walls
        // these trolls jump very high, there is no
        // disadvantage to not having walls.
        // You will need them back in the next wave though.
        public function phaseNightEight():void{
            trollStats(40, 4, 50, 3, false, 12.0)
            spawnTrolls(16);
        }

        // You need the highest walls here
        public function phaseNightNine():void{
            trollStats(30, 4, 45, 4, false, 8.0)
            spawnTrolls(24);
        }

        // Kill the player off
        public function phaseNightTen():void{
            trollStats(20, 30, 10, 999999, true, 16.0); // Boss
            spawnTrolls(4);
            trollStats(30, 4, 45, 4, false, 8.0); // Strong 
            spawnTrolls(20);
            trollStats(40, 2, 50, 3, false, 12.0); // Jumper
            spawnTrolls(10);
            trollStats(26, 1, 30, 2, false, 12.0); // Grunts
            spawnTrolls(40);
        }
        
        public function phaseNightCycle():void{
            var difficulty:Number = day.value - 10;
            trollStats(30, 3 + 2 * difficulty, 45, 4, false, 8.0); // Strong 
            spawnTrolls(int(10 + difficulty));
            if (day.value % 2 == 0){
                trollStats(20, 30, 10, 999999, true, 16.0); // Boss
                spawnTrolls(int(2 * difficulty));
            }
        }
        
        public const PHASES:Array = [
            // INTRO (0-3)
            [WeatherPresets.FOGGY, 10, null, phaseFirst, null],
            // ONE (4-9)
            [WeatherPresets.DAWN, 25, null, daybreak, null],
            [WeatherPresets.SUNNY, 30, null, null, null],
            [WeatherPresets.EVENING, 20, null, null, null],
            [WeatherPresets.NIGHT, 20, null, phaseBeforeNightOne, MusicNight2],
            [null, 50, null, phaseNightOne, null],
            // TWO (10-14)
            [WeatherPresets.DAWNLIGHTPINK, 20, null, daybreak, null],
            [WeatherPresets.DAYWINDYCLEAR, 30, null, null, MusicDay1],
            [WeatherPresets.DUSKYELLOW, 20, null, null, null],
            [WeatherPresets.EVENINGORANGE, 20, null, null, MusicNight3],
            [WeatherPresets.NIGHTGREEN, 60, 30, phaseNightTwo, null], // GREEN
            // THREE (15-18)
            [WeatherPresets.DAWNGREY, 20, null, daybreak, null],
            [WeatherPresets.DAYBLEAK, 50, null, null, MusicDay2],
            [WeatherPresets.DUSKWARM, 20, null, null, null],
            [WeatherPresets.EVENINGBLACK, 20, null, null, MusicNight4],
            [WeatherPresets.NIGHTDARK, 60, 30, phaseNightThree, null],
            // FOUR (19-22)
            [WeatherPresets.DAWNBLEAK, 20, null, daybreak, null],
            [WeatherPresets.DAYSOFT, 40, null, null, null],
            [WeatherPresets.EVENINGMONOTONE, 30, null, null, MusicNight5],
            [WeatherPresets.NIGHTSUPERDARK, 65, 30, phaseNightFour, null],
            // FIVE (23-26)
            [WeatherPresets.DAWNLIGHTPINK, 20, null, daybreak, MusicDay3],
            [WeatherPresets.DAYBLEAK, 55, null, null, null],
            [WeatherPresets.EVENINGFOGGY, 40, null, null, MusicNight4],
            [WeatherPresets.NIGHTFOGGY, 60, 30, phaseNightFive, null],
            // SIX (27-30)
            [WeatherPresets.DAWNBLEAK, 25, null, daybreak, MusicDay4],
            [WeatherPresets.DAYMONOCHROME, 60, null, null, null],            
            [WeatherPresets.DUSKPINK, 15, null, null, null],
            [WeatherPresets.NIGHTCLEAR, 70, 30, phaseNightSix, MusicNight4],
            // SEVEN (31-34)
            [WeatherPresets.DAWNCLEARORANGE, 20, null, daybreak, null], 
            [WeatherPresets.DAYCLEARCOLD, 40, null, null, MusicDay3],
            [WeatherPresets.DUSKCLEAR, 20, null, null, null],
            [WeatherPresets.NIGHTSHINE, 70, 30, phaseNightSeven, MusicNight3],
            // EIGHT (35-38)
            [WeatherPresets.DAWNREDMOON, 40, null, daybreak, MusicDay5],
            [WeatherPresets.DAYORANGESKY, 40, null, null, null],
            [WeatherPresets.DUSKFOGGY, 20, null, null, null],
            // BIG WAVE
            [WeatherPresets.NIGHTPURPLE, 80, 30, phaseNightEight, MusicNight4],  
            // NINE (39-42)
            [WeatherPresets.DAWNBRIGHT, 20, null, daybreak, null],
            [WeatherPresets.DAYPASTEL, 75, null, null, MusicDay2],            
            [WeatherPresets.DUSKTAN, 20, null, null, MusicNight4],
            // SINGLE TROLL, MASSIVE HEALTH
            [WeatherPresets.NIGHTREDMOON, 60, 30, phaseNightNine, null],
            // TEN (43)
            [WeatherPresets.DAWNBROWN, 20, null, daybreak, null],
            [WeatherPresets.DAYDUSTY, 40, null, null, null],
            [WeatherPresets.DUSKRED, 20, null, null, MusicNight3],
            // EVERYTHING, YOU DIE HERE.
            [WeatherPresets.NIGHTLONG, 60, 30, phaseNightTen, null],
            [WeatherPresets.DAWNEARLY, 15, null, trollRetreat, null],

        ];
        
        public const PHASES_CYCLE:Array = [
            [WeatherPresets.DAWNREDMOON, 20, null, daybreak, null],
            [WeatherPresets.DAYPASTEL, 40, null, null, null],
            [WeatherPresets.DUSKTAN, 20, null, null, null],
            [WeatherPresets.NIGHTLONG, 30, null, null, MusicNight5],
            [null, 55, null, phaseNightCycle, null]
        ];
        
        
        public function nextPhase():void{
            if (phasesPaused){
                return;
            }
            var currentPhase:Array;
            if (phase < PHASES.length){
                currentPhase = PHASES[phase];
            } else {
                var p:int = (phase - PHASES.length) % 5;
                currentPhase = PHASES_CYCLE[p]
            }
            var weatherTweenTime:Number;
            timeToNextPhase = currentPhase[1];
            // Transform weather
            if (currentPhase[2] == null){
                weatherTweenTime = timeToNextPhase * 0.7;
            } else {
                weatherTweenTime = currentPhase[2]
            }
            if (currentPhase[0] != null){
                weather.tweenTo(currentPhase[0], weatherTweenTime);
            }
            phase += 1;
            // Call the function to do custom actions if there is one
            if (currentPhase[3] != null){
                currentPhase[3]();
            }
            // Play music
            if (currentPhase[4] != null){
                if (this.music != null){
                    this.music.stop();
                }
                this.music = FlxG.play(currentPhase[4]);
                FlxG.log("Playing " + currentPhase[4]);
            }
        }

        public function updateEnvironmentSounds():void{
            var v:Number;
            v = 1 - Math.pow(Math.abs(weather.timeOfDay - 0.7) / 0.1, 2);
            this.cicada.volume = v;

            v = 1 - Math.pow(Math.min(weather.timeOfDay, Math.abs(weather.timeOfDay - 1.0)) / 0.2, 2);
            this.owls.volume = v;

            v = 1 - Math.pow(Math.abs(weather.timeOfDay - 0.4) / 0.25, 2);
            this.birds.volume = v;

            // if (v > 0){
            //     this.cicadas.resume();
            // } else {
            //     this.cicadas.pause();
            // }
        }

        public function trollStats(speed:Number, health:Number, jumpheight:Number, jumpiness:Number=2, big:Boolean=false, confusion:Number=3):void{
            trollMaxSpeed = speed;
            trollHealth = health;
            trollJumpHeight = jumpheight;
            trollJumpiness = jumpiness;
            trollBig = big;
            trollConfusion = confusion;
        }
                
        public function spawnTrolls(amount:int):void{
            if (cheatNoTrolls)
                return;

            while(amount){
                amount -= 2;
            
                var troll:Troll = (trolls.recycle(Troll) as Troll);
                troll.reset(64, groundHeight - 40)
                trollsToSpawn.push(troll);
                
                troll = (trolls.recycle(Troll) as Troll);
                troll.reset(GAME_WIDTH - 64, groundHeight - 40);
                trollsToSpawn.push(troll);

                updateTrollSpawn();    
            }
            
        }
        
        public function updateTrollSpawn():void{
            if (trollsToSpawn.length > 0 && trollSpawnTimer <= 0){
                (trollsToSpawn.shift() as Troll).go();
                (trollsToSpawn.shift() as Troll).go();
                trollSpawnTimer = MIN_TROLL_SPAWNTIME;
            }
        }

        public function daybreak():void{
            trollRetreat();
            (coins.recycle(Coin) as Coin).drop(castle, player);
            if (castle.stage >= 2) {
                (coins.recycle(Coin) as Coin).drop(castle, player);
            }
            day.addValue(1);
            showCenterText(Utils.toRoman(day.value));
            saveProgress();
        }

        public function saveProgress():void{
            var numBeggars:int = beggars.countLiving();
            var numCitizens:Array = [0,0,0,0];
            for (var i:int = 0; i < characters.length; i ++){
                if (characters.members[i] != null && (characters.members[i].alive)){
                    numCitizens[(characters.members[i] as Citizen).occupation] ++;
                }
            }
            numCitizens[Citizen.HUNTER] += Math.max(0, archers.countLiving());
            var wallStages:Array = [];
            for (i = 0; i < walls.length; i ++){
                wallStages.push((walls.members[i] as Wall).stage);
            }

            var s:String = '';
            s += 'D' + day.value + ' ';
            s += 'A' + phase + ' ';
            s += 'X' + int(player.x) + ' ';
            s += 'B' + numBeggars + ' ';
            s += 'P' + numCitizens[Citizen.POOR] + ' ';
            s += 'F' + numCitizens[Citizen.FARMER] + ' ';
            s += 'H' + numCitizens[Citizen.HUNTER] + ' ';
            s += 'W' + wallStages.join('') + ' ';
            s += 'C' + castle.stage + ' ';
            s += 'S' + (shops.members[0] as Shop).supply + (shops.members[1] as Shop).supply + ' ';
            s += 'G' + (player as Player).coins
            FlxG.log(s);
            savedProgress = s;
        }

        public function setProgress(s:String):void{
            // Parse the string
            // 'N1 X1 B2 P0 F0 H0 W000011 C0 G7'
            progressAll();
            FlxG.flash(0xFFFFFFFF, 3);
            FlxG.log("Skip to " + s);

            var newDay:int = parseInt(s.match(/D(\d+)/)[1]);
            var ph:int = parseInt(s.match(/A(\d+)/)[1]);
            var playerX:int = parseInt(s.match(/X(\d+)/)[1]);
            var numBeggars:int = parseInt(s.match(/B(\d+)/)[1]);
            var numPoor:int = parseInt(s.match(/P(\d+)/)[1]);
            var numFarmers:int = parseInt(s.match(/F(\d+)/)[1]);
            var numHunters:int = parseInt(s.match(/H(\d+)/)[1]);
            var wallStages:Array = s.match(/W(\d)(\d)(\d)(\d)(\d)(\d)/);
            var castleStage:int = parseInt(s.match(/C(\d)/)[1]);
            var shopSupply:Array = s.match(/S(\d)(\d)/);
            var gold:int = parseInt(s.match(/G(\d)/)[1]);

            while (beggars.countLiving() < numBeggars){
                beggars.add(new Citizen((kingdomRight + kingdomLeft) / 2,0));
            }

            player.x = playerX;

            characters.callAll('kill');
            archers.callAll('kill');
            var c:Citizen;
            while (numPoor) {
                c = new Citizen ((kingdomRight+kingdomLeft) / 2, 0);
                c.morph(Citizen.POOR);
                characters.add(c);
                numPoor --;
            }

            while (numFarmers) {
                c = new Citizen ((kingdomRight+kingdomLeft) / 2, 0);
                c.morph(Citizen.FARMER);
                characters.add(c);
                numFarmers --;
            }

            while (numHunters) {
                c = new Citizen ((kingdomRight+kingdomLeft) / 2, 0);
                c.morph(Citizen.HUNTER);
                characters.add(c);
                numHunters --;   
            }

            for (var i:int = 0; i < walls.length; i ++){
                (walls.members[i] as Wall).buildTo(parseInt(wallStages[i+1]), true);
            }

            (shops.members[0] as Shop).setSupply(parseInt(shopSupply[0]));
            (shops.members[1] as Shop).setSupply(parseInt(shopSupply[1]));

            castle.morph(castleStage);
            
            (player as Player).changeCoins(gold - (player as Player).coins);

            phase = ph - 1;
            day.setValue(newDay - 1);
            nextPhase();

            trolls.callAll("kill");
            trollsNoCollide.callAll("kill");
            gibs.callAll("kill");

        }
        
        public function trollRetreat(delay:Number=10):void{
            
            retreatDelay = delay;
            
            if (retreatDelay <= 0){
                trollsToSpawn.splice(0);
                trolls.callAll("retreat");
                trollsNoCollide.callAll("retreat");
            }
        }
        
        public function pickUpCoin(coin:FlxObject, char:FlxObject):void{
            if (char is Player){
                (char as Player).pickup(coin);
            } else if (char is Citizen){
                (char as Citizen).pickup(coin);
            } else if (char is Troll){
                (char as Troll).pickup(coin);
            }
        }
		
		public function giveTaxes(char:FlxObject, player:FlxObject):void{
			if (char != player){
				(char as Citizen).giveTaxes(player as Player);
			}
		}
        
        public function trollWall(troll:FlxObject, wall:FlxObject):void{
            FlxObject.separate(troll, wall);
            wall.hurt((troll as Troll).big ? 2 * TROLL_WALL_DAMAGE : TROLL_WALL_DAMAGE);
        }
        
        public function trollShot(arrow:FlxObject, troll:Troll):void{
            if (troll.alive && arrow.exists){
                FlxG.play(HitbigSound).proximity(arrow.x, arrow.y, player, FlxG.width);
                arrow.kill();
                (troll as Troll).getShot();
            }
        }
        
        public function bunnyShot(arrow:FlxObject, bunny:FlxObject):void{
            if (bunny.alive && arrow.exists){
                FlxG.play(HitSound).proximity(arrow.x, arrow.y, player, FlxG.width);
                arrow.kill();
                (bunny as Bunny).getShot(arrow as Arrow);
            }
        }
        
        public function trollHit(troll:FlxObject, char:FlxObject):void{
            if (char is Citizen){
                (char as Citizen).hitByTroll(troll as Troll);
            }
            if (char == player){
                (char as Player).hitByTroll(troll as Troll);
            }
        }

        public function crownStolen():void{
            gameover = true;
            phasesPaused = true;
            trollRetreat(0);
            FlxG.mouse.show();
            showText("No crown, no king. Game over.");
            showText("Click to continue or wait to enter highscore.");
            showText("Click to continue or wait to enter highscore.");
            FlxG.fade(0, 20, endGame);
        }

        public function endGame():void{
            FlxG.switchState(new GameOverState(day.value - 1));
        }
        
        //=== RENDERING ==//
        override public function draw():void{
            darkness.dirty = true;
            darkness.fill(weather.darknessColor);
            
            super.draw();
            weather.ambientTransform.applyFilter(FlxG.camera.buffer);
        }
        
		public function showCoins():void{
            var c:int = (player as Player).coins;
			sack.show(c);
		}
        
        public function showText(t:String=null):void{
			if (t != null){
				textQueue = textQueue.concat(t.split('\n'))
			}
			if (textQueue.length > 0 && textTimeout <= 0){
	            text.text = textQueue.shift();
	            text.visible = true;
				textTimeout = Math.max(TEXT_MIN_TIME, TEXT_READ_SPEED * text.text.length);
			}
        }

        public function showCenterText(t:String):void{
            centerText.text = t;
            centerText.visible = true;
            centerText.alpha = 0.999;
        }
        
        public function panTo(o:FlxSprite, duration:Number=8.0, lead:Number=0):void{
            cameraTimeout = duration;
            cameraTarget.target = o;
            cameraTarget.lead = lead;
        }
    }
}

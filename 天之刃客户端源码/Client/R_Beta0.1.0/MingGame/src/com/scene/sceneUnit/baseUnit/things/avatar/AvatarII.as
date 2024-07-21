package com.scene.sceneUnit.baseUnit.things.avatar {
	import com.globals.GameConfig;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneUnit.baseUnit.OnlyIDCreater;
	import com.scene.sceneUnit.baseUnit.things.common.BitmapMovieClip;
	import com.scene.sceneUnit.baseUnit.things.heartbeat.ThingFrameFrequency;
	import com.scene.sceneUnit.baseUnit.things.resource.SourceManager;
	import com.scene.sceneUnit.baseUnit.things.thing.Thing;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	
	import modules.mypackage.managers.ItemLocator;
	
	import proto.common.p_skin;
	
	public class AvatarII extends Sprite {
		public static const BODY_COMPLETE:String="BodyComplete";
		
		private var onlyKey:String;
		/**分层**/
		public var _effectLayerTop:Sprite;
		public var _effectLayerBottom:Sprite;
		public var _bodyLayer:Sprite;
		private var _shadow:Bitmap;
		
		/**各部件**/
		private var _weapon:AvatarBMC;
		private var _body:AvatarBMC;
		private var _mounts:AvatarBMC;
		
		public var isPerson:Boolean = false;
		public var sex:int;
		public var category:int;
		public var hasInit:Boolean=false;
		
		/**各部件URL**/
		private var oldBodyURL:String;
		private var bodyURL:String="";
		private function set _bodyURL(value:String):void{
			if(bodyURL == value)return;
			oldBodyURL = bodyURL;
			bodyURL = value;
		}
		private function get _bodyURL():String{
			return bodyURL;
		}
		private var oldWeaponURL:String;
		private var weaponURL:String="";
		private function set _weaponURL(value:String):void{
			oldWeaponURL = weaponURL;
			weaponURL = value;
		}
		private function get _weaponURL():String{
			return weaponURL;
		}
		
		private var oldMountsURL:String;
		private var mountsURL:String="";
		private function set _mountsURL(value:String):void{
			oldMountsURL=mountsURL;
			mountsURL = value;
		}
		private function get _mountsURL():String{
			return mountsURL;
		}
		
		/**当前skinVO**/
		private var _skinData:p_skin;
		
		public function get skinData():p_skin {
			return _skinData;
		}
		
		/* 一堆标致符 */
		/**身体部位加载是否完成**/
		private var bodyComplete:Boolean=false;
		private var hasBodyComplete:Boolean=false;
		private function set _bodyComplete(value:Boolean):void{
			bodyComplete=value;
			if(value){
				hasBodyComplete=true;
			}
		}
		
		private function get _bodyComplete():Boolean{
			return bodyComplete;
		}
		/**是否停止播放**/
		private var _isStop:Boolean=false;
		/**是否是裸体**/
		private var _isNude:Boolean=false;
		/**是否是显示**/
		private var _isVisible:Boolean=true;
		/**是否停止更新形象**/
		private var _isTransform:Boolean=false;
		/**是否是飞行坐骑**/
		private var _isSkyMount:Boolean=false;
		
		/**当前状态,默认站立**/
		private var _selectState:String=AvatarConstant.ACTION_STAND;
		/**前一个状态**/
		private var _preState:String=AvatarConstant.ACTION_STAND;
		
		public function get selectState():String {
			return _selectState;
		}
		
		/**坐骑偏移量**/
		private function set mountOffsetX(value:int):void {
			
		}
		
		private var _mountOffsetY:int=0;
		
		private function set mountOffsetY(value:int):void {
			_mountOffsetY=value;
			if (_body)
				_body._skyMountOffsetY=value;
			if (_weapon)
				_weapon._skyMountOffsetY=value;
		}
		
		private function get mountOffsetY():int {
			return _mountOffsetY;
		}
		
		private var _mountStandOffsetY:int=0;
		
		private function set mountStandOffset(value:int):void {
			_mountStandOffsetY=value;
			if (_body)
				_body._skyStandOffsetY=value;
			if (_weapon)
				_weapon._skyStandOffsetY=value;
			if (_mounts)
				_mounts._skyStandOffsetY=value;
		}
		
		/**当前方向,默认向下**/
		private var _selectDir:int=4;
		
		public function get selectDir():int {
			return _selectDir;
		}
		
		/**当前速度,默认120**/
		private var _selectSpeed:int=4;
		
		public function get selectSpeed():int {
			return _selectSpeed;
		}
		
		/**当前帧位**/
		private var _step:int=0;
		
		/**当前动作方向标志**/
		private var _selectStateAndDir:String=AvatarConstant.ACTION_STAND.concat(AvatarConstant.DIR_DOWN);
		
		/**当前状态的maxStep**/
		private var _maxStep:int=0;
		
		public function get maxStep():int {
			return _maxStep;
		}
		
		public function set isTransform(value:Boolean):void {
			_isTransform=value;
		}
		
		public function get isTransform():Boolean {
			return _isTransform;
		}
		
		/**是否暂停播放**/
		public function set isStop(value:Boolean):void {
			_isStop=value;
		}
		
		public function get isStop():Boolean {
			return _isStop;
		}
		
		/**是否隐藏**/
		public function set isVisible(value:Boolean):void {
			_isVisible=value;
			if (_isVisible) {
				play(_selectState, _selectDir, selectSpeed);
			} else {
				stop();
			}
			_effectLayerTop.visible=_isVisible;
			_effectLayerBottom.visible=_isVisible;
			_bodyLayer.visible=_isVisible;
		}
		
		public function get isVisible():Boolean {
			return _isVisible;
		}
		
		/**是否裸体**/
		public function set isNude(value:Boolean):void {
			if (value != _isNude) {
				_isNude=value;
				createSkinURL(_skinData);
				checkURL();
				updataBMC();
			}
		}
		
		public function get isNude():Boolean {
			return _isNude;
		}
		
		/**是否是飞行坐骑**/
		public function set isSkyMount(value:Boolean):void {
			_isSkyMount=value;
			if (_isSkyMount) {
				mountOffsetY=-49;
			} else {
				LoopManager.removeFromSceond(onlyKey);
				mountOffsetY=0;
				if (_body)
					_body.y=0;
				if (_mounts)
					_mounts.y=0;
				if (_weapon)
					_weapon.y=0;
			}
		}
		
		public function get isSkyMount():Boolean {
			return _isSkyMount;
		}
		
		public function AvatarII() {
			onlyKey=OnlyIDCreater.createID();
		}
		
		/**
		 * 初始化
		 * @param $skinData
		 */
		public function initSkin($skinData:p_skin):void {
			createLayer();
			createSkinURL($skinData);
			SourceManager.getInstance().addEventListener(SourceManager.CREATE_COMPLETE, sourceCreateComplete);
			checkURL();
			hasInit=true;
		}
		
		public function createLayer():void {
			addShadow();
			_effectLayerBottom=new Sprite();
			_effectLayerBottom.mouseEnabled=false;
			_effectLayerBottom.mouseChildren=false;
			addChild(_effectLayerBottom);
			_bodyLayer=new Sprite();
			_bodyLayer.mouseEnabled=false;
			_bodyLayer.mouseChildren=false;
			addChild(_bodyLayer);
			_effectLayerTop=new Sprite();
			_effectLayerTop.mouseEnabled=false;
			_effectLayerTop.mouseChildren=false;
			addChild(_effectLayerTop);
		}
		
		/**
		 * 添加到BITMAP容器并放到指定的深度
		 * @param child
		 * @param childName
		 * @return
		 */
		private function addChilds(child:AvatarBMC):void {
			if (_mounts)
				_bodyLayer.addChild(_mounts);
			if (_body)
				_bodyLayer.addChild(_body);
			if (_weapon)
				_bodyLayer.addChild(_weapon);
			
		}
		
		private function createChild(name:String):void {
			switch (name) {
				case "_body":
					_body=new AvatarBMC();
					addChilds(_body);
					_body._skyMountOffsetY=mountOffsetY;
					break;
				case "_weapon":
					_weapon=new AvatarBMC();
					addChilds(_weapon);
					_weapon._skyMountOffsetY=mountOffsetY;
					break;
				case "_mounts":
					_mounts=new AvatarBMC();
					addChilds(_mounts);
					break;
			}
		}
		
		private function removeChilds(child:DisplayObject):void {
			if (child != null) {
				if (child.parent != null)
					child.parent.removeChild(child);
				child=null;
			}
		}
		
		private function createSkinURL($skinData:p_skin):void {
			_skinData=$skinData;
			createClotheURL(_skinData);
			createWeaponURL(_skinData);
			createMountsURL(_skinData);
		}
		
		private function createClotheURL($skinData:p_skin):void{
			if ($skinData.clothes == 0 && $skinData.fashion == 0) {
				//则使用skinid 怪物和人物纠结在一起 后续把URL生成替换到客户端
				if ($skinData.skinid < 10001) {
					_bodyURL=getDefaultURL();
				} else {
					if ($skinData.skinid == 20000 || $skinData.skinid == 20010) {
						_bodyURL=GameConfig.YBC_PATH + $skinData.skinid + '.swf';
					} else {
						_bodyURL=GameConfig.NPC_PATH + $skinData.skinid + '.swf';
					}
				}
			} else {
				//则使用clothes
				if (isNude) { //有clothes但显示裸体
					_bodyURL=getDefaultURL();
				} else {
					if ($skinData.fashion == 0) {
						_bodyURL=GameConfig.EQUIP_PATH + wrapperURL(ItemLocator.getInstance().getForm($skinData.clothes))+'.swf';
					} else {
						_bodyURL=GameConfig.FASHION_PATH + wrapperURL(ItemLocator.getInstance().getForm($skinData.fashion))+ '.swf';
					}
				}
			}
		}
		
		private function createWeaponURL($skinData:p_skin):void{
			if ($skinData.weapon == 0) {
				_weaponURL="";
			} else {
				if ($skinData.weapon == 20011) {
					_weaponURL=GameConfig.YBC_PATH + $skinData.weapon +'.swf';
				} else {
					_weaponURL=GameConfig.EQUIP_PATH + wrapperURL(ItemLocator.getInstance().getForm($skinData.weapon))+'.swf';
				}
			}
		}
		
		private function createMountsURL($skinData:p_skin):void{
			if ($skinData.mounts == 0) {
				_mountsURL="";
				isSkyMount=false;
			} else {
				var mountSkinID:String=ItemLocator.getInstance().getForm($skinData.mounts);
				if (mountSkinID == "10005" || mountSkinID == "10006") {
					isSkyMount=true;
				} else {
					isSkyMount=false;
				}
				_mountsURL=GameConfig.MOUNT_PATH + mountSkinID + '.swf';
				if (!isSkyMount) {
					if ($skinData.skinid % 2 == 1) {
						if(mountSkinID == "10008"){//草尼玛服装
							_bodyURL=GameConfig.ROOT_URL + "com/ui/role/mount/10008man.swf"
						}else{
							_bodyURL=GameConfig.DEFLUT_MOUNT_MAN_URL;
						}
					} else {
						if(mountSkinID == "10008"){
							_bodyURL=GameConfig.ROOT_URL + "com/ui/role/mount/10008woman.swf"
						}else{
							_bodyURL=GameConfig.DEFLUT_MOUNT_WOMAN_URL;
						}
					}
				} else {
					
				}
			}	
		}
		
		/**
		 *检测资源是否存在
		 *
		 */
		private function checkURL():void {
			if (_bodyURL == '') {
				removeChilds(_body);
			} else {
				if (!_body) {
					createChild("_body");
					_body.addEventListener(BitmapMovieClip.END, onActionEnd);
				}
				if (SourceManager.getInstance().has(_bodyURL)) {
					
					if (SourceManager.getInstance().hasComplete(_bodyURL)) {
						setBodyComplete(true);
					} else {
						setBodyComplete(false);
						SourceManager.getInstance().load(_bodyURL);
					}
				} else {
					setBodyComplete(false);
					SourceManager.getInstance().load(_bodyURL);
				}
			}
			if (_weaponURL == '') {
				removeChilds(_weapon);
				_weapon=null;
			} else {
				if (SourceManager.getInstance().has(_weaponURL)) {
					if (SourceManager.getInstance().hasComplete(_weaponURL)) {
						if (!_weapon) {
							createChild("_weapon");
							if (_weaponEffect != null)
								_weapon.filters=_weaponEffect
						}
					} else {
						removeChilds(_weapon);
						_weapon=null;
						SourceManager.getInstance().load(_weaponURL);
					}
				} else {
					removeChilds(_weapon);
					_weapon=null;
					SourceManager.getInstance().load(_weaponURL);
				}
			}
			if (_mountsURL == '') {
				removeChilds(_mounts);
				_mounts=null;
			} else {
				if (SourceManager.getInstance().has(_mountsURL)) {
					if (SourceManager.getInstance().hasComplete(_mountsURL)) {
						if (!_mounts) {
							createChild("_mounts");
						}
					} else {
						removeChilds(_mounts);
						_mounts=null;
						SourceManager.getInstance().load(_mountsURL);
					}
				} else {
					removeChilds(_mounts);
					_mounts=null;
					SourceManager.getInstance().load(_mountsURL);
				}
			}
			
		}
		
		private function sourceCreateComplete(event:DataEvent):void {
			if (_bodyURL == event.data) {
				setBodyComplete(true);
				updataBMC();
			}
			if (_weaponURL == event.data) {
				if (!_weapon) {
					createChild("_weapon");
					if (_weaponEffect != null)
						_weapon.filters=_weaponEffect;
				}
				updataBMC();
			}
			if (_mountsURL == event.data) {
				if (!_mounts) {
					createChild("_mounts");
				}
				updataBMC();
			}
		}
		/**
		 * 获取当前资源后缀 
		 * @return 
		 * 
		 */		
		private function getSuffix():String{
			if(_selectState == AvatarConstant.ACTION_ATTACK_CASTING){
				return "_"+AvatarConstant.TYPE_MAGIC;
			}else if(_selectState == AvatarConstant.ACTION_HURT){
				return "_"+AvatarConstant.TYPE_HURT;
			}else if(_selectState == AvatarConstant.ACTION_DIE){
				return "_"+AvatarConstant.TYPE_DIE;
			}else{
				return "";
			}
		}
		
		private function wrapperURL(skinId:String):String{
			if(isPerson){
				return category+""+sex+""+skinId+getSuffix();
			}	
			return skinId;
		}
		
		private function getDefaultURL():String{
			if(isPerson){
				return GameConfig.EQUIP_PATH+category+""+sex+"100201"+getSuffix()+".swf";
			}
			return "";
		}
		
		/**
		 *
		 * @private
		 * 画阴影
		 *
		 */
		private function addShadow():void {
			if (_shadow != null)
				return;
			_shadow=new Bitmap(SourceManager.getInstance().getShadow());
			_shadow.x=-27;
			_shadow.y=-14;
			addChild(_shadow);
		}
		
		private function updataShadow():void {
			if (_mountsURL != "") {
				_shadow.bitmapData=SourceManager.getInstance().getMountShadow();
				switch (_selectDir) {
					case AvatarConstant.DIR_UP:
						_shadow.x=14;
						_shadow.y=-70;
						_shadow.rotation=90;
						break;
					case AvatarConstant.DIR_RIGHT_UP:
						_shadow.x=40;
						_shadow.y=-5;
						_shadow.rotation=160;
						break;
					case AvatarConstant.DIR_RIGHT:
						_shadow.x=-70;
						_shadow.y=-14;
						_shadow.rotation=0;
						break;
					case AvatarConstant.DIR_RIGHT_DOWN:
						_shadow.x=30;
						_shadow.y=25;
						_shadow.rotation=-160;
						break;
					case AvatarConstant.DIR_DOWN:
						_shadow.x=14;
						_shadow.y=-80;
						_shadow.rotation=90;
						break;
					case AvatarConstant.DIR_LEFT_DOWN:
						_shadow.x=70;
						_shadow.y=-10;
						_shadow.rotation=160;
						break;
					case AvatarConstant.DIR_LEFT:
						_shadow.x=-40;
						_shadow.y=-14;
						_shadow.rotation=0;
						break;
					case AvatarConstant.DIR_LEFT_UP:
						_shadow.x=60;
						_shadow.y=35;
						_shadow.rotation=-160;
						break;
				}
			} else {
				_shadow.bitmapData=SourceManager.getInstance().getShadow();
				_shadow.x=-27;
				_shadow.y=-14;
				_shadow.rotation=0;
			}
		}
		
		/**
		 * @private
		 * 移除阴影
		 */
		private function removeShadow():void {
			var s:Shape=getChildByName('shadow') as Shape
			if (_shadow) {
				removeChild(_shadow);
				_shadow=null;
			}
		}
		
		/**
		 * 控制avatar的颜色滤镜
		 * @param $redOffset
		 * @param $greenOffset
		 * @param $blueOffset
		 */
		public function colorFilter($redOffset:Number=0, $greenOffset:Number=0, $blueOffset:Number=0):void {
			var matrix:Array=new Array();
			matrix=matrix.concat([$redOffset, 0, 0, 0, 0]); // red
			matrix=matrix.concat([0, $greenOffset, 0, 0, 0]); // green
			matrix=matrix.concat([0, 0, $blueOffset, 0, 0]); // blue
			matrix=matrix.concat([0, 0, 0, 1, 0]); // alpha
			_bodyLayer.filters=[new ColorMatrixFilter(matrix)];
		}
		
		public function cleanFilter():void {
			_bodyLayer.filters=[];
		}
		
		/**
		 * 给武器滤镜
		 * @param $array
		 *
		 */
		private var _weaponEffect:Array;
		
		public function addWeaponEffect($array:Array):void {
			if (_weapon != null) {
				_weapon.filters=$array;
			}
			_weaponEffect=$array;
		}
		
		public function updataSkin($skinData:p_skin):void {
			if (_isTransform)
				return;
			if (compareSkin($skinData, _skinData)) {
				createSkinURL($skinData);
				checkURL();
				updataBMC();
				updataShadow();
			}
		}
		
		/**
		 * 比较对象是否相同
		 */
		private function compareSkin(skinA:p_skin, skinB:p_skin):Boolean {
			if (skinA.skinid != skinB.skinid)
				return true;
			if (skinA.clothes != skinB.clothes)
				return true;
			if (skinA.weapon != skinB.weapon)
				return true;
			if (skinA.mounts != skinB.mounts)
				return true;
			if (skinA.fashion != skinB.fashion)
				return true;
			return false;
		}
		
		public function get bobyHeight():int {
			return _bodyLayer.height;
		}
		
		public function getAttackPoint():Point {
			return new Point(_body.width / 2, _body.height / 2);
		}
		
		public function getHurtPoint():Point {
			return new Point(_body.width / 2, _body.height / 2);
		}
		
		/**设置当前状态**/
		private var _oldState:String;
		public function setState($state:String):void {
			_selectState=$state;
			if(isPerson && _selectState != _oldState && skinData){
				createClotheURL(skinData);
				createWeaponURL(skinData);
				checkURL();
			}
			_oldState = _selectState;
		}
		
		/**设置当前方向**/
		public function setDirection($dir:int):void {
			_selectDir=$dir
			//死亡和坐下特殊情况固定方向
			if (selectState == AvatarConstant.ACTION_DIE || selectState == AvatarConstant.ACTION_SIT) {
				_selectDir=AvatarConstant.DIR_DOWN;
			}
			updataShadow();
		}
		
		/**设置当前速度**/
		public function setSpeed($speed:int):void {
			_selectSpeed=$speed;
		}
		
		/**设置身体是否加载完成**/
		public function setBodyComplete(value:Boolean):void {
			_bodyComplete=value;
			if (_bodyComplete) {
				hideChangeEffect();
				var event:DataEvent=new DataEvent(BODY_COMPLETE);
				var h:int=SourceManager.getInstance().getResource(_bodyURL).getHeight();
				if (isSkyMount) {
					h+=-mountOffsetY;
				}
				event.data=h.toString();
				dispatchEvent(event);
			} else {
				if(hasBodyComplete){
					showChangeEffect();
				}
			}
		}
		
		public function play($state:String, $dir:int, $speed:int, isLoop:Boolean=false):void {
			if ($state == AvatarConstant.ACTION_HURT) {
				if (_selectState == AvatarConstant.ACTION_ATTACK || _selectState == AvatarConstant.ACTION_ATTACK_ARROW || _selectState == AvatarConstant.ACTION_ATTACK_CASTING || _selectState == AvatarConstant.ACTION_WALK) {
					return;
				}
			}
			if ($state != AvatarConstant.ACTION_STAND && _selectState == $state && $dir == _selectDir)
				return;
			_preState=selectState; //记录当前状态
			setState($state);
			setDirection($dir);
			setSpeed($speed);
			_selectStateAndDir=_selectState.concat("_d").concat(_selectDir);
			if ($state == AvatarConstant.ACTION_STAND || $state == AvatarConstant.ACTION_WALK) {
				display(true);
			} else {
				display(false);
			}
			
		}
		
		public function stop():void {
			isStop=true;
			if (_body) {
				_body.stop()
			}
			if (_weapon) {
				_weapon.stop()
			}
			if (_mounts) {
				_mounts.stop()
			}
		}
		
		public function resume():void {
			isStop=false;
			if (_body != null)
				updataBMC();
		}
		
		/**
		 * 不改变动作的情况下更新显示,主要是用于换装备的情况
		 */
		private function updataBMC():void {
			if (selectState == AvatarConstant.ACTION_STAND || selectState == AvatarConstant.ACTION_WALK) {
				display(true);
			} else {
				display(false);
			}
		}
		
		private var _standB:Boolean=false;
		
		private function flyMountStand():void {
			_standB=!_standB
			if (_standB) {
				if (_body)
					_body.y=-5;
				if (_mounts)
					_mounts.y=-5;
				if (_weapon)
					_weapon.y=-5;
			} else {
				if (_body)
					_body.y=0;
				if (_mounts)
					_mounts.y=0;
				if (_weapon)
					_weapon.y=0;
			}
		}
		
		/**
		 * 渲染
		 */
		private var interval:int=0;
		
		protected function display($isLoop:Boolean=false):void {
			if (_bodyComplete) {
				if (_isTransform && _selectState == AvatarConstant.ACTION_SIT) {
					if (_body) {
						_body.play(_bodyURL, AvatarConstant.ACTION_STAND, _selectDir, speed, true);
					}
					return;
				}
				if (isSkyMount) { //飞行坐骑
					if (_selectState == AvatarConstant.ACTION_STAND) {
						LoopManager.addToSecond(onlyKey, flyMountStand);
					} else {
						LoopManager.removeFromSceond(onlyKey);
					}
					if (_body) {
						_body.play(_bodyURL, AvatarConstant.ACTION_STAND, _selectDir, ThingFrameFrequency.STAND, $isLoop);
					}
					if (_weapon) {
						_weapon.play(_weaponURL, AvatarConstant.ACTION_STAND, _selectDir, ThingFrameFrequency.STAND, $isLoop);
					}
					if (_mounts) {
						_mounts.play(_mountsURL, AvatarConstant.ACTION_STAND, _selectDir, ThingFrameFrequency.STAND, $isLoop);
					}
					return;
				}
				var speed:int=_selectSpeed;
				if (_skinData.skinid == 10086 || _skinData.skinid == 10089 || _skinData.skinid == 10090 || _skinData.skinid == 10092 || _skinData.skinid == 10094 || _skinData.skinid == 10098) {
					speed=4;
				}
				if (_body) {
					_body.play(_bodyURL, _selectState, _selectDir, speed, $isLoop);
				}
				if (_weapon) {
					_weapon.play(_weaponURL, _selectState, _selectDir, _selectSpeed, $isLoop);
				}
				if (_mounts) {
					_mounts.play(_mountsURL, _selectState, _selectDir, _selectSpeed, $isLoop);
				}
			} else { //透明
				if(hasBodyComplete){
					if (_body) {
						_body.play(oldBodyURL, _selectState, _selectDir, _selectSpeed, $isLoop);
					}
					if (_weapon) {
						_weapon.play(oldWeaponURL, _selectState, _selectDir, _selectSpeed, $isLoop);
					}
					if (_mounts) {
						_mounts.play(oldMountsURL, _selectState, _selectDir, _selectSpeed, $isLoop);
					}
				}else{
					_body.setTransparent(Style.getUIBitmapData(GameConfig.T1_VIEWUI,"transparent"));
					_body.stop();
					if (_weapon) {
						_weapon.stop();
						_weapon.clean();
					}
					if (_mounts) {
						_mounts.stop();
						_mounts.clean();
					}
				}
			}
			checkStateChange();
		}
		
		private function onActionEnd(event:Event):void {
			switch (selectState) {
				case AvatarConstant.ACTION_SIT:
					stop();
					break;
				case AvatarConstant.ACTION_DIE:
					stop();
					break;
				default:
					play(AvatarConstant.ACTION_STAND, _selectDir, ThingFrameFrequency.STAND, true);
			}
		}
		
		private var _changeEffect:Thing;
		private function showChangeEffect():void{
			if(!_changeEffect){
				_changeEffect=new Thing();
				_changeEffect.load(GameConfig.OTHER_PATH+"huanzhuang.swf");
				_changeEffect.play(4,true);
				_effectLayerTop.addChild(_changeEffect);
			}else{
				_changeEffect.play(4,true);
				_effectLayerTop.addChild(_changeEffect);
			}
		}
		
		private function hideChangeEffect():void{
			if(_changeEffect){
				_changeEffect.stop();
				if(_changeEffect.parent){
					_changeEffect.parent.removeChild(_changeEffect);
				}
			}
		}
		
		/***********状态改变后触发，用于调整名字高度************/
		private function checkStateChange():void {
			var e:DataEvent;
			if (_preState != selectState) {
				if (selectState == AvatarConstant.ACTION_SIT) {
					e=new DataEvent(BODY_COMPLETE);
					e.data="54"; //_bodyLayer.height.toString();
					dispatchEvent(e);
				} else if (selectState == AvatarConstant.ACTION_DIE) {
					e=new DataEvent(BODY_COMPLETE);
					e.data="40"; //_bodyLayer.height.toString();
					dispatchEvent(e);
				} else if (selectState == AvatarConstant.ACTION_STAND) {
					if (_preState == AvatarConstant.ACTION_SIT || _preState == AvatarConstant.ACTION_DIE) {
						e=new DataEvent(BODY_COMPLETE);
						e.data=_bodyLayer.height.toString();
						dispatchEvent(e);
					}
				} else if (selectState == AvatarConstant.ACTION_ATTACK) {
					if (_preState == AvatarConstant.ACTION_SIT || _preState == AvatarConstant.ACTION_DIE) {
						e=new DataEvent(BODY_COMPLETE);
						e.data=_bodyLayer.height.toString();
						dispatchEvent(e);
					}
				} else if (selectState == AvatarConstant.ACTION_ATTACK_ARROW) {
					if (_preState == AvatarConstant.ACTION_SIT || _preState == AvatarConstant.ACTION_DIE) {
						e=new DataEvent(BODY_COMPLETE);
						e.data=_bodyLayer.height.toString();
						dispatchEvent(e);
					}
				} else if (selectState == AvatarConstant.ACTION_ATTACK_CASTING) {
					if (_preState == AvatarConstant.ACTION_SIT || _preState == AvatarConstant.ACTION_DIE) {
						e=new DataEvent(BODY_COMPLETE);
						e.data=_bodyLayer.height.toString();
						dispatchEvent(e);
					}
				} else if (selectState == AvatarConstant.ACTION_WALK) {
					if (_preState == AvatarConstant.ACTION_SIT || _preState == AvatarConstant.ACTION_DIE) {
						e=new DataEvent(BODY_COMPLETE);
						e.data=_bodyLayer.height.toString();
						dispatchEvent(e);
					}
				} else if (selectState == AvatarConstant.ACTION_HURT) {
					if (_preState == AvatarConstant.ACTION_SIT || _preState == AvatarConstant.ACTION_DIE) {
						e=new DataEvent(BODY_COMPLETE);
						e.data=_bodyLayer.height.toString();
						dispatchEvent(e);
					}
				}
			}
		}
		
		public function reset():void{
			hasBodyComplete=false;
			_oldState = null;
		}
		
		public function unload():void {
			if (_body)
				_body.removeEventListener(BitmapMovieClip.END, onActionEnd);
			SourceManager.getInstance().removeEventListener(SourceManager.CREATE_COMPLETE, sourceCreateComplete);
			stop();
			hideChangeEffect();
			removeShadow();
			
			removeChilds(_body);
			_body=null;
			removeChilds(_weapon);
			_weapon=null;
			removeChilds(_mounts);
			_mounts=null;
			
			removeChilds(_effectLayerBottom);
			_effectLayerBottom=null;
			removeChilds(_effectLayerTop);
			_effectLayerTop=null;
			removeChilds(_bodyLayer);
			_bodyLayer=null;
			_oldState = null;
			
		}
	}
}
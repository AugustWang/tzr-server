package com.scene.sceneUnit.baseUnit {
	import com.globals.GameConfig;
	import com.scene.sceneData.BinaryMath;
	import com.scene.sceneKit.SayWords;
	import com.scene.sceneUnit.IMutualUnit;
	import com.scene.sceneUnit.baseUnit.things.avatar.Avatar;
	import com.scene.sceneUnit.baseUnit.things.avatar.AvatarConstant;
	import com.scene.sceneUnit.baseUnit.things.avatar.AvatarII;
	import com.scene.sceneUnit.baseUnit.things.effect.Effect;
	import com.scene.sceneUnit.baseUnit.things.heartbeat.ThingFrameFrequency;
	import com.scene.sceneUnit.baseUnit.things.thing.Thing;
	import com.scene.sceneUtils.Slice;
	import com.scene.tile.Pt;
	import com.scene.tile.TileUitls;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.geom.Point;
	
	import modules.buff.BuffModule;
	import modules.roleStateG.RoleStateDateManager;
	import modules.scene.SceneDataManager;
	import modules.system.SystemConfig;
	
	import proto.common.p_actor_buf;
	import proto.common.p_skin;
	
	/**
	 * 场景中基于Avatar的可交互单位 基类
	 * @author LXY
	 *
	 */
	public class MutualAvatar extends Sprite implements IMutualUnit {
		public var onlyKey:String;
		private var _sceneType:int;
		public var id:int;
		protected var skinData:p_skin;
		protected var $specialSkin:Boolean=false;
		protected var avatar:AvatarII;
		public var isConceal:Boolean=false;
		public var dir:int=4; //朝向
		public var isDead:Boolean; //是否死亡
		public var isStop:Boolean; //Avatar是否停止
		protected var $sayword:SayWords;
		private var buffs:Array=[];
		private var _enabled:Boolean=true;
		
		public function MutualAvatar() {
			super();
			onlyKey=OnlyIDCreater.createID();
		}
		
		public function hide():void {
			if (this.parent)
				this.parent.removeChild(this);
		}
		
		public function initSkin(skin:p_skin):void {
			skinData=skin;
			avatar=new AvatarII();
			initAvatar();
			avatar.addEventListener(Avatar.BODY_COMPLETE, onBodyComplete);
			avatar.initSkin(skin);
			avatar.mouseChildren=false;
			avatar.mouseEnabled=false;
			addChild(avatar);
		}
		
		protected function initAvatar():void{
			
		}
		
		protected function onBodyComplete(e:DataEvent):void {
			avatar.removeEventListener(Avatar.BODY_COMPLETE, onBodyComplete);
		}
		
		public function set enabled(value:Boolean):void {
			if (_enabled != value) {
				if (avatar != null) {
					if (value) {
						avatar.resume();
					} else {
						avatar.stop();
					}
				}
			}
		}
		
		public function set hideAvatar(value:Boolean):void {
			if (avatar != null) {
				enabled=value;
				avatar.isVisible=!value;
			}
		}
		
		public function say(words:String=null):void {
			if ($sayword == null) {
				$sayword=new SayWords();
				$sayword.mouseChildren=$sayword.mouseEnabled=false;
			}
			if ($sayword.parent == null) {
				addChild($sayword);
			}
			$sayword.execute(words);
			$sayword.y=-avatar.height - 20 - $sayword.height + 8;
			$sayword.x=-$sayword.width / 2 - 12;
		}
		
		public function turnDir(_dir:int=4):void {
			dir=_dir;
			this.play(AvatarConstant.ACTION_STAND, dir, ThingFrameFrequency.STAND);
		}
		
		protected var _filter:Array
		public function mouseOver():void {
			if (avatar != null) {
				if (this.avatar._bodyLayer.filters != SceneStyle.bodyFilter) {
					_filter = this.avatar._bodyLayer.filters.concat();
					this.avatar._bodyLayer.filters = SceneStyle.bodyFilter;
				}
			}
		}
		
		public function mouseOut():void {
			if (avatar != null) {
				//				if (isDead == true) {
				//					this.avatar._bodyLayer.filters=SceneStyle.deathFilter;
				//				} else {
				if (this.avatar.filters != null || this.avatar.filters.length > 0) {
					this.avatar.filters=null;
				}
				this.avatar.cleanFilter();
				this.avatar._bodyLayer.filters = _filter;
				//				}
			}
		}
		
		public function mouseDown():void {
			
		}
		
		public function normal():void {
			if (isDead == false) {
				this.play(AvatarConstant.ACTION_STAND, dir, ThingFrameFrequency.STAND);
			}
		}
		
		public function attack(attackType:String, _dir:int):void {
			if (isDead == false) {
				dir=_dir;
				this.play(attackType, dir, ThingFrameFrequency.ATTACK);
			}
		}
		
		public function hurt():void {
			if (isDead == false) {
				this.play(AvatarConstant.ACTION_HURT, dir, ThingFrameFrequency.HURT);
			}
		}
		
		public function die():void {
			this.play(AvatarConstant.ACTION_DIE, dir, ThingFrameFrequency.DIE);
			if (avatar != null)
				avatar._bodyLayer.filters=SceneStyle.deathFilter;
		}
		
		public function conceal(value:Boolean, anti_conceal:Boolean=false):void {
			isConceal=value;
			if (!anti_conceal) {
				this.visible=!value;
			} else {
				this.visible=true;
				if (value) {
					this.alpha=0.5;
				} else {
					this.alpha=1;
				}
			}
		}
		
		public function play($state:String, $dir:int, $speed:int):void {
			if (avatar != null && ($state != avatar.selectState || $dir != avatar.selectDir || $speed != avatar.selectSpeed)) { //动作或方向有不同才执行
				avatar.play($state, $dir, $speed);
			}
			if(sitPlaying == false && $state == AvatarConstant.ACTION_SIT){
				playSitEffect();
			}else if(sitPlaying){
				removeSitEffect();
			}
		}
		
		protected var sitEffect:Thing;
		protected var sitPlaying:Boolean = false;
		protected function playSitEffect():void{
			if(sitEffect == null){
				sitEffect = new Thing();
				sitEffect.load(GameConfig.OTHER_PATH+"/dazuo.swf");
			}  
			sitEffect.play(2,true);
			boby.addChild(sitEffect);
			if(avatar.category == 2 && avatar.sex == 2){
				sitEffect.y = -30;
			}else{
				sitEffect.y = 0;
			}
			sitPlaying = true;
		}
		
		protected function removeSitEffect():void{
			boby.y = 0;
			sitPlaying = false;
			if(sitEffect){
				sitEffect.stop();
				if(sitEffect.parent){
					sitEffect.parent.removeChild(sitEffect);
				}
			}
		}
		
		/**
		 * 获得当前索引，（在等角坐标系中的位置）
		 * @return
		 *
		 */
		public function get index():Pt {
			var pt:Pt=TileUitls.getIndex(new Point(this.x, this.y));
			return pt;
		}
		
		
		/**
		 * 获得受伤点位置
		 * @return
		 *
		 */
		public function getHurtPoint():Point {
			if (avatar)
				return avatar.getHurtPoint();
			return new Point
		}
		
		/**
		 * 获取攻击点位置
		 * @return
		 *
		 */
		public function getAttackPoint():Point {
			if (avatar)
				return avatar.getAttackPoint();
			return new Point
		}
		
		public function getSelectState():String {
			if (avatar)
				return avatar.selectState;
			return null;
		}
		
		protected function setWeak(b:Boolean):void {
			if (avatar == null)
				return;
			if (b) {
				if (avatar.alpha != 0.6) {
					avatar.alpha=0.6;
				}
			} else {
				if (avatar.alpha != 1) {
					avatar.alpha=1;
				}
			}
		}
		
		/**
		 * 获得所在格子的类型
		 * @param point 当前像素点
		 * @return
		 *
		 */
		protected function isAlphaCell(pt:Pt):Boolean {
			var isAlpha:Boolean;
			var cell:int=SceneDataManager.getCell(pt.x,pt.z);
			if (BinaryMath.isExist(cell)==true && BinaryMath.isAlpha(cell)==true) {
				isAlpha=true;
			}
			return isAlpha;
		}
		
		public function getDretion(dx:Number, dy:Number):int {
			var dir:int;
			//dgr范围：-180到180
			var x1:Number=dx - this.x;
			var y1:Number=dy - this.y;
			var ang:Number=Math.atan2(y1, x1) * 180 / Math.PI;
			if (ang >= -15 && ang < 15) {
				dir=2;
			} else if (ang >= 15 && ang < 75) {
				dir=3;
			} else if (ang >= 75 && ang < 105) {
				dir=4;
			} else if (ang >= 105 && ang < 170) {
				dir=5;
			} else if (ang >= 170 || ang < -170) {
				dir=6;
			} else if (ang >= -75 && ang < -15) {
				dir=1;
			} else if (ang >= -105 && ang < -75) {
				dir=0;
			} else if (ang >= -170 && ang < -105) {
				dir=7;
			}
			return dir;
		}
		
		public function addBuff(value:Array):void {
			for (var i:int=0; i < value.length; i++) {
				var vo:p_actor_buf=value[i] as p_actor_buf;
				switch (vo.buff_type) {
					case 31: //中毒
						avatar.colorFilter(0, 1, 0);
						break;
					case 36: //隐身
						conceal(true, RoleStateDateManager.isAntiStealth);
						break;
					case 86: //冰冻
						if (SystemConfig.openEffect) {
							var buffEffect:Effect=Effect.getEffect();
							buffEffect.show(GameConfig.EFFECT_SKILL_PATH + 'buff86.swf', 0, 0, avatar._effectLayerTop);
						}
						avatar.colorFilter(0, 0, 1);
						break;
					case 87:
						avatar.colorFilter(0, 1, 0);
						break;
					case 1003:
						var skin:p_skin=new p_skin();
						skin.skinid=vo.value;
						skin.hair_type=0;
						if (avatar.selectState != AvatarConstant.ACTION_ATTACK || avatar.selectState != AvatarConstant.ACTION_STAND || avatar.selectState != AvatarConstant.ACTION_WALK) {
							avatar.play(AvatarConstant.ACTION_STAND, avatar.selectDir, ThingFrameFrequency.STAND);
						}
						avatar.isTransform=false;
						avatar.updataSkin(skin);
						avatar.isTransform=true;
						break;
					case 1034:
						normal();
						if (SystemConfig.openEffect) {
							var trapEffect:Thing=new Thing();
							trapEffect.name="jing_ji_xian_jing";
							trapEffect.x=trapEffect.y=0;
							avatar._effectLayerTop.addChild(trapEffect);
							trapEffect.load(GameConfig.EFFECT_SKILL_PATH + 'trap/jing_ji_xian_jing.swf');
							trapEffect.play(4);
						}
						break;
					case 1035:
						if (SystemConfig.openEffect && avatar && !avatar._effectLayerTop.getChildByName('zuijiu')) {
							var zuijiuEffect:Thing=new Thing();
							zuijiuEffect.name="zuijiu";
							zuijiuEffect.x=-10;
							zuijiuEffect.y=-140;
							avatar._effectLayerTop.addChild(zuijiuEffect);
							zuijiuEffect.load(GameConfig.OTHER_PATH + 'zuijiu.swf');
							zuijiuEffect.play(8, true);
						}
						break;
				}
			}
		}
		
		public function removeBuff(value:Array):void {
			for (var i:int=0; i < value.length; i++) {
				var vo:p_actor_buf=value[i] as p_actor_buf;
				switch (vo.buff_type) {
					case 31: //中毒
						avatar.colorFilter(1, 1, 1);
						break;
					case 36: //隐身
						conceal(false, RoleStateDateManager.isAntiStealth);
						break;
					case 86:
						avatar.colorFilter(1, 1, 1);
						break;
					case 87:
						avatar.colorFilter(1, 1, 1);
						break;
					case 1003:
						avatar.isTransform=false;
						avatar.updataSkin(skinData);
						break;
					case 1034: //荆棘陷阱
						var thing:DisplayObject=avatar._effectLayerTop.getChildByName("jing_ji_xian_jing");
						if (thing) {
							avatar._effectLayerTop.removeChild(thing);
						}
						break;
					case 1035:
						if (SystemConfig.openEffect && avatar && avatar._effectLayerTop.getChildByName('zuijiu')) {
							thing=avatar._effectLayerTop.getChildByName('zuijiu')
							avatar._effectLayerTop.removeChild(thing);
						}
						break;
				}
			}
		}
		
		
		
		public function createBuff($buffs:Array):void {
			var buff_add:Array=BuffModule.checkBuffAdd(buffs, $buffs);
			addBuff(buff_add);
			var buff_remove:Array=BuffModule.checkBuffRemove(buffs, $buffs);
			removeBuff(buff_remove);
			buffs=$buffs;
		}
		
		public function get topEffectLayer():Sprite {
			if (avatar)
				return avatar._effectLayerTop;
			return null;
		}
		
		public function get bottomEffectLayer():Sprite {
			if (avatar)
				return avatar._effectLayerBottom;
			return null;
		}
		
		public function get bobyHeight():int {
			if (avatar)
				return avatar.bobyHeight;
			return 0;
		}
		
		public function get boby():Sprite{
			if(avatar){
				return avatar._bodyLayer;
			}
			return null;
		}

		public function get slice():Point {
			var sx:int=int((this.x - Slice.offsetx) / Slice.width);
			var sy:int=int((this.y - Slice.offsety) / Slice.height);
			var newSlice:Point=new Point(sx, sy);
			return newSlice;
		}
		
		public function remove():void {
			if (this.avatar) {
				this.avatar.removeEventListener(Avatar.BODY_COMPLETE, onBodyComplete);
				this.avatar.stop();
			}
			if (this.parent != null) {
				this.parent.removeChild(this);
			}
		}
		
		public function get unitKey():String {
			return sceneType + "_" + id;
		}
		
		public function set sceneType(value:int):void {
			_sceneType=value;
		}
		
		public function get sceneType():int {
			return _sceneType;
		}
		
		override public function set x(value:Number):void {
			super.x=Math.round(value);
		}
		
		override public function set y(value:Number):void {
			super.y=Math.round(value);
		}
	}
}
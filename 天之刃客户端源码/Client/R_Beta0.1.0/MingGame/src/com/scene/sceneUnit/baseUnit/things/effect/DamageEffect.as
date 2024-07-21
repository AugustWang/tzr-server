package com.scene.sceneUnit.baseUnit.things.effect {
	import com.common.GlobalObjectManager;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneUnit.baseUnit.OnlyIDCreater;
	import com.scene.sceneUnit.baseUnit.things.ThingFrame;
	import com.scene.sceneUnit.baseUnit.things.common.NumberImage;
	import com.scene.tile.Pt;
	import com.scene.tile.TileUitls;
	import com.utils.tick.ITick;
	import com.utils.tick.TickManager;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	import modules.skill.SkillConstant;


	public class DamageEffect implements ITick{
		public static const NORMAL:String='normal';
		public static const CRIT:String='crit';
		public static const MISS:String='miss';
		public static const NO_DEFENCE:String='noDefence';

		public static var POOL_MAX:int=10;
		public static var pool:Array=[];
		public var onlyKey:String;
		
		private var _dir:int;
		private var _type:int;
		private var _shape:Shape;
		private var _parent:Sprite;
		private var _step:int;
		private var _delay:int;
		private var _time:int;

		public function DamageEffect() {
			onlyKey=OnlyIDCreater.createID();
		}

		public static function getEffect():DamageEffect {
			if (pool.length > 0) {
				return pool.pop();
			}
			return new DamageEffect();
		}
		
		public function showZhangong(parent:Sprite, startPont:Point,gunxun:int, delay:int=0):void{
			var key:String="g" + gunxun.toString();
			_shape=NumberImage.getInstance().toImage(key, "104");
			_shape.x=startPont.x - _shape.width / 2;
			_shape.y=startPont.y + 20;
			_parent=parent;
			_delay=delay;
			_type=SkillConstant.EXP_ADD;
			addToLoop();
		}
		
		public function showExp(parent:Sprite, startPont:Point,exp:int, delay:int=0):void {
			var key:String="e" + exp.toString();
			_shape=NumberImage.getInstance().toImage(key, "104");
			_shape.x=startPont.x - _shape.width / 2;
			_shape.y=startPont.y + 20;
			_parent=parent;
			_delay=delay;
			_type=SkillConstant.EXP_ADD;
			addToLoop();
		}

		public function showWord(parent:Sprite, startPont:Point, word:String, delay:int=0):void {
			_shape=NumberImage.getInstance().toWord(word);
			_shape.x=startPont.x - _shape.width / 2;
			_shape.y=startPont.y;
			_parent=parent;
			_delay=delay;
			addToLoop();
		}

		public function show(parent:Sprite, startPont:Point, data:int=0, type:int=2, state:String='normal', delay:int=0):void {
			var key:String=data.toString();
			switch (state) {
				case CRIT:
					key='b' + key;
					break;
				case NO_DEFENCE:
					key='p' + key;
					break;
				case MISS:
					key='m';
					break;
			}
			_type = type;
			switch (type) {
				case SkillConstant.BUFF_INTERVAL_EFFECT_REDUCE_HP:
					_shape=NumberImage.getInstance().toImage(key, "101");
					break;
				case SkillConstant.BUFF_INTERVAL_EFFECT_ADD_HP:
					_shape=NumberImage.getInstance().toImage(key, "102");
					break;
				case SkillConstant.REDUCE_HP_SELF:
					_shape=NumberImage.getInstance().toImage(key, "103");
					break;
				case SkillConstant.BUFF_INTERVAL_EFFECT_REDUCE_MP:
					_shape=NumberImage.getInstance().toImage(key, "104");
					break;
				case SkillConstant.RESULT_TYPE_ADD_MP:
					_shape=NumberImage.getInstance().toImage(key, "104");
					break;
				case 0:
					_shape=NumberImage.getInstance().toImage(key, "104");
					break;
				default :
					_shape=NumberImage.getInstance().toImage(key, "104");
					break;
			}
			_dir = SceneUnitManager.getSelf().dir;
			_shape.x=startPont.x - _shape.width / 2;
			_shape.y=startPont.y + 40;
			_delay=delay;
			_parent=parent;
			addToLoop();
		}

		private function addToLoop():void {
			_time=3000;
			_step=0;
			if (_delay == 0)
				_parent.addChild(_shape);
			TickManager.getInstance().addTick(this);
		}

		private function removeToLoop():void {
			TickManager.getInstance().removeTick(this);
		}

		public function onTick(framecount:int,dt:Number = 40) : void{
			_time = _time - dt;
			if (_time <= 0) {
				unload();
				return;
			}
			if (_delay == 0) {
				if (!_shape.parent)
					_parent.addChild(_shape);
				if (_step >= 25) {
					unload();
					return;
				}
				if (4 > _step) {
					_shape.y-=20;
					if(_dir < 5){
						if(_type == SkillConstant.REDUCE_HP_SELF){
							_shape.x -= 6;
						}else if(_type == SkillConstant.BUFF_INTERVAL_EFFECT_REDUCE_HP){
							_shape.x += 6;
						}
					}else{
						if(_type == SkillConstant.REDUCE_HP_SELF){
							_shape.x += 6;
						}else if(_type == SkillConstant.BUFF_INTERVAL_EFFECT_REDUCE_HP){
							_shape.x -= 6;
						}
					}
				} else {
					_shape.y-=4.3;
					_shape.alpha-=0.03;
				}
				_step++;
			} else {
				_delay--;
			}
		}

		public function unload():void {
			removeToLoop();
			if (_shape.parent)
				_shape.parent.removeChild(_shape);
			_shape=null;
			_parent=null;
			if (pool.length < POOL_MAX) {
				pool.push(this);
			}
		}
	}
}
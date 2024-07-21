package com.scene.sceneUnit
{
	import com.globals.GameConfig;
	import com.scene.sceneUnit.baseUnit.MutualThing;
	import com.scene.sceneUnit.baseUnit.SceneStyle;
	import com.scene.sceneUnit.baseUnit.things.ThingsEvent;
	import com.scene.sceneUnit.baseUnit.things.effect.SceneEffect;
	import com.scene.sceneUnit.baseUnit.things.thing.Thing;
	import com.scene.sceneUtils.SceneUnitType;
	
	import modules.broadcast.views.Tips;
	import modules.mypackage.ItemConstant;
	import modules.needfire.NeedfieModule;
	import modules.scene.SceneDataManager;
	import modules.scene.cases.MyRoleControler;
	
	import proto.common.p_map_bonfire;

	public class Needfire extends MutualThing
	{
		public var vo:p_map_bonfire;
		
		private var _fire:Thing;
		private var _sceneEffect:SceneEffect;
		private var _type:String;
		private var state:int = 2;//2:熄灭,1:燃烧；
		private var _url:String;
		
		public function Needfire()
		{
			super();
			_url = GameConfig.EFFECT_SCENE + "gouhuo.swf";
			_type=type;
			sceneType=SceneUnitType.NEEDFIRE_TYPE;
			init(_url);
			this.buttonMode=true;
		}
		
		public function get type():String
		{
			return _type;
		}
		
		public function stop():void{
			if(_fire){
				_fire.stop();
			}
		}
		
		
		public function play():void{
			_thing.gotoAndStop(0);
			if(vo.state == 1){
				if(_fire){
					_fire.gotoAndPlay(5,1,3,true);
					addChild(_fire);
				}else{
					_sceneEffect = new SceneEffect();
					_fire = new Thing();
					_fire.mouseEnabled = false;
					_fire.mouseChildren = false;
					_fire.load(_url);
					_fire.gotoAndPlay(5,1,3,true);
					_fire.y = -45;
					_sceneEffect.addChild(_fire);
					_sceneEffect.x = this.x;
					_sceneEffect.y = this.y;
					this.parent.addChild(_sceneEffect);
				}
			}else{
				if(_fire){
					_fire.stop();
					if(_fire.parent){
						_fire.parent.removeChild(_fire);
					}
				}
			}
		}
		
		override protected function onLoadComplete(event:ThingsEvent):void{
			//super.onLoadComplete(event);
			play();
		}
		
		override public function mouseOver():void {
			super.mouseOver();
//			if (_fire != null) {
//				if (_fire.filters == null || _fire.filters.length == 0) {
//					_fire.filters=SceneStyle.bodyFilter;
//				}
//			}
		}
		
		override public function mouseOut():void {
			super.mouseOut();
//			if (_fire != null) {
//				if (_fire.filters != null || _fire.filters.length > 0) {
//					_fire.filters=null;
//				}
//			}
		}
		
		override public function mouseDown():void {
			MyRoleControler.getInstance().onClickUnit(this);
		}
		
		override public function remove():void{
			var index:int = NeedfieModule.getInstance().fires.indexOf(this);
			if(index != -1){
				NeedfieModule.getInstance().fires.splice(index,1);
			}
			super.remove();
		}
	}
}
package modules.finery.views.item {
	import com.globals.GameConfig;
	import com.scene.sceneUnit.baseUnit.things.effect.Effect;
	import com.scene.sceneUnit.baseUnit.things.thing.Thing;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	
	import modules.mypackage.views.GoodsImage;
	import modules.mypackage.views.ItemToolTip;
	import modules.mypackage.vo.BaseItemVO;

	public class EquipBox extends Sprite {
		public var bg:Bitmap;
		private var content:GoodsImage;
		private var stoneBox:StoneBox;
		private var _data:BaseItemVO;
		private var effect:Thing;
		
		public function set data(value:Object):void{
			_data = value as BaseItemVO;
			if(_data){
				content.setImageContent(_data,_data.path);
				content.visible = true;
			}else{
				content.visible = false;
			}
			if(stoneBox)stoneBox.data = _data;
		}
		
		public function get data():Object{
			return _data;
		}
		
		public function EquipBox(label:String="装备",showStone:Boolean=true) {
			bg=Style.getBitmap(GameConfig.STOVE_UI,"skyItem");
			addChild(bg);
			var equipWordTxt:TextField = ComponentUtil.createTextField("",23,25,null,36,36,this);
			equipWordTxt.htmlText = HtmlUtil.font(label,"#CEF8FB");
			content = new GoodsImage();
			content.x = 21;
			content.y = 19;
			addChild(content);
			if(showStone){
				stoneBox = new StoneBox();
				stoneBox.initUI(bg);
				addChild(stoneBox);
			}
			content.addEventListener(MouseEvent.MOUSE_OVER,onRollOver);
			content.addEventListener(MouseEvent.MOUSE_OUT,onRollOut);
			content.addEventListener(MouseEvent.CLICK,onClick);
			data = null;
		}
		
		private function onClick(event:MouseEvent):void{
			dispatchEvent(new Event("EQUIP_BOX_CLICK"));
		}
		
		private function onRollOver(event:MouseEvent):void{
			if(_data){
				var point:Point = new Point(content.x+content.width+2,content.y);
				point = this.localToGlobal(point);
				ItemToolTip.show(BaseItemVO(_data),point.x,point.y,false);
			}
		}
		
		private function onRollOut(event:MouseEvent):void{
			ItemToolTip.hide();
		}
		
		public function playEffect():void{
			if(!effect){
				effect = new Thing();
				effect.load(GameConfig.ROOT_URL + "com/assets/stoveEffect/boxEffect.swf");
				addChild(effect);
				effect.x = -8;
				effect.y = -12;
			}
			effect.play(2,true);
		}
		
		public function stopEffect():void{
			if(effect){
				effect.stop();
				removeChild(effect);
				effect=null;
			}
		}
		
		public function playCompleteEffec():void{
			var completeEffect:Effect = Effect.getEffect();
			completeEffect.show(GameConfig.ROOT_URL + "com/assets/stoveEffect/boxCompleteEffect.swf",35,35,this,2);
		}
	}
}
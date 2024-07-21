package modules.finery.views.item
{
	import com.globals.GameConfig;
	import com.managers.WindowManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.style.StyleManager;
	import com.scene.sceneUnit.baseUnit.things.thing.Thing;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.mypackage.views.GoodsImage;
	import modules.mypackage.views.ItemToolTip;
	import modules.mypackage.vo.BaseItemVO;
	
	public class BoxItem extends Sprite
	{
		private var bg:Bitmap;
		private var _data:BaseItemVO;
		private var content:GoodsImage;
		private var countlb:TextField;
		private var effect:Thing;
		private var _showNum:Boolean;
		private var btn:Button;
		
		public function set data(value:Object):void{
			_data = value as BaseItemVO;
			if(_data){
				content.setImageContent(_data,_data.path);
				updateCount(_data.num);
				content.visible = true;
				countlb.visible = _showNum;
			}else{
				content.visible = false;
				countlb.visible = false;
			}
		}
		
		public function get data():Object{
			return _data;
		}
		
		public function BoxItem(label:String="",showNum:Boolean=false)
		{
			_showNum = showNum;
			bg=Style.getBitmap(GameConfig.T1_VIEWUI,"borderItemBg");
			addChild(bg);
			if(label!=""){
				var labelTxtFormat:TextFormat=new TextFormat("Tahoma", 12, 0xCEF8FB, null, null, null, null, null, TextFormatAlign.
					CENTER);
				var labelTxt:TextField = ComponentUtil.createTextField(label,21,19,labelTxtFormat,36,36,this);
				labelTxt.htmlText = HtmlUtil.font(label,"#CEF8FB");
				labelTxt.x = (bg.width-labelTxt.width)*0.5;
			}
			content = new GoodsImage();
			content.x = 15;
			content.y = 15;
			addChild(content);
			createCountLabel(0);
			content.addEventListener(MouseEvent.MOUSE_OVER,onRollOver);
			content.addEventListener(MouseEvent.MOUSE_OUT,onRollOut);
			content.addEventListener(MouseEvent.CLICK,onClick);
			
//			btn = new Button();
//			btn.label="提交";
//			btn.height=25;
//			btn.width=60;
//			btn.addEventListener(MouseEvent.CLICK,onBtnClick);
//			btn.y = bg.height+15;
//			btn.x = (bg.width-btn.width)*0.5;
//			addChild(btn);
			
			data = null;
		}
		
		private function onBtnClick(event:MouseEvent):void{
			
		}
		
		private function onClick(event:MouseEvent):void{
			dispatchEvent(new Event("MATERIAL_BOX_CLICK"));
		}
		
		private function createCountLabel(num:int):void{
			var tf:TextFormat = StyleManager.textFormat;
			tf.size = 11;
			countlb = ComponentUtil.createTextField("",12,30,tf,33,NaN,this);
			countlb.filters = [new GlowFilter(0x000000)];
			updateCount(num);
			countlb.selectable = false;		
			countlb.autoSize = "right";	
		}
		
		public function updateCount(count:int):void{
			if(countlb){
				if(count > 0){
					countlb.text = count.toString();
				}else{
					countlb.text = "";
				}
			}	
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
				effect.x = -16;
				effect.y = -18;
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
	}
}
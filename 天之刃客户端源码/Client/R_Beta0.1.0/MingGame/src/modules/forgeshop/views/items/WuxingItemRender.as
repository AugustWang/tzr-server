package modules.forgeshop.views.items
{
	import com.ming.ui.controls.CheckBox;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import proto.line.p_equip_build_goods;
	
	public class WuxingItemRender extends UIComponent
	{
		public var checkBox:CheckBox;
		private var needTxt:TextField;
		private var hasTxt:TextField
		public function WuxingItemRender()
		{
			checkBox = ComponentUtil.createCheckBox("",5,0,this);
			checkBox.width = 88;
			
			needTxt = ComponentUtil.createTextField("",checkBox.x + checkBox.width,checkBox.y,null,88,26,this);
			hasTxt = ComponentUtil.createTextField("",needTxt.x + needTxt.width,needTxt.y,null,88,26,this);
		}
		
		private function setValue(name:String,needNum:int,hasNum:int):void{
			checkBox.text = name;
			needTxt.text = needNum.toString();
			hasTxt.text = hasNum.toString();
		}
		
		public function changeTextColor(color:uint):void{
			var textFormat:TextFormat = new TextFormat("Tahoma",12,color,null,null,null,null,null,TextFormatAlign.CENTER);
			checkBox.textFormat = textFormat;
			needTxt.setTextFormat(textFormat);
			hasTxt.setTextFormat(textFormat);
		}
		
		override public function get data():Object{
			return super.data;
		}
		
		override public function set data(value:Object):void{
			super.data = value;
			var vo:p_equip_build_goods = value as p_equip_build_goods;
			setValue(vo.name,vo.needed_num,vo.current_num);
			checkBox.validateNow();
			if(vo.needed_num > vo.current_num){
				changeTextColor(0xff0000);
				checkBox.selected = false;
				checkBox.enable = false;
			}else{
				changeTextColor(0x00ff00);
			}
		}
	}
}
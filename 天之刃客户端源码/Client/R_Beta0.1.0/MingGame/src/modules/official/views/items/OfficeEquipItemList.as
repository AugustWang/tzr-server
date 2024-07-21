package modules.official.views.items
{
	import com.globals.GameConfig;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.views.GoodsImage;
	import modules.mypackage.vo.BaseItemVO;
	import modules.official.OfficialConstants;
	import modules.official.OfficialModule;
	
	import proto.line.m_office_take_equip_tos;
	import proto.line.p_office_equip;
	
	public class OfficeEquipItemList extends UIComponent
	{
		private var goodsItem:GoodsImage;
		private var titleText:TextField;
		private var view:Sprite;
		private var equipName:TextField;
		private var equip:p_office_equip;
		
		public function OfficeEquipItemList(equip:p_office_equip)
		{
			super();
			init();
		}
		
		private function init():void
		{
			Style.setBorderSkin(this);
			width = 280;
			height = 89;
			
			var tf:TextFormat = Style.textFormat;
			tf.align = "center";
			tf.bold = true;
			tf.color = 0xffff00;
			titleText = ComponentUtil.buildTextField("",tf,280,25,this);
			titleText.y = 2;
			
			var itemBg:Sprite = Style.getSpriteBitmap(GameConfig.T1_VIEWUI,"packItemBg");
			itemBg.x = 10;
			itemBg.y = 26;
			addChild(itemBg);
			
			goodsItem = new GoodsImage();
			goodsItem.x = goodsItem.y = 2;
			goodsItem.addEventListener(MouseEvent.ROLL_OVER,onRollOver);
			goodsItem.addEventListener(MouseEvent.ROLL_OUT,onRollOut);
			itemBg.addChild(goodsItem);
			
		}
		 
		override public function set data(value:Object):void{
			var equip:p_office_equip = value as p_office_equip;
			this.titleText.text = equip.office_name;
			this.equip = equip;
			var itemVO:BaseItemVO = ItemLocator.getInstance().getObject(equip.type_id);
			goodsItem.setImageContent(itemVO,itemVO.path);
			goodsItem.data = itemVO;
			view = initTakeView(itemVO.name);
			if(view){
				view.x = 89;
				view.y = 44;
				addChild(view);
			}
		}
		
		private function initTakeView(equip_name:String):Sprite{
			var sp:Sprite = new Sprite; 
			var tf:TextFormat = Style.textFormat;
			tf.leading = 4;
			tf.bold = true;
			equipName = ComponentUtil.createTextField(equip_name,0,0,tf,150,22,sp);
			var getButton:Button = ComponentUtil.createButton("领取",120,16,60,25,sp);
			getButton.addEventListener(MouseEvent.CLICK,onGetClick);
			return sp;
		}
		
		//领取官职装备
		private function onGetClick(event:MouseEvent):void{
			OfficialModule.getInstance().takeEquip(equip.office_id,equip.equip_num);
		}

		private function onRollOver(event:MouseEvent):void{
			if(goodsItem.data){
				ToolTipManager.getInstance().show(goodsItem.data,50,0,0,"goodsToolTip");
			}
		}
		
		private function onRollOut(event:MouseEvent):void{
			ToolTipManager.getInstance().hide();
		}
		
		override public function dispose():void
		{
			super.dispose();
			while(this.numChildren>0)
			{
				var displayobj:DisplayObject = this.getChildAt(0);
				removeChild(displayobj);
				displayobj = null;
			}
				
		}
	}
}



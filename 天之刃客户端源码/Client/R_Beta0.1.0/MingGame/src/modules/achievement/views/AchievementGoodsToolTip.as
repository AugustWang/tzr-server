package modules.achievement.views
{
	import com.common.GlobalObjectManager;
	import com.ming.ui.controls.core.BaseToolTip;
	import com.ming.ui.style.StyleManager;
	import com.ming.utils.StringUtil;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	import com.utils.MoneyTransformUtil;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.mypackage.ItemConstant;
	import modules.mypackage.components.BaseTip;
	import modules.mypackage.components.EquipTip;
	import modules.mypackage.components.ItemTip;
	import modules.mypackage.components.StoneShowBox;
	import modules.mypackage.views.GoodsImage;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	import modules.mypackage.vo.GeneralVO;
	
	import proto.common.p_property_add;
	
	public class AchievementGoodsToolTip extends BaseToolTip
	{
		private var tip:BaseTip;
		private var itemTip:ItemTip;
		private var equipTip:EquipTip;
		public function AchievementGoodsToolTip()
		{
			super();
			this.bgSkin = Style.getInstance().tipSkin;
		}
		
		override public function set data(itemVO:Object):void
		{
			super.data=itemVO;
			removeTips();
			if(itemVO is EquipVO){
				tip = getTip(true);
			}else{
				tip = getTip(false);
			}
			tip.type = BaseTip.NORMAL_TOOLTIP;
			tip.createItemTip(itemVO as BaseItemVO);
			addChild(tip);
			width = tip.width;
			height = tip.height;
			validateNow();
		}
		
		private function removeTips():void{
			if(itemTip && itemTip.parent){
				itemTip.parent.removeChild(itemTip);
			}
			if(equipTip && equipTip.parent){
				equipTip.parent.removeChild(equipTip);
			}
		}
		
		private function getTip(isEquip:Boolean):BaseTip{
			if(isEquip){
				if(equipTip == null){
					equipTip = new EquipTip();
				}
				return equipTip;
			}else{
				if(itemTip == null){
					itemTip = new ItemTip();
				}
				return itemTip;
			}
		}
		
		override public function set mX(value:Number):void
		{
			super.mX=value;
			if (stage != null)
			{
				if (value - 5 <= 0)
				{
					value=0;
				}
				else if (value - 5 + width > stage.stageWidth)
				{
					value=stage.stageWidth - width;
				}
				else
				{
					value=value - 5;
				}
			}
			else
			{
				value=value - 5;
			}
			x=value;
		}
		
		override public function set mY(value:Number):void
		{
			super.mY=value;
			if (stage != null)
			{
				if (value + height + 30 > stage.stageHeight)
				{
					value=value - height - 8;
				}
				else
				{
					value=value + 20;
				}
			}
			else
			{
				value=value + 20;
			}
			y=value;
		}
		
		
		override public function clear():void{
			data = "";
		}
	}
}
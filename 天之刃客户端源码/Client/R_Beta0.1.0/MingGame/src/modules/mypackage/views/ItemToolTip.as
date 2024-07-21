package modules.mypackage.views
{
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.display.DisplayObjectContainer;
	
	import modules.mypackage.components.BaseTip;
	import modules.mypackage.components.EquipTip;
	import modules.mypackage.components.ItemTip;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	import modules.roleStateG.RoleStateDateManager;
	import modules.system.SystemConfig;

	public class ItemToolTip extends UIComponent
	{
		private var itemTip:BaseTip;
		private var equipTip:EquipTip;
		public var type:String;
		public function ItemToolTip()
		{
			super();
			this.mouseEnabled = this.mouseChildren = false;
			this.bgSkin = Style.getInstance().tipSkin;
		}
		
		public static function get tipContainer():DisplayObjectContainer{
			return ToolTipManager.getInstance().getContainer();
		}
		
		public static var tips:ToolTipContainer;
		public static function show(vo:BaseItemVO,targetX:Number,targetY:Number,toCompare:Boolean=true,type:String="itemToolTip"):void{
			var equipVO:EquipVO = vo as EquipVO;
			var tipsVO:Array = [vo];
			if(equipVO && toCompare && SystemConfig.showEquipCompare){
				var roleEquips:Array = RoleStateDateManager.equips;
				for each(var roleEquip:EquipVO in roleEquips){
					if(roleEquip && roleEquip.putWhere == equipVO.putWhere){
						tipsVO.push(roleEquip);
					}
				}
			}
			if(tips == null){
				tips = new ToolTipContainer();
			}
			tips.type = type;
			tipContainer.addChild(tips);
			tips.x = targetX;
			tips.y = targetY;
			tips.addToolTips(tipsVO);
		}
		
		
		public static function hide():void{
			if(tips && tipContainer.contains(tips)){
				tipContainer.removeChild(tips);
			}
		}
		
		public static function isShow():Boolean{
			return tips && tipContainer.contains(tips);
		}
		
		override public function set data(value:Object):void
		{
			super.data=value;
			wrapperHTML(data as BaseItemVO);
		}
		
		public var useDesc:String = "";
		private function wrapperHTML(itemVo:BaseItemVO):void{
			removeTips();
			var tip:BaseTip = getTip(itemVo is EquipVO);
			tip.type = type;
			addChild(tip);
			tip.createItemTip(itemVo);
			width = tip.width;
			height = tip.height;
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
				equipTip.useDesc = useDesc;
				return equipTip;
			}else{
				if(itemTip == null){
					itemTip = new ItemTip();
				}
				return itemTip;
			}
		}
	}
}
package modules.official.views
{
	import com.components.BasePanel;
	import modules.official.views.items.OfficeEquipItemList;
	
	import proto.line.*;

	public class OfficialEquipView extends BasePanel
	{
		private var office_equip:Array;
		public var closeFunc:Function;
		public function OfficialEquipView()
		{
			super();
			this.title = "官职装备";
			width = 304;
			height = 410;
		}
		public function initData(office_equip:Array):void{
			this.office_equip = office_equip;
			var i:int = 0;
			for each(var equip:p_office_equip in office_equip){
				var rewardItem:OfficeEquipItemList = new OfficeEquipItemList(equip);
				rewardItem.data = equip;
				rewardItem.y = i*rewardItem.height+4;
				rewardItem.x = 12;
				addChild(rewardItem);
				i++;
			}
		}
		
		override public function closeWindow(save:Boolean=false):void{
			super.closeWindow(save);
			if(closeFunc != null){
				closeFunc.apply(null);
			}
		}
	}
}
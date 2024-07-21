package modules.finery.views.item
{
	import com.components.HeaderBar;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.controls.ComboBox;
	import com.ming.ui.controls.TabNavigation;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import modules.finery.StoveConstant;
	import modules.mypackage.ItemConstant;

	public class RightTopList extends UIComponent
	{
		
		private var type:String;
		private var equipIndex:String;
		private var headerBar:HeaderBar;
		private var colorCombox:ComboBox;
		private var equipCombox:ComboBox;
		private var equipListView:EquipList;
		
		public function RightTopList(type:String)
		{
			this.type = type;
		}
		
		public function initUI():void{
		
			width = 270;
			height = 215;
			Style.setBorderSkin(this);
			
			headerBar = new HeaderBar();
			headerBar.y = 2;
			headerBar.x = 2;
			headerBar.width = 266;
			headerBar.height = 23;
			headerBar.textFormat.bold = true;
			headerBar.textFormat.color = 0xffffff;
			headerBar.addColumn("选择装备",264);
			addChild(headerBar);
			
			ComponentUtil.createTextField("颜色：",5,30,null,40,20,this);
			colorCombox = createComboBox(StoveConstant.EQUIP_COLORS,40,28);
			colorCombox.addEventListener(Event.CHANGE,filterChangeHandler);
			
			ComponentUtil.createTextField("装备：",130,30,null,40,20,this);
			equipCombox = createComboBox(StoveConstant.EQUIP_TYPES,170,28);
			equipCombox.addEventListener(Event.CHANGE,filterChangeHandler);
			
			var colorEquipBg:Sprite = new Sprite();
			this.addChild(colorEquipBg);
			colorEquipBg.y = 51;
			
			equipListView = new EquipList(type);
			equipListView.height = 152;
			equipListView.y = 55;
			equipListView.x = 6;
			equipListView.update();
			addChild(equipListView);
		}
		
		private function filterChangeHandler(event:Event):void{
			var colorItem:Object = colorCombox.selectedItem;
			var equipItem:Object = equipCombox.selectedItem;
			if(colorCombox && equipItem){
				equipListView.update(colorItem.value,equipItem.value);
				checkSelet(_id);
			}
		}
		
		private function createComboBox(dataProvider:Array,x:int,y:int):ComboBox{
			var comboBox:ComboBox = new ComboBox();
			comboBox.width = 80;
			comboBox.height = 25;
			comboBox.x = x;
			comboBox.y = y;
			comboBox.dataProvider = dataProvider;
			comboBox.labelField = "label";
			addChild(comboBox);
			return comboBox;
		}
		
		private var _id:int = -1;
		public function checkSelet(id:int=-1):void{
			equipListView.checkSelet(id);
			_id = id;
		}
		
		public function update():void{
			equipListView.update(equipListView.selectColor,equipListView.selectPutWhere);
			checkSelet(_id);
		}
	}
}
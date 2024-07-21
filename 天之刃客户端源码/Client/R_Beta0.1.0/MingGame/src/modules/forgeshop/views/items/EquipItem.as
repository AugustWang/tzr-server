package modules.forgeshop.views.items
{
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.DragItem;
	import com.utils.ComponentUtil;
	
	import flash.display.DisplayObject;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.forgeshop.ForgeshopModule;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.views.GoodsItem;
	import modules.mypackage.views.ItemToolTip;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	
	
	public class EquipItem extends DragItem
	{
		private var txt:TextField;
		private var  accept:Boolean = true;
		private var targetData:EquipVO;
		
		public function EquipItem(){
			super(36,"skyItem");
			var textField:TextField = ComponentUtil.createTextField("装备",24,25,new TextFormat("宋体",12,0xffcc00),30,20,this);
			textField.selectable = false; 
			textField.filters = [new GlowFilter(0x000000)];
		}
		
		override protected function updateBorder(x:int, y:int):void{
			if(overBorder){
				overBorder.x = 20;
				overBorder.y = 18;
			}
		}
		
		override protected function rollOverHandler(tipCompare:Boolean=true):void{
			if(data){
				var p:Point = new Point(x+width,y);
				p = parent.localToGlobal(p);
				ItemToolTip.show(data as BaseItemVO,p.x + 20,p.y + 20,false);
			}
		}
		
		override protected function createContent():void{
			content = new GoodsItem(data as BaseItemVO);
			addChild(content);	
			super.createContent();
		}
		
		override protected function updatePosition():void{
			if(this.content){
				this.content.x = 20;
				this.content.y = 18;
			}
		}
		
		public function updateContent(itemVO:BaseItemVO):void{
			if(itemVO == null){
				disposeContent();
				return;
			}
			if(content == null){
				data = itemVO;
			}else{
				setData(itemVO);
				content.updateContent(itemVO);
			}
			this.updatePosition();
		}
		
		override public function allowAccept(data:Object,name:String):Boolean{
			if((data is EquipVO)&&(EquipVO(data).material !=0)&& (name == DragConstant.PACKAGE_ITEM) || (name == DragConstant.FORGESHOP_ITEM)){
				return true;
			}
			return false;
		}
		
		override public function dragDrop(dragData:Object, dragTarget:DisplayObject, itemName:String):void{
			//已存在物品，想替换
			ForgeshopModule.getInstance().swapGoods();
			var item:GoodsItem = dragTarget as GoodsItem;
			var tempData:EquipVO = dragData as EquipVO;
			PackManager.getInstance().lockGoods(tempData,true);
			data = tempData;
			switch(ForgeshopModule.getInstance().index()){
				case 1://品质改造
					ForgeshopModule.getInstance().requestEquipChangeMaterial(0);
					break;
				case 2://更改签名
					ForgeshopModule.getInstance().equipChangeName(tempData);
					break;
				case 3://升级
					ForgeshopModule.getInstance().requestEquipUpdateMaterial(0);
					break;
				case 4://分解
					ForgeshopModule.getInstance().equipDestroy(tempData);
					break;
				case 5://五行
					ForgeshopModule.getInstance().requestWuXingMaterial(0);
					break;
			}
		}	
 
	}
}
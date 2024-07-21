package modules.roleStateG.views
{	
	import com.common.FilterCommon;
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.DragItem;
	import com.components.alert.Alert;
	
	import flash.display.DisplayObject;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.mypackage.ItemConstant;
	import modules.mypackage.PackageModule;
	import modules.mypackage.components.BaseTip;
	import modules.mypackage.views.GoodsItem;
	import modules.mypackage.views.ItemToolTip;
	import modules.mypackage.views.MaskShape;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;

	/**
	 * 装备项
	 * 
	 */	
	public class EquipItem extends DragItem
	{
		public static const EQUIP_NAME:Array = ["头盔","项链","护甲","武器","特殊","靴子","特殊","时装","护腕","护腕","腰带","戒指","戒指","特殊","坐骑"];
		public var accept:Boolean = true;
		private var txt:TextField;
		public function EquipItem()
		{
			super(36);
			txt = new TextField();
			txt.width = 30;
			txt.defaultTextFormat = new TextFormat("宋体",12,0xAFE0EE);
			txt.selectable = false;
			txt.height = 20;
			txt.filters = FilterCommon.FONT_BLACK_FILTERS;
			txt.x = 6;
			txt.y = 11;
			addChild(txt);
		}
		
		override protected function rollOverHandler(tipCompare:Boolean=true):void{
			if(data){
				var p:Point = new Point(x+width,y);
				p = parent.localToGlobal(p);
				if(accept){
					ItemToolTip.show(data as BaseItemVO,p.x,p.y,false);
				}else{
					ItemToolTip.show(data as BaseItemVO,p.x,p.y,false,BaseTip.NORMAL_TOOLTIP);
				}	
			}
		}
		
		public var _position:int;
		public function set position(value:int):void{
			_position = value;
			txt.text = EQUIP_NAME[_position-1];
		}
		public function get position():int{
			return _position;
		}
		
		override protected function createContent():void{
			content = new GoodsItem(data as BaseItemVO);
			addChild(content);
			super.createContent();
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
			if((data as EquipVO).current_endurance == 0){
				addRedMaskShape();
			}else{
				removeRedMaskShape();
			}
			showTip();
		}	
		
		override public function allowAccept(data:Object,name:String):Boolean{
			var equipVO:EquipVO = data as EquipVO;
			if(accept && equipVO && equipVO.putWhere == ItemConstant.pos[position-1]){
				return true;
			}
			return false;
		}
		
		override public function getItemName():String{
			return DragConstant.EQUIP_ITEM;
		}
		
		private var redmask:MaskShape;
		private function addRedMaskShape():void{
			if(redmask == null){
				redmask = new MaskShape();
				redmask.draw(MaskShape.NO_ENDURANCE);
			}
			addChild(redmask);
		}
		
		private function removeRedMaskShape():void{
			if(redmask){
				redmask.remove();
				redmask = null;
			}
		}
		
		override public function disposeContent():void{
			super.disposeContent();
			removeRedMaskShape();
		}
		
		override public function dragDrop(dragData:Object, dragTarget:DisplayObject, itemName:String):void{
			var item:GoodsItem = dragTarget as GoodsItem;
			var tempData:EquipVO = dragData as EquipVO;
			if(tempData){
				if(itemName == DragConstant.PACKAGE_ITEM){
					if(!tempData.bind && tempData.use_bind == 1){
						Alert.show("本装备初次使用后将会被绑定，是否确定使用？","警告",yesHandler,null,"使用","取消");
					}else{
						PackageModule.getInstance().useEquip(tempData.oid,position);
					}
					function yesHandler():void{
						PackageModule.getInstance().useEquip(tempData.oid,position);
					}
				}else if(itemName == DragConstant.EQUIP_ITEM){
					if(position == tempData.loadposition){ //启动拖拽，但是单击的是同一位置，不做任何操作
						setContent(item,item.itemVO);
						return;
					}		
					PackageModule.getInstance().swapRoleItem(tempData.oid,position);	
				}else if(itemName == DragConstant.STOVE_ITEM){
					if(!tempData.bind && tempData.use_bind == 1){
						Alert.show("本装备初次使用后将会被绑定，是否确定使用？","警告",okHandler,null,"使用","取消");
					}else{
						PackageModule.getInstance().useEquip(tempData.oid,position);
					}
					function okHandler():void{
						PackageModule.getInstance().useEquip(tempData.oid,position);
					}
				}
			}
		}			
		
	}
}
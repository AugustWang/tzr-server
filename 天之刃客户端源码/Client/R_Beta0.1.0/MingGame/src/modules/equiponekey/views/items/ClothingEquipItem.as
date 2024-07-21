package modules.equiponekey.views.items
{	
	import com.common.FilterCommon;
	import com.common.GlobalObjectManager;
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.DragItem;
	import com.utils.HtmlUtil;
	
	import flash.display.DisplayObject;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.broadcast.views.BroadcastSelf;
	import modules.equiponekey.views.RoleChangeClothingView;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.views.GoodsItem;
	import modules.mypackage.views.ItemToolTip;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;

	/**
	 * 装备项
	 * 
	 */	
	public class ClothingEquipItem extends DragItem
	{
		public static const EQUIP_NAME:Array = ["头盔","项链","护甲","主手","副手","靴子","特殊","时装","护腕","护腕","腰带","戒指","戒指","特殊"];
		private var txt:TextField;
		public function ClothingEquipItem()
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
				ItemToolTip.show(data as BaseItemVO,p.x,p.y,false);
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
			if(_position == 4 && data && ItemConstant.getKind(data.kind) != 1){ //假如是主手
				var box:RoleChangeClothingView = parent as  RoleChangeClothingView;
				var assistantData:EquipVO = box.getEquipItemByName(5).data as EquipVO;
				if(assistantData && ItemConstant.getKind(assistantData.kind) == 1){
					box.getEquipItemByName(5).disposeContent();
				}
			}else if(_position == 5 && data && ItemConstant.getKind(data.kind) == 1){ //假如是副手
				box = parent as  RoleChangeClothingView;
				var mainData:EquipVO = box.getEquipItemByName(4).data as EquipVO;
				if(mainData && ItemConstant.getKind(mainData.kind) != 1){
					box.getEquipItemByName(4).disposeContent();
				}
			}else if(_position == 9 || _position == 10){
				box = parent as  RoleChangeClothingView;
				var otherPosition:int = _position == 9 ? 10 : 9;
				var otherItem:EquipVO = box.getEquipItemByName(otherPosition).data as EquipVO;
				if(otherItem && otherItem.oid == data.oid){
					box.getEquipItemByName(otherPosition).disposeContent();
				}
			}else if(_position == 12 || _position == 13){
				box = parent as  RoleChangeClothingView;
				otherPosition = _position == 12 ? 13 : 12;
				otherItem = box.getEquipItemByName(otherPosition).data as EquipVO;
				if(otherItem && otherItem.oid == data.oid){
					box.getEquipItemByName(otherPosition).disposeContent();
				}
			}
			
			showTip();
		}	
		
		override public function allowAccept(data:Object,name:String):Boolean{
			var equipVO:EquipVO = data as EquipVO;
			if((name == DragConstant.PACKAGE_ITEM || name == DragConstant.CLOTHING_EQUIP_ITEM) && equipVO && equipVO.putWhere == ItemConstant.pos[position-1]){
				var sex:int = GlobalObjectManager.getInstance().user.base.sex;
				var level:int = GlobalObjectManager.getInstance().user.attr.level;
				if(equipVO.sex !=0 && equipVO.sex != sex){
					BroadcastSelf.logger(HtmlUtil.font("性别不匹配，不能穿戴。","#ff0000"));
					return false;
				}else if(level < equipVO.minlvl){
					BroadcastSelf.logger(HtmlUtil.font("等级不够，不能穿戴。","#ff0000"));
					return false;
				}
				return true;
			}
			return false;
		}
		
		override public function getItemName():String{
			return DragConstant.CLOTHING_EQUIP_ITEM;
		}
	
		override public function dragDrop(dragData:Object, dragTarget:DisplayObject, itemName:String):void{
			var item:GoodsItem = dragTarget as GoodsItem;
			var tempData:EquipVO = dragData as EquipVO;
			if(tempData){
				if(itemName == DragConstant.PACKAGE_ITEM){
					updateContent(dragData as BaseItemVO);
				}else if(itemName == DragConstant.CLOTHING_EQUIP_ITEM){
					var clothingEquipItem:ClothingEquipItem = ClothingEquipItem(dragTarget.parent);
					clothingEquipItem.disposeContent();
					var tempTarget:DisplayObject = getContent();
					if(tempTarget){
						clothingEquipItem.setContent(tempTarget,data);
					}
					setContent(dragTarget,dragData);
				}
			}
		}			
		
	}
}
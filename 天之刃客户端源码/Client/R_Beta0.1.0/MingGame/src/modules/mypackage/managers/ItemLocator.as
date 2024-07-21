package modules.mypackage.managers {
	import com.globals.GameConfig;
	import com.loaders.CommonLocator;
	
	import flash.utils.Dictionary;
	
	import modules.mypackage.ItemConstant;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	import modules.mypackage.vo.GeneralVO;
	import modules.mypackage.vo.StoneVO;

	public class ItemLocator {
		public static var BASE_DIR:String="com/assets"; //装备图片的基本目录 (需要从配置我呢间读取)
		public var cacheItems:Dictionary = new Dictionary();

		public function ItemLocator() {
			BASE_DIR=GameConfig.ROOT_URL + BASE_DIR;
			equipsXML=CommonLocator.getXML(CommonLocator.EQUIP_URL);
			itemsXML=CommonLocator.getXML(CommonLocator.ITEM_URL)
			stonesXML=CommonLocator.getXML(CommonLocator.STONE_URL);
			itemLinkXML=CommonLocator.getXML(CommonLocator.ITEMLINK);
		}

		private static var instance:ItemLocator;

		public static function getInstance():ItemLocator {
			if (instance == null) {
				instance=new ItemLocator();
			}
			return instance;
		}

		public var allTypes:Array;

		public function getItemLinkByEffectType(effectType:int):Object {
			//trace("===="+itemLinkXML.@allTypes);
			if (allTypes == null) {
				allTypes=String(itemLinkXML.@allTypes).split("|");
			}
			var desc:Object={};
			try {
				var item:XMLList=itemLinkXML.item.(@effectType == effectType);
				desc.id=int(item.@id);
				desc.name=String(item.@name);
				desc.npcId_tai=String(item.@npcId_tai);
				desc.npcId_jing=String(item.@npcId_jing);
				desc.judgeLvl=int(item.@judgeLvl);
				desc.desc=String(item.desc);
				desc.preview=String(item.@perview);
			} catch (e:Error) {
			}
			return desc;
		}

		public function getAllItemLinkType():Array {
			if (!allTypes)
				allTypes=String(itemLinkXML.@allTypes).split("|");

			return allTypes;
		}

		public function getItem(type:int, typeId:int):Object {
			try{
				switch (type) {
					case ItemConstant.TYPE_EQUIP:
						return getEquip(typeId);
					case ItemConstant.TYPE_GENERAL:
						return getGeneral(typeId);
					case ItemConstant.TYPE_STONE:
						return getStone(typeId);
				}
				return null;
			}catch(e:*){
				trace("数据ID异常："+typeId);
			}
			return null;
		}

		public function getGeneral(typeId:int):Object {
			var desc:Object = cacheItems[typeId];
			if (desc == null) {
				var item:XML=itemsXML.item.(@id == typeId)[0];
				if(desc == null){
					desc = new Object();
					desc.kind=int(item.@kind);
					desc.name=String(item.@name);
					desc.minlvl=int(item.@minlvl);
					desc.maxlvl=int(item.@maxlvl);
					desc.color=int(item.@color);
					desc.effectType=int(item.@effectType);
					desc.usenum=int(item.@usenum);
					desc.path=BASE_DIR + String(item.@path);
					desc.desc=String(item.@desc);
					desc.preview=String(item.@preview);
					desc.maxico=BASE_DIR + String(item.@maxico);
					cacheItems[typeId] = desc;
				}
			}
			return desc;
		}

		public function getEquip(typeId:int):Object {
			var desc:Object = cacheItems[typeId];
			if(desc == null){
				var item:XML=equipsXML.equip.(@id == typeId)[0];
				if(item){
					desc = new Object();
					desc.name=String(item.@name);
					desc.sex=int(item.@sex);
					desc.minlvl=int(item.@minlvl);
					desc.maxlvl=int(item.@maxlvl);
					desc.kind=int(item.@kind);
					desc.color=int(item.@color);
					desc.putWhere=int(item.@putWhere);
					desc.path=BASE_DIR + String(item.@path);
					desc.desc=String(item.@desc);
					desc.material=int(item.@material);
					desc.form=String(item.@form);
					desc.preview=String(item.@preview);
					desc.maxico=BASE_DIR + String(item.@maxico);
					cacheItems[typeId] = desc;
				}
			}
			return desc;
		}

		public function getStone(typeId:int):Object {
			var desc:Object = cacheItems[typeId];
			if(desc == null){
				var item:XML=stonesXML.stone.(@id == typeId)[0];
				if(item){
					desc = new Object();
					desc.name=String(item.@name);
					desc.color=int(item.@color);
					desc.type=int(item.@type);
					desc.path=BASE_DIR + String(item.@path);
					desc.desc=String(item.@desc);
					desc.preview=String(item.@preview);
					desc.embe_equip_list=String(item.@embe_equip_list);
					desc.maxico=BASE_DIR + String(item.@maxico);
				}
			}
			return desc;
		}

		public function getObject(typeId:int):BaseItemVO {
			try {
				var type:int=int(typeId.toString().substr(0, 1));
				var itemVO:BaseItemVO;
				switch (type) {
					case ItemConstant.TYPE_EQUIP:
						itemVO=new EquipVO();
						break;
					case ItemConstant.TYPE_GENERAL:
						itemVO=new GeneralVO();
						break;
					case ItemConstant.TYPE_STONE:
						itemVO=new StoneVO();
						break;
				}
				if (itemVO)
					itemVO.typeId=typeId;
			} catch (e:*) {
				throw new Error("不存在ID为" + typeId + "的物品!");
			}
			return itemVO;
		}

		public function getForm(typeId:int):String {
			if(cacheItems.hasOwnProperty(typeId)){
				return cacheItems[typeId].form;
			}
			var item:Object=getEquip(typeId);
			if (item == null)
				return '';
			return item.form;
		}

		public var equipsXML:XML;
		public var itemsXML:XML;
		public var stonesXML:XML;
		public var itemLinkXML:XML; //链接需要支持的功能
	}
}
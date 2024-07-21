package modules.finery {
	import flash.utils.Dictionary;
	
	import modules.finery.views.vo.StoveItemVO;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	import modules.mypackage.vo.GeneralVO;
	import modules.mypackage.vo.StoneVO;

	public class StoveMaterialFilter {
		public function StoveMaterialFilter() {
		}

		private static var recastMaterial:Array;
		private static var punchMaterial:Array;
		private static var insertStones:Array;
		private static var insertSymbols:Array;
		private static var disassemblySymbols:Array;
		private static var strengthMaterials:Array;
		private static var bindStones:Array;
		private static var bindMaterials:Array;
		private static var exaltMaterials:Array;
		private static var upgradeMaterials:Array;

		public static function createShopVo(typeId:int, isBind:Boolean=false):StoveItemVO {
            var vo:StoveItemVO=new StoveItemVO();
            vo.isBind=isBind;
            vo.vo=ItemLocator.getInstance().getObject(typeId);
            return vo;
		}

		public static function getBindItem(ids:Array, isBind:Boolean=true):Array {
			var result:Array=[];
			var packItems:Array=PackManager.getInstance().packItems;
			for each (var item:BaseItemVO in packItems) {
				if (item) {
					var index:int=ids.indexOf(item.typeId);
					if (index != -1 && item.bind == isBind) {
						result.push(createShopVo(item.typeId, isBind));
						ids.splice(index, 1);
						if (ids.length == 0) {
							return result;
						}
					}
				}
			}
			return result;
		}

		/**
		 * 追加并按一定的规则排序
         * 当已经有绑定的物品，并没有不绑定物品时，不显示不绑定物品
		 * @param showArr 不绑定并且要显示的数据
		 * @param appendArr 绑定的数据
		 * @return
		 *
		 */
		public static function appenAndSortMaterial(showArr:Array, appendArr:Array):Array {
			var result:Array=[];
			if (showArr == null || showArr.length == 0) {
				if (appendArr == null || appendArr.length == 0) {
					return result;
				} else {
					result=appendArr;
					return result;
				}
			}
			showArr.sort(function compare(a:StoveItemVO, b:StoveItemVO):int {
					if (BaseItemVO(a.vo).typeId > BaseItemVO(b.vo).typeId) {
						return 1;
					}
					if (BaseItemVO(a.vo).typeId < BaseItemVO(b.vo).typeId) {
						return -1;
					}
					return 0;
				});
			if (appendArr == null || appendArr.length == 0) {
				result=showArr;
			} else {
				appendArr.sort(function compare(a:StoveItemVO, b:StoveItemVO):int {
						if (BaseItemVO(a.vo).typeId > BaseItemVO(b.vo).typeId) {
							return 1;
						}
						if (BaseItemVO(a.vo).typeId < BaseItemVO(b.vo).typeId) {
							return -1;
						}
						return 0;
					});
				for each (var showVo:StoveItemVO in showArr) {
                    var isHasBindGoods:Boolean = false;
					for each (var appendVo:StoveItemVO in appendArr) {
						if (BaseItemVO(appendVo.vo).typeId == BaseItemVO(showVo.vo).typeId) {
                            isHasBindGoods = true;
							result.push(appendVo);
							break;
						}
					}
                    var isHasNotBindGoods:Boolean = false;
                    var notBindNumber:int = PackManager.getInstance().getBindGoodsNunByTypeId(BaseItemVO(appendVo.vo).typeId,false);
                    if(notBindNumber > 0){
                        isHasNotBindGoods = true;
                    }
                    if(!(isHasNotBindGoods == false && isHasBindGoods == true)){
                        result.push(showVo);
                    }
				}
				for each (var tempAppendVo:StoveItemVO in appendArr) {
					var flag:Boolean=false;
					for each (var tempShowVo:StoveItemVO in showArr) {
						if (BaseItemVO(tempAppendVo.vo).typeId == BaseItemVO(tempShowVo.vo).typeId) {
							flag=true;
						}
					}
					if (!flag) {
						result.push(tempAppendVo);
					}
				}
			}
			return result;
		}

		/**
		 * 10600001~10600003:开孔锥
		 */
		public static function punch():Array {
			var result:Array=[];
			if (punchMaterial == null) {
				punchMaterial=[createShopVo(10600001), createShopVo(10600002), createShopVo(10600003)];
			}
			result=StoveMaterialFilter.appenAndSortMaterial(punchMaterial, getBindItem([10600001, 10600002, 10600003]));
			return result;
		}
		/**
		 * 创建商店重铸石列表 
		 * @return 
		 * 
		 */
		public static function recastStones():Array{
			var result:Array=[];
			if (recastMaterial == null) {
				recastMaterial=[createShopVo(10404001), createShopVo(10404002), createShopVo(10404003)];
			}
			result=recastMaterial.concat(getBindItem([10404004, 10404005, 10404006], false));
			result=StoveMaterialFilter.appenAndSortMaterial(result, getBindItem([10404001, 10404002, 10404003,10404004,10404005,10404006]));
			return result;
		}
		/**
		 * 取背包的灵石
		 */
		public static function insertStone():Array {
			var result:Array=[];
			var ids:Array=[];
			var packItems:Array=PackManager.getInstance().packItems;
			for each (var item:BaseItemVO in packItems) {
				if (item is StoneVO && item.typeId != 23100001 && item.typeId != 23200001 && ids.indexOf(item.typeId) ==
					-1) {
					ids.push(item.typeId);
				}
			}
			result=result.concat(getBindItem(ids.concat(), false));
			result=result.concat(getBindItem(ids));
			return result;
		}
		
		/**
		 * 根据当前镶嵌装备获取合适的背包灵石
		 */
		public static function insertStoneByEquip(putWhere:int=-1):Array {
			var result:Array=[];
			var ids:Array=[];
			var packItems:Array=PackManager.getInstance().packItems;
			for each (var item:BaseItemVO in packItems) {
				var stoneVO:StoneVO = item as StoneVO;
				if (stoneVO && stoneVO.typeId != 23100001 && stoneVO.typeId != 23200001 && ids.indexOf(item.typeId) == -1) {
					var equipPos:Array = stoneVO.embe_equip_list;
					if(putWhere != -1 && equipPos && equipPos.indexOf(putWhere.toString()) != -1){
						ids.push(item.typeId);
					}else if(putWhere == -1){
						ids.push(item.typeId);
					}
				}
			}
			result=result.concat(getBindItem(ids.concat(), false));
			result=result.concat(getBindItem(ids));
			return result;
		}

		/**
		 *镶嵌符 10600007~10600009
		 */
		public static function insertSymbol():Array {
			var result:Array=[];
			if (insertSymbols == null) {
				insertSymbols=[createShopVo(10600007), createShopVo(10600008), createShopVo(10600009)];
			}
			result=StoveMaterialFilter.appenAndSortMaterial(insertSymbols, getBindItem([10600007, 10600008, 10600009]));
			return result;
		}

		/**
		 * 拆卸保护符
		 */
		public static function disassemblySymbol():Array {
			var result:Array=[];
			if (disassemblySymbols == null) {
				disassemblySymbols=[createShopVo(10600013)];
			}
			result=disassemblySymbols.concat(getBindItem([10600013]));
			return result;
		}

		/**
		 * 强化石10401001
		 */
		public static function strengthMaterial():Array {
			var result:Array=[];
			if (strengthMaterials == null) {
				strengthMaterials=[createShopVo(10401001), createShopVo(10401002)];
			}
			result=strengthMaterials.concat(getBindItem([10401004, 10401005, 10401006], false));
			result=StoveMaterialFilter.appenAndSortMaterial(result, getBindItem([10401001, 10401002]));
			return result;
		}

		/**
		 * 绑定血灵珠
		 */
		public static function bindStone():Array {
			var result:Array=[];
			if (bindStones == null) {
				bindStones=[createShopVo(23100001)];
			}
			result=bindStones.concat(getBindItem([23100001]));
			return result;
		}

		/**
		 * 绑定材料
		 */
		public static function bindMaterial():Array {
			var result:Array=[];
			if (bindMaterials == null) {
				bindMaterials=[createShopVo(10410006), createShopVo(10410007)];
			}
			result=StoveMaterialFilter.appenAndSortMaterial(bindMaterials, getBindItem([10410006,10410007]));
			return result;
		}

		/**
		 *
		 * @return
		 * 10410001	,<<"	绿色材料
		   10410002	,<<"	蓝色材料
		   10410003	,<<"	紫色材料
		   10410004	,<<"	橙色材料
		   10410005	,<<"	金色材料
		 */
		public static function exalt():Array {
            var result:Array=[];
			if (exaltMaterials == null) {
				exaltMaterials=[createShopVo(10410001), createShopVo(10410002), createShopVo(10410003), createShopVo(10410004)]
			}
            result=StoveMaterialFilter.appenAndSortMaterial(exaltMaterials, getBindItem([10410001,10410002,10410003,10410004]));
			return result;
		}

		public static function percent(equip:BaseItemVO, material:BaseItemVO):Number {
			var colorSpan:int=equip.color - material.color;
			var levelSpan:int=int(material.level / 10) - int(equip.level / 10);
			if (material is EquipVO) {
				for (var j:int=0; j < StoveConstant.equipPCT.length; j++) {
					var levelItem:Array=StoveConstant.equipPCT[j];
					if (levelSpan > levelItem[0][0] && levelSpan < levelItem[0][1]) {
						for (var k:int=1; k < levelItem.length; k++) {
							var colorItem:Array=levelItem[k];
							if (colorSpan > colorItem[0] && colorSpan < colorItem[1]) {
								return colorItem[2];
							}
						}
					}
				}
			} else if (material is GeneralVO) {
				for (var i:int=0; i < StoveConstant.materialPCT.length; i++) {
					var item:Array=StoveConstant.materialPCT[i]
					if (colorSpan > item[0] && colorSpan < item[1]) {
						return item[2];
					}
				}
			}
			return 0;
		}

		/**
		 *10600104 40级装备符
		 * @return
		 * 开发到120级 10600112；
		 */
		private static var upgradeSymbolID:Array;
		public static function upgrade():Array{
			var result:Array=[];
			if (upgradeMaterials == null) {
				upgradeMaterials = [];
				upgradeSymbolID = [];
				var temp:Array = [];
				for(var i:int=0; i < StoveConstant.upgradeSymbols.length; i++){
					temp.push(createShopVo(StoveConstant.upgradeSymbols[i].id));
					upgradeSymbolID.push(StoveConstant.upgradeSymbols[i].id);
				}
				upgradeMaterials=temp;
			}
			result=StoveMaterialFilter.appenAndSortMaterial(upgradeMaterials, getBindItem(upgradeSymbolID.concat()));
			return result;
		}
	}
}
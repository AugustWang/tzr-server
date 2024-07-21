package modules.navigation {
	import com.common.GlobalObjectManager;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.net.SocketCommand;
	import com.utils.KeyUtil;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.equiponekey.views.items.ClothingItemVO;
	import modules.family.FamilyLocator;
	import modules.friend.FriendsManager;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.GeneralVO;
	import modules.navigation.views.HotKeyBox;
	import modules.navigation.views.NavBar;
	import modules.playerGuide.GuideConstant;
	import modules.skill.SkillDataManager;
	import modules.skill.SkillModule;
	import modules.skillTree.SkillTreeModule;
	
	import proto.line.m_shortcut_init_toc;
	import proto.line.m_shortcut_update_tos;
	import proto.line.p_shortcut;

	/**
	 * 导航栏目模块(负责接收和处理导航栏目模块的相关指令)
	 */
	public class NavigationModule extends BaseModule {
		public static const SKILL_TYPE:int=1;
		public static const ITEM_TYPE:int=2;
		public static const CLOTHING_TYPE:int=3;

		public var gameInit:Boolean=false;
		private var initHotKey:Boolean=false;

		public function NavigationModule() {

		}

		private static var instance:NavigationModule;

		public static function getInstance():NavigationModule {
			if (instance == null) {
				instance=new NavigationModule();
			}
			return instance;
		}

		override protected function initListeners():void {
			addMessageListener(ModuleCommand.ENTER_GAME, onEnterGame);
			addMessageListener(ModuleCommand.EXP_CHAGNGE, setRoleExp);
			addMessageListener(ModuleCommand.GOODS_CHANGED, goodsCountChange);
			addMessageListener(ModuleCommand.RESET_SKILL, removeAllSkillItem);
			addMessageListener(ModuleCommand.REMOVE_SKILL_ITEM, removeSkill);
			addMessageListener(ModuleCommand.SOCIETY_FLICK, onSocietyFlick);
			addMessageListener(ModuleCommand.STOP_SOCIETY_FLICK, onStopSocietyFlick);
			addMessageListener(ModuleCommand.FRIEND_FLICK, onFriendFlick);
			addMessageListener(ModuleCommand.FRIEND_STOP_FLICK, onFriendStopFlick);
			addMessageListener(ModuleCommand.CLOTHING_NAME_CHANGED, clothingChangedHandler);
			addMessageListener(ModuleCommand.SHOW_HP_TIP, showGaoyao);
			addMessageListener(ModuleCommand.ROLE_DEAD_ALIVE, onRoleDeadAlive);
			addMessageListener(ModuleCommand.STAGE_RESIZE, onStageResize);
			addSocketListener(SocketCommand.SHORTCUT_INIT, initHotBar);
		}


		public function startRoleFlick():void {
			if (this.navBar) {
				navBar.flickRole();
			}
		}

		public function stopRoleFlick():void {
			if (this.navBar) {
				navBar.stopFlickRole();
			}
		}

		public function startSkillFlick():void {
			if (this.navBar) {
				navBar.flickSkill();
			}
		}

		public function stopSkillFlick():void {
			if (this.navBar) {
				navBar.stopFlickSkill();
			}
		}

		public function startBagFlick():void {
			if (this.navBar) {
				navBar.flickBag();
			}
		}

		public function stopBagFlick():void {
			if (this.navBar) {
				navBar.stopBag();
			}
		}

		public function set enabled(value:Boolean):void {
			navBar.mouseEnabled=navBar.mouseChildren=value;
		}

		private function onEnterGame():void {
			if (!gameInit) {
				gameInit=true;
				addToolBar();
				FriendsManager.getInstance().showOfflineRequest();
				FamilyLocator.getInstance().showFamilyRequest();
			}
		}

		private function onSocietyFlick():void {
			if (navBar) {
				navBar.flickSociety();
			}
		}

		private function onStopSocietyFlick():void {
			if (navBar) {
				navBar.stopSocietyFlick();
			}
		}

		private function onFriendFlick():void {
			if (navBar) {
				navBar.flickFriend();
			}
		}

		private function onFriendStopFlick():void {
			if (navBar) {
				navBar.stopFlick();
			}
		}

		private function onRoleDeadAlive(alive:Boolean):void {
			if (navBar) {
				navBar.mouseChildren=alive;
				WindowManager.getInstance().removeAllWindow();
				KeyUtil.getInstance().enabled=alive;
			}
		}

		private function onStageResize(value:Object):void {
			if (navBar) {
				navBar.x=int((GlobalObjectManager.GAME_WIDTH - 1000) * 0.5);
				navBar.y=GlobalObjectManager.GAME_HEIGHT - 56 //501; // 533
			}
		}

		public function getNacBarPos():Point {
			return new Point(navBar.x, navBar.y);
		}

		private function removeAllSkillItem():void {
			navBar.upgoodsBox.removeAllSkillItem();
			navBar.downgoodsBox.removeAllSkillItem();
			updateHotBar();
		}

		private function removeSkill(data:Object):void {
			navBar.upgoodsBox.removeSkill(data.category, data.skillid);
			navBar.downgoodsBox.removeSkill(data.category, data.skillid);
			updateHotBar();
		}

		public function goodsCountChange(type:int):void {
			navBar.downgoodsBox.updateGoods(type);
			navBar.upgoodsBox.updateGoods(type);
		}

		private function setRoleExp():void {
			if (navBar) {
				var newExp:Number=GlobalObjectManager.getInstance().user.attr.exp;
				navBar.setExpProgress(newExp);
			}
		}

		public var navBar:NavBar;

		private function addToolBar():void {
			if (navBar == null) {
				navBar=new NavBar();
				navBar.x=int((GlobalObjectManager.GAME_WIDTH - 1000) * 0.5);
				navBar.y=GlobalObjectManager.GAME_HEIGHT - 56 //501; // 533
				initHotKeys();
			}
			LayerManager.uiLayer.addChild(navBar);
			setRoleExp();
		}

		private function initHotKeys():void {
			if (initHotKey)
				return;
			if (navBar && ups && downs) {
				navBar.upgoodsBox.setItems(ups);
				navBar.downgoodsBox.setItems(downs);
				initHotKey=true;
				SkillTreeModule.getInstance().getSkills()
				navBar.upgoodsBox.updataSkillAutoStatus();
				navBar.downgoodsBox.updataSkillAutoStatus();
			}
		}

		/**
		 * 初始化热键
		 */
		private var ups:Array;
		private var downs:Array;

		private function initHotBar(voc:m_shortcut_init_toc):void {
			onEnterGame();
			PackManager.getInstance().addEventListener(Event.COMPLETE, onLoadComplete);
			var list:Array=voc.shortcut_list;
			ups=getHotKeys(list.slice(0, HotKeyBox.HOT_KEY_COUNT));
			downs=getHotKeys(list.slice(HotKeyBox.HOT_KEY_COUNT, 20));
			initHotKeys();
			SkillModule.getInstance().autoSkill=SkillDataManager.getSkill(voc.selected);
		}

		private function onLoadComplete(event:Event):void {
			initHotKeys();
		}

		/**
		 * 更新热键位置
		 */
		public function updateHotBar():void {
			var voc:m_shortcut_update_tos=new m_shortcut_update_tos();
			voc.shortcut_list=getItems();
			SkillDataManager.autoSkill != null ? voc.selected=SkillDataManager.autoSkill.sid : voc.selected=0;
			sendSocketMessage(voc);
		}

		/**
		 * 获取快捷栏信息
		 */
		public function getItems():Array {
			var list:Array=navBar.upgoodsBox.getItems();
			list=list.concat(navBar.downgoodsBox.getItems());
			return list;
		}

		public function addItemAt(item:Object, index:int):void {
			if (index <= (HotKeyBox.HOT_KEY_COUNT-1)) {
				navBar.upgoodsBox.setItemAt(item, index);
			} else {
				index=index % HotKeyBox.HOT_KEY_COUNT;
				navBar.downgoodsBox.setItemAt(item, index);
			}
			updateHotBar();
		}

		public function clearItemAt(index:int):void {
			if (index <= 9) {
				navBar.upgoodsBox.clearContent(index);
			} else {
				index=index % HotKeyBox.HOT_KEY_COUNT;
				navBar.downgoodsBox.clearContent(index);
			}
			updateHotBar();
		}

		public function addItemToEnd(item:BaseItemVO):void {
			var level:int=GlobalObjectManager.getInstance().user.attr.level;
			if (level < 20) {
				var list:Array=navBar.downgoodsBox.getItems();
				var put:int=8;
				for (var i:int=list.length - 1; i >= 0; i--) {
					var hotItem:p_shortcut=list[i];
					if (hotItem.id == 0 && put == 8) {
						put=put + (i + 1);
					}
					if (hotItem.type == ITEM_TYPE && hotItem.id == item.typeId) {
						put=-1;
						break;
					}
				}
				if (put > 8) {
					addItemAt(item, put);
				}
			}
		}

		public var isShow:Boolean;

		public function showGaoyao():void {
			var items:Array=navBar.downgoodsBox.getDatas();
			var currentIndex:int=-1;
			for (var i:int=0; i < items.length; i++) {
				var itemVO:GeneralVO=items[i] as GeneralVO;
				if (itemVO && itemVO.effectType == ItemConstant.EFFECT_HP) {
					currentIndex=i;
					break;
				}
			}
			if (currentIndex != -1) {
				this.dispatch(GuideConstant.HP_DOWN_TIP, ['有战争就有流血，使用金创药可助你恢复血量。', navBar.x - 45 + currentIndex * 37, GlobalObjectManager.GAME_HEIGHT - 160]);
				isShow=true;
			}
		}


		private function getHotKeys(list:Array):Array {
			var hotkeys:Array=[];
			for each (var vo:p_shortcut in list) {
				var hotkeyVO:Object=null;
				if (vo) {
					if (vo.type == SKILL_TYPE) {
						hotkeyVO=SkillDataManager.getSkill(vo.id);
					} else if (vo.type == ITEM_TYPE) {
						hotkeyVO=ItemLocator.getInstance().getObject(vo.id);
					} else if (vo.type == CLOTHING_TYPE) {
						var clothingItemVO:ClothingItemVO=new ClothingItemVO();
						clothingItemVO.suitId=vo.id;
						clothingItemVO.name=vo.name;
						clothingItemVO.draw();
						hotkeyVO=clothingItemVO;
					}
				}
				hotkeys.push(hotkeyVO);
			}
			return hotkeys;
		}

		private function clothingChangedHandler(clothinItemVo:ClothingItemVO):void {
			var items:Array=navBar.upgoodsBox.getDatas();
			for (var i:int=0; i < HotKeyBox.HOT_KEY_COUNT; i++) {
				var itemVo:Object=items[i];
				var clothingVO:ClothingItemVO=itemVo as ClothingItemVO;
				if (clothingVO && clothingVO.suitId == clothinItemVo.suitId) {
					clothingVO.name=clothinItemVo.name;
					clothingVO.path=clothinItemVo.path;
					navBar.upgoodsBox.setItemAt(clothingVO, i);
				}
			}
			items=navBar.downgoodsBox.getDatas();
			for (i=0; i < HotKeyBox.HOT_KEY_COUNT; i++) {
				itemVo=items[i];
				clothingVO=itemVo as ClothingItemVO;
				if (clothingVO && clothingVO.suitId == clothinItemVo.suitId) {
					clothingVO.name=clothinItemVo.name;
					clothingVO.path=clothinItemVo.path;
					navBar.downgoodsBox.setItemAt(clothingVO, i);
				}
			}
			updateHotBar();
		}
	}
}
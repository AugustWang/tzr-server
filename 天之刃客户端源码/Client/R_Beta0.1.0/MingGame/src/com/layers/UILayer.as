package com.layers
{
	import com.common.GlobalObjectManager;
	import com.common.dragManager.DragItemManager;
	import com.components.BoxItems;
	import com.managers.Dispatch;
	import com.ming.managers.ToolTipManager;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import modules.ModuleCommand;
	import modules.achievement.views.AchievementGoodsToolTip;
	import modules.friend.views.part.ChatWindowBar;
	import modules.heroFB.HeroFBModule;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.views.ItemToolTip;
	import modules.scene.SceneDataManager;
	import modules.sceneWarFb.SceneWarFbModule;

	public class UILayer extends Sprite
	{
		public var box:BoxItems;
		public var chatwindowBar:ChatWindowBar;
		public function UILayer()
		{
			this.mouseEnabled=false; 
			init();
		}
		
		private function init():void
		{
			ToolTipManager.registerToolTip(ItemConstant.ITEM_TOOLTIP, ItemToolTip);
			Dispatch.register(ModuleCommand.STAGE_RESIZE,onStageResize);
			ToolTipManager.registerToolTip("targetToolTip",AchievementGoodsToolTip);
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			with(this.graphics){
				beginFill(0x0, 0);
				drawRect(0, 0, GlobalObjectManager.GAME_WIDTH, GlobalObjectManager.GAME_HEIGHT);
				endFill();
			}
			box = new BoxItems();
			box.y = 340;
			addChild(box);
			
			chatwindowBar=new ChatWindowBar();
			chatwindowBar.x=GlobalObjectManager.GAME_WIDTH * 0.5 + 170;
			chatwindowBar.y=GlobalObjectManager.GAME_HEIGHT - 110;
			addChild(chatwindowBar);
            
            Dispatch.register(ModuleCommand.CHANGE_MAP_ROLE_READY,onChangeMapRoleReady);
		}
		
		public function hide():void{
			box.visible = false;	
		}
		
		public function show():void{
			box.visible = true;
		}
		
		public function addIcon(icon:DisplayObject):void{
			//box.addIcon(icon);
		}
		
		public function removeIcon(icon:DisplayObject):void{
			box.removeIcon(icon);
		}
		
		public function removeAllIcon():void{
			box.removeAllIcon();
		}
		
		public function onStageResize(value:Object):void{
			box.onStageResize(value);
			chatwindowBar.x=GlobalObjectManager.GAME_WIDTH * 0.5 + 170;
			chatwindowBar.y=GlobalObjectManager.GAME_HEIGHT - 82;
		}
		
		private function onAddedToStage(event:Event):void{
			DragItemManager.setUp(this);
		}
        /**
         * 处理在那些地图显示小图标
         */        
        private function onChangeMapRoleReady():void {
            var mapId:int = SceneDataManager.mapData.map_id;
            var isHeroFBMapId:Boolean = HeroFBModule.getInstance().isMapHeroFB(mapId);
            var isSceneWarFbMapId:Boolean = SceneWarFbModule.getInstance().isSceneWarFbMapId(mapId);
            var isCountryTreasureFbMapId:Boolean = (10500 == mapId);
            var isVieWarFbMapId:Boolean = (10400 == mapId);
            if (isHeroFBMapId || isSceneWarFbMapId || isCountryTreasureFbMapId || isVieWarFbMapId || HeroFBModule.isOpenHeroFBPanel){
                box.visible = false;   
            }else{
                box.visible = true;
            }
                
        }
	}
}
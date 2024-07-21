package modules.Activity.activityManager
{
	import com.components.alert.Prompt;
	import com.events.ParamEvent;
	import com.globals.GameConfig;
	import com.scene.WorldManager;
	import com.scene.sceneManager.LoopManager;
	import com.utils.DateFormatUtil;
	import com.utils.HtmlUtil;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import modules.Activity.ActivityModule;
	import modules.Activity.vo.BossDropThingVO;
	import modules.Activity.vo.BossGroupVO;
	import modules.system.SystemConfig;
	
	import proto.common.p_boss_group;

	public class BossGroupManager extends EventDispatcher
	{
		public static const BOSS_GROUP:String = "BOSS_GROUP";
		public static const INIT_COMPLETE:String = "INIT_COMPLETE";
		public static const TIME_TICK:String = "TIME_TICK";
		public static const BOSSGROUP_UPDATE:String = "BOSSGROUP_UPDATE";
		public var inited:Boolean = false;
		private var urlLoader:URLLoader;
		private var currentDate:Date;
		private var today:int;
		private var boosGroupXML:XML;
		public var bossList:Array;
		private var attentions:Array;
		public function BossGroupManager()
		{
		}
		
		private static var _instance:BossGroupManager;
		public static function getInstance():BossGroupManager{
			if(_instance == null){
				_instance = new BossGroupManager();
			}
			return _instance;
		}
		
		public function startInit():void{
			if(urlLoader == null){
				urlLoader = new URLLoader();
				urlLoader.addEventListener(Event.COMPLETE,loadCompleteHandler);
				urlLoader.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
				urlLoader.load(new URLRequest(GameConfig.BOSS_GROUP_XML_URL));
			}
		}
		
		private function loadCompleteHandler(event:Event):void{
			inited = true;
			boosGroupXML = new XML(urlLoader.data);
			dispatchEvent(new ParamEvent(INIT_COMPLETE));
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void{
			removeListener();
			inited = false;
		}
		
		private function removeListener():void{
			urlLoader.removeEventListener(Event.COMPLETE,loadCompleteHandler);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
		}
		
		public function setdGroupList(list:Array):void{
			bossList = new Array();
			for each(var vo:p_boss_group in list){
				if(vo.end_time > SystemConfig.serverTime){
					var bossGroupVO:BossGroupVO = new BossGroupVO();
					bossGroupVO.id = vo.boss_id;
					bossGroupVO.startTime = vo.start_time;
					bossGroupVO.duration = vo.last_time;
					bossGroupVO.endTime = vo.end_time;
					bossGroupVO.gapTime = vo.space_time;
					wrapperBossGroupVO(bossGroupVO);
					bossList.push(bossGroupVO);
				}
			}
			dispatchEvent(new ParamEvent(BOSSGROUP_UPDATE));	
		}
		
		public function updateGroupBossVO(bossId:int,mapId:int,tx:int,ty:int):void{
			for each(var bossGroupVO:BossGroupVO in bossList){
				if(bossGroupVO.id == bossId){
					bossGroupVO.mapName = WorldManager.getCityVo(mapId).name;
					bossGroupVO.mapId = mapId;
					bossGroupVO.tx = tx;
					bossGroupVO.ty = ty;
					break;
				}
			}
		}
		
		public function addAttention(bossId:int):void{
			if(attentions == null){
				attentions = [];
			}
			if(!hasAttention(bossId)){
				attentions.push(bossId);
			}
		}
		
		public function removeAttention(bossId:int):void{
			if(attentions){
				var index:int = attentions.indexOf(bossId);
				attentions.splice(index,1);
			}
		}
		
		public function hasAttention(bossId:int):Boolean{
			if(attentions){
				return attentions.indexOf(bossId) != -1;
			}
			return false;
		}
		
		public function wrapperBossGroupVO(bossGroupVO:BossGroupVO):void{
			if(boosGroupXML){
				var bossXML:XML = boosGroupXML..boss.(@id == bossGroupVO.id)[0];
				bossGroupVO.name = bossXML.@name;
				bossGroupVO.desc = bossXML.desc[0].text();
				bossGroupVO.level = bossXML.@level;
				bossGroupVO.dropThings = new Array();
				var dropThingsXML:XMLList = bossXML..goodsItem;
				for each(var dropThingXML:XML in dropThingsXML){
					var dropThing:BossDropThingVO = new BossDropThingVO();
					dropThing.typeId = dropThingXML.@typeId;
					dropThing.name = dropThingXML.@name;
					dropThing.color = dropThingXML.@color;
					bossGroupVO.dropThings.push(dropThing);
				}
				
			}			
		}
		
		public function startTimer():void{
			if(currentDate == null){
				currentDate = new Date();
				currentDate.time = SystemConfig.serverTime*1000;
				today = currentDate.date;
			}
			LoopManager.addToSecond(BOSS_GROUP,timerHandler);
		}
		
		public function stopTimer():void{
			LoopManager.removeFromSceond(BOSS_GROUP);
		}
		
		private function timerHandler():void{
			currentDate.time = SystemConfig.serverTime*1000;
			if(today != currentDate.date){
				today = currentDate.date;
				return;
			}
			for each(var bossGroupVO:BossGroupVO in bossList){
				var leaveTime:int = SystemConfig.serverTime - bossGroupVO.startTime;
				if(leaveTime < 0 ){
					bossGroupVO.state = BossGroupVO.UN_START;
					bossGroupVO.mapName = BossGroupVO.UNKNOW;
					bossGroupVO.stateDesc = HtmlUtil.font(DateFormatUtil.formatTime(-leaveTime),"#ff0000");
				}else if(SystemConfig.serverTime > bossGroupVO.endTime){
					var index:int = bossList.indexOf(bossGroupVO);
					if(index != -1){
						bossList.splice(index,1);
						dispatchEvent(new ParamEvent(BOSSGROUP_UPDATE));
					}
				}else{
					var currentTime:int = leaveTime%bossGroupVO.gapTime-bossGroupVO.duration;
					if(currentTime < 0){
						if(hasAttention(bossGroupVO.id) && bossGroupVO.state != BossGroupVO.START){
							bossAppear(bossGroupVO);
						}
						bossGroupVO.state = BossGroupVO.START;
						bossGroupVO.stateDesc = HtmlUtil.font("击杀中","#00ff00");
					}else if(leaveTime > 0){
						bossGroupVO.state = BossGroupVO.UN_START;
						bossGroupVO.mapName = BossGroupVO.UNKNOW;
						bossGroupVO.stateDesc = HtmlUtil.font(DateFormatUtil.formatTime(bossGroupVO.gapTime - bossGroupVO.duration - currentTime),"#ff0000");
					}
				}
				bossGroupVO.callBack();
			}
			dispatchEvent(new ParamEvent(TIME_TICK));
		}
		
		private function bossAppear(bossGroupVO:BossGroupVO):void{
			Prompt.show(bossGroupVO.name+"已经出现了，是否立即前往击杀？立即传送将消耗一个传送卷。","Boss击杀提示",yesHandler,null,"立即前往");
			function yesHandler():void{
				ActivityModule.getInstance().requestBossGroupTransfer(bossGroupVO.id);
			}
		}
	}	
}
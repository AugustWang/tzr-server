package modules.sceneWarFb {
	import com.common.GlobalObjectManager;
	import com.components.MessageIconManager;
	import com.components.alert.Alert;
	import com.events.ParamEvent;
	import com.loaders.CommonLocator;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.net.SocketCommand;
	import com.scene.sceneUtils.RoleActState;
	
	import flash.events.TextEvent;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.duplicate.views.DuplicateNPCPanel;
	import modules.duplicate.vo.ContentVO;
	import modules.duplicate.vo.TalkContentVO;
	import modules.duplicate.vo.TalkVO;
	import modules.npc.NPCActionType;
	import modules.npc.vo.NpcLinkVO;
	import modules.scene.SceneDataManager;
	import modules.sceneWarFb.CallMonsterTip;
	import modules.smallMap.SmallMapModule;
	
	import proto.common.p_scene_war_fb_link;
	import proto.line.m_scene_war_fb_call_monster_toc;
	import proto.line.m_scene_war_fb_call_monster_tos;
	import proto.line.m_scene_war_fb_enter_toc;
	import proto.line.m_scene_war_fb_enter_tos;
	import proto.line.m_scene_war_fb_query_toc;
	import proto.line.m_scene_war_fb_query_tos;
	import proto.line.m_scene_war_fb_quit_toc;
	import proto.line.m_scene_war_fb_quit_tos;

	/**
	 * 场景大战模块代码
	 * @author caochuncheng
	 *
	 */
	public class SceneWarFbModule extends BaseModule {
		
		public static const SCENEWARFB_QUERY_TYPE_OPEN:int = 1; //查询玩家副本信息
		public static const SCENEWARFB_NPC_TYPE_ENTER:int = 1; //查询玩家副本信息
		public static const SCENEWARFB_NPC_TYPE_QUIT:int = 2; //查询玩家副本信息
		public static const SCENEWARFB_PASS_MONSTER_CLEAR:int = 2; //当前关卡怪物清除
		public static const SCENEWARFB_FINISH_PASS_ID:int = -1; //关卡打完时  服务端发来的关卡id为0
		
		public function SceneWarFbModule() {
			super();
		}
		
		private static var instance:SceneWarFbModule;
		
		public static function getInstance():SceneWarFbModule {
			if (!instance) {
				instance = new SceneWarFbModule();
			}
			return instance;
		}
		
		/**
		 * 事件处理
		 */
		override protected function initListeners():void {
			this.addSocketListener(SocketCommand.SCENE_WAR_FB_ENTER,doSceneWarFbEnterToc);
			this.addSocketListener(SocketCommand.SCENE_WAR_FB_QUIT,doSceneWarFbQuitToc);
			this.addSocketListener(SocketCommand.SCENE_WAR_FB_QUERY,doSceneWarFbQueryToc);
			this.addSocketListener(SocketCommand.SCENE_WAR_FB_CALL_MONSTER,doSceneWarFbCallMonsterToc);
			this.addMessageListener(ModuleCommand.CHANGE_MAP_ROLE_READY,onChangeMapRoleReady);
			this.addMessageListener(NPCActionType.NA_100, doSceneWarFbCallMonster);
		}
		/**
		 * 界面显示处理
		 */
		
		/**
		 * 当前操作NPC
		 */
		private var curNpcId:int;
		
		/**
		 * 当前副本id 当前副本level 当前关卡
		 */
		private var curPassID:int=1;
		
		/**
		 * 点击师门副本相关NPC的操作界面
		 * @param vo
		 *
		 */
		public function doMouseClickNpc(npcId:int):void {
			this.curNpcId = npcId;
			var npcObj:Object = this.findSwFbNpcByNpcObj(npcId);
			if(npcObj != null && npcObj.npcType == SCENEWARFB_NPC_TYPE_ENTER){
				var enterVo:m_scene_war_fb_query_tos = new m_scene_war_fb_query_tos;
				enterVo.npc_id = this.curNpcId;
				enterVo.op_type = SCENEWARFB_QUERY_TYPE_OPEN;
				this.sendSocketMessage(enterVo);
			}else if(npcObj != null && npcObj.npcType == SCENEWARFB_NPC_TYPE_QUIT){
				this.openQuitNpcPanel(npcObj);
			}
		}
		/**
		 * 场景大战副本传着NPC对话内容
		 */
		private var npcPanel:DuplicateNPCPanel;
		
		/**
		 * 打开进入场景大战副本NPC
		 *
		 */
		private function openEnterNpcPanel(vo:m_scene_war_fb_query_toc):void {
			if (npcPanel == null) {
				npcPanel = new DuplicateNPCPanel();
				npcPanel.addEventListener(DuplicateNPCPanel.SHOW_CONTENT,onShowContent);
				npcPanel.addEventListener(DuplicateNPCPanel.OTHER,onOhter);
				npcPanel.addEventListener(DuplicateNPCPanel.FINISH,onFinish);
			}
			WindowManager.getInstance().openDistanceWindow(npcPanel);
			WindowManager.getInstance().centerWindow(npcPanel);
			var npcObj:Object = this.findSwFbNpcByNpcObj(vo.npc_id);
			var talkVO:TalkVO = new TalkVO();
			talkVO.name = npcObj.npcName;
			talkVO.talks = new Vector.<TalkContentVO>();
			
			var talkContent:TalkContentVO = new TalkContentVO();
			talkContent.contents = new Vector.<ContentVO>();
			talkContent.type = DuplicateNPCPanel.FINISH;
			
			
			
			var titleContent:ContentVO = new ContentVO();
			titleContent.type = DuplicateNPCPanel.CONTENT;
			titleContent.text = npcObj.description;
			talkContent.contents.push(titleContent);
			
			var isInitDescription:Boolean = false;
			for each (var linkObj:Object in npcObj.links) {
				if (linkObj.show_type == 0) { //链接
					var pSwFbLink:p_scene_war_fb_link = this.findSceneWarFbLink(linkObj.fb_type,linkObj.fb_level,vo.fb_links);
					if (pSwFbLink != null) {
						var enterLink:ContentVO = new ContentVO();
						enterLink.type = DuplicateNPCPanel.LINK;
						enterLink.text = linkObj.level_name;
						if(!isInitDescription){
							isInitDescription = true;
							if (pSwFbLink.fb_times > pSwFbLink.fb_max_times){
								titleContent.text = npcObj.description + "\n\n<font color=\"#3BE450\">每天可进入<font color=\"#FFFF00\">" + pSwFbLink.fb_max_times.toString() + 
									"</font>次，今天次数已满，请明天再继续</font>";
							}else{
								if (pSwFbLink.enter_fee > 0) {
									titleContent.text = npcObj.description + "\n\n<font color=\"#3BE450\">每天可进入<font color=\"#FFFF00\">" + pSwFbLink.fb_max_times.toString() + 
										"</font>次，当前为第<font color=\"#FFFF00\">"+ pSwFbLink.fb_times.toString() + "</font>次，费用：<font color=\"#FFFF00\">" + 
										pSwFbLink.enter_fee.toString() + "</font>元宝</font>";
								} else {
									titleContent.text = npcObj.description + "\n\n<font color=\"#3BE450\">每天可进入<font color=\"#FFFF00\">" + pSwFbLink.fb_max_times.toString() + 
										"</font>次，当前为第<font color=\"#FFFF00\">"+ pSwFbLink.fb_times.toString() + "</font>次</font>";
								}
							}
						}
						enterLink.linkType = DuplicateNPCPanel.OTHER;
						enterLink.data = "enterLink," + String(linkObj.npc_id) + "," + String(linkObj.fb_type) + "," + 
							String(linkObj.fb_level) + "," + String(pSwFbLink.fb_id) + "," + String(pSwFbLink.fb_seconds) + "," + 
							String(pSwFbLink.enter_fee);
						talkContent.contents.push(enterLink);
					}
				} else if (linkObj.show_type == 1) {//直接显示
					var showLink:ContentVO = new ContentVO();
					showLink.type = DuplicateNPCPanel.LINK;
					showLink.text = linkObj.level_name;
					showLink.linkType = DuplicateNPCPanel.SHOW_CONTENT;
					showLink.data = "showLink," + String(linkObj.npc_id) + "," + String(linkObj.fb_type) + "," + String(linkObj.fb_level);
					talkContent.contents.push(showLink);
				}
			}
			talkVO.talks.push(talkContent);
			npcPanel.talkVO = talkVO;
		}
		/**
		 * 打开退出场景大战副本NPC界面 
		 * @param npcObj
		 * 
		 */		
		private function openQuitNpcPanel(npcObj:Object):void{
			if(npcPanel == null){
				npcPanel = new DuplicateNPCPanel();
				npcPanel.addEventListener(DuplicateNPCPanel.SHOW_CONTENT,onShowContent);
				npcPanel.addEventListener(DuplicateNPCPanel.OTHER,onOhter);
				npcPanel.addEventListener(DuplicateNPCPanel.FINISH,onFinish);
			}
			WindowManager.getInstance().openDistanceWindow(npcPanel);
			WindowManager.getInstance().centerWindow(npcPanel);
			
			var talkVO:TalkVO = new TalkVO();
			talkVO.name = "NPC对话";
			talkVO.talks = new Vector.<TalkContentVO>();
			
			var talkContent:TalkContentVO = new TalkContentVO();
			talkContent.contents = new Vector.<ContentVO>();
			
			var titleContent:ContentVO = new ContentVO();
			titleContent.type = DuplicateNPCPanel.CONTENT;
			titleContent.text = npcObj.description;
			talkContent.contents.push(titleContent);
			for each (var linkObj:Object in npcObj.links) {
				if (linkObj.show_type == 3) { //退出连接
					var quitLink:ContentVO = new ContentVO();
					quitLink.type = DuplicateNPCPanel.LINK;
					quitLink.text = linkObj.level_name;
					quitLink.linkType = DuplicateNPCPanel.OTHER;
					quitLink.data = "quitLink," + String(linkObj.npc_id) + "," + String(linkObj.fb_type) + "," + String(linkObj.fb_level);
					talkContent.contents.push(quitLink);
				}
			}
			talkVO.talks.push(talkContent);
			npcPanel.talkVO = talkVO;
		}
		
		
		/**
		 * 显示对话事件描述
		 * @param event
		 *
		 */
		private function onShowContent(event:ParamEvent):void {
			var param:Array = String(event.data).split(",");
			if (param[0] == "showLink") {
				var linkObj:Object = this.findSwFbNpcLinkObj(param[1],param[2],param[3]);
				var talk:TalkContentVO = new TalkContentVO();
				talk.contents = new Vector.<ContentVO>();
				talk.type = DuplicateNPCPanel.GO_BACK;
				talk.data = 0;
				var content:ContentVO = new ContentVO();
				content.type = DuplicateNPCPanel.CONTENT;
				content.text = linkObj.description;
				talk.contents.push(content);
				npcPanel.wrapperTalk(talk);
			}
		}
		
		/**
		 * 处理进入副本连接
		 * @param event
		 *
		 */
		private function onOhter(event:ParamEvent):void {
			var param:Array = String(event.data).split(",");
			if (param[0] == "enterLink") {
				if(this.npcPanel != null && WindowManager.getInstance().isPopUp(this.npcPanel)){
					WindowManager.getInstance().removeWindow(this.npcPanel);
				}
				var npcObj:Object = findSwFbNpcByNpcObj(this.curNpcId);
				if(npcObj != null && npcObj.viewType==1){
					var enterVo:m_scene_war_fb_enter_tos = new m_scene_war_fb_enter_tos;
					enterVo.npc_id = param[1];
					enterVo.fb_type = param[2];
					enterVo.fb_level = param[3];
					enterVo.fb_id = param[4];
					enterVo.fb_seconds = param[5];
					this.sendSocketMessage(enterVo);
				}
			}else if(param[0] == "quitLink"){
				if(this.npcPanel != null && WindowManager.getInstance().isPopUp(this.npcPanel)){
					WindowManager.getInstance().removeWindow(this.npcPanel);
				}
				var quitVo:m_scene_war_fb_quit_tos = new m_scene_war_fb_quit_tos;
				quitVo.npc_id = param[1];
				this.sendSocketMessage(quitVo);
			}
		}
		
		/**
		 * 完成按钮事件处理
		 * @param event
		 *
		 */
		private function onFinish(event:ParamEvent):void {
			//如果有打开子界面，可以同步处理关闭
		}
		
		/**
		 * 玩家切换地图时，场景大战副本模块相关处理
		 */
		
		private function onChangeMapRoleReady():void {
			//获取npcid列表
//			if (sceneWarFbXml == null || sceneWarFbXml == [] || sceneWarFbXml.length == 0) {
//				initSceneWarFbXml();
//			}
//			npcIdList = String(sceneWarFbTeamNpcIds).split(",");
//			
//			//弹框
//			if(SceneDataManager.mapData.map_id==10904){
//				if(callMonsterTip == null){
//					callMonsterTip = new CallMonsterTip();
//				}
//				if(!LayerManager.uiLayer.contains(this.callMonsterTip)){
//					LayerManager.uiLayer.addChild(this.callMonsterTip);
//					this.callMonsterTip.npcId =npcIdList[curPassID-1];
//					this.callMonsterTip.x = int(GlobalObjectManager.GAME_WIDTH >> 1) - int(this.callMonsterTip.width >> 1);
//					this.callMonsterTip.y = int(GlobalObjectManager.GAME_HEIGHT >> 1) - int(this.callMonsterTip.height >> 1);
//				}
//			}
		}
		
		private var npcIdList:Array;
		private var callMonsterTip:CallMonsterTip;
		/**
		 * 通知打完怪物
		 *
		 */
		private function doSceneWarFbCallMonsterToc(vo:m_scene_war_fb_call_monster_toc):void{
			if (vo.succ && vo.op_type == SCENEWARFB_PASS_MONSTER_CLEAR){
				this.curPassID=vo.pass_id;
				if(curPassID!=SCENEWARFB_FINISH_PASS_ID){
					//获取npcid列表
					if (sceneWarFbXml == null || sceneWarFbXml == [] || sceneWarFbXml.length == 0) {
						initSceneWarFbXml();
					}
					npcIdList = String(sceneWarFbTeamNpcIds).split(",");
					
					//弹框
					if(SceneDataManager.mapData.map_id==10904){
						if(callMonsterTip == null){
							callMonsterTip = new CallMonsterTip();
						}
						if(!LayerManager.uiLayer.contains(this.callMonsterTip)){
							LayerManager.uiLayer.addChild(this.callMonsterTip);
							this.callMonsterTip.npcId =npcIdList[curPassID-1];
							this.callMonsterTip.x = int(GlobalObjectManager.GAME_WIDTH >> 1) - int(this.callMonsterTip.width >> 1);
							this.callMonsterTip.y = int(GlobalObjectManager.GAME_HEIGHT >> 1) - int(this.callMonsterTip.height >> 1);
						}
					}}
			}else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}
		
		
		private function doSceneWarFbCallMonster(vo:NpcLinkVO=null):void{
			//判断当前npc是否可用
			if(curPassID==SCENEWARFB_FINISH_PASS_ID){
				Tips.getInstance().addTipsMsg("当前没有怪物可以挑战");
			}else{
				if(npcIdList.length>0){
					if(npcIdList[curPassID-1]!=vo.npcID.toString()){
						Tips.getInstance().addTipsMsg("召唤怪物条件未达到");
					}else{
						var callMonsterVo:m_scene_war_fb_call_monster_tos = new m_scene_war_fb_call_monster_tos;
						callMonsterVo.npc_id = vo.npcID;
						callMonsterVo.pass_id =curPassID;
						this.sendSocketMessage(callMonsterVo);
					}
				}
			}
			
		}
		
		private var notEnoughFeeAlert:String = null;
		private var canEnterAlert:String = null;
		/**
		 * 进入场景大战副本请求回复处理
		 * @param vo
		 *
		 */
		private function doSceneWarFbEnterToc(vo:m_scene_war_fb_enter_toc):void {
			if(vo.return_self){
				if(vo.succ){
					var linkObj:Object = this.findSwFbNpcLinkObj(vo.npc_id,vo.fb_type,vo.fb_level);
					if(vo.fb_fee > 0){
						BroadcastSelf.logger("<font color='#3BE450'>你今天第" + vo.fb_times.toString() + "次挑战" +　linkObj.name + 
							"副本，扣除费用：" + vo.fb_fee.toString() + "元宝</font>"　);
					}
				}else{
					if(vo.reason_code == 2){//元宝不足处理
						if(!Alert.isPopUp(notEnoughFeeAlert)){
							var str:String = "你的元宝不足，<a href='event:pay'><font color=\"#3be450\"><u>点击充值</u></font></a>, 请点击链接充值！";
							notEnoughFeeAlert = Alert.show(str,"提示",null,null,"关闭","",null,false,true,null,onClickPay);
						}
					}else{
						Tips.getInstance().addTipsMsg(vo.reason);
					}
				}
			}else{
				//自动弹窗提示是否跟着进入相应的副本
				if(vo.succ){
					if(this.npcPanel != null && WindowManager.getInstance().isPopUp(this.npcPanel)){
						WindowManager.getInstance().removeWindow(this.npcPanel);
						var enterVo:m_scene_war_fb_query_tos = new m_scene_war_fb_query_tos;
						enterVo.npc_id = vo.npc_id;
						enterVo.op_type = SCENEWARFB_QUERY_TYPE_OPEN;
						this.sendSocketMessage(enterVo);
					}
					//判断玩家当前的状态是不是正常的状态,玩家当前的地图是不是副本地图，门派地图除外
					if((GlobalObjectManager.getInstance().user.base.status == RoleActState.NORMAL
						|| GlobalObjectManager.getInstance().user.base.status == RoleActState.ZAZEN)
						&& (SceneDataManager.mapData.map_id == 10300 || !SceneDataManager.isSubMap())){
						Alert.removeAlert(canEnterAlert);
						var linkFbObj:Object = this.findSwFbNpcLinkObj(vo.npc_id,vo.fb_type,vo.fb_level);
						var enterStr:String = "队长进入了 <font color=\"#3be450\">" + linkFbObj.name + "-" + linkFbObj.level_name + "</font> 副本，立即前往吗？\n";
						if(vo.fb_max_times > 0){
							BroadcastSelf.logger("队长进入了 <font color=\"#3be450\">" + linkFbObj.name + "-" + linkFbObj.level_name + "</font> 副本，你今天已经全部完成！");
						}else{
							if(vo.fb_fee > 0){
								enterStr = enterStr + "<font color=\"#FFFF00\">今天第" +　vo.fb_times.toString() + "次（ " + vo.fb_fee.toString() + " 元宝）</font>";
							}else{
								enterStr = enterStr + "<font color=\"#FFFF00\">今天第" +　vo.fb_times.toString() + "次</font>";
							}
							canEnterAlert = Alert.show(enterStr,"进入副本提示",onClickEnter,null,"前往","取消",[vo]);
						}
					}
				}
			}
		}
		/**
		 * 进入副本
		 */        
		private function onClickEnter(vo:m_scene_war_fb_enter_toc):void{
			if((GlobalObjectManager.getInstance().user.base.status == RoleActState.NORMAL
				|| GlobalObjectManager.getInstance().user.base.status == RoleActState.ZAZEN)
				&& (SceneDataManager.mapData.map_id == 10300 || !SceneDataManager.isSubMap())){
				var tosVo:m_scene_war_fb_enter_tos = new m_scene_war_fb_enter_tos;
				tosVo.npc_id = vo.npc_id;
				tosVo.fb_id = vo.fb_id;
				tosVo.fb_seconds = vo.fb_seconds;
				tosVo.fb_type = vo.fb_type;
				tosVo.fb_level = vo.fb_level;
				this.sendSocketMessage(tosVo);
			}else{
				BroadcastSelf.logger("当前的状态，不能直接传送进入副本！");
			}
			
		}
		/**
		 * 点击充值 
		 * @param evt
		 * 
		 */	
		private function onClickPay(evt:TextEvent):void{
			if(Alert.isPopUp(notEnoughFeeAlert)){
				Alert.removeAlert(notEnoughFeeAlert);
			}
			if(evt.text == "pay"){
				SmallMapModule.getInstance().openPayHandler();
			}
		}
		
		/**
		 * 退出场景大战副本请求回复处理
		 * @param vo
		 *
		 */
		private function doSceneWarFbQuitToc(vo:m_scene_war_fb_quit_toc):void {
			if(vo.succ){
				var linkObj:Object = this.findSwFbNpcLinkObj(vo.npc_id,vo.fb_type,vo.fb_level);
				if(linkObj != null){
					BroadcastSelf.logger("<font color='#3BE450'>你退出" +　linkObj.name + "副本</font>");
				}else{
					BroadcastSelf.logger("<font color='#3BE450'>你退出副本</font>");
				}
			}else{
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}
		
		/**
		 * 查询玩家场景大战副本消息
		 * @param vo
		 *
		 */
		private function doSceneWarFbQueryToc(vo:m_scene_war_fb_query_toc):void {
			if (vo.succ && vo.op_type == SCENEWARFB_QUERY_TYPE_OPEN) {
				this.openEnterNpcPanel(vo);
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}
		

		
		/**
		 * 判断当前地图是不是场景大战副本地图
		 */
		public function isSceneWarFbMapId(mapId:int):Boolean{
			if (sceneWarFbXml == null || sceneWarFbXml == [] || sceneWarFbXml.length == 0) {
				initSceneWarFbXml();
			}
			if(this.sceneWarFbMapIds == ""){
				return false;
			}
			var curMapId:String = mapId.toString();
			if(this.sceneWarFbMapIds.indexOf(curMapId) != -1){
				return true;
			}
			return false;
		}
		/**
		 * 场景大战链接描述配置XML
		 * 结构为：
		 * npcId
		 * npcType NPC类型
		 * npcName
		 * viewType NPC点击界面显示类型 1:NPC界面显示 2:推荐组队界面显示
		 * description NPC 开场白
		 * link.npc_id
		 * link.fb_type
		 * link.fb_level
		 * link.name
		 * link.level_name
		 * link.enter_fee
		 * link.fb_times
		 * link.seq
		 * link.show_type
		 * link.description
		 */
		private var sceneWarFbXml:Array = [];
		private var sceneWarFbMapIds:String = "";
		private var sceneWarFbTeamNpcIds:String = "";
		private function initSceneWarFbXml():void {
			var xml:XML = CommonLocator.getXML(CommonLocator.SCENE_WAR_FB);
			var npcObj:Object = null;
			for each (var npc:XML in xml.npc) {
				npcObj = {};
				npcObj.npcId = npc.@id;
				npcObj.npcName = npc.@npc_name;
				npcObj.npcType = npc.@npc_type;
				npcObj.viewType = npc.@view_type;
				if (npc.child("description").length() == 0) {
					npcObj.description = "";
				} else {
					npcObj.description = npc.description.text();
				}
				var linkArr:Array = [];
				for each (var link:XML in npc.link) {
					var linkObj:Object = {};
					linkObj.npc_id = npc.@id;
					linkObj.fb_type = link.@fb_type;
					linkObj.fb_level = link.@fb_level;
					linkObj.seq = link.@seq;
					linkObj.show_type = link.@show_type;
					linkObj.name = link.@name;
					linkObj.level_name = link.@level_name;
					linkObj.enter_fee = 0;
					linkObj.fb_times = 0;
					if (link.children().length() == 0) {
						linkObj.description = "";
					} else {
						linkObj.description = link.description.text();
					}
					linkArr.push(linkObj);
				}
				linkArr.sortOn("seq",Array.NUMERIC);
				npcObj.links = linkArr;
				sceneWarFbXml.push(npcObj);
			}
			if(xml.child("sw_fb_map_id").length() > 0){
				sceneWarFbMapIds = xml.sw_fb_map_id.@map_ids;
			}
			if(xml.child("sw_fb_team_npc_id").length()>0){
				sceneWarFbTeamNpcIds = xml.sw_fb_team_npc_id.@npc_ids;
			}
		}
		
		/**
		 * 获取 p_scene_war_fb_link
		 * @param fbType
		 * @param fbLevel
		 * @param pLinkArr
		 * @return
		 *
		 */
		private function findSceneWarFbLink(fbType:int,fbLevel:int,pLinkArr:Array):p_scene_war_fb_link {
			if (pLinkArr != null && pLinkArr.length > 0) {
				for each (var link:p_scene_war_fb_link in pLinkArr) {
					if (link.fb_type == fbType && link.fb_level == fbLevel) {
						return link;
					}
				}
			}
			return null;
		}
		
		/**
		 * 检查此NPC是否是场景大战副本的NPC
		 * @param npcId
		 * @return 返回 true or false
		 */
		public function isSceneWarFbNpc(npcId:int):Boolean {
			if (this.findSwFbNpcByNpcObj(npcId) != null) {
				return true;
			}
			return false;
		}
		
		/**
		 * 根据场景大战NPC ID 查找要在此NPC显示的连接
		 * @param npcId
		 * @return
		 *
		 */
		private function findSwFbNpcByNpcObj(npcId:int):Object {
			if (sceneWarFbXml == null || sceneWarFbXml == [] || sceneWarFbXml.length == 0) {
				initSceneWarFbXml();
			}
			for each (var npcObj:Object in sceneWarFbXml) {
				if (npcObj.npcId == npcId) {
					return npcObj;
				}
			}
			return null;
		}
		
		/**
		 * 获取NPC配置数据
		 * @param npcId
		 * @param fbType
		 * @param fbLevel
		 * @return
		 *
		 */
		private function findSwFbNpcLinkObj(npcId:int,fbType:int,fbLevel:int):Object {
			if (sceneWarFbXml == null || sceneWarFbXml == [] || sceneWarFbXml.length == 0) {
				initSceneWarFbXml();
			}
			for each (var npcObj:Object in sceneWarFbXml) {
				if (npcObj.npcId == npcId) {
					for each (var linkObj:Object in npcObj.links) {
						if (linkObj.fb_type == fbType && linkObj.fb_level == fbLevel) {
							return linkObj;
						}
					}
				}
			}
			return null;
		}
		
	}
}
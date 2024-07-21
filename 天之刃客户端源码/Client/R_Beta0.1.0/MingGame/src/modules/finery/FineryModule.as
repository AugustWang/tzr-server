package modules.finery {
	import com.Message;
	import com.events.ParamEvent;
	import com.events.WindowEvent;
	import com.globals.GameConfig;
	import com.loaders.ViewLoader;
	import com.managers.WindowManager;
	import com.net.SocketCommand;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneUnit.baseUnit.things.thing.Thing;
	
	import flash.utils.getTimer;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.Tips;
	import modules.finery.views.StovePanel;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	import modules.mypackage.vo.GeneralVO;
	import modules.mypackage.vo.StoneVO;
	
	import proto.common.p_refining;
	import proto.line.m_refining_box_toc;
	import proto.line.m_refining_box_tos;
	import proto.line.m_refining_firing_toc;
	import proto.line.m_refining_firing_tos;

	public class FineryModule extends BaseModule {



		public var stovePanel:StovePanel;

		public function FineryModule() {
			super();
		}

		private static var _instance:FineryModule;

		public static function getInstance():FineryModule {
			if (!_instance) {
				_instance=new FineryModule();
			}
			return _instance;
		}

		override protected function initListeners():void {
			addMessageListener(ModuleCommand.ENTER_GAME, onEnterGame);
			addMessageListener(ModuleCommand.OPEN_STOVE_WINDOW, openStoveWindow);
			addMessageListener(ModuleCommand.OPEN_EQUIP_PUNCH, openEquipPunch);
			addMessageListener(ModuleCommand.OPEN_EQUIP_EXALT, openEquipExalt);
			addMessageListener(ModuleCommand.OPEN_EQUIP_BIND, openEquipBind);
			addMessageListener(ModuleCommand.OPEN_EQUIP_UPGRADE, openEquipUpgrade);
			addMessageListener(ModuleCommand.OPEN_EQUIP_BOX, openEquipBox);
			addMessageListener(ModuleCommand.OPEN_EQUIP_COMPOSE, openEquipCompose);
			addMessageListener(ModuleCommand.OPEN_EQUIP_REFINE, openEquipRefine);
			addSocketListener(SocketCommand.REFINING_FIRING, refiningFiring);
			addSocketListener(SocketCommand.REFINING_BOX, refiningBox);

			addMessageListener(ModuleCommand.PACKAGE_UPDATE_GOODS, packageUpdateGoods);
		}

		private function openEquipPunch():void {
			openStoveWindow(5,true);
		}

		private function openEquipExalt():void {
			openStoveWindow(2,true);
		}

		private function openEquipBind():void {
			openStoveWindow(1,true);
		}

		private function openEquipUpgrade():void {
			openStoveWindow(7,true);
		}

		private function openEquipBox():void {
			openStoveWindow(0,true);
		}

		private function openEquipCompose():void {
			openStoveWindow(7,true);
		}

		private function openEquipRefine():void {
			openStoveWindow(9,true);
		}

		private function onEnterGame():void {
			//查询天工开物状态
			checkBoxState();
		}

		private function refiningFiring(vo:m_refining_firing_toc):void {
			LoopManager.setTimeout(delayRefiningFiring, 1500, [vo]);
		}

		private function delayRefiningFiring(vo:m_refining_firing_toc):void {
			switch (vo.op_type) {
				case StoveConstant.OP_TYPE_PUNCH:
					stovePanel.punchView.callBack(vo);
					break;
				case StoveConstant.OP_TYPE_INSERT:
					stovePanel.insertView.callBack(vo);
					break;
				case StoveConstant.OP_TYPE_DISASSEMBLY:
					stovePanel.disassemblyView.callBack(vo);
					break;
				case StoveConstant.OP_TYPE_BIND:
					stovePanel.bindView.callBack(vo);
					break;
				case StoveConstant.OP_TYPE_BIND_UP:
					stovePanel.exaltView.callBack(vo);
					break;
				case StoveConstant.OP_TYPE_STRENGTH:
					stovePanel.strengthView.callBack(vo);
					break;
				case StoveConstant.OP_TYPE_COMPOSE:
					stovePanel.composeView.callBack(vo);
					break;
				case StoveConstant.OP_TYPE_REFINE:
					stovePanel.refineView.callBack(vo);
					break;
				case StoveConstant.OP_TYPE_UPGRADE:
					stovePanel.upgradeView.callBack(vo);
					break;
				case StoveConstant.OP_TYPE_RECAST:
					stovePanel.recastView.callBack(vo);
					break;
			}
			setEnable(true);
		}

		private function onBtnClick(event:ParamEvent):void {
			event.stopPropagation();
			switch (event.type) {
				case StoveConstant.PUNCH_BTN_CLICK:
					punch(event.data);
					break;
				case StoveConstant.INSERT_BTN_CLICK:
					insert(event.data);
					break;
				case StoveConstant.DISASSEMBLY_BTN_CLICK:
					disassembly(event.data);
					break;
				case StoveConstant.BIND_BTN_CLICK:
					bind(event.data);
					break;
				case StoveConstant.STRENGTH_BTN_CLICK:
					strength(event.data);
					break;
				case StoveConstant.COMPOSE_BTN_CLICK:
					compose(event.data);
					break;
				case StoveConstant.REFINE_BTN_CLICK:
					refine(event.data);
					break;
				case StoveConstant.EXALT_BTN_CLICK:
					exalt(event.data);
					break;
				case StoveConstant.EXALT_NEXT:
					exaltGetNext(event.data);
					break;
				case StoveConstant.UPGRADE_NEXT:
					upgradeNext(event.data);
					break;
				case StoveConstant.UPGRADE_BTN_CLICK:
					upgrade(event.data);
					break;
				case StoveConstant.BOX_GET_INFO:
					getBoxInfo();
					break;
				case StoveConstant.BOX_RELOAD:
					reloadBoxInfo();
					break;
				case StoveConstant.BOX_RESTORE:
					restore();
					break;
				case StoveConstant.BOX_GET_TO_PACK:
					getBoxToPack();
					break;
				case StoveConstant.BOX_QUERY:
					query(event.data);
					break;
				case StoveConstant.BOX_ITEM_DOULE_CLICK:
					getGoods(event.data);
					break;
				case StoveConstant.BOX_MERGE_CLICK:
					merge();
					break;
				case StoveConstant.BOX_RESTORE_TO_PACK:
					restoreToPack();
					break;
				case StoveConstant.BOX_ALL_GET_CLICK:
					getGoods(event.data);
					break;
				case StoveConstant.RECAST_BTN_CLICK:
					recast(event.data);
					break;
			}
		}

		/**
		 * 封装目标
		 */
		private function setTarget(itemVO:BaseItemVO, firing_list:Array):void {
			var equipVo:p_refining=new p_refining();
			equipVo.firing_type=StoveConstant.FIRING_TYPE_TARGET;
			equipVo.goods_id=itemVO.oid;
			equipVo.goods_type=StoveConstant.GOODS_TYPE_EQUIP;
			equipVo.goods_type_id=itemVO.typeId;
			equipVo.goods_number=1;
			firing_list.push(equipVo);
		}

		/**
		 * 封装宝石材料
		 */
		private function setStoneMaterial(itemVO:BaseItemVO, firing_list:Array):void {
			var stoneVo:p_refining=new p_refining();
			stoneVo.firing_type=StoveConstant.FIRING_TYPE_MATERIAL;
			stoneVo.goods_id=itemVO.oid;
			stoneVo.goods_type=StoveConstant.GOODS_TYPE_STONE;
			stoneVo.goods_type_id=itemVO.typeId;
			stoneVo.goods_number=1;
			firing_list.push(stoneVo);
		}

		/**
		 * 封装材料
		 */
		private function setMaterial(itemVO:BaseItemVO, firing_list:Array=null, num:int=1):p_refining {
			var materialVo:p_refining=new p_refining();
			materialVo.firing_type=StoveConstant.FIRING_TYPE_MATERIAL;
			materialVo.goods_id=itemVO.oid;
			if (itemVO is StoneVO) {
				materialVo.goods_type=StoveConstant.GOODS_TYPE_STONE;
			} else if (itemVO is GeneralVO) {
				materialVo.goods_type=StoveConstant.GOODS_TYPE_MATERIAL;
			} else if (itemVO is EquipVO) {
				materialVo.goods_type=StoveConstant.GOODS_TYPE_EQUIP;
			}
			materialVo.goods_type_id=itemVO.typeId;
			materialVo.goods_number=num;
			if (firing_list)
				firing_list.push(materialVo);
			return materialVo
		}

		/**
		 * 批量封装材料
		 */
		private function setMaterials(items:Array, firing_list:Array=null):void {
			var vos:Array=[];
			var p:p_refining;
			var has:Boolean=false;
			for (var i:int=0; i < items.length; i++) {
				p=setMaterial(items[i]);
				has=false;
				for (var j:int=0; j < vos.length; j++) {
					if (p.goods_id == vos[j].goods_id) {
						has=true;
						vos[j].goods_number++;
					}
				}
				if (!has) {
					vos.push(p);
				}
			}
			if (firing_list) {
				for (i=0; i < vos.length; i++) {
					firing_list.push(vos[i]);
				}
			}
		}

		/**
		 * 打孔
		 */
		private function punch(data:Object):void {
			var vo:m_refining_firing_tos=new m_refining_firing_tos();
			vo.op_type=StoveConstant.OP_TYPE_PUNCH;
			setTarget(data.equip, vo.firing_list);
			setMaterial(data.material, vo.firing_list);
			sendSocketMessage(vo);
			stovePanel.punchView.startEffect();
		}

		/**
		 * 重铸
		 */
		private function recast(data:Object):void {
			var vo:m_refining_firing_tos=new m_refining_firing_tos();
			vo.op_type=StoveConstant.OP_TYPE_RECAST;
			setTarget(data.equip, vo.firing_list);
			setMaterial(data.material, vo.firing_list);
			sendSocketMessage(vo);
			stovePanel.recastView.startEffect();
		}
		
		/**
		 * 镶嵌
		 */
		private function insert(data:Object):void {
			var vo:m_refining_firing_tos=new m_refining_firing_tos();
			vo.op_type=StoveConstant.OP_TYPE_INSERT;
			setTarget(data.equip, vo.firing_list);
			setStoneMaterial(data.stone, vo.firing_list);
			setMaterial(data.material, vo.firing_list);
			sendSocketMessage(vo);
			stovePanel.insertView.startEffect();
		}

		/**
		 * 拆卸
		 */
		private function disassembly(data:Object):void {
			var vo:m_refining_firing_tos=new m_refining_firing_tos();
			vo.op_type=StoveConstant.OP_TYPE_DISASSEMBLY;
			setTarget(data.equip, vo.firing_list);
			setMaterials(data.materials, vo.firing_list);
			sendSocketMessage(vo);
			stovePanel.disassemblyView.startEffect();
		}

		/**
		 * 绑定
		 */
		private function bind(data:Object):void {
			var vo:m_refining_firing_tos=new m_refining_firing_tos();
			if (data.type == 3) {
				vo.op_type=StoveConstant.OP_TYPE_BIND_UP;
				vo.sub_op_type=StoveConstant.SUB_BIND_UP;
				setTarget(data.equip, vo.firing_list);
				var materials:Array=data.materials;
				var item:Object;
				for (var i:int=0; i < materials.length; i++) {
					item=materials[i];
					var p:p_refining=setMaterial(item.data, vo.firing_list);
					p.goods_number=item.num;
				}
			} else if (data.type == 2) {
				vo.op_type=StoveConstant.OP_TYPE_BIND;
				vo.sub_op_type=StoveConstant.SUB_BIND_REBIND;
				setTarget(data.equip, vo.firing_list);
				setMaterial(data.material, vo.firing_list);
			} else if (data.type == 1) {
				vo.op_type=StoveConstant.OP_TYPE_BIND;
				vo.sub_op_type=StoveConstant.SUB_BIND_BIND;
				setTarget(data.equip, vo.firing_list);
				setMaterial(data.material, vo.firing_list);
			}
			sendSocketMessage(vo);
			if(data.type == 3){
				stovePanel.exaltView.startEffect();
			}else{
				stovePanel.bindView.startEffect();
			}
		}

		/**
		 * 强化
		 */
		private function strength(data:Object):void {
			var vo:m_refining_firing_tos=new m_refining_firing_tos();
			vo.op_type=StoveConstant.OP_TYPE_STRENGTH;
			setTarget(data.equip, vo.firing_list);
			var materials:Array=data.materials;
			var item:Object;
			for (var i:int=0; i < materials.length; i++) {
				item=materials[i];
				var p:p_refining=setMaterial(item.data, vo.firing_list);
				p.goods_number=item.num;
			}
			sendSocketMessage(vo);
			stovePanel.strengthView.startEffect();
		}

		/**
		 * 合成
		 */
		private function compose(data:Object):void {
			var vo:m_refining_firing_tos=new m_refining_firing_tos();
			vo.op_type=StoveConstant.OP_TYPE_COMPOSE;
			vo.sub_op_type=data.type;
			var materials:Array=data.materials;
			var item:Object;
			for (var i:int=0; i < materials.length; i++) {
				item=materials[i];
				var p:p_refining=setMaterial(item.data, vo.firing_list);
				p.goods_number=item.num;
			}
			sendSocketMessage(vo);
			stovePanel.composeView.startEffect();
		}

		/**
		 * 精炼
		 */
		private function refine(data:Object):void {
			var vo:m_refining_firing_tos=new m_refining_firing_tos();
			vo.op_type=StoveConstant.OP_TYPE_REFINE;
			var materials:Array=data.materials;
			var item:BaseItemVO;
			for (var i:int=0; i < materials.length; i++) {
				item=materials[i];
				setMaterial(item, vo.firing_list, item.num);
			}
			sendSocketMessage(vo);
			stovePanel.refineView.startEffect();
		}

		/**
		 * 精炼
		 */
		private function exalt(data:Object):void {
			var vo:m_refining_firing_tos=new m_refining_firing_tos();
			vo.op_type=StoveConstant.OP_TYPE_EXALT;
			vo.sub_op_type=StoveConstant.SUB_EXALT_UP;
			setTarget(data.equip, vo.firing_list);
			setMaterials(data.materials, vo.firing_list);
			sendSocketMessage(vo);
			stovePanel.exaltView.startEffect();
		}

		/**
		 * 查询下一个颜色
		 */
		private function exaltGetNext(data:Object):void {
			var vo:m_refining_firing_tos=new m_refining_firing_tos();
			vo.op_type=StoveConstant.OP_TYPE_EXALT;
			vo.sub_op_type=StoveConstant.SUB_EXALT_NEXT;
			setTarget(data.equip, vo.firing_list);
			sendSocketMessage(vo);
			setEnable(true);
		}

		private function upgradeNext(data:Object):void {
			var vo:m_refining_firing_tos=new m_refining_firing_tos();
			vo.op_type=StoveConstant.OP_TYPE_UPGRADE;
			vo.sub_op_type=StoveConstant.SUB_UPGRADE_NEXT;
			setTarget(data.equip, vo.firing_list);
			setMaterial(data.material, vo.firing_list);
			sendSocketMessage(vo);
			setEnable(true);
		}

		private function upgrade(data:Object):void {
			var vo:m_refining_firing_tos=new m_refining_firing_tos();
			vo.op_type=StoveConstant.OP_TYPE_UPGRADE;
			vo.sub_op_type=StoveConstant.SUB_UPGRADE;
			setTarget(data.equip, vo.firing_list);
			setMaterial(data.material, vo.firing_list);
			sendSocketMessage(vo);
		}

		/**
		 * 查询天工开物开关
		 */
		private function checkBoxState():void {
			var vo:m_refining_box_tos=new m_refining_box_tos();
			vo.op_type=StoveConstant.BOX_OP_TYPE_ISOPEN;
			sendSocketMessage(vo);
		}

		public function getBoxInfo():void {
			var vo:m_refining_box_tos=new m_refining_box_tos();
			vo.op_type=StoveConstant.BOX_OP_TYPE_INFO;
			sendSocketMessage(vo);
		}

		private function reloadBoxInfo():void {
			var vo:m_refining_box_tos=new m_refining_box_tos();
			vo.op_type=StoveConstant.BOX_OP_TYPE_RELOAD;
			vo.op_fee_type=1;
			sendSocketMessage(vo);
		}

		private function getBoxToPack():void {
			var vo:m_refining_box_tos=new m_refining_box_tos();
			vo.op_type=StoveConstant.BOX_OP_TYPE_GET_TO_PACK;
			sendSocketMessage(vo);
		}

		private function restore():void {
			var vo:m_refining_box_tos=new m_refining_box_tos();
			vo.op_type=StoveConstant.BOX_OP_TYPE_RESTORE;
			sendSocketMessage(vo);
		}

		private function query(data:Object):void {
			var vo:m_refining_box_tos=new m_refining_box_tos();
			vo.op_type=StoveConstant.BOX_OP_TYPE_QUERY;
			vo.page_no=data.index;
			vo.page_type=data.type;
			sendSocketMessage(vo);
		}

		private function getGoods(data:Object):void {
			var vo:m_refining_box_tos=new m_refining_box_tos();
			vo.op_type=StoveConstant.BOX_OP_TYPE_GET;
			vo.goods_ids=data.ids;
			sendSocketMessage(vo);
		}

		private function merge():void {
			var vo:m_refining_box_tos=new m_refining_box_tos();
			vo.op_type=StoveConstant.BOX_OP_TYPE_MERGE;
			sendSocketMessage(vo);
		}

		private function restoreToPack():void {
			var vo:m_refining_box_tos=new m_refining_box_tos();
			vo.op_type=StoveConstant.BOX_OP_TYPE_RESTORE_TO_PACK;
			vo.op_fee_type=1;
			sendSocketMessage(vo);
		}

		private function refiningBox(vo:m_refining_box_toc):void {
			LoopManager.setTimeout(delayRefiningBox, 1, [vo]);
		}

		private function delayRefiningBox(vo:m_refining_box_toc):void {
			switch (vo.op_type) {
				case StoveConstant.BOX_OP_TYPE_ISOPEN:
					StoveConstant.boxIsOpen=vo.is_open;
					StoveConstant.boxIsFree=vo.is_free;
					if (stovePanel) {
						stovePanel.checkBoxState();
					}
					break;
				default:
					if (stovePanel.boxView) {
						stovePanel.boxView.callback(vo);
					}
					break;
			}
			setEnable(true);
		}

		public function boxTest(value:Boolean):void {
			StoveConstant.boxIsOpen=value;
			StoveConstant.boxIsFree=!value;
			stovePanel.checkBoxState();
		}

		private function openStoveWindow(tabIndex:int=-1,mustPopUp:Boolean=false):void {
			if (!_enable)
				return;
			if(!ViewLoader.hasLoaded(GameConfig.STOVE_UI)){
				ViewLoader.load(GameConfig.STOVE_UI,openStoveWindow,[tabIndex]);
				return;
			}
			if (!stovePanel) {
				stovePanel=new StovePanel();
				stovePanel.addEventListener(StoveConstant.RECAST_BTN_CLICK,onBtnClick);
				stovePanel.addEventListener(StoveConstant.PUNCH_BTN_CLICK, onBtnClick);
				stovePanel.addEventListener(StoveConstant.INSERT_BTN_CLICK, onBtnClick);
				stovePanel.addEventListener(StoveConstant.DISASSEMBLY_BTN_CLICK, onBtnClick);
				stovePanel.addEventListener(StoveConstant.BIND_BTN_CLICK, onBtnClick);
				stovePanel.addEventListener(StoveConstant.STRENGTH_BTN_CLICK, onBtnClick);
				stovePanel.addEventListener(StoveConstant.COMPOSE_BTN_CLICK, onBtnClick);
				stovePanel.addEventListener(StoveConstant.REFINE_BTN_CLICK, onBtnClick);
				stovePanel.addEventListener(StoveConstant.EXALT_BTN_CLICK, onBtnClick);
				stovePanel.addEventListener(StoveConstant.EXALT_NEXT, onBtnClick);
				stovePanel.addEventListener(StoveConstant.UPGRADE_NEXT, onBtnClick);
				stovePanel.addEventListener(StoveConstant.UPGRADE_BTN_CLICK, onBtnClick);
				stovePanel.addEventListener(StoveConstant.BOX_GET_INFO, onBtnClick);
				stovePanel.addEventListener(StoveConstant.BOX_RELOAD, onBtnClick);
				stovePanel.addEventListener(StoveConstant.BOX_RESTORE, onBtnClick);
				stovePanel.addEventListener(StoveConstant.BOX_GET_TO_PACK, onBtnClick);
				stovePanel.addEventListener(StoveConstant.BOX_QUERY, onBtnClick);
				stovePanel.addEventListener(StoveConstant.BOX_ITEM_DOULE_CLICK, onBtnClick);
				stovePanel.addEventListener(StoveConstant.BOX_MERGE_CLICK, onBtnClick);
				stovePanel.addEventListener(StoveConstant.BOX_RESTORE_TO_PACK, onBtnClick);
				stovePanel.addEventListener(StoveConstant.BOX_ALL_GET_CLICK, onBtnClick);
				loadEffect();
				WindowManager.getInstance().centerWindow(stovePanel);
			}
			var removeModel:String = mustPopUp ? WindowManager.UNREMOVE : WindowManager.REMOVE;
			WindowManager.getInstance().popUpWindow(stovePanel,removeModel);
			if(tabIndex != -1){
				stovePanel.selectIndex = tabIndex;
			}
			if (!stovePanel.hasEventListener(WindowEvent.OPEN)) {
				stovePanel.addEventListener(WindowEvent.OPEN, onStovePanelOpen);
			}
		}

		private function onStovePanelOpen(event:WindowEvent):void {
			if (stovePanel) {
				stovePanel.reset();
			}
		}

		private function loadEffect():void {
			var thing:Thing=new Thing();
			thing.load(GameConfig.ROOT_URL + "com/assets/stoveEffect/boxEffect.swf");
			thing.load(GameConfig.ROOT_URL + "com/assets/stoveEffect/boxCompleteEffect.swf");
		}

		public function getCurrentIndex():String {
			if (stovePanel) {
				return StovePanel.currentIndex;
			}
			return "";
		}

		public function updateMaterial():void {
			//LoopManager.setTimeout(delayUpdateMaterial, 500);
		}

		private function delayUpdateMaterial():void {
			if (stovePanel) {
				stovePanel.updateMaterial();
			}
		}
		
		private var packageUpdateTime:Number = 0;
		private function packageUpdateGoods():void {
			var _time:Number = getTimer();
			if(_time - packageUpdateTime > 500){
				LoopManager.setTimeout(delayUpdateMaterial, 500);
				packageUpdateTime = _time;
			}
		}

		private function errorTip(str:String):void {
			Tips.getInstance().addTipsMsg(str);
		}

		override protected function sendSocketMessage(vo:Message):void {
			super.sendSocketMessage(vo);
			setEnable(false);
		}

		private var _enable:Boolean=true;
		private var _enableTime:int=0;

		private function setEnable(value:Boolean):void {
			if (stovePanel) {
				_enable=value;
				stovePanel.mouseChildren=value;
				//stovePanel.mouseEnabled=value;
				if (!value) {
					LoopManager.clearTimeout(_enableTime);
					_enableTime=LoopManager.setTimeout(function reEnable():void {
							setEnable(true)
						}, 5000);
				}
			}
		}
	}
}
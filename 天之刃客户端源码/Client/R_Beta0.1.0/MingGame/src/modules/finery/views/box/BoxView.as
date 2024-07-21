package modules.finery.views.box
{
	import com.common.FilterCommon;
	import com.common.GlobalObjectManager;
	import com.common.effect.ZoomEffect;
	import com.components.alert.Alert;
	import com.events.ParamEvent;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.managers.WindowManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.CheckBox;
	import com.ming.ui.controls.TextArea;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.layout.LayoutUtil;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneUnit.baseUnit.OnlyIDCreater;
	import com.utils.ComponentUtil;
	import com.utils.DateFormatUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.ModuleCommand;
	import modules.broadcast.views.Tips;
	import modules.finery.FineryModule;
	import modules.finery.StoveConstant;
	import modules.finery.views.item.BoxItem;
	import modules.finery.views.item.BoxItemToolTip;
	import modules.finery.views.item.BoxPackWindow;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.PackageModule;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.vo.BaseItemVO;
	import modules.system.SystemConfig;
	
	import proto.common.p_goods;
	import proto.common.p_refining_box_log;
	import proto.line.m_refining_box_toc;

	public class BoxView extends UIComponent
	{
		public static const NAME:String = "BoxView";
		public static const BOX_NUM:int = 1;
		public static const CONSUME_GOLD:int = 9;
		private var time:int=0;
		private var key:String;
		
		private var timeTF:TextField;
		private var reloadBtn:Button;
		private var TRLog:TextArea;
		private var BRLog:TextArea;
		private var boxCan:Sprite;
		private var getBtn:Button;
		private var packBtn:Button;
		public var ToPackCB:CheckBox;
		
		private var myLogs:Array;
		private var otherLogs:Array;
		
		private var tip:BoxItemToolTip
		
		public function BoxView()
		{
			key = OnlyIDCreater.createID();
		}
		
		private var hasInit:Boolean = false;
		public function initUI():void{
			if(hasInit){
				return;
			}
			this.x = 2;
			this.y = 2;
			var bg:UIComponent = ComponentUtil.createUIComponent(0,0,308,304);
			Style.setBorderSkin(bg);
			var stoveBg:Bitmap = Style.getBitmap(GameConfig.STOVE_UI,"stoveBg");
			stoveBg.x = bg.width - stoveBg.width >> 1;
			stoveBg.y = bg.height - stoveBg.height >> 1;
			addChild(bg);
			bg.addChild(stoveBg);
			bg.x=0;
			bg.y=3;
			
			var timeTFFormat:TextFormat=new TextFormat("Tahoma", 13, 0xE8E7B7, true, null, null, null, null, TextFormatAlign.
				CENTER);
			timeTF=ComponentUtil.createTextField("距离下次更新：xx:xx:xx", 8, 42, timeTFFormat, 200, 26, bg);
			timeTF.filters=Style.textBlackFilter;
			timeTF.x = (bg.width - timeTF.width)*0.5;
			
			boxCan = new Sprite();
			for(var i:int=0; i<BOX_NUM; i++){
				var item:BoxItem = new BoxItem("?");
				boxCan.addChild(item);
			}
			if(BOX_NUM > 1){
				LayoutUtil.layoutHorizontal(boxCan,20,0);
			}
			bg.addChild(boxCan);
			boxCan.y = timeTF.y + 70;
			boxCan.x = (bg.width - boxCan.width)*0.5;
			
			getBtn=ComponentUtil.createButton("提取",100,boxCan.y+boxCan.height+15,90,25,bg);
			getBtn.addEventListener(MouseEvent.CLICK,onGetBtnClick);
			
			reloadBtn=ComponentUtil.createButton("9元宝立即更新",100,boxCan.y+boxCan.height+15,90,25,bg);
			reloadBtn.addEventListener(MouseEvent.CLICK,onReloadBtnClick);
			reloadBtn.visible = !StoveConstant.boxIsFree;
			
			reloadBtn.x = (bg.width - 200)*0.5;
			getBtn.x = reloadBtn.x + 110;
			
			ToPackCB = new CheckBox();
			ToPackCB.text = "直接更新到临时仓库";
			ToPackCB.textFormat = new TextFormat("Tahoma",12,0x00FF00);
			bg.addChild(ToPackCB);
			ToPackCB.x = reloadBtn.x;
			ToPackCB.y = reloadBtn.y + 27;
			ToPackCB.selected = true;
			
			packBtn=ComponentUtil.createButton("打开临时仓库",bg.width - 115,bg.height - 40,100,25,bg);
			packBtn.addEventListener(MouseEvent.CLICK,onPackBtnClick);
			//packBtn.visible = false;
			
			//说明的背景
			var boxDescbg:UIComponent=new UIComponent();
			addChild(boxDescbg);
			Style.setBorderSkin(boxDescbg);
			boxDescbg.width=bg.width;
			boxDescbg.height=79;
			boxDescbg.x=bg.x;
			boxDescbg.y=bg.y + bg.height + 2;
			
			var boxDescFormat:TextFormat = new TextFormat("Tahoma",12);
			boxDescFormat.leading = 5;
			var boxDesc:TextField=ComponentUtil.createTextField("", 5, 5, boxDescFormat, 295, 70, boxDescbg);
			boxDesc.wordWrap=true;
			boxDesc.multiline=true;
			boxDesc.htmlText=HtmlUtil.font("天工开物说明\n", "#CCE741") + HtmlUtil.font("每隔一小时，天工炉都会聚集天地精华，造出各种神奇的宝物、还有强大的装备！",
				"#ffffff");
			boxDesc.filters=Style.textBlackFilter;
			
			var logNameFormat:TextFormat=new TextFormat("Tahoma", 12, 0xE8E7B7, true, null, null, null, null, TextFormatAlign.
				LEFT);
			var selfLogName:TextField=ComponentUtil.createTextField("个人提取记录：", bg.x+bg.width+2, bg.y + 2, logNameFormat, 200, 26, this);
			selfLogName.filters=Style.textBlackFilter;
			
			//左上背景
			var topR:UIComponent=new UIComponent();
			addChild(topR);
			//Style.setBorderSkin(topR);
			topR.width=270;
			topR.height=167;
			topR.x=bg.x+bg.width+2;
			topR.y=bg.y + 25;
			
			TRLog = new TextArea();
			TRLog.textField.filters = FilterCommon.FONT_BLACK_FILTERS;
			Style.setBorderSkin(TRLog);
			//TRLog.bgSkin=Style.getSkin("popUpBg",GameConfig.T1_VIEWUI,new Rectangle(4,4,199,153));
			topR.addChild(TRLog);
			//TRLog.htmlText = HtmlUtil.font("个人提取记录：","#000fff");
			TRLog.editable=false;
			TRLog.width=270;
			TRLog.height=166;
			TRLog.addEventListener(TextEvent.LINK,onMySelfLogClick);
			
			var otherLogName:TextField=ComponentUtil.createTextField("其他提取记录", bg.x+bg.width+2, bg.y + topR.height + 29, logNameFormat, 200, 26, this);
			otherLogName.filters=Style.textBlackFilter;
			
			var bottomR:UIComponent=new UIComponent();
			addChild(bottomR);
			//Style.setBorderSkin(bottomR);
			bottomR.width=270;
			bottomR.height=166;
			bottomR.x=bg.x+bg.width+2;
			bottomR.y=bg.y + topR.height +52;
			
			BRLog = new TextArea();
			BRLog.textField.filters = FilterCommon.FONT_BLACK_FILTERS;
			Style.setBorderSkin(BRLog);
			bottomR.addChild(BRLog);
			//BRLog.htmlText = HtmlUtil.font("其他提取记录：","#000fff");
			BRLog.editable=false;
			BRLog.width=270;
			BRLog.height=165;
			BRLog.addEventListener(TextEvent.LINK,onOtherLogClick);
			hasInit=true;
			addEventListener(Event.REMOVED_FROM_STAGE,onRemovedFromStage);
		}
		
		private function onRemovedFromStage(event:Event):void{
			if(packWindow && packWindow.parent){
				WindowManager.getInstance().removeWindow(packWindow);
			}
		}
		
		public function reset():void{
			getInfo();
		}
		
		public function update():void{
			
		}
		
		private function getInfo():void{
			FineryModule.getInstance().getBoxInfo();
//			startEffect();
		}
		
		private var _alertStr:String;
		private function onReloadBtnClick(event:Event):void{
			var gold:int = GlobalObjectManager.getInstance().user.attr.gold + GlobalObjectManager.getInstance().user.attr.gold_bind;
			if(gold < CONSUME_GOLD){
				_alertStr =  Alert.show("您的元宝不足！ <font color='#00FF00'><a href='event:openPay;'><u>快速充值</u></a></font>", "提示", null, null, "确定", "", null, false, false, null, openPay);
				return;
			}
			var e:ParamEvent;
			if(ToPackCB.selected){
				e = new ParamEvent(StoveConstant.BOX_RESTORE_TO_PACK,null,true);
			}else{
				e = new ParamEvent(StoveConstant.BOX_RELOAD,null,true);
			}
			dispatchEvent(e);
			startEffect();
		}
		
		private function openPay(e:TextEvent):void {
			Alert.removeAlert(_alertStr);
			Dispatch.dispatch(ModuleCommand.OPEN_PAY_HANDLER);
		}
		
		private function onGetBtnClick(event:MouseEvent):void{
			if(hasItem()){
				var e:ParamEvent = new ParamEvent(StoveConstant.BOX_RESTORE,null,true);
				//var e:ParamEvent = new ParamEvent(StoveConstant.BOX_GET_TO_PACK,null,true);
				dispatchEvent(e);
			}else{
				Tips.getInstance().addTipsMsg("没有物品可提取");
			}
		}
		
		private var packWindow:BoxPackWindow;
		private function onPackBtnClick(event:MouseEvent):void{
			if(!packWindow){
				packWindow=new BoxPackWindow(0,10,10);
				packWindow.addEventListener(StoveConstant.BOX_ITEM_DOULE_CLICK,onItemDouleClick);
				packWindow.addEventListener(StoveConstant.BOX_MERGE_CLICK,onMergeClick);
				packWindow.addEventListener(StoveConstant.BOX_ALL_GET_CLICK,onAllGetClick);
				packWindow.addEventListener(StoveConstant.BOX_CLASS_CLICK,onClassClick);
			}
			if(!packWindow.parent){
				WindowManager.getInstance().popUpWindow(packWindow);
			}
			var w:int = packWindow.width + FineryModule.getInstance().stovePanel.width + 5;
			FineryModule.getInstance().stovePanel.x = (GlobalObjectManager.GAME_WIDTH - w)*0.5;
			var p:Point = FineryModule.getInstance().stovePanel.localToGlobal(new Point(0,0));
			packWindow.x = p.x + FineryModule.getInstance().stovePanel.width + 5;
			packWindow.y = p.y;
			queryPack(1,0);
		}
		
		private function queryPack(index:int,type:int):void{
			var e:ParamEvent = new ParamEvent(StoveConstant.BOX_QUERY,null,true);
			e.data = {index:index,type:type};
			dispatchEvent(e);
		}
		
		private function onItemDouleClick(event:ParamEvent):void{
			dispatchEvent(new ParamEvent(event.type,event.data,true));
		}
		
		private function onMergeClick(event:ParamEvent):void{
			dispatchEvent(new ParamEvent(event.type,null,true));
		}
		
		private function onAllGetClick(event:ParamEvent):void{
			dispatchEvent(new ParamEvent(event.type,event.data,true));
		}
		
		private function onClassClick(event:ParamEvent):void{
			queryPack(1,event.data.type);
		}
		
		public function callback(vo:m_refining_box_toc):void{
			switch(vo.op_type){
				case StoveConstant.BOX_OP_TYPE_INFO:
					info(vo);
					break;
				case StoveConstant.BOX_OP_TYPE_GET_TO_PACK:
					getToPack(vo);
					break;
				case StoveConstant.BOX_OP_TYPE_RELOAD:
					reload(vo);
					break;
				case StoveConstant.BOX_OP_TYPE_RESTORE:
					restore(vo);
					break;
				case StoveConstant.BOX_OP_TYPE_QUERY:
					query(vo);
					break;
				case StoveConstant.BOX_OP_TYPE_GET:
					getGood(vo);
					break;
				case StoveConstant.BOX_OP_TYPE_MERGE:
					merge(vo);
					break;
				case StoveConstant.BOX_OP_TYPE_RESTORE_TO_PACK:
					restore(vo);
					break;
			}
			cleanEffect();
		}
		
		private function info(vo:m_refining_box_toc):void{
			if(vo.succ){
				setTime(vo.award_time);
				setItem(vo.cur_list);
				setMyLog(vo.self_log_list);
				setOtherLog(vo.all_log_list);
			}else{
				errorTip(vo.reason);
			}
		}
		
		private function reload(vo:m_refining_box_toc):void{
			if(vo.succ){
				setTime(vo.award_time);
				setItem(vo.cur_list);
				setMyLog(vo.self_log_list);
				setOtherLog(vo.all_log_list);
			}else{
				errorTip(vo.reason);
			}
		}
		
		private function getToPack(vo:m_refining_box_toc):void{
			if(vo.succ){
				setTime(vo.award_time);
				setItem(vo.cur_list);
				setMyLog(vo.self_log_list);
				setOtherLog(vo.all_log_list);
			}else{
				errorTip(vo.reason);
			}
		}
		
		private var zoom:ZoomEffect;
		private function restore(vo:m_refining_box_toc):void{
			if(vo.succ){
				setTime(vo.award_time);
				setItem(vo.cur_list);
				showGood(vo.award_list);
				setMyLog(vo.self_log_list);
				setOtherLog(vo.all_log_list);
			}else{
				errorTip(vo.reason);
			}
		}
		
		private function merge(vo:m_refining_box_toc):void{
			if(vo.succ){
				if(packWindow){
					packWindow.setGoods(vo.box_list);
				}
			}else{
				errorTip(vo.reason);
			}
			if(packWindow){
				packWindow.removeDataLoading();
			}
		}
		
		private function query(vo:m_refining_box_toc):void{
			if(vo.succ){
				if(packWindow){
					packWindow.setGoods(vo.box_list);
				}
			}else{
				errorTip(vo.reason);
			}
		}
		
		private function getGood(vo:m_refining_box_toc):void{
			if(vo.succ){
				var s:String = "";
				var p:p_goods;
				for(var i:int=0; i < vo.award_list.length; i++){
					p = vo.award_list[i] as p_goods;
					Tips.getInstance().addTipsMsg("成功拾取"+HtmlUtil.font(p.name,ItemConstant.COLOR_VALUES[p.current_colour],14)+"x"+p.current_num);
					//BroadcastSelf.logger("成功拾取"+HtmlUtil.font(p.name,ItemConstant.COLOR_VALUES[p.current_colour],12)+"x"+p.current_num);
					if(packWindow){
						packWindow.removeGoods(p.id);
					}
				}
			}else{
				errorTip(vo.reason);
			}
			if(packWindow && packWindow.isAll){
				packWindow.removeAllGetEffect();
			}
		}
		
		private function showGood(value:Array):void{
			if(!zoom){
				zoom = new ZoomEffect();
			}
			var startPoint:Point = boxCan.localToGlobal(new Point(boxCan.width*0.5,0));
			var endPoint:Point = packBtn.localToGlobal(new Point(packBtn.width*0.5,0));
			for(var i:int = 0; i < value.length; i++){
				var p:p_goods = value[i] as p_goods;
				var baseItemVO:BaseItemVO = PackageModule.getInstance().getBaseItemVO(p);
				if(packWindow){
					packWindow.addGoods(p);
				}
				zoom.zoomTo(baseItemVO.path,startPoint.x,startPoint.y,endPoint.x,endPoint.y,endPoint.x+20,endPoint.y-20);
			}
		}
		
		private function setTime(value:int):void{
			time = value;
			if(time - SystemConfig.serverTime > 0){
				LoopManager.addToSecond(key,updateTime);
				updateTime();
			}else{
				timeTF.text = "距离下次更新：00:00";
			}
		}
		
		public function updateTime():void{
			var s:int = Math.max(0,(time - SystemConfig.serverTime));
			timeTF.text = "距离下次更新："+DateFormatUtil.formatTime(s);
			if(s==0){
				LoopManager.removeFromSceond(key);
				LoopManager.setTimeout(getInfoFromTimeOut,1500);
			}
		}
		
		private function getInfoFromTimeOut():void{
			getInfo();
		}
		
		private function cleanItem():void{
			var l:int = boxCan.numChildren;
			for(var i:int = 0; i < l; i++){
				var boxItem:BoxItem = boxCan.getChildAt(i) as BoxItem;
				boxItem.data=null;
			}
		}
		
		private function hasItem():Boolean{
			var l:int = boxCan.numChildren;
			for(var i:int = 0; i < l; i++){
				var boxItem:BoxItem = boxCan.getChildAt(i) as BoxItem;
				if(boxItem.data==null){
					return false;
				}
			}
			return true;
		}
		
		private function setItem(items:Array):void{
			cleanItem();
			for(var i:int=0; i < items.length; i++){
				var p:p_goods = items[i] as p_goods;
				var baseItem:BaseItemVO = ItemLocator.getInstance().getObject(p.typeid);
				baseItem.copy(p);
				if(boxCan.numChildren > i){
					var boxItem:BoxItem = boxCan.getChildAt(i) as BoxItem;
					boxItem.data = baseItem;
				}
			}
		}
		
		private function onMySelfLogClick(event:TextEvent):void{
			var values:Array = event.text.split("*");
			var time:Number = values[0];
			var roleID:int = values[1];
			var index:int = values[2];
			var typeid:int = values[3];
			for(var i:int = 0; i < myLogs.length; i++){
				var vo:p_refining_box_log = myLogs[i] as p_refining_box_log;
				if(time == vo.award_time && roleID == vo.role_id){
					var p:p_goods = vo.box_list[index];
					if(p!=null && p.typeid == typeid){
						var baseItem:BaseItemVO = ItemLocator.getInstance().getObject(p.typeid);
						baseItem.copy(p);
						getTip().show(baseItem,vo.role_name,vo.role_sex);
						updateTipPostion();
						return;
					}
				}
			}
		}
		
		private function onOtherLogClick(event:TextEvent):void{
			var values:Array = event.text.split("*");
			var time:Number = values[0];
			var roleID:int = values[1];
			var index:int = values[2];
			for(var i:int = 0; i < otherLogs.length; i++){
				var vo:p_refining_box_log = otherLogs[i] as p_refining_box_log;
				if(time == vo.award_time && roleID == vo.role_id){
					var p:p_goods = vo.box_list[index];
					var baseItem:BaseItemVO = ItemLocator.getInstance().getObject(p.typeid);
					baseItem.copy(p);
					getTip().show(baseItem,vo.role_name,vo.role_sex);
					updateTipPostion();
					return;
				}
			}
		}
		
		private function setMyLog(logs:Array):void{
			if(logs.length == 0){
				return;
			}
			myLogs = logs;
			var s:String = "";
			var l:int = logs.length;
			var vo:p_refining_box_log;
			for(var i:int = 0; i < l; i++){
				vo = logs[i];
				s+=createLog(vo,1);
			}
			TRLog.htmlText = s;
			TRLog.validateNow();
			TRLog.setMaxScroll();
		}
		
		private function setOtherLog(logs:Array):void{
			if(logs.length == 0){
				return;
			}
			otherLogs = logs;
			var s:String = "";
			var l:int = logs.length;
			var vo:p_refining_box_log;
			for(var i:int = 0; i < l; i++){
				vo = logs[i];
				s+=createLog(vo);
			}
			BRLog.htmlText = s;
			BRLog.validateNow();
			BRLog.setMaxScroll();
		}
		
		private function createLog(vo:p_refining_box_log,model:int=0):String{
			var s:String = '';
			var l:int = vo.box_list.length;
			var p:p_goods;
			for(var i:int; i < l; i++){
				p = vo.box_list[i] as p_goods;
				var key:String = vo.award_time + "*" + vo.role_id +"*"+ i + "*" + p.typeid;
				if(model==0)s += HtmlUtil.font('['+vo.role_name+'] ','#ffffff');
				s += HtmlUtil.font('获得 ',"#ffffff");
				s += HtmlUtil.link(HtmlUtil.font('【'+p.name+'】',ItemConstant.COLOR_VALUES[p.current_colour]),key,true);
				if(p.current_num > 1){
					s += HtmlUtil.font('x'+p.current_num,'#ffffff') + '\n';
				}else{
					s += '\n';
				}
			}
			return s;
		}
		
		private function getTip():BoxItemToolTip{
			if(tip){
				return tip;
			}
			return tip=new BoxItemToolTip();
		}
		
		private function updateTipPostion():void{
			if(tip){
				var p:Point = this.localToGlobal(new Point(0,0));
				tip.x = this.localToGlobal(new Point(0,0)).x + 120;
				if( p.y + tip.height >  stage.stageHeight){
					tip.y = stage.stageHeight - tip.height;
				}else{
					tip.y = p.y + 20;
				}
			}
		}
		
		private function errorTip(str:String):void{
			Tips.getInstance().addTipsMsg(str);
			//BroadcastSelf.logger(str);
		}
		
		private function startEffect():void{
			var l:int = boxCan.numChildren;
			for(var i:int = 0; i < l; i++){
				var boxItem:BoxItem = boxCan.getChildAt(i) as BoxItem;
				if(boxItem)boxItem.playEffect();
			}
		}
		
		private function cleanEffect():void{
			var l:int = boxCan.numChildren;
			for(var i:int = 0; i < l; i++){
				var boxItem:BoxItem = boxCan.getChildAt(i) as BoxItem;
				if(boxItem)boxItem.stopEffect();
			}
		}
		
		public function unload():void{
			LoopManager.removeFromSceond(key);
		}
		
		public function checkState():void{
			reloadBtn.visible = !StoveConstant.boxIsFree;
		}
	}
}
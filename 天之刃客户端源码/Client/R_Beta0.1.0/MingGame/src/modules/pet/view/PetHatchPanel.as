package modules.pet.view {
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.components.DataGrid;
	import com.components.alert.Alert;
	import com.managers.Dispatch;
	import com.managers.WindowManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.net.connection.Connection;
	import com.scene.sceneManager.LoopManager;
	import com.utils.ComponentUtil;
	import com.utils.DateFormatUtil;
	import com.utils.HtmlUtil;

	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;

	import modules.ModuleCommand;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;

	import proto.line.m_pet_egg_refresh_toc;
	import proto.line.m_pet_egg_refresh_tos;
	import proto.line.m_pet_egg_use_toc;

	public class PetHatchPanel extends BasePanel {
		public static var eggID:int; //使用的宠物蛋ID
		private var tip:TextField;
		private var nextTime:TextField;
		private var grid:DataGrid;
		private var hatchBtn:Button;
		private var items:Array;
		private var tipStr:String;
		private var effectTime:int; //剩余时间，单位是秒
		private var freshTime:int; //刷新时间
		private var hasRefresh:Boolean;
		private var alertID:String;

		public function PetHatchPanel(key:String=null) {
			super(key);
			title="领养宠物";
			width=536;
			height=418;
			initView();
		}

		private function initView():void {
			var tf:TextFormat=new TextFormat(null, null, 0xAFE0EE);
			var tf2:TextFormat=new TextFormat(null, null, 0xAFE0EE, null, null, null, null, null, "left");
//			tipStr="宠物蛋" + HtmlUtil.font("有效时间", 0x00ff00) + "剩余:";
			tip=ComponentUtil.createTextField("宠物蛋有效时间剩余：23时12分22秒，刷新出称心的宠物请尽快领养。", 12, 4, tf2, 512, 20, this);
			nextTime=ComponentUtil.createTextField("距离下一次列表刷新还有：1时20分", 12, 40, tf2, 512, 20, this);
			var tip2:TextField=ComponentUtil.createTextField("", 12, 22, tf2, 512, 20, this);
			tip2.htmlText="神宠蛋可刷出资质为：" + HtmlUtil.font("2500、2200、2100、2000、1900、1700、1500", "#00ff00") + "的宠物";
			grid=new DataGrid;
			grid.addColumn("宠物", 160);
			grid.addColumn("类型", 70);
			grid.addColumn("可携带等级", 90);
			grid.addColumn("资质最高可达", 100);
			grid.addColumn("操作", 76);
			grid.width=512;
			grid.height=16;
			grid.verticalScrollPolicy="off";
			grid.x=12;
			grid.y=72;
			addChild(grid);
			var p1:UIComponent=new UIComponent();
			Style.setBorder1Skin(p1);
			p1.width=512;
			p1.height=68;
			addChild(p1);
			var p2:UIComponent=new UIComponent();
			Style.setBorder1Skin(p2);
			p2.width=512;
			p2.height=68;
			addChild(p2);
			var p3:UIComponent=new UIComponent();
			Style.setBorder1Skin(p3);
			p3.width=512;
			p3.height=68;
			addChild(p3);
			var p4:UIComponent=new UIComponent();
			Style.setBorder1Skin(p4);
			p4.width=512;
			p4.height=68;
			addChild(p4);
			p1.x=p2.x=p3.x=p4.x=12;
			p1.y=96;
			p2.y=p1.y + 70;
			p3.y=p2.y + 70;
			p4.y=p3.y + 70;
			hatchBtn=ComponentUtil.createButton("立刻更新下一批 ", 310, 40, 120, 30, this);
			hatchBtn.textColor=0xff9933;
			hatchBtn.addEventListener(MouseEvent.CLICK, onClickHatch);
			var money:TextField=ComponentUtil.createTextField("需花费10元宝", hatchBtn.x + 124, 44, null, 120, 20, this);
			money.textColor=0x00ff00;
			items=new Array(4);
			for (var i:int=0; i < 4; i++) {
				var t:PetHatchItem=new PetHatchItem;
				t.x=12;
				t.y=70 * i + 96;
				addChild(t);
				items[i]=t;
			}
		}

		private function onClickHatch(e:MouseEvent):void {
			if (GlobalObjectManager.getInstance().getGold() < 10) {
				alertID=Alert.show("您的元宝不足，无法立即刷新！<font color='#00FF00'><a href='event:openPay;'><u>快速充值</u></a></font>", "提示", null, null, "确定", "", null, false, false, null, openPay);
				return;
			}
			var vo:m_pet_egg_refresh_tos=new m_pet_egg_refresh_tos;
			vo.goods_id=eggID;
			Connection.getInstance().sendMessage(vo);
		}

		private function openPay(e:TextEvent):void {
			Alert.removeAlert(alertID);
			Dispatch.dispatch(ModuleCommand.OPEN_PAY_HANDLER);
		}

		public function onUseEgg(vo:m_pet_egg_use_toc):void {
			eggID=vo.goods_id;
			hasRefresh=false;
			for (var i:int=0; i < 4; i++) {
				var t:PetHatchItem=items[i];
				t.data=vo.type_id_list[i];
			}
			effectTime=getTimer() + vo.egg_left_tick * 1000;
			freshTime=getTimer() + vo.refresh_tick * 1000;
			LoopManager.addToSecond(this, secondLoop);
			for (i=0; i < 4; i++) {
				var tt:PetHatchItem=items[i];
				tt.opBtn.enabled=true;
			}
			hatchBtn.enabled=true;
		}

		public function onRefresh(vo:m_pet_egg_refresh_toc):void {
			for (var i:int=0; i < 4; i++) {
				var t:PetHatchItem=items[i];
				t.data=vo.type_id_list[i];
			}
			hasRefresh=true;
		}

		private function secondLoop():void {
			var effectLeft:int=int((effectTime - getTimer()) / 1000);
			var freshLeft:int=int((freshTime - getTimer()) / 1000);
			if (effectLeft > 0) {
				tip.htmlText="宠物蛋有效时间剩余：" + HtmlUtil.font(DateFormatUtil.formatTickToCNTimes(effectLeft), "#ffaa33") + "，刷新出称心的宠物请尽快领养。"
			} else {
				tip.htmlText="您的宠物蛋已过期，不可领养宠物";
				nextTime.htmlText="";
				resetBtn(false);
			}
			if (hasRefresh == false && freshLeft > 0) {
				nextTime.htmlText=HtmlUtil.font(DateFormatUtil.formatTickToCNTimes(freshLeft), "#ffaa33") + "后更新下一批宠物";
			} else {
				nextTime.htmlText="";
			}
		}

		public function onAdopt():void {
			for (var i:int=0; i < 4; i++) {
				var t:PetHatchItem=items[i];
				t.opBtn.enabled=false;
			}
			hatchBtn.enabled=false;
			LoopManager.removeFromSceond(this);
			nextTime.htmlText="本次宠物蛋已经使用";
			if (WindowManager.getInstance().isPopUp(this) == true) {
				WindowManager.getInstance().removeWindow(this);
			}
		}

		private function resetBtn(value:Boolean):void {
			for (var i:int=0; i < 4; i++) {
				var t:PetHatchItem=items[i];
				t.opBtn.enabled=value;
			}
			hatchBtn.enabled=value;
		}
	}
}
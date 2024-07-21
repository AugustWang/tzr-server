package modules.family.views.items {
	import com.common.GlobalObjectManager;
	import com.components.DataGrid;
	import com.managers.Dispatch;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.NumericStepper;
	import com.ming.ui.controls.TextInput;
	import com.net.SocketCommand;
	import com.net.connection.Connection;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	import com.utils.MoneyTransformUtil;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.broadcast.views.Tips;
	import modules.family.FamilyDepotModule;
	import modules.family.FamilyModule;
	
	import proto.line.m_family_donate_toc;
	import proto.line.m_family_get_donate_info_toc;
	import proto.line.m_family_get_donate_info_tos;
	
	public class ContributeSilverView extends Sprite {
		private var goldInput:NumericStepper;
		private var hasGoldTF:TextField;
		private var contributePoint:TextField;
		private var yesBtn:Button;
		private var goldDataGrid:DataGrid;
		private var silverInput:NumericStepper;
		
		public function ContributeSilverView() {
			initView();
		}
		
		private function initView():void {
			var tf:TextFormat=new TextFormat("Tahoma", 12, 0xfffd4b)
			var startX:int=18;
			var startY:int=18;
			var landing:int=20;
			ComponentUtil.createTextField("捐献金币：", startX, startY, tf, 100, 25, this).filters=Style.textBlackFilter;
			goldInput=new NumericStepper();
			goldInput.minnum = 0;
			goldInput.width=50;
			goldInput.height=24;
			goldInput.x=startX + 60;
			goldInput.y= startY - 2;
			goldInput.value = 0;
			goldInput.addEventListener(Event.CHANGE,onInputChange);
			addChild(goldInput);
			ComponentUtil.createTextField("锭",goldInput.x+goldInput.width+2,startY,null,20,24,this);
			silverInput=new NumericStepper();
			silverInput.minnum = 0;
			silverInput.width=50;
			silverInput.height=24;
			silverInput.x=goldInput.x + 65 ;
			silverInput.y= startY - 2;
			silverInput.value = 0;
			silverInput.addEventListener(Event.CHANGE,onInputChange);
			addChild(silverInput);
			ComponentUtil.createTextField("两",silverInput.x+silverInput.width+2,startY,null,20,24,this);
			
			hasGoldTF=ComponentUtil.createTextField("", startX, startY + landing, null, 150, 25, this);
			hasGoldTF.filters=Style.textBlackFilter;
			hasGoldTF.htmlText=HtmlUtil.font("拥有金币：" + MoneyTransformUtil.silverToOtherString(GlobalObjectManager.getInstance().user.attr.silver), "#fffd4b");
			contributePoint=ComponentUtil.createTextField("", startX, startY + landing * 2, null, 150, 25, this);
			contributePoint.filters=Style.textBlackFilter;
			contributePoint.htmlText=HtmlUtil.font("可获得贡献度：" + goldInput.value, "#fffd4b");
			
			yesBtn=ComponentUtil.createButton("确定", startX, startY + landing * 3, 60, 24, this);
			yesBtn.addEventListener(MouseEvent.CLICK, onYesBtnClick);
			
			goldDataGrid=new DataGrid();
			goldDataGrid.list.listSkin=Style.getBorderListSkin();
			goldDataGrid.list.autoJustSize=true;
			Style.setBorderSkin(goldDataGrid);
			goldDataGrid.x=15;
			goldDataGrid.y=yesBtn.y + 30;
			goldDataGrid.itemHeight=46;
			goldDataGrid.itemRenderer=ContributeGlodItemRender;
			goldDataGrid.width=270;
			goldDataGrid.height=200;
			goldDataGrid.addColumn("排名", 40);
			goldDataGrid.addColumn("角色名", 100);
			goldDataGrid.addColumn("捐献金额", 100);
			//goldDataGrid.list.addEventListener(ItemEvent.ITEM_CLICK, onSkillItemClick);
			addChild(goldDataGrid);
			
			addEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE,onRemovedFromStage);
		}
		
		private function onInputChange(event:Event):void {
			var moneys:Array = MoneyTransformUtil.silverToOther(GlobalObjectManager.getInstance().user.attr.silver);
			if (goldInput.value > moneys[0]) {
				goldInput.value = moneys[0];
			}
			if (goldInput.value < 0) {
				goldInput.value=0;
			}
			if (silverInput.value > moneys[1]) {
				silverInput.value = moneys[1];
			}
			if (silverInput.value < 0) {
				silverInput.value=0;
			}
			contributePoint.htmlText=HtmlUtil.font("可获得贡献度：", "#fffd4b") + HtmlUtil.font(String(goldInput.value*100+silverInput.value), "#00ff00");
		}
		
		private var _silverList:Array;
		
		private function onFamilyGetDonateInfo(vo:m_family_get_donate_info_toc):void {
			if (vo.succ) {
				update(vo.donate_silver_list);
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}
		
		private function update(value:Array):void {
			value.sortOn("donate_amount", Array.NUMERIC);
			_silverList=value;
			var result:Array=[];
			for (var i:int=0; i < value.length; i++) {
				result.push({index: i, vo: value[i]});
			}
			goldDataGrid.dataProvider=result;
			hasGoldTF.htmlText=HtmlUtil.font("拥有金币：" + MoneyTransformUtil.silverToOtherString(GlobalObjectManager.getInstance().user.attr.silver), "#fffd4b");
		}
		
		private function onFamilyDonate(vo:m_family_donate_toc):void {
			if (vo.donate_type != 2) {
				return;
			}
			if (vo.succ) {
				Tips.getInstance().addTipsMsg("捐献成功");
				var hasID:Boolean = false;
				for (var i:int=0; i < _silverList.length; i++) {
					if (vo.donate_info.role_id == _silverList[i].role_id) {
						_silverList[i].donate_amount=vo.donate_info.donate_amount;
						hasID=true;
					}
				}
				if(!hasID){
					if(!_silverList){
						_silverList=[];
					}
					_silverList.push(vo.donate_info.donate_amount);
				}
				update(_silverList);
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}
		
		private function onYesBtnClick(event:MouseEvent):void {
			FamilyModule.getInstance().donate(2,goldInput.value*100+silverInput.value);
		}
		
		private function onAddedToStage(event:Event):void{
			Connection.getInstance().addSocketListener(SocketCommand.FAMILY_GET_DONATE_INFO,onFamilyGetDonateInfo);
			Connection.getInstance().addSocketListener(SocketCommand.FAMILY_DONATE, onFamilyDonate);
			FamilyModule.getInstance().getDonateInfo();
		}
		
		private function onRemovedFromStage(event:Event):void{
			Connection.getInstance().removeSocketListener(SocketCommand.FAMILY_GET_DONATE_INFO, onFamilyGetDonateInfo);
			Connection.getInstance().removeSocketListener(SocketCommand.FAMILY_DONATE, onFamilyDonate);
		}
		
		private function createTextInput(x:int, y:int, w:int, h:int, $parent:DisplayObjectContainer):TextInput {
			var itf:TextFormat=new TextFormat("Tahoma", 12, 0xfffd4b);
			var textInput:TextInput=ComponentUtil.createTextInput(x, y, w, h, $parent);
			textInput.textField.defaultTextFormat=itf;
			textInput.leftPadding=8;
			$parent.addChild(textInput);
			return textInput;
		}
	}
}
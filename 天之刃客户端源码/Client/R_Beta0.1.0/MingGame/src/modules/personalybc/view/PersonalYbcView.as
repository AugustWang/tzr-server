package modules.personalybc.view {
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.managers.WindowManager;
	import com.ming.ui.controls.Button;
	import com.utils.ComponentUtil;
	import com.utils.MoneyTransformUtil;
	import com.utils.PathUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	
	import modules.broadcast.views.BroadcastView;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.PackageModule;
	import modules.mypackage.managers.PackManager;
	import modules.personalybc.PersonalYbcModule;
	import modules.shop.ShopModule;
	
	import proto.line.m_personybc_info_toc;
	import proto.line.p_personybc_award_attr;
	import proto.line.p_personybc_info;

	public class PersonalYbcView extends BasePanel {
		private var dataTxt:TextField;
		public var color:int;
		public var desc:String;
		public var info_toc:m_personybc_info_toc;
		public var sureBtn:Button;
		// 各种镖车奖励信息面板
		private var ybcListPanel:YBCListView;
		public var cancaleBtn:Button;
		public var updataBtn:Button;
		private var textAcc:TextField;
		private var txt:TextField;
		public var doit:int=0;
		public var type:int=0;

		public static const YBC_UPGRADE_CARD:int=11600001; //换车令
		private var payText:TextField;

		//颜色数组
		private var colorArray:Array;
		//显示本次拉镖的颜色的text
		private var colorText:TextField;
		//经验显示
		private var expeText:TextField;
		//绑定银子显示
		private var bindGoldText:TextField;
		//不绑定银子显示
		private var unBindGoldText:TextField;
		//显示是不是门派的提示text
		private var isGenText:TextField;
		//目前是第几次获取镖车
		private var getCarText:TextField;
		//该颜色是否已经被保护
		private var protectText:TextField;

		public function PersonalYbcView(key:String=null) {
			super(key);
			initView();
		}

		public function updataColor(color:int):void {

			if (this.info_toc == null || this.info_toc.info == null) {
				return;
			}

			if (color != 5) {
				this.updataBtn.enabled=true;
			} else {
				this.updataBtn.enabled=false;
			}

			this.mouseEnabled=false;
			this.color=color;
			this.info_toc.info.color=color;
//			var baioche:String;
//			var str2:String='';
//			
//			var bai:String='<FONT COLOR="#FFFFFF">白</FONT>';
//			var lv:String='<FONT COLOR="#10ff04">绿</FONT>';
//			var lan:String='<FONT COLOR="#00c6ff">蓝</FONT>';
//			var zi:String='<FONT COLOR="#ff00c6">紫</FONT>';
//			var cheng:String='<FONT COLOR="#FF6c00">橙</FONT>';
//			var colors:Array=[bai,lv,lan,zi,cheng];
//			var dun:String='<FONT COLOR="#F6F5CD">、</FONT>';
//			var nowColor:String=colors[int(this.color-1)];

//			if(this.type == 1){
//				pannelStr = '<FONT COLOR="#F6F5CD"><BR />完成国运拉镖任务，额外获得50%的经验奖励，获得的银子奖励25%为不绑定银子。</FONT>';
//			}else{
//				pannelStr = '<FONT COLOR="#F6F5CD">'+desc+'</FONT>';
//			}

			var vo:p_personybc_info=PersonalYbcModule.getInstance().view.info_toc.info;
			//var _costStr:String = '<FONT COLOR="#FFFF00">需要押金：</FONT><font color="#F6F5CD">不绑定银子'+MoneyTransformUtil.silverToOtherString(vo.cost_silver+vo.cost_silver_bind)+'</font>';

			getCarText.htmlText="<font color='#FFFF00'>今天第" + "<font color='#3BE450'>" + vo.do_times +
				"</font>" + "次领取镖车(共3次)</font>";

			var _noFamilyTips:String='';
			//vo.status == 3表示拉镖超时，1是拉镖状态，2是镖车被劫状态
			if (GlobalObjectManager.getInstance().user.base.family_id == 0 && vo.status == 3) {
				_noFamilyTips='<font color="#3BE450">你当前没有门派，只能领取5%的奖励。</font>';
			} else if (GlobalObjectManager.getInstance().user.base.family_id == 0) {
				_noFamilyTips='<font color="#3BE450">你当前没有门派，只能领取20%的奖励。</font>';
			}
			isGenText.htmlText=_noFamilyTips;

			var nowColor:String=colorArray[int(this.color - 1)];
			var obj:Object=getColorInfo(this.color);
			if (this.color == 4) {
				protectText.visible=true;
			} else {
				protectText.visible=false;
			}
			if (this.color == 5) {
				this.updataBtn.enabled=false;
			} else {
				this.updataBtn.enabled=true;
			}

			if (obj.jy_num > 0)
				expeText.htmlText="<FONT color='#F6F5CD'>经        验： " + obj.jy + "</FONT>";
			if (obj.bdyz_num > 0)
				bindGoldText.htmlText="<FONT color='#F6F5CD'>绑定银子：" + obj.bdyz + "</FONT>";
			colorText.htmlText="<FONT COLOR='#F6F5CD' SIZE='36'>" + nowColor + "</FONT>";

			if (type == 0) {
				this.title="个人拉镖";
				unBindGoldText.visible=false;
			} else {
				this.title="门派拉镖";
				unBindGoldText.htmlText="</FONT><font color='#F6F5CD'>不绑银子：" + obj.yz + "</font>";
				unBindGoldText.visible=true;
			}
		}

		public function commitView():void {
			this.updataBtn.visible=false;
			this.sureBtn.enabled=true;
			this.cancaleBtn.visible=false;
			this.sureBtn.x=this.cancaleBtn.x;
		}

		public function publicView():void {
			this.updataBtn.visible=true;
			this.sureBtn.enabled=true;
			this.cancaleBtn.enabled=true;
			this.sureBtn.x=125;
		}

		public function initView():void {
			var ui:Sprite=new Sprite();
			ui.x=7
			ui.width=285;
			ui.height=346;
			this.addChild(ui);
			this.dataTxt=new TextField;
			dataTxt.filters=[new GlowFilter(0, 1, 2, 2)];
			dataTxt.addEventListener(TextEvent.LINK, onLinkFunc)
			dataTxt.x=25;
			dataTxt.y=10
			this.width=300
			this.height=385;
			dataTxt.width=300;
			dataTxt.height=280;
			dataTxt.multiline=true;
			dataTxt.wordWrap=true;
			dataTxt.selectable=false;
			this.addChild(dataTxt);

			var pannelStr:String='<FONT COLOR="#F6F5CD">张将军：<BR />        护送镖车到边城交给蓝玉将军。</FONT>';

			var bai:String='<FONT COLOR="#FFFFFF">白</FONT>';
			var lv:String='<FONT COLOR="#10ff04">绿</FONT>';
			var lan:String='<FONT COLOR="#00c6ff">蓝</FONT>';
			var zi:String='<FONT COLOR="#ff00c6">紫</FONT>';
			var cheng:String='<FONT COLOR="#FF6c00">橙</FONT>';
			colorArray=[bai, lv, lan, zi, cheng];
//			var dun:String='<FONT COLOR="#F6F5CD">、</FONT>';
			var baioche:String='<FONT COLOR="#F6F5CD">        镖车颜色有：</FONT>' + bai + " " + lv + " " +
				lan + " " + zi + " " + cheng + '<FONT COLOR="#F6F5CD">      <A HREF="event:"><FONT color="#EBED32"><U>查看奖励</U></FONT></A>';
			this.dataTxt.htmlText=pannelStr + '\n' + baioche


			var thisColorText:TextField=new TextField();
			thisColorText.height=50;
			thisColorText.filters=[new GlowFilter(0, 1, 2, 2)];
			thisColorText.x=50;
			thisColorText.y=70;
			thisColorText.htmlText='<FONT COLOR="#F6F5CD">当前镖车颜色：</FONT>';
			this.addChild(thisColorText);

			colorText=new TextField();
			colorText.x=140;
			colorText.y=85;
			colorText.text="紫色";
			this.addChild(colorText);

			protectText=new TextField();
			protectText.x=190;
			protectText.y=110;
			protectText.htmlText="<font color='#3BE450'>颜色已保护</font>";
			protectText.visible=false;
			this.addChild(protectText);

			updataBtn=ComponentUtil.createButton('使用换车令(0)', 160, 132, 110, 25, this);
			updataBtn.addEventListener(MouseEvent.CLICK, updataFunc);

//			payText=ComponentUtil.createTextField("", 175, updataBtn.y, null, 100, 22);
//			payText.htmlText="<font color='#00FF00'><a href='#'><u>购买换车令</u></a></font>";
//			payText.mouseEnabled = true;
//			payText.addEventListener(MouseEvent.CLICK, onBuyBtnClick);
//			addChild(payText);


			var mission:String='<FONT color="#EBED32"><b>任务奖励：</b></FONT>';
			var missionText:TextField=new TextField();
			missionText.filters=[new GlowFilter(0, 1, 2, 2)];
			missionText.x=50;
			missionText.y=179;
			missionText.htmlText=mission;
			this.addChild(missionText);

			expeText=new TextField();
			expeText.filters=[new GlowFilter(0, 1, 2, 2)];
			expeText.x=50;
			expeText.y=199;
			expeText.width=160;
			this.addChild(expeText);

			bindGoldText=new TextField();
			bindGoldText.filters=[new GlowFilter(0, 1, 2, 2)];
			bindGoldText.x=50;
			bindGoldText.y=214;
			bindGoldText.width=160;
			this.addChild(bindGoldText);

			unBindGoldText=new TextField();
			unBindGoldText.filters=[new GlowFilter(0, 1, 2, 2)];
			unBindGoldText.x=50;
			unBindGoldText.y=229;
			unBindGoldText.width=160;
			this.addChild(unBindGoldText);

			isGenText=new TextField();
			isGenText.filters=[new GlowFilter(0, 1, 2, 2)];
			isGenText.x=50;
			isGenText.y=259;
			isGenText.width=230;
			this.addChild(isGenText);

			getCarText=new TextField();
			getCarText.x=118;
			getCarText.y=289;
			getCarText.width=160;
			this.addChild(getCarText);

			sureBtn=ComponentUtil.createButton("确定", 125, 310, 70, 25, this);
			sureBtn.addEventListener(MouseEvent.CLICK, sureFunc);

			cancaleBtn=ComponentUtil.createButton("取消", 200, 310, 70, 25, this);
			cancaleBtn.addEventListener(MouseEvent.CLICK, canclefunc)

			setHCLNum();

			Style.setRedBtnStyle(updataBtn);
//			Style.setRedBtnStyle(sureBtn);
//			Style.setRedBtnStyle(cancaleBtn);
		}

		/**
		 * 点击个人拉镖面板中的 京城知事 链接
		 * 自动寻路到那里
		 */
		private function onAccPersonYbcClick(e:TextEvent):void {
			PathUtil.findNPC(e.text);
		}

		//设置换车令数量提示文本
		public function setHCLNum():void {
			if (this.info_toc) {
				if (this.info_toc.info.color == 5) {
					this.updataBtn.enabled=false;
				} else {
					this.updataBtn.enabled=true;
				}
			} else {
				this.updataBtn.enabled=true;
			}
			var hclNum:int=PackManager.getInstance().getGooodsCountByEffectType(ItemConstant.EFFECT_HCL);
			if (hclNum == 0) {
				updataBtn.label='购买换车令';
			} else {
				updataBtn.label='使用换车令(' + hclNum + ')';
			}
		}

		private function onLinkFunc(e:TextEvent):void {
			if (ybcListPanel == null) {
				ybcListPanel=new YBCListView;
			}
			ybcListPanel.width=300
			ybcListPanel.x=this.x + 260;
			ybcListPanel.y=this.y + 90
			var arrx:Array=[{jy: 0, yz: 0, bdyz: 0}, {jy: 0, yz: 0, bdyz: 0}, {jy: 0, yz: 0, bdyz: 0},
				{jy: 0, yz: 0, bdyz: 0}, {jy: 0, yz: 0, bdyz: 0}]
			var arr_info:Array=info_toc.info.attr_award
			for (var c:int=0; c < arr_info.length; c++) {
				var v:p_personybc_award_attr=arr_info[c] as p_personybc_award_attr
				switch (v.attr_type) {
					case 1:
						arrx[v.color - 1].jy=v.attr_num
						break;
					case 2:
						arrx[v.color - 1].yz=MoneyTransformUtil.silverToOtherString(v.attr_num)
						break;
					case 3:
						arrx[v.color - 1].bdyz=MoneyTransformUtil.silverToOtherString(v.attr_num)
						break;
				}
			}
			ybcListPanel.updata(arrx);
			WindowManager.getInstance().popUpWindow(ybcListPanel);
			ybcListPanel.x=this.x + this.width;
		}

		private function canclefunc(e:MouseEvent):void {
			this.closeWindow();
		}

		private function sureFunc(e:MouseEvent):void {
			if (this.type == 1 && GlobalObjectManager.getInstance().user.attr.family_contribute < 5) {
				BroadcastView.getInstance().addBroadcastMsg('门派贡献度（可参加门派活动获得）不足5点，无法领取国运镖车。')
			} else {
				PersonalYbcModule.getInstance().publicFunc(this.type);
			}
			this.closeWindow();
		}

		private function cancleFunc(e:MouseEvent):void {
			PersonalYbcModule.getInstance().cancel()
			this.closeWindow();

		}

		public function updataFunc(evt:MouseEvent):void {
			var target:Button=evt.target as Button;
			if (updataBtn.label == "购买换车令") {
				//高级商店 10102
				ShopModule.getInstance().requestShopItem(10102, YBC_UPGRADE_CARD,new Point(stage.mouseX-178, stage.mouseY-90));
			} else {
				if (PackageModule.getInstance().useHCL()) {
					this.updataBtn.enabled=false;
				}
			}
		}

		private function cancle():void {

		}

		private function getColorInfo(color:int):Object {
			var arrx:Array=[{jy: 0, yz: 0, bdyz: 0}, {jy: 0, yz: 0, bdyz: 0}, {jy: 0, yz: 0, bdyz: 0},
				{jy: 0, yz: 0, bdyz: 0}, {jy: 0, yz: 0, bdyz: 0}]
			var arr_info:Array=info_toc.info.attr_award
			for (var c:int=0; c < arr_info.length; c++) {
				var v:p_personybc_award_attr=arr_info[c] as p_personybc_award_attr
				switch (v.attr_type) {
					case 1:

						arrx[v.color - 1].jy=v.attr_num
						arrx[v.color - 1].jy_num=v.attr_num
						break;
					case 2:

						arrx[v.color - 1].yz=MoneyTransformUtil.silverToOtherString(v.attr_num)
						arrx[v.color - 1].yz_num=v.attr_num

						break;
					case 3:

						arrx[v.color - 1].bdyz=MoneyTransformUtil.silverToOtherString(v.attr_num)
						arrx[v.color - 1].bdyz_num=v.attr_num

						break;

				}
			}
			return arrx[color - 1]
		}

		public function updataTaskCar(vo:m_personybc_info_toc):void {
			this.info_toc=vo;
			this.color=vo.info.color;
			desc=vo.info.desc;
			updataColor(this.color);
			this.cancaleBtn.enabled=true;
			setHCLNum();
		}

		override public function closeWindow(save:Boolean=false):void {
			super.closeWindow(save)
		}

	}
}
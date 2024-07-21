package modules.Activity.view
{
	import com.common.FilterCommon;
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.globals.GameParameters;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.NumericStepper;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.JSUtil;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;

	import modules.Activity.ActivityModule;
	import modules.broadcast.views.Tips;
	import modules.conlogin.ConloginModule;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.views.GoodsImage;
	import modules.mypackage.vo.BaseItemVO;
	import modules.vip.VipModule;

	import proto.common.p_conlogin_reward;
	import proto.line.m_conlogin_fetch_toc;
	import proto.line.m_conlogin_fetch_tos;

	public class ConloginRewardList extends UIComponent
	{
		private var titleText:TextField;
		private var goodsItem:GoodsImage;
		private var view:Sprite;
		private var reward:p_conlogin_reward;
		private var buyButton:Button;
		private var conditionText:TextField;
		private var numStep:NumericStepper;
		private var remainNumText:TextField;
		public var id:int;
		private var showFetch:Boolean;
		// 下次领取奖励还需要多少天
		private var needDay:int;

		public function ConloginRewardList(rewardID:int, next_day:int, need_day:int)
		{
			this.needDay=need_day;

			this.showFetch=!(next_day > 0);
			this.id=rewardID;
			super();
			width=320;
			height=100;
			this.x=2;
			Style.setBorderSkin(this);

			var titleBar:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI, "titleBar");
			titleBar.width=319;
			titleBar.x=0;
			addChild(titleBar);

			var tf:TextFormat=Style.textFormat;
			tf.align="center";
			titleText=ComponentUtil.buildTextField("", tf, 318, 25, this);
			titleText.filters=FilterCommon.FONT_BLACK_FILTERS;
			titleText.mouseEnabled=true;
			titleText.selectable=true;
			titleText.x=1;
			titleText.y=0;

			var itemBg:Sprite=Style.getSpriteBitmap(GameConfig.T1_VIEWUI, "packItemBg");
			itemBg.x=28;
			itemBg.y=33;
			addChild(itemBg);

			goodsItem=new GoodsImage();
			goodsItem.x=goodsItem.y=4;
			goodsItem.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
			goodsItem.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			itemBg.addChild(goodsItem);
		}

		private function onRollOver(event:MouseEvent):void
		{
			if (goodsItem.data)
			{
				ToolTipManager.getInstance().show(goodsItem.data, 50, 0, 0, "goodsToolTip");
			}
		}

		/**
		 * 领取或者购买奖励成功后调用
		 * 需要更新道具的剩余数量，如果为0，则移除
		 * @return bool 是否需要移除本奖励view对象
		 */
		public function update(vo:m_conlogin_fetch_toc):Boolean
		{
			if (reward.gold > 0 || reward.silver > 0)
			{
				reward.num-=vo.num;
				if (reward.num < 1)
				{
					return true;
				}
				this.numStep.maxnum=reward.num;
				this.remainNumText.text="/" + reward.num;
				return false;
			}
			else
			{
				return true;
			}
		}

		private function onRollOut(event:MouseEvent):void
		{
			ToolTipManager.getInstance().hide();
		}

		override public function set data(value:Object):void
		{
			var reward:p_conlogin_reward=value as p_conlogin_reward;
			var itemObj:Object=ItemLocator.getInstance().getItem(value.type, value.type_id);
			super.data=value;
			this.titleText.htmlText="<font color='" + ItemConstant.COLOR_VALUES[itemObj.color] + "'>" + itemObj.name + "</font>";
			this.goodsItem.setImageContent(itemObj as BaseItemVO, itemObj.path);
			this.reward=reward;
			initView();
		}

		private function initBuyView():Sprite
		{
			var sp:Sprite=new Sprite;
			var priceStr:String="单价: ";
			if (reward.gold > 0)
			{
				priceStr+="元宝" + reward.gold;
			}
			if (reward.silver > 0)
			{
				priceStr+="银两" + reward.silver;
			}
			var priceText:TextField=ComponentUtil.createTextField(priceStr, 0, 0, null, 150, 22, sp);
			priceText.selectable=true;
			priceText.mouseEnabled=true;
			var condition:String=new String();
			if (reward.need_payed && !GlobalObjectManager.getInstance().user.attr.is_payed)
			{
				condition="需要已充值";
			}
			if (reward.min_level > GlobalObjectManager.getInstance().user.attr.level)
			{
				if (condition == '')
				{
					condition+="需要等级" + reward.min_level;
				}
				else
				{
					condition+=" 需要等级" + reward.min_level;
				}
			}
			if (this.needDay > 0)
			{
				if (condition == '')
				{
					condition+="需再连续登录" + this.needDay + "天";
				}
				else
				{
					condition+=" 需再连续登录" + this.needDay + "天";
				}
			}
			if (reward.need_vip_level > VipModule.getInstance().getRoleVipLevel())
			{
				if (condition == '')
				{
					condition+="需要VIP等级" + reward.need_vip_level;
				}
				else
				{
					condition+=" 需要VIP等级" + reward.need_vip_level;
				}
			}
			if (condition == '')
			{
				var buyCountText:TextField=ComponentUtil.createTextField("输入购买数量：", 0, 33, Style.themeTextFormat, 150, 22, sp);
				numStep=new NumericStepper();
				numStep.x=94;
				numStep.y=31;
				numStep.textFiled.restrict="0-9";
				numStep.textFiled.maxChars=4;
				numStep.maxnum=reward.num;
				numStep.minnum=1;
				numStep.stepSize=1;
				numStep.textFiled.textField.defaultTextFormat=new TextFormat("", 12, 0xffffff);
				numStep.value=numStep.maxnum;
				numStep.width=40;
				sp.addChild(numStep);
				remainNumText=ComponentUtil.createTextField("/" + reward.num, 136, 33, null, 60, 22, sp);
				buyButton=ComponentUtil.createButton("购买", 163, 31, 60, 25, sp);
				buyButton.addEventListener(MouseEvent.CLICK, onBuyClick);
				if (this.showFetch)
				{
				}
				else
				{
					numStep.enable=false;
					buyButton.enabled=false;
					buyButton.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
					buyButton.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
				}
			}
			else
			{
				var tf:TextFormat=Style.textFormat;
				tf.color=0xFF0000;
				conditionText=ComponentUtil.createTextField(condition, 0, 15, tf, 236, 22, sp);
				conditionText.mouseEnabled=true;
				conditionText.selectable=true;
			}
			return sp;
		}

		/**
		 * 购买奖励
		 */
		private function onBuyClick(event:MouseEvent):void
		{
			// 先判断玩家的钱或者银子是否足够
			var num:int=this.numStep.value;
			var needSilver:int=num * this.reward.silver;
			if (needSilver > GlobalObjectManager.getInstance().user.attr.silver_bind && needSilver > GlobalObjectManager.getInstance().user.attr.silver)
			{
				Tips.getInstance().addTipsMsg("银两不足");
				return;
			}
			var needGold:int=num * this.reward.gold;
			if (needGold > GlobalObjectManager.getInstance().user.attr.gold_bind && needGold > GlobalObjectManager.getInstance().user.attr.gold)
			{
				Tips.getInstance().addTipsMsg("元宝不足");
				return;
			}
			var vo:m_conlogin_fetch_tos=new m_conlogin_fetch_tos;
			vo.id=this.reward.id;
			vo.num=num;
			ConloginModule.getInstance().send(vo);
		}

		private function openPayURL(e:Event):void
		{
			JSUtil.openPaySite();
		}

		private function initGetView():Sprite
		{
			var sp:Sprite=new Sprite;
			var tf:TextFormat=Style.textFormat;
			var descText:TextField=ComponentUtil.createTextField("免费获得 " + reward.num + " 个", 0, 0, tf, 150, 22, sp);
			descText.mouseEnabled=true;
			descText.selectable=true;
			var payText:TextField;
			var condition:String=new String();
			if (reward.need_payed && !GlobalObjectManager.getInstance().user.attr.is_payed)
			{
				condition="需要已充值";
				// 显示充值链接
				payText=ComponentUtil.createTextField("", 0, 40, null, 100, 22);
				payText.htmlText="<font color='#00FF00'><a href='event:openPay;'><u>我要充值</u></a></font>";
				payText.mouseEnabled=true;
				payText.selectable=true;
				payText.addEventListener(MouseEvent.CLICK, openPayURL);
				sp.addChild(payText);
			}
			if (reward.min_level > GlobalObjectManager.getInstance().user.attr.level)
			{
				if (condition == '')
				{
					condition+="需要等级" + reward.min_level;
				}
				else
				{
					condition+=" 需要等级" + reward.min_level;
				}
			}
			if (this.needDay > 0)
			{
				if (condition == '')
				{
					condition+="需再连续登录" + this.needDay + "天";
				}
				else
				{
					condition+=" 需再连续登录" + this.needDay + "天";
				}
			}
			if (reward.need_vip_level > VipModule.getInstance().getRoleVipLevel())
			{
				if (condition == '')
				{
					condition+="需要VIP等级" + reward.need_vip_level;
				}
				else
				{
					condition+=" 需要VIP等级" + reward.need_vip_level;
				}

				var x:int;
				if (!payText)
				{
					x=0;
				}
				else
				{
					x=70;
				}

				var vipText:TextField=ComponentUtil.createTextField("", x, 40, null, 100, 22);
				vipText.htmlText="<font color='#00FF00'><a href='event:openVip;'><u>成为VIP" + reward.need_vip_level + "</u></a></font>";
				vipText.mouseEnabled=true;
				vipText.selectable=true;
				vipText.addEventListener(MouseEvent.CLICK, openVip);
				sp.addChild(vipText);
			}
			if (condition == '')
			{
				var getButton:Button=ComponentUtil.createButton("领取", 163, 31, 60, 25, sp);
				getButton.addEventListener(MouseEvent.CLICK, onGetClick);
				if (!this.showFetch)
				{
					getButton.enabled=false;
					getButton.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
					getButton.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
				}
			}
			else
			{
				var tf2:TextFormat=Style.textFormat;
				tf2.color=0xFF0000;
				conditionText=ComponentUtil.createTextField(condition, 0, 20, tf2, 236, 22, sp);
				conditionText.mouseEnabled=true;
				conditionText.selectable=true;
			}
			return sp;
		}

		private function openVip(e:Event):void
		{
			VipModule.getInstance().onOpenVipPannel();
		}

		private function onMouseOver(e:Event):void
		{
			ToolTipManager.getInstance().show("登录天数还未达到领奖条件", 0);
		}

		private function onMouseOut(e:Event):void
		{
			ToolTipManager.getInstance().hide();
		}

		/**
		 * 免费领取奖励
		 */
		private function onGetClick(event:MouseEvent):void
		{
			var vo:m_conlogin_fetch_tos=new m_conlogin_fetch_tos;
			vo.id=this.reward.id;
			ActivityModule.getInstance().send(vo);
		}

		private function initView():void
		{
			var itemVO:BaseItemVO=ItemLocator.getInstance().getObject(data.type_id);
			goodsItem.setImageContent(itemVO, itemVO.path);
			goodsItem.data=itemVO;

			if (this.reward.gold > 0 || this.reward.silver > 0)
			{
				view=initBuyView();
			}
			else
			{
				view=initGetView();
			}
			if (view)
			{
				view.x=79;
				view.y=34;
				addChild(view);
			}
		}
	}
}


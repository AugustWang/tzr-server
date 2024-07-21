package modules.deal.views
{
	import com.components.components.DragUIComponent;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.managers.WindowManager;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.NumericStepper;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Keyboard;
	
	import modules.ModuleCommand;
	import modules.deal.NpcDealModule;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.views.GoodsImage;
	import modules.mypackage.vo.BaseItemVO;
	
	import proto.line.m_family_collect_get_role_info_toc;

	public class NpcDealBatchView extends DragUIComponent
	{
		private var _dealItemObj:Object;
		private var _data:Object;
		private var image:GoodsImage;
		private var imageBox:UIComponent;
		private var exchangeBut:Button;
		private var numTxf:TextField;
		private var nameTxf:TextField;
		private var numStep:NumericStepper;//max 100;
		private var limitLabe:TextField;
		private static var instance:NpcDealBatchView;
		public function NpcDealBatchView()
		{
			
		}
		public static function getInstance():NpcDealBatchView{
			if(instance==null){
				instance=new NpcDealBatchView();
			}
			return instance;
		}
		private function upView():void{
			width = 223;
			height = 109;
			Style.setRectBorder(this);
			var tf:TextFormat = Style.textFormat;
			tf.leading=4;
			tf.color=0xffffff;
			tf.align = TextFormatAlign.LEFT;
			   if(!nameTxf){
				   
				nameTxf = ComponentUtil.createTextField("",8,6,tf,175,23,this);
				nameTxf.filters=[Style.BLACK_FILTER];
				nameTxf.htmlText=_dealItemObj.title;
			   }else{
				   nameTxf.htmlText=_dealItemObj.title;
			   }
			   if(!numTxf){
				numTxf = ComponentUtil.createTextField("", 47, 45, null, 28, 20, this);
				numTxf.htmlText = "<font color='#F6F5CD'>数量</font>";
			   }else{
				   numTxf.htmlText = "<font color='#F6F5CD'>数量</font>";
			   }
			   if(!numStep){
				numStep = new NumericStepper();
				numStep.x = 75;
				numStep.y = 43;
				numStep.textFiled.restrict = "0-9";
				numStep.textFiled.maxChars=4;
				numStep.maxnum = 100;
				numStep.minnum = 1;
				numStep.stepSize = 1;
				numStep.textFiled.textField.defaultTextFormat = new TextFormat("Tahoma",12,0xffffff);
				numStep.value = 1;
				numStep.width = 60;
				addChild(numStep);
			   }else{
				   numStep.value=1;
			   }
			
			
				imageBox=new UIComponent();
				addChild(imageBox);
				imageBox.width=imageBox.height=36;
				imageBox.x=10;
				imageBox.y=35;
				imageBox.addEventListener(MouseEvent.ROLL_OVER,onRollOverHandler);
				imageBox.addEventListener(MouseEvent.ROLL_OUT,onRollOutHandler);
				var box:Sprite = Style.getSpriteBitmap(GameConfig.T1_VIEWUI,"packItemBg");;
				box.mouseEnabled=false;
				var baseItemVO:BaseItemVO=ItemLocator.getInstance().getObject(_dealItemObj.imgId);
				image=new GoodsImage();
				box.addChild(image);
				imageBox.data=baseItemVO;
				image.x=2;
				image.y=2;
				image.setImageContent(baseItemVO, baseItemVO.path);
				imageBox.addChild(box);
				

			if(!exchangeBut){
				exchangeBut = ComponentUtil.createButton("兑换" ,160,75,52,25,this)
				Style.setRedBtnStyle(exchangeBut);
			}
			
			if(int(_dealItemObj.limitNum)!=0)
			{
				NpcDealModule.getInstance().getattrvaluebyID(_dealItemObj.imgId,reflimit,null);
			}
			else
			{
				if(limitLabe)
					limitLabe.visible = false;
				exchangeBut.visible = true;
			}			
		}
		
		public function reflimit(vo:m_family_collect_get_role_info_toc):void
		{
			if(!limitLabe)
				limitLabe = ComponentUtil.createTextField("", 10, 75, null, 152, 20, this);
			limitLabe.visible = true;
			var allnum:int = _dealItemObj.limitNum;
			var usenum:int = vo.value;
			if(usenum==allnum)
				exchangeBut.visible = false;
			limitLabe.htmlText = "<font color='#F6F5CD'>限量版："+usenum.toString()+"/"+allnum.toString()+"</font>";
			
		}
		
		private function upEventListener():void{
			numStep.addEventListener(Event.CHANGE,onNumChange);
			numStep.addEventListener(KeyboardEvent.KEY_DOWN,onExchangeDown);
			exchangeBut.addEventListener(MouseEvent.CLICK,onExchangeClick);
			
		}
		private function onNumChange(event:Event):void{
			_dealItemObj.num = numStep.value;
			
		}
		
		private function onExchangeDown(event:KeyboardEvent):void{
			if(event.charCode == Keyboard.ENTER){
				exchangeGoods();
			}
		}
		private function onExchangeClick(e:MouseEvent):void{
			exchangeGoods();
			
		}
		private function exchangeGoods():void{
			if(_dealItemObj!=null){
				Dispatch.dispatch(ModuleCommand.EXCHANGE_NPC_DEAL, _dealItemObj);
				closeView();
			}
		}
		override public function set data(vo:Object):void{
			_dealItemObj=vo;
			_dealItemObj.num=1;
			upView();
			upEventListener();
			if(x == 0 && y == 0 && this.parent != null){
				x = (parent.width - width)/2;
				y = (parent.height - height)/2;
			}
			this.showCloseButton = true;
		}
		override protected function onCloseHandler(event:MouseEvent):void{
			closeView();
		}
		
		public function showView():void{
			WindowManager.getInstance().popUpWindow(this, WindowManager.UNREMOVE);
			this.x = this.stage.mouseX -this.width+97;
			this.y = this.stage.mouseY -this.height+55;
			this.numStep.textFiled.setFocus();
			this.numStep.maxnum = _dealItemObj.MaxChangeNum;		
			this.numStep.textFiled.textField.setSelection(0,this.numStep.textFiled.textField.text.length);
		}
		
		public function closeView():void{
			if(!this.parent){
				return;
			}else{
				this.parent.removeChild(this);
				WindowManager.getInstance().removeWindow(this);	
			}
		}
		private function onRollOverHandler(evt:MouseEvent):void{
			var cur_ui:UIComponent = evt.currentTarget as UIComponent;
			var baseItemVo:BaseItemVO = cur_ui.data as BaseItemVO;
			if(baseItemVo){
				ToolTipManager.getInstance().show(baseItemVo,500,0,0,"targetToolTip");
			}
		}
		private function onRollOutHandler(evt:MouseEvent):void{
			ToolTipManager.getInstance().hide();
		}
	}
}
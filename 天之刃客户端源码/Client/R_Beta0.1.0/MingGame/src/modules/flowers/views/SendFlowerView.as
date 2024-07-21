package modules.flowers.views
{
	import com.common.GlobalObjectManager;
	import com.components.menuItems.TargetRoleInfo;
	import com.globals.GameConfig;
	import com.loaders.SourceLoader;
	import com.ming.events.CloseEvent;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.ComboBox;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.ButtonSkin;
	import com.ming.ui.skins.PanelSkin;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.flowers.FlowerModule;
	import modules.flowers.FlowersTypes;
	
	public class SendFlowerView extends Sprite
	{
		public static var flowerBg_URL:String ="com/assets/flowers/flowers.swf"; 
		
		private var flowerURL:String;
		private var closeBtn:UIComponent ;       // 关闭按钮；
		private var sendToNameTf:TextField; //赠予 name 
		private var sendTypeTf:TextField;   //请选择你送花的类型
		
		private var combobox:ComboBox;
		private var sendBtn:Button;         // 立即行动
		
		private var to_role_id:int;         //要送给的人的 id
		private var to_role_name:String;    //送给的人
		private var to_role_sex:int;    //送给的人 的性别.
		private var _num:int; 
		
		private var is_niMing:Boolean;      //是否匿名
		private var flowerTypes:int;        // goodsid ;
		private var flowerNums:int;                //花的个数，
		
		
		private var dataPro:Array;
		private var nimingArr:Array;     // 全部出现的
		private var allArr:Array;        //只出现匿名的 
		public function SendFlowerView()
		{
			super();
		}
		
		public function initView(loader:SourceLoader):void
		{
			var bmdt:BitmapData = loader.getBitmapData("flowerBg");
			var bg:Bitmap = new Bitmap(bmdt);
			
			addChildAt(bg,0);
			
			var closeBtn:UIComponent = new UIComponent();
			closeBtn.x = 293;
			closeBtn.y = 92;
			closeBtn.bgSkin = getButtonSkin("closeSkin","closeOverSkin","closeDownSkin", loader);
			closeBtn.useHandCursor = closeBtn.buttonMode = true;
			closeBtn.addEventListener(MouseEvent.CLICK,closeHandler);
			addChild(closeBtn);
			
			var tf:TextFormat = new TextFormat("宋体",18,0xfff800,true,null,null,null,null,"center");
			//"Tahoma"  Style.textFormat;   //113;90;
			sendToNameTf = ComponentUtil.createTextField("赠予 ",80,134,tf,250,28,this);
			sendToNameTf.selectable =false;
			
			var tf_type:TextFormat = new TextFormat("宋体",16,0xfff800,true,null,null,null,null,"center");
			sendTypeTf = ComponentUtil.createTextField("请选择你送花的类型",86,
				sendToNameTf.y + 35,tf_type,254,26,this);
			sendTypeTf.selectable =false;
			
			
			var filterArr:Array=new Array();
			var myGlowFilter:GlowFilter = new GlowFilter(0x000000, 1, 2, 2, 8, 1, false, false);
			filterArr.push(myGlowFilter);
			sendToNameTf.filters = filterArr; 
			sendTypeTf.filters = filterArr;
			
			combobox = new ComboBox();
			combobox.labelField = "label";
			combobox.x = 152;
			combobox.y = 200;
			combobox.width = 120;
			combobox.height = 23;
			combobox.maxListHeight = 315;
			combobox.addEventListener(Event.CHANGE,onLabelChange);
			addChild(combobox);
			
			sendBtn = ComponentUtil.createButton("立即行动",165,242,NaN,NaN,this);
			var sendBtnSkin:ButtonSkin = getButtonSkin("flowerSkin","flowerOverSkin","flowerDownSkin",loader);
			sendBtnSkin.rect = new Rectangle(4,5,40,10);
			sendBtn.bgSkin = sendBtnSkin
			
			sendBtn.addEventListener(MouseEvent.ROLL_OVER, onShowTips);
			sendBtn.addEventListener(MouseEvent.ROLL_OUT, onHideTips);
			sendBtn.addEventListener(MouseEvent.CLICK, sendFlowerToServer);
			
		}
		
		private function onShowTips(e:MouseEvent):void
		{
			ToolTipManager.getInstance().show(FlowersTypes.SEND_BTN_TOOLTIP);
		}
		private function onHideTips(e:MouseEvent):void
		{
			ToolTipManager.getInstance().hide();
		}
		
		private function onLabelChange(e:Event):void
		{
		}
		
		public function sendFlower(roleVo:TargetRoleInfo,num:int=0):void  // roleVo:Object
		{
			to_role_id = roleVo.roleId;
			to_role_name = roleVo.roleName;
			to_role_sex = roleVo.sex;
			_num = num;
			
			if(sendToNameTf)
				sendToNameTf.text = "赠予 " + roleVo.roleName ;
			if(combobox)
				setComboboxData(roleVo.sex,num);
		}
		
		private function setComboboxData(sex:int,num:int = 0):void
		{
			var selfSex:int = GlobalObjectManager.getInstance().user.base.sex;
			if(sex != selfSex) //selfSex==1 && 
			{
				is_niMing = false;
				
			}else{
				
				is_niMing = true;
			}
			dataPro = FlowersTypes.sendTypeArr(!is_niMing,num);
			combobox.dataProvider = dataPro;
			combobox.selectedIndex = 0;
			combobox.validateNow();
			
		}
		
		//签名送花1朵
		//签名送花9朵
		//签名送花99朵
		//签名送花999朵
		
		//匿名送花1朵  
		//匿名送花9朵
		//匿名送花99朵
		//匿名送花999朵
		
		
		// 1朵玫瑰 9朵玫瑰 99朵玫瑰 999朵玫瑰 9朵玫瑰     99朵蓝色妖姬  999朵蓝色妖姬
		public function sendUseGoods(roleVo:TargetRoleInfo,num:int):void  
		{
			flowerTypes = FlowersTypes.getTypeByNum(num);
			sendFlower(roleVo,num);
			
		}
		private function sendFlowerToServer(e:MouseEvent):void
		{
			var index:int = combobox.selectedIndex;
			flowerNums = dataPro[index].num;
			flowerTypes = FlowersTypes.getTypeByNum(flowerNums);
			
			if(!is_niMing)
			{
				if(dataPro.length==2)
				{
					if(index==1)
						is_niMing = true;
				}else if(dataPro.length==8)
				{
					if(index>3)
						is_niMing = true;
				}
				
			}
			FlowerModule.getInstance().send_tos(to_role_id,is_niMing,flowerTypes);
		}
		
		private function getButtonSkin(skin:String,overSkin:String,downSkin:String,loader:SourceLoader):ButtonSkin
		{
			var btnSkin:ButtonSkin = new ButtonSkin();
			btnSkin.skin = loader.getBitmapData(skin);
			btnSkin.overSkin = loader.getBitmapData(overSkin);
			btnSkin.downSkin = loader.getBitmapData(downSkin);
			
			return btnSkin;
		}
		
		private function closeHandler(e:MouseEvent):void
		{
//			if(this.parent)
//				this.parent.removeChild(this);
			this.dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
//			if(this.parent)
//				LayerManager.remove(this);
		}
		
		public function dispose():void
		{
			if(sendBtn)
				sendBtn.removeEventListener(MouseEvent.CLICK, sendFlowerToServer);
			
			if(this.numChildren>0)
			{
				for(var i:int=0;i<numChildren;i++)
				{
					var obj:DisplayObject = this.getChildAt(i) as DisplayObject;
					removeChild(obj);
					obj = null;
				}
			}
		}
		
	}
}





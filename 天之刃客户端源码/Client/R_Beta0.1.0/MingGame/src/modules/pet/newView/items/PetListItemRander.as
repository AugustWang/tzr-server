package modules.pet.newView.items {
	import com.globals.GameConfig;
	import com.ming.core.IDataRenderer;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.ProgressBar;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	import modules.mypackage.ItemConstant;
	import modules.pet.PetDataManager;
	
	import proto.common.p_pet;
	import proto.common.p_pet_id_name;

	public class PetListItemRander extends UIComponent implements IDataRenderer{
		private var iconBg:Bitmap;
		private var nameTF:TextField;
		private var expBar:ProgressBar;
		public function PetListItemRander() {
			initView();
		}
		
		private function initView():void{
			iconBg = Style.getBitmap(GameConfig.T1_VIEWUI,"packItemBg");
			iconBg.x = iconBg.y = 4;
			addChild(iconBg);
			
			nameTF = ComponentUtil.createTextField("",46,3,null,100,25,this);
			nameTF.filters = Style.textBlackFilter;
			
			expBar=new ProgressBar();
			expBar.bgSkin=Style.getSkin("expBarBg", GameConfig.T1_UI,new Rectangle(5,5,108,4));
			expBar.bar=Style.getBitmap(GameConfig.T1_UI, "expBar");
			expBar.padding=3;
			expBar.x=45	;
			expBar.y=26;
			expBar.width=114;
			expBar.height=12;
			expBar.value=0.5;
			expBar.htmlText="50%";
			addChild(expBar);
			expBar.addEventListener(MouseEvent.ROLL_OVER,showTips);
			expBar.addEventListener(MouseEvent.ROLL_OUT,hideTips);
		}
		
		private function showTips(event:MouseEvent):void{
			ToolTipManager.getInstance().show(_tips);
		}
		
		private function hideTips(event:MouseEvent):void{
			ToolTipManager.getInstance().hide();
		}
		
		private var info:p_pet_id_name;
		private var _tips:String="";
		override public function set data(value:Object):void{
			info = value as p_pet_id_name;
			nameTF.htmlText=HtmlUtil.font(info.name,ItemConstant.COLOR_VALUES[info.color]);
			expBar.value = info.exp/info.next_level_exp;
			expBar.htmlText = int(info.exp/info.next_level_exp*100)+"%";
			_tips = "经验："+info.exp+"/"+info.next_level_exp;
		}
		
		override public function get data():Object{
			return info;
		}
	}
}
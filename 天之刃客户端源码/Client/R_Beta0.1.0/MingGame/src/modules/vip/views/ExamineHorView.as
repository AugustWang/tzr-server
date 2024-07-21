package modules.vip.views
{
	import com.components.BasePanel;
	import com.loaders.CommonLocator;
	import com.ming.events.CloseEvent;
	import com.ming.managers.ToolTipManager;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.vo.BaseItemVO;
	
	public class ExamineHorView extends BasePanel
	{
		//存放各个奖励的容器
		private var parentSprite:Sprite;
		
		private var isTip:Boolean = false;
		
		public function ExamineHorView()
		{
			super();
			initUI();
			initData();
		}
		
		private function initUI():void
		{
			this.width=300;
			this.height=325;
			this.title="查看奖励";
			this.titleAlign=2;
			
			addContentBG(8);
			
			parentSprite = new Sprite();
			parentSprite.x = 20;
			parentSprite.y = 13;
			addChild(parentSprite);
			
			
		}
		
		private function onShowTip(e:MouseEvent):void
		{
			if( e.currentTarget is HorSprite )
			{
				var target:HorSprite=e.currentTarget as HorSprite;
				var baseItemVo:BaseItemVO=ItemLocator.getInstance().getObject(int(target.typeId));
				if( baseItemVo != null)
				{
					ToolTipManager.getInstance().show(baseItemVo, 0, 0, 0, "targetToolTip");
				}
			}
		}
		
		private function onCloseTip(e:MouseEvent):void
		{
			ToolTipManager.getInstance().hide();
		}
		
		public function initData():void
		{
			var data:XML = CommonLocator.getXML(CommonLocator.HORTATION);
			var length:int = data.data.length();
			var horSprite:HorSprite;
			for(var i:int=0; i<length; i++)
			{
				var o:Object = new Object();
				o.day = data.data[i].@day;
				o.bind = data.data[i].@bind;
				o.typeId = data.data[i].@typeId;
				o.num = data.data[i].@num;
				horSprite = new HorSprite();
				horSprite.Data = o;
				
				var row:int=i / 2;
				var column:int=i % 2;
				horSprite.x=column * 130 + column * 2;
				horSprite.y=row * 50 + row * 2;
				parentSprite.addChild(horSprite);
				horSprite.addEventListener(MouseEvent.ROLL_OVER, onShowTip, true);
				horSprite.addEventListener(MouseEvent.ROLL_OUT, onCloseTip, true);
			}
		}
	}
}
import com.globals.GameConfig;
import com.ming.ui.controls.Image;
import com.ming.ui.controls.Text;
import com.ming.ui.style.StyleManager;
import com.utils.ComponentUtil;

import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.filters.GlowFilter;
import flash.text.TextField;
import flash.text.TextFormat;

import modules.mypackage.managers.ItemLocator;
import modules.mypackage.views.GoodsImage;

class HorSprite extends Sprite
{
	
	//连续登录的天数
	private var continueDay:TextField;
	//奖励的物品
	private var horGoods:Image;
	
	public var typeId:String;
	
	public function HorSprite()
	{
		initUI();
	}
	
	public function initUI():void
	{
		var bg:Shape = new Shape();
		bg.graphics.lineStyle(1,0xFFFF00);
		bg.graphics.beginFill(0x000000,0.5);
		bg.graphics.drawRoundRect(0,0,130,50,6,6);
		bg.graphics.endFill();
		addChild(bg);
				
		continueDay = new TextField();
		continueDay.x = 6;
		continueDay.y = 16;
		continueDay.text = "连续登录xxx天";
		continueDay.selectable = false;
		addChild(continueDay);
		
		var itemBg:Sprite = Style.getSpriteBitmap(GameConfig.T1_VIEWUI,"packItemBg");;
		itemBg.width = itemBg.height = 36;
		itemBg.x = 85;
		itemBg.y = 9;
		addChild(itemBg);
		horGoods = new Image();
		horGoods.x = 4;
		horGoods.y = 4;
		itemBg.addChild(horGoods);
	}
	
	public function set Data(data:Object):void
	{
		typeId = data.typeId;
		
		var day:String = data.day;
		continueDay.htmlText = "<font color='#F8F8FF'>连续登录"+day+"天</font>";
		var imageURL:String=ItemLocator.getInstance().getObject(int(data.typeId)).path;
		horGoods.source = imageURL;
		createCountLabel(data.num, horGoods);
	}
	
	private function createCountLabel(num:String, parent:Sprite):void {
		var tf:TextFormat=StyleManager.textFormat;
		tf.size=11;
		var countlb:TextField=ComponentUtil.createTextField("", 0, 18, tf, 33, NaN, parent);
		countlb.text=num
		countlb.filters=[new GlowFilter(0x000000)];
		countlb.selectable=false;
		countlb.autoSize="right";
	}
}
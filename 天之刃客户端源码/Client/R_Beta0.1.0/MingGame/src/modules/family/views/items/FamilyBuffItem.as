package modules.family.views.items
{
	import com.globals.GameConfig;
	import com.ming.core.IDataRenderer;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Image;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class FamilyBuffItem extends Sprite implements IDataRenderer
	{
//		public static var BUFF_PATH:String = 'com/assets/buffIcon/';
		public static var BUFF_PATH:String = GameConfig.ROOT_URL+'com/assets/buffIcon/';
		private var _data:Object;
		private var img:Image;
		private var itemNameTxt:TextField;
		private var needTxt:TextField; 
		
		private var itemName:String = "";
		
		public function FamilyBuffItem()
		{
			super();
			
			var bg:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"packItemBg");;
			bg.x = 10;
			bg.y =1;
			bg.scaleX = bg.scaleY = 0.73;
			addChild(bg);
			
			img = new Image();
			img.x = 13;
			img.y = 4;
			img.addEventListener(MouseEvent.MOUSE_OVER, onOver);
			img.addEventListener(MouseEvent.MOUSE_OUT, onOut);
			addChild(img)
			
			var tf:TextFormat = new TextFormat("Tahoma",12,0xF6F5CD);//new TextFormat(); Style.textFormat
			itemNameTxt = ComponentUtil.createTextField("",40,5,tf,100,25,this);
			needTxt = ComponentUtil.createTextField("",140,5,tf,140,25,this);
			
			
		}
		private function onOver(e:MouseEvent):void
		{
			//（1级）同时提升内外攻击力XX点，持续60分钟。
			if(data && data.desc)
				ToolTipManager.getInstance().show(data.desc,100);//,120,0,0,"goodsToolTip");
			
			
		}
		private function onOut(e:MouseEvent):void
		{
			ToolTipManager.getInstance().hide();
		}
		
		public function set data(value:Object):void
		{
			if(value)
			{
				_data = value;
				showItemView();
			}
			// p_fml_buff   public var fml_buff_id:int = 0;public var level:int = 0;
			////obj.name;	obj.url ; obj.id ; obj.level ;  obj.familyLv ;  obj.cost = buff.@cost; obj.desc = buff.@desc;
		}
		public function get data():Object
		{
			
			return _data;
		}
		
		private function showItemView():void
		{
			img.source = BUFF_PATH + data.url;
			itemNameTxt.text = data.name + "("+data.level +"级)";
			needTxt.text ="门派贡献度："+data.cost +"点";
			
		}
		
	}
}
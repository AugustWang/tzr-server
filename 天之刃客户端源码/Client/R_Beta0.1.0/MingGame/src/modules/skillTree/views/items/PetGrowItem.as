package modules.skillTree.views.items
{

	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.Skin;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	import com.utils.MoneyTransformUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.broadcast.views.Tips;
	import modules.pet.PetModule;
	import modules.skill.SkillConstant;
	
	import proto.common.p_grow_info;
	
	public class PetGrowItem extends UIComponent
	{
		private var _select:Boolean = false;
		public  var content:Image;
		public var levelTxt:TextField;
		private var selectBg:Bitmap;
		
		public var growType:int;
		
		public var pvo:p_grow_info;
		
		private var isLearn:Boolean=false;//为学习技能接收参数。
		public function PetGrowItem(type:int)
		{
			super();
			growType = type;
			this.buttonMode = true;
			this.height = this.width = 32;
			//this.mouseEnabled=true;
			addEventListener(MouseEvent.CLICK,mouseClickHandler);
			
			selectBg = Style.getBitmap(GameConfig.T1_VIEWUI,"skillBorder");
			selectBg.x = -4;
			selectBg.y = -4;
			selectBg.width = 44;
			selectBg.height = 44;
			selectBg.visible = false;
			//selectBg.mouseChildren = false;
			//selectBg.mouseEnabled = false;
			content = new Image();
			content.x = 2;
			content.y = 2;
			content.filters = [];
			addChild(content);
			addChild(selectBg);
			levelTxt = new TextField();
			levelTxt.autoSize = TextFieldAutoSize.CENTER;
			levelTxt.defaultTextFormat = new TextFormat("Tahoma",12,0xFFFFFF);
			levelTxt.filters = Style.textBlackFilter;
			levelTxt.x = 26;
			levelTxt.y = 19;
			levelTxt.text = "0";
			levelTxt.mouseEnabled = false;
			levelTxt.selectable = false;
			addChild(levelTxt);
			
			setPetGrowItemXY(growType);
			
		}
		
		
		public function setPetGrowItemXY(type:int):void
		{
			switch(type)
			{
				case SkillConstant.PET_GROW_SKILL_CON:
					this.x=23;
					this.y=145;
					this.content.source = GameConfig.ROOT_URL + "com/assets/items/generals/shu/05127" + ".png";
					break;
				case SkillConstant.PET_GROW_SKILL_PHY_DEFENCE:
					this.x=139;
					this.y=109;
					this.content.source = GameConfig.ROOT_URL + "com/assets/items/generals/shu/05112" + ".png";
					break;
				case SkillConstant.PET_GROW_SKILL_MAGIC_DEFENCE:
					this.x=139;
					this.y=180;
					this.content.source = GameConfig.ROOT_URL + "com/assets/items/generals/shu/05109" + ".png";
					break;
				case SkillConstant.PET_GROW_SKILL_PHY_ATTACK:
					this.x=258;
					this.y=109;
					this.content.source = GameConfig.ROOT_URL + "com/assets/items/generals/shu/05103" + ".png";
					break;
				case SkillConstant.PET_GROW_SKILL_MAGIC_ATTACK:
					this.x=258;
					this.y=180;
					this.content.source = GameConfig.ROOT_URL + "com/assets/items/generals/shu/05130" + ".png";
					break;
			}
		}
		
		private function mouseClickHandler(e:MouseEvent):void{
			
			var dataEvent:DataEvent = new DataEvent(SkillConstant.EVENT_PET_GROW_ITEM_CLICK,true);
			dataEvent.data = growType.toString();
			dispatchEvent(dataEvent);
		}
		

		public function set select( value:Boolean ):void{
			if( _select == value )return;
			_select = value;
			if(_select){
				selectBg.visible = true;
				
			}else{
				selectBg.visible = false;
			}
			
		}
		
		public function set growInfo(value:p_grow_info):void{
			pvo = value;
			levelTxt.text = (pvo.level-1).toString();
			/*
			if(pvo.need_level >= GlobalObjectManager.getInstance().user.attr.level)
			{
				content.filters = [PetModule.filter];
			}
			else
			{
				content.filters = [];
			}*/
		}
		
		public function get growInfo():p_grow_info{
			return pvo;
		}
		
		public function set learnFlag(value:Boolean):void
		{
		   isLearn=value;
			if(value == true)
				content.filters = [];
			else
				content.filters = [PetModule.filter];
		 }
		public function get learnFlag():Boolean{
			return isLearn;
		}
	  }
}
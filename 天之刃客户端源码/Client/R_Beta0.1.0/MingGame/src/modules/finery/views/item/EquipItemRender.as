package modules.finery.views.item
{
	import com.events.ParamEvent;
	import com.globals.GameConfig;
	import com.ming.core.IDataRenderer;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	
	import modules.finery.FineryModule;
	import modules.finery.views.StovePanel;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.views.GoodsImage;
	import modules.mypackage.views.ItemToolTip;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	
	public class EquipItemRender extends UIComponent
	{
		private var nameTxt:TextField;
		private var numTxt:TextField;
		private var box:Sprite;
		private var type:String;
		
		public function EquipItemRender()
		{
			super();
			
			this.width = 120;
			this.height = 48;
			Style.setListBgSkin(this);
			
			box = Style.getSpriteBitmap(GameConfig.T1_VIEWUI,"packItemBg");;
			this.addChild(box);
			box.x = 2;
			box.y = 5;
			
			nameTxt = ComponentUtil.createTextField("",box.x + box.width + 2,box.y,null,75,25,this);
			nameTxt.htmlText = "XXOO";
			numTxt = ComponentUtil.createTextField("",box.x + box.width + 2,nameTxt.y + nameTxt.textHeight + 2,null,100,45,this);
			
			box.addEventListener(MouseEvent.ROLL_OVER,onBoxRollOverHandler);
			box.addEventListener(MouseEvent.ROLL_OUT,onBoxRollOutHandler);
			this.addEventListener(MouseEvent.CLICK,onMouseClickHandler);
			this.addEventListener(MouseEvent.ROLL_OVER,onMouseOverHandler);
			this.addEventListener(MouseEvent.ROLL_OUT,onMouseOutHandler);
		}
		
		private function onMouseOverHandler(event:MouseEvent):void{
			if(!_select){
				filters = [new GlowFilter(0xFBCF22,0.5,12,12,2,1,true)];
			}
		}
		
		private function onMouseOutHandler(event:MouseEvent):void{
			if(!_select){
				filters = [];
			}
		}
		
		private function onBoxRollOverHandler(evt:MouseEvent):void{
			if(data){
				var point:Point = new Point(this.x,this.y);
				point = this.parent.localToGlobal(point);
				ItemToolTip.show(BaseItemVO(data),point.x + 45,point.y + 20,false);
			}
		}
		
		private function onBoxRollOutHandler(evt:MouseEvent):void{
			ItemToolTip.hide();
		}
		
		private function onMouseClickHandler(evt:MouseEvent):void{
			var event:ParamEvent = new ParamEvent("EQUIP_ITEM_CLICK",data,true);
			dispatchEvent(event);
			select(true);
		}
		
		private var _select:Boolean
		public function select(value:Boolean):void{
			if(_select == value){
				return;
			}
			_select = value;
			if(_select){
				filters = [new GlowFilter(0xFBCF22,0.9,6,6,2,1,true)];//#5CEAE7 FBCF22 #00EBF8
			}else{
				filters = [];
			}
		}
		
		override public function get data():Object{
			return super.data;
		}
		
		override public function set data(value:Object):void{
			super.data = value;
			var image:GoodsImage = new GoodsImage();
			box.addChild(image);
			image.x = 4;
			image.y = 4;
			image.setImageContent(BaseItemVO(data),data.path);
			var colorValue:String = ItemConstant.COLOR_VALUES[BaseItemVO(data).color];
			switch(FineryModule.getInstance().getCurrentIndex()){
				case StovePanel.TABNAME_ARRAY.EQUIP_PUNCH:
					if(EquipVO(data).punch_num == 0){
						nameTxt.htmlText = "<font color='"+colorValue+"'>"+EquipVO(data).name+"</font>";
						numTxt.htmlText = "0/6 孔";
					}else{
						nameTxt.htmlText = "<font color='"+colorValue+"'>"+EquipVO(data).name+"</font>";
						numTxt.htmlText = EquipVO(data).punch_num+"/6 孔";
					}
					break;
				case StovePanel.TABNAME_ARRAY.STONE_INLAY:
					nameTxt.htmlText = "<font color='"+colorValue+"'>"+EquipVO(data).name+"</font>";
					numTxt.htmlText = EquipVO(data).stone_num+"石 "+EquipVO(data).punch_num+"孔";
					break;
				case StovePanel.TABNAME_ARRAY.STONE_SPLIT:
					nameTxt.htmlText = "<font color='"+colorValue+"'>"+EquipVO(data).name+"</font>";
					numTxt.htmlText = EquipVO(data).stone_num+"石";
					break;
				case StovePanel.TABNAME_ARRAY.EQUIP_BIND:
					if(EquipVO(data).bind){
						nameTxt.htmlText = "<font color='"+colorValue+"'>"+EquipVO(data).name+"</font>";
						numTxt.htmlText = "绑定";
					}else{
						nameTxt.htmlText = "<font color='"+colorValue+"'>"+EquipVO(data).name+"</font>";
						numTxt.htmlText = "未绑定";
					}
					break;
				case StovePanel.TABNAME_ARRAY.EQUIP_REINFORCE:
					if(EquipVO(data).reinforce_result != 0){
						var starts:String=String(EquipVO(data).reinforce_result % 10);
						var startsLvl:String=String(EquipVO(data).reinforce_result).charAt(0);
						nameTxt.htmlText = "<font color='"+colorValue+"'>"+EquipVO(data).name+"</font>";
						numTxt.htmlText = startsLvl+"级 "+starts+"星";
					}else{
						nameTxt.htmlText = "<font color='"+colorValue+"'>"+EquipVO(data).name+"</font>";
						numTxt.htmlText = "0级 0星";
					}
					break;
				case StovePanel.TABNAME_ARRAY.EQUIP_EXALT:
					nameTxt.htmlText = "<font color='"+colorValue+"'>"+EquipVO(data).name+"</font>";
					break;
				default:
					nameTxt.htmlText = "<font color='"+colorValue+"'>"+EquipVO(data).name+"</font>";
					break;
			}
		}
	}
}
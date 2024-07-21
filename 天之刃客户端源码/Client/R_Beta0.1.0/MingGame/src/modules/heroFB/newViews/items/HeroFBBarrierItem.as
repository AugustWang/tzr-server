package modules.heroFB.newViews.items
{
	import com.globals.GameConfig;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.core.UIComponent;
	import com.scene.sceneUnit.baseUnit.things.common.NumberImage;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.family.views.CreateFamilyPanel;
	import modules.heroFB.HeroFBDataManager;
	import modules.heroFB.HeroFBModule;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.views.ToolTipContainer;
	import modules.mypackage.vo.BaseItemVO;
	
	import proto.common.p_hero_fb_barrier;

	public class HeroFBBarrierItem extends UIComponent
	{
		private var bg:Bitmap;
		private var suo:Bitmap;
		private var state:int;
		private var nameTF:TextField;
		private var indexShape:Shape;
		private var starItem:StarItem;
		private var id:int;
		private var stateInfo:p_hero_fb_barrier;
		public function HeroFBBarrierItem(){
			super();
			this.width = 70;
			this.height = 70;
		}
		
		public function initView():void{
			bg=Style.getBitmap(GameConfig.HERO_FB,"barrierBg");
			addChild(bg);
			var ctf:TextFormat = new TextFormat();
			ctf.align = TextFormatAlign.CENTER;
			nameTF=ComponentUtil.createTextField("",0,24,ctf,70,25,this);
			starItem = new StarItem();
			starItem.y = 50;
			starItem.x = -4;
			addChild(starItem);
			addEventListener(MouseEvent.ROLL_OVER,onRollOverHandler);
			addEventListener(MouseEvent.ROLL_OUT, onRollOutHandler);
			addEventListener(MouseEvent.CLICK, onMouseClickHandler);
		}
		
		private function onRollOverHandler(event:MouseEvent):void{
			var p:Point = new Point(x+44,y);
			p = parent.localToGlobal(p);
			ToolTipManager.getInstance().show(crateToolTip(),0,p.x,p.y);
		}
		
		private function onRollOutHandler(event:MouseEvent):void{
			ToolTipManager.getInstance().hide();
		}
		
		private function onMouseClickHandler(event:MouseEvent):void{
			HeroFBModule.getInstance().heroFBEnter(id);
		}
		
		private function crateToolTip():String{
			var html:String = "";
			html += HtmlUtil.fontBr(data.@barrierStr,"#FFFFFF");
			for(var i:int=0; i<data.reward.item.length(); i++){
				if(data.reward.item[i].@type == "1"){
					html += HtmlUtil.fontBr("声望值："+data.reward.item[i].@value,"#FFFFFF");
				}else if(data.reward.item[i].@type == "2"){
					var equipStr:String = data.reward.item[i].@value;
					var equip:Array = equipStr.split(",");
					var itemVO:BaseItemVO = ItemLocator.getInstance().getObject(int(equip[0]));
					html += HtmlUtil.fontBr(HtmlUtil.font("掉落：","#FFFFFF")+itemVO.name,ItemConstant.COLOR_VALUES[equip[1]]);
				}
			}
			if(stateInfo){
				html += HtmlUtil.fontBr("剩余次数："+stateInfo.fight_times,"#FFFFFF");
				html += HtmlUtil.fontBr("（每天9：00，12：00，19：00，24：00刷新）","#FFFFFF");
				
				html += HtmlUtil.fontBr("本关得分："+stateInfo.score,"#FFFFFF");
				html += HtmlUtil.fontBr("星级评分："+stateInfo.star_level,"#FFFFFF");
				html += HtmlUtil.fontBr("服务器排名："+stateInfo.order,"#FFFFFF");
			}
			return html
		}
		
		private var _data:XML;
		override public function set data(value:Object):void{
			_data=value as XML;
			//nameTF.htmlText = HtmlUtil.font(value.@barrierStr,"#FFFFFF",12);
			indexShape = NumberImage.getInstance().toOnlyNum(value.@barrierId,"104");
//			trace(value.@barrierId);
			id = value.@id;
			stateInfo = HeroFBDataManager.getInstance().getBarrierStateById(id);
			if(stateInfo){
				starItem.update(stateInfo.star_level,5);
			}
		}
		
		override public function get data():Object{
			return _data;
		}
		
		private var _enable:Boolean;
		public function set enable(value:Boolean):void{
			_enable = value;
			if(value){
				if(suo && suo.parent){
					suo.parent.removeChild(suo);
				}
				if(indexShape){
					addChild(indexShape);
					indexShape.y = (bg.height - indexShape.height)>>1;
					indexShape.x = (bg.width - indexShape.width)>>1;
				}
//				bg.bitmapData=Style.getBitmap(GameConfig.HERO_FB,"barrier_open").bitmapData;
//				bg.x = (this.width - bg.width)*0.5 + 3;
				starItem.visible = true;
				starItem.x = (this.bg.width-starItem.width)*0.5;
				buttonMode=true;
			}else{
				if(!suo){
					suo = Style.getBitmap(GameConfig.HERO_FB,"suo");
					addChild(suo);
					suo.x = 10;
					suo.y = 7;
				}
				if(indexShape && indexShape.parent){
					indexShape.parent.removeChild(indexShape);
				}
//				bg.bitmapData=Style.getBitmap(GameConfig.HERO_FB,"suo").bitmapData;
//				bg.x = (this.width - bg.width)*0.5 + 3;
				starItem.visible = false;
				buttonMode=false;
				nameTF.htmlText = "";
			}
			mouseEnabled = value;
		}
		
		public function get enable():Boolean{
			return _enable;
		}
	}
}
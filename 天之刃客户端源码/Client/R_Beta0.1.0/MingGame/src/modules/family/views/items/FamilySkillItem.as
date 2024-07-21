package modules.family.views.items
{
	import com.common.GlobalObjectManager;
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.DragItemManager;
	import com.globals.GameConfig;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Image;
	import com.ming.utils.ScaleBitmap;
	import com.utils.MoneyTransformUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.family.FamilyLocator;
	import modules.family.FamilySkillModule;
	import modules.skill.SkillConstant;
	import modules.skill.vo.ConditionVO;
	import modules.skill.vo.SkillLevelVO;
	
	public class FamilySkillItem extends Sprite
	{
		public static const INFO:String = "info";
		public static const RESREACH:String = "resreach";
		public static const LEARN:String = "learn";
		public static const TREE:String = "tree";
		
		public static const CLICK_EVENT:String = "clickEvent";
		
		private var status:String = "";
		private var _img:Image;
		private var _infoName:TextField;
		private var _resreachNameLeft:TextField;
		private var _resreachNameRight:TextField;
		private var _jiantou:Sprite;
		private var _xml:XML;
		private var matrix:Array = [ 0.5,0.5,0.082,0,-50,
			0.5,0.5,0.082,0,-50,
			0.5,0.5,0.082,0,-50,
			0,0,0,1,0 ];
		private var colorMat:ColorMatrixFilter = new ColorMatrixFilter(matrix);
		private var needSilver:Number;
		private var needPoint:Number;
		public var selectbg:Bitmap;
		public var scaleBitmap:ScaleBitmap;
		public var overBg:Bitmap;
		public function FamilySkillItem()
		{
			super();
		}
		
		public function initView($status:String = "info",selectName:String = "skillBorder",selectbgWidth:Number = 60,selectbgHeight:Number = 59):void{
			status = $status;
			this.buttonMode = this.useHandCursor = true;
			addChild(Style.getBitmap(GameConfig.T1_VIEWUI,"borderItemBg"));
			
			_img = new Image();
			_img.x = 15;
			_img.y = 15;
			addChild(_img);
			var htmlFormat:TextFormat = new TextFormat("宋体",14);
			htmlFormat.leading = 3;
			switch( $status ){
				case INFO:
				case TREE:
					var back:Sprite = Style.getBlackSprite(56,20);
					back.mouseChildren = back.mouseEnabled = false;
					back.x = 1;
					back.y = 66;
					addChild(back);
					_infoName = new TextField();
					_infoName.width = 56;
					_infoName.height = 25;
					_infoName.defaultTextFormat = new TextFormat(null,null,0xFFF673);
					_infoName.x = 3;
					_infoName.y = 68;
					addChild(_infoName);
					addEventListener(MouseEvent.ROLL_OVER,onRollOver);
					addEventListener(MouseEvent.ROLL_OUT, onRollOut);
					if( TREE ){
						addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
						addEventListener(MouseEvent.CLICK,onClick);
					}
					selectbg = Style.getBitmap(GameConfig.T1_VIEWUI,selectName);;
					selectbg.width = selectbgWidth;
					selectbg.height = selectbgHeight;
					selectbg.visible = false;
					this.addChild(selectbg);
					break;
				case RESREACH:
				case LEARN:
					this.y = -4;
					graphics.beginFill(0x000000,0);
					graphics.drawRect(0,0,524,58);
					graphics.endFill();
					var bgViewLeft:Bitmap = new Bitmap(Style.getUIBitmapData(GameConfig.T1_VIEWUI, "itemBg"));
					bgViewLeft.width = 142;
					bgViewLeft.height = 58;
					bgViewLeft.x = 65;
					addChild(bgViewLeft);
					var bgViewRight:Bitmap = new Bitmap(Style.getUIBitmapData(GameConfig.T1_VIEWUI, "itemBg"));
					bgViewRight.width = 252;
					bgViewRight.height = 58;
					bgViewRight.x = 272;
					addChild(bgViewRight);
					_jiantou = Style.getViewBg("jiantou");
					_jiantou.visible = false;
					_jiantou.x = 208;
					_jiantou.y = 10;
					addChild(_jiantou);
					_resreachNameLeft = new TextField();
					_resreachNameLeft.defaultTextFormat = htmlFormat;
					_resreachNameLeft.wordWrap = true;
					_resreachNameLeft.selectable = false;
					_resreachNameLeft.x = 67;
					_resreachNameLeft.y = 2;
					_resreachNameLeft.width = 142;
					_resreachNameLeft.height = 58;
					addChild(_resreachNameLeft);
					_resreachNameRight = new TextField();
					_resreachNameRight.defaultTextFormat = htmlFormat;
					_resreachNameRight.wordWrap = true;
					_resreachNameRight.selectable = false;
					_resreachNameRight.x = 274;
					_resreachNameRight.y = 2;
					_resreachNameRight.width = 252;
					_resreachNameRight.height = 58;
					addChild(_resreachNameRight);
					addEventListener(MouseEvent.CLICK,onClick);
					
					var bigmapdata:BitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,selectName);
					scaleBitmap = new ScaleBitmap(bigmapdata);
					scaleBitmap.setScale9Grid(new Rectangle(10,10,bigmapdata.width - 2*10,bigmapdata.height - 2*10));
					scaleBitmap.setSize(selectbgWidth,selectbgHeight);
					scaleBitmap.y = -3;
					scaleBitmap.visible = false;
					this.addChild(scaleBitmap);
					
					overBg = Style.getBitmap(GameConfig.T1_VIEWUI,"family_kuang");
					this.addChild(overBg);
					overBg.visible = false;
					overBg.width = 525;
					overBg.height = 65;
					overBg.y = -3;
					break;
			}
		}
		
		private function onMouseDown(event:MouseEvent):void{
			if(data.attack_type != 2){
				doDrag()
			}
		}
		
		private function doDrag():void{
			if(data.level > 0)
			{
				DragItemManager.instance.startDragItem(_img,this._img,DragConstant.SKILL_ITEM,data,DragItemManager.CLONE,false);
			}
		}
		
		private function onClick(event:MouseEvent):void{
			switch( status ){
				case INFO:
					break;
				case TREE:
					var dataEvent:DataEvent = new DataEvent(SkillConstant.EVENT_SKILL_ITEM_CLICK,true);
					dataEvent.data = data.sid;
					dispatchEvent(dataEvent);
					break;
				case LEARN:
					if( data.fml_level > 0 && !selected )dispatchEvent(new Event(CLICK_EVENT));
					break;
				case RESREACH:
					if( !selected )dispatchEvent(new Event(CLICK_EVENT));
					break;
			}
		}
		
		private function onRollOver(event:MouseEvent):void{
			ToolTipManager.getInstance().show(tooltip,100);
		}
		
		private function onRollOut(event:MouseEvent):void{
			ToolTipManager.getInstance().hide();
		}
		
		private var _data:Object;
		public function set data(obj:Object):void{
			_data = obj;
			_xml = FamilySkillModule.getInstance().getResreachData(data.sid);
			_img.source = obj.path;
			switch( status ){
				case INFO:
					_infoName.text = obj.name;
					break;
				case RESREACH:
					_resreachNameLeft.htmlText = "<font color='#ffffff'>"+ obj.name +"</font>\n<font color='#00ff00'>等级（"+obj.fml_level+"级）</font>" ;
					selectedChange();
					break;
				case LEARN:
					_resreachNameLeft.htmlText = "<font color='#ffffff'>"+ obj.name +"</font>\n<font color='#00ff00'>等级（"+obj.level+"级）</font>" ;
					selectedChange();
					break;
				case TREE:
					_infoName.text = obj.name;
					selectedChange();
					break;
			}
		}
		
		public function get data():Object{
			return _data;
		}
		
		public function get tooltip():String{
			var s:String = "";
			switch( status ){
				case INFO:
					s += "【"+ data.name +"】\n"
					for( var i:int = 0; i < data.levels.length; i++ ){
						var item:SkillLevelVO = data.levels[i];
						s += "（" +(i+1)+"级）" + item.discription +'\n';
					}
					break;
				case TREE:
					s = createHtml();
					break;
			}
			return s;
		}
		
		private function createHtml():String{
			var s:String = '';
			s = s.concat("<font color='#FFFFFF'size='14'><b>" + data.name + "</b></font>\n");
			s = s.concat("<font color='#FFFFFF'>等级:"+data.level+"/"+data.max_level+"</font>\n");
			if(data.category == SkillConstant.CATEGORY_LIFE){
				s = s.concat("<font color='#f2c802'>"+data.levels[data.level - 1].discription+"</font>\n\n");
				return s;
			}
			if(data.is_common_phy == 1){
				s = s.concat("<font color='#FFFFFF'>攻击距离:"+data.distance+"</font>\n");
			}else{
				if(data.effect_type ==1){
					s = s.concat("<font color='#FFFFFF'>释放距离:自身</font>\n");
				}else{
					s = s.concat("<font color='#FFFFFF'>释放距离:"+data.distance+"</font>\n");
				}
			}
			if(data.level > 0)
			{
				if(data.attack_type != 2){
					s = s.concat("<font color='#FFFFFF'>冷却时间:"+data.levels[data.level - 1].cooldown * 0.001+"秒</font>\n");
					s = s.concat("<font color='#FFFFFF'>消耗内力:"+data.levels[data.level - 1].consume_mp+"点</font>\n");
				}
				s = s.concat("<font color='#f2c802'>"+data.levels[data.level - 1].discription.toString().replace('\n','')+"</font>\n");
			}
			if(data.level < data.levels.length)
			{
				s = s.concat("\n<font color='#FFFFFF'>下一等级:</font>\n");
				if(data.attack_type != 2){
					s = s.concat("<font color='#FFFFFF'>冷却时间:"+data.levels[data.level].cooldown * 0.001+"秒</font>\n");
					s = s.concat("<font color='#FFFFFF'>消耗内力:"+data.levels[data.level].consume_mp+"点</font>\n");
				}
				s = s.concat("<font color='#f2c802'>"+data.levels[data.level].discription+"</font>\n\n");
			}
			return s
		}
		
		private var _selected:Boolean = false;
		public function set selected(value:Boolean):void{
			if( _selected != value ){
				_selected = value;
				selectedChange();
			}
		}
		
		private function selectedChange():void{
			switch( status ){
				case INFO:
				case TREE:
					if( data.level > 0 ){
						_img.filters = [];
					}else{
						_img.filters = [colorMat];
					}
					break;
				case RESREACH:
					if( _selected ){
						var rightTxt:String = "<textformat leading='6'>";
						if( data.fml_level >= data.max_level ){
							rightTxt = "<font color='#ffffff'>"+ data.name +"</font><font color='#00ff00'>等级（"+(Math.min(data.fml_level + 1,data.max_level))+"级）</font>";
							rightTxt += "\n<font color='#ff0000>该技能已经升至顶级！</font>";
						}else{
							rightTxt = "<font color='#ffffff'>"+ data.name +"</font><font color='#00ff00'>等级（"+(Math.min(data.fml_level + 1,data.max_level))+"级）</font>";
							var conditions:XMLList = _xml.level[data.fml_level].condition;
							for( var i:int = 0; i < conditions.length(); i++ ){
								var conditionItem:XML = conditions[i]
								switch( conditionItem.@name.toString() ){
									case "money":
										if( FamilyLocator.getInstance().getMoney() >= int(conditionItem.@data) ){
											rightTxt += "\n<font color='#00ff00'>需要：门派资金"+ MoneyTransformUtil.silverToOtherString(int(conditionItem.@data)) +"</font>";
										}else{
											rightTxt += "\n<font color='#ff0000'>需要：门派资金"+ MoneyTransformUtil.silverToOtherString(int(conditionItem.@data)) +"</font>";
										}
										break;
									case "prosperity":
										if( FamilyLocator.getInstance().familyInfo.active_points >= int(conditionItem.@data) ){
											rightTxt += "\n<font color='#00ff00'>需要：门派繁荣度"+ int(conditionItem.@data) +"点</font>";
										}else{
											rightTxt += "\n<font color='#ff0000'>需要：门派繁荣度"+ int(conditionItem.@data) +"点</font>";
										}
										break;
								}
							}
						}
						_resreachNameRight.htmlText = rightTxt + "</textformat>"
						_jiantou.visible = selected;
					}else{
						_resreachNameRight.htmlText = "<font color='#ffffff'>"+ data.name +"</font>"
						_jiantou.visible = selected;
					}
					break;
				case LEARN:
					if( data.fml_level == 0 ){
						_img.filters = [colorMat];
						_resreachNameRight.htmlText = "<font color='#ffffff'>"+ data.name +"</font>";
						_jiantou.visible = false;
					}else if( data.max_level > data.level){
						_img.filters = [];
						rightTxt =  "<textformat leading='6'>";
						if( selected ){
							rightTxt = "<font color='#ffffff'>"+ data.name +"</font><font color='#00ff00'>等级（"+(Math.min(data.level + 1,data.max_level))+"级）</font>";
							var cons:Array = data.levels[data.level].conditions
							for( var j:int = 0; j < cons.length; j++ ){
								var condition:ConditionVO = cons[j];
								switch( condition.name ){
									case "need_silver":
										needSilver = int(condition.data);
										if((GlobalObjectManager.getInstance().user.attr.silver + GlobalObjectManager.getInstance().user.attr.silver_bind) >= int(condition.data)){
											rightTxt += "\n<font color='#00ff00'>需要：个人银两"+ MoneyTransformUtil.silverToOtherString(int(condition.data)) +"</font>";
										}else{
											rightTxt += "\n<font color='#ff0000'>需要：个人银两"+ MoneyTransformUtil.silverToOtherString(int(condition.data)) +"</font>";
										}
										break;
									case "pre_point":
										needPoint = int(condition.data);
										if(GlobalObjectManager.getInstance().user.attr.family_contribute >= int(condition.data) ){
											rightTxt += "\n<font color='#00ff00'>需要：个人门派贡献点"+ int(condition.data) +"</font>";
										}else{
											rightTxt += "\n<font color='#ff0000'>需要：个人门派贡献点"+ int(condition.data) +"</font>";
										}
										break;
								}
							}
						}else{
							rightTxt = "<font color='#ffffff'>"+ data.name +"</font>";
						}
						_resreachNameRight.htmlText = rightTxt +  "</textformat>";;
						_jiantou.visible = selected;
					}else{
						_img.filters = [];
						if( selected ){
							_resreachNameRight.htmlText = "<font color='#ffffff'>"+ data.name +"</font>\n<font color='#ff0000>该技能已经升至顶级！</font>";
						}else{
							_resreachNameRight.htmlText = "<font color='#ffffff'>"+ data.name +"</font>";
						}
						_jiantou.visible = selected;
					}
					break;
			}
		}
		
		public function get selected():Boolean{
			return _selected
		}
		
		public function get reseachTip():String{
			var s:String = "研究门派技能【"+data.name+"】到"+(data.fml_level+1)+"级，将扣取";
			var conditions:XMLList = _xml.level[data.fml_level].condition;
			for( var i:int = 0; i < conditions.length(); i++ ){
				var conditionItem:XML = conditions[i]
				switch( conditionItem.@name.toString() ){
					case "money":
						s += "门派资金" + MoneyTransformUtil.silverToOtherString(int(conditionItem.@data));
						break;
					case "prosperity":
						s += "、门派繁荣度" + int(conditionItem.@data) + "点";
						break;
				}
			}
			s += "，你确定要研究该技能吗？";
			return s;
		}
		
		public function get forgetTip():String{
			var s:String = "遗忘门派技能【"+data.name+"】需要扣取门派资金"+ MoneyTransformUtil.silverToOtherString(int(_xml.level[data.fml_level - 1].@forgetMoney)) +"，并且所有帮众已学的该技能将被清零！你确定遗忘该门派技能吗？";
			return s;
		}
		
		public function get learnTip():String{
			var s:String = "学习门派技能【"+data.name+"】需要消耗个人银两"+MoneyTransformUtil.silverToOtherString(needSilver)+"、个人门派贡献度"+needPoint+"点，你确定要学习该技能吗？";
			return s;
		}
		
		public function get personalTip():String{
			var s:String;
			var cons:Array = data.levels[data.level - 1].conditions
			for( var i:int = 0; i < cons.length; i++ ){
				var condition:ConditionVO = cons[i];
				if( condition.name == "need_silver" ){
					s  = "遗忘门派技能【"+data.name+"】需要消耗银"+MoneyTransformUtil.silverToOtherString(int(condition.data))+"，你确定要遗忘该技能吗？";
				}
			}
			return s;
		}
	}
}
package modules.skillTree.views.items
{
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.DragItemManager;
	import com.globals.GameConfig;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.core.UIComponent;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneUnit.baseUnit.things.effect.Effect;
	import com.scene.sceneUnit.baseUnit.things.thing.Thing;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.skill.SkillConstant;
	import modules.skill.SkillMethods;
	import modules.skill.vo.SkillVO;
	import modules.skillTree.views.SkillPanel;
	
	public class SkillItem extends UIComponent
	{
		private var _skillVO:SkillVO;
		private var _state:int = -1;
		private var _select:Boolean = false;
		private var _selectThing:Thing;
		private var content:Image;
		private var levelTxt:TextField;
		private var selectBg:Bitmap;
		private var addImage:Bitmap;
		private var matrix:Array = [ 0.5,0.5,0.082,0,-50,
					0.5,0.5,0.082,0,-50,
					0.5,0.5,0.082,0,-50,
					0,0,0,1,0 ];
		private var grayMatrix:ColorMatrixFilter = new ColorMatrixFilter(matrix);
		
		public function SkillItem()
		{
			super();
			this.buttonMode = true;
			this.doubleClickEnabled = true;
			this.height = this.width = 32;
			this.addEventListener(MouseEvent.MOUSE_DOWN,mouseDownHandler);
			this.addEventListener(MouseEvent.CLICK,mouseClickHandler);
			this.addEventListener(MouseEvent.DOUBLE_CLICK,mouseDoubleClickHandler);
		}
		
		public function set skillVO($skillVO:SkillVO):void{
			_skillVO = $skillVO;
			if(_skillVO){
				selectBg = Style.getBitmap(GameConfig.T1_VIEWUI,"skillBorder");
				selectBg.x = -4;
				selectBg.y = -4;
				selectBg.width = 44;
				selectBg.height = 44;
				selectBg.visible = false;
				addImage = Style.getBitmap(GameConfig.T1_VIEWUI,"skillAdd");
				addImage.x = 2;
				addImage.y = 2;
				addImage.width = 11;
				addImage.height = 11;
				addImage.visible = false;
				content = new Image();
				content.doubleClickEnabled = true;
				content.source = _skillVO.path;
				content.x = 2;
				content.y = 2;
				addChild(content);
				addChild(selectBg);
				addChild(addImage);
				levelTxt = new TextField();
				levelTxt.autoSize = TextFieldAutoSize.CENTER;
				levelTxt.defaultTextFormat = new TextFormat("Tahoma",12,0xFFFFFF);
				levelTxt.filters = Style.textBlackFilter;
				levelTxt.x = 26;
				levelTxt.y = 19;
				levelTxt.text = _skillVO.level.toString();
				levelTxt.mouseEnabled = false;
				levelTxt.selectable = false;
				addChild(levelTxt);
				addEventListener(MouseEvent.ROLL_OVER,onRollOver);
				check();
				SkillPanel.items[skillVO.sid] = this;
			}
		}
		
		public function get skillVO():SkillVO{
			return _skillVO;
		}
		
		private function mouseDownHandler(e:MouseEvent):void{
			if(skillVO.attack_type != 2){
				doDrag()
			}
		}
		
		private function doDrag():void{
			if(skillVO.level > 0)
			{
				DragItemManager.instance.startDragItem(content,this,DragConstant.SKILL_ITEM,skillVO,DragItemManager.CLONE,false);
			}
		}
		
		private var rollFlag:Boolean = false;
		private function onRollOver(event:MouseEvent):void{
			rollFlag = true;
			addEventListener(MouseEvent.ROLL_OUT,onRollOut);
			createToolTip();
		}
		
		private function createToolTip():void{
			var p:Point = new Point(x+44,y);
			p = parent.localToGlobal(p);
			ToolTipManager.getInstance().show(SkillMethods.createTreeTip(skillVO),0,p.x,p.y,SkillConstant.SKILL_TREE_TIP);
		}
		
		private function onRollOut(event:MouseEvent):void{
			rollFlag = false;
			removeEventListener(MouseEvent.ROLL_OUT,onRollOut);
			ToolTipManager.getInstance().hide();
		}
		
		private var clickEnable:Boolean = true;
		private function mouseDoubleClickHandler(e:MouseEvent):void{
			if(clickEnable){
				clickEnable = false;
				LoopManager.setTimeout(function fun():void{clickEnable = true},500);
			}else{
				return;
			}
			check();
			switch( state ){
				case SkillConstant.CONDITION_MAXLEVEL:showError("该技能已经达到最高级！");break;
				case SkillConstant.CONDITION_DIS_ROLE_LEVEL:showError("等级不够！");break;
				case SkillConstant.CONDITION_DIS_PRE_SKILL:showError("前置技能等级不够！");break;
				case SkillConstant.CONDITION_DIS_NEED_ITEM:showError("缺少技能书！");break;
				case SkillConstant.CONDITION_DIS_NEED_SILVER:showError("银子不足！");break;
				case SkillConstant.CONDITION_DIS_EXP:showError("经验不足！");break;
				case SkillConstant.CONDITION_ACCORD:
					var dataEvent:DataEvent = new DataEvent(SkillConstant.EVENT_SKILL_UPGRADE,true);
					dataEvent.data = skillVO.sid.toString();
					dispatchEvent(dataEvent);
					break;
			}
		}
		
		private function mouseClickHandler(e:MouseEvent):void{
			var dataEvent:DataEvent = new DataEvent(SkillConstant.EVENT_SKILL_ITEM_CLICK,true);
			dataEvent.data = skillVO.sid.toString();
			dispatchEvent(dataEvent);
		}
		
		private function showError(msg:String):void{
			Tips.getInstance().addTipsMsg(msg)
			BroadcastSelf.getInstance().appendMsg(msg)
			return;
		}
		
		private function set state(value:int):void{
			if(_state == value)return;
			_state = value;
			if(_state == SkillConstant.CONDITION_ACCORD){
				addImage.visible = true;
				if(_select){
					if(_selectThing == null){
						_selectThing = new Thing();
						_selectThing.load(GameConfig.OTHER_PATH + 'skillSelect.swf');
						_selectThing.x = -13;
						_selectThing.y = -13;
					}
					addChild(_selectThing);
					_selectThing.play(5,true);
				}
				content.filters = [];
				levelTxt.textColor = 0x00FF00;
			}else{
				addImage.visible = false;
				if(_selectThing != null){
					_selectThing.stop();
					if(_selectThing.parent)removeChild(_selectThing);
				}
				if( _state == SkillConstant.CONDITION_MAXLEVEL ){
					levelTxt.textColor = 0xe7ba00;
					addImage.visible = false;
					return;
				}
				if( skillVO.level == 0 ){
					if(SkillMethods.checkLevel(skillVO.sid)){
						content.filters = [];
					}else{
						content.filters = [grayMatrix];
					}
				}else{
					content.filters = [];
				}
				levelTxt.textColor = 0xFFFFFF;
			}
		}
		
		private function get state():int{
			return _state;
		}
		
		public function showUpLevel():void{
			if(_select && _selectThing)_selectThing.visible = false;
			var up:Effect = new Effect();
			up.endFunction = upShowEnd;
			up.show(GameConfig.OTHER_PATH + 'skillSelectUp.swf',-18,-18,this,5);
		}
		
		public function upShowEnd():void{
			if(_select && _selectThing)_selectThing.visible = true;
		}
		
		public function set select( value:Boolean ):void{
			if( _select == value )return;
			_select = value;
			if(_select){
				selectBg.visible = true;
				if(state == SkillConstant.CONDITION_ACCORD){
					if(_selectThing==null){
						_selectThing = new Thing();
						_selectThing.load(GameConfig.OTHER_PATH + 'skillSelect.swf');
						_selectThing.x = -13;
						_selectThing.y = -13;
					}
					addChild(_selectThing);
					_selectThing.play(5,true);
				}
			}else{
				selectBg.visible = false;
				if(_selectThing){
					_selectThing.stop();
					if(_selectThing.parent)removeChild(_selectThing);
				}
			}
		}
		
		public function check():void{
			state = SkillMethods.checkLearnState(skillVO.sid);
		}
		
		public function updata():void{
			if(levelTxt == null)return;
			levelTxt.text = _skillVO.level.toString();
			if(rollFlag)createToolTip();
		}
	}
}
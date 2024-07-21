package modules.roleStateG.views.changeHair
{
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.events.ParamEvent;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.CheckBox;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.Slider;
	import com.ming.ui.controls.core.UIComponent;
	import com.scene.sceneUnit.baseUnit.things.avatar.Avatar;
	import com.scene.sceneUnit.baseUnit.things.avatar.AvatarConstant;
	import com.scene.sceneUnit.baseUnit.things.heartbeat.ThingFrameFrequency;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.mypackage.managers.PackManager;
	
	import proto.common.p_skin;
	import proto.line.m_role2_hair_tos;
	
	public class HairView extends Sprite
	{
		public static const CHANGE_HAIR_EVENT:String="CHANGE_HAIR_EVENT";
		private var manHairNames:Array=["清新俊逸", "温文尔雅", "雅人深致", "蜂迷蝶猜", "玉树临风", "惊才风逸","铁血硬汉","器宇不凡"];
		private var womanHairNames:Array=["清纯可人", "明艳动人", "楚楚动人", "清丽脱俗", "玉洁冰清", "丽质天成","英姿飒爽","飞阁流丹"];
		private var hairColors:Array=[0xD0FF00, 0xFFFF00, 0x9E9700, 0xFF6700, 0xFE3106, 0xFE0000, 0x790000, 0xBC004F, 0x9B006A, 0xFF00FF, 0xFF65FF, 0x8703F6, 0x3F009D, 0x99989E, 0x989BFD, 0x2DFF9A, 0x00FFFF, 0x00BE4B, 0x03FD03, 0x009D00, 0x006B00, 0x003434, 0x009997, 0x0993FF, 0x0000FA, 0x000380, 0x000000];
		private var faceImgs:Array=[]; //放脸
		private var colorImgs:Array=[]; //放色块
		private var commitBtn:Button;
		private var cancelBtn:Button;
		private var bareheaded:CheckBox;
		private var useDefaultColor:Button;
		
		
		private var avatar:Avatar;
		private var skin:p_skin;
		private var _selectedHair:int;
		private var _selectedColor:String="000000";
		private var hairCard:TextField;
		private var hairCardNum:int;
		
		public function HairView()
		{
			super();
			initView();
		}
		
		private function initView():void
		{
			////////////搞上面一排
			var sex:int=GlobalObjectManager.getInstance().user.base.sex;
			var url:String;
			var hair:String;
			if (sex == 1)
			{
				url=GameConfig.ROOT_URL + "com/assets/changeHair/hair/man";
			}
			else
			{
				url=GameConfig.ROOT_URL + "com/assets/changeHair/hair/woman";
			}
			var tf:TextFormat=new TextFormat(null, null, 0xECE8BB, null, null, null, null, null, "center");
			for (var i:int=1; i <=8; i++)
			{
				var img:Image=createImage(url + i + ".jpg", 2 + 66 * (i-1), 6, this);
				img.name=i + "";
				img.addEventListener(MouseEvent.CLICK, onClickFace);
				faceImgs.push(img);
				sex == 1 ? ComponentUtil.createTextField(manHairNames[i-1], img.x, (img.y + 84), tf, 65, 22, this) : ComponentUtil.createTextField(womanHairNames[i-1], img.x, (img.y + 84), tf, 65, 22, this);
			}
			////////////搞AVATAR 
			var di_url:String=GameConfig.ROOT_URL + "com/assets/changeHair/hair/di.jpg";
			createImage(di_url, 4, 108, this);
			avatar=new Avatar;
			avatar.x=96;
			avatar.y=266;
			addChild(avatar);
			var leftup:UIComponent=new UIComponent();
			leftup.useHandCursor=leftup.buttonMode=true;
			leftup.x=38;
			leftup.y=250;
			leftup.bgSkin=Style.getButtonSkin("right", "", "", null, GameConfig.T1_VIEWUI);
			leftup.addEventListener(MouseEvent.CLICK, turnLeft);
			addChild(leftup);
			var rightup:UIComponent=new UIComponent();
			rightup.useHandCursor=rightup.buttonMode=true;
			rightup.x=140;
			rightup.y=250;
			rightup.bgSkin=Style.getButtonSkin("left", "", "", null, GameConfig.T1_VIEWUI);
			rightup.addEventListener(MouseEvent.CLICK, turnRight);
			addChild(rightup);
			//////////////////搞颜色选择
			var colorBg:UIComponent=ComponentUtil.createUIComponent(194, 108, 336, 172);
			Style.setBorder1Skin(colorBg);
			addChild(colorBg);
			var tf2:TextFormat=new TextFormat(null, 16, 0xECE8BB, true, null, null, null, null, "center");
			ComponentUtil.createTextField("颜色调整", 0, 2, tf2, 318, 30, colorBg);
			for (i=0; i < hairColors.length; i++)
			{
				var shape:Sprite=new Sprite;
				shape.buttonMode=true;
				shape.name=i + "";
				shape.graphics.beginFill(hairColors[i]);
				shape.graphics.drawRect(0, 0, 32, 32);
				shape.graphics.endFill();
				shape.x=12 + 35 * (i % 9);
				shape.y=30 + 34 * int(i / 9);
				shape.addEventListener(MouseEvent.CLICK, onClickColors);
				colorBg.addChild(shape);
				colorImgs.push(shape);
			}
			var useDefaultBtn:Button=ComponentUtil.createButton("使用默认颜色", 6, 142, 100, 25, colorBg);
			useDefaultBtn.addEventListener(MouseEvent.CLICK, onClickDefaultColor);
			var costTF:TextField=ComponentUtil.createTextField("", 120, 146, null, 120, 22, colorBg); //更换费用：<font color=''>1锭
			costTF.htmlText=HtmlUtil.font("更换费用：", "#AFE0EE") + HtmlUtil.font("1锭银子", "#ECE8BB");
			
			hairCard = ComponentUtil.createTextField("", 260, 146, null, 200, 22, colorBg);
			
			///////////搞确认按钮
			var bg4:UIComponent=ComponentUtil.createUIComponent(194, 280, 336, 30);
			Style.setBorder1Skin(bg4);
			addChild(bg4);
			bareheaded=new CheckBox;
			bareheaded.textFormat=new TextFormat(null, null, 0xECE8BB);
			bareheaded.text="选择光头";
			bareheaded.addEventListener(Event.CHANGE, onClickBarehead);
			bareheaded.x=4;
			bareheaded.y=4;
			bg4.addChild(bareheaded);
			
			commitBtn=ComponentUtil.createButton("确定", 166, 2, 60, 25, bg4);
			commitBtn.addEventListener(MouseEvent.CLICK, onCommit);
			cancelBtn=ComponentUtil.createButton("取消", 252, 2, 60, 25, bg4);
			cancelBtn.addEventListener(MouseEvent.CLICK, onCancel);
		}
		
		//打开界面时重置一下
		public function reset():void
		{
			skin=GlobalObjectManager.getInstance().user.attr.skin;
			skin.mounts=0;
			avatar.initSkin(skin);
			avatar.scaleX=avatar.scaleY=1.2;
			avatar.play(AvatarConstant.ACTION_STAND, 4, ThingFrameFrequency.STAND);
			_selectedHair=skin.hair_type;
			_selectedColor=skin.hair_color;
			for (var i:int=0; i < faceImgs.length; i++)
			{
				var img:Image=faceImgs[i];
				img.filters=null;
				img.mouseEnabled=_selectedHair>0;
			}
			for (i=0; i < colorImgs.length; i++)
			{
				var s:Sprite=colorImgs[i];
				s.filters=null;
				s.mouseEnabled=_selectedHair>0;
			}
			if (_selectedHair > 0 && _selectedHair <= 8)
			{
				var imgSelected:Image=this.getChildByName(_selectedHair+"") as Image;
				if(imgSelected!=null){
					imgSelected.filters=[new GlowFilter(0xAFE0EE, 1, 8, 8, 6, 1, true)];
				}
				bareheaded.selected=false;
			}
			else
			{
				bareheaded.selected=true;
			}
			var colorIndex:int=hairColors.indexOf(uint("0x" + _selectedColor));
			if (colorIndex != -1&&_selectedHair>0)
			{
				colorImgs[colorIndex].filters=[new GlowFilter(0xAFE0EE, 1, 8, 8, 6, 1, true)];
			}
			
			resetHairCardNum();
		}
		
		private function resetHairCardNum():void
		{
			hairCardNum = PackManager.getInstance().getGoodsNumByTypeId(10100024);
			if (hairCardNum > 0) {
				hairCard.htmlText=HtmlUtil.font("发型卡 x "+hairCardNum, "#AFE0EE");
				hairCard.visible = true;
			} else {
				hairCard.visible = false;
			}
		}
		
		public function reduceHairCardNum():void
		{
			hairCardNum --;
			if (hairCardNum > 0) {
				hairCard.htmlText=HtmlUtil.font("发型卡 x "+hairCardNum, "#AFE0EE");
				hairCard.visible = true;
			} else {
				hairCard.visible = false;
			}
		}
		
		private function createImage(source:String, px:Number, py:Number, parent:DisplayObjectContainer):Image
		{
			var img:Image=new Image;
			img.source=source;
			img.x=px;
			img.y=py;
			parent.addChild(img);
			return img;
		}
		
		private function onClickDefaultColor(e:MouseEvent):void
		{
			for (var i:int=0; i < colorImgs.length; i++)
			{
				var s:Sprite=colorImgs[i];
				s.filters=null;
			}
			_selectedColor="";
			reFreshRole();
		}
		
		private function onClickBarehead(e:Event):void
		{
			var i:int=0;
			var img:Image;
			var s:Sprite;
			if (bareheaded.selected == true)
			{
				for (i=0; i < faceImgs.length; i++)
				{
					img=faceImgs[i];
					img.filters=null;
					img.mouseEnabled=false;
				}
				for (i=0; i < colorImgs.length; i++)
				{
					s=colorImgs[i];
					s.filters=null;
					s.mouseEnabled=false;
				}
			}
			else
			{
				for (i=0; i < faceImgs.length; i++)
				{
					img=faceImgs[i];
					img.mouseEnabled=true;
				}
				for (i=0; i < colorImgs.length; i++)
				{
					s=colorImgs[i];
					s.mouseEnabled=true;
				}
			}
			_selectedHair=0; //光头
			_selectedColor=""; //默认色
			reFreshRole();
		}
		
		
		
		private function onClickFace(e:MouseEvent):void
		{
			for (var i:int=0; i < faceImgs.length; i++)
			{
				faceImgs[i].filters=null;
			}
			var img:Image=e.currentTarget as Image;
			img.filters=[new GlowFilter(0xAFE0EE, 1, 8, 8, 6, 1, true)];
			_selectedHair=int(img.name);
			reFreshRole();
		}
		
		private function onClickColors(e:MouseEvent):void
		{
			for (var i:int=0; i < colorImgs.length; i++)
			{
				colorImgs[i].filters=null;
			}
			var img:Sprite=e.currentTarget as Sprite;
			img.filters=[new GlowFilter(0xAFE0EE, 1, 8, 8), new GlowFilter(0xAFE0EE, 1, 8, 8, 6, 1, true)];
			_selectedColor=hairColors[int(img.name)].toString(16);
			while (_selectedColor.length < 6)
			{
				_selectedColor="0" + _selectedColor;
			}
			reFreshRole();
		}
		
		private function reFreshRole():void
		{
			var s:p_skin=new p_skin();
			s.skinid=skin.skinid;
			s.weapon=skin.weapon;
			s.clothes=skin.clothes;
			s.mounts=0;
			s.fashion = skin.fashion;
			s.assis_weapon=skin.assis_weapon;
			s.hair_type=_selectedHair;
			s.hair_color=_selectedColor;
			avatar.updataSkin(s);
		}
		
		private function turnLeft(e:MouseEvent):void
		{
			var dir:int=avatar.selectDir + 1;
			dir=dir % 8;
			avatar.play(AvatarConstant.ACTION_STAND, dir, ThingFrameFrequency.STAND);
		}
		
		private function turnRight(e:MouseEvent):void
		{
			var dir:int=avatar.selectDir + 7;
			dir=dir % 8;
			avatar.play(AvatarConstant.ACTION_STAND, dir, ThingFrameFrequency.STAND);
		}
		
		private function onCommit(evt:MouseEvent):void
		{
			if (_selectedHair < 0 && _selectedHair > 6)
			{
				Alert.show("请选择要更换的发型", "提示");
				return ;
			}
			var hairType:int=GlobalObjectManager.getInstance().user.attr.skin.hair_type;
			var hairColor:String=GlobalObjectManager.getInstance().user.attr.skin.hair_color;
			if (hairType == _selectedHair && hairColor == _selectedColor)
			{
				Alert.show("与原发型、原发色一致，没有任何改变，请重新选择", "提示", null, null, "确定", "", null, false);
				return ;
			}
			Alert.show("更改发型、发色需要发型卡1张或花费1锭银子。你确定更改吗？", "提示", yesHandler, null, "同意", "取消");
		}
		
		private function yesHandler():void
		{
			var vo:m_role2_hair_tos=new m_role2_hair_tos;
			vo.hair_type=_selectedHair;
			vo.hair_color=_selectedColor;

			var e:ParamEvent = new ParamEvent(CHANGE_HAIR_EVENT, vo, true);
			this.dispatchEvent(e);
		}
		
		private function onCancel(evt:MouseEvent):void
		{
			this.dispatchEvent(new Event("closeWindow", true, false));
		}
		
		private function createSlider(xValue:Number, yValue:Number, min:Number, max:Number, snapInterval:Number):Slider
		{
			var slider:Slider=new Slider();
			slider.x=xValue;
			slider.y=yValue;
			slider.minimum=min;
			slider.maximum=max;
			slider.width=163;
			slider.height=25;
			slider.handlerSize=15;
			slider.tickInterval=snapInterval;
			addChild(slider);
			return slider;
		}
	}
}


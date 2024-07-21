package modules.team.view {
	import com.common.GameConstant;
	import com.common.GlobalObjectManager;
	import com.common.cursor.CursorManager;
	import com.common.cursor.CursorName;
	import com.common.cursor.cursors.MagicHandCursor;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.core.UIComponent;
	import com.scene.WorldManager;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneUnit.Role;
	import com.scene.sceneUtils.SceneUnitType;
	import com.utils.ProgressBarUtil;
	
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import modules.ModuleCommand;
	import modules.mypackage.PackageModule;
	import modules.roleStateG.SeletedRoleVo;
	import modules.scene.SceneDataManager;
	import modules.skill.SkillConstant;
	import modules.skill.SkillModule;
	import modules.team.TeamMenuManager;
	
	import proto.line.p_team_role;

	public class TeamRoleView extends UIComponent {
		public var five:Array=["无", "金", "木", "水", "火", "土"];
		private var _role:p_team_role; //角色
		private var _isCaptain:Boolean=false; //队长标志，默认为false;
		private var _roleHeadImage:Image;
		private var _titleTF:TextField; //称号：队长或者队员;
		private var _hpBar:Bitmap //ProgressBar; //血条；
		private var _mpBar:Bitmap //ProgressBar; //蓝条；		
		private var _levelTxt:TextField;
		private var captain:Bitmap;
		private var _tip:String;
		private var bodyHot:Sprite;
		private var menu:TeamMenuManager;

		public function TeamRoleView(role:p_team_role, isCaptain:Boolean) {
			_role=role;
			_isCaptain=isCaptain;
		}

		public function setupUI():void {
			addChild(Style.getBitmap(GameConfig.T1_VIEWUI,"roleBg"));
			//角色形象
			_roleHeadImage=new Image();
			_roleHeadImage.addEventListener(MouseEvent.CLICK, onHeadClick);
			_roleHeadImage.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
			_roleHeadImage.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			_roleHeadImage.x=2;
			_roleHeadImage.y=3;
			_roleHeadImage.width=32;
			_roleHeadImage.height=32;
			_roleHeadImage.source=GameConstant.getHeadImage(_role.category*10+_role.sex);
			_roleHeadImage.buttonMode=true;
			addChild(_roleHeadImage);

			_hpBar=Style.getBitmap(GameConfig.T1_VIEWUI,"playerHP");
			_hpBar.x=33;
			_hpBar.y=20;
			_hpBar.width=72;
			_hpBar.height=6;


			addChild(_hpBar)

			_mpBar=Style.getBitmap(GameConfig.T1_VIEWUI,"playerMP");
			_mpBar.x=27;
			_mpBar.y=_hpBar.y + _hpBar.height + 2;

			_mpBar.width=72;
			_mpBar.height=6;


			addChild(_mpBar);
			_titleTF=new TextField();
			var tf:TextFormat=new TextFormat;
			tf.color=0xffffff;
			_titleTF.defaultTextFormat=tf;
			_titleTF.x=35;
			_titleTF.y=1;
			_titleTF.selectable=false;
			_titleTF.autoSize=TextFieldAutoSize.LEFT;
			addChild(_titleTF);
			_levelTxt=new TextField();
			_levelTxt.defaultTextFormat=tf;
			_levelTxt.x=109;
			_levelTxt.y=18;
			_levelTxt.selectable=false;
			_levelTxt.autoSize=TextFieldAutoSize.LEFT;
			addChild(_levelTxt);
			captain=Style.getBitmap(GameConfig.T1_VIEWUI,"Captain");
			captain.x=-3;
			captain.y=0;
			captain.visible=false;
			addChild(captain);
			upDate(_role, _isCaptain);
			var attackModeDown:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI,"attackModeDown");
			attackModeDown.x=122;
			attackModeDown.y=9;
			attackModeDown.alpha=0.7;
			//			attackModeDown.rotation=-90;
			addChild(attackModeDown);
			bodyHot=new Sprite;
			bodyHot.graphics.beginFill(0, 0);
			bodyHot.graphics.drawRect(0, 0, 94, 34);
			bodyHot.graphics.endFill();
			bodyHot.x=_titleTF.x;
			bodyHot.y=_titleTF.y;
			bodyHot.buttonMode=true;
			addChild(bodyHot);
			bodyHot.addEventListener(MouseEvent.ROLL_OVER, onHpMp);
			bodyHot.addEventListener(MouseEvent.ROLL_OUT, onHpMpOut);
			bodyHot.addEventListener(MouseEvent.CLICK, onClickBody);
			menu=TeamMenuManager.instance;
		}


		private function onRollOver(event:MouseEvent):void {
			var job:String="没职业";
			if (_role.category > 0 && _role.category < 5) {
				job=SkillConstant.categorys_name[_role.category];
			}
			if (_role.is_offline == true) {
				ToolTipManager.getInstance().show("玩家已下线，2分钟后自动离队\n五行：" + five[_role.five_ele_attr] + "\n职业：" + job, 100);
			} else {
				if (_role.map_id == SceneDataManager.mapData.map_id) {
					if (this.alpha < 1) {
						ToolTipManager.getInstance().show("玩家不在附近|无法共享奖励\n五行：" + five[_role.five_ele_attr] + "\n职业：" + job, 100);
					} else {
						ToolTipManager.getInstance().show("玩家在附近|可以共享奖励\n五行：" + five[_role.five_ele_attr] + "\n职业：" + job, 100);
					}
				} else {
					ToolTipManager.getInstance().show("所在地图：" + WorldManager.getMapName(_role.map_id) + "|无法共享奖励\n五行:" + five[_role.five_ele_attr] + "\n职业：" + job, 100);
				}
			}

		}

		private function onRollOut(event:MouseEvent):void {
			ToolTipManager.getInstance().hide();
		}

		private function onHpMp(e:MouseEvent):void {
			var hp:String=wapperHtml("生命值", "#af0d10", _role.hp + " / " + _role.max_hp + "\n");

			var mp:String=wapperHtml("内力值", "#026da4", _role.mp + " / " + _role.max_mp);

			ToolTipManager.getInstance().show(hp + mp)
		}

		private function onHpMpOut(e:MouseEvent):void {
			ToolTipManager.getInstance().hide();
		}

		private function wapperHtml(name:String, color:String, value:String):String {
			return "<font color='" + color + "' size='12'>" + name + "：</font><font color='#ffffff' size='11'>" + value + "</font>";
		}

		public function upDate(role:p_team_role, isCaptain:Boolean):void {
			//更新界面
			_role=role;
			_isCaptain=isCaptain;
			_titleTF.text=_role.role_name;
			_levelTxt.text=_role.level + '';
			_hpBar.scaleX=ProgressBarUtil.calculateScale(_role.hp, _role.max_hp);
			_mpBar.scaleX=ProgressBarUtil.calculateScale(_role.mp, _role.max_mp);
			var myroleid:int=GlobalObjectManager.getInstance().user.base.role_id;
			if (_role.is_leader && myroleid != _role.role_id) {
				captain.visible=true;
			} else {
				captain.visible=false;
			}

			if (_role.is_offline) {
				var mat:Array=[0.5, 0, 0, 0, 0, 0.5, 0, 0, 0, 0, 0.5, 0, 0, 0, 0, 0, 0, 0, 1, 0]
				var cm:ColorMatrixFilter=new ColorMatrixFilter(mat);
				filters=[cm];
				_tip="玩家已下线";
			} else {
				filters=null;
			}
			//队长标志
			if (_role.is_leader && myroleid != _role.role_id) {
				captain.visible=true;
			}
		}

		/**
		 * 更新菜单选项
		 * @param p
		 *
		 */
		private function checkType(p:p_team_role):String {
			var type:String;
			//更新菜单和函数
			if (_isCaptain == true) {
				if (p.is_leader) {
					if (GlobalObjectManager.getInstance().user.base.role_id == p.role_id) { //队长点自己
						type=TeamMenuManager.LEADER_SELF;
					}
				} else { //队长点队员
					type=TeamMenuManager.LEADER_OTHER;
				}
			} else {
				if (GlobalObjectManager.getInstance().user.base.role_id == p.role_id) { //队员点自己
					type=TeamMenuManager.MEMBER_SELF;
				} else { //队员点别人
					type=TeamMenuManager.MEMBER_OTHER;
				}
			}
			return type;
		}

		public function set tip(s:String):void {
			_tip=s;
		}

		/**
		 * 改队长
		 * @param e
		 *
		 */
		private function onClickBody(e:MouseEvent):void {
			ToolTipManager.getInstance().hide();
			var type:String=checkType(_role);
			menu.show(type, _role);
		}

		private function onHeadClick(e:MouseEvent):void {
			var role:Role=SceneUnitManager.getUnit(_role.role_id) as Role;
			if (role != null) {
				if (CursorManager.getInstance().currentCursor == CursorName.MAGIC_HAND) {
					var magicCursor:MagicHandCursor=CursorManager.getInstance().getCursor(CursorName.MAGIC_HAND) as MagicHandCursor;
					PackageModule.getInstance().useItem(magicCursor.data.oid, 1, _role.role_id);
					return;
				}
				if (CursorManager.getInstance().currentCursor == CursorName.SELECT_TARGET) {
					SkillModule.getInstance().skillToTarget(role); //选择技能后就去打
					return;
				}
				var rolevo:SeletedRoleVo=new SeletedRoleVo();
				rolevo.setupRole(role.pvo);
				Dispatch.dispatch(ModuleCommand.SHOW_SELECTED_ONE, {'see': true, 'vo': rolevo});
			}
		}


		private function get blackShape():Shape {

			var blackShape:Shape=new Shape();
			blackShape.graphics.beginFill(0x0, 0.3);
			blackShape.graphics.drawRect(0, 0, 50, 8);
			blackShape.graphics.endFill();

			return blackShape;
		}


		/**
		 * 改变血量
		 * @param value
		 *
		 */
		public function setBlood(value:int, max:int):void {
			if (_hpBar) {
				//				_hpBar.setProgress(value, max);
				_hpBar.scaleX=ProgressBarUtil.calculateScale(value, max);
			}
		}

		/**
		 *改变魔法
		 * @param value
		 *
		 */
		public function setMagic(value:int, max:int):void {
			if (_mpBar) {
				//				_mpBar.setProgress(value, max);
				_mpBar.scaleX=ProgressBarUtil.calculateScale(value, max);
			}
		}

		public function unload():void {
			_role=null;
			_roleHeadImage.removeEventListener(MouseEvent.MOUSE_DOWN, onHeadClick);
			menu=null;
			removeChild(_roleHeadImage);
			removeChild(_titleTF);
			removeChild(_hpBar);
			removeChild(_mpBar);
			_roleHeadImage=null;
			_titleTF=null;
			_hpBar=null;
			_mpBar=null;
			if (this.parent != null) {
				this.parent.removeChild(this);
			}
		}

		public function set isCaptain(value:Boolean):void {
			_isCaptain=value;
		}

		public function get pvo():p_team_role {
			return _role;
		}
	}
}
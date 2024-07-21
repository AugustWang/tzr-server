package modules.roleStateG.views.states {
	import com.common.GlobalObjectManager;
	import com.components.menuItems.GameMenuItems;
	import com.components.menuItems.MenuBar;
	import com.components.menuItems.MenuItemConstant;
	import com.components.menuItems.MenuItemData;
	import com.components.menuItems.TargetRoleInfo;
	import com.events.ParamEvent;
	import com.globals.GameConfig;
	import com.ming.events.ItemEvent;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.core.UIComponent;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneUtils.SceneUnitType;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import modules.pet.PetDataManager;
	import modules.pet.PetModule;
	import modules.roleStateG.RoleStateDateManager;
	import modules.roleStateG.SeletedRoleVo;
	import modules.scene.SceneDataManager;
	
	import proto.line.m_map_update_actor_mapinfo_toc;

	public class RoleSelectedStateView extends Sprite {
		public static const EVENT_ROLE_HEAD_CLICK:String="EVENT_ROLE_HEAD_CLICK";
		public static const EVENT_UPDATE_SELECTED:String="EVENT_UPDATE_SELECTED";
		private var _headImage:Image;
		private var _nameTxt:TextField;
		private var _levelTxt:TextField;
		private var hpAmptxt:TextField;
		private var mptxt:TextField;
		private var _hpBar:Bitmap;
		private var _orangeBar:Bitmap;
		private var _greenBar:Bitmap;
		private var _mpBar:Bitmap;
		private var _buffBox:RoleBuffView;
		private var _bloodTipHot:Sprite;
		private var pvo:SeletedRoleVo; //主信息
		private var levelBg:Bitmap
		private var menuItems:Array;
		private var targetRoleInfo:TargetRoleInfo;
		private var petMenu:MenuBar;

		public function RoleSelectedStateView() {
			createChildren();
			menuItems=[MenuItemConstant.CHAT, MenuItemConstant.OPEN_FRIEND_CHAT, MenuItemConstant.REQUEST_GROUP,MenuItemConstant.APPLY_TEAM, MenuItemConstant.DEAL, MenuItemConstant.FOLLOW, MenuItemConstant.FLOWER, MenuItemConstant.VIEW_DETAIL, MenuItemConstant.FRIEND, MenuItemConstant.INVITE_JOIN_FAMILY];
			targetRoleInfo=new TargetRoleInfo();
		}

		private function createChildren():void {
			var bg:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI,"otherRoleStateBg"); //"targetRoleBg"
			_headImage=new Image;
			_headImage.buttonMode=true;
			_headImage.useHandCursor=true;
			_headImage.addEventListener(MouseEvent.CLICK, onClickHead);
			_headImage.x=10;
			_headImage.y=-10;
			_nameTxt=new TextField;
			_nameTxt=new TextField();
			_nameTxt.mouseEnabled=false;
			_nameTxt.selectable=false;
			_nameTxt.filters=Style.textBlackFilter;
			_nameTxt.defaultTextFormat=new TextFormat(null, null, 0xffffff, null, null, null, null, null, "center");
			_nameTxt.x=64; //78;
			_nameTxt.y=-2;
			_nameTxt.width=100; //80;
			_nameTxt.height=20;

			levelBg = Style.getBitmap(GameConfig.T1_VIEWUI,"levelBg2");
			levelBg.x = 60;
			levelBg.y = 13;
			_levelTxt=new TextField();
			_levelTxt.addEventListener(MouseEvent.MOUSE_OVER, showLevelTip);
			_levelTxt.addEventListener(MouseEvent.MOUSE_OUT, hideTip);
			_levelTxt.autoSize=TextFieldAutoSize.CENTER;
			_levelTxt.filters=Style.textBlackFilter;
			_levelTxt.defaultTextFormat=new TextFormat(null, null, 0xffff00, null, null, null, null, null, "center");
			_levelTxt.width=20;
			_levelTxt.height=15;
			_levelTxt.selectable=false;
			_levelTxt.x=71;
			_levelTxt.y=18;
			_hpBar=Style.getBitmap(GameConfig.T1_VIEWUI,"otherRoleHP");
			_hpBar.x=71;
			_hpBar.y=19;
			_orangeBar=Style.getBitmap(GameConfig.T1_VIEWUI,"orangeBar");
			_orangeBar.x=71;
			_orangeBar.y=19;
			_greenBar=Style.getBitmap(GameConfig.T1_VIEWUI,"greenBar");
			_greenBar.x=71;
			_greenBar.y=19;
			_mpBar=Style.getBitmap(GameConfig.T1_VIEWUI,"otherRoleMP");
			_mpBar.x=71;
			_mpBar.y=31; //41.5;

			var tf:TextFormat=new TextFormat(null, 11, 0xffffff, null, null, null, null, null, "center");
			tf.leading=0;
			hpAmptxt=ComponentUtil.createTextField("", 92, 12, tf, 90, 15, this);
			//hpAmptxt.multiline = hpAmptxt.wordWrap = true;
			hpAmptxt.mouseEnabled=false;
			hpAmptxt.filters=[new GlowFilter(0x000000, 1, 2, 2, 3, 1, false, false)];

			mptxt=ComponentUtil.createTextField("", 92, 24, tf, 90, 15, this);
			//mptxt.multiline = hpAmptxt.wordWrap = true;
			mptxt.mouseEnabled=false;
			mptxt.filters=[new GlowFilter(0x000000, 1, 2, 2, 3, 1, false, false)];

			_buffBox=new RoleBuffView(81, 41);
			_buffBox.showTime=false;
//			var _closeBtn:UIComponent=new UIComponent;
//			_closeBtn.bgSkin=Style.getInstance().npcCloseBtnSkin;
//			_closeBtn.x=159.5;
//			_closeBtn.y=6;
//			_closeBtn.buttonMode=true;
//			_closeBtn.useHandCursor=true;
//			_closeBtn.addEventListener(MouseEvent.CLICK, onClickClose);
			
			addChild(bg);
			addChild(_headImage);
			addChild(_hpBar);
			addChild(_mpBar);
			addChild(levelBg);
			addChild(_levelTxt);
			addChild(_nameTxt);
			addChild(hpAmptxt);
			addChild(mptxt);
//			addChild(_closeBtn);
			addChild(_buffBox);
			_bloodTipHot=new Sprite;
			_bloodTipHot.graphics.beginFill(0, 0);
			_bloodTipHot.graphics.drawRect(0, 0, 88, 32);
			_bloodTipHot.graphics.endFill();
			_bloodTipHot.x=64;
			_bloodTipHot.y=15;
			addChild(_bloodTipHot);
			_bloodTipHot.addEventListener(MouseEvent.CLICK, onClickHead);
			_bloodTipHot.addEventListener(MouseEvent.ROLL_OVER, showRoleHpAMp);
			_bloodTipHot.addEventListener(MouseEvent.ROLL_OUT, hideTip);
			petMenu=new MenuBar;
			petMenu.labelField="label";
			petMenu.addEventListener(ItemEvent.ITEM_CLICK, onClickPetItem);
			var petItem:MenuItemData=new MenuItemData;
			petItem.label="查看宠物详细信息";
			var d:Vector.<MenuItemData>=new Vector.<MenuItemData>;
			d.push(petItem);
			petMenu.dataProvider=d;
			petMenu.validateNow();
			this.visible=false;
		}

		override public function set visible(value:Boolean):void {
			super.visible=value;
			if (value == false) {
				LoopManager.removeFromSceond(this);
			}

		}

		public function reset(obj:Object):void {
			var see:Boolean=obj.see;
			this.visible=see;
			if (see == false) {
				SceneDataManager.lockEnemyKey="";
				RoleStateDateManager.seletedUnit=null;
			} else {
				pvo=obj.vo as SeletedRoleVo;
				if (pvo != null) {
					updateView();
					if ((pvo.unit_type == SceneUnitType.ROLE_TYPE && pvo.id != GlobalObjectManager.getInstance().user.base.role_id) || pvo.unit_type == SceneUnitType.PET_TYPE) {
						_headImage.mouseEnabled=true;
					} else {
						_headImage.mouseEnabled=false;
					}
					var notSelf:Boolean=!(pvo.id == GlobalObjectManager.getInstance().user.base.role_id && pvo.unit_type == SceneUnitType.ROLE_TYPE);
					if (notSelf && (pvo.unit_type == SceneUnitType.MONSTER_TYPE || pvo.unit_type == SceneUnitType.YBC_TYPE || pvo.unit_type == SceneUnitType.SERVER_NPC_TYPE || pvo.unit_type == SceneUnitType.PET_TYPE || pvo.unit_type == SceneUnitType.ROLE_TYPE)) {
						toRequestInfo();
						LoopManager.addToSecond(this, toRequestInfo);
					} else {
						LoopManager.removeFromSceond(this);
					}
				}
			}
		}
		private var barIndex:int=0;

		private function upDateIndexHPBar(percent:Number, index:int=1):void {
			if (index == 1) {
				if (index != barIndex) {
					if (_greenBar.parent) {
						_greenBar.parent.removeChild(_greenBar);
					}
					if (_orangeBar.parent) {
						_orangeBar.parent.removeChild(_orangeBar);
					}
				}
				_hpBar.scaleX=percent;
			} else if (index == 2) {
				if (index != barIndex) {
					if (_greenBar.parent) {
						_greenBar.parent.removeChild(_greenBar);
					}
					if (_orangeBar.parent == null) {
						var index:int = getChildIndex(levelBg);
						addChildAt(_orangeBar,index-1);
					}
				}
				_orangeBar.scaleX=percent;
				if (_hpBar.scaleX != 1) {
					_hpBar.scaleX=1;
				}
				
			} else if (index == 3) {
				if (index != barIndex) {
					if (_orangeBar.parent == null) {
						index = getChildIndex(levelBg);
						addChildAt(_orangeBar,index-1);
					}
					if (_greenBar.parent == null) {
						index = getChildIndex(levelBg);
						addChildAt(_greenBar,index-1);
					}
				}
				_greenBar.scaleX=percent;
				if (_orangeBar.scaleX != 1) {
					_orangeBar.scaleX=1;
				}
			}
			barIndex=index;
		}

		private function updateView():void {
			var str:String="";
			var mpstr:String;
			RoleStateDateManager.seletedUnit=pvo;
			if (pvo.unit_type == SceneUnitType.NPC_TYPE || pvo.unit_type == SceneUnitType.MONSTER_TYPE){
				if(_headImage.visible){
					_headImage.visible = false;
				}
			}else{
				if (pvo.head_url != null && _headImage.source != pvo.head_url) {
					if(!_headImage.visible){
						_headImage.visible = true;
					}
					_headImage.source=pvo.head_url;
				}
			}
			if (pvo.name != null && _nameTxt.text != pvo.name) {
				_nameTxt.text=pvo.name;
			}
			if (pvo.level != 0 && _levelTxt.text != pvo.level.toString()) {
				_levelTxt.text=pvo.level.toString();
			}
			if (pvo.maxHp != 0) {
				var per:Number=pvo.hp / pvo.maxHp;
				if (pvo.isBoss == false) { //红色血
					upDateIndexHPBar(per, 1);
				} else {
					var tern:Number=pvo.maxHp / 3;
					if (pvo.hp > tern * 2) { //绿色血
						per=(pvo.hp - tern * 2) / tern;
						upDateIndexHPBar(per, 3);
					} else if (pvo.hp > tern && pvo.hp <= tern * 2) { //橙色血
						per=(pvo.hp - tern) / tern;
						upDateIndexHPBar(per, 2);
					} else { //红色血
						per=pvo.hp / tern;
						upDateIndexHPBar(per, 1);
					}
				}
			}
			if (pvo.maxMp != 0) {
				_mpBar.scaleX=pvo.mp / pvo.maxMp;
			}
			if (_hpBar.scaleX < 0) {
				_hpBar.scaleX=0;
			}
			if (_hpBar.scaleX > 1) {
				_hpBar.scaleX=1;
			}
			if (_mpBar.scaleX < 0) {
				_mpBar.scaleX=0;
			}
			if (_mpBar.scaleX > 1) {
				_mpBar.scaleX=1;
			}

			_buffBox.updateDataSource(pvo.buf);

			if (pvo.unit_type != SceneUnitType.NPC_TYPE && pvo.unit_type != SceneUnitType.MONSTER_TYPE && pvo.unit_type != SceneUnitType.YBC_TYPE && pvo.unit_type != SceneUnitType.SERVER_NPC_TYPE) {
				if (!hpAmptxt.visible) {
					hpAmptxt.visible=true;
					mptxt.visible=true;
				}
				str=pvo.hp + " / " + pvo.maxHp; //pvo.hp / pvo.maxHp;
				mpstr=pvo.mp + " / " + pvo.maxMp; //pvo.mp / pvo.maxMp;
				hpAmptxt.text=str;
				mptxt.text=mpstr
			} else {
				if (hpAmptxt.visible) {
					hpAmptxt.visible=false;
					mptxt.visible=false;
				}
			}
		}

		public function onUpdateInfo(mvo:m_map_update_actor_mapinfo_toc):void {
			if (pvo != null) {
				if (pvo.unit_type == mvo.actor_type && pvo.id == mvo.actor_id) {
					var selectvo:SeletedRoleVo=new SeletedRoleVo;
					if (mvo.actor_type == SceneUnitType.ROLE_TYPE && mvo.role_info != null) {
						if (mvo.role_info == null || mvo.role_info.role_id == 0)
							return;
						selectvo.setupRole(mvo.role_info);
					} else if (mvo.actor_type == SceneUnitType.MONSTER_TYPE && mvo.monster_info != null) {
						if (mvo.monster_info == null || mvo.monster_info.typeid == 0)
							return;
						selectvo.setupMonster(mvo.monster_info);
					} else if (mvo.actor_type == SceneUnitType.YBC_TYPE && mvo.monster_info != null) {
						if (mvo.ybc_info == null || mvo.ybc_info.ybc_id == 0)
							return;
						selectvo.setupYBC(mvo.ybc_info);
					} else if (mvo.actor_type == SceneUnitType.SERVER_NPC_TYPE && mvo.server_npc != null) {
						if (mvo.server_npc == null || mvo.server_npc.type_id == 0)
							return;
						selectvo.setupServerNPC(mvo.server_npc);
					} else if (mvo.actor_type == SceneUnitType.PET_TYPE && mvo.pet_info != null) {
						if (mvo.pet_info == null || mvo.pet_info.pet_id == 0)
							return;
						selectvo.setupPet(mvo.pet_info);
					}
					pvo=selectvo;
					updateView();
				}
			}
		}

		private function toRequestInfo():void {
			if (pvo != null && this.visible == true) {
				var e:ParamEvent=new ParamEvent(EVENT_UPDATE_SELECTED, pvo);
				this.dispatchEvent(e);
			}
		}

		public function updateBuff():void {

		}

		private function onClickHead(e:MouseEvent):void {
			if (pvo != null) {
				if (pvo.id != GlobalObjectManager.getInstance().user.base.role_id && pvo.unit_type == SceneUnitType.ROLE_TYPE) {
					targetRoleInfo.roleId=pvo.id;
					targetRoleInfo.roleName=pvo.name;
					targetRoleInfo.faction_id=pvo.faction_id;
					targetRoleInfo.family_id=pvo.family_id;
					targetRoleInfo.team_id=pvo.team_id;
					targetRoleInfo.sex=pvo.sex;
					targetRoleInfo.head=pvo.headId;
					GameMenuItems.getInstance().show(menuItems, targetRoleInfo);
				} else if (pvo.unit_type == SceneUnitType.PET_TYPE && (PetDataManager.thePet == null || pvo.id != PetDataManager.thePet.pet_id)) {
					petMenu.show();
				}
			}
		}

		private function onClickPetItem(e:ItemEvent):void {
			PetModule.getInstance().mediator.toPetInfo(pvo.id);
		}

		private function onClickClose(e:MouseEvent):void {
			RoleStateDateManager.seletedUnit=null;
			SceneDataManager.lockEnemyKey="";
			this.visible=false;
			pvo=null;
		}

		private function showLevelTip(e:MouseEvent):void {
			ToolTipManager.getInstance().show("角色等级：" + _levelTxt.text + "级");
		}

		private function hideTip(e:MouseEvent):void {
			ToolTipManager.getInstance().hide();
		}

		private function showRoleHpAMp(evt:MouseEvent=null):void {
			if (pvo.unit_type != SceneUnitType.NPC_TYPE && pvo.unit_type != SceneUnitType.MONSTER_TYPE && pvo.unit_type != SceneUnitType.YBC_TYPE && pvo.unit_type != SceneUnitType.SERVER_NPC_TYPE) {
				var hp:String="<font color='#af0d10' size='12'>生命值：</font><font color='#ffffff' size='11'>" + pvo.hp + " / " + pvo.maxHp + "</font>\n";
				var mp:String="<font color='#026da4' size='12'>内力值：</font><font color='#ffffff' size='11'>" + pvo.mp + " / " + pvo.maxMp + "</font>";
				ToolTipManager.getInstance().show(hp + mp);
			}
		}
	}
}
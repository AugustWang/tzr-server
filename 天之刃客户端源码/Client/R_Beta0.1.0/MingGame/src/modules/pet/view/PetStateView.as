package modules.pet.view {
	import com.common.GlobalObjectManager;
	import com.common.InputKey;
	import com.components.alert.Alert;
	import com.events.ParamEvent;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.core.UIComponent;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneUnit.MyPet;
	import com.scene.sceneUnit.baseUnit.SceneStyle;
	import com.scene.sceneUtils.RoleActState;
	import com.scene.sceneUtils.SceneUnitType;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	import com.utils.KeyUtil;
	import com.utils.ProgressBarUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.pet.PetDataManager;
	import modules.pet.config.PetConfig;
	import modules.roleStateG.views.states.RoleBuffView;
	
	import proto.common.p_map_pet;
	import proto.common.p_pet;
	import proto.common.p_pet_id_name;

	public class PetStateView extends Sprite {
		private var _petID:int=0;
		private var _blood:Number=0;
		private var _bloodMax:Number=0;
		private var _exp:Number=0;
		private var _expMax:Number=0;
		////////////////////////////
		private var _headImage:Image;
		private var _nameTxt:TextField;
		private var _levelTxt:TextField;
		private var _hpBar:Bitmap;
		private var _expBar:Bitmap;
		private var hpTxt:TextField;
		private var expTxt:TextField;
		public var buff:RoleBuffView;
		private var _bloodTipHot:Sprite;
		private var letOutBtn:TextField;
		private var letInBtn:TextField;

		public function PetStateView() {
			super();
			initView();
//			this.visible=false;
		}

		private function initView():void {
			KeyUtil.getInstance().addKeyHandler(toSummonORCallBack, [InputKey.W]);
			var format:TextFormat=new TextFormat("Tahoma", 12, 0xffeecc, null, null, null, null, null, "center");
			var bgView:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI,"petStateBg");
			_headImage=new Image;
			_headImage.buttonMode=true;
			_headImage.useHandCursor=true;
			_headImage.addEventListener(MouseEvent.CLICK, onClickBody);
			_headImage.x=0;
			_headImage.y=0;
			_nameTxt=new TextField();
			_nameTxt.mouseEnabled=false;
			_nameTxt.selectable=false;
			_nameTxt.filters=Style.textBlackFilter;
			_nameTxt.defaultTextFormat=new TextFormat(null, null, 0xffffff, null, null, null, null, null, "left");
			_nameTxt.x=70; //72;
			_nameTxt.y=1;
			_nameTxt.width=100; //80;
			_nameTxt.height=20;

			var levelBg:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"levelBg2");
			levelBg.x = 42;
			levelBg.y = 41;
			
			_levelTxt=new TextField();
			_levelTxt.addEventListener(MouseEvent.MOUSE_OUT, hideTip);
			_levelTxt.autoSize=TextFieldAutoSize.CENTER;
			_levelTxt.filters=Style.textBlackFilter;
			_levelTxt.defaultTextFormat=new TextFormat(null, 12, 0xffff00, null, null, null, null, null, "center");
			_levelTxt.width=20;
			_levelTxt.height=15;
			_levelTxt.selectable=false;
			_levelTxt.x=53; //67;
			_levelTxt.y=45; //5
			_hpBar=Style.getBitmap(GameConfig.T1_VIEWUI,"petHP");
			_hpBar.x=43;
			_hpBar.y=19;
			_expBar=Style.getBitmap(GameConfig.T1_VIEWUI,"greenBar");
			_expBar.width = _hpBar.width;
			_expBar.scaleX=0
			_expBar.x=43;
			_expBar.y=31;

			buff=new RoleBuffView(81, 51);
			addChild(bgView);
			addChild(_nameTxt);
			addChild(levelBg);
			addChild(_levelTxt);
			addChild(_hpBar);
			addChild(_expBar);
			//			addChild(expTxt);
			addChild(_headImage);
			addChild(buff);
			
			var tf:TextFormat=new TextFormat(null, 11, 0xffffff, null, null, null, null, null, "center");
			tf.leading=0;
			hpTxt=ComponentUtil.createTextField("", 58, 14, tf, 90, 15, this);
			hpTxt.mouseEnabled=false;
			hpTxt.filters=[new GlowFilter(0x000000, 1, 2, 2, 3, 1, false, false)];
			expTxt=ComponentUtil.createTextField("", 58, 30, tf, 90, 15, this);
			expTxt.mouseEnabled=false;
			expTxt.filters=[new GlowFilter(0x000000, 1, 2, 2, 3, 1, false, false)];
			
			_bloodTipHot=new Sprite;
			_bloodTipHot.graphics.beginFill(0, 0);
			_bloodTipHot.graphics.drawRect(0, 0, 106, 32);
			_bloodTipHot.graphics.endFill();
			_bloodTipHot.x=68;
			_bloodTipHot.y=15;
			addChild(_bloodTipHot);
			_bloodTipHot.addEventListener(MouseEvent.ROLL_OVER, showPetHp);
			_bloodTipHot.addEventListener(MouseEvent.ROLL_OUT, hideTip);
			_bloodTipHot.addEventListener(MouseEvent.CLICK, onClickBody);
			var btnBg:UIComponent = new UIComponent();
			btnBg.bgSkin = Style.getButtonSkin("petBtn_1skin","petBtn_2skin","petBtn_3skin","",GameConfig.T1_UI);
			btnBg.x = 153;
			btnBg.y = 15;
			addChild(btnBg);
			letOutBtn=ComponentUtil.createTextField("", 158, 18, null, 40, 30, this);
			letOutBtn.filters=SceneStyle.nameFilter;
			letOutBtn.htmlText="<font color='#FFFFFF'>战</font>";
			letInBtn=ComponentUtil.createTextField("", 158, 18, null, 40, 30, this);
			letInBtn.filters=SceneStyle.nameFilter;
			letInBtn.htmlText="<font color='#FFFFFF'>收</font>";
			btnBg.addEventListener(MouseEvent.ROLL_OVER, onOver);
			btnBg.addEventListener(MouseEvent.ROLL_OUT, onOut);
			btnBg.addEventListener(MouseEvent.CLICK, clickHandler);
			resetSummonBtn(PetDataManager.isBattle == false);
		}

		private function clickHandler(event:MouseEvent):void{
			if(letOutBtn.visible){
				toSummon();
			}else{
				toCallBack();
			}
		}
		private function onOver(e:MouseEvent):void {
			var tar:TextField=e.target as TextField;
			if (tar == letOutBtn) {
				ToolTipManager.getInstance().show("出战宠物（W）", 100);
			} else if (tar == letInBtn) {
				ToolTipManager.getInstance().show("召回宠物（W）", 100);
			}
		}

		private function onOut(e:MouseEvent):void {
			ToolTipManager.getInstance().hide();
		}

		public function resetSummonBtn(useSummon:Boolean):void {
			if (letOutBtn.visible != useSummon) {
				letOutBtn.visible=useSummon;
			}
			if (letInBtn.visible == useSummon) {
				letInBtn.visible=!useSummon;
			}
		}

		/**
		 *  改变宠物头像状态
		 * @param vo==null时，没宠物出战，这时头像显示列表里选中的那只或列表第一只
		 *  不为null时，头像显示出战那只
		 */
		public function resetBattlePet(vo:p_map_pet=null):void {
			if (vo == null) { //没出战的宠物
				if (PetDataManager.isBattle == false) { //没宠物出战才更新
					var selectedPet:p_pet=PetDataManager.selectedPet;
					if (selectedPet != null) { //有选中的宠物,头像就显示选中那只
						upDateByMapPet(PetDataManager.createP_map_pet(selectedPet));
						_petID=selectedPet.pet_id;
//						_headImage.filters=SceneStyle.deathFilter;
//						_hpBar.filters=SceneStyle.deathFilter;
//						_expBar.filters=SceneStyle.deathFilter;
					} else { //没选中的宠物，就拿列表的第一只来显示
						if (PetDataManager.petList.length > 0) { //没选中的宠物，拿列表里面的第一只
							updateByP_Pet_ID_Name(PetDataManager.petList[0]);
							_petID=PetDataManager.petList[0].pet_id;
//							_headImage.filters=SceneStyle.deathFilter;
//							_hpBar.filters=SceneStyle.deathFilter;
//							_expBar.filters=SceneStyle.deathFilter;
						}
					}
					resetSummonBtn(true);
				}
				updateBuff([]);
			} else { //有宠物出战，不理那些选中的切换
				_petID=vo.pet_id;
				upDateByMapPet(vo);
//				_headImage.filters=null;
//				_hpBar.filters=null;
//				_expBar.filters=null;
				resetSummonBtn(false);
			}
		}

		private function toSummonORCallBack():void {
			if (GlobalObjectManager.getInstance().isDead == true) {
				Dispatch.dispatch(ModuleCommand.TIPS, "死亡状态下不能召唤宠物");
				return;
			}
			if (PetDataManager.isBattle == false) {
				toSummon();
			} else {
				toCallBack();
			}
		}

		private function toCallBack(e:MouseEvent=null):void {
			if (GlobalObjectManager.getInstance().isDead == true) {
				Dispatch.dispatch(ModuleCommand.TIPS, "死亡状态下不能召唤宠物");
				return;
			}
			if (PetInfoView.callBackAbled == false) {
				Tips.getInstance().addTipsMsg("5秒后才能召回宠物");
				return;
			}
			var evt:ParamEvent=new ParamEvent(PetInfoView.CALL_BACK_EVENT);
			this.dispatchEvent(evt);
			PetInfoView.setCallBackAbledFalse();
			PetInfoView.setSummonAbledFalse();
		}


		private function toSummon(e:MouseEvent=null):void {
			if (GlobalObjectManager.getInstance().isDead == true) {
				Dispatch.dispatch(ModuleCommand.TIPS, "死亡状态下不能召唤宠物");
				return;
			}
			if (PetInfoView.summonAbled == false) {
				Tips.getInstance().addTipsMsg("10秒后才能再次召唤宠物");
				return;
			}
			if (PetDataManager.petList == null || PetDataManager.petList.length == 0) {
				Dispatch.dispatch(ModuleCommand.BROADCAST_SELF, HtmlUtil.font("你还没有宠物，可到神农架捕捉或按S从宠物商城购买", "#ff0000"));
				Dispatch.dispatch(ModuleCommand.BROADCAST, "你还没有宠物，可到神农架捕捉或按S从宠物商城购买");
				return;
			}
//			var petID:int;
//			if (PetDataManager.selectedPet != null) {
//				petID=PetDataManager.selectedPet.pet_id;
//			} else {
//				petID=PetDataManager.petList[0].pet_id;
//			}
			if (_petID != 0) {
				var evt:ParamEvent=new ParamEvent(PetInfoView.SUMMON_EVENT, _petID);
				this.dispatchEvent(evt);
				PetInfoView.setSummonAbledFalse();
				PetInfoView.setCallBackAbledFalse();
			}
		}

		private function updateByP_Pet_ID_Name(vo:p_pet_id_name):void {
			var skinid:int=PetConfig.getPetSkin(vo.type_id);
			var url:String=GameConfig.ROOT_URL + "com/assets/pet/head/" + skinid + ".png";
			if (url != _headImage.source) {
				_headImage.source=url;
			}
			if (_nameTxt.text != vo.name) {
				_nameTxt.htmlText=vo.name;
			}
			if (_hpBar.scaleX != 1) {
				_hpBar.scaleX=1;
			}
			if (_expBar.scaleX != 1) {
				_expBar.scaleX=1;
			}
			if (_levelTxt.text == "") {
				_levelTxt.text='';
			}
			if (hpTxt.text == "") {
				hpTxt.text="";
			}
			if (expTxt.text == "") {
				expTxt.text="";
			}
		}

		private function upDateByMapPet(vo:p_map_pet):void {
			_blood=vo.hp;
			_bloodMax=vo.max_hp;
			var skinid:int=PetConfig.getPetSkin(vo.type_id);
			var headURL:String=GameConfig.ROOT_URL + "com/assets/pet/head/" + skinid + ".png";
			var percent:Number=_blood / _bloodMax;
			if (_headImage.source != headURL) {
				_headImage.source=headURL;
			}
			if (_nameTxt.text != vo.pet_name) {
				_nameTxt.text=vo.pet_name;
			}
			if (_levelTxt.text != vo.level.toString()) {
				_levelTxt.text=vo.level + '';
			}
			if (hpTxt.text != _blood + "/" + _bloodMax) {
				hpTxt.text=_blood + "/" + _bloodMax;
			}
			if (_hpBar.scaleX != percent) {
				_hpBar.scaleX=percent;
				if (_hpBar.scaleX < 0) {
					_hpBar.scaleX=0;
				} else if (_hpBar.scaleX > 1) {
					_hpBar.scaleX=1;
				}
			}
			if (PetDataManager.thePet != null) { //p_map_pet里面的buff只是p_pet里的一部分
				updateBuff(PetDataManager.thePet.buffs);
				if (PetDataManager.isBattle == true) {
					var expPercent:Number=PetDataManager.thePet.exp / PetDataManager.thePet.next_level_exp;
					if (_expBar.scaleX != expPercent) {
						_expBar.scaleX=expPercent;
						if (_expBar.scaleX < 0) {
							_expBar.scaleX=0;
						} else if (_expBar.scaleX > 1) {
							_expBar.scaleX=1;
						}
					}
				}
			}
		}

		//没出战或是当前出战宠物才更新
		public function updateInfo(vo:p_pet):void {
			if (PetDataManager.isBattle == false || _petID == vo.pet_id) {
				_blood=vo.hp;
				_bloodMax=vo.max_hp;
				_exp=vo.exp;
				_expMax=vo.next_level_exp;
				var skinid:int=PetConfig.getPetSkin(vo.type_id);
				var headURL:String=GameConfig.ROOT_URL + "com/assets/pet/head/" + skinid + ".png";
				var hpPercent:Number=_blood / _bloodMax;
				var expPercent:Number=_exp / _expMax;
				if (_headImage.source != headURL) {
					_headImage.source=headURL;
				}
				if (_nameTxt.text != vo.pet_name) {
					_nameTxt.text=vo.pet_name;
				}
				if (hpTxt.text != _blood + "/" + _bloodMax) {
					hpTxt.text=_blood + "/" + _bloodMax;
				}
				if (_levelTxt.text != vo.level.toString()) {
					_levelTxt.text=vo.level + '';
				}
				if (_hpBar.scaleX != hpPercent) {
					_hpBar.scaleX=hpPercent;
					if (_hpBar.scaleX < 0) {
						_hpBar.scaleX=0;
					} else if (_hpBar.scaleX > 1) {
						_hpBar.scaleX=1;
					}
				}
				if (_expBar.scaleX != expPercent) {
					_expBar.scaleX=expPercent;
					if (_expBar.scaleX < 0) {
						_expBar.scaleX=0;
					} else if (_expBar.scaleX > 1) {
						_expBar.scaleX=1;
					}
				}
				updateBuff(vo.buffs);
			}
		}

		public function updateBuff(buffs:Array):void {
			buff.setDataSource(buffs);
		}

		public function updateBlood(blood:int):void {
			_blood=blood;
			if (_bloodMax == 0) {
				return;
			}
			var hpPercent:Number=_blood / _bloodMax;
			if (hpTxt.text != _blood + "/" + _bloodMax) {
				hpTxt.text=_blood + "/" + _bloodMax;
			}
			if (_hpBar.scaleX != hpPercent) {
				_hpBar.scaleX=hpPercent;
				if (_hpBar.scaleX < 0) {
					_hpBar.scaleX=0;
				} else if (_hpBar.scaleX > 1) {
					_hpBar.scaleX=1;
				}
			}
			var mypet:MyPet=SceneUnitManager.getUnit(_petID, SceneUnitType.PET_TYPE) as MyPet;
			if (mypet) {
				mypet.updateBlood(_blood, _bloodMax);
			}
			if (PetDataManager.thePet) {
				PetDataManager.thePet.hp=blood;
			}
		}

		public function updateBloodMax(blood:int):void {
			_bloodMax=blood;
			if (_bloodMax == 0) {
				return;
			}
			var hpPercent:Number=_blood / _bloodMax;
			if (hpTxt.text != _blood + "/" + _bloodMax) {
				hpTxt.text=_blood + "/" + _bloodMax;
			}
			if (_hpBar.scaleX != hpPercent) {
				_hpBar.scaleX=hpPercent;
				if (_hpBar.scaleX < 0) {
					_hpBar.scaleX=0;
				} else if (_hpBar.scaleX > 1) {
					_hpBar.scaleX=1;
				}
			}
			if (PetDataManager.thePet) {
				PetDataManager.thePet.max_hp=blood;
			}
		}

		public function updateExp(exp:Number):void {
			var addExp:Number=exp - _exp;
			BroadcastSelf.logger("宠物获得" + addExp + "经验。");
			_exp=exp;
			if (_expMax == 0) {
				return;
			}
			var percent:Number=_exp / _expMax;
			if (_expBar.scaleX != percent) {
				_expBar.scaleX=percent;
				if (_expBar.scaleX < 0) {
					_expBar.scaleX=0;
				} else if (_expBar.scaleX > 1) {
					_expBar.scaleX=1;
				}
			}
		}

		private function showPetHp(e:MouseEvent):void {
			var hp:String="<font color='#af0d10' size='12'>生命值：</font><font color='#ffffff' size='11'>" + _blood + " / " + _bloodMax + "</font>\n";
			var exp:String="<font color='#00ff00' size='12'>经验值：</font><font color='#ffffff' size='11'>" + _exp + " / " + _expMax + "</font>";
			ToolTipManager.getInstance().show(hp + exp);
		}

		private function hideTip(e:MouseEvent):void {
			ToolTipManager.getInstance().hide();
		}

		private function onClickBody(e:MouseEvent):void {
			if (GlobalObjectManager.getInstance().isDead == false) {
				Dispatch.dispatch(ModuleCommand.OPEN_OR_CLOSE_PET_MAIN);
			}
		}
	}
}
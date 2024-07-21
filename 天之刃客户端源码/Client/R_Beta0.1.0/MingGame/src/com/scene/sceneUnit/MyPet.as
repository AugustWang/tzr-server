package com.scene.sceneUnit {
	import com.common.GameColors;
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.scene.sceneKit.RoleNameItem;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneManager.UnitPool;
	import com.scene.sceneUnit.baseUnit.MutualAvatar;
	import com.scene.sceneUnit.baseUnit.things.avatar.Avatar;
	import com.scene.sceneUnit.baseUnit.things.avatar.AvatarConstant;
	import com.scene.sceneUnit.baseUnit.things.effect.DamageEffect;
	import com.scene.sceneUnit.baseUnit.things.thing.Thing;
	import com.scene.sceneUtils.MoveSpeedMath;
	import com.scene.sceneUtils.RoleActState;
	import com.scene.sceneUtils.ScenePtMath;
	import com.scene.sceneUtils.SceneUnitType;
	import com.scene.sceneUtils.TargetIdentify;
	import com.scene.tile.Pt;
	import com.scene.tile.TileUitls;
	import com.utils.HtmlUtil;
	
	import flash.events.DataEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	import modules.ModuleCommand;
	import modules.pet.PetDataManager;
	import modules.pet.config.PetConfig;
	import modules.pet.view.PetInfoView;
	import modules.roleStateG.RoleStateDateManager;
	import modules.roleStateG.SeletedRoleVo;
	import modules.scene.cases.FightCase;
	import modules.skill.SkillConstant;
	import modules.skill.SkillDataManager;
	import modules.skill.vo.SkillVO;
	
	import proto.common.p_map_pet;
	import proto.common.p_skin;


	/**
	 * 宠物类
	 * 接收指令，然后执行相应动作
	 * @author LXY
	 *
	 */
	public class MyPet extends MutualAvatar {
		protected var roleName:RoleNameItem;
		protected var petName:RoleNameItem;
		protected var petTitle:RoleNameItem;
		private var $pvo:p_map_pet;
		private var skin:p_skin;
		public var curState:int;
		/////////
		protected var masPos:Pt;
		protected var masDir:int;
		protected var startTime:int;
		protected var endTime:int;
		protected var startX:Number;
		protected var startY:Number;
		protected var tarX:Number;
		protected var tarY:Number;
		protected var curSpeedX:Number;
		protected var curSpeedY:Number;
		//////////
		private var targetKey:String="";
		private var attackAble:Boolean;
		private var cdReady:Boolean=true;
		private var startCDTime:int;

		public function MyPet() {
			super();
			sceneType=SceneUnitType.PET_TYPE;
		}

		public function reset(p:p_map_pet):void {
			id=p.pet_id;
			$pvo=p;
			if (roleName == null) {
				roleName=new RoleNameItem;
				this.addChild(roleName);
			}
			if (petName == null) {
				petName=new RoleNameItem;
				this.addChild(petName);
			}
			if (petTitle == null) {
				petTitle=new RoleNameItem;
				this.addChild(petTitle);
			}
			var color:String=GameColors.getHtmlColorByIndex(p.color);
			if (p.color == 4) {
				color="#9B52FF";
			}
			roleName.setHtmlText(HtmlUtil.font("(" + GlobalObjectManager.getInstance().user.base.role_name + "的宠物)", "#ffffff"));
			petName.setHtmlText(HtmlUtil.font(p.pet_name, color));
			petTitle.setHtmlText(HtmlUtil.font(p.title, color));
			skin=new p_skin;
			skin.skinid=PetConfig.getPetSkin(p.type_id);
			if (avatar == null) {
				super.initSkin(skin);
			} else {
				avatar.updataSkin(skin);
				avatar.addEventListener(Avatar.BODY_COMPLETE, onBodyComplete);
			}
			var mas:MyRole=SceneUnitManager.getUnit(p.role_id) as MyRole;
			if (mas != null) {
				masPos=new Pt(mas.index.x, 0, mas.index.z);
				masDir=mas.dir;
			}
			normal();
			var nowTile:Pt=TileUitls.getIndex(new Point(this.x, this.y));
			setWeak(isAlphaCell(nowTile));
			LoopManager.addToFrame(this, loop);
			PetDataManager.isBattle=true; //有宠物出战了
			glowEffect();
		}

		override protected function onBodyComplete(e:DataEvent):void {
//			super.onBodyComplete(e);
			roleName.y=-int(e.data) - 20;
			petName.y=roleName.y - 18;
			petTitle.y=petName.y - 18;
		}

		//走路的循环
		private function loop():void {
			checkCDTime();
			if (curState == RoleActState.NORMAL) { //当前空闲
				doNextMove();
			} else if (curState == RoleActState.RUNING) {
				exeMove();
			} else if (curState == RoleActState.FIGHT) {

			} else if (curState == RoleActState.DEAD) {

			}
		}
		
		private var _glowEffect:Thing
		private function glowEffect():void{
			if(pvo.type_id == 30051009 || pvo.type_id == 30051010){
				avatar._bodyLayer.filters = [new GlowFilter(0xfbc95e,0.6,20,20,2,1)];
				if(!_glowEffect){
					_glowEffect = new Thing();
					_glowEffect.load(GameConfig.EFFECT_PET_PATH + "dlh.swf");
					_glowEffect.play(4,true);
					_glowEffect.y = -100;
					avatar._effectLayerTop.addChild(_glowEffect);
				}
			}else if(pvo.type_id == 30051019 || pvo.type_id == 30051020){
				if(!_glowEffect){
					_glowEffect = new Thing();
					_glowEffect.load(GameConfig.EFFECT_PET_PATH + "bh.swf");
					_glowEffect.play(4,true);
					//_glowEffect.y = -100;
					avatar._effectLayerBottom.addChild(_glowEffect);
				}
			}else if(pvo.type_id == 30051029 || pvo.type_id == 30051030){
				avatar._bodyLayer.filters = [new GlowFilter(0xfa99dd,0.6,20,20,2,1)];
				if(!_glowEffect){
					_glowEffect = new Thing();
					_glowEffect.load(GameConfig.EFFECT_PET_PATH + "dlh.swf");
					_glowEffect.play(4,true);
					_glowEffect.y = -100;
					avatar._effectLayerTop.addChild(_glowEffect);
				}
			}
			
		}

		private function exeMove():void {
			var nowTime:int=getTimer();
			if (nowTime >= endTime) {
				this.x=tarX;
				this.y=tarY;
				onArriveRunEnd();
			} else {
				var passTime:Number=(nowTime - startTime) / 1000;
				this.x=startX + curSpeedX * passTime;
				this.y=startY + curSpeedY * passTime;
				onMoving();
			}
		}

		private function doNextMove():void {
			var mas:MyRole=UnitPool.getMyRole();
			if (mas != null) {
				var masIndex:Pt=mas.index;
				if (masIndex.key != masPos.key || mas.dir != masDir) { //主人的位置或方向有发生变化
					curState=RoleActState.RUNING; //状态变为走路
					masPos.x=masIndex.x;
					masPos.z=masIndex.z;
					masDir=mas.dir;
					var tarPt:Pt=ScenePtMath.getPetPt(masIndex, mas.dir, 2);
					var tarPoint:Point=TileUitls.getIsoIndexMidVertex(tarPt);
					startX=this.x;
					startY=this.y;
					tarX=tarPoint.x;
					tarY=tarPoint.y;
					var dir:int=getDretion(tarX, tarY);
					this.dir=dir;
					startTime=getTimer();
					var distance:Number=Point.distance(new Point(startX, startY), new Point(tarX, tarY));
					var realSpeed:Number=MoveSpeedMath.getRealSpeed(mas.pvo.move_speed, dir);
					var needTime:Number=distance / realSpeed;
					curSpeedX=(tarX - startX) / needTime;
					curSpeedY=(tarY - startY) / needTime;
					endTime=int(needTime * 1000) + startTime;
					this.play(AvatarConstant.ACTION_WALK, dir, PetDataManager.getWalkSpeed(skin.skinid));
				} else {
					//主人没动(位置和方向都没变)
					onArriveRunEnd();
				}
			} else {
//				throw new Error("找不到主人");
//				LoopManager.removeFromFrame(this);
			}
		}

		private function onArriveRunEnd():void { //走完了或者着长期不动都一直执行
			if (curState != RoleActState.NORMAL) {
				curState=RoleActState.NORMAL;
				var mas:MyRole=SceneUnitManager.getUnit(pvo.role_id) as MyRole;
				if (mas) {
					var masIndex:Pt=mas.index;
					if (masIndex.key == masPos.key && mas.dir == masDir) { //主人的位置或方向有发生变化
						this.play(AvatarConstant.ACTION_STAND, mas.dir, PetDataManager.getStandSpeed(skin.skinid));
					}
				}
			} else {
//				checkAutoTrick(); //检查是否施放回天和益气
				checkAttack(); //
			}
			checkRandomSay();
		}

		private function checkRandomSay():void {
			var rate:Number=Math.random();
			var level:int=GlobalObjectManager.getInstance().user.attr.level;
			if (level <= 20 && rate < 0.001) {
				if ($sayword == null || $sayword.parent == null) {
					say(PetConfig.getSayWordByAction("random").data);
				}
			} else if (level > 20 && rate < 0.0003) {
				if ($sayword == null || $sayword.parent == null) {
					say(PetConfig.getSayWordByAction("random").data);
				}
			}
		}

		private function onMoving():void {
			setWeak(isAlphaCell(this.index));
		}
		private var roleHp:int;
		private var roleMaxHp:int;
		private var roleMp:int;
		private var roleMaxMp:int;

		private function checkAutoTrick():void { //自动释放回天和益气
			if (cdReady == true) {
				roleHp=GlobalObjectManager.getInstance().user.fight.hp;
				roleMaxHp=GlobalObjectManager.getInstance().user.base.max_hp;
				roleMp=GlobalObjectManager.getInstance().user.fight.mp;
				roleMaxMp=GlobalObjectManager.getInstance().user.base.max_mp;
				if (roleHp / roleMaxHp < 0.8) { //检查释放回天技能
					var huiTianID:int=PetDataManager.checkHuiTianReady();
					if (huiTianID > 0) {
						FightCase.getInstance().toPetFight(huiTianID, GlobalObjectManager.getInstance().getRoleID(), SceneUnitType.ROLE_TYPE, sceneType, dir);
						cdReady=false;
						startCDTime=getTimer(); //记录攻击瞬间时间，用于计算CD
					}
				}
				if (roleMp / roleMaxMp < 0.5) { //检查释放益气技能
					var yiQiID:int=PetDataManager.checkYiQiReady();
					if (yiQiID > 0) {
						FightCase.getInstance().toPetFight(yiQiID, GlobalObjectManager.getInstance().getRoleID(), SceneUnitType.ROLE_TYPE, sceneType, dir);
						cdReady=false;
						startCDTime=getTimer(); //记录攻击瞬间时间，用于计算CD
					}
				}
			}
		}

		private function checkAttack():void {
			if (cdReady == true) {
				var skillID:int=PetDataManager.selectSkill();
				var skill:SkillVO=SkillDataManager.getSkill(skillID);
				if (skill.effect_type == SkillConstant.EFFECT_TYPE_MASTER) { //给主人施放的技能
					FightCase.getInstance().toPetFight(skillID, GlobalObjectManager.getInstance().getRoleID(), SceneUnitType.ROLE_TYPE, sceneType, dir);
					if (skillID == PetDataManager.selectedSkillID) {
						PetDataManager.selectedSkillID=0;
					}
					cdReady=false;
					startCDTime=getTimer(); //记录攻击瞬间时间，用于计算CD
				} else { //攻击的技能
					var seletedUnit:SeletedRoleVo=RoleStateDateManager.seletedUnit;
					if (seletedUnit != null) {
						if (seletedUnit.key != targetKey)
							targetKey=seletedUnit.key;
					} else {
						targetKey="";
						PetDataManager.attackAble=false;
					}
					if (PetDataManager.attackAble == true && targetKey != "") {
						var tar:MutualAvatar=SceneUnitManager.getUnitByKey(targetKey) as MutualAvatar;
						if (tar != null) {
							//////////以下判断攻击模式不对就停止/////
							var isEnemy:Boolean=TargetIdentify.checkAttack(tar, skill);
							if (isEnemy == false || tar.isDead == true) {
								targetKey="";
								PetDataManager.attackAble=false;
								return;
							}
							if (ScenePtMath.checkDistance(this.index, tar.index) > 24) {
								return; //太远了不打
							}
							//////////////////////////////
							dir=ScenePtMath.getDretion(this.index, tar.index);
							FightCase.getInstance().toPetFight(skillID, tar.id, tar.sceneType, sceneType, dir);
							if (skillID == PetDataManager.selectedSkillID) {
								PetDataManager.selectedSkillID=0;
							}
							/*---------------这里处理是宠物的技能特效文字---------------*/
							showSkillWord(skill.sid);
							cdReady=false;
							startCDTime=getTimer(); //记录攻击瞬间时间，用于计算CD
						}
					}
				}
			} else {
				curState=RoleActState.NORMAL;
			}
		}

		private function showSkillWord(sid:int):void {
			switch (sid) {
				case 61331101:
				case 61331201:
				case 61331301:
				case 61331401:
					DamageEffect.getEffect().showWord(topEffectLayer, new Point(0, -85), "da_jiang_dong_qu", 15);
					break;
				case 61131101:
				case 61131201:
				case 61131301:
				case 61131401:
					DamageEffect.getEffect().showWord(topEffectLayer, new Point(0, -85), "meng_ji", 15);
					break;
				case 61332101:
				case 61332201:
				case 61332301:
				case 61332401:
					DamageEffect.getEffect().showWord(topEffectLayer, new Point(0, -85), "qi_tun_shan_he", 15);
					break;
				case 61132101:
				case 61132201:
				case 61132301:
				case 61132401:
					DamageEffect.getEffect().showWord(topEffectLayer, new Point(0, -85), "tong_ji", 15);
					break;
			}
		}

		//重置CD
		private function checkCDTime():void {
			if (cdReady == false) {
				if (getTimer() - startCDTime > 1360000 / pvo.attack_speed) {
					cdReady=true;
				}
			}
		}

		override public function die():void {
			super.die();
			curState=RoleActState.DEAD;
			PetDataManager.isBattle=false;
			Dispatch.dispatch(ModuleCommand.BATTLE_PET_CHANGE);
			PetInfoView.setSummonAbledFalse();
			PetInfoView.setCallBackAbledFalse();
		}

		override public function turnDir(_dir:int=4):void {
			dir=_dir;
			var skinid:int=PetConfig.getPetSkin(pvo.type_id);
			this.play(AvatarConstant.ACTION_STAND, dir, PetDataManager.getStandSpeed(skinid));
		}

		override public function remove():void {
			super.remove();
			LoopManager.removeFromFrame(this);
			$pvo=null;
			PetDataManager.isBattle=false;
			if(_glowEffect){
				_glowEffect.stop();
				if(_glowEffect.parent){
					_glowEffect.parent.removeChild(_glowEffect);
				}
				_glowEffect = null;
			}
			Dispatch.dispatch(ModuleCommand.BATTLE_PET_CHANGE);
		}

		//蛋疼的后台血改变不发pvo过来，只能只样
		public function updateBlood(hp:int, max_hp:int):void {
			if (hp / max_hp < 0.5) {
				if ($sayword == null || $sayword.parent == null) {
					say(PetConfig.getSayWordByAction("littleBlood").data);
				}
			}
			if ($pvo) {
				$pvo.hp=hp;
				$pvo.max_hp=max_hp;
			}
		}

		public function set pvo(value:p_map_pet):void {
			$pvo=value;
		}

		public function get pvo():p_map_pet {
			return $pvo;
		}
	}
}

package modules.scene.cases {
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.net.SocketCommand;
	import com.scene.GameScene;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneUnit.IMutualUnit;
	import com.scene.sceneUnit.Role;
	import com.scene.sceneUnit.baseUnit.MutualAvatar;
	import com.scene.sceneUnit.baseUnit.things.avatar.AvatarConstant;
	import com.scene.sceneUnit.baseUnit.things.effect.ArrowEffect;
	import com.scene.sceneUnit.baseUnit.things.effect.DamageEffect;
	import com.scene.sceneUnit.baseUnit.things.effect.Effect;
	import com.scene.sceneUnit.baseUnit.things.effect.Shake;
	import com.scene.sceneUtils.SceneCheckers;
	import com.scene.sceneUtils.SceneUnitType;
	import com.scene.tile.Pt;
	import com.scene.tile.TileUitls;
	
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.pet.PetDataManager;
	import modules.playerGuide.GuideConstant;
	import modules.roleStateG.AttackModeContant;
	import modules.roleStateG.RoleStateDateManager;
	import modules.roleStateG.SeletedRoleVo;
	import modules.scene.SceneDataManager;
	import modules.scene.SceneModule;
	import modules.skill.SkillConstant;
	import modules.skill.SkillDataManager;
	import modules.skill.SkillModule;
	import modules.skill.vo.SkillEffectActionVO;
	import modules.skill.vo.SkillEffectItemVO;
	import modules.skill.vo.SkillEffectVO;
	import modules.skill.vo.SkillVO;
	import modules.system.SystemConfig;
	import modules.team.TeamDataManager;
	
	import proto.common.p_map_tile;
	import proto.common.p_pos;
	import proto.common.p_role;
	import proto.line.m_fight_attack_toc;
	import proto.line.m_fight_attack_tos;
	import proto.line.m_fight_buff_effect_toc;
	import proto.line.p_attack_result;
	import proto.line.p_buff_effect;

	public class FightCase extends BaseModule {
		private static var _instance:FightCase;
		private var _view:GameScene;
		public var _attackTargetKey:String="";
		public var lastAttackTime:int=0;

		public function set attackTargetKey(value:String):void {
			_attackTargetKey=value;
		}

		public function get attackTargetKey():String {
			return _attackTargetKey;
		}

		public function FightCase():void {
			_view=GameScene.getInstance();
		}

		public static function getInstance():FightCase {
			if (_instance == null) {
				_instance=new FightCase;
			}
			return _instance;
		}

		/**
		 * 持续性buff消息返回
		 * @param vo
		 */
		public function onBuff(vo:m_fight_buff_effect_toc):void {
			var dest:MutualAvatar=MutualAvatar(SceneUnitManager.getUnit(vo.actor_id, vo.actor_type));
			var myRoleID:int=GlobalObjectManager.getInstance().user.attr.role_id;
			if (dest != null && dest.topEffectLayer != null) {
				for (var i:int=0; i < vo.buff_effect.length; i++) {
					var effect:p_buff_effect=vo.buff_effect[i] as p_buff_effect;
					var buffEffect:Effect=Effect.getEffect();
					if (effect.effect_type == SkillConstant.BUFF_INTERVAL_EFFECT_REDUCE_HP || effect.effect_type == SkillConstant.BUFF_INTERVAL_EFFECT_REDUCE_MP) {
						dest.hurt();
						buffEffect.show(GameConfig.EFFECT_SKILL_PATH + 'hurt1.swf', 0, -dest.bobyHeight * 0.5, dest.topEffectLayer);
					} else {
						buffEffect.show(GameConfig.EFFECT_SKILL_PATH + 'hurt1002.swf', 0, -dest.bobyHeight * 0.5, dest.topEffectLayer);
					}
					var isSrc:Boolean=(vo.src_type == SceneUnitType.ROLE_TYPE && vo.src_id == myRoleID);
					var isTar:Boolean=(vo.actor_type == SceneUnitType.ROLE_TYPE && vo.actor_id == myRoleID)
					if (isTar && !isSrc && effect.effect_type == SkillConstant.BUFF_INTERVAL_EFFECT_REDUCE_HP) {
						effect.effect_type=SkillConstant.REDUCE_HP_SELF;
					}
					if (isSrc || isTar) {
						var damage:DamageEffect=DamageEffect.getEffect();
						damage.show(dest.topEffectLayer, new Point(0, -85), effect.effect_value, effect.effect_type);
					}
				}
			}
		}

		/**
		 * 战斗消息返回
		 * @param vo
		 */
		public function onfight(vo:m_fight_attack_toc):void {
			//if (!SceneDataManager.isGaming)return;
			//如果是自己发起攻击,服务器给别人的广播消息 跳过
			if (vo && !vo.return_self && vo.src_id == GlobalObjectManager.getInstance().user.base.role_id) {
				return;
			}
			if (!vo) {
				//战斗返回是否为空,空则跳过
				trace("战斗返回VO为空");
				return;
			}
			if (vo.return_self == true && vo.src_type == SceneUnitType.ROLE_TYPE) { //自己发起的战斗才重置
				SceneModule.isAttackBack=true;
				SceneModule.fightBackTime=getTimer(); //战斗返回时的时间
			}
			if (vo.succ == false) {
				//攻击是否失败,失败则打印原因并跳过
				BroadcastSelf.getInstance().appendMsg(vo.reason);
				if (vo.return_self == true && vo.src_type == SceneUnitType.PET_TYPE) { //我的宠物攻击失败
					PetDataManager.attackAble=false;
				} else {
					attackTargetKey="";
					if (_view.hero)
						_view.hero.normal();
				}
				return;
			}
			var srcRole:IMutualUnit;
			var destRole:MutualAvatar;
			var skillVO:SkillVO=SkillDataManager.getSkill(vo.skillid);
			if (vo.return_self) {
				//自己的攻击返回,只显示伤害
				//RoleDataManager.isAttackBack = true;//战斗返回标志
				lastAttackTime=getTimer();
				SkillModule.getInstance().coolDownStart(vo.skillid); //技能CD
				if (vo.result.length != 0) {
					if (skillVO.category == 0 || skillVO.category == 1 || skillVO.category == 2 || skillVO.category == 3 || skillVO.category == 4) {
						var tar:MutualAvatar=MutualAvatar(SceneUnitManager.getUnit(vo.target_id, vo.target_type));
						attackAgain(skillVO, tar);
					}
				}
			} else {
				//这个写这里怪怪的..功能是如果跟随的人被攻击了,那么则从新跟随一下
				//if(vo.src_id==SceneModule.getInstance().moveCase.follow_id&&vo.src_type==SceneUnitType.ROLE_TYPE){
				//	SceneModule.getInstance().moveCase.runToMaster();
				//}
				srcRole=SceneUnitManager.getUnit(vo.src_id, vo.src_type);
				if (srcRole && vo.target_type == SceneUnitType.ROLE_TYPE && vo.target_id == GlobalObjectManager.getInstance().user.attr.role_id && skillVO.kind == SkillConstant.KIND_NEGATIVE) {
					//挂机中反击
					if (SystemConfig.open == true && vo.src_type == SceneUnitType.ROLE_TYPE) {
						var pkMode:int=GlobalObjectManager.getInstance().user.base.pk_mode;
						if (Role(srcRole).pvo.faction_id == GlobalObjectManager.getInstance().user.base.faction_id) { //同国家
							if (pkMode != AttackModeContant.KINDEVIL && SceneCheckers.checkIsEnemy(srcRole as Role) == false) {
								dispatch(ModuleCommand.ROLE_CHANGE_ATTACK_MODE, AttackModeContant.KINDEVIL); //同国当前模式不能打
							}
						} else {
							if (pkMode != AttackModeContant.FACTION && SceneCheckers.checkIsEnemy(srcRole as Role) == false) {
								dispatch(ModuleCommand.ROLE_CHANGE_ATTACK_MODE, AttackModeContant.FACTION); //异国国当前模式不能打
							}
						}
					}
					//如果没目标则选中目标
					if (srcRole && RoleStateDateManager.seletedUnit == null) {
						SceneDataManager.lockEnemyKey=srcRole.unitKey;
						var svo:SeletedRoleVo=new SeletedRoleVo;
						svo.setup(srcRole);
						dispatch(ModuleCommand.SHOW_SELECTED_ONE, {see: true, vo: svo});
					}
				}

				if (srcRole != null) {
					if (vo.src_pos != null) { //同步位置,肯定不是自己
						var srcpos:Point=TileUitls.getIsoIndexMidVertex(new Pt(vo.src_pos.tx, 0, vo.src_pos.ty))
						srcRole.x=srcpos.x;
						srcRole.y=srcpos.y;
					}
				}

			}
			showFightEffect(vo);
		}

		private function showFightEffect($vo:m_fight_attack_toc):void {
			var effectVo:SkillEffectVO=SkillDataManager.getSkill($vo.skillid).effect;
			//地动山摇，冲锋特殊处理
			if ($vo.return_self && ($vo.skillid == 12204001 || $vo.skillid == 12104001)) {
				Shake.shakeScene();
			}
			if ($vo.return_self && $vo.skillid == 11101002) {
				if ($vo.result.length > 0 && $vo.result[0].is_erupt) {
					LoopManager.setTimeout(function():void {
							Shake.shakeScene();
						}, 550);
				}
			}
			//同归于尽特殊处理
			if ($vo.skillid == 11103006 && $vo.target_id == 0 && $vo.target_type == 0) {
				effectVo=SkillDataManager.getSkill(12204001).effect;
			}
			if (effectVo == null)
				return;
			if (effectVo.isNormal) {
				var i:int=0;
				//执行技能动作
				for (i=0; i < effectVo.actions.length; i++) {
					var actionItem:SkillEffectActionVO=effectVo.actions[i];
					var key:String;
					if (actionItem.target == SkillConstant.TAR_SRC) {
						key=$vo.src_type + "_" + $vo.src_id;
						updataPosition(key, $vo.src_pos);
						excAction($vo, key, actionItem.type, $vo.dir, actionItem.delay);
							//////////////////////////////更正位置攻击者位置
					} else {
						for (var j:int=0; j < $vo.result.length; j++) {
							key=$vo.result[j].dest_type + "_" + $vo.result[j].dest_id;
							excAction($vo, key, actionItem.type, -1, actionItem.delay);
						}
					}
				}
				//执行技能特效
				for (i=0; i < effectVo.effects.length; i++) {
					var effectItem:SkillEffectItemVO=effectVo.effects[i];
					if (effectItem.type == SkillConstant.TYPE_NORAML) {
						excEffect(effectItem, $vo);
					} else {
						excArrowEffect(effectItem, $vo);
					}
				}
				if (effectVo.hasDamage && effectVo.damageStart == SkillConstant.START_NORMAL) {
					showHurt($vo);
				}
			} else {
				//特殊技能
			}
		}

		public function excAction($vo:m_fight_attack_toc, $targetKey:String, $type:String, $dir:int, $delay:int):void {
			var target:MutualAvatar=MutualAvatar(SceneUnitManager.getUnitByKey($targetKey));
			var srcKey:String=$vo.src_type + "_" + $vo.src_id;
			if (target == null)
				return;
			if ($dir < 0)
				$dir=target.dir;
			if ($delay) {
				if ($type == AvatarConstant.ACTION_HURT) {
					LoopManager.setTimeout(hurt, $delay * 33, [srcKey, target]);
				} else {
					LoopManager.setTimeout(attack, $delay * 33, [$type, $dir]);
				}
			} else {
				if ($type == AvatarConstant.ACTION_HURT) {
					hurt(srcKey, target);
				} else {
					attack(target, $type, $dir);
				}
			}

		}

		private function hurt(srcKey:String, target:MutualAvatar):void {
			if (SceneUnitManager.getSelf() && target) {
//				if (srcKey == SceneUnitManager.getSelf().unitKey && target.isDead && Math.random() < 0.3) {
//					Shake.shakeScene(3);
//				}
				target.hurt();
			}
		}

		private function attack(target:MutualAvatar, type:String, dir:int):void {
			if (target) {
				target.attack(type, dir);
			}
		}

		/**
		 * 播放特效
		 */
		private function excEffect($vo:SkillEffectItemVO, $fightVo:m_fight_attack_toc):void {
			if (!SystemConfig.openEffect)
				return;
			var effect:Effect;
			var layer:Sprite;
			var effectX:Number;
			var effectY:Number;
			switch ($vo.target) {
				case SkillConstant.TAR_SCENE:
					effect=Effect.getEffect();
					$vo.layerType == SkillConstant.TOP_LAYER ? layer=_view.highEffLayer : layer=_view.lowEffLayer;
					var p:Point;
					switch ($vo.posType) {
					case SkillConstant.POS_BOTTOM:
						p=TileUitls.getIsoIndexMidVertex(new Pt($fightVo.dest_pos.tx, 0, $fightVo.dest_pos.ty));
						effectX=p.x;
						effectY=p.y;
						break;
					case SkillConstant.POS_MIDDLE:
						p=TileUitls.getIsoIndexMidVertex(new Pt($fightVo.dest_pos.tx, 0, $fightVo.dest_pos.ty));
						effectX=p.x;
						effectY=p.y - 60;
						break;
					case SkillConstant.POS_SRC_BOTTOM:
						p=TileUitls.getIsoIndexMidVertex(new Pt($fightVo.src_pos.tx, 0, $fightVo.src_pos.ty));
						effectX=p.x;
						effectY=p.y;
						break;
					case SkillConstant.POS_SRC_MIDDLE:
						p=TileUitls.getIsoIndexMidVertex(new Pt($fightVo.src_pos.tx, 0, $fightVo.src_pos.ty));
						effectX=p.x;
						effectY=p.y - 60;
						break;
					case SkillConstant.POS_DEST_BOTTOM:
						p=TileUitls.getIsoIndexMidVertex(new Pt($fightVo.dest_pos.tx, 0, $fightVo.dest_pos.ty));
						effectX=p.x;
						effectY=p.y;
						break;
					case SkillConstant.POS_DEST_MIDDLE:
						p=TileUitls.getIsoIndexMidVertex(new Pt($fightVo.dest_pos.tx, 0, $fightVo.dest_pos.ty));
						effectX=p.x;
						effectY=p.y - 60;
						break;
				}
					if ($vo.hasDir) {
						var newDir:int=$fightVo.dir;
						if (newDir > 4) {
							newDir=int($fightVo.dir.toString().replace('5', '3').replace('6', '2').replace('7', '1'));
							effect.scaleX=-1;
						}
						effect.show(GameConfig.EFFECT_SKILL_PATH + $vo.id + '_' + newDir + '.swf', effectX, effectY, layer, $vo.speed, $vo.delay);
					} else {
						effect.show(GameConfig.EFFECT_SKILL_PATH + $vo.id + '.swf', effectX, effectY, layer, $vo.speed, $vo.delay);
					}
					break;
				case SkillConstant.TAR_SRC:
					effect=Effect.getEffect();
					var src:MutualAvatar=MutualAvatar(SceneUnitManager.getUnit($fightVo.src_id, $fightVo.src_type));
					if (src == null)
						return;
					$vo.layerType == SkillConstant.TOP_LAYER ? layer=src.topEffectLayer : layer=src.bottomEffectLayer;
					$vo.posType == SkillConstant.POS_BOTTOM ? effectY=0 : effectY=-src.bobyHeight * 0.5;

					if ($vo.hasDir) {
						newDir=$fightVo.dir;
						if (newDir > 4) {
							newDir=int($fightVo.dir.toString().replace('5', '3').replace('6', '2').replace('7', '1'));
							effect.scaleX=-1;
						}
						effect.show(GameConfig.EFFECT_SKILL_PATH + $vo.id + '_' + newDir + '.swf', 0, effectY, layer, $vo.speed, $vo.delay);
					} else {
						effect.show(GameConfig.EFFECT_SKILL_PATH + $vo.id + '.swf', 0, effectY, layer, $vo.speed, $vo.delay);

					}
					break;
				case SkillConstant.TAR_DEST:
				case SkillConstant.TAR_DESTS:
					for (var i:int=0; i < $fightVo.result.length; i++) {
						effect=Effect.getEffect();
						var $dest:MutualAvatar=MutualAvatar(SceneUnitManager.getUnit($fightVo.result[i].dest_id, $fightVo.result[i].dest_type));
						if ($dest == null)
							return;
						$vo.layerType == SkillConstant.TOP_LAYER ? layer=$dest.topEffectLayer : layer=$dest.bottomEffectLayer;
						$vo.posType == SkillConstant.POS_BOTTOM ? effectY=0 : effectY=-$dest.bobyHeight * 0.5;
						if ($vo.hasDir) {
							newDir=$fightVo.dir;
							if (newDir > 4) {
								newDir=int($fightVo.dir.toString().replace('5', '3').replace('6', '2').replace('7', '1'));
								effect.scaleX=-1;
							}
							effect.show(GameConfig.EFFECT_SKILL_PATH + $vo.id + '_' + newDir + '.swf', 0, effectY, layer, $vo.speed, $vo.delay);
						} else {
							var effectPath:String; //后台改怪物攻击使用的技能ID前 先这样处理
							if($fightVo.src_type == SceneUnitType.MONSTER_TYPE){
								effectPath = GameConfig.EFFECT_SKILL_PATH + $vo.id + '_guai.swf';
							}else{
								effectPath = GameConfig.EFFECT_SKILL_PATH + $vo.id + '.swf';
							}
							effect.show(effectPath, 0, effectY, layer, $vo.speed, $vo.delay);
						}
					}
					break;
			}
		}

		public function excArrowEffect($vo:SkillEffectItemVO, $fightVo:m_fight_attack_toc):void {
			var src:MutualAvatar=MutualAvatar(SceneUnitManager.getUnit($fightVo.src_id, $fightVo.src_type));
			var dest:MutualAvatar=MutualAvatar(SceneUnitManager.getUnit($fightVo.result[0].dest_id, $fightVo.result[0].dest_type));
			if (src == null || dest == null)
				return;
			var arrowEffect:ArrowEffect=ArrowEffect.getEffect();
			arrowEffect._endFunArg=$fightVo;
			arrowEffect.endFunction=arrowEnd;
			var arrowX:Number;
			var arrowY:Number;
			var arrowLayer:Sprite;
//			switch ($vo.layerType) {
//				case SkillConstant.TOP_LAYER:
//					arrowLayer=_view.highEffLayer;
//					break;
//				case SkillConstant.BOTTOM_LAYER:
//					//arrowLayer=_view.lowEffLayer;
//					arrowLayer=_view.highEffLayer;
//					break;
//			}
			if ($vo.posType == SkillConstant.POS_MIDDLE) {
				arrowX=dest.x;
				arrowY=dest.y - dest.bobyHeight * 0.5;
			}
			if ($vo.posType == SkillConstant.POS_BOTTOM) {
				arrowX=dest.x;
				arrowY=dest.y;
			}
			var path:String=GameConfig.EFFECT_SKILL_PATH + $vo.id + '.swf';
			if (!SystemConfig.openEffect) {
				path=GameConfig.EFFECT_SKILL_PATH + "pu_tong_yuan_cheng.swf";
			}
			arrowEffect.show(path, src.x, src.y - 75, arrowX, arrowY, _view.highEffLayer, $vo.delay);
		}

		private function arrowEnd($vo:m_fight_attack_toc):void {
			var effectVo:SkillEffectVO=SkillDataManager.getSkill($vo.skillid).effect;
			var i:int=0;
			for (i=0; i < effectVo.arrowEndActions.length; i++) {
				var actionItem:SkillEffectActionVO=effectVo.arrowEndActions[i];
				var key:String;
				if (actionItem.target == SkillConstant.TAR_SRC) {
					key=$vo.src_type + "_" + $vo.src_id;
					excAction($vo, key, actionItem.type, $vo.dir, actionItem.delay);
				} else {
					for (var j:int=0; j < $vo.result.length; j++) {
						key=$vo.result[j].dest_type + "_" + $vo.result[j].dest_id;
						excAction($vo, key, actionItem.type, -1, actionItem.delay);
					}
				}
			}
			//执行技能特效
			for (i=0; i < effectVo.arrowEndEffects.length; i++) {
				var effectItem:SkillEffectItemVO=effectVo.arrowEndEffects[i];
				if (effectItem.type == SkillConstant.TYPE_NORAML) {
					excEffect(effectItem, $vo);
				} else {
					excArrowEffect(effectItem, $vo);
				}
			}
			if (effectVo.hasDamage && effectVo.damageStart == SkillConstant.START_ARROW_END) {
				showHurt($vo);
			}
		}

		private var hurtPoint:Point=new Point(0, -85);

		private function showHurt($vo:m_fight_attack_toc):void {
			var effectVo:SkillEffectVO=SkillDataManager.getSkill($vo.skillid).effect;
			var myid:int=GlobalObjectManager.getInstance().user.base.role_id;
			var myPetId:int=0;
			var result:p_attack_result;
			var l:int=$vo.result.length;
			var damage:DamageEffect;
			var $dest:MutualAvatar;
			var effectType:String;
			if (PetDataManager.thePet != null) {
				myPetId=PetDataManager.thePet.pet_id;
			}
			for (var i:int=0; i < l; i++) {
				result=$vo.result[i];
				if ($vo.return_self == true || (result.dest_id == myid && result.dest_type == 1) || (result.dest_id == myPetId && result.dest_type == 3) || TeamDataManager.isTeamMember($vo.src_id)) {
					$dest=MutualAvatar(SceneUnitManager.getUnit(result.dest_id, result.dest_type));
					if ($dest == null) {
						return;
					}
					if (result.is_miss) {
						damage=DamageEffect.getEffect();
						damage.show($dest.topEffectLayer, hurtPoint, result.result_value, result.result_type, DamageEffect.MISS);
						continue;
					}
					if (result.result_type != 0) { //返回数值类型为0,则不显示伤害值,一些BUFF技能时需要显示动画不显示数值时需要.
						damage=DamageEffect.getEffect();
						if (result.dest_type == SceneUnitType.ROLE_TYPE && result.dest_id == _view.hero.pvo.role_id) {
							result.result_type=SkillConstant.REDUCE_HP_SELF; //如果受害人是自己，弄成飘红血
							onMyhurtTip(result.result_value);
						}
						if (result.dest_type == SceneUnitType.PET_TYPE && PetDataManager.thePet != null && result.dest_id == PetDataManager.thePet.pet_id) {
							result.result_type=SkillConstant.REDUCE_HP_SELF; //如果受害人是自己的宠物，弄成飘红血
						}
						effectType=DamageEffect.NORMAL;
						if (result.is_erupt) {
							effectType=DamageEffect.CRIT;
						}
						if (result.is_no_defence) {
							effectType=DamageEffect.NO_DEFENCE;
						}
						if ($dest.isDead) {
							damage.show(_view.highEffLayer, new Point($dest.x, $dest.y - 85), result.result_value, result.result_type, effectType, effectVo.damageDelay);
						} else {
							damage.show($dest.topEffectLayer, hurtPoint, result.result_value, result.result_type, effectType, effectVo.damageDelay);
						}
					}
				}
			}
		}



		public function attackAgain(skillVO:SkillVO, tar:MutualAvatar):void {
			if (SystemConfig.open == true) {
				return; //挂机时再打由挂机timer驱动
			}
			if (attackTargetKey != "") {
				var againTime:int=1400;
				var cooldown:int=skillVO.levels[skillVO.level - 1].cooldown;
				if (cooldown > 2000) {
					againTime=1400;
				} else {
					againTime=Math.max(cooldown / (GlobalObjectManager.getInstance().user.base.attack_speed * 0.001), 1360);
				}
				if (SceneUnitManager.getSelf() != null) {
					LoopManager.setTimeout(SceneUnitManager.getSelf().attackAgain, againTime);
				}
			}
		}

		private function updataPosition(key:String, p:p_pos):void {
			var avatar:MutualAvatar=MutualAvatar(SceneUnitManager.getUnitByKey(key));
			if (avatar != null) {
				var pos:Point=TileUitls.getIsoIndexMidVertex(new Pt(p.tx, 0, p.ty))
				avatar.x=pos.x;
				avatar.y=pos.y;
			}
		}
		private var showHPDownID:int;
		private var hasShowHPDown:Boolean;

		/**
		 * 被打了，提示吃药
		 * @param reduce_hp
		 *
		 */
		private function onMyhurtTip(reduce_hp:int=0):void {
			var user:p_role=GlobalObjectManager.getInstance().user;
			var hp:int=user.fight.hp - reduce_hp;
			if (hp < user.base.max_hp * 0.5 && hasShowHPDown == false) {
				if (user.attr.level < 25) {
					this.dispatch(ModuleCommand.SHOW_HP_TIP);
				} else {
					this.dispatch(ModuleCommand.BROADCAST, "你的血量较低，请使用金创药补血");
				}
				hasShowHPDown=true;
				LoopManager.clearTimeout(showHPDownID);
				showHPDownID=LoopManager.setTimeout(function s():void {
						hasShowHPDown=false;
					}, 5000);
			}
		}

		override protected function initListeners():void {
			addSocketListener(SocketCommand.FIGHT_ATTACK, onfight);
			addSocketListener(SocketCommand.FIGHT_BUFF_EFFECT, onBuff); //buff
		}

		public function toPetFight(skillid:int, tarid:int, targetType:int, srcType:int, dir:int, pt:Pt=null):void {
			var vo:m_fight_attack_tos=new m_fight_attack_tos;
			vo.skillid=skillid;
			vo.target_id=tarid;
			vo.target_type=targetType;
			vo.src_type=srcType;
			vo.dir=dir;
			if (pt != null) {
				vo.tile=new p_map_tile;
				vo.tile.tx=pt.x;
				vo.tile.ty=pt.z;
			}
			sendSocketMessage(vo);
		}

		public function fight(sid:int=1, targetID:int=0, targetType:int=0, point:Point=null):void {
			SkillDataManager.currentSkill=null;
			SkillDataManager.currentSkillTraget=null;
			var vo:m_fight_attack_tos=new m_fight_attack_tos();
			var tarPt:Pt;
			vo.skillid=sid;
			if (SceneUnitManager.getSelf() == null) {
				return;
			}
			vo.dir=SceneUnitManager.getSelf().dir;
			vo.target_id=targetID;
			vo.target_type=targetType;
			if (point != null) {
				tarPt=TileUitls.getIndex(point);
				vo.tile=new p_map_tile();
				vo.tile.tx=tarPt.x;
				vo.tile.ty=tarPt.z;
			} else if (targetID != 0) {
				vo.tile=new p_map_tile();
				var unit:IMutualUnit=SceneUnitManager.getUnit(targetID, targetType);
				if (unit == null) {
					return;
				}
				tarPt=TileUitls.getIndex(new Point(unit.x, unit.y));
				vo.tile.tx=tarPt.x;
				vo.tile.ty=tarPt.z;
			}
			sendSocketMessage(vo);
			Dispatch.dispatch(GuideConstant.SCENE_FIGHT, targetID);
		}
	}
}
package com.scene.sceneUnit {
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.managers.MusicManager;
	import com.scene.GameScene;
	import com.scene.sceneData.HandlerAction;
	import com.scene.sceneData.MacroPathVo;
	import com.scene.sceneData.WaitingCommand;
	import com.scene.sceneKit.AutoRunTxt;
	import com.scene.sceneKit.GuajiTxt;
	import com.scene.sceneKit.RoleNames;
	import com.scene.sceneKit.TrainingLight;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneManager.NPCTeamManager;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneUnit.baseUnit.MutualAvatar;
	import com.scene.sceneUnit.baseUnit.things.avatar.Avatar;
	import com.scene.sceneUnit.baseUnit.things.avatar.AvatarConstant;
	import com.scene.sceneUnit.baseUnit.things.effect.Effect;
	import com.scene.sceneUnit.baseUnit.things.heartbeat.ThingFrameFrequency;
	import com.scene.sceneUnit.baseUnit.things.thing.Thing;
	import com.scene.sceneUtils.ConvertMath;
	import com.scene.sceneUtils.RoleActState;
	import com.scene.sceneUtils.SceneCheckers;
	import com.scene.sceneUtils.ScenePtMath;
	import com.scene.sceneUtils.SceneUnitType;
	import com.scene.sceneUtils.Slice;
	import com.scene.tile.Pt;
	import com.scene.tile.TileUitls;
	
	import flash.events.DataEvent;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.collect.CollectModule;
	import modules.heroFB.HeroFBModule;
	import modules.pet.PetDataManager;
	import modules.scene.SceneDataManager;
	import modules.scene.SceneModule;
	import modules.scene.cases.FightCase;
	import modules.scene.cases.MapCase;
	import modules.scene.cases.MoveCase;
	import modules.skill.SkillDataManager;
	import modules.skill.SkillModule;
	import modules.skill.vo.SkillVO;
	import modules.system.SystemConfig;
	
	import proto.common.p_actor_buf;
	import proto.common.p_map_role;
	import proto.common.p_role_attr;
	import proto.common.p_skin;
	
	public class MyRole extends Animal implements IRole {
		private static const MAX_BLOCK_TIME:int=20; //受阻挡最大次数，超过时停止走路
		private static const NORMAL_RUN:String="NORMAL_RUN";
		private static const ATTACK_RUN:String="ATTACK_RUN";
		private var runMode:String="NORMAL_RUN";
		private var $pvo:p_map_role;
		
		private var nowSlice:Point;
		private var names:RoleNames;
		private var training:TrainingLight; //训练的发光
		private var board:StallBoard; //摆摊的招牌
		private var guaji:GuajiTxt;
		private var autoRunTxt:AutoRunTxt;
		private var _targetKey:String; //跟踪目标的键值，(id_type)
		private var _curSkillPoint:Point;
		private var _curSkill:SkillVO;
		private var blockCount:int;
		private var finalPt:Pt;
		public var underControl:Boolean=true; //是否受玩家控制
		public var attackAbled:Boolean=true; //是否可以发起攻击
		private var lastAttackAbled:int=0;
		public var UnderControlID:int;
		private var attackAbledID:int;
		private var arriveAction:HandlerAction;
		public var isSkillCooling:Boolean=false;
		private var attackSpeed:int;
		private var readyAutoSitTime:int; //可以自动打坐瞬间时间
		///////////////////
		private var command:WaitingCommand; //等待的指令
		
		public function MyRole() {
			super();
			sceneType=SceneUnitType.ROLE_TYPE;
			command=new WaitingCommand;
		}
		
		public function reset(vo:p_map_role):void {
			this.isDead=vo.state == RoleActState.DEAD;
			curState=vo.state;
			this.alpha=1;
			LoopManager.clearTimeout(UnderControlID);
			LoopManager.clearTimeout(attackAbledID);
			underControl=true;
			attackAbled=true;
			id=vo.role_id;
			attackSpeed=900; //这值如果根据人物的攻击速度，会出现attackAgain的时候 attackAbled = false 从而停止攻击
			speed=vo.move_speed; // == 0 ? 160 : p.move_speed;
			$pvo=vo;
			if (names == null) {
				names=new RoleNames($pvo);
				addChild(names);
			}
			if (avatar == null) {
				super.initSkin($pvo.skin);
			} else {
				initAvatar();
				avatar.updataSkin($pvo.skin);
				avatar.addEventListener(Avatar.BODY_COMPLETE, onBodyComplete);
			}
			avatar._bodyLayer.filters=null;
			var point:Point=TileUitls.getIsoIndexMidVertex(new Pt(vo.pos.tx, 0, vo.pos.ty));
			this.x=point.x;
			this.y=point.y;
			avatar.isNude=!$pvo.show_cloth;
			lastTile=new Pt($pvo.pos.tx, 0, $pvo.pos.ty);
			doNameJob();
			createBuff($pvo.state_buffs);
			nowSlice=slice;
			checkSlice();
			setWeak(isAlphaCell(lastTile));
			LoopManager.addToFrame(this, loop);
			//MonsterDebugger.trace(this, pvo);
			checkEquipRing();
			checkMountRing();
			GameScene.getInstance().centerCamera(this.x, this.y);
		}
		
		override protected function initAvatar():void{
			avatar.isPerson = true;
			avatar.category = $pvo.category;
			avatar.sex = $pvo.sex;
		}
		
		override protected function loop():void {
			super.loop();
			GameScene.getInstance().autoRoad();
			checkAutoSit();
		}
		
		override protected function onCurStateChange():void {
			
		}
		
		//三分钟发呆自动打坐
		private function checkAutoSit():void {
			if (curState == RoleActState.NORMAL) {
				if (readyAutoSitTime == 0) {
					readyAutoSitTime=getTimer();
				} else {
					if (getTimer() - readyAutoSitTime > 180000 && SceneModule.isAutoHit == false) {
						SceneModule.getInstance().doRoleZaZen(true);
						readyAutoSitTime=getTimer(); //执行了坐之后，重新计时，给点时间后台返回
					}
				}
			} else {
				readyAutoSitTime=0;
			}
		}
		
		override protected function onBodyComplete(e:DataEvent):void {
			if (names)
				names.y=-int(e.data) - 25;
		}
		
		public function resetUnderControl(b:Boolean):void {
			if (isDead == false) {
				underControl=b;
				if (b == true && command.hasCommand == true) {
					runToPoint(command.tarPt, command.cut, command.handler, command.runMode);
					command.clearCommand();
				}
			}
		}
		
		public function resetAttackAbled(b:Boolean):void {
			if (isDead == false) {
				attackAbled=b;
				if (!attackAbled) {
					lastAttackAbled=getTimer()
				}
				if (b == true && curState == RoleActState.FIGHT) {
					curState=RoleActState.NORMAL;
				}
			}
		}
		
		override public function attack(attackType:String, _dir:int):void {
			super.attack(attackType, _dir);
			MusicManager.playSound(MusicManager.DAO);
		}
		
		public function attackAgain():void {
			if (runMode == ATTACK_RUN) {
				var tar:MutualAvatar=MutualAvatar(SceneUnitManager.getUnitByKey(FightCase.getInstance().attackTargetKey))
				if (tar) {
					var obj:Object=SkillModule.getInstance().filterSkill(tar);
					if (obj) {
						runAndHit(obj.targetKey, obj.skillVO);
					}
				}
			} else {
				FightCase.getInstance().attackTargetKey="";
				SkillDataManager.currentSkill=null;
				SkillDataManager.currentSkillTraget=null;
			}
		}
		
		public function runToPoint(tarPt:Pt, cut:int=0, handler:HandlerAction=null, runMode:String=NORMAL_RUN):void {
			if (isDead == true) {
				BroadcastSelf.logger("角色处于死亡状态不能行走");
				return;
			}
			if (HeroFBModule.isOpenHeroFBPanel == true) {
				BroadcastSelf.logger("英雄副本画面中不能行走");
				return;
			}
			if (underControl == false) {
				command.setCommand(tarPt, cut, handler, runMode);
				return;
			}
			LoopManager.clearTimeout(UnderControlID); //这三行防止玩家狂点狂发走路消息
			resetUnderControl(false);
			UnderControlID=LoopManager.setTimeout(resetUnderControl, 500, [true]);
			
			if (ScenePtMath.checkDistance(tarPt, this.index) > cut) {
				var t:int=getTimer();
				var arr:Array=GameScene.getInstance().astar.findPath(index, tarPt);
				//				trace("寻路时间：", getTimer() - t);
				if (arr == null || Pt(arr[0]).key == Pt(arr[arr.length - 1]).key) {
					return;
				}
				this.runMode=runMode; //两种模式：普通走路和跟踪走路,跟踪走路目标移动会继续跟踪
				arriveAction=handler;
				if (arr.length >= 2) {
					if (Pt(arr[0]).key == index.key) { //这寻出来的路，不一定就包括自己站的那一格
						arr.shift(); //去掉自己站的那格
					}
					//cut最终点倒退格子数
					for (var i:int=0; i < cut; i++) {
						if (arr.length > 0)
							arr.pop();
					}
					if (arr.length > 0) { //变拐点
						if (arr.length > 30) {
							Dispatch.dispatch(ModuleCommand.MOUNT_UP_FAR_RUN);
						}
						var sort:Array=ConvertMath.sortPath(arr);
						run(sort);
					}
				}
			} else { //如果当前已经站在指定位置
				if (arriveAction != null) {
					arriveAction.execute();
					arriveAction=null;
				}
			}
		}
		
		override protected function onArriveRunEnd():void {
			showAutoRun(false);
			curState=RoleActState.NORMAL;
			finalPt=null;
			normal();
			blockCount=0; //成功走完了路，把阻挡数改为0
			if (runMode == NORMAL_RUN) {
				if (arriveAction != null) {
					arriveAction.execute();
					arriveAction=null;
				}
			} else if (runMode == ATTACK_RUN) {
				runAndHit(_targetKey, _curSkill);
			}
		}
		
		public function runAndHit(targetKey:String, skill:SkillVO, pt:Point=null):void {
			if (isDead == false && underControl == true) {
				var tar:MutualAvatar=SceneUnitManager.getUnitByKey(targetKey) as MutualAvatar;
				if (tar != null) {
					if (tar.isDead == true && skill.sid != 41108001) {
						normal();
						return;
					}
					_curSkill=skill;
					_targetKey=targetKey;
					_curSkillPoint=null;
					if (ScenePtMath.checkDistance(this.index, tar.index) <= _curSkill.distance) {
						//在攻击距离之内
						normal();
						runMode=ATTACK_RUN;
						doAttack(skill.sid, tar);
						path=null;
					} else { //在攻击距离之外
						blockCount=0;
						runToPoint(tar.index, _curSkill.distance, null, ATTACK_RUN);
					}
				} else if (pt != null) {
					_curSkill=skill;
					_targetKey="";
					_curSkillPoint=pt;
					var tarPt:Pt=TileUitls.getIndex(pt);
					if (ScenePtMath.checkDistance(this.index, tarPt) <= _curSkill.distance) {
						//在攻击距离之内
						normal();
						runMode=ATTACK_RUN;
						doAttack(skill.sid, null, pt);
						path=null;
					} else { //在攻击距离之外
						blockCount=0;
						runToPoint(tarPt, _curSkill.distance, null, ATTACK_RUN);
					}
				} else { //找不到敌人
					_targetKey="";
					runMode=NORMAL_RUN;
					normal();
				}
			}
		}
		
		public function rerun():void {
			if (finalPt != null) {
				blockCount++; //碰壁次数
				if (blockCount <= MAX_BLOCK_TIME && index.key != finalPt.key) {
					//当目标格不是终点时才寻路
					this.runToPoint(finalPt, 0, arriveAction, runMode);
				} else {
					//碰壁太多次，不走了，但由于其他客户端仍按原路径走，会走到路径终点，为了保持一致，把当前位置发给后台广播;
					path=[];
					normal();
					MoveCase.getInstance().walkPathUp([this.index]);
				}
			} else {
				normal();
				MoveCase.getInstance().walkPathUp([this.index]);
			}
		}
		
		/**
		 * 走路并告诉服务器
		 * @param vo
		 *
		 */
		override public function run(newPath:Array):void {
			path=newPath; //path存的是拐点
			finalPt=path[path.length - 1];
			MoveCase.getInstance().walkPathUp(path);
			super.run(path);
		}
		
		override public function normal():void {
			super.normal();
			curState=RoleActState.NORMAL;
		}
		
		/**
		 * 移动中
		 *
		 */
		override protected function onMoving():void {
			super.onMoving();
			checkAttack();
			checkBlockRun();
			GameScene.getInstance().centerCamera(this.x, this.y);
			checkSlice();
		}
		
		private function doAttack(skillId:int, tar:MutualAvatar=null, pt:Point=null):void {
			if (getTimer() - lastAttackAbled > 3000) {
				attackAbled=true;
			}
			if (attackAbled == true) {
				if (tar != null) {
					if (tar != this) {
						setDretion(tar.x, tar.y);
					}
					FightCase.getInstance().fight(skillId, tar.id, tar.sceneType);
				} else if (pt != null) {
					setDretion(pt.x, pt.y);
					FightCase.getInstance().fight(skillId, 0, 0, pt);
				}
				if (SceneModule.isAutoHit == true) {
					SceneModule.isAttackBack=false;
				}
				curState=RoleActState.FIGHT;
				resetUnderControl(false);
				resetAttackAbled(false);
				LoopManager.clearTimeout(UnderControlID);
				LoopManager.clearTimeout(attackAbledID);
				UnderControlID=LoopManager.setTimeout(resetUnderControl, 500, [true]);
				attackAbledID=LoopManager.setTimeout(resetAttackAbled, attackSpeed, [true]);
				PetDataManager.attackAble=true;
			} else {
				trace("attackAbled is FALSE!")
			}
		}
		
		
		override public function die():void {
			super.die();
			isDead=true;
			underControl=false;
			attackAbled=false;
			path=null;
		}
		
		
		public function attrChange(vo:p_role_attr):void {
			avatar.updataSkin(vo.skin);
		}
		
		
		/**
		 * 跟随步骤，1，走到主人目前站的位置，2，走到主人路径终点
		 * @param tarpt,主人当前位置，endpt，主人最终位置
		 *
		 */
		public function follow(tarpt:Pt, endpt:Pt=null):void {
			if (isDead == true || underControl == false) {
				return;
			}
			runMode=NORMAL_RUN;
			var arr:Array=GameScene.getInstance().astar.findPath(index, tarpt);
			if (arr && arr.length > 0) {
				if (Pt(arr[0]).key == index.key) { //这寻出来的路，不一定就包括自己站的那一格
					arr.shift(); //去掉自己站的那格
				}
			}
			//arr2指主人的路径，这里自己再寻一次路，而不直接用主人的路，原因是主人走路时，由于时间间隔较长，阻挡有变化
			var arr2:Array;
			var path:Array;
			if (endpt != null) {
				arr2=GameScene.getInstance().astar.findPath(tarpt, endpt);
				if (arr2 && arr2.length > 0) {
					arr2.shift();
				}
				path=arr.concat(arr2);
			} else {
				path=arr;
			}
			//去掉2格，与主人保持2格距离
			for (var i:int=0; i < 2; i++) {
				if (path && path.length > 0)
					path.pop();
			}
			blockCount=0;
			if (path && path.length > 0) { //有路就走
				run(path);
			} else { //没路就发当前格，纠正其他客户端按原路走
				//					vo.walk_path.path=[this.index];
			}
		}
		
		
		/**
		 * 更新hero所在slice
		 *
		 */
		
		public function checkSlice():void {
			var sx:int=int((this.x + Slice.offsetx) / Slice.width);
			var sy:int=int((this.y + Slice.offsety) / Slice.height);
			var newSlice:Point=new Point(sx, sy);
			if (nowSlice != null && nowSlice.toString() != newSlice.toString()) {
				nowSlice=newSlice;
				NPCTeamManager.npcCheckOut(x, y);
				var nowIndex:Pt=this.index; //防范格子是不可走的
				if (SceneDataManager.hasCell(nowIndex.x, nowIndex.z) == true) {
					MoveCase.getInstance().walkUp(this.index, dir);
				}
			}
		}
		
		private function sendWalkTile(curPt:Pt):void {
			var hasCell:Boolean=SceneDataManager.hasCell(curPt.x, curPt.z);
			if (hasCell == true) { //有格子的
				var dis:int=ScenePtMath.checkDistance(lastTile, curPt);
				if (dis <= 1) {
					if (dis == 1) {
						lastTile=curPt;
						MoveCase.getInstance().walkUp(curPt, dir);
					}
				} else {
					//					var moveArr:Array=ConvertMath.revertPath([lastTile, curPt]); // 由于丢帧或走路速度太快，上个格子可能和现在这格不相邻
					var moveArr:Array=GameScene.getInstance().astar.findPath(lastTile, curPt);
					if (lastTile.key == moveArr[0].key && moveArr.length > 1) { //去掉lastTile那格
						moveArr.shift();
					}
					for (var i:int=0; i < moveArr.length; i++) {
						dis=ScenePtMath.checkDistance(moveArr[i], lastTile);
						if (dis > 1) { //Alert.show("格子太远:" + moveArr[i].x + "_" + moveArr[i].z);
							normal();
							var p:Point=TileUitls.getIsoIndexMidVertex(this.index);
							this.x=p.x;
							this.y=p.y;
							lastTile=this.index;
							return;
						}
						if (SceneDataManager.hasCell(moveArr[i].x, moveArr[i].z) == false) { //这时很可能是站在一个不存在的格子上，先移到之前那个格子再寻路
							normal(); //Alert.show("格子不可走:" + moveArr[i].x + "_" + moveArr[i].z);
							var p1:Point=TileUitls.getIsoIndexMidVertex(lastTile);
							this.x=p1.x;
							this.y=p1.y;
							rerun();
							return;
						}
						if (dis == 1) {
							lastTile=moveArr[i];
							MoveCase.getInstance().walkUp(moveArr[i], dir);
						}
					}
				}
			} else {
				//格子不可走，不发送
			}
		}
		
		/**
		 * 到了一个新格子
		 *
		 */
		override protected function changeCell(curPt:Pt):void {
			//			super.changeCell();
			setWeak(isAlphaCell(curPt));
			checkArea();
			sendWalkTile(curPt); //发送walk_up消息
			if (checkTurn() == true) {
				normal();
				resetUnderControl(false);
			}
		}
		
		public function skip():void {
			finalPt=null;
			lastTile=this.index;
			checkSlice();
			//			changeCell();//这里不用changeCell是因为到了跳转点时会跳转地图，策划不希望直接跳
			checkArea();
			MoveCase.getInstance().walkUp(this.index, dir); //告诉后台我到了某格
		}
		
		protected function checkBlockRun():void {
			if (tarPt == null)
				return;
			var p:Point=TileUitls.getIsoIndexMidVertex(this.index); //得到中点
			var midDir:int=getDretion(p.x, p.y); //得到与中点的方向
			if ((midDir + 4) % 8 != dir) { //若与格子中点的方向相反，则已过中点(还没过中心点，直接返回)
				return;
			}
			var nextPt:Pt; //下一格
			var _dir:int; //指向下一格子的方向
			if (this.index.key == tarPt.key) { //到了拐点，
				if (path && path.length > 0) {
					var newTarPt:Pt=path[0];
					_dir=ScenePtMath.getDretion(this.index, newTarPt);
					nextPt=ScenePtMath.getDirPt(this.index, _dir);
				}
			} else { //没到拐点
				nextPt=ScenePtMath.getDirPt(this.index, dir);
			}
			if (nextPt != null) {
				var isBlock:Boolean=SceneDataManager.isBlockCell(nextPt.x, nextPt.z); //下一格是否有阻挡
				if (isBlock == true) {
					rerun();
				}
			}
		}
		
		protected function checkAttack():void {
			var p:Point=TileUitls.getIsoIndexMidVertex(this.index); //得到中点
			var _dir:int=getDretion(p.x, p.y); //得到与中点的方向
			if ((_dir + 4) % 8 != dir) { //判断是否已经过了格子的中点,这里是未过，所以返回
				if (p.x != this.x || p.y != this.y) {
					return;
				}
			}
			if (runMode == ATTACK_RUN) {
				var tar:MutualAvatar=SceneUnitManager.getUnitByKey(_targetKey) as MutualAvatar;
				
				if (tar != null) {
					if (tar.isDead == true) {
						normal();
						return;
					}
					if (ScenePtMath.checkDistance(this.index, tar.index) <= _curSkill.distance) {
						//在攻击距离之内
						normal();
						runMode=ATTACK_RUN;
						doAttack(_curSkill.sid, tar);
						path=null;
					}
				}
			}
		}
		
		private function checkArea():void {
			SceneCheckers.checkArea(lastTile, this.index);
		}
		
		private function checkTurn():Boolean {
			var turnAble:Boolean;
			var tarMap:MacroPathVo=SceneCheckers.checkTurnPoint(this.index);
			if (tarMap != null) {
				MapCase.getInstance().toChangeMap(tarMap.mapid, tarMap.pt.x, tarMap.pt.z);
				turnAble=true;
			}
			return turnAble;
		}
		
		
		override public function addBuff(value:Array):void {
			for (var i:int=0; i < value.length; i++) {
				var vo:p_actor_buf=value[i] as p_actor_buf;
				switch (vo.buff_type) {
					case 31: //中毒
						avatar.colorFilter(0, 1, 0);
						break;
					case 33: //%%定身，无法移动，可以使用技能和道具
						normal()
						break;
					case 34: //%%麻痹，移动速度下降，无法使用技能
						break;
					case 36: //隐身
						conceal(true, true);
						break;
					case 37: //反隐身
						SkillModule.getInstance().antiStealth(true);
						break;
					case 32: //%%晕迷，无法移动，无法使用技能和道具
					case 35: //%%混乱状态，不受角色控制一段时间
					case 85: //%%镶嵌晕眩
						normal();
						Dispatch.dispatch(ModuleCommand.USEGOODS_ENABLE, {enabled: false, desc: '晕迷状态下不能使用道具'});
						underControl=false;
						break;
					case 86: //冰冻
						if (SystemConfig.openEffect) {
							var buffEffect:Effect=Effect.getEffect();
							buffEffect.show(GameConfig.EFFECT_PATH + 'buff86.swf', 0, 0, avatar._effectLayerTop);
						}
						avatar.colorFilter(0, 0, 1);
						break;
					case 87:
						avatar.colorFilter(0, 1, 0);
						break;
					case 1003:
						var skin:p_skin=new p_skin();
						skin.skinid=vo.value;
						skin.hair_type=0;
						if (avatar.selectState != AvatarConstant.ACTION_ATTACK || avatar.selectState != AvatarConstant.ACTION_STAND || avatar.selectState != AvatarConstant.ACTION_WALK) {
							avatar.play(AvatarConstant.ACTION_STAND, avatar.selectDir, ThingFrameFrequency.STAND);
						}
						avatar.isTransform=false;
						avatar.updataSkin(skin);
						avatar.isTransform=true;
						break;
					case 1034:
						normal();
						if (SystemConfig.openEffect) {
							var trapEffect:Thing=new Thing();
							trapEffect.name="jing_ji_xian_jing";
							trapEffect.x=trapEffect.y=0;
							avatar._effectLayerTop.addChild(trapEffect);
							trapEffect.load(GameConfig.EFFECT_PATH + 'trap/jing_ji_xian_jing.swf');
							trapEffect.play(4);
						}
						break;
					case 1035:
						if (SystemConfig.openEffect && avatar && !avatar._effectLayerTop.getChildByName('zuijiu')) {
							var zuijiuEffect:Thing=new Thing();
							zuijiuEffect.name="zuijiu";
							zuijiuEffect.x=-10;
							zuijiuEffect.y=-140;
							avatar._effectLayerTop.addChild(zuijiuEffect);
							zuijiuEffect.load(GameConfig.OTHER_PATH + 'zuijiu.swf');
							zuijiuEffect.play(8, true);
						}
						break;
				}
			}
		}
		
		override public function removeBuff(value:Array):void {
			for (var i:int=0; i < value.length; i++) {
				var vo:p_actor_buf=value[i] as p_actor_buf;
				switch (vo.buff_type) {
					case 31: //中毒
						avatar.colorFilter(1, 1, 1);
						break;
					case 33: //%%定身，无法移动，可以使用技能和道具
						break;
					case 34: //%%麻痹，移动速度下降，无法使用技能
						break;
					case 36: //隐身
						conceal(false, true);
						break;
					case 37: //反隐身
						SkillModule.getInstance().antiStealth(false);
						break;
					case 32: //%%晕迷，无法移动，无法使用技能和道具
					case 35: //%%混乱状态，不受角色控制一段时间
					case 85: //%%镶嵌晕眩
						Dispatch.dispatch(ModuleCommand.USEGOODS_ENABLE, {enabled: true, desc: '晕迷状态结束'});
						underControl=true;
						break;
					case 86:
						avatar.colorFilter(1, 1, 1);
						break;
					case 87:
						avatar.colorFilter(1, 1, 1);
						break;
					case 1003:
						avatar.isTransform=false;
						avatar.updataSkin(skinData);
						var status:int=GlobalObjectManager.getInstance().user.base.status;
						if (status == RoleActState.ON_HOOK || status == RoleActState.STALL || status == RoleActState.TRAINING) {
							sitDown(true);
						}
						break;
					case 1034: //荆棘陷阱
						var thing:DisplayObject=avatar._effectLayerTop.getChildByName("jing_ji_xian_jing");
						if (thing) {
							avatar._effectLayerTop.removeChild(thing);
						}
						break;
					case 1035:
						if (SystemConfig.openEffect && avatar && avatar._effectLayerTop.getChildByName('zuijiu')) {
							thing=avatar._effectLayerTop.getChildByName('zuijiu')
							avatar._effectLayerTop.removeChild(thing);
						}
						break;
				}
			}
		}
		
		public function showGuaJi(value:Boolean):void {
			if (value == true) {
				showAutoRun(false);
				if (guaji == null) {
					guaji=new GuajiTxt;
				}
				guaji.y=names.y - names.height - 10;
				addChild(guaji);
				guaji.gjPlay();
			} else {
				if (guaji != null && guaji.parent != null) {
					guaji.gjRemove();
				}
			}
		}
		
		public function showAutoRun(value:Boolean):void {
			if (value) {
				showGuaJi(false);
				if (autoRunTxt == null) {
					autoRunTxt=new AutoRunTxt;
				}
				autoRunTxt.y=names.y - names.height - 26;
				addChild(autoRunTxt);
				autoRunTxt.zdxlPlay();
			} else {
				if (autoRunTxt != null) {
					if (autoRunTxt.parent) {
						autoRunTxt.parent.removeChild(autoRunTxt);
						autoRunTxt.zdxlRemove();
					}
				}
			}
		}
		
		/**
		 * 是否处于空闲站立状态
		 * @return
		 *
		 */
		public function isStanding():Boolean {
			//			var b:Boolean;
			//			if ((path == null || path.length == 0) && curState == RoleActState.NORMAL) {
			//				b=true;
			//			} else {
			//				b=false;
			//			} 
			//			return b;
			return curState == RoleActState.NORMAL;
		}
		
		public function doStall(stall:Boolean, stallName:String=""):void {
			if (stall == true) {
				curState=RoleActState.STALL;
				if (board == null) {
					board=new StallBoard(stallName);
					board.y=-10;
				}
				if (this.contains(board) == false) {
					addChild(board);
				}
			} else {
				curState=RoleActState.NORMAL;
				if (board != null && this.contains(board) == true) {
					removeChild(board);
				}
			}
			sitDown(stall);
		}
		
		public function doTraining(value:Boolean):void {
			if (value == true) {
				curState=RoleActState.TRAINING;
				
				if (!training) {
					training=new TrainingLight;
				}
				addChildAt(training, 0);
			} else {
				curState=RoleActState.NORMAL;
				
				if (training)
					training.remove();
			}
			resetUnderControl(!value);
			sitDown(value);
		}
		
		public function doHook(value:Boolean):void {
			if (value == true) {
				curState=RoleActState.ON_HOOK;
				if (training == null) {
					training=new TrainingLight();
				}
				addChildAt(training, 0);
			} else {
				curState=RoleActState.NORMAL;
				if (training != null) {
					training.remove();
				}
			}
			resetUnderControl(!value);
			sitDown(value);
		}
		
		public function doNameJob():void {
			names.reset(pvo);
		}
		
		public function set pvo(value:p_map_role):void {
			$pvo=value;
			if (pvo.state != RoleActState.TRAINING && value.state == RoleActState.TRAINING) {
				doTraining(true);
			}
			if (pvo.state == RoleActState.TRAINING && value.state != RoleActState.TRAINING) {
				doTraining(false);
			}
			$pvo=pvo;
			if (speed != $pvo.move_speed) {
				speed=$pvo.move_speed;
				if (pvo.state != RoleActState.ZAZEN && pvo.state != RoleActState.TRAINING && pvo.state != RoleActState.STALL && pvo.state != RoleActState.ON_HOOK) {
					rerun();
				}
			}
			createBuff($pvo.state_buffs);
			avatar.updataSkin($pvo.skin);
			names.reset($pvo);
			doNameJob();
			if (SystemConfig.showClothing == true) {
				avatar.isNude=!$pvo.show_cloth;
			}
			checkEquipRing();
			checkMountRing();
			checkCollectState();
		}
		
		private var _collectState:Thing
		
		public function checkCollectState():void {
			if (pvo.state == RoleActState.COLLECTING && CollectModule.catchTypeIds.indexOf(CollectModule.selectTypeID) == -1) {
				if (!_collectState) {
					_collectState=new Thing();
					_collectState.load(GameConfig.MOUSE_ICON_PATH + "shouji.swf");
					_collectState.gotoAndStop(0);
					addChild(_collectState);
					_collectState.y=-150;
				}
			} else {
				if (_collectState) {
					_collectState.unload();
					_collectState=null;
				}
			}
		}
		
		public function showCloth(value:Boolean):void {
			if (value == true) {
				if ($pvo && $pvo.show_cloth == true) {
					avatar.isNude=false;
				}
			} else {
				avatar.isNude=true;
			}
		}
		
		public function get pvo():p_map_role {
			return $pvo;
		}
		
		override public function remove():void {
			arriveAction=null;
			super.remove();
		}
		private var effect:Effect;
		
		/**
		 * 大表情显示
		 * @param expresionId
		 *
		 */
		public function expresion(expresionId:int):void {
			if (effect && effect.parent) {
				effect.parent.removeChild(effect);
			}
			effect=new Effect();
			effect.show(GameConfig.FACE_PATH + expresionId + '.swf', 0, names.y - names.height - 10, this, 8, 0, true, 9000);
		}
		
		public function checkEquipRing():void {
			if (pvo.show_equip_ring && pvo.equip_ring_color != 0) {
				showEquipRing(pvo.equip_ring_color);
			} else {
				hideEquipRing();
			}
		}
		
		private var _equipRing:Thing;
		
		public function showEquipRing(value:int):void {
			if (_equipRing) {
				var url:String;
				switch (value) {
					case 1:
						url=GameConfig.OTHER_PATH + 'zhuangbei_zise.swf';
						break;
					case 2:
						url=GameConfig.OTHER_PATH + 'zhuangbei_chengse.swf';
						break;
					case 3:
						url=GameConfig.OTHER_PATH + 'zhuangbei_jinse.swf';
						break;
				}
				if (url != _equipRing.path) {
					hideEquipRing();
				} else {
					return;
				}
			}
			_equipRing=new Thing();
			switch (value) {
				case 1:
					_equipRing.load(GameConfig.OTHER_PATH + 'zhuangbei_zise.swf');
					break;
				case 2:
					_equipRing.load(GameConfig.OTHER_PATH + 'zhuangbei_chengse.swf');
					break;
				case 3:
					_equipRing.load(GameConfig.OTHER_PATH + 'zhuangbei_jinse.swf');
					break;
			}
			_equipRing.play(8, true);
			addChild(_equipRing);
			if (avatar.selectState == AvatarConstant.ACTION_SIT) {
				_equipRing.y+=50;
			}
		}
		
		public function hideEquipRing():void {
			if (_equipRing) {
				_equipRing.stop();
				_equipRing.unload();
				_equipRing=null;
			}
		}
		
		public function checkMountRing():void {
			if (pvo.skin.mounts != 0) {
				showMountRing(pvo.mount_color);
			} else {
				hideMountRing();
			}
		}
		
		private var _mountRing:Thing;
		
		public function showMountRing(value:int):void {
			if (_mountRing) {
				var url:String;
				switch (value) {
					case 4:
						url=GameConfig.ROOT_URL + 'com/ui/effect/mount/mount_Zi.swf';
						break;
					case 5:
						url=GameConfig.ROOT_URL + 'com/ui/effect/mount/mount_Cheng.swf';
						break;
				}
				if (url != _mountRing.path) {
					hideMountRing();
				} else {
					return;
				}
			}
			_mountRing=new Thing();
			switch (value) {
				case 4:
					_mountRing.load(GameConfig.ROOT_URL + 'com/ui/effect/mount/mount_Zi.swf');
					break;
				case 5:
					_mountRing.load(GameConfig.ROOT_URL + 'com/ui/effect/mount/mount_Cheng.swf');
					break;
			}
			_mountRing.play(6, true);
			avatar._effectLayerBottom.addChild(_mountRing);
		}
		
		public function hideMountRing():void {
			if (_mountRing) {
				_mountRing.stop();
				_mountRing.unload();
				_mountRing=null;
			}
		}
		
		override public function play($state:String, $dir:int, $speed:int):void {
			super.play($state, $dir, $speed);
			
			if (_equipRing) {
				if ($state == AvatarConstant.ACTION_SIT) {
					_equipRing.y=50;
				} else {
					_equipRing.y=0;
				}
			}
		}
		
		override protected function playSitEffect():void{
			super.playSitEffect();
			names.y = names.y - 30;
		}
		
		override protected function removeSitEffect():void{
			super.removeSitEffect();
			names.y = names.y + 30;
		}
	}
}
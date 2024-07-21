package com.scene.sceneUnit {
	import com.common.GameColors;
	import com.common.cursor.CursorManager;
	import com.common.cursor.CursorName;
	import com.globals.GameConfig;
	import com.gs.Quadratic;
	import com.gs.TweenMax;
	import com.scene.sceneKit.RoleNameItem;
	import com.scene.sceneManager.UnitPool;
	import com.scene.sceneUnit.baseUnit.MutualThing;
	import com.scene.sceneUnit.baseUnit.things.ThingsEvent;
	import com.scene.sceneUtils.SceneUnitType;
	import com.utils.HtmlUtil;
	
	import modules.mypackage.ItemConstant;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	import modules.mypackage.vo.GeneralVO;
	import modules.mypackage.vo.StoneVO;
	import modules.scene.SceneModule;
	import modules.scene.cases.MyRoleControler;
	
	import proto.common.p_map_dropthing;

	public class DropThing extends MutualThing {
		private var _pvo:p_map_dropthing;
		private var nameTxt:RoleNameItem;
		private var pickAbled:Boolean=true;
		private var startY:Number;

		public function DropThing() {
			sceneType=SceneUnitType.DROP_THING_TYPE;
			super();
		}

		public function reset(vo:p_map_dropthing):void {
			id=vo.id;
			_pvo=vo;
			if (nameTxt == null) {
				nameTxt=new RoleNameItem();
			}
			var name:String=getItemName(vo);
			var color:String=GameColors.getHtmlColorByIndex(vo.colour);
			nameTxt.setHtmlText(HtmlUtil.font(name, color));
			nameTxt.y=-50;
			addChild(nameTxt);
			var skinURL:String=getURL(vo);
			_thing == null ? init(skinURL) : _thing.load(skinURL);
		}

		override protected function onLoadComplete(e:ThingsEvent):void {
			super.onLoadComplete(e);
			nameTxt.y=-int(e.data) - 20;
		}

		public function set showName(value:Boolean):void {
			nameTxt.visible=value;
		}

		public function pickFail():void {
			if (pickAbled) {
				startY=this._thing.y;
				pickAbled=false;
				TweenMax.to(this._thing, 0.3, {y: startY - 60, ease: Quadratic.easeOut, onComplete: onTop});
			}
		}

		private function onTop():void {
			TweenMax.to(this._thing, 0.25, {y: startY, ease: Quadratic.easeIn, onComplete: function onDown():void {
					pickAbled=true;
				}});
		}

		public function get pvo():p_map_dropthing {
			return _pvo;
		}

		override public function mouseOver():void {
			super.mouseOver();
			if (SceneModule.isFollowFoot == false && SceneModule.isLookInfo == false) {
				CursorManager.getInstance().setCursor(CursorName.PICK);
			}
		}

		override public function mouseOut():void {
			super.mouseOut();
			if (SceneModule.isFollowFoot == false && SceneModule.isLookInfo == false) {
				CursorManager.getInstance().clearAllCursor();
			}
		}

		override public function mouseDown():void {
			MyRoleControler.getInstance().onClickUnit(this);
		}

		override public function remove():void {
			super.remove();
			UnitPool.disposeDropThing(this);
		}

		private static function getItemName(vo:p_map_dropthing):String {
			var item_name:String;
			if (vo.ismoney == false) {
				item_name=ItemLocator.getInstance().getObject(vo.goodstypeid).name;
			} else {
				if (vo.money <= 1) {
					item_name="少量银子";
				} else if (vo.money > 1 && vo.money <= 1000) {
					item_name="一些银子";
				} else if (vo.money > 1000 && vo.money <= 3000) {
					item_name="许多银子";
				} else if (vo.money > 3000 && vo.money <= 10000) {
					item_name="大量银子";
				} else if (vo.money > 10000) {
					item_name="海量银子";
				}
			}
			return item_name;
		}

		public static function getURL(vo:p_map_dropthing):String {
			var url:String=GameConfig.DROP_ITEM_ICON;
			if (vo.ismoney == true) {
				url+='yinzi.swf';
			} else {
				var itemvo:BaseItemVO=ItemLocator.getInstance().getObject(vo.goodstypeid);
				if (itemvo is EquipVO) {
					var putWhere:int=EquipVO(itemvo).putWhere;
					if (putWhere == 1) {
						switch (EquipVO(itemvo).kind) {
							case 101:
								url+="dao.swf"
								break;
							case 102:
								url+="gong.swf"
								break;
							case 103:
								url+="zhan.swf"
								break;
							case 104:
								url+="shan.swf"
								break;
							default:
								url+="zawu.swf"
								break;
						}
					} else {
						switch (EquipVO(itemvo).putWhere) {
							case 2:
								url+="xianglian.swf";
								break;
							case 3:
								url+="jiezhi.swf";
								break;
							case 4:
								url+="toukui.swf";
								break;
							case 5:
								if (EquipVO(itemvo).sex == 1) {
									url+="nanhujia.swf";
								} else {
									url+="nvhujia.swf";
								}
								break;
							case 6:
								url+="yaodai.swf";
								break;
							case 7:
								url+="huwan.swf";
								break;
							case 8:
								url+="xuezi.swf";
								break;
							case 9:
								url+="dunpai.swf"; //副手武器
								break;
							case 10:
								url+="zawu.swf"; //挂饰
								break;
							case 11:
								url+="zawu.swf"; //时装
								break;
							default:
								url+="zawu.swf"
								break;
						}
					}
				} else if (itemvo is GeneralVO) {
					if (GeneralVO(itemvo).effectType == ItemConstant.EFFECT_HP) {
						url+="hongyao.swf";
					} else if (GeneralVO(itemvo).effectType == ItemConstant.EFFECT_MP) {
						url+="lanyao.swf";
					} else if (GeneralVO(itemvo).effectType == ItemConstant.EFFECT_SUPER_HP) {
						url+="chaojihongyao.swf";
					} else if (GeneralVO(itemvo).effectType == ItemConstant.EFFECT_YP) {
						url+="yinpiao.swf";
					} else if (GeneralVO(itemvo).effectType == 10) {
						url+="yuanxiaoshicai.swf";
					} else if (GeneralVO(itemvo).kind == ItemConstant.KIND_GIFT_BAG) {
						url+="libao.swf";
					} else if (GeneralVO(itemvo).kind == ItemConstant.KIND_BOOK) {
						url+="shuji.swf";
					} else if (GeneralVO(itemvo).kind == ItemConstant.KIND_MATERIAL) {
						url+="cailiao.swf";
					} else if (GeneralVO(itemvo).kind == ItemConstant.KIND_PACK) {
						url+="baoguo.swf";
					} else if (GeneralVO(itemvo).kind == ItemConstant.KIND_HIEROGRAM) {
						url+="lingfu.swf";
					} else if (GeneralVO(itemvo).kind == ItemConstant.KIND_GIFT_BAG) {
						url+="libao.swf";
					} else {
						url+="zawu.swf";
					}
				} else if (itemvo is StoneVO) {
					url+="lingshi.swf";
				} else {
					url+="zawu.swf";
				}
			}
			return url;
		}
	}
}

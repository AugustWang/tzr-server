package com.scene.sceneKit {

	import com.common.GameConstant;
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.ming.ui.controls.Image;
	import com.scene.sceneUnit.baseUnit.things.ThingsEvent;
	import com.scene.sceneUnit.baseUnit.things.thing.Thing;
	import com.scene.sceneUtils.RoleActState;
	import com.utils.HtmlUtil;

	import flash.display.Sprite;

	import modules.chat.TitlePool;
	import modules.scene.SceneDataManager;
	import modules.system.SystemConfig;

	import proto.common.p_map_role;

	public class RoleNames extends Sprite {
		private static const picTitles:Array=["护花使者", "鲜花宝贝", "鲜花公主", "至尊情圣", "云州王", "沧州王", "幽州王"];
		private static const titleURLS:Array=["hhsz.swf", "xhbb.swf", "xhgz.swf", "zzqs.swf", "dqw.swf", "xcw.swf", "nhw.swf"];
		protected var $AName:RoleNameItem; //名字
		protected var $BName:RoleNameItem; //门派
		protected var $CName:RoleNameItem; //称号
		protected var $title:RoleImageTitle; //图片称号
		private var _role_name:String;
		private var _teamID:int;
		private var _teamFlag:Sprite;
		private var _vipIcon:String="VIP"; //#F1BC21
		private var _faction_id:int;
		private var _family_name:String;
		private var _cur_title:String;
		private var titleIndex:int; //是否使用了图片的称号
		private var _vipLevel:int;
		private var vipImage:Image;
		private var teamImage:Image;

		public function RoleNames(vo:p_map_role):void {
			super();
			$AName=new RoleNameItem(vo.role_name + "[" + GameConstant.getNation(vo.faction_id) + "]");
			$BName=new RoleNameItem(vo.family_name + "(门)");
			$CName=new RoleNameItem(vo.cur_title);
			addChild($AName);
			addChild($BName);
			addChild($CName);
			setColor(0xffffff);
			titleIndex=picTitles.indexOf(vo.cur_title); //蛋疼的后台不提供是否是图片称号的依据，只能靠对比字符串了
			if (titleIndex != -1) { //如果是图片称号
				initPicTitle();
				var titleURL:String=GameConfig.ROOT_URL + "com/assets/titleImage/" + titleURLS[titleIndex];
				$title.load(titleURL);
				$title.gotoAndStop(0);
			}
			update();
		}

		private function setTeamFlag(show:Boolean, x:Number=0, y:Number=0):void {
			if (show == true) {
				if (teamImage == null) {
					teamImage=new Image;
					addChild(teamImage);
					var url:String=GameConfig.ROOT_URL + "com/assets/team.png";
					teamImage.source=url;
				}
				teamImage.visible=true;
				teamImage.x=x;
				teamImage.y=y;
			} else {
				if (teamImage) {
					teamImage.visible=false;
				}
			}
		}



		private function setVIP(show:Boolean, x:Number=0, y:Number=0):void {
			if (show == true) {
				if (vipImage == null) {
					vipImage=new Image;
					addChild(vipImage);
				}
				var url:String=GameConfig.ROOT_URL + "com/assets/vip/vip" + _vipLevel + ".png";
				if (_vipLevel > 0) {
					if (vipImage.source != url) {
						vipImage.source=url
					}
					vipImage.visible=true;
					vipImage.x=x;
					vipImage.y=y;
				}
			} else {
				if (vipImage) {
					vipImage.visible=false;
				}
			}
		}

		private function initPicTitle():void {
			if ($title == null) {
				$title=new RoleImageTitle();
				$title.addEventListener(ThingsEvent.THING_LOAD_COMPLETE, update);
				addChild($title);
			}
		}

		public function reset(vo:p_map_role):void {
			if (vo.role_name != _role_name || vo.faction_id != _faction_id || vo.team_id != _teamID || vo.vip_level != _vipLevel) {
				_role_name=vo.role_name;
				_faction_id=vo.faction_id;
				_teamID=vo.team_id;
				_vipLevel=vo.vip_level;
				$AName.setHtmlText(vo.role_name + "[" + GameConstant.getNation(vo.faction_id) + "]");
//					$AName.setHtmlText(_vipIcon + vo.vip_level + vo.role_name + "[" + GameConstant.getNation(vo.faction_id) + "]");
				if (vo.vip_level > 0) {
					setVIP(true, $AName.x - 35, $AName.y + 4);
				} else {
					setVIP(false);
				}
				if (_teamID > 0 && _faction_id == GlobalObjectManager.getInstance().getRoleFactionID()) {
					setTeamFlag(true, $AName.x + $AName.width, $AName.y + 4);
				} else {
					setTeamFlag(false);
				}
			}
			if (vo.family_name != _family_name) {
				_family_name=vo.family_name;
				$BName.setHtmlText(vo.family_name + "(门)");
			}
			if (vo.cur_title == "") {
				vo.cur_title="天之刃";
			}
			if (vo.cur_title != _cur_title) {
				_cur_title=vo.cur_title;
				$CName.setHtmlText(vo.cur_title);
				titleIndex=picTitles.indexOf(vo.cur_title);
				if (titleIndex != -1) { //如果是图片称号
					initPicTitle();
					$CName.visible=false;
					var titleURL:String=GameConfig.ROOT_URL + "com/assets/titleImage/" + titleURLS[titleIndex];
					$title.stop();
					$title.load(titleURL);
					$title.gotoAndStop(0);
				} else {
					if ($title) {
						$title.visible=false;
					}
				}
			}
			if (vo.family_id > 0 && SystemConfig.showFmaily == true) {
				showFamily();
			} else {
				hideFamily();
			}
			if (vo.cur_title == "" || vo.cur_title == "无") {
				hideTitle();
			} else {
				showTitle();
			}
			//是否在需要所有名称统一颜色的地图,比如王座争霸战
			var isSpecialMap:Boolean=SceneDataManager.isRobKingMap;
			var color:uint=0xFFFFFF;
			if (isSpecialMap == false) {
				if (vo != null) {
					if (vo.faction_id != GlobalObjectManager.getInstance().user.base.faction_id) {
						color=0xFF00AA;
						setColor(0xFF00AA);
						return;
					} else {
						if (vo.pk_point == 0) {
							color=0x00FF99;
						}
						if (vo.gray_name) {
							color=0xaaaaaa;
						} else {
							if (vo.pk_point > 0 && vo.pk_point < 18) {
								color=0xd45c0c;
							}
						}
						if (vo.pk_point >= 18) {
							color=0xff0000;
						}
					}
				}
				setRoleNameColor(color);
				var titleColor:uint=uint("0x" + vo.cur_title_color);
				var titleVo:Object=TitlePool.getInstance().getObject(vo.cur_title);
				if (titleVo) {
					titleColor=uint("0x" + titleVo.color);
				} else {
					titleColor=0x0d79ff;
				}
				setTitleNameColor(titleColor);

			} else {
				if (vo.family_id == GlobalObjectManager.getInstance().user.base.family_id) {
					color=0x00ff00;
				} else {
					color=0xff0000;
				}
				setColor(color);
			}
			if (SystemConfig.showRoleInfo == true && vo.state != RoleActState.STALL) {
				visible=true;
			} else {
				visible=false;
			}
		}

		public function hideFamily():void {
			$BName.visible=false;
			update();
		}

		public function showFamily():void {
			$BName.visible=true;
			update();
		}

		public function hideTitle():void {
			$CName.visible=false;
			if ($title != null) {
				$title.visible=false;
			}
			update();
		}

		public function showTitle():void {
			if (titleIndex == -1) {
				$CName.visible=true;
			} else {
				if ($title != null) {
					$title.visible=true;
				}
			}
			update();
		}

		private function changeNameColor(color:uint):void {
			var s:String=$AName.text;
			var index:int=s.indexOf(_vipIcon);
			if (index != -1) {
				var nameStr:String=s.substring(4, s.length);
				$AName.setHtmlText(HtmlUtil.font(HtmlUtil.bold(_vipIcon), "#F1BC21", 10) + HtmlUtil.font(HtmlUtil.bold(_vipLevel.toString()), "#F1BC21", 14) + HtmlUtil.font2(nameStr, color));
			} else {
				$AName.setHtmlText(HtmlUtil.font2(s, color));
			}
		}

		public function setRoleNameColor(color:uint):void {
			$AName.textColor=color;
//			changeNameColor(color);
		}

		public function setTitleNameColor(color:uint):void {
			$CName.textColor=color;
		}

		public function setColor(color:uint):void {
			$AName.textColor=color;
//			changeNameColor(color);
			$BName.textColor=color;
			$CName.textColor=color;
		}

		//处理位置而已
		public function update(e:ThingsEvent=null):void {
			$BName.y=$AName.y - 18;
			var cy:Number=$BName.visible == true ? ($AName.y - 18 * 2) : ($AName.y - 18);
			$CName.y=cy;
			if (titleIndex != -1 && $title != null) {
				$title.y=cy + 20;
			}
		}

		public function unload():void {
			if ($title) {
				$title.unload();
				$title=null;
			}
			while (this.numChildren > 0) {
				this.removeChildAt(0);
			}
			$AName=null;
			$BName=null;
			$CName=null;
			if (this.parent != null) {
				this.parent.removeChild(this);
			}
		}
	}
}
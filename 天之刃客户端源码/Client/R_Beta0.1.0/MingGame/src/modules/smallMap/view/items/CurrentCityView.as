package modules.smallMap.view.items {
	import com.common.FilterCommon;
	import com.common.GlobalObjectManager;
	import com.common.cursor.CursorManager;
	import com.globals.GameConfig;
	import com.loaders.ResourcePool;
	import com.managers.Dispatch;
	import com.ming.events.ItemEvent;
	import com.ming.events.TabNavigationEvent;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.containers.treeList.BranchNode;
	import com.ming.ui.containers.treeList.LeafNode;
	import com.ming.ui.containers.treeList.Tree;
	import com.ming.ui.containers.treeList.TreeDataProvider;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.CheckBox;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.TabBar;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.ToolTip;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.Skin;
	import com.scene.WorldManager;
	import com.scene.sceneData.CityVo;
	import com.scene.sceneData.MacroPathVo;
	import com.scene.sceneData.MapElementVo;
	import com.scene.sceneData.MapTransferVo;
	import com.scene.sceneData.NPCVo;
	import com.scene.sceneData.RunVo;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneManager.NPCTeamManager;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneUnit.IMutualUnit;
	import com.scene.sceneUnit.IRole;
	import com.scene.sceneUnit.NPC;
	import com.scene.sceneUnit.Role;
	import com.scene.sceneUnit.Waiter;
	import com.scene.sceneUnit.YBC;
	import com.scene.sceneUnit.configs.MonsterConfig;
	import com.scene.sceneUnit.configs.MonsterType;
	import com.scene.tile.Pt;
	import com.scene.tile.TileUitls;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	import com.utils.ObjectUtils;
	import com.utils.PathUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.CapsStyle;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	import flashx.textLayout.formats.WhiteSpaceCollapse;
	
	import modules.ModuleCommand;
	import modules.npc.NPCDataManager;
	import modules.scene.SceneDataManager;
	import modules.smallMap.SmallMapDataManager;
	import modules.smallMap.SmallMapModule;
	import modules.smallMap.view.SmallSceneView;
	import modules.team.TeamDataManager;
	
	import mx.core.mx_internal;
	
	import proto.common.p_map_role;
	import proto.common.p_map_ybc;
	import proto.common.p_role_base;
	import proto.line.m_map_transfer_tos;
	import proto.line.p_team_role;

	public class CurrentCityView extends Sprite {
		private static const IMGWITH:int=557;
		private static const IMGHEIGHT:int=376;
		private var cityBG:UIComponent
		private var mapNametxt:TextInput;
		private var mapContaner:Sprite
		private var mapBitmap:Bitmap;
		private var inputX:TextInput;
		private var inputY:TextInput;
		private var go:Button;
		private var tabBar:TabBar;
		private var npcTree:Tree;
		private var turnTree:Tree;
		private var map:Sprite;
		private var spriteMonster:Sprite;//怪物
		private var spriteNPCName:Sprite;//npc名字
		private var shapeOther:Shape; //画别人
		private var shapeSelf:Shape; //画自己
		public var shapeYBC:Shape; //画骠车
		private var shapeRoad:Shape; //画路径
		private var city:CityVo;
		private var isRoadFinish:Boolean=true;
		private var roadEndPoint:Pt; //路的终点
		private var ptsMsg:Array; //NPC,跳转点的位置信息
		private var teamMsg:Array; //同地图队员位置信息
		
		private var npcChk:CheckBox;
		private var monsterChk:CheckBox;
		private var playerChk:CheckBox;

		public function CurrentCityView() {
			super();
			initView();
		}

		private function initView():void {
			var startX:int=570;
			npcChk = ComponentUtil.createCheckBox("NPC",startX,5,this);
			npcChk.textFilter = FilterCommon.FONT_BLACK_FILTERS;
			npcChk.setSelected(true);
			npcChk.addEventListener(Event.CHANGE,drawNPC);
			monsterChk = ComponentUtil.createCheckBox("怪物",startX+52,5,this);
			monsterChk.textFilter = FilterCommon.FONT_BLACK_FILTERS;
			monsterChk.setSelected(true);
			monsterChk.addEventListener(Event.CHANGE,onMonsterChkChange);
			playerChk = ComponentUtil.createCheckBox("玩家",startX+104,5,this);
			playerChk.textFilter = FilterCommon.FONT_BLACK_FILTERS;
			playerChk.setSelected(true);
			//当前地图左边背景
			mapNametxt=ComponentUtil.createTextInput(260, -21, 135, 24, this);
			mapNametxt.mouseEnabled=mapNametxt.mouseChildren=false;
			cityBG = new UIComponent();
			Style.setBorderSkin(cityBG);
			cityBG.width = 567;
			cityBG.height = 386;
			addChild(cityBG);
			
			mapBitmap =new Bitmap;
			mapContaner =new Sprite();
			mapContaner.x=5;
			mapContaner.y=5;
			mapContaner.addChild(mapBitmap);
			var mask:Shape = new Shape();
			mask.graphics.beginFill(0x000000);
			mask.graphics.drawRoundRect(0,0,IMGWITH,IMGHEIGHT,15);
			mapBitmap.mask=mask;
			mapContaner.addChild(mask);
			cityBG.addChild(mapContaner);
			
			mapContaner.addEventListener(MouseEvent.CLICK, onClickMap);
			mapContaner.addEventListener(MouseEvent.MOUSE_MOVE, onMouseOver);
			mapContaner.addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
			
			var bg2:Sprite=new Sprite();
			bg2.x=startX;
			bg2.y=3;
			
			addChild(bg2);
			map=new Sprite;
			map.mouseChildren=map.mouseEnabled=false;
			cityBG.addChild(map);
			spriteMonster=new Sprite();
			spriteNPCName=new Sprite(); //npc 圈 
			shapeOther=new Shape; //画别人
			shapeSelf=new Shape; //画自己
			shapeYBC=new Shape; //画骠车
			shapeRoad=new Shape; //画路径
			shapeRoad.filters=[new GlowFilter(0x4c4432, 1, 2, 2, 20)];
			map.addChild(spriteMonster);
			map.addChild(spriteNPCName);
			map.addChild(shapeOther);
			map.addChild(shapeYBC);
			map.addChild(shapeRoad);
			map.addChild(shapeSelf);
			var tf:TextFormat=new TextFormat(null, null, 0xffff00);
			var xtext:TextField = ComponentUtil.createTextField("X:", 2, 30, tf, 30, 20, bg2);
			xtext.filters = FilterCommon.FONT_BLACK_FILTERS;
			var ytext:TextField = ComponentUtil.createTextField("Y:", 82, 30, tf, 30, 20, bg2);
			ytext.filters = FilterCommon.FONT_BLACK_FILTERS;
			
			inputX=ComponentUtil.createTextInput(20, 25, 50, 23, bg2);
			inputX.restrict="[0-9]";
			inputX.maxChars=3;
			inputY=ComponentUtil.createTextInput(100,25, 50, 23, bg2);
			inputY.restrict="[0-9]";
			inputY.maxChars=3;
			bg2.addChild(inputX);
			bg2.addChild(inputY);
			go=ComponentUtil.createButton("立即前往", 40, 53, 80, 25, bg2);
			go.addEventListener(MouseEvent.CLICK, onClickGo);
			tabBar=new TabBar();
			tabBar.addItem('NPC', 65, 21);
			tabBar.addItem('跳转点', 65, 21);
			tabBar.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED, onChange);
			tabBar.x = 16;
			tabBar.y = 86;
			bg2.addChild(tabBar);
			var treeBg:Skin = Style.getSkin("contentBg", GameConfig.T1_VIEWUI, new Rectangle(10, 10, 120, 104));
			treeBg.mouseChildren = true;
			treeBg.y = 104;
			treeBg.setSize(162,279);
			bg2.addChild(treeBg);
			npcTree=new Tree;
			npcTree.x=1;
			npcTree.y=5;
			npcTree.width=157;
			npcTree.height=268;
			npcTree.cellRenderer=MaptreeITem;
			turnTree=new Tree;
			turnTree.x=1;
			turnTree.y=5;
			turnTree.width=157;
			turnTree.height=268;
			turnTree.cellRenderer=MaptreeITem;
			treeBg.addChild(npcTree);
			treeBg.addChild(turnTree);
			npcTree.addEventListener(ItemEvent.ITEM_CLICK, onClickNPC);
			npcTree.addEventListener(ItemEvent.ITEM_DOUBLE_CLICK, onDoubleClickNPC);
			turnTree.addEventListener(ItemEvent.ITEM_CLICK, onClickTurn);
			turnTree.addEventListener(ItemEvent.ITEM_DOUBLE_CLICK, onDoubleClickTurn);
			turnTree.visible=false;
		}
				
		private function onChange(e:TabNavigationEvent):void {
			if (e.index == 0) {
				npcTree.visible=true;
				turnTree.visible=false;
			} else {
				npcTree.visible=false;
				turnTree.visible=true;
			}
		}

		private function onClickMap(e:MouseEvent):void {
			var mx:Number=mapBitmap.mouseX;
			var my:Number=mapBitmap.mouseY;
			if (mapBitmap.mouseX < city.posx) { //在边缘外面的处理
				my=city.posx;
			} else if (mapBitmap.mouseX > IMGWITH - city.posx) {
				my=IMGWITH - city.posx;
			}
			if (mapBitmap.mouseY < city.posy) {
				my=city.posy;
			} else if (mapBitmap.mouseY > IMGHEIGHT - city.posy) {
				my=IMGHEIGHT - city.posy;
			}
			var cx:Number=(mx - city.posx) / city.scale - SceneDataManager.offsetX;
			var cy:Number=(my - city.posy) / city.scale - SceneDataManager.offsetY;
			var pt:Pt=TileUitls.getIndex(new Point(cx, cy));
			if (SmallSceneView.isJump) {
				var vo:m_map_transfer_tos=new m_map_transfer_tos;
				vo.mapid=SceneDataManager.mapID;
				vo.tx=pt.x;
				vo.ty=pt.z;
				Dispatch.dispatch(ModuleCommand.REQUEST_JUMP_POS, vo);
				SmallMapModule.getInstance().resetTransferBtn(false);
			} else {
				var runvo:RunVo=new RunVo();
				runvo.pt=pt;
				Dispatch.dispatch(ModuleCommand.ROLE_MOVE_TO, runvo);
			}
		}

		private function onClickGo(e:MouseEvent):void {
			var runVo:RunVo=new RunVo();
			runVo.pt=new Pt(int(inputX.text), 0, int(inputY.text));
			Dispatch.dispatch(ModuleCommand.ROLE_MOVE_TO, runVo);
		}

		public function onSmallMapComplete(bmd:BitmapData):void {
			mapBitmap.bitmapData=bmd;
			mapContaner.x = cityBG.width - bmd.width >> 1;
			mapContaner.y = cityBG.height - bmd.height >> 1;
			map.x = mapContaner.x;
			map.y = mapContaner.y;
		}

		//切地图时重置NPC点和跳转点
		public function reset():void {
			LoopManager.setTimeout(function rename():void {
					mapNametxt.textField.htmlText='<p align="center"><FONT COLOR="#FFFFFF">' + WorldManager.getCurrentCity().name + '</FONT></p>';
				}, 1000);

//			var mapURL:String=WorldManager.getCurrentCity().url;
//			var bgPath:String=GameConfig.ROOT_URL + mapURL + '/view.jpg';
//			img.source=bgPath;
			spriteNPCName.graphics.clear();
			city=WorldManager.getCurrentCity();
			var npcArr:Array=SceneDataManager.npcs;
			var npcProvider:TreeDataProvider=new TreeDataProvider;
			var funNode:BranchNode=new BranchNode(npcProvider);
			var talkNode:BranchNode=new BranchNode(npcProvider);
			npcProvider.addItem(funNode);
			npcProvider.addItem(talkNode);
			funNode.data="功能NPC";
			talkNode.data="对话NPC";
			funNode.openNode();
			talkNode.openNode();
			var turnProvider:TreeDataProvider=new TreeDataProvider;
			var turnNode:BranchNode=new BranchNode(turnProvider);
			turnProvider.addItem(turnNode);
			turnNode.data="跳转点";
			turnNode.openNode();
			var leaf:LeafNode;
			var point:Point;
			ptsMsg=[]; //记录NPC点,跳转点信息
			teamMsg=[];
			var rect:Rectangle; //点的矩形
			var msg:String; //点的信息
			var pt:Pt;
			var npcName:TextField;
			while(spriteNPCName.numChildren){
				spriteNPCName.removeChildAt(0);
			}
			for (var i:int; i < npcArr.length; i++) {
				var npc:MapElementVo=npcArr[i];
				if(npcChk.selected){
					pt=new Pt(npc.tx, 0, npc.ty);
					point=TileUitls.getIsoIndexMidVertex(pt);
					point.x=city.posx + (point.x + SceneDataManager.offsetX) * city.scale;
					point.y=city.posy + (point.y + SceneDataManager.offsetY) * city.scale;
					npcName = ComponentUtil.createTextField("",0,0,Style.textFormat);
					npcName.filters = Style.textBlackFilter;
					npcName.y = point.y - 20;
					npcName.x = point.x;
					spriteNPCName.addChild(npcName);
					draw(point.x, point.y, 9, 4, spriteNPCName.graphics);
				}
				var npcvo:NPCVo=new NPCVo;
				npcvo.setUP(pt, npc.id);
				rect=new Rectangle(point.x - 5, point.y - 5, 10, 10);
				msg=npcvo.job + "\n" + npcvo.name + "\n[" + pt.x + "," + pt.z + "]";
				if(npcName){
					if(npcvo.job != ""){
						npcName.htmlText = HtmlUtil.font(npcvo.job,"#"+npcvo.color,12);
					}else{
						npcName.htmlText = HtmlUtil.font(npcvo.name,"#"+npcvo.color,12);
					}
					npcName.x = point.x - npcName.textWidth*0.5;
				}
				ptsMsg.push({rect: rect, msg: msg});
				leaf=new LeafNode(npcProvider);
				leaf.data=npcvo;
				if (npcvo.type == 1) {
					funNode.addChildNode(leaf);
				} else {
					talkNode.addChildNode(leaf);
				}
			}
			drawMonster(monsterChk.selected);
			npcTree.dataProvider=npcProvider;
			var turnPoints:Array=SceneDataManager.visualTurns;
			for (var m:int=0; m < turnPoints.length; m++) {
				var tran:MapTransferVo=turnPoints[m];
				pt=new Pt(tran.tx, 0, tran.ty);
				point=TileUitls.getIsoIndexMidVertex(pt);
				point.x=city.posx + (point.x + SceneDataManager.offsetX) * city.scale;
				point.y=city.posy + (point.y + SceneDataManager.offsetY) * city.scale;
				draw(point.x, point.y, 6, 4, spriteNPCName.graphics);
				var turnName:String=WorldManager.getMapName(tran.tar_Map);
				leaf=new LeafNode(turnProvider);
				leaf.data={"name": turnName, "tx": tran.tx, "ty": tran.ty};
				turnNode.addChildNode(leaf);
				rect=new Rectangle(point.x - 5, point.y - 5, 10, 10);
				msg=turnName + "\n[" + pt.x + "," + pt.z + "]";
				ptsMsg.push({rect: rect, msg: msg});
			}
			turnTree.dataProvider=turnProvider;
			LoopManager.addToSecond(this, loop);
		}
		
		private function onMonsterChkChange(event:Event):void{
			drawMonster(monsterChk.selected);
		}
		
		private function drawMonster(isShow:Boolean=true):void{
			while(spriteMonster.numChildren>0){
				spriteMonster.removeChildAt(0);
			}
			if(isShow){
				var monsterDic:Dictionary = SceneDataManager.getMonsters(false);
				var pos:Pt;
				var point:Point;
				var monsterType:MonsterType;
				for(var i:String in monsterDic){
					pos = MonsterConfig.getMonsterPos(SceneDataManager.mapID,int(i));
					if(pos){
						monsterType = monsterDic[i];
						var monsterName:TextField = ComponentUtil.createTextField("",0,0,Style.textFormat);
						monsterName.filters = Style.textBlackFilter;
						monsterName.htmlText = HtmlUtil.font(monsterType.monstername + "（"+monsterType.level+"）","#9AD9A4",14);
						point=TileUitls.getIsoIndexMidVertex(pos);
						monsterName.x=city.posx + (point.x + SceneDataManager.offsetX) * city.scale;
						monsterName.y=city.posy + (point.y + SceneDataManager.offsetY) * city.scale;
						spriteMonster.addChild(monsterName);
					}
				}
			}
		}
		
		private function drawNPC(event:Event):void{
			while(spriteNPCName.numChildren){
				spriteNPCName.removeChildAt(0);
			}
			if(npcChk.selected){
				var npcArr:Array=SceneDataManager.npcs;
				var pt:Pt;
				var point:Point;
				var npcName:TextField;
				for (var i:int; i < npcArr.length; i++) {
					var npc:MapElementVo=npcArr[i];
					pt=new Pt(npc.tx, 0, npc.ty);
					point=TileUitls.getIsoIndexMidVertex(pt);
					point.x=city.posx + (point.x + SceneDataManager.offsetX) * city.scale;
					point.y=city.posy + (point.y + SceneDataManager.offsetY) * city.scale;
					npcName = ComponentUtil.createTextField("",0,0,Style.textFormat);
					npcName.filters = Style.textBlackFilter;
					npcName.y = point.y - 20;
					spriteNPCName.addChild(npcName);
					draw(point.x, point.y, 9, 4, spriteNPCName.graphics);
					var npcvo:NPCVo=new NPCVo;
					npcvo.setUP(pt, npc.id);
					if(npcName){
						if(npcvo.job != ""){
							npcName.htmlText = HtmlUtil.font(npcvo.job,"#"+npcvo.color,12);
						}else{
							npcName.htmlText = HtmlUtil.font(npcvo.name,"#"+npcvo.color,12);
						}
						npcName.x = point.x - npcName.textWidth*0.5;
					}
				}
			}else{
				spriteNPCName.graphics.clear();
			}
		}
		
		//把点填充到点上
		private function draw(px:Number, py:Number, bit:int, size:int, graphics:Graphics):void {
			var round:BitmapData=SmallMapDataManager.getBit(bit);
			var mt:Matrix=new Matrix;
			mt.tx=px - size;
			mt.ty=py - size;
			graphics.beginBitmapFill(round, mt, false);
			graphics.drawCircle(px, py, size);
//			shape.graphics.beginFill(0xff0000);
//			shape.graphics.drawRect(px, py, size, size);
			graphics.endFill();
		}


		private function loop():void {
			updataPoints();
		}

		//每1秒更新一次 0.紫、1.粉红、2.红、3.深蓝、4.绿、5.黑、6浅蓝.、7.白、8.朱红、9.黄、10.橙、11.青
		public function updataPoints():void {
			if (this.stage) { //夫妻、队友、自身
				shapeOther.graphics.clear();
				shapeSelf.graphics.clear();
				var myBase:p_role_base=GlobalObjectManager.getInstance().user.base;
				for (var s:String in SceneUnitManager.unitHash) {
					var tar:IMutualUnit=SceneUnitManager.unitHash[s];
					var px:Number=(tar.x + SceneDataManager.offsetX) * city.scale + city.posx;
					var py:Number=(tar.y + SceneDataManager.offsetY) * city.scale + city.posy;
					if (tar is IRole && IRole(tar).pvo != null) {
							var pvo:p_map_role=IRole(tar).pvo;
							if (pvo.faction_id == myBase.faction_id) { //===同国
								if ((pvo.role_id == GlobalObjectManager.getInstance().user.attr.couple_id) && pvo.role_id != 0 && GlobalObjectManager.getInstance().user.attr.couple_id != 0) { //夫妻(大粉红)
	//								draw(point,5,1);
								} else if (pvo.team_id == myBase.team_id && pvo.team_id != 0 && myBase.team_id != 0 && pvo.role_id != myBase.role_id) {
									if(playerChk.selected){
										draw(px, py, 4, 5, shapeOther.graphics); //队友(大绿点)
									}else{
										shapeOther.graphics.clear();
									}
								} else if (pvo.role_id == myBase.role_id) {
									draw(px, py, 3, 5, shapeSelf.graphics); //自自（大蓝点）
									//下面画自己在路上的圆圈
									isRoadFinish=(roadEndPoint == null || tar.index.key == roadEndPoint.key);
									if (isRoadFinish == true) {
										shapeRoad.graphics.clear();
										roadEndPoint=null;
									}
								}
	//								drawMyRoad();
							}

					} else if (tar is YBC) { //骠车（紫色）
//						var yvo:p_map_ybc=YBC(tar).pvo;
//						if ((yvo.group_type == 1 && yvo.creator_id == myBase.role_id) || (yvo.group_type == 2 && yvo.group_id == myBase.family_id)) {
//							draw(px, py, 0, 5, shapeYBC);
//						}
					} else if (tar is Waiter) {
//						draw(px, py, 0, 3, shapeOther);
					}
				}
				drawMyTeam(); //画队友
			}
		}

		public function drawMyYBC(tx:int, ty:int):void {
			var p:Point=TileUitls.getIsoIndexMidVertex(new Pt(tx, 0, ty));
			var px:Number=(p.x + SceneDataManager.offsetX) * city.scale + city.posx;
			var py:Number=(p.y + SceneDataManager.offsetY) * city.scale + city.posy;
			shapeYBC.graphics.clear();
			draw(px, py, 0, 5, shapeYBC.graphics);
		}

		public function clearYBC():void {
			shapeYBC.graphics.clear();
		}

		private function drawMyTeam():void {
			var arr:Array=TeamDataManager.teamMembers;
			teamMsg.length=0;
			var rect:Rectangle;
			for (var i:int=0; i < arr.length; i++) {
				var vo:p_team_role=arr[i];
				if (vo.role_id != GlobalObjectManager.getInstance().user.base.role_id) {
					if (SceneUnitManager.getUnit(vo.role_id) == null && vo.map_id == SceneDataManager.mapID) { //九宫格子外才画,内的部分已经画了
						var p:Point=ptToSmallmap(new Pt(vo.tx, 0, vo.ty));
						draw(p.x, p.y, 4, 5, shapeOther.graphics);
						rect=new Rectangle(p.x - 5, p.y - 5, 10, 10);
						teamMsg.push({rect: rect, msg: vo.role_name});
					}
				}
			}
		}

		public function drawMyPath(path:Array):void {
			shapeRoad.graphics.clear();
			var pos:MacroPathVo=SceneDataManager.getMyPostion();
			if (pos) {
				path.unshift(pos.pt);
			}
			shapeRoad.graphics.lineStyle(1, 0xffff00, 1, false, LineScaleMode.VERTICAL, CapsStyle.NONE, JointStyle.ROUND, 3);
			for (var i:int=0; i < path.length - 1; i++) {
				drawDashed(shapeRoad.graphics, ptToSmallmap(path[i]), ptToSmallmap(path[i + 1]));
			}
			roadEndPoint=path[path.length - 1];
			isRoadFinish=false;
			shapeRoad.graphics.beginFill(0x00ff00,1);
			var p:Point=ptToSmallmap(roadEndPoint);
			shapeRoad.graphics.drawCircle(p.x, p.y, 3);
		}

		public function clearPath():void {
			shapeRoad.graphics.clear();
		}

		//画虚线
		private function drawDashed(graphics:Graphics, p1:Point, p2:Point, length:Number=5, gap:Number=5):void {
			var max:Number=Point.distance(p1, p2);
			var l:Number=0;
			var p3:Point;
			var p4:Point;
			graphics.lineStyle(1, 0xffff00);
			while (l < max) {
				p3=Point.interpolate(p2, p1, l / max);
				l+=length;
				if (l > max)
					l=max
				p4=Point.interpolate(p2, p1, l / max);
				graphics.moveTo(p3.x, p3.y)
				graphics.lineTo(p4.x, p4.y)
				l+=gap;
			}
		}

		private function onMouseOver(e:MouseEvent):void {
			for (var i:int=0; i < ptsMsg.length; i++) {
				var rec:Rectangle=ptsMsg[i].rect;
				if (rec.contains(mapBitmap.mouseX, mapBitmap.mouseY)) {
					ToolTipManager.getInstance().show(HtmlUtil.font(ptsMsg[i].msg, "#ffff00"), 0);
					return;
				}
			}
			var cx:Number=(mapBitmap.mouseX - city.posx) / city.scale - SceneDataManager.offsetX;
			var cy:Number=(mapBitmap.mouseY - city.posy) / city.scale - SceneDataManager.offsetY;
			var pt:Pt=TileUitls.getIndex(new Point(cx, cy));
			var str:String="[" + pt.x + "," + pt.z + "]";
			for (i=0; i < teamMsg.length; i++) { //显示队友名字
				var rec2:Rectangle=teamMsg[i].rect;
				if (rec2.contains(mapBitmap.mouseX, mapBitmap.mouseY)) {
					ToolTipManager.getInstance().show(HtmlUtil.font(teamMsg[i].msg + "\n" + str, "#ffff00"), 0);
					return;
				}
			}
			ToolTipManager.getInstance().show(HtmlUtil.font(str, "#ffff00"), 0);
		}

		private function onMouseOut(e:MouseEvent):void {
			ToolTipManager.getInstance().hide();
		}

		private function onClickNPC(e:ItemEvent):void {
			if (Tree(e.target).selectedItem is LeafNode) {
				var pt:Pt=Tree(e.target).selectedItem.data.pt;
				inputX.text=pt.x + "";
				inputY.text=pt.z + "";
//				drawClipNpc(pt);//在NPC点画圆圈
			}
		}

		private function onDoubleClickNPC(e:ItemEvent):void {
			if (Tree(e.target).selectedItem is LeafNode) {
				var npcVO:NPCVo = Tree(e.target).selectedItem.data as NPCVo;
				PathUtil.findNPC(npcVO.id.toString());
//				var pt:Pt=Tree(e.target).selectedItem.data.pt;
//				var vo:RunVo=new RunVo;
//				vo.pt=pt;
//				Dispatch.dispatch(ModuleCommand.ROLE_MOVE_TO, vo);
			}
		}

		private function onClickTurn(e:ItemEvent):void {
			if (Tree(e.target).selectedItem is LeafNode) {
				inputX.text=Tree(e.target).selectedItem.data.tx + "";
				inputY.text=Tree(e.target).selectedItem.data.ty + "";
					//				drawClipNpc(pt);//在NPC点画圆圈
			}
		}

		private function onDoubleClickTurn(e:ItemEvent):void {
			if (Tree(e.target).selectedItem is LeafNode) {
				var obj:Object=Tree(e.target).selectedItem.data;
				var vo:RunVo=new RunVo;
				vo.pt=new Pt(obj.tx, 0, obj.ty);
				Dispatch.dispatch(ModuleCommand.ROLE_MOVE_TO, vo);
			}
		}

		private function ptToSmallmap(pt:Pt):Point {
			var curCity:CityVo = WorldManager.getCurrentCity();
			var point:Point=TileUitls.getIsoIndexMidVertex(pt);
			point.x=curCity.posx + (point.x + SceneDataManager.offsetX) * curCity.scale;
			point.y=curCity.posy + (point.y + SceneDataManager.offsetY) * curCity.scale;
			return point;
		}
	}
}
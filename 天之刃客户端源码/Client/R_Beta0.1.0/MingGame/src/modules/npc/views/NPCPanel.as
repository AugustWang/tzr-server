package modules.npc.views {
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.managers.WindowManager;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.containers.Canvas;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.Skin;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.npc.NPCConstant;
	import modules.npc.vo.NPCPannelVO;
	import modules.npc.vo.NpcLinkVO;
	import modules.scene.SceneDataManager;

	public class NPCPanel extends BasePanel {
		public function NPCPanel(key:String=null) {
			super();
			initView();
		}


		private var _canvas:Canvas;
		private var _linksContainer:Sprite;
		private var _contentText:TextField;
		private var _button:Button;
		
		private var _vo:NPCPannelVO;
		private var _line:Bitmap;

		private function initView():void {
			this.width=293;
			this.height=401;
			this.y = 90;
			addContentBG(30);
			
			var bitmap:Skin = Style.getSkin("packTileBg",GameConfig.T1_VIEWUI,new Rectangle(60,60,172,177));
			bitmap.setSize(273,316);
			bitmap.x = 11;
			bitmap.y = 10;
			addChild(bitmap);


			var tf:TextFormat=new TextFormat();
			tf.leading=4;
			tf.color=0xffffff;

			this._contentText=ComponentUtil.createTextField('', 25, 20, tf, 240, NaN, this);
			this._contentText.filters=[Style.BLACK_FILTER]
			this._contentText.multiline=true;
			this._contentText.wordWrap=true;

			this._line=Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			_line.width = 280;
			_line.x = 10;
			addChild(_line);

			this._canvas=new Canvas();
			this._canvas.x=13;
			this._canvas.y=18;
			this._canvas.width=267;
			this._canvas.height=238;
			this._canvas.horizontalScrollPolicy=ScrollPolicy.OFF;
			this._canvas.verticalScrollPolicy=ScrollPolicy.AUTO;
			this.addChild(this._canvas);

			this._linksContainer=new Sprite();
			this._canvas.addChild(this._linksContainer);

			this._button=ComponentUtil.createButton("", this.width - 95, this.height - 70, 80, 25, this);
			this._button.addEventListener(MouseEvent.CLICK, this.onButtonClick);
			this._button.label='接受任务';
			this._button.visible = false;

		}

		public function set vo(basePannelVO:NPCPannelVO):void {
			this._vo=basePannelVO;
		}
		
		public function get vo():NPCPannelVO
		{
			return this._vo;
		}

		/**
		 * 渲染显示界面链接
		 */
		private function render():void {

			//this.title=this._vo.npcName;
			var content:String = this._vo.content;
			
			content = content.replace(GameConfig.S_REG_EXP, GameConfig.SUO_JIN_STR);
			content = content.replace(GameConfig.N_REG_EXP, GameConfig.N_STR);
			this._contentText.htmlText=content;
			
            this._contentText.height = this._contentText.textHeight + 10;
			this._line.y=this._contentText.y +  this._contentText.height;
			this._canvas.y=this._line.y + 10;

			var startY:Number=0;
			for each (var missionLink:NpcLinkVO in this._vo.missionLinks) {
				var itemMission:NPCLinkItem=new NPCLinkItem();
				itemMission.addEventListener(MouseEvent.CLICK, onItemClick);
				itemMission.data=missionLink;
				itemMission.iconStyle=missionLink.iconStyle;
				itemMission.label=missionLink.linkName;
				itemMission.y=startY;
				this._linksContainer.addChild(itemMission);
				startY=startY + itemMission.height;
			}

			if ( this._vo.missionLinks.length > 0 ) {
				this._button.visible=true;
				var firstMissionLink:NpcLinkVO=_vo.missionLinks[ 0 ];
				switch ( firstMissionLink.iconStyle ) {
					case NPCConstant.LINK_ICON_STYLE_MISSION_ACCEPT:
						this._button.label='接受任务';
						break;
					case NPCConstant.LINK_ICON_STYLE_MISSION_FINISH:
						this._button.label='完成任务';
						break;
					default:
						this._button.label='继续';
						break;
				}
			} else {
				this._button.visible=false;
			}
			if ( startY > 0 ) {
				startY+=20;
			}
			for each (var actionlink:NpcLinkVO in this._vo.actionLinks) {
				var itemAction:NPCLinkItem=new NPCLinkItem();
				itemAction.addEventListener(MouseEvent.CLICK, onItemClick);
				itemAction.data=actionlink;
				itemAction.iconStyle=actionlink.iconStyle;
				itemAction.label=actionlink.linkName;
				itemAction.y=startY;
				this._linksContainer.addChild(itemAction);
				startY=startY + itemAction.height;
			}
		}

		private function onItemClick(event:MouseEvent):void {
			var item:NPCLinkItem=event.currentTarget as NPCLinkItem;

			var linkVO:NpcLinkVO=item.data as NpcLinkVO;

			//一定要放这里 所有消息是同步的 先关窗口 其他操作才不会被影响
			this.close();

			Dispatch.dispatch(linkVO.dispatchMessage, linkVO);
		}

		private function onButtonClick(e:MouseEvent):void {
			if( _button.visible ){
				//处理接受任务
				if( _linksContainer.numChildren > 0 ){
					var firstItem:NPCLinkItem = this._linksContainer.getChildAt(0) as NPCLinkItem;
					var linkVO:NpcLinkVO= firstItem.data as NpcLinkVO;
					//一定要放这里 所有消息是同步的 先关窗口 其他操作才不会被影响
					this.close();
					
					Dispatch.dispatch(linkVO.dispatchMessage, linkVO);
				}
			}
			
		}

		/**
		 * 打开窗口
		 */
		override public function open():void {
			this.clear();
			this.renderInit();
			this.render();
			if (!WindowManager.getInstance().isPopUp(this)) {
				WindowManager.getInstance().openDistanceWindow(this);
				WindowManager.getInstance().centerWindow(this);
			}
		}

		private function close():void {
			this.clear();
			this.closeWindow();
		}

		private function clear():void {
			_contentText.htmlText="";
			while (_linksContainer.numChildren > 0) {
				var item:DisplayObject=_linksContainer.removeChildAt(0);
				item.removeEventListener(MouseEvent.CLICK, onItemClick);
			}

			this._line.visible=false;
			this._linksContainer.visible=false;
			this._button.visible=false;
		}

		private function renderInit():void {
			this._line.visible=true;
			this._linksContainer.visible=true;
		}
	}
}
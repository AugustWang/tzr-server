package modules.duplicate.views
{
	import com.components.BasePanel;
	import com.events.ParamEvent;
	import com.globals.GameConfig;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.containers.Canvas;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.Skin;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import modules.duplicate.vo.ContentVO;
	import modules.duplicate.vo.TalkContentVO;
	import modules.duplicate.vo.TalkVO;
	import modules.npc.NPCConstant;
	import modules.npc.views.NPCLinkItem;
	
	public class DuplicateNPCPanel extends BasePanel
	{
		
		/**
		 * 聊天类型(继续，完成，返回) 
		 */		
		public static const CONTINUE:String = "continue";
		public static const FINISH:String = "finish";
		public static const GO_BACK:String = "goBack";
		public static const GO_BACK_REFRESH:String = "GO_BACK_REFRESH";
		/**
		 * 对话节点类型 
		 */		
		public static const LINK:String = "link";  //链接
		public static const CONTENT:String = "content"; //内容
		
		/**
		 * Link节点 类型
		 */		
		public static const SHOW_CONTENT:String = "showContent";
		public static const OTHER:String = "other";
		
		
		public static var icon:String;
			

		private var _linksContainer:Sprite;
		private var _contentText:TextField;
		private var _line:Bitmap;
		private var _canvas:Canvas;
		private var button:Button;
		private var buttonDesc:Object;
		public function DuplicateNPCPanel()
		{
			super();
			initView();
		}
		
		private function initView():void{
			
			this.width=293;
			this.height=401;
			this.y = 90;
			addContentBG(30);
			
			var bitmap:Skin = Style.getSkin("packTileBg",GameConfig.T1_VIEWUI,new Rectangle(60,60,172,177));
			bitmap.setSize(273,316);
			bitmap.x = 11;
			bitmap.y = 10;
			addChild(bitmap);
		
            var tf:TextFormat = Style.textFormat;
			tf.leading=4;
			tf.color=0xffffff;
			
			this._contentText=ComponentUtil.createTextField("", 23, 20, tf, 240, NaN, this);
			this._contentText.filters=[Style.BLACK_FILTER];
			this._contentText.multiline=true;
			this._contentText.wordWrap=true;
			this._contentText.autoSize = TextFieldAutoSize.LEFT;
			
			this._line=Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			_line.width = 280;
			_line.x = 10;
			addChild(_line);
			
			this._canvas=new Canvas();
			this._canvas.x=8;
			this._canvas.width=240;
			this._canvas.height=190;
			this._canvas.horizontalScrollPolicy=ScrollPolicy.OFF;
			this._canvas.verticalScrollPolicy=ScrollPolicy.AUTO;
			this.addChild(this._canvas);
			
			this._linksContainer=new Sprite();
			this._canvas.addChild(this._linksContainer);
			
			this.button=ComponentUtil.createButton("", this.width - 95, this.height - 70, 80, 25, this);
			this.button.addEventListener(MouseEvent.CLICK, this.onClickHandler);
			this.button.label="关闭";
			this.button.visible = false;
			
		}
		
		private var _talkVO:TalkVO
		public function set talkVO(vo:TalkVO):void{
			_talkVO = vo;
			if(_talkVO){
				startTalk();
			}
		}
		
		public function get talkVO():TalkVO{
			return _talkVO;
		}
		
		private function onClickHandler(event:MouseEvent):void{
			if(buttonDesc.type == CONTINUE){
				nextTalk();
			}else if(buttonDesc.type == FINISH){
				closeWindow();
			}else if(buttonDesc.type == GO_BACK){
				var index:int = buttonDesc.goBackIndex;
				talkIndex = Math.min(index,0);
				var talkContentVO:TalkContentVO = talkVO.talks[talkIndex];
				wrapperTalk(talkContentVO);
			}else if (buttonDesc.type == GO_BACK_REFRESH) {
				dispatchEvent(new Event(GO_BACK_REFRESH));
			}
		}
		private var talkIndex:int = -1;
		private function startTalk():void{
			talkIndex = -1;
			nextTalk();
		}
		
		private function nextTalk():void{
			talkIndex++;
			talkIndex = Math.min(talkIndex,talkVO.talks.length);
			var talkContentVO:TalkContentVO = talkVO.talks[talkIndex];
			wrapperTalk(talkContentVO);
		}
		
		public function wrapperTalk(talkContentVO:TalkContentVO):void{
			if(talkContentVO){
				this.clear();
				//this.title = talkVO.name;
 				buttonDesc = {};
				button.visible = true;
				
				if(talkContentVO.type == CONTINUE){
					button.label = "继续";
					buttonDesc.type = CONTINUE;
				}else if(talkContentVO.type == GO_BACK){
					button.label = "返回";
					buttonDesc.type = GO_BACK;
					buttonDesc.goBackIndex = talkContentVO.data;
				}else if(talkContentVO.type == GO_BACK_REFRESH){
					button.label = "返回";
					buttonDesc.type = GO_BACK_REFRESH;
					//buttonDesc.goBackIndex = talkContentVO.data;
				}else{
					button.label = "关闭";
					buttonDesc.type = FINISH;
					button.visible = false;
				}
				
				_linksContainer.visible = true;
				
				var startY:Number=0;
				for(var i:int = 0; i < talkContentVO.contents.length; i ++){
					var contentVO:ContentVO = talkContentVO.contents[i];
					if(i == 0 && contentVO.type == CONTENT){
						this._contentText.htmlText="<font color=\"#FFFFFF\">" + contentVO.text + "</font>";
						this._contentText.height = this._contentText.textHeight + 10;
						if(talkContentVO.contents.length > 1){
							this._line.y=this._contentText.textHeight + this._contentText.y + 10;
							this._line.visible= true;
							this._canvas.y=this._line.y + 10;
						}
					}else{
						if(contentVO.type != CONTENT){
							var itemAction:NPCLinkItem=new NPCLinkItem();
							itemAction.addEventListener(MouseEvent.CLICK, onItemClick);
							itemAction.data={type:contentVO.type,linkType:contentVO.linkType,data:contentVO.data};
							itemAction.iconStyle=NPCConstant.LINK_ICON_STYLE_ACTION;
							itemAction.label=contentVO.text;
							itemAction.y=startY;
							this._linksContainer.addChild(itemAction);
							startY=startY + itemAction.height;
						}
					}
					
				}
			}
		}
		private function onItemClick(event:MouseEvent):void {
			var item:NPCLinkItem=event.currentTarget as NPCLinkItem;
			var dataObj:Object = item.data;
			if(dataObj.linkType == SHOW_CONTENT){
				dispatchEvent(new ParamEvent(SHOW_CONTENT,dataObj.data));
			}else{
				dispatchEvent(new ParamEvent(OTHER,dataObj.data));
			}
			dispatchEvent(new ParamEvent(FINISH,null));
		}
		override public function closeWindow(save:Boolean=false):void{
			this.clear();
			super.closeWindow(save);
			dispatchEvent(new ParamEvent(FINISH,"close"));
		}
		private function clear():void {
			_contentText.htmlText="";
			while (_linksContainer.numChildren > 0) {
				var item:DisplayObject=_linksContainer.removeChildAt(0);
				item.removeEventListener(MouseEvent.CLICK, onItemClick);
			}
			
			this._line.visible=false;
			this._linksContainer.visible=false;
			this.button.visible=false;
		}
	}
}
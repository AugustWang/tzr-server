package modules.roleStateG.views.changeHair
{
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.events.ParamEvent;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.mypackage.managers.PackManager;
	
	import proto.line.m_role2_head_tos;
	
	public class HeadView extends Sprite
	{
		public static const CHANGE_FACE_EVENT:String="CHANGE_FACE_EVENT";
		private var faces:Array=[];
		private var _selectedFace:int=0;
		private var headCard:TextField;
		private var headCardNum:int;
		
		public function HeadView()
		{
			super();
			initView();
		}
		private function initView():void{
			var bg1:UIComponent = ComponentUtil.createUIComponent(4,4,526,280);
			Style.setBorder1Skin(bg1);
			addChild(bg1);
			var url:String;
			if(GlobalObjectManager.getInstance().user.base.sex==1){
				url=GameConfig.ROOT_URL+"com/assets/changeHair/face/man";
			}else{
				url=GameConfig.ROOT_URL+"com/assets/changeHair/face/woman";
			}
			var tf:TextFormat=new TextFormat(null,null,0xECE8BB,null,null,null,null,null,"center");
			for(var i:int=0;i<10;i++){
				var faceUrl:String=url+(i+1)+".jpg";
				var px:Number=6+104*(i%5);
				var py:Number=1+139*int(i/5);
				var face:Image=createImage(faceUrl,px,py,bg1);
				face.buttonMode=true;
				face.name=(i+1)+"";
				face.addEventListener(MouseEvent.CLICK,onSelecteFace);
				faces.push(face);
				ComponentUtil.createTextField("头像"+(i+1),px,(py+122),tf,98,22,bg1);
			}
			var bg2:UIComponent = ComponentUtil.createUIComponent(4,284,526,28);
			Style.setBorder1Skin(bg2);
			addChild(bg2);
			var t:TextField=ComponentUtil.createTextField("更换费用：1锭银子",4,4,null,120,22,bg2);
			t.htmlText=HtmlUtil.font("更换费用：","#AFE0EE")+HtmlUtil.font("1锭银子","#ECE8BB");
			
			headCard= ComponentUtil.createTextField("", 170, 4, null, 200, 22, bg2);
			var commitBtn:Button=ComponentUtil.createButton("确定",360,1,60,25,bg2);
			var cancelBtn:Button=ComponentUtil.createButton("取消",442,1,60,25,bg2);
			commitBtn.addEventListener(MouseEvent.CLICK,onCommit);
			cancelBtn.addEventListener(MouseEvent.CLICK,onCancel);
		}
		public function reset():void{
			for(var i:int=0;i<faces.length;i++){
				faces[i].filters=null;
			}
			var skinid:int=GlobalObjectManager.getInstance().user.attr.skin.skinid;
			var sex:int=skinid%2;
			_selectedFace=sex==1?(skinid+1)/2:skinid/2;
			faces[_selectedFace-1].filters=[new GlowFilter(0xAFE0EE,1,8,8),new GlowFilter(0xAFE0EE,1,8,8,6,1,true)];
			
			resetHeadCardNum();
		}
		
		private function resetHeadCardNum():void
		{
			headCardNum = PackManager.getInstance().getGoodsNumByTypeId(10100023);
			if (headCardNum > 0) {
				headCard.htmlText=HtmlUtil.font("头像卡 x "+headCardNum,"#AFE0EE");
				headCard.visible = true;
			} else {
				headCard.visible = false;
			}
		}
		
		public function reduceHeadCardNum():void
		{
			headCardNum --;
			if (headCardNum > 0) {
				headCard.htmlText=HtmlUtil.font("头像卡 x "+headCardNum,"#AFE0EE");
				headCard.visible = true;
			} else {
				headCard.visible = false;
			}
		}
		
		private function onCommit(e:MouseEvent):void{
			if(_selectedFace<1||_selectedFace>10){
				Alert.show("请选择要更换的头像","提示");
				return;
			}
			var head_id:int;
			if(GlobalObjectManager.getInstance().user.base.sex==1){
				head_id=_selectedFace*2-1;
			}else{
				head_id=_selectedFace*2;
			}
			if(head_id==GlobalObjectManager.getInstance().user.attr.skin.skinid){
				Alert.show("与原头像一致，请重新选择","提示",null,null,"确定","",null,false);
				return;
			}
			Alert.show("更改头像需要发型卡1张或花费1锭银子。你确定更改为该头像？","提示",yesHander,null,"同意","取消",[head_id]);
		}
		private function yesHander(head_id:int):void{
			var vo:m_role2_head_tos=new m_role2_head_tos;
			vo.head_id=head_id;
			
			var uie:ParamEvent=new ParamEvent(CHANGE_FACE_EVENT, vo, true);
			this.dispatchEvent(uie);
		}
		private function onCancel(e:MouseEvent=null):void{
			this.dispatchEvent(new Event("closeWindow",true));
		}
		private function onSelecteFace(e:MouseEvent):void{
			for(var i:int=0;i<faces.length;i++){
				faces[i].filters=null;
			}
			var img:Image=e.currentTarget as Image;
			img.filters=[new GlowFilter(0xAFE0EE,1,8,8),new GlowFilter(0xAFE0EE,1,8,8,6,1,true)];
			_selectedFace=int(img.name);
		}
		private function createImage(source:String,px:Number,py:Number,parent:DisplayObjectContainer):Image{
			var img:Image=new Image;
			img.source=source;
			img.x=px;
			img.y=py;
			parent.addChild(img);
			return img;
		}
	}
}
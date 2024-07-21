package modules.personalybc
{
	
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.smallMap.SmallMapModule;
	
	public class GeRenAndGuoYunTimeView extends Sprite
	{
		private var txtView:TextField;
		public var link:TextField;
		private var bg:UIComponent;
		public function GeRenAndGuoYunTimeView()
		{
			super();
			this.addEventListener(MouseEvent.MOUSE_OVER,overFunc);
			this.addEventListener(MouseEvent.MOUSE_OUT,outFunc);
		}
		private function overFunc(e:MouseEvent):void
		{
			if(this.vo.id==DealGeRenAndGuoYunTime.PERSON){
				ToolTipManager.getInstance().show('超时后只获得20%的奖励，不返回押金.')
			}else if(this.vo.id == DealGeRenAndGuoYunTime.PERSON_YBC_FACTION){
				ToolTipManager.getInstance().show("国运期间完成拉镖任务获得的银子奖励25%为不绑定银子");
			}
		}
		private function outFunc(e:MouseEvent):void
		{
			ToolTipManager.getInstance().hide();
		}
		private function getTextFormat():TextFormat
		{
			var textFormat:TextFormat = new TextFormat();
			
			textFormat.color = "0xFFF673";
			textFormat.size = 12;
			textFormat.align = "left";
		
			return textFormat;
		}
		public function setUp(id:String):void{
			this.vo.id=id;
			bg=new UIComponent
			bg.width=100;
			bg.height=40;
			Style.setMenuItemBg(bg);//背景
			this.addChild(bg);
			txtView=ComponentUtil.createTextField("",5,3,getTextFormat(),95,20,this);
			link=new TextField();
			link.selectable=false;
			link.x=5;
			link.y=18;
			link.width=95;
			link.height=20;
			link.addEventListener(TextEvent.LINK,onLinkFunc);
			this.addChild(link);
			if(id==DealGeRenAndGuoYunTime.PERSON){
				txtView.y = 1;
			}else{
				txtView.y = 8;
			}
			
		}
		private function onLinkFunc(e:TextEvent):void
		{
			var orders:Array=e.text.split('|')
			var args:Array=orders[0].split('#');
			var order:String=args.shift()
			var key:String;
			args=args[0].split(',')
			var getter:Vector.<int> = new Vector.<int>;
			getter.push(ModelConstant.SCENE_MODEL);
			var body:MessageBody = new MessageBody();
			var scaleGrid:ScaleGrid=TileGroup.getInstance().getScale9Grid(new  Pt(int(args[1]),0,int(args[2])))
			
			var array:Array=scaleGrid.passAndFrontCell()
			var cell:Cell=array[int(Math.random()*array.length>>0)]
			if(cell==null)
			{ cell=new Cell
				cell.index=new  Pt(int(args[1]),0,int(args[2]))
			}
			body.setUp(null,null,null,{map:int(args[0]),width:0,height:0,x:cell.x,y:cell.z,type:1});
			var message:IMessage  = SmallMapModule.getInstance().model.createMessage(MessageConstant.MODEL_TO_MODEL, MessageConstant.CALL, getter,body);
			var vo:RunVo=new RunVo
			vo.mapid=int(args[0])
			vo.pt=cell.index
			message.data=vo
			message.name = String(SmallMapActionType.MOVE_TO);
			SmallMapModule.getInstance().model.send(message)
			
			
		}
		public function set text(value:String):void
		{
			if(this.txtView)this.txtView.htmlText=value;
		}
		
		override  public function unload():void
		{
			if(bg){
				if(bg.parent)this.removeChild(bg);
				bg=null;
			}
			super.unload()
			if(link.parent)
			{
				link.parent.removeChild(link)
			this.link.removeEventListener(TextEvent.LINK,onLinkFunc)
			}
			link=null
			if(txtView.parent)txtView.parent.removeChild(txtView)
			
			txtView=null;
			
			
		}
	}
}
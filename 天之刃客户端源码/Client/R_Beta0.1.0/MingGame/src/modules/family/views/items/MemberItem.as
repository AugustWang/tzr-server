package modules.family.views.items
{
	import com.common.GlobalObjectManager;
	import com.managers.WindowManager;
	import com.ming.core.IDataRenderer;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.TextEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.family.FamilyConstants;
	import modules.family.FamilyItemEvent;
	import modules.family.FamilyLocator;
	import modules.family.FamilyModule;
	import modules.letter.LetterModule;
	import modules.letter.view.FamilySelectView;
	
	import proto.common.p_family_member_info;
	
	public class MemberItem extends Sprite implements IDataRenderer
	{
		public static const tf:TextFormat = new TextFormat("Arail",12,0xffffff,null,null,null,null,null,"center");
		private var nameTF:TextField;
		private var titleTF:TextField;
		private var levelTF:TextField;
		private var gongxianTF:TextField;
		private var teamTF:TextField;
		private var batchLetterTxt:TextField;
		
		private var writeLetter:Sprite;
		public function MemberItem()
		{
			super();
			var css:StyleSheet = new StyleSheet();
			css.parseCSS("a {color: #ffff00;} a:hover {color: #ffffff;}");

			nameTF = ComponentUtil.createTextField("",0,2,tf,100,25,this);
			nameTF.styleSheet = css;
			nameTF.mouseEnabled = true;
			
			titleTF = ComponentUtil.createTextField("",100,2,tf,100,25,this);
			levelTF = ComponentUtil.createTextField("",200,2,tf,60,25,this);
			gongxianTF = ComponentUtil.createTextField("",260,2,tf,88,25,this);
			teamTF = ComponentUtil.createTextField("",348,2,tf,95,25,this);
			teamTF.htmlText = "<a href='event:team'>组队</a>   <a href='event:write'>写信</a>";
			teamTF.mouseEnabled = true;
			teamTF.styleSheet = css;
			batchLetterTxt = ComponentUtil.createTextField("",348,2,null,95,25,this);
			batchLetterTxt.mouseEnabled = true;
			batchLetterTxt.visible = false;
			batchLetterTxt.htmlText = "<a href='event:batchLetter'><p align='center'>[批量信件]</p></a>";
			
			teamTF.addEventListener(TextEvent.LINK,onTeamLink);
			nameTF.addEventListener(TextEvent.LINK,onTextLink);
			batchLetterTxt.addEventListener(TextEvent.LINK,onLetterLinkHandler);
		}
		
		private var familySelectView:FamilySelectView;
		private function onLetterLinkHandler(evt:TextEvent):void{
			if(evt.text == "batchLetter"){
				if(!familySelectView){
					familySelectView = new FamilySelectView();
				}
				WindowManager.getInstance().popUpWindow(familySelectView,WindowManager.UNREMOVE);
				WindowManager.getInstance().centerWindow(familySelectView);
			}
		}
		
		private function setOnline(online:Boolean,last_online:int):void{
			if(info.role_id == GlobalObjectManager.getInstance().getRoleID() || info.online){
				filters = [];
			}else{
				var date:Date = new Date();
				var second:Number = int(date.time/1000) - last_online;
				var off_line_long:Boolean;
				if(last_online>0 && Math.round(second/(24 * 3600 )) > FamilyConstants.OFF_LINE_LONG) //大于两周。
				{
					off_line_long = true;
				}
				
				if(off_line_long)
				{
					//  0.2225 ,7169 ,0606
//					filters = [new ColorMatrixFilter([0.2225 ,7169 ,0606,0,0, 0.2225 ,7169 ,0606,0,0, 0.2225 ,7169 ,0606,0,0, 0,0,0,1,0] ) ];
					
					filters = [new GlowFilter(0x808090,1,2,2,4,1,true)];
				}else{
					filters = [new ColorMatrixFilter([1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,1,0])];
				}
			}
		}
		private var _data:Object;
		public function set data(value:Object):void{
			this._data = value;
			if(_data){
				wrapperContent();
			}else{
				clearContent();
			}
		}
		
		public function get data():Object{
			return _data;
		}
		
		private var info:p_family_member_info;
		private function wrapperContent():void{
			info = data as p_family_member_info;
			if(info){
				nameTF.htmlText = "<a href='event:showInfo'>"+info.role_name+"</a>";
				titleTF.text = info.title;
				levelTF.text = info.role_level.toString();
				gongxianTF.text = info.family_contribution.toString();
				setOnline(info.online,info.last_login_time);//info.last_login_time
				var selfId:int = GlobalObjectManager.getInstance().user.attr.role_id;
				var curfactionId:int = FamilyLocator.getInstance().getRoleID(selfId);
				var factionId:int = FamilyLocator.getInstance().getRoleID(info.role_id);
				teamTF.visible = true;
				
				if(info.role_id == GlobalObjectManager.getInstance().user.attr.role_id){
					
					if (FamilyLocator.getInstance().isFamilyOwner(info.role_id) 
					|| FamilyLocator.getInstance().isSecondOwner( info.role_id )) {
						teamTF.visible = false;
						batchLetterTxt.visible = true;
					} else {
						teamTF.visible = true;
						batchLetterTxt.visible = false;
					}
				} else {
					batchLetterTxt.visible = false;
				}
			}
		}
		
		private function clearContent():void{
			nameTF.htmlText = "";
			titleTF.text = "";
			gongxianTF.text = "";
		}	
		
		private function onTextLink(event:TextEvent):void{
			var text:String = event.text;
			if(text == "showInfo"){
				dispatchEvent(new FamilyItemEvent(info));
			}
		}
		
		private function onTeamLink(event:TextEvent):void{
			var text:String = event.text;
			if(text == "team"){
				FamilyModule.getInstance().inviteTeam(info.role_id);
			}else{
				LetterModule.getInstance().openLetter(info.role_name);
			}
		}
		
	}
}
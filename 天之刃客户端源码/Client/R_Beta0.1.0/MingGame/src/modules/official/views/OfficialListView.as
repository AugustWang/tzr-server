package modules.official.views
{
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.events.ParamEvent;
	import com.globals.GameConfig;
	import com.loaders.SourceLoader;
	import com.managers.WindowManager;
	import com.ming.events.ComponentEvent;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.ButtonSkin;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.official.OfficialConstants;
	import modules.official.OfficialDataManager;
	import modules.official.views.items.OfficialItem;
	
	import proto.line.p_office;
	import proto.line.p_office_position;
	
	public class OfficialListView extends BasePanel
	{
		private var leftBG:UIComponent;
		private var rightBG:UIComponent;
		
		private var kingBitmap:Bitmap;
		
		private var kingName:TextField;
		private var chengxiangItem:OfficialItem;
		private var dajiangjunItem:OfficialItem;
		private var jinyiweiItem:OfficialItem;
		
		private var officeInfo:p_office;
		public var nations:Array = ["","yunz_king","cz_king","yz_king"];
		public function OfficialListView()
		{
			super();
			
			width = 511;
			height = 335;
			addTitleBG(446);
			addImageTitle("title_officeList");
			addContentBG(15,10,0);
			
			leftBG = ComponentUtil.createUIComponent(14,5,141,267);
			Style.setBorderSkin(leftBG);
			addChild(leftBG);
			
			rightBG = ComponentUtil.createUIComponent(leftBG.x+leftBG.width+2,leftBG.y,338,leftBG.height);
			Style.setBorderSkin(rightBG);
			addChild(rightBG);
			
			kingBitmap = new Bitmap();
			kingBitmap.y = 20;
			kingBitmap.x = 30;
			leftBG.addChild(kingBitmap);
			
			var tf:TextFormat = Style.textFormat;
			tf.align = "center";
			tf.color = 0xffff00;
			tf.size = 14;
			kingName = ComponentUtil.createTextField("",0,50,tf,141,25,leftBG);
			kingName.filters = [new GlowFilter(0x000000,1,3,3,3)];
			
			chengxiangItem = createOfficialItem(135,18,OfficialConstants.OFFICIAL_CHENGXIANG);
			dajiangjunItem = createOfficialItem(135,53,OfficialConstants.OFFICIAL_DAJIANGJUN);
			jinyiweiItem = createOfficialItem(135,86,OfficialConstants.OFFICIAL_JINYIWEI);
			OfficialDataManager.getInstance().addEventListener(OfficialDataManager.FACTIOIN_INIT,factionInitHandler);
			var officialVO:p_office = OfficialDataManager.getInstance().getOfficial();
			if(officialVO){
				initData(officialVO);
			}
		}
		
		private function factionInitHandler(event:ParamEvent):void{
			initData(OfficialDataManager.getInstance().getOfficial());
		}
		
		public function initView(loader:SourceLoader):void{
			var nationId:int = GlobalObjectManager.getInstance().user.base.faction_id;
			kingBitmap.bitmapData = loader.getBitmapData(nations[nationId]);
			
			createOfficailTitle(loader,"neigedachen",12,14);
			createOfficailTitle(loader,"dajianjun",12,49);
			createOfficailTitle(loader,"jinyiwei",12,82);
		}
		
		private function createOfficailTitle(loader:SourceLoader,titleName:String,x:int,y:int):void{
			var icon:Bitmap = ComponentUtil.createBitmap(loader.getBitmapData("officeIcon"),x,y,rightBG);
			ComponentUtil.createBitmap(loader.getBitmapData(titleName),x+30,y+5,rightBG);
		}
		
		private function createOfficialItem(x:int,y:int,officeId:int):OfficialItem{
			var item:OfficialItem = new OfficialItem();
			item.x = x
			item.y = y;
			item.officeId = officeId;
			rightBG.addChild(item);
			return item;
		}
		
		private function initData(officeInfo:p_office):void{
			this.officeInfo = officeInfo;
			kingName.text = officeInfo.king_role_name;
			for each(var role:p_office_position in officeInfo.offices){
				var item:OfficialItem = getItemByOfficeId(role.office_id);
				if(item){
					item.kingId = officeInfo.king_role_id;
					item.setRoleInfo(role.role_id,role.role_name,role.invite_role_name);
					item.setState(getState(role));
				}
			}
		}
		
		/**
		 * 任命并等待消息反馈 
		 */		
		public function ordainAndCancel(officeId:int,roleName:String):void{
			var item:OfficialItem = getItemByOfficeId(officeId);
			if(item){
				item.setRoleInfo(0,roleName,roleName);
				item.setState(OfficialItem.CANCEL);
			}
		}
		/**
		 * 任命成功 
		 */		
		public function ordain(officeId:int,roleName:String):void{
			var item:OfficialItem = getItemByOfficeId(officeId);
			if(item){
				item.setRoleInfo(0,roleName,"");
				item.setState(OfficialItem.DISMISS);
			}
		}
		
		/**
		 * 解除职务 
		 */		
		public function disappoint(officeId:int):void{
			var item:OfficialItem = getItemByOfficeId(officeId);
			if(item){
				item.setRoleInfo(0,"","");
				item.setState(OfficialItem.ORDAIN);
			}
		}
		
		/**
		 * 撤销任命 
		 */		
		public function cancelAppoint(officeId:int):void{
			var item:OfficialItem = getItemByOfficeId(officeId);
			if(item){
				item.setRoleInfo(0,"","");
				item.setState(OfficialItem.ORDAIN);
			}	
		}
		
		private function getItemByOfficeId(officeId:int):OfficialItem{
			var item:OfficialItem;
			if(officeId == OfficialConstants.OFFICIAL_CHENGXIANG){
				item = chengxiangItem;
			}else if(officeId == OfficialConstants.OFFICIAL_DAJIANGJUN){
				item = dajiangjunItem;
			}else if(officeId == OfficialConstants.OFFICIAL_JINYIWEI){
				item = jinyiweiItem;
			}
			return item;
		}
		
		private function getState(role:p_office_position):int{
			if(role.role_id != 0){
				return OfficialItem.DISMISS;
			}else if(role.role_id == 0 && role.invite_role_id == 0){
				return OfficialItem.ORDAIN;
			}else{
				return OfficialItem.CANCEL;
			}
		}
		
		private function onMouseClick(event:MouseEvent):void{
			WindowManager.getInstance().removeWindow(this);
		}
	}
}
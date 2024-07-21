package modules.family.views
{
	import flash.display.Sprite;
	
	import proto.common.p_family_info;
	
	public class FamilyPlacard extends Sprite
	{
		private var familyInfoBg:Sprite;
		
		private var familyPlacard:Placard;
		private var familyOutPlacard:Placard;
		
		private var familyInfo:FamilyInfo;
		public function FamilyPlacard(){
			init();
		}
				
		private function init():void{
			familyInfo = new FamilyInfo();
			Style.setBorderSkin(familyInfo);
			familyInfo.width = 459;
			familyInfo.height = 85;
			familyInfo.y = 2;
			familyInfo.x = 3;
			addChild(familyInfo);
			
			familyPlacard = new Placard("门派公告");
			Style.setBorderSkin(familyPlacard);
			familyPlacard.isprivate = true;
			familyPlacard.x = 3;
			familyPlacard.y = 89;
			familyPlacard.width = 459;
			familyPlacard.height = 110;
			addChild(familyPlacard);
			
			familyOutPlacard = new Placard("对外公告");
			Style.setBorderSkin(familyOutPlacard);
			familyOutPlacard.isprivate = false;
			familyOutPlacard.x = 3;
			familyOutPlacard.y = 199;
			familyOutPlacard.width = 459;
			familyOutPlacard.height = 110;
			addChild(familyOutPlacard);
		}
		
		private var info:p_family_info;
		public function setFamilyInfo(info:p_family_info):void{
			this.info = info;
			familyInfo.setFamilyInfo(info);
			familyPlacard.setPlacard(info.private_notice);
			familyOutPlacard.setPlacard(info.public_notice);
		}
		
		public function updateFamilyInfo():void{
			setFamilyInfo(info);
			updateFactioin();
		}
		
		public function updateFactioin():void{
			familyPlacard.updateFaction();
			familyOutPlacard.updateFaction();
		}
		
		public function updatePlacard(content:String,isprivate:Boolean):void{
			if(isprivate){
				familyPlacard.setPlacard(content);
			}else{
				familyOutPlacard.setPlacard(content);
			}
		}
	}
}
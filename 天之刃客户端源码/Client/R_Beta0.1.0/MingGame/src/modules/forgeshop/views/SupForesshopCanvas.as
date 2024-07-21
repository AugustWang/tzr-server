package modules.forgeshop.views
{
	import flash.text.TextField;
	
	import modules.forgeshop.views.items.EquipItem;
	
	
	public class SupForesshopCanvas extends ForesshopCanvas
	{
	 
		public var equipUpgradeCanvas:EquipUpgradeCanvas;
		public var equipResolveCanvas:EquipResolveCanvas;
		public var supRightCanvas:SupRightCanvas;
		public  var equipItem :EquipItem= new EquipItem();
		public  var titleLabel:TextField;
		
		public function SupForesshopCanvas(index:int)
		{
			super(); 
			
			this.width =  410;			 
			this.height = 300;	
		 
		
			if(index == 2){
					
				if(equipUpgradeCanvas == null)
						equipUpgradeCanvas = new EquipUpgradeCanvas(); 
							
					this.addChildAt(equipUpgradeCanvas,1);
			}
			else  if(index == 3){
							if(equipResolveCanvas == null)
						   equipResolveCanvas = new EquipResolveCanvas(); 
							
							this.addChildAt(equipResolveCanvas,1);
				}
			
			//changeRightCanvas(index);
          
		}
//		
//		public function changeRightCanvas(index:int):void{
//		//	//  trace("this.numChildren ======"+this.numChildren );
//			////  trace("this.contains(supLeftCanvas)======"+ this.contains(supLeftCanvas) );
//			 
////			if(!this.contains(supLeftCanvas))
//				addChild(supLeftCanvas);
//			
//			
////			if(this.numChildren >=2)
////		    	removeChildAt(1);						
//		
//						
//			if(index == 2){
//				
//				if(equipUpgradeCanvas == null)
//					equipUpgradeCanvas = new EquipUpgradeCanvas(); 
//				
//				this.addChildAt(equipUpgradeCanvas,1);
//				
//				supLeftCanvas.changeTitleText("升级");
//			}
//			else  if(index == 3){
//				if(equipResolveCanvas == null)
//				   equipResolveCanvas = new EquipResolveCanvas(); 
//				
//				this.addChildAt(equipResolveCanvas,1);
//				
//				supLeftCanvas.changeTitleText("分解");
//			}
//			
//		}
	}
}
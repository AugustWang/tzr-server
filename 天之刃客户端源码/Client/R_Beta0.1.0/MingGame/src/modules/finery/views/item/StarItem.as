package modules.finery.views.item {
	import com.globals.GameConfig;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;

	public class StarItem extends Sprite {
		private var startArray:Array=[];
		private var grayStartArr:Array=[];

		public function StarItem() {
		}
		
		private function clean():void{
			while(numChildren>0){
				removeChildAt(numChildren-1);
			}
		}
		
		/**
		 *1级强化：白色2级强化：绿色3级强化：蓝色4级强化：紫色5级强化：橙色6级强化：金色
		 */
		public function set data(value:EquipVO):void {
			var starts:int;
			var startsLvl:int;
			clean();
			if(value!=null){
				starts=value.reinforce_result % 10;
				startsLvl=int(String(value.reinforce_result).charAt(0));
				for (var k:int=0; k < 6; k++) { //灰色的星星
					var grayStar:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI,"xing_07");
					grayStar.x=k * 20;
					grayStar.y=10;
					this.addChild(grayStar);
					grayStartArr.push(grayStar);
				}
				for (var i:int; i < starts; i++) { //金色的星星
					var startSprite:Bitmap;
					if (startsLvl == 1) {
						startSprite=Style.getBitmap(GameConfig.T1_VIEWUI,"xing_00");
					} else if (startsLvl == 2) {
						startSprite=Style.getBitmap(GameConfig.T1_VIEWUI,"xing_01");
					} else if (startsLvl == 3) {
						startSprite=Style.getBitmap(GameConfig.T1_VIEWUI,"xing_02");
					} else if (startsLvl == 4) {
						startSprite=Style.getBitmap(GameConfig.T1_VIEWUI,"xing_03");
					} else if (startsLvl == 5) {
						startSprite=Style.getBitmap(GameConfig.T1_VIEWUI,"xing_04");
					} else if (startsLvl == 6) {
						startSprite=Style.getBitmap(GameConfig.T1_VIEWUI,"xing_05");
					}
					startSprite.x=i * 20;
					startSprite.y=10;
					this.addChild(startSprite);
					startArray.push(startSprite);
				}
			}
		}
	}
}
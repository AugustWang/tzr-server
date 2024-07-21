package modules.duplicate.views.vo
{
	import proto.common.p_educate_fb_award;

	public class DuplicateAwardVO{
		
		public var count:int;
		public var luckyCount:int;
		public var maxLuckyCount:int;
		public var awardGoodsArray:Array;
		public var awardConfigArray:Array;
		
		public function DuplicateAwardVO(){
			
		}
		private var _curAwardNumber:int;
		public function get curAwardNumber():int{
			if(awardConfigArray == null){
				return 0;
			}
			_curAwardNumber = 0;
			var flag:Boolean = false;
			var sumCount:int = count + luckyCount;
			for(var i:int = 0; i < awardConfigArray.length; i ++ ){
				var awardGoods:p_educate_fb_award = awardConfigArray[i] as p_educate_fb_award;
				if(!flag && sumCount >= awardGoods.min_count
					&& awardGoods.max_count >= sumCount){
					flag = true;
					_curAwardNumber = awardGoods.award_number;
				}
			}
			return _curAwardNumber;
		}
		private var _maxAwardNumber:int;
		public function get maxAwardNumber():int{
			var maxCount:int = this.maxLuckyCount + this.count;
			if(awardConfigArray == null){
				return 0;
			}
			_maxAwardNumber = 0;
			awardConfigArray.sortOn("min_count",Array.NUMERIC);
			var flag:Boolean = false;
			for(var i:int = 0; i < awardConfigArray.length; i ++ ){
				var awardGoods:p_educate_fb_award = awardConfigArray[i] as p_educate_fb_award;
				if(!flag && maxCount >= awardGoods.min_count
					&& awardGoods.max_count >= maxCount){
					flag = true;
					_maxAwardNumber = awardGoods.award_number;
				}
			}
			return _maxAwardNumber;
		}
		
		
		private var _curAwardColorValue:String;
		public function get curAwardColorValue():String{
			if(awardConfigArray == null){
				return "#ffffff";
			}
			_curAwardColorValue = "#ffffff";
			var flag:Boolean = false;
			var sumCount:int = count + luckyCount;
			awardConfigArray.sortOn("min_count",Array.NUMERIC);
			for(var i:int = 0; i < awardConfigArray.length; i ++ ){
				var awardGoods:p_educate_fb_award = awardConfigArray[i] as p_educate_fb_award;
				if(!flag && sumCount >= awardGoods.min_count
					&& awardGoods.max_count >= sumCount){
					flag = true;
					switch(i + 1){
						case 1:
							_curAwardColorValue = "#ffffff";
							break;
						case 2:
							_curAwardColorValue = "#12cc95";
							break;
						case 3:
							_curAwardColorValue = "#0d79ff";
							break;
						case 4:
							_curAwardColorValue = "#fe00e9";
							break;
						case 5:
							_curAwardColorValue = "#ff7e00";
							break;
						case 6:
							_curAwardColorValue = "#FFD700";
							break;
					}//end switch
				}//end if
			}//end for
			return _curAwardColorValue;
		}
		
		
	}
}
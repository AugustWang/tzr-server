package modules.roleStateG.views.items
{
	import com.ming.ui.layout.LayoutUtil;
	
	import flash.display.Sprite;
	
	import modules.buff.BuffModule;
	
	import proto.common.p_actor_buf;
	
	public class BuffIconBox extends Sprite
	{
		public static var BUFF_XML_PATH:String = "com/data/buff.xml";
		public static var BUFF_PATH:String = 'com/assets/buffIcon/';
		
		
		public function BuffIconBox()
		{
		}
		
		public function setDataSource(buff:Array):void
		{
			updateDataSource(buff);
		}
		
		private var buffs:Array = [];
		private var buffs_view:Array = [];
		public function updateDataSource($buff:Array):void
		{
			var buffs_temp:Array = $buff.concat();
			if($buff != null && $buff.length != 0){
			}
			removeBuff(BuffModule.checkBuffRemove(buffs,buffs_temp));
			addBuff(BuffModule.checkBuffAdd(buffs,buffs_temp));
			
			var buffs_target_view:Array = BuffModule.getShowItems(buffs_temp);
			if(!BuffModule.check(buffs_view,buffs_target_view)){
				removeAllBuff();
				addBuff(buffs_temp);
			}
			
			buffs = buffs_temp;
			//调整位置
			updataTime();
			LayoutUtil.layoutGrid(this,5,23,23);
			//启动更新
		}
		
		private function updataTime():void{
			//
			for(var i:int = 0; i < numChildren; i++){
				var buffItem:BuffItem = getChildAt(i) as BuffItem
				for(var j:int = 0; j < buffs.length; j++){
					if(buffItem.buff.buff_id == buffs[j].buff_id){
						if(buffItem.buff.start_time != buffs[j].start_time || buffItem.buff.remain_time != buffs[j].remain_time){
							buffItem.updata(buffs[j]);
						}
					}
				}
			}
		}
		
		private function addBuff(value:Array):void{
			for(var i:int = 0; i < value.length; i++){
				var vo:p_actor_buf = value[i] as p_actor_buf;
				if(!BuffModule.isShow(vo.buff_id))continue;
				var buffItem:BuffItem = new BuffItem(vo,vo.remain_time != 0);
				buffItem.name = vo.buff_id.toString();
				addChild(buffItem);
				buffs_view.push(vo);
			}
		}
		
		private function removeBuff(value:Array):void{
			for(var i:int=0;i<value.length;i++)
			{
				var vo:p_actor_buf = value[i] as p_actor_buf;
				var buffItem:BuffItem = getChildByName(vo.buff_id.toString()) as BuffItem;
				if(buffItem){
					removeChild(buffItem);
					for(var j:int = 0; j < buffs_view.length; j++){
						if(buffs_view[j].buff_id == vo.buff_id){
							buffs_view.splice(j,1);
						}
					}
					buffItem.dispose();
				}
			}
		}
		
		private function removeAllBuff():void{
			while(numChildren){
				var buffItem:BuffItem = getChildAt(0) as BuffItem
				removeChild(buffItem);
				buffItem.dispose();
				buffItem = null;
			}
			buffs = [];
			buffs_view = [];
		}
	}
}
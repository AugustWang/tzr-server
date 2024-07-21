package modules.roleStateG.views.states
{
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.ming.ui.layout.LayoutUtil;
	
	import flash.display.Sprite;
	
	import modules.buff.BuffModule;
	import modules.roleStateG.views.items.BuffItem;
	import modules.system.SystemConfig;
	
	import proto.common.p_actor_buf;
	import proto.line.p_sys_buff_info;
	
	public class RoleBuffView extends Sprite
	{
		public static var BUFF_XML_PATH:String=GameConfig.ROOT_URL+"com/data/buff.xml";
		public static var BUFF_PATH:String=GameConfig.ROOT_URL+'com/assets/buffIcon/';
		
		public var showTime:Boolean = true;
		public var _systemBuff:Array = [];
		
		public function RoleBuffView(px:Number, py:Number)
		{
			super();
			this.x=px;
			this.y=py;
		}
		
		public function update():void{}
		
		public function setDataSource(buff:Array):void
		{
			updateDataSource(buff);
		}
		
		private var buffs:Array=[];
		private var buffs_view:Array=[];
		
		public function updateDataSource($buff:Array):void
		{
			//暂停刷新
			if ($buff == null){
				removeAllBuff();
				return ;
			}
			var buffs_temp:Array=$buff.concat();
			
			removeBuff(BuffModule.checkBuffRemove(buffs, buffs_temp));
			addBuff(BuffModule.checkBuffAdd(buffs, buffs_temp));
			
			var buffs_target_view:Array=BuffModule.getShowItems(buffs_temp);
			if (!BuffModule.check(buffs_view, buffs_target_view))
			{
				removeAllBuff();
				addBuff(buffs_temp);
			}
			
			buffs=buffs_temp;
			//调整位置
			//setBuffIndex(buffs_target_view);
			
			updataTime();
			
			if( GlobalObjectManager.getInstance().system_buff.length > 0 && showTime ){
				var sysBuff:Array = GlobalObjectManager.getInstance().system_buff;
				for( var i:int = 0; i < sysBuff.length; i++ ){
					var buff:p_sys_buff_info = sysBuff[i];
					var has:Boolean = false;
					for( var j:int = 0; j < _systemBuff.length; j++ ){
						if( buff.buff_type == _systemBuff[j].buffId )has = true;
					}
					if( !has ){
						var buffvo:p_actor_buf = new p_actor_buf();
						buffvo.buff_id = GlobalObjectManager.getInstance().system_buff[0].buff_type;
						buffvo.remain_time = GlobalObjectManager.getInstance().system_buff[0].remain_time;
						buffvo.end_time = SystemConfig.serverTime + buffvo.remain_time;
						var buffItem:BuffItem = new BuffItem( buffvo , buffvo.remain_time != 0 );
						buffItem.callback = systemBuffComplete;
						addChild(buffItem);
						_systemBuff.push(buffItem);
					}
				}
			}
			LayoutUtil.layoutGrid(this, 5, 23, 23);
			//启动更新
		}
		
		private function systemBuffComplete(buffID:int):void{
			for( var i:int = 0; i < GlobalObjectManager.getInstance().system_buff.length; i++ ){
				var buff:p_sys_buff_info = GlobalObjectManager.getInstance().system_buff[i];
				if( buff.buff_type == buffID ){
					GlobalObjectManager.getInstance().system_buff.splice(i);
					i--;
				}
			};
			for( var j:int = 0; j < _systemBuff.length; j++ ){
				if( buffID == _systemBuff[j].buffId ){
					_systemBuff.splice(j);
					j--;
				}
			}
			LayoutUtil.layoutGrid(this, 5, 23, 23);
		}
		
		private function updataTime():void
		{
			for (var i:int=0; i < numChildren; i++)
			{
				var buffItem:BuffItem=getChildAt(i)as BuffItem
				for (var j:int=0; j < buffs.length; j++)
				{
					if (buffItem.buff.buff_id == buffs[j].buff_id)
					{
						if (buffItem.buff.start_time != buffs[j].start_time || buffItem.buff.remain_time != buffs[j].remain_time)
						{
							buffItem.updata(buffs[j]);
						}
					}
				}
			}
		}
		
		private function addBuff(value:Array):void
		{
			for (var i:int=0; i < value.length; i++)
			{
				var vo:p_actor_buf=value[i]as p_actor_buf;
				if (!BuffModule.isShow(vo.buff_id))
					continue;
				var buffItem:BuffItem
				if(showTime){
					buffItem=new BuffItem(vo, vo.remain_time != 0);
				}else{
					buffItem=new BuffItem(vo);
				}
				
				buffItem.name=vo.buff_id.toString();
				addChild(buffItem);
				buffs_view.push(vo);
			}
		}
		
		private function removeBuff(value:Array):void
		{
			for (var i:int=0; i < value.length; i++)
			{
				var vo:p_actor_buf=value[i]as p_actor_buf;
				var buffItem:BuffItem=getChildByName(vo.buff_id.toString())as BuffItem;
				if (buffItem)
				{
					removeChild(buffItem);
					for (var j:int=0; j < buffs_view.length; j++)
					{
						if (buffs_view[j].buff_id == vo.buff_id)
						{
							buffs_view.splice(j, 1);
						}
					}
				}
			}
		}
		
		private function removeAllBuff():void
		{
			while (numChildren)
			{
				var buffItem:BuffItem=getChildAt(0)as BuffItem
				removeChild(buffItem);
				//buffItem.dispose();
				buffItem=null;
			}
			buffs=[];
			buffs_view=[];
		}
	}
}
package modules.buff
{
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.loaders.CommonLocator;
	
	import flash.utils.Dictionary;
	
	import modules.BaseModule;
	import modules.roleStateG.RoleStateModule;
	import modules.roleStateG.views.items.BuffItem;
	import modules.skill.SkillModule;
	
	import proto.common.p_actor_buf;

	/**
	 *  状态模块 处理状态的更新方法 
	 * @author dongwoming
	 * 
	 */	
	public class BuffModule extends BaseModule
	{
		private static var buffs:Dictionary;
		private static var name:Vector.<String>;
		private static var description:Vector.<String>;
		private static var icon:Vector.<String>;
		private static var instance:BuffModule;
		
		public static function init():void{
			var buffXML:XMLList = CommonLocator.getXML(CommonLocator.BUFF_XML_PATH).buff;
			var l:int = buffXML.length();
			buffs = new Dictionary();
			name = new Vector.<String>(l);
			description = new Vector.<String>(l);
			icon = new Vector.<String>(l);
			for( var i:int = 0; i < l; i++){
				buffs[buffXML[i].@id.toString()] = i;
				name[i] = buffXML[i].@name.toString();
				description[i] = buffXML[i].@description.toString();
				icon[i] = buffXML[i].@icon.toString();
			}
		}
		
		public static function checkBuffAdd($source:Array,$target:Array):Array{
			var source:Array = $source.concat();
			var target:Array = $target.concat();
			for(var i:int = 0; i < target.length; i++){
				var buff_target:p_actor_buf = target[i] as p_actor_buf;
				if(buff_target == null)continue;
				for(var j:int = 0; j < source.length; j++){
					var buff_source:p_actor_buf = source[j] as p_actor_buf;
					if(buff_source == null)continue;
					if(buff_source.buff_id == buff_target.buff_id && buff_source.value == buff_target.value){
						target.splice(i,1);
						i--;
					}
				}
			}
			return target;
		}
		
		public static function checkBuffRemove($source:Array,$target:Array):Array{
			var source:Array = $source.concat();
			var target:Array = $target.concat();
			for(var i:int = 0; i < source.length; i++){
				var buff_source:p_actor_buf = source[i] as p_actor_buf;
				if(buff_source == null)continue;
				for(var j:int = 0; j < target.length; j++){
					var buff_target:p_actor_buf = target[j] as p_actor_buf;
					if(buff_target == null)continue;
					if(buff_source.buff_id == buff_target.buff_id){
						source.splice(i,1);
						i--;
					}
				}
			}
			return source;
		}
		
		public static function checkBuffUpdata($source:Array,$target:Array):Array{
			var source:Array = $source.concat();
			var target:Array = $target.concat();
			var updatas:Array = [];
			for(var i:int = 0; i < source.length; i++){
				var buff_source:p_actor_buf = source[i] as p_actor_buf;
				if(buff_source == null)continue;
				for(var j:int = 0; j < target.length; j++){
					var buff_target:p_actor_buf = target[j] as p_actor_buf;
					if(buff_target == null)continue;
					if(buff_source.buff_id == buff_target.buff_id && buff_source.start_time != buff_target.start_time){
						updatas.push(buff_target);
					}
				}
			}
			return updatas;
		}
		
		public static function checkHasBuff(buffID:int,buffs:Array):Boolean{
			for (var i:int=0; i < buffs.length; i++) {
				var buff:p_actor_buf=buffs[i] as p_actor_buf;
				if (buffID == buff.buff_id) {
					return true;
				}
			}
			return false
		}
		
		public static function getShowItems($target:Array):Array{
			var target:Array = $target.concat();
			for(var i:int = 0; i < target.length; i++){
				var buff:p_actor_buf = target[i] as p_actor_buf;
				if(!isShow(buff.buff_id)){
					target.splice(i,1);
					i--;
				}
			}
			return target;
		}
		
		public static function isShow(id:int):Boolean{
			return buffs.hasOwnProperty(id);
		}
		
		
		public static function createImageUrl(id:int):String{
			var s:String = GameConfig.BUFF_ICON_PATH + icon[buffs[id]];
			return s;
		}
		
		public static function createTooltip(id:int,value:int):String{
			var s:String = '';
			var buffName:String = name[buffs[id]];
			var buffDesc:String = description[buffs[id]];
			if(buffDesc.indexOf('%') != -1){
				s += "<font color='#FFFFFF'>"+buffName.replace('#',value*0.01) + '</font>\n';
				s += "<font color='#FFFFFF'>"+buffDesc.replace('#',value*0.01) + '</font>\n';
			}else if(buffDesc.indexOf('倍') != -1){
				s += "<font color='#FFFFFF'>"+buffName.replace('#',value*0.0001) + '</font>\n';
				s += "<font color='#FFFFFF'>"+buffDesc.replace('#',value*0.0001) + '</font>\n';
			}else{
				s += "<font color='#FFFFFF'>"+buffName.replace('#',value) + '</font>\n';
				s += "<font color='#FFFFFF'>"+buffDesc.replace('#',value) + '</font>\n';
			}
			return s;
		}
		
		public static function check(source:Array,target:Array):Boolean{
			if(source.length != target.length)return false;
			//每个对比
			return true;
		}
		
		public static function checkEXPBuff(value:Number):String{
			var buffs:Array = GlobalObjectManager.getInstance().user.base.buffs;
			for(var i:int = 0; i < buffs.length; i++){
				var buff:p_actor_buf = buffs[i] as p_actor_buf;
				if(buff.buff_id >= 9011 && buff.buff_id <= 9030){
					var buffValue:Number = 1+ buff.value*0.0001
					if(buffValue != value){
						var buffItem:BuffItem = RoleStateModule.getInstance().buffBox.getChildByName(buff.buff_id.toString()) as BuffItem;
						return '你当前还有'+timeFormat(buffItem.remainTime)+'的'+buffValue+'倍经验收益，使用不同种类的经验符会消除原来的经验状态，是否确定使用?';
					}
				}  
			}
			return '';
		}
		
		//蛋痛啊! 画个圈圈，诅咒他们
		public static function checkDrunkBuff(buffid:Number):String{
			var buffs:Array = GlobalObjectManager.getInstance().user.base.buffs;
			for(var i:int = 0; i < buffs.length; i++){
				var buff:p_actor_buf = buffs[i] as p_actor_buf;
				if(buff.buff_type == 1035){
					if(buff.buff_id != buffid){
						return '你的醉酒状态将会被替换，是否继续使用？';
					}
				}  
			}
			return '';
		}
		
		private static function timeFormat(time:Number):String{
			//var   seconds:String =  (int(   time   %   60   )).toString(); 
			var minutes:String = (int(time/60%60)).toString(); 
			var hours:String = (int(time/60/60)).toString(); 
			//if   (int(seconds) <   10) {seconds =   "0 "   +   seconds;} 
			if(int(minutes) <   10){ minutes =   "0"   +   minutes;} 
			if(int(hours)<   10) {hours =   "0"   +   hours;} 
			if(int(hours) == 0)return minutes + '分钟';
			if(int(hours) != 0 && int(minutes)== 0)return hours + '小时';
			return hours + '小时' + minutes + '分钟';
		}
	}
}
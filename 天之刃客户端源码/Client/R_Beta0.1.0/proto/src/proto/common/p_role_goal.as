package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_role_goal extends Message
	{
		public var role_id:int = 0;
		public var goals:Array = new Array;
		public var days:int = 0;
		public function p_role_goal() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_role_goal", p_role_goal);
		}
		public override function getMethodName():String {
			return 'role_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			var size_goals:int = this.goals.length;
			output.writeShort(size_goals);
			var temp_repeated_byte_goals:ByteArray= new ByteArray;
			for(i=0; i<size_goals; i++) {
				var t2_goals:ByteArray = new ByteArray;
				var tVo_goals:p_role_goal_item = this.goals[i] as p_role_goal_item;
				tVo_goals.writeToDataOutput(t2_goals);
				var len_tVo_goals:int = t2_goals.length;
				temp_repeated_byte_goals.writeInt(len_tVo_goals);
				temp_repeated_byte_goals.writeBytes(t2_goals);
			}
			output.writeInt(temp_repeated_byte_goals.length);
			output.writeBytes(temp_repeated_byte_goals);
			output.writeInt(this.days);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			var size_goals:int = input.readShort();
			var length_goals:int = input.readInt();
			if (length_goals > 0) {
				var byte_goals:ByteArray = new ByteArray; 
				input.readBytes(byte_goals, 0, length_goals);
				for(i=0; i<size_goals; i++) {
					var tmp_goals:p_role_goal_item = new p_role_goal_item;
					var tmp_goals_length:int = byte_goals.readInt();
					var tmp_goals_byte:ByteArray = new ByteArray;
					byte_goals.readBytes(tmp_goals_byte, 0, tmp_goals_length);
					tmp_goals.readFromDataOutput(tmp_goals_byte);
					this.goals.push(tmp_goals);
				}
			}
			this.days = input.readInt();
		}
	}
}

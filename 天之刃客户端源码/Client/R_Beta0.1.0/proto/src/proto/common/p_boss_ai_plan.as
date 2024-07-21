package proto.common {
	import proto.common.p_boss_ai_condition;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_boss_ai_plan extends Message
	{
		public var boss_typeid:int = 0;
		public var conditions:Array = new Array;
		public function p_boss_ai_plan() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_boss_ai_plan", p_boss_ai_plan);
		}
		public override function getMethodName():String {
			return 'boss_ai_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.boss_typeid);
			var size_conditions:int = this.conditions.length;
			output.writeShort(size_conditions);
			var temp_repeated_byte_conditions:ByteArray= new ByteArray;
			for(i=0; i<size_conditions; i++) {
				var t2_conditions:ByteArray = new ByteArray;
				var tVo_conditions:p_boss_ai_condition = this.conditions[i] as p_boss_ai_condition;
				tVo_conditions.writeToDataOutput(t2_conditions);
				var len_tVo_conditions:int = t2_conditions.length;
				temp_repeated_byte_conditions.writeInt(len_tVo_conditions);
				temp_repeated_byte_conditions.writeBytes(t2_conditions);
			}
			output.writeInt(temp_repeated_byte_conditions.length);
			output.writeBytes(temp_repeated_byte_conditions);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.boss_typeid = input.readInt();
			var size_conditions:int = input.readShort();
			var length_conditions:int = input.readInt();
			if (length_conditions > 0) {
				var byte_conditions:ByteArray = new ByteArray; 
				input.readBytes(byte_conditions, 0, length_conditions);
				for(i=0; i<size_conditions; i++) {
					var tmp_conditions:p_boss_ai_condition = new p_boss_ai_condition;
					var tmp_conditions_length:int = byte_conditions.readInt();
					var tmp_conditions_byte:ByteArray = new ByteArray;
					byte_conditions.readBytes(tmp_conditions_byte, 0, tmp_conditions_length);
					tmp_conditions.readFromDataOutput(tmp_conditions_byte);
					this.conditions.push(tmp_conditions);
				}
			}
		}
	}
}

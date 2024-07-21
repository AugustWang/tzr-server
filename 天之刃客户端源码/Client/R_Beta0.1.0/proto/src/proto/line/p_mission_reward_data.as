package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_mission_reward_data extends Message
	{
		public var exp:int = 0;
		public var silver:int = 0;
		public var silver_bind:int = 0;
		public var prop:Array = new Array;
		public var prestige:int = 0;
		public function p_mission_reward_data() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_mission_reward_data", p_mission_reward_data);
		}
		public override function getMethodName():String {
			return 'mission_reward_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.exp);
			output.writeInt(this.silver);
			output.writeInt(this.silver_bind);
			var size_prop:int = this.prop.length;
			output.writeShort(size_prop);
			var temp_repeated_byte_prop:ByteArray= new ByteArray;
			for(i=0; i<size_prop; i++) {
				var t2_prop:ByteArray = new ByteArray;
				var tVo_prop:p_mission_prop = this.prop[i] as p_mission_prop;
				tVo_prop.writeToDataOutput(t2_prop);
				var len_tVo_prop:int = t2_prop.length;
				temp_repeated_byte_prop.writeInt(len_tVo_prop);
				temp_repeated_byte_prop.writeBytes(t2_prop);
			}
			output.writeInt(temp_repeated_byte_prop.length);
			output.writeBytes(temp_repeated_byte_prop);
			output.writeInt(this.prestige);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.exp = input.readInt();
			this.silver = input.readInt();
			this.silver_bind = input.readInt();
			var size_prop:int = input.readShort();
			var length_prop:int = input.readInt();
			if (length_prop > 0) {
				var byte_prop:ByteArray = new ByteArray; 
				input.readBytes(byte_prop, 0, length_prop);
				for(i=0; i<size_prop; i++) {
					var tmp_prop:p_mission_prop = new p_mission_prop;
					var tmp_prop_length:int = byte_prop.readInt();
					var tmp_prop_byte:ByteArray = new ByteArray;
					byte_prop.readBytes(tmp_prop_byte, 0, tmp_prop_length);
					tmp_prop.readFromDataOutput(tmp_prop_byte);
					this.prop.push(tmp_prop);
				}
			}
			this.prestige = input.readInt();
		}
	}
}

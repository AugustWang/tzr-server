package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_equip_endurance_info extends Message
	{
		public var equip_id:int = 0;
		public var num:int = 0;
		public var max_num:int = 0;
		public function p_equip_endurance_info() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_equip_endurance_info", p_equip_endurance_info);
		}
		public override function getMethodName():String {
			return 'equip_endurance_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.equip_id);
			output.writeInt(this.num);
			output.writeInt(this.max_num);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.equip_id = input.readInt();
			this.num = input.readInt();
			this.max_num = input.readInt();
		}
	}
}

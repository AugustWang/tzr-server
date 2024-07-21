package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_role_fight extends Message
	{
		public var role_id:int = 0;
		public var hp:int = 0;
		public var mp:int = 0;
		public var energy:int = 0;
		public var energy_remain:int = 0;
		public var time_reset_energy:int = 0;
		public function p_role_fight() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_role_fight", p_role_fight);
		}
		public override function getMethodName():String {
			return 'role_f';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			output.writeInt(this.hp);
			output.writeInt(this.mp);
			output.writeInt(this.energy);
			output.writeInt(this.energy_remain);
			output.writeInt(this.time_reset_energy);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.hp = input.readInt();
			this.mp = input.readInt();
			this.energy = input.readInt();
			this.energy_remain = input.readInt();
			this.time_reset_energy = input.readInt();
		}
	}
}

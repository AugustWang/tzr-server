package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_role_pet_grow extends Message
	{
		public var role_id:int = 0;
		public var state:int = 1;
		public var grow_type:int = 0;
		public var grow_over_tick:int = 0;
		public var grow_tick:int = 0;
		public var con_level:int = 0;
		public var phy_defence_level:int = 0;
		public var magic_defence_level:int = 0;
		public var phy_attack_level:int = 0;
		public var magic_attack_level:int = 0;
		public function p_role_pet_grow() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_role_pet_grow", p_role_pet_grow);
		}
		public override function getMethodName():String {
			return 'role_pet_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			output.writeInt(this.state);
			output.writeInt(this.grow_type);
			output.writeInt(this.grow_over_tick);
			output.writeInt(this.grow_tick);
			output.writeInt(this.con_level);
			output.writeInt(this.phy_defence_level);
			output.writeInt(this.magic_defence_level);
			output.writeInt(this.phy_attack_level);
			output.writeInt(this.magic_attack_level);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.state = input.readInt();
			this.grow_type = input.readInt();
			this.grow_over_tick = input.readInt();
			this.grow_tick = input.readInt();
			this.con_level = input.readInt();
			this.phy_defence_level = input.readInt();
			this.magic_defence_level = input.readInt();
			this.phy_attack_level = input.readInt();
			this.magic_attack_level = input.readInt();
		}
	}
}

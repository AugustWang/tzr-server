package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_use_requirement extends Message
	{
		public var sex:int = 0;
		public var min_level:int = 0;
		public var max_level:int = 0;
		public var min_power:int = 0;
		public var min_agile:int = 0;
		public var min_brain:int = 0;
		public var min_vitality:int = 0;
		public var min_spirit:int = 0;
		public function p_use_requirement() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_use_requirement", p_use_requirement);
		}
		public override function getMethodName():String {
			return 'use_require';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.sex);
			output.writeInt(this.min_level);
			output.writeInt(this.max_level);
			output.writeInt(this.min_power);
			output.writeInt(this.min_agile);
			output.writeInt(this.min_brain);
			output.writeInt(this.min_vitality);
			output.writeInt(this.min_spirit);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.sex = input.readInt();
			this.min_level = input.readInt();
			this.max_level = input.readInt();
			this.min_power = input.readInt();
			this.min_agile = input.readInt();
			this.min_brain = input.readInt();
			this.min_vitality = input.readInt();
			this.min_spirit = input.readInt();
		}
	}
}

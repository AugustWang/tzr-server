package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_drop_property extends Message
	{
		public var bind:Boolean = false;
		public var colour:int = 0;
		public var quality:int = 0;
		public var hole_num:int = 0;
		public var use_bind:int = 0;
		public function p_drop_property() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_drop_property", p_drop_property);
		}
		public override function getMethodName():String {
			return 'drop_prop';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.bind);
			output.writeInt(this.colour);
			output.writeInt(this.quality);
			output.writeInt(this.hole_num);
			output.writeInt(this.use_bind);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.bind = input.readBoolean();
			this.colour = input.readInt();
			this.quality = input.readInt();
			this.hole_num = input.readInt();
			this.use_bind = input.readInt();
		}
	}
}

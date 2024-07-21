package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_family_task extends Message
	{
		public var id:int = 0;
		public var status:int = 0;
		public function p_family_task() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_family_task", p_family_task);
		}
		public override function getMethodName():String {
			return 'family_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			output.writeInt(this.status);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.status = input.readInt();
		}
	}
}

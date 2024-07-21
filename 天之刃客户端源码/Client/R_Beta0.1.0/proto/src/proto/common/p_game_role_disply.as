package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_game_role_disply extends Message
	{
		public var type:int = 1;
		public var value:int = 0;
		public function p_game_role_disply() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_game_role_disply", p_game_role_disply);
		}
		public override function getMethodName():String {
			return 'game_role_di';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.type);
			output.writeInt(this.value);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.type = input.readInt();
			this.value = input.readInt();
		}
	}
}

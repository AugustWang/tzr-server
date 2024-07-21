package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_flowers_accept_toc extends Message
	{
		public var succ:Boolean = true;
		public var id:int = 0;
		public var give_role_id:int = 0;
		public function m_flowers_accept_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_flowers_accept_toc", m_flowers_accept_toc);
		}
		public override function getMethodName():String {
			return 'flowers_accept';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			output.writeInt(this.id);
			output.writeInt(this.give_role_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.id = input.readInt();
			this.give_role_id = input.readInt();
		}
	}
}

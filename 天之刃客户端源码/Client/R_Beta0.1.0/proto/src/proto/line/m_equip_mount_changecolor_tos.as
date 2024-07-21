package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_equip_mount_changecolor_tos extends Message
	{
		public var mountid:int = 0;
		public function m_equip_mount_changecolor_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_equip_mount_changecolor_tos", m_equip_mount_changecolor_tos);
		}
		public override function getMethodName():String {
			return 'equip_mount_changecolor';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.mountid);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.mountid = input.readInt();
		}
	}
}

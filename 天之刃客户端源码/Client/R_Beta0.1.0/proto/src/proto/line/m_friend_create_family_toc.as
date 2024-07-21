package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_friend_create_family_toc extends Message
	{
		public var role_id:int = 0;
		public var family_id:int = 0;
		public var family_name:String = "";
		public function m_friend_create_family_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_friend_create_family_toc", m_friend_create_family_toc);
		}
		public override function getMethodName():String {
			return 'friend_create_family';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			output.writeInt(this.family_id);
			if (this.family_name != null) {				output.writeUTF(this.family_name.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.family_id = input.readInt();
			this.family_name = input.readUTF();
		}
	}
}

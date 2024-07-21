package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_set_interior_manager_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var return_self:Boolean = true;
		public var role_id:int = 0;
		public var role_name:String = "";
		public var oldrole_id:int = 0;
		public var oldrole_name:String = "";
		public function m_family_set_interior_manager_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_set_interior_manager_toc", m_family_set_interior_manager_toc);
		}
		public override function getMethodName():String {
			return 'family_set_interior_manager';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.return_self);
			output.writeInt(this.role_id);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.oldrole_id);
			if (this.oldrole_name != null) {				output.writeUTF(this.oldrole_name.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.return_self = input.readBoolean();
			this.role_id = input.readInt();
			this.role_name = input.readUTF();
			this.oldrole_id = input.readInt();
			this.oldrole_name = input.readUTF();
		}
	}
}

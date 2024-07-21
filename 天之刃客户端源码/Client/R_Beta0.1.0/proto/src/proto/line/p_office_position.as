package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_office_position extends Message
	{
		public var office_id:int = 0;
		public var office_name:String = "";
		public var role_id:int = 0;
		public var role_name:String = "";
		public var head:int = 0;
		public var invite_role_id:int = 0;
		public var invite_role_name:String = "";
		public function p_office_position() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_office_position", p_office_position);
		}
		public override function getMethodName():String {
			return 'office_posi';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.office_id);
			if (this.office_name != null) {				output.writeUTF(this.office_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.role_id);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.head);
			output.writeInt(this.invite_role_id);
			if (this.invite_role_name != null) {				output.writeUTF(this.invite_role_name.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.office_id = input.readInt();
			this.office_name = input.readUTF();
			this.role_id = input.readInt();
			this.role_name = input.readUTF();
			this.head = input.readInt();
			this.invite_role_id = input.readInt();
			this.invite_role_name = input.readUTF();
		}
	}
}

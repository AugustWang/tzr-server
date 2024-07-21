package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_five_ele_attr_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var five_ele_attr_level:int = 0;
		public var five_ele_attr:int = 0;
		public function m_role2_five_ele_attr_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_role2_five_ele_attr_toc", m_role2_five_ele_attr_toc);
		}
		public override function getMethodName():String {
			return 'role2_five_ele_attr';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.five_ele_attr_level);
			output.writeInt(this.five_ele_attr);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.five_ele_attr_level = input.readInt();
			this.five_ele_attr = input.readInt();
		}
	}
}

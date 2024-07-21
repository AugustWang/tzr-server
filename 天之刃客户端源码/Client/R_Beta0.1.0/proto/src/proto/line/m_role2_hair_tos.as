package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_hair_tos extends Message
	{
		public var hair_type:int = 0;
		public var hair_color:String = "";
		public function m_role2_hair_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_role2_hair_tos", m_role2_hair_tos);
		}
		public override function getMethodName():String {
			return 'role2_hair';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.hair_type);
			if (this.hair_color != null) {				output.writeUTF(this.hair_color.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.hair_type = input.readInt();
			this.hair_color = input.readUTF();
		}
	}
}

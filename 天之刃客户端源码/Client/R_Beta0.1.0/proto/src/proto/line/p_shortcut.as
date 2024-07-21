package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_shortcut extends Message
	{
		public var type:int = 0;
		public var id:int = 0;
		public var name:String = "";
		public function p_shortcut() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_shortcut", p_shortcut);
		}
		public override function getMethodName():String {
			return 'shor';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.type);
			output.writeInt(this.id);
			if (this.name != null) {				output.writeUTF(this.name.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.type = input.readInt();
			this.id = input.readInt();
			this.name = input.readUTF();
		}
	}
}

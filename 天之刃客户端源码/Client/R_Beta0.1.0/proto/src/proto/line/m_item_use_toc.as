package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_item_use_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:Array = new Array;
		public var itemid:int = 0;
		public var rest:int = 0;
		public function m_item_use_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_item_use_toc", m_item_use_toc);
		}
		public override function getMethodName():String {
			return 'item_use';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			var size_reason:int = this.reason.length;
			output.writeShort(size_reason);
			var temp_repeated_byte_reason:ByteArray= new ByteArray;
			for(i=0; i<size_reason; i++) {
				if (this.reason != null) {					temp_repeated_byte_reason.writeUTF(this.reason[i].toString());
				} else {
					temp_repeated_byte_reason.writeUTF("");
				}
			}
			output.writeInt(temp_repeated_byte_reason.length);
			output.writeBytes(temp_repeated_byte_reason);
			output.writeInt(this.itemid);
			output.writeInt(this.rest);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			var size_reason:int = input.readShort();
			var length_reason:int = input.readInt();
			if (size_reason>0) {
				var byte_reason:ByteArray = new ByteArray; 
				input.readBytes(byte_reason, 0, length_reason);
				for(i=0; i<size_reason; i++) {
					var tmp_reason:String = byte_reason.readUTF(); 
					this.reason.push(tmp_reason);
				}
			}
			this.itemid = input.readInt();
			this.rest = input.readInt();
		}
	}
}

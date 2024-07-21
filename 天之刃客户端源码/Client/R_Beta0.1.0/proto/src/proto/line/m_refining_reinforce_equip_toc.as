package proto.line {
	import proto.common.p_goods;
	import proto.common.p_goods;
	import proto.common.p_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_refining_reinforce_equip_toc extends Message
	{
		public var succ:Boolean = true;
		public var equip:p_goods = null;
		public var stuff:p_goods = null;
		public var protect:p_goods = null;
		public var prompt:String = "";
		public function m_refining_reinforce_equip_toc() {
			super();
			this.equip = new p_goods;
			this.stuff = new p_goods;
			this.protect = new p_goods;

			flash.net.registerClassAlias("copy.proto.line.m_refining_reinforce_equip_toc", m_refining_reinforce_equip_toc);
		}
		public override function getMethodName():String {
			return 'refining_reinforce_equip';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			var tmp_equip:ByteArray = new ByteArray;
			this.equip.writeToDataOutput(tmp_equip);
			var size_tmp_equip:int = tmp_equip.length;
			output.writeInt(size_tmp_equip);
			output.writeBytes(tmp_equip);
			var tmp_stuff:ByteArray = new ByteArray;
			this.stuff.writeToDataOutput(tmp_stuff);
			var size_tmp_stuff:int = tmp_stuff.length;
			output.writeInt(size_tmp_stuff);
			output.writeBytes(tmp_stuff);
			var tmp_protect:ByteArray = new ByteArray;
			this.protect.writeToDataOutput(tmp_protect);
			var size_tmp_protect:int = tmp_protect.length;
			output.writeInt(size_tmp_protect);
			output.writeBytes(tmp_protect);
			if (this.prompt != null) {				output.writeUTF(this.prompt.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			var byte_equip_size:int = input.readInt();
			if (byte_equip_size > 0) {				this.equip = new p_goods;
				var byte_equip:ByteArray = new ByteArray;
				input.readBytes(byte_equip, 0, byte_equip_size);
				this.equip.readFromDataOutput(byte_equip);
			}
			var byte_stuff_size:int = input.readInt();
			if (byte_stuff_size > 0) {				this.stuff = new p_goods;
				var byte_stuff:ByteArray = new ByteArray;
				input.readBytes(byte_stuff, 0, byte_stuff_size);
				this.stuff.readFromDataOutput(byte_stuff);
			}
			var byte_protect_size:int = input.readInt();
			if (byte_protect_size > 0) {				this.protect = new p_goods;
				var byte_protect:ByteArray = new ByteArray;
				input.readBytes(byte_protect, 0, byte_protect_size);
				this.protect.readFromDataOutput(byte_protect);
			}
			this.prompt = input.readUTF();
		}
	}
}

package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_add_energy_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var gold:int = 0;
		public var gold_bind:int = 0;
		public var energy:int = 0;
		public var energy_remain:int = 0;
		public function m_role2_add_energy_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_role2_add_energy_toc", m_role2_add_energy_toc);
		}
		public override function getMethodName():String {
			return 'role2_add_energy';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.gold);
			output.writeInt(this.gold_bind);
			output.writeInt(this.energy);
			output.writeInt(this.energy_remain);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.gold = input.readInt();
			this.gold_bind = input.readInt();
			this.energy = input.readInt();
			this.energy_remain = input.readInt();
		}
	}
}

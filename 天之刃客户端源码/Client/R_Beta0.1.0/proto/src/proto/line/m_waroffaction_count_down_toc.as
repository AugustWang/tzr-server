package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_waroffaction_count_down_toc extends Message
	{
		public var attack_faction_id:int = 0;
		public var defence_faction_id:int = 0;
		public var type:int = 0;
		public var tick:int = 0;
		public var current_target:String = "";
		public function m_waroffaction_count_down_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_waroffaction_count_down_toc", m_waroffaction_count_down_toc);
		}
		public override function getMethodName():String {
			return 'waroffaction_count_down';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.attack_faction_id);
			output.writeInt(this.defence_faction_id);
			output.writeInt(this.type);
			output.writeInt(this.tick);
			if (this.current_target != null) {				output.writeUTF(this.current_target.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.attack_faction_id = input.readInt();
			this.defence_faction_id = input.readInt();
			this.type = input.readInt();
			this.tick = input.readInt();
			this.current_target = input.readUTF();
		}
	}
}

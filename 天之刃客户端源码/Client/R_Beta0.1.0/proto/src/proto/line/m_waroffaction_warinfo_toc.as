package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_waroffaction_warinfo_toc extends Message
	{
		public var faction_id:int = 0;
		public var dest_faction_id:int = 0;
		public var next_war_tick:int = 0;
		public var is_attack_faction:Boolean = true;
		public var declare_war1:Boolean = true;
		public var declare_war2:Boolean = true;
		public var silver:int = 0;
		public var max_guarder_level:int = 0;
		public var left_guarder_level:int = 0;
		public var right_guarder_level:int = 0;
		public var road_block:int = 0;
		public function m_waroffaction_warinfo_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_waroffaction_warinfo_toc", m_waroffaction_warinfo_toc);
		}
		public override function getMethodName():String {
			return 'waroffaction_warinfo';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.faction_id);
			output.writeInt(this.dest_faction_id);
			output.writeInt(this.next_war_tick);
			output.writeBoolean(this.is_attack_faction);
			output.writeBoolean(this.declare_war1);
			output.writeBoolean(this.declare_war2);
			output.writeInt(this.silver);
			output.writeInt(this.max_guarder_level);
			output.writeInt(this.left_guarder_level);
			output.writeInt(this.right_guarder_level);
			output.writeInt(this.road_block);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.faction_id = input.readInt();
			this.dest_faction_id = input.readInt();
			this.next_war_tick = input.readInt();
			this.is_attack_faction = input.readBoolean();
			this.declare_war1 = input.readBoolean();
			this.declare_war2 = input.readBoolean();
			this.silver = input.readInt();
			this.max_guarder_level = input.readInt();
			this.left_guarder_level = input.readInt();
			this.right_guarder_level = input.readInt();
			this.road_block = input.readInt();
		}
	}
}

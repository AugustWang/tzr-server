package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_property_add extends Message
	{
		public var power:int = 0;
		public var agile:int = 0;
		public var brain:int = 0;
		public var vitality:int = 0;
		public var spirit:int = 0;
		public var min_physic_att:int = 0;
		public var max_physic_att:int = 0;
		public var min_magic_att:int = 0;
		public var max_magic_att:int = 0;
		public var physic_def:int = 0;
		public var magic_def:int = 0;
		public var blood:int = 0;
		public var magic:int = 0;
		public var physic_att_rate:int = 0;
		public var magic_att_rate:int = 0;
		public var physic_def_rate:int = 0;
		public var magic_def_rate:int = 0;
		public var blood_rate:int = 0;
		public var magic_rate:int = 0;
		public var blood_resume_speed:int = 0;
		public var magic_resume_speed:int = 0;
		public var dead_attack:int = 0;
		public var lucky:int = 0;
		public var move_speed:int = 0;
		public var attack_speed:int = 0;
		public var dodge:int = 0;
		public var no_defence:int = 0;
		public var main_property:int = 0;
		public var dizzy:int = 0;
		public var poisoning:int = 0;
		public var freeze:int = 0;
		public var hurt:int = 0;
		public var hurt_shift:int = 0;
		public var poisoning_resist:int = 0;
		public var dizzy_resist:int = 0;
		public var freeze_resist:int = 0;
		public var phy_anti:int = 0;
		public var magic_anti:int = 0;
		public var hurt_rebound:int = 0;
		public function p_property_add() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_property_add", p_property_add);
		}
		public override function getMethodName():String {
			return 'property';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.power);
			output.writeInt(this.agile);
			output.writeInt(this.brain);
			output.writeInt(this.vitality);
			output.writeInt(this.spirit);
			output.writeInt(this.min_physic_att);
			output.writeInt(this.max_physic_att);
			output.writeInt(this.min_magic_att);
			output.writeInt(this.max_magic_att);
			output.writeInt(this.physic_def);
			output.writeInt(this.magic_def);
			output.writeInt(this.blood);
			output.writeInt(this.magic);
			output.writeInt(this.physic_att_rate);
			output.writeInt(this.magic_att_rate);
			output.writeInt(this.physic_def_rate);
			output.writeInt(this.magic_def_rate);
			output.writeInt(this.blood_rate);
			output.writeInt(this.magic_rate);
			output.writeInt(this.blood_resume_speed);
			output.writeInt(this.magic_resume_speed);
			output.writeInt(this.dead_attack);
			output.writeInt(this.lucky);
			output.writeInt(this.move_speed);
			output.writeInt(this.attack_speed);
			output.writeInt(this.dodge);
			output.writeInt(this.no_defence);
			output.writeInt(this.main_property);
			output.writeInt(this.dizzy);
			output.writeInt(this.poisoning);
			output.writeInt(this.freeze);
			output.writeInt(this.hurt);
			output.writeInt(this.hurt_shift);
			output.writeInt(this.poisoning_resist);
			output.writeInt(this.dizzy_resist);
			output.writeInt(this.freeze_resist);
			output.writeInt(this.phy_anti);
			output.writeInt(this.magic_anti);
			output.writeInt(this.hurt_rebound);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.power = input.readInt();
			this.agile = input.readInt();
			this.brain = input.readInt();
			this.vitality = input.readInt();
			this.spirit = input.readInt();
			this.min_physic_att = input.readInt();
			this.max_physic_att = input.readInt();
			this.min_magic_att = input.readInt();
			this.max_magic_att = input.readInt();
			this.physic_def = input.readInt();
			this.magic_def = input.readInt();
			this.blood = input.readInt();
			this.magic = input.readInt();
			this.physic_att_rate = input.readInt();
			this.magic_att_rate = input.readInt();
			this.physic_def_rate = input.readInt();
			this.magic_def_rate = input.readInt();
			this.blood_rate = input.readInt();
			this.magic_rate = input.readInt();
			this.blood_resume_speed = input.readInt();
			this.magic_resume_speed = input.readInt();
			this.dead_attack = input.readInt();
			this.lucky = input.readInt();
			this.move_speed = input.readInt();
			this.attack_speed = input.readInt();
			this.dodge = input.readInt();
			this.no_defence = input.readInt();
			this.main_property = input.readInt();
			this.dizzy = input.readInt();
			this.poisoning = input.readInt();
			this.freeze = input.readInt();
			this.hurt = input.readInt();
			this.hurt_shift = input.readInt();
			this.poisoning_resist = input.readInt();
			this.dizzy_resist = input.readInt();
			this.freeze_resist = input.readInt();
			this.phy_anti = input.readInt();
			this.magic_anti = input.readInt();
			this.hurt_rebound = input.readInt();
		}
	}
}

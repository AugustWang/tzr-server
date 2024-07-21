package proto.line {
	import proto.line.p_mission_reward_data;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_mission_do_toc extends Message
	{
		public var id:int = 0;
		public var current_status:int = 0;
		public var pre_status:int = 0;
		public var current_model_status:int = 0;
		public var pre_model_status:int = 0;
		public var reward_data:p_mission_reward_data = null;
		public var code:int = 0;
		public var code_data:Array = new Array;
		public function m_mission_do_toc() {
			super();
			this.reward_data = new p_mission_reward_data;

			flash.net.registerClassAlias("copy.proto.line.m_mission_do_toc", m_mission_do_toc);
		}
		public override function getMethodName():String {
			return 'mission_do';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			output.writeInt(this.current_status);
			output.writeInt(this.pre_status);
			output.writeInt(this.current_model_status);
			output.writeInt(this.pre_model_status);
			var tmp_reward_data:ByteArray = new ByteArray;
			this.reward_data.writeToDataOutput(tmp_reward_data);
			var size_tmp_reward_data:int = tmp_reward_data.length;
			output.writeInt(size_tmp_reward_data);
			output.writeBytes(tmp_reward_data);
			output.writeInt(this.code);
			var size_code_data:int = this.code_data.length;
			output.writeShort(size_code_data);
			var temp_repeated_byte_code_data:ByteArray= new ByteArray;
			for(i=0; i<size_code_data; i++) {
				temp_repeated_byte_code_data.writeInt(this.code_data[i]);
			}
			output.writeInt(temp_repeated_byte_code_data.length);
			output.writeBytes(temp_repeated_byte_code_data);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.current_status = input.readInt();
			this.pre_status = input.readInt();
			this.current_model_status = input.readInt();
			this.pre_model_status = input.readInt();
			var byte_reward_data_size:int = input.readInt();
			if (byte_reward_data_size > 0) {				this.reward_data = new p_mission_reward_data;
				var byte_reward_data:ByteArray = new ByteArray;
				input.readBytes(byte_reward_data, 0, byte_reward_data_size);
				this.reward_data.readFromDataOutput(byte_reward_data);
			}
			this.code = input.readInt();
			var size_code_data:int = input.readShort();
			var length_code_data:int = input.readInt();
			var byte_code_data:ByteArray = new ByteArray; 
			if (size_code_data > 0) {
				input.readBytes(byte_code_data, 0, size_code_data * 4);
				for(i=0; i<size_code_data; i++) {
					var tmp_code_data:int = byte_code_data.readInt();
					this.code_data.push(tmp_code_data);
				}
			}
		}
	}
}

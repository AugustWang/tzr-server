package com.net.connection {
	import com.Message;
	import com.components.alert.Alert;
	import com.globals.GameParameters;
	import com.managers.Dispatch;
	import com.net.event.ConnectionEvent;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.ObjectEncoding;
	import flash.net.Socket;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	import modules.system.SystemModule;

	/**
	 * Socket 连接类
	 * @author Huyongbo
	 *
	 */
	public class Connection extends Socket {
		/**
		 * 当前连接所有状态
		 */
		public static const CONNECTED:int = 0; //连接成功
		public static const CONNECTING:int = 1; //正在连接
		public static const CLOSE:int = 2; //关闭连接
		
		/**
		 * 基本属性
		 */
		public var host:String;
		public var port:int;
		
		private var id:int=0x7000;
		private var listeners:Dictionary;

		public function Connection() {
			//监听器
			listeners=new Dictionary();
			
			objectEncoding=ObjectEncoding.AMF3;
			timeout=5000;
			addEventListener(Event.CLOSE, closeHandler);
			addEventListener(Event.CONNECT, connectHandler);
			addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
			state=CLOSE;
		}
		
		private static var instance:Connection;
		
		public static function getInstance():Connection {
			if (instance == null) {
				instance=new Connection();
			}
			return instance;
		}
		
		public override function close():void
		{
			if (this.connected) {
				this.close();
			}
		}
		
		/**
		 * 注册消息处理函数
		 */
		public function addSocketListener(command:String, handler:Function):void {
			var handlers:Array=listeners[command];
			if (handlers == null) {
				handlers=[];
				listeners[command]=handlers;
			} else {
				if (handlers.indexOf(handler) != -1) {
					return;
				}
			}
			handlers.push(handler);
		}
		
		/**
		 * 删除消息处理监听
		 */
		public function removeSocketListener(command:String, handler:Function):void {
			var handlers:Array=listeners[command];
			if (handlers) {
				var index:int=handlers.indexOf(handler);
				if (index != -1) {
					handlers.splice(index, 1);
				}
			}
		}
		
		/**
		 * 发送消息
		 */
		
		public function sendMessage(message:Message):void {
			var methodName:String=message.getMethodName();
			var desc:Object=ServerMapConfig.getMethodByName(methodName.toUpperCase());
			if (state == CONNECTED) {
				send(getMessageId(), desc.moduleId, desc.id, message);
			} else {
				SystemModule.getInstance().showSocketClosedWindow();
			}
		}
		
		/**
		 * 获取消息ID
		 */
		private function getMessageId():int {
			return id=id <= 0 ? 0x7000 : id--;
		}
		
		public function resultHandler(command:String, vo:Message):void {
			var m:String=command.split("_")[0];
			var handlers:Array=listeners[command];
			for each (var call:Function in handlers) {
				call.apply(null, [vo]);
			}
		}

		public function startConnect():void {
			try {
				if (state != CONNECTED && state != CONNECTING) {
					connect(host, port);
					state=CONNECTING;
				}
			} catch (error:*) {
				throw new Error("连接" + host + "服务器时发生异常!");
			}
		}

		public function disconnect():void {
			if (state == CONNECTED || state == CONNECTING) {
				close();
				closeHandler(null);
			}
		}

		private function send(id:int, moduleId:int, methodId:int, message:Message):void {
			var body:ByteArray=new ByteArray;
			var packetHeader:int;
			var dataByte:ByteArray=new ByteArray();
			if (message != null) {
				dataByte.position=0;
				message.writeToDataOutput(dataByte);
				if (dataByte.length > 20) {
					dataByte.compress();
					id=id | 0x8000;
				}
			}
			body.writeShort(id);
			body.writeByte(moduleId);
			body.writeShort(methodId);
			if (message != null) {
				body.writeBytes(dataByte);
			}
			packetHeader=body.length;
			var packet:ByteArray = new ByteArray();
			writeInt(packetHeader);
			writeBytes(body);
			flush();
		}

		private function starthandclasp():void {
			var ba:ByteArray=new ByteArray;
			ba.length=23;
			writeShort(23);
			writeBytes(ba);
			flush();
		}

		private var _state:int;

		public function set state(value:int):void {
			if (value != _state) {
				_state=value;
			}
		}

		public function get state():int {
			return _state;
		}

		private function closeHandler(event:Event):void {
			state=CLOSE;
			dispatchEvent(new ConnectionEvent(ConnectionEvent.CLOSE));
			SystemModule.getInstance().onServerClosed();
		}

		private function connectHandler(event:Event):void {
			state=CONNECTED;
			starthandclasp();
			dispatchEvent(new ConnectionEvent(ConnectionEvent.SUCCESS));
		}

		private function ioErrorHandler(event:Event):void {
			state=CLOSE;
			dispatchEvent(new ConnectionEvent(ConnectionEvent.IO_ERROR));
		}

		private function securityErrorHandler(event:Event):void {
			state=CLOSE;
			dispatchEvent(new ConnectionEvent(ConnectionEvent.SECURITY_ERROR));
		}

		private var hasReadHead:Boolean = false;
		private var _unParseData:ByteArray = new ByteArray();
		private var _hasUnParseData:Boolean = false;
		
		private function socketDataHandler(event:Event):void {
			try {
				var data:ByteArray = new ByteArray();
				if (bytesAvailable > 0) {
					this.readBytes(data, 0, this.bytesAvailable);
				}
				var totalData:ByteArray = new ByteArray();
				if (this._hasUnParseData) {
					this._unParseData.position=0;
					//拼凑上一次的数据
					totalData.writeBytes(this._unParseData, 0, this._unParseData.bytesAvailable);
					//清理未处理内容标志
					this._unParseData.length=0;
					this._hasUnParseData=false;
				}
				totalData.writeBytes(data, 0, data.bytesAvailable);
				data = null;
				totalData.position=0;
				
				while (totalData.bytesAvailable >= 9) {
					//读取长度
					var len:int = new int;
					len=totalData.readInt();
					//判断数据是否足够
					if (totalData.bytesAvailable < len) {
						totalData.position=totalData.position - 4;
						break;
					} else {
						var tmpArray:ByteArray = new ByteArray;
						var id:int=totalData.readUnsignedShort();
						var moduleId:int=totalData.readUnsignedByte();
						var methodId:int=totalData.readUnsignedShort();
						var is_zip:Boolean=(id & 0x8000) == 0x8000;
						id=id & 0x7fff;
						
						tmpArray.position=0;
						//排除服务端返回没值的vo长度为5的空包
						if (len > 5) {
							totalData.readBytes(tmpArray, 0, len - 5);
						}
						if (is_zip) {
							tmpArray.uncompress();
						}
						decodeData(tmpArray, id, moduleId, methodId);
					}
				}
				totalData.readBytes(_unParseData, 0, totalData.bytesAvailable);
				totalData = null;
				this._hasUnParseData=true;
			} catch (e:Error) {
				SystemModule.getInstance().postError(e, "socket read");
				Alert.show("系统检查到网络发生错误，需要刷新", "警告", refreshGame, null, "重新进入游戏", null, null, false);
			}
		}
		
		private function refreshGame():void {
			flash.net.navigateToURL(new URLRequest(GameParameters.getInstance().serviceHost + "game.php"), "_self");
		}

		private function decodeData(tmpByte:ByteArray, id:int, moduleId:int, methodId:int):void {
			var desc:Object = ServerMapConfig.getMethodById(methodId);
			var classpackage:String="proto." + desc.packageName + "::m_" + desc.name.toLowerCase() + "_toc";
			var VoClass:Class;
			var vo:Message;
			if (GameParameters.getInstance().isDebug()) {
				VoClass=getDefinitionByName(classpackage) as Class;
				vo=new VoClass();
				tmpByte.position=0;
				vo.readFromDataOutput(tmpByte);
				resultHandler(desc.name, vo);
			} else {
				try {
					VoClass=getDefinitionByName(classpackage) as Class;
					vo=new VoClass();
					tmpByte.position=0;
					vo.readFromDataOutput(tmpByte);
					resultHandler(desc.name, vo);
				} catch (e:Error) {
					if (e.errorID == 1065) {
						SystemModule.getInstance().postError(e, "cannot found vo:" + classpackage);
					} else {
						SystemModule.getInstance().postError(e, "packet decode");
					}
				}
			}
		}
	}
}
package com.loaders.gameLoader {
	import com.loaders.ResourcePool;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import modules.system.SystemModule;
	
	/**
	 * 游戏资源加载器（负责加载NPC，任务，怪物，技能，地图）
	 * @author Administrator
	 *
	 */
	public class GameLoader extends EventDispatcher {
		public static var MAX_LOADER_COUNT:int=12; //总共的urlLoader数量，即同时最多可以LOAD多少个资源
		
		private var urlLoaders:Array; //放urlLoader的数组
		private var sources:Array; //NPC，怪物，技能加载队列
		private var maps:Array; //地图加载队列
		private var loadingLoader:Dictionary; //正在加载的URLLOADER,KET为urlLoader，值为ResourceItem
		private var registerDic:Dictionary; //标志是否注册某资源的加载，KEY为url
		
		public var isLoading:Boolean;
		public var decoder:Decoder;
		
		public function GameLoader() {
			urlLoaders = new Array();
			sources = new Array();
			maps = new Array();
			loadingLoader=new Dictionary();
			registerDic=new Dictionary();
			decoder = new Decoder();
			decoder.contentLoaderInfo.addEventListener(Event.COMPLETE, decoderComplete);
			decoder.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, decoderError);
			while (urlLoaders.length < MAX_LOADER_COUNT) {
				var loader:URLStream=new URLStream();
				loader.addEventListener(Event.COMPLETE, completeHandler);
				loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				urlLoaders.push(loader);
			}
		}
		
		private static var instance:GameLoader;
		public static function getInstance():GameLoader {
			if (instance == null) {
				instance=new GameLoader();
			}
			return instance;
		}
		
		//加载NPC，怪物，技能等
		public function add(url:String, priority:int=1, data:Object=null, handler:Function=null):void {
			if (!ResourcePool.hasResource(url) && !registerDic[url]) {
				var item:ResourceItem=new ResourceItem();
				item.url=url;
				item.data=data;
				item.priority=priority;
				item.handler=handler;
				addItem(item);
				load();
			}
		}
		
		private function addItem(item:ResourceItem):void {
			registerDic[item.url]=true;
			sources.push(item);
			sources.sortOn("priority", Array.NUMERIC);
		}
		
		//加载地图切片
		public function addMap(url:String, data:Object=null, handler:Function=null):void {
			if (!registerDic[url]) {
				registerDic[url]=true;
				var item:ResourceItem=new ResourceItem();
				item.url=url;
				item.data=data;
				item.handler=handler;
				item.sourceType=ResourceItem.MAP;
				maps.unshift(item);
				load();
			}
		}
		
		private function getLoader():URLStream {
			if (urlLoaders && urlLoaders.length > 0) {
				return urlLoaders.shift();
			}
			return null;
		}
		
		private function load():void {
			var item:ResourceItem;
			var array:Array;
			if (maps.length > 0) {
				item=maps[0];
				array=maps;
			} else if (sources.length > 0) {
				item=sources[0];
				array=sources;
			}
			if (item) {
				var loader:URLStream=getLoader();
				if (loader) {
					if (item.type == ResourceItem.SWF || item.type == ResourceItem.IMAGE) {
						array.shift();
						loader.load(new URLRequest(item.url));
						loadingLoader[loader]=item;
						load();
						isLoading=true;
					} else if (item.type == ResourceItem.FILE) {
						array.shift();
						loader.load(new URLRequest(item.url));
						loadingLoader[loader]=item;
						load();
						isLoading=true;
					}
				}
			} else {
				isLoading=false;
			}
		}
		
		private function completeHandler(event:Event):void {
			var loader:URLStream=URLStream(event.currentTarget);
			var item:ResourceItem=loadingLoader[loader];
			delete loadingLoader[loader];
			urlLoaders.push(loader);
			if (item) {
				var bytes:ByteArray = new ByteArray();
				loader.readBytes(bytes,0,loader.bytesAvailable);
				item.content=bytes;
				delete registerDic[item.url];
				if (item.type == ResourceItem.SWF || item.type == ResourceItem.IMAGE) {
					decoder.add(item);
				} else if (item.type == ResourceItem.FILE) {
					ResourcePool.add(item.url, bytes);
					dispatchEvent(new GameLoaderEvent(GameLoaderEvent.COMPLETE, item.url, item.data));
				}
			}
			load();
		}
		
		
		private function decoderComplete(e:Event):void {
			try {
				var decoder:Decoder=e.target.loader as Decoder;
				var item:ResourceItem=decoder.info;
				if (item.sourceType != ResourceItem.MAP) {
					ResourcePool.add(item.url, decoder.content);
				}
				if (item.handler != null && item.sourceType == ResourceItem.MAP) {
					item.handler.call(null, decoder, item.data);
				} else if (item.handler != null) {
					item.handler.call(null, decoder, item.url);
				} else {
					dispatchEvent(new GameLoaderEvent(GameLoaderEvent.COMPLETE, item.url, item.data));
				}
			} catch (e:Error) {
				SystemModule.getInstance().postError(e, "加载的资源：" + item.url + "导致出错");
			}
			decoder.dispose();
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void {
			var loader:URLStream=URLStream(event.currentTarget);
			var item:ResourceItem=loadingLoader[loader];
			delete loadingLoader[loader];
			delete registerDic[item.url];
			urlLoaders.push(loader);
			//加载重试一次
			if (item.reload == false) {
				item.reload=true;
				if (item.sourceType == ResourceItem.MAP) {
					registerDic[item.url]=true;
					maps.unshift(item);
					load();
				} else {
					addItem(item);
					load();
				}
			}
		}
		
		private function decoderError(e:IOErrorEvent):void {
			trace("LOADER加载内存二进制出错");
			decoder.dispose();
		}
		
		public function clearAll():void {
			for (var loader:Object in loadingLoader) {
				unLoadLoader(loader as URLStream);
			}
			loadingLoader=new Dictionary;
			registerDic=new Dictionary();
			sources=[];
			maps=[];
			try {
				decoder.close();
			} catch (e:Error) {
			}
			decoder.isDecoding=false;
			decoder.decodelist.length=0;
		}
		
		public function clearLoadingMap():void{
			var item:ResourceItem;
			for each(item in loadingLoader) {
				if(item.sourceType == ResourceItem.MAP){
					delete registerDic[item.url];
					delete loadingLoader[item];
					unLoadLoader(loadingLoader[item] as URLStream);
				}
			}
			for each(item in maps){
				delete registerDic[item.url];
			}
			maps = [];
			try{
				if(decoder.info && decoder.info.sourceType == ResourceItem.MAP){
					decoder.close();
					decoder.dispose();
				}
			}catch(e:*){
				decoder.dispose();
			}
			for(var i:int=0;i<decoder.decodelist.length;i++){
				item = decoder.decodelist[i];
				if(item.sourceType == ResourceItem.MAP){
					delete registerDic[item.url];
					decoder.decodelist.splice(i,1);
					i--
				}
			}
		}
		
		private function unLoadLoader(loader:URLStream):void {
			try {
				urlLoaders.push(loader);
				loader.close();
			} catch (e:*) {
				//这里不要加代码，因为正在LOAD的loader执行close必然抛异常,不影响close的执行
			}
		}
	}
}


import com.loaders.gameLoader.ResourceItem;

import flash.display.Loader;
import flash.utils.ByteArray;

class Decoder extends Loader {
	public var decodelist:Array=[];
	public var isDecoding:Boolean;
	public var info:ResourceItem;
	
	public function add(info:ResourceItem):void {
		decodelist.push(info);
		start();
	}
	
	private function start():void {
		if (isDecoding == true || decodelist.length == 0) {
			return;
		}
		try {
			info=decodelist.shift();
			loadBytes(info.content);
			isDecoding=true;
		} catch (e:Error) {
			isDecoding=false;
		}
	}
	
	public function dispose():void {
		isDecoding=false;
		start();
	}
}
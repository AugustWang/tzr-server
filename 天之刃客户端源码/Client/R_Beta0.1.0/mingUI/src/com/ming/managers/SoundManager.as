package com.ming.managers
{
	import com.ming.errors.IllegalArgumentError;
	import com.ming.events.SoundEvent;
	
	import flash.display.Sprite;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;

	/**
	 * 声音管理器 
	 * @author Administrator
	 * 
	 */
	public class SoundManager extends EventDispatcher
	{
		private var scene:Sprite; //场景层
		private var soundDic:Dictionary; //缓存音效
		private var soundChannel:SoundChannel; //音频
		private var sceneSound:Sound; //场景声音播放
		private var lastMusicUrl:String;
		public var isPlaying:Boolean = false;
		public var isLoading:Boolean = false;
		private static var instance:SoundManager;
		
		public function SoundManager(){
			init();
		}
		
		public static function getInstance():SoundManager{
			if(instance == null){
				instance = new SoundManager();
			}
			return instance;
		}				
		/**
		 * 注册场景 
		 * @param scene
		 * 
		 */		
		public static function registerScene(scene:Sprite):void{
			if(scene == null){
				throw new IllegalArgumentError("非法参数 SoundManager的scene不能设置为null");
			}
			getInstance().scene = scene;
		}
		/**
		 * 初始化 
		 * 
		 */		
		private function init():void{
			soundDic = new Dictionary();	
		}
		/**
		 * 设置背景声音大小 
		 */		
		private var _sceneVolume:Number=0.5;
		public function get sceneVolume():Number{
			return _sceneVolume;
		}
		public function set sceneVolume(value:Number):void
		{
			_sceneVolume = value;
			setSceneVolume(_sceneVolume);
		}
		/**
		 * 设置效果声音大小 
		 */		
		private var _soundVolume:Number=0.5;
		public function get soundVolume():Number{
			return _soundVolume;
		}
		public function set soundVolume(value:Number):void
		{
			_soundVolume = value;
		}		
		/**
		 * 设置获取音效的函数库。例如刀剑声音效果 
		 */		
		private var _soundLibraryFunc:Function;
		public function set soundLibraryFunc(func:Function):void{
			_soundLibraryFunc = func;
		}
		public function get soundLibraryFunc():Function{
			return _soundLibraryFunc;
		}
		/**
		 * 播放背景音乐 
		 * @param url
		 * 
		 */		
		public function playMusic(url:String):void
		{
			if(url != lastMusicUrl){
				if(sceneSound){
					try{
						sceneSound.removeEventListener(Event.COMPLETE,onLoadComplete);
						sceneSound.removeEventListener(IOErrorEvent.IO_ERROR,onIOError);
						sceneSound.close();
					}catch(e:*){}
				}
				if(soundChannel){
					soundChannel.stop();
				}
				var sound:Sound = soundDic[url]; 
				if(sound){
					sceneSound = sound;
					startPlay();
				}else{
					sceneSound = new Sound();
					sceneSound.load(new URLRequest(url));
					sceneSound.addEventListener(Event.COMPLETE,onLoadComplete);
					sceneSound.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
					lastMusicUrl = url;
					isLoading = true;
				}
			}else if(isPlaying == false){
				startPlay();
			}
		}
		
		private function onLoadComplete(event:Event):void{
			if(soundChannel){
				soundChannel.removeEventListener(Event.SOUND_COMPLETE,onSoundComplete);
			}
			soundDic[sceneSound.url] = sceneSound;
			startPlay();
		}
		
		private function startPlay():void{
			if(sceneSound){
				if (soundChannel != null) {
					soundChannel.stop();
				}
				soundChannel = sceneSound.play(0,0, new SoundTransform(sceneVolume));
				if (soundChannel != null) {
					soundChannel.addEventListener(Event.SOUND_COMPLETE,onSoundComplete);
					isPlaying = true;
					isLoading = false;
					dispatchEvent(new SoundEvent(SoundEvent.START_PLAY));
				}
			}
		}
		
		private function onSoundComplete(event:Event):void{
			isPlaying = false;
			dispatchEvent(new SoundEvent(SoundEvent.PLAY_COMPLETE));
		}
		
		private function onIOError(event:IOErrorEvent):void{
			lastMusicUrl = "";
			isLoading = false;
		}
		
		/**
		 * 停止背景音乐 
		 * @param type
		 * 
		 */		
		public function stopMusic():void{
			if(isLoading && sceneSound){
				try{
					sceneSound.removeEventListener(Event.COMPLETE,onLoadComplete);
					sceneSound.removeEventListener(IOErrorEvent.IO_ERROR,onIOError);
					sceneSound.close();
					sceneSound = null;
				}catch(e:*){}
			}
			if(soundChannel){
				soundChannel.stop();
			}
			isPlaying = false;
		}
		/**
		 * 暂停背景音乐 
		 * 
		 */		
		private var playTime:Number;
		public function pauseMusic():void{
			setSceneVolume(0);
			if(soundChannel){
				playTime = soundChannel.position;
				soundChannel.stop();
				isPlaying = false;
			}
		}		
		/**
		 * 播放音效 
		 * @param type
		 * 
		 */		
		public function playSound(type:String):void
		{
			if(_soundVolume == 0) return;
			var sound:Sound = soundDic[type];
			if(sound == null){
				sound = soundLibraryFunc(type) as Sound;
				if(sound == null){
					return;
				}
				soundDic[type] = sound;				
			}
			sound.play(0, 0, new SoundTransform(soundVolume));
		}
		/**
		 * 删除音效缓存 
		 * @param type
		 * 
		 */		
		public function removeSound(type:String):void{
			var sound:Sound = soundDic[type];
			if(sound){
				try{
					sound.close()
				}catch(e:IOError){
				
				}
				sound = null;
				soundDic[type] = null;
			}
		}
		/**
		 * 设置场景音乐 
		 * @param vol
		 * 
		 */		
		private function setSceneVolume(vol:Number):void
		{
			var soundTransform:SoundTransform = new SoundTransform(vol);
			scene.soundTransform = soundTransform;
			if(soundChannel){	
				soundChannel.soundTransform = soundTransform;
			}
		}
		
	}
}
package com.managers {
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.loaders.ResourcePool;
	import com.ming.events.SoundEvent;
	import com.ming.managers.SoundManager;
	import com.scene.WorldManager;
	import com.scene.sceneData.CityVo;
	
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.utils.Timer;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import modules.scene.SceneDataManager;
	import modules.system.SystemConfig;
	
	public class MusicManager {
		/**
		 * 音效常量列表
		 */
		public static const WINDOWOPEN:String="s_tabbar"; //打开窗口
		public static const TABBAR:String="s_tabbar"; //选项卡
		public static const BUTTON:String="s_button"; //按钮
		public static const CHANGEEQUIP:String="s_changeEquip"; //换装备
		public static const NEWMESSAGE:String="s_newMessage"; //新消息
		public static const SELLGOODS:String="s_sellGoods"; //卖出东西
		public static const ALERT:String="s_alert"; //弹出窗口
		public static const DISPOSE:String="s_dispose"; //销毁物品
		public static const DAO:String="s_dao"; //刀砍
		public static const DIE:String="s_die"; //刀砍
		/**
		 * 当前音乐路径
		 */
		public static var url:String;
		
		private static var volume:Number=0;
		private static var volumeTimer:Timer;
		private static var isFade:Boolean=false;
		
		private static var interval:int;
		
		public static function init():void {
			SoundManager.registerScene(LayerManager.main);
			SoundManager.getInstance().soundLibraryFunc=getSound;
			SoundManager.getInstance().addEventListener(SoundEvent.START_PLAY, onStartPlay);
			SoundManager.getInstance().addEventListener(SoundEvent.PLAY_COMPLETE, onPlayComplete);
			volumeTimer=new Timer(100);
			volumeTimer.addEventListener(TimerEvent.TIMER, onTimer);
			volumeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
		}
		
		/**
		 * 播放场景音乐
		 */
		public static function play(_url:String=""):void {
			if (_url == "") {
				var faction:int=GlobalObjectManager.getInstance().user.base.faction_id;
				if (!SceneDataManager.mapData) {
					return;
				}
				var vo:CityVo=WorldManager.getCityVo(SceneDataManager.mapData.map_id);
				_url=GameConfig.ROOT_URL + vo.music; //当前场景音乐
			}
			var count:int=0;
			if (SystemConfig.openBackSound && _url != "") {
				if (SoundManager.getInstance().isPlaying && _url != url) {
					count=SoundManager.getInstance().sceneVolume * 100;
					if (count != 0) {
						volumeTimer.reset();
						isFade=false;
						volumeTimer.repeatCount=SoundManager.getInstance().sceneVolume * 100;
						volumeTimer.start();
					}
				} else {
					clearTimeout(interval);
					if (url != _url) {
						if (SceneDataManager.mapData.map_id != int("1" + faction + "000")) { //暂时屏蔽新手村
							SoundManager.getInstance().playMusic(_url);
						}
						url=_url;
					} else {
						if (volumeTimer.running && !isFade) {
							count=SystemConfig.sceneVolume - SoundManager.getInstance().sceneVolume * 100;
							if (count != 0) {
								volumeTimer.reset();
								isFade=true;
								volumeTimer.repeatCount=count;
								volumeTimer.start();
							}
						} else if (!SoundManager.getInstance().isPlaying && !SoundManager.getInstance().isLoading) {
							if (SceneDataManager.mapData.map_id != int("1" + faction + "000")) { //暂时屏蔽新手村
								SoundManager.getInstance().playMusic(url);
							}
						}
					}
				}
			}
		}
		
		private static function onTimer(event:TimerEvent):void {
			if (isFade == false) {
				SoundManager.getInstance().sceneVolume-=0.01;
			} else {
				SoundManager.getInstance().sceneVolume+=0.01;
			}
		}
		
		private static function onTimerComplete(event:TimerEvent):void {
			if (isFade == false) {
				SoundManager.getInstance().stopMusic();
				url="";
				play();
			} else {
				SoundManager.getInstance().sceneVolume=SystemConfig.sceneVolume / 100;
			}
		}
		
		private static function onStartPlay(event:SoundEvent):void {
			if (SystemConfig.sceneVolume != 0) {
				SoundManager.getInstance().sceneVolume=0;
				volumeTimer.reset();
				isFade=true;
				volumeTimer.repeatCount=SystemConfig.sceneVolume;
				volumeTimer.start();
			}
		}
		
		private static function onPlayComplete(event:SoundEvent):void {
			clearTimeout(interval);
			interval=setTimeout(play, 15000, url);
		}
		
		public static function stop():void {
			if (SystemConfig.openBackSound == false) {
				SoundManager.getInstance().sceneVolume=0;
				SoundManager.getInstance().stopMusic();
				url="";
				clearTimeout(interval);
				volumeTimer.stop();
			}
		}
		
		public static function playSound(type:String):void {
			if (SystemConfig.openGameSound) {
				SoundManager.getInstance().soundVolume=SystemConfig.gameVolume / 100
				SoundManager.getInstance().playSound(type);
			}
		}
		
		public static function getSound(type:String):Sound {
			if (ResourcePool.hasResource(GameConfig.SOUND_URL)) {
				try {
					var clazz:Class=ResourcePool.getClass(GameConfig.SOUND_URL, type);
					return new clazz();
				} catch (e:Error) {
					return null;
				}
			} else {
				//发起url loader请求
			}
			return null;
		}
	}
}
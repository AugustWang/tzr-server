package {
	import flash.display.Sprite;
	import flash.events.*;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.text.TextField;
	public class Bgm extends Sprite {
		private var txt:TextField=new TextField;
		private var _playPercent:Number;
		private var song:SoundChannel;
		private var soundFactory:Sound;
		private var vol:SoundTransform;
		private var ready:Boolean=false;
		private var big:Number=0.3;//声音大小
		public function Bgm(url:String,playPercent:Number) {
			_playPercent=playPercent;
			var request:URLRequest=new URLRequest(url);
			//addChild(txt);
			soundFactory=new Sound  ;
			soundFactory.addEventListener(Event.COMPLETE,completeHandler);
			soundFactory.addEventListener(ProgressEvent.PROGRESS,progressHandler);
			soundFactory.load(request);

		}

		private function completeHandler(e:Event):void {

		}

		private function progressHandler(e:ProgressEvent):void {
			var per:Number=(e.bytesLoaded / e.bytesTotal) * 100;
			if (ready == false) {
				if (per > _playPercent) {
					song=soundFactory.play(0,1500);
					var transform:SoundTransform =new SoundTransform;
					transform.volume=big;
					song.soundTransform=transform;
					ready=true;
				}
			}
			txt.text=per + "%";
		}
		public function setVolume(value:Number):void{
			var transform:SoundTransform =new SoundTransform;
			transform.volume=value;
			song.soundTransform=transform;
		}
		public function reVolume():void{
			var transform:SoundTransform =new SoundTransform;
			transform.volume=big;
			song.soundTransform=transform;
		}
	}
}
package {
	import com.freshplanet.ane.AirFacebook.Facebook;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.StatusEvent;
	
	import fl.controls.Button;
	import fl.controls.TextArea;

	public class FacebookConnect extends Sprite {
		private static const APP_ID:String = "xxxxxxxxxx";
		private static const PERMISSIONS:Array = ["email", "user_about_me", "user_birthday", "user_hometown", "user_website", "offline_access", "read_stream", "publish_stream", "read_friendlists"];
		
		private var _facebook:Facebook;
		public var loginBTN:Button;
		public var infoGRP:Button;
		public var infoTA:TextArea;
		
		public function FacebookConnect() {
			super();

			// support autoOrients
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			this.addEventListener(Event.ADDED_TO_STAGE, init);
			
			loginBTN = new Button();
			loginBTN.label = "login";
			loginBTN.x = 100;
			loginBTN.y = 100;
			
			addChild(loginBTN);
			
			infoGRP = new Button();
			infoGRP.label = "info";
			infoGRP.x = 300;
			infoGRP.y = 100;
			infoGRP.enabled = false;
			infoGRP.addEventListener(MouseEvent.CLICK, handler_infoBTNclick);
			addChild(infoGRP);
			
			infoTA = new TextArea();
			infoTA.x = 100;
			infoTA.y = 200;
			infoTA.width = 500;
			infoTA.height = 500;
			infoTA.editable = false;
			addChild(infoTA);
		}
		
		protected function init($evt:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			
			showInfo('facebook.isSupported:', Facebook.isSupported);
			if(Facebook.isSupported)
			{
				_facebook = Facebook.getInstance();
				_facebook.addEventListener(StatusEvent.STATUS, handler_status);
				_facebook.init(APP_ID);
				
				showInfo("isSeesionOpen:", _facebook.isSessionOpen);
				if(_facebook.isSessionOpen)
				{
					loginSuccess();
					_facebook.dialog("oauth", null, handler_dialog, true);
				}else{
					loginBTN.addEventListener(MouseEvent.CLICK, handler_loginBTNclick);
				}
			}
		}
		
		private function loginSuccess():void
		{
			//loginBTN.enabled = false;
			infoGRP.enabled = true;
			loginBTN.removeEventListener(MouseEvent.CLICK, handler_loginBTNclick);
			loginBTN.addEventListener(MouseEvent.CLICK, handler_logoutBTNclick);
			loginBTN.label = "logout";
		}
		
		private function logoutSuccess():void
		{
			loginBTN.removeEventListener(MouseEvent.CLICK, handler_logoutBTNclick);
			loginBTN.addEventListener(MouseEvent.CLICK, handler_loginBTNclick);
			loginBTN.label = "login";
			loginBTN.enabled = true;
			infoGRP.enabled = false;
		}
		
		protected function handler_infoBTNclick($evt:MouseEvent):void
		{
			//_facebook.requestWithGraphPath("/me", null, "GET", handler_requesetWithGraphPath);
			_facebook.requestWithGraphPath("/me/friends", null, "GET", handler_requesetWithGraphPath);
			
		}
		
		protected function handler_loginBTNclick($evt:MouseEvent):void
		{
			if(!_facebook.isSessionOpen)
			{
				_facebook.openSessionWithPermissions(PERMISSIONS, handler_openSessionWithPermissions);
				//_facebook.dialog("oauth", null, handler_dialog);
			}
			else
			{
				showInfo('isSessionOpen!');
			}
		}
		
		protected function handler_logoutBTNclick($evt:MouseEvent):void
		{
			_facebook.closeSessionAndClearTokenInformation();
			logoutSuccess();
		}
		
		protected function handler_status($evt:StatusEvent):void
		{
			showInfo("statusEvent,type:", $evt.type,",code:", $evt.code,",level:", $evt.level);
		}
		
		private function handler_openSessionWithPermissions($success:Boolean, $userCancelled:Boolean, $error:String = null):void
		{
			if($success)
			{
				loginSuccess();
			}
			showInfo("success:", $success, ",userCancelled:", $userCancelled, ",error:", $error);
		}
		
		private function handler_dialog($data:Object):void
		{
			showInfo('handler_dialog:', JSON.stringify($data));
		}
		
		private function handler_requesetWithGraphPath($data:Object):void
		{
			showInfo("handler_requesetWithGraphPath:", JSON.stringify($data));  
		}
		
		private function showInfo(...$args):void
		{
			var __msg:String = "";
			for (var i:int = 0; i < $args.length; i++) 
			{
				__msg += $args[i] + " ";
			}
			__msg += "\n";
			infoTA.appendText(__msg);
		}
	}
}

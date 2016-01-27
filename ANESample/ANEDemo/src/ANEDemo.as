package
{
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	
	import cn.sharesdk.ane.PlatformID;
	import cn.sharesdk.ane.ShareSDKExtension;
	import cn.sharesdk.ane.ShareType;
	
	public class ANEDemo extends Sprite
	{
		
		private var shareSDK:ShareSDKExtension = new ShareSDKExtension();
		
		public function ANEDemo()
		{
			super();
			
			// 支持 autoOrient
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
		
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
				
			var TotalConf:Object = new Object();
									
			var SinaConf:Object = new Object();
			SinaConf["app_key"] = "568898243";
			SinaConf["app_secret"] = "38a4f8204cc784f81f9f0daaf31e02e3";
			SinaConf["redirect_uri"] = "http://www.sharesdk.cn";
			SinaConf["auth_type"] = "both"; 							//iOS需要,可填入web、sso 或 both
			TotalConf[PlatformID.SinaWeibo] = SinaConf;
			
			var TencentConf:Object = new Object();
			TencentConf["app_key"] = "801307650";
			TencentConf["app_secret"] = "ae36f4ee3946e1cbb98d6965b0b2ff5c";
			TencentConf["redirect_uri"] = "http://www.sharesdk.cn";
			TotalConf[PlatformID.TencentWeibo] = TencentConf;
			
			var WechatSessionConf:Object = new Object();
			WechatSessionConf["app_id"] = "wx4868b35061f87885";
			WechatSessionConf["app_secret"] = "64020361b8ec4c99936c0e3999a9f249";		
			
			TotalConf[PlatformID.WeChat] = WechatSessionConf;
			TotalConf[PlatformID.WeChatMoments] = WechatSessionConf;
			TotalConf[PlatformID.WeChatFavorites] = WechatSessionConf;
					
//			TotalConf[PlatformID.WechatSeries] = WechatSessionConf; 	// iOS中可直接通过本句配置微信系列
			
			var QQConf:Object = new Object();
			QQConf["app_id"] = "100371282";
			QQConf["app_key"] = "aed9b0303e3ed1e27bae87c33761161d";
			QQConf["auth_type"] = "both";
			
			TotalConf[PlatformID.QQ] = QQConf;
			TotalConf[PlatformID.QZone] = QQConf;
			
//			TotalConf[PlatformID.QQSeries] = QQConf;					// iOS中可直接通过本句配置QQ系列
			
			var RenrenConf:Object = new Object();
			RenrenConf["app_id"] = "226427";
			RenrenConf["app_key"] = "fc5b8aed373c4c27a05b712acba0f8c3";
			RenrenConf["app_secret"] = "f29df781abdd4f49beca5a2194676ca4";
			RenrenConf["auth_type"] = "both";
			TotalConf[PlatformID.Renren] = RenrenConf;
					
			var FaceBookConf:Object = new Object();
			FaceBookConf["api_key"] = "107704292745179";
			FaceBookConf["app_secret"] = "38053202e1a5fe26c80c753071f0b573";
			FaceBookConf["auth_type"] = "both";
			TotalConf[PlatformID.Facebook] = FaceBookConf;
			
			var TwitterConf:Object = new Object();
			TwitterConf["consumer_key"] = "LRBM0H75rWrU9gNHvlEAA2aOy";
			TwitterConf["consumer_secret"] = "gbeWsZvA9ELJSdoBzJ5oLKX0TU09UOwrzdGfo9Tg7DjyGuMe8G";
			TwitterConf["redirect_uri"] = "http://mob.com";
			TotalConf[PlatformID.Twitter] = TwitterConf;
			
			shareSDK.registerAppAndSetPlatformConfig("6c7d91b85e4b",TotalConf);
			shareSDK.setPlatformActionListener(onComplete, onError, onCancel);
	
		}
		
		private static const BUTTON_WIDTH:Number = 300;
		private static const BUTTON_HEIGHT:Number = 60;
		
		private function addedToStageHandler(event:Event):void
		{
			
			var authBtn:Button = new Button();
			authBtn.label = "授权";
			authBtn.x = 100;
			authBtn.y = 20;
			authBtn.width = BUTTON_WIDTH;
			authBtn.height = BUTTON_HEIGHT;
			this.addChild(authBtn);
			authBtn.addEventListener(MouseEvent.CLICK, authBtnClickHandler);
			
			var cancelAuthBtn:Button = new Button();
			cancelAuthBtn.label = "取消授权";
			cancelAuthBtn.x = 100;
			cancelAuthBtn.y = authBtn.y + authBtn.height + 10;
			cancelAuthBtn.width = BUTTON_WIDTH;
			cancelAuthBtn.height = BUTTON_HEIGHT;
			this.addChild(cancelAuthBtn);
			cancelAuthBtn.addEventListener(MouseEvent.CLICK, cancelAuthBtnClickHandler);
			
			var hasAuthBtn:Button = new Button();
			hasAuthBtn.label = "检测授权";
			hasAuthBtn.x = 100;
			hasAuthBtn.y = cancelAuthBtn.y + cancelAuthBtn.height + 10;
			hasAuthBtn.width = BUTTON_WIDTH;
			hasAuthBtn.height = BUTTON_HEIGHT;
			this.addChild(hasAuthBtn);
			hasAuthBtn.addEventListener(MouseEvent.CLICK, hasAuthBtnClickHandler);
			
			var getUserInfoBtn:Button = new Button();
			getUserInfoBtn.label = "获取用户资料";
			getUserInfoBtn.x = 100;
			getUserInfoBtn.y = hasAuthBtn.y + hasAuthBtn.height + 10;
			getUserInfoBtn.width = BUTTON_WIDTH;
			getUserInfoBtn.height = BUTTON_HEIGHT;
			this.addChild(getUserInfoBtn);
			getUserInfoBtn.addEventListener(MouseEvent.CLICK, getUserInfoBtnClickHandler);
			
			var shareBtn:Button = new Button();
			shareBtn.label = "分享";
			shareBtn.x = 100;
			shareBtn.y = getUserInfoBtn.y + getUserInfoBtn.height + 10;
			shareBtn.width = BUTTON_WIDTH;
			shareBtn.height = BUTTON_HEIGHT;
			this.addChild(shareBtn);
			shareBtn.addEventListener(MouseEvent.CLICK, shareBtnClickHandler);
			
			var oneKeyShareBtn:Button = new Button();
			oneKeyShareBtn.label = "一键分享";
			oneKeyShareBtn.x = 100;
			oneKeyShareBtn.y = shareBtn.y + shareBtn.height + 10;
			oneKeyShareBtn.width = BUTTON_WIDTH;
			oneKeyShareBtn.height = BUTTON_HEIGHT;
			this.addChild(oneKeyShareBtn);
			oneKeyShareBtn.addEventListener(MouseEvent.CLICK, oneKeyShareBtnClickHandler);
			
			var shareMenuBtn:Button = new Button();
			shareMenuBtn.label = "显示分享菜单";
			shareMenuBtn.x = 100;
			shareMenuBtn.y = oneKeyShareBtn.y + oneKeyShareBtn.height + 10;
			shareMenuBtn.width = BUTTON_WIDTH;
			shareMenuBtn.height = BUTTON_HEIGHT;
			this.addChild(shareMenuBtn);
			shareMenuBtn.addEventListener(MouseEvent.CLICK, shareMenuBtnClickHandler);
			
			var shareViewBtn:Button = new Button();
			shareViewBtn.label = "显示分享编辑页";
			shareViewBtn.x = 100;
			shareViewBtn.y = shareMenuBtn.y + shareMenuBtn.height + 10;
			shareViewBtn.width = BUTTON_WIDTH;
			shareViewBtn.height = BUTTON_HEIGHT;
			this.addChild(shareViewBtn);
			shareViewBtn.addEventListener(MouseEvent.CLICK, shareViewBtnClickHandler);
			
			var checkClientBtn:Button = new Button();
			checkClientBtn.label = "检测客户端";
			checkClientBtn.x = 100;
			checkClientBtn.y = shareViewBtn.y + shareViewBtn.height + 10;
			checkClientBtn.width = BUTTON_WIDTH;
			checkClientBtn.height = BUTTON_HEIGHT;
			this.addChild(checkClientBtn);
			checkClientBtn.addEventListener(MouseEvent.CLICK, checkClientBtnClickHandler);
			
			var getCredentialBtn:Button = new Button();
			getCredentialBtn.label = "获取授权信息";
			getCredentialBtn.x = 100;
			getCredentialBtn.y = checkClientBtn.y + checkClientBtn.height + 10;
			getCredentialBtn.width = BUTTON_WIDTH;
			getCredentialBtn.height = BUTTON_HEIGHT;
			this.addChild(getCredentialBtn);
			getCredentialBtn.addEventListener(MouseEvent.CLICK, getCredentialBtnClickHandler);
			
			var addFriendBtn:Button = new Button();
			addFriendBtn.label = "添加好友";
			addFriendBtn.x = 100;
			addFriendBtn.y = getCredentialBtn.y + getCredentialBtn.height + 10;
			addFriendBtn.width = BUTTON_WIDTH;
			addFriendBtn.height = BUTTON_HEIGHT;
			this.addChild(addFriendBtn);
			addFriendBtn.addEventListener(MouseEvent.CLICK, addFriendBtnClickHandler);
			
			var getFriendListBtn:Button = new Button();
			getFriendListBtn.label = "获取好友列表";
			getFriendListBtn.x = 100;
			getFriendListBtn.y = addFriendBtn.y + addFriendBtn.height + 10;
			getFriendListBtn.width = BUTTON_WIDTH;
			getFriendListBtn.height = BUTTON_HEIGHT;
			this.addChild(getFriendListBtn);
			getFriendListBtn.addEventListener(MouseEvent.CLICK, getFriendListBtnClickHandler);
				
		}
		
		public function onComplete(reqId:int, platform:int, action:String, res:Object):void
		{
			var json:String = (res == null ? "" : JSON.stringify(res));
			var message:String = "onComplete\nPlatform=" + platform + ", action=" + action + "\nres=" + json + "\n reqId=" + reqId;
			//var message:String = "onComplete: Platform =" + platform + ", action = " + action + ", uid = " + res["uid"] + ", accessToken = " + res["access_token"];
			shareSDK.toast(message);
		}
		
		public function onCancel(reqId:int, platform:int, action:String):void 
		{
			var message:String = "onCancel\nPlatform=" + platform + ", action=" + action + "\n reqId=" + reqId;
			shareSDK.toast(message);
		}
		
		public function onError(reqId:int, platform:int, action:String, err:Object):void 
		{
			var json:String = (err == null ? "" : JSON.stringify(err));
			var message:String = "onError\nPlatform=" + platform + ", action=" + action + "\nres=" + json + "\n reqId=" + reqId;
			shareSDK.toast(message);
		}
		
		private function authBtnClickHandler(event:MouseEvent):int
		{
			return shareSDK.authorize(PlatformID.SinaWeibo);
		}
		
		private function cancelAuthBtnClickHandler(event:MouseEvent):void
		{
			shareSDK.cancelAuthorize(PlatformID.SinaWeibo);
		}
		
		private function hasAuthBtnClickHandler(event:MouseEvent):void
		{
			var isValid:Boolean = shareSDK.isAuthorizedValid(PlatformID.SinaWeibo);
			shareSDK.toast("isValid = " + isValid);
		}
		
		private function checkClientBtnClickHandler(event:MouseEvent):void
		{
			var isInstalled:Boolean = shareSDK.isClientValid(PlatformID.WeChat);
			
			shareSDK.toast("isInstalled =" + isInstalled);
		}
		private function getUserInfoBtnClickHandler(event:MouseEvent):int
		{
			return shareSDK.getUserInfo(PlatformID.TencentWeibo);
		}
		
		private function shareBtnClickHandler(event:MouseEvent):int
		{
			var shareParams:Object = new Object();
			shareParams.text = "这是分享的Text";
			shareParams.title = "ShareSDK for ANE发布";
			shareParams.imageUrl = "http://f1.sharesdk.cn/imgs/2014/02/26/owWpLZo_638x960.jpg";	
			shareParams.type = ShareType.SSDKContentTypeImage;
			return shareSDK.shareContent(PlatformID.SinaWeibo, shareParams);
		}
		
		private function oneKeyShareBtnClickHandler(event:MouseEvent):int
		{
			var platforms:Array = new Array(PlatformID.SinaWeibo, PlatformID.TencentWeibo);
			var shareParams:Object = new Object();
			shareParams.text = "好耶～好高兴啊～";
			shareParams.title = "ShareSDK for ANE发布";
			shareParams.url = "http://mob.com";
			shareParams.imageUrl = "http://f1.sharesdk.cn/imgs/2014/02/26/owWpLZo_638x960.jpg";	
			shareParams.type = ShareType.SSDKContentTypeImage;
			return shareSDK.oneKeyShareContent(platforms, shareParams);
		}
		
		private function shareMenuBtnClickHandler(event:MouseEvent):int
		{
			var shareParams:Object = new Object();
			//自定义菜单数组
			var shareList:Array = new Array(PlatformID.SinaWeibo,PlatformID.WeChat);	
			shareParams.text = "ShareSDK 3.0 for ANE Text";
			shareParams.title = "ShareSDK 3.0 for ANE Title";
			shareParams.url = "http://mob.com";
			shareParams.imageUrl = "http://f1.sharesdk.cn/imgs/2014/02/26/owWpLZo_638x960.jpg";
			shareParams.type = ShareType.SSDKContentTypeWebPage;
			
			//定制指定平台的分享内容(目前仅对iOS有效)
			var sinaParams:Object = new Object();
			sinaParams.text = "ANE Sina Text";
			sinaParams.title = "ANE Sina Title";
			var file:File = File.applicationDirectory.resolvePath("mac.jpeg");
			sinaParams.imageUrl = file.nativePath;
			sinaParams.url = "http://mob.com";
			sinaParams.latitude = "55.55";
			sinaParams.longitude = "66.66";
			sinaParams.objectID = "sinaId";
			sinaParams.type = ShareType.SSDKContentTypeImage;
			shareParams[PlatformID.SinaWeibo] = sinaParams;
			
			return shareSDK.showShareMenu(null, shareParams, 320, 460);
		}
		
		private function shareViewBtnClickHandler(event:MouseEvent):int
		{
			var shareParams:Object = new Object();
//			var file:File = File.applicationDirectory.resolvePath("mac.jpeg");
//			shareParams.imageUrl = file.nativePath;
			shareParams.text = "ShareSDK 3.0 for ANE Text";
			shareParams.title = "ShareSDK 3.0 for ANE Title";
			shareParams.url = "http://mob.com";
			shareParams.imageUrl = "http://f1.sharesdk.cn/imgs/2014/02/26/owWpLZo_638x960.jpg";
			shareParams.type = ShareType.SSDKContentTypeWebPage;
			return shareSDK.showShareView(PlatformID.SinaWeibo, shareParams);
		}	
		
		private function getCredentialBtnClickHandler(event:MouseEvent):void
		{
			var authInfo:Object = shareSDK.getAuthInfo(PlatformID.SinaWeibo);
			var json:String = (authInfo == null ? "" : JSON.stringify(authInfo));
			shareSDK.toast("authInfo = " + json);
		}
		
		private function addFriendBtnClickHandler(event:MouseEvent):int
		{
			return shareSDK.addFriend(PlatformID.TencentWeibo,"ShareSDK");
		}
		
		private function getFriendListBtnClickHandler(event:MouseEvent):int
		{
			return shareSDK.getFriendList(PlatformID.SinaWeibo,20,1);
		}
		
	}
}
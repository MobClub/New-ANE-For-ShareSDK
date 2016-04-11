package cn.sharesdk.ane 
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.InvokeEvent;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.system.Capabilities;
	import cn.sharesdk.ane.events.AddFriendEvent;
	import cn.sharesdk.ane.events.AuthEvent;
	import cn.sharesdk.ane.events.GetFriendsListEvent;
	import cn.sharesdk.ane.events.ShareEvent;
	import cn.sharesdk.ane.events.UserInfoEvent;
	
	public class ShareSDKExtension implements IEventDispatcher 
	{
		private var SDKKey:String;
		private var reqID:int;
		private var context:ExtensionContext;
		private var onCom:Function;
		private var onErr:Function;
		private var onCan:Function;
		
		public function ShareSDKExtension()
		{
			context = ExtensionContext.createExtensionContext("cn.sharesdk.ane.ShareSDKExtension","");
			context.addEventListener(StatusEvent.STATUS, apiCallback);
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, invokeHandler);
		}
		
		private function invokeHandler(event:InvokeEvent):void
		{
			if (event.arguments.length > 0)
			{
				var params:Object = new Object();
				params["url"] = event.arguments[0] as String;
				params["source_app"] = event.arguments[1] as String;
				params["annotation"] = event.arguments[2] as String;
				
				apiCaller("handleOpenURL", params);
			}	
		}
		
		private function apiCaller(action:String, params:Object = null):Object 
		{
			var data:Object = new Object();
			data.action = action;
			data.params = params;
			var json:String = JSON.stringify(data);
//			trace("callJavaFunctionMethod-params : ", json);
			return context.call("ShareSDKUtils", json);
		}
		
		private function apiCallback(e:StatusEvent):void 
		{
			if (e.code == "SSDK_PA") 
			{
				var json:String = e.level;
//				trace (json);
				if (json == null) 
				{
					return;
				}
				
				var resp:Object = JSON.parse(json);
				var platform:int = resp.platform;
				var action:int = resp.action; 		// 
				var status:int = resp.status; 		// Success = 1, Fail = 2, Cancel = 3
				var reqID:int = resp.reqID;
				var res:Object = resp.res;
				
				var error:Object = null;
				var user:Object = null;
				
				switch (status)
				{
					case ResponseState.SUCCESS: 
						onComplete(reqID, platform, action, res); 
						break;
					case ResponseState.FAIL:
						error = res;
						onError(reqID, platform, action, res); 
						break;
					case ResponseState.CANCEL: 
						onCancel(reqID, platform, action); 
						break;
				}
				
				//派发事件
				switch (action)
				{
					case Action.AUTHORIZE:
						
						var authEvt:AuthEvent = new AuthEvent(AuthEvent.STATUS);
						authEvt.platform = platform;
						authEvt.status = status;
						authEvt.error = error;
						authEvt.reqID = reqID;
						this.dispatchEvent(authEvt);
						
						break;
					case Action.USER_INFO:
						
						var userEvt:UserInfoEvent = new UserInfoEvent(UserInfoEvent.STATUS);
						userEvt.platform = platform;
						userEvt.status = status;
						userEvt.error = error;
						userEvt.reqID = reqID;
						if (userEvt.status == ResponseState.SUCCESS && res)
						{
							userEvt.data = res;
						}
						
						this.dispatchEvent(userEvt);
						
						break;
					case Action.SHARE:
						
						var shareEvt:ShareEvent = new ShareEvent(ShareEvent.STATUS);
						shareEvt.platform = platform;
						shareEvt.status = status;
						shareEvt.error = error;
						shareEvt.reqID = reqID;
						if (shareEvt.status == ResponseState.SUCCESS && res)
						{
							shareEvt.end = res.end;
							shareEvt.data = res.data;
						}
						
						this.dispatchEvent(shareEvt);
			
						break;
					
					case Action.ADD_FRIEND:
						
						var addFriendEvt:AddFriendEvent = new AddFriendEvent(AddFriendEvent.STATUS);
						addFriendEvt.platform = platform;
						addFriendEvt.status = status;
						addFriendEvt.error = error;	
						addFriendEvt.reqID = reqID;
						this.dispatchEvent(addFriendEvt);
						
						break;
					
					case Action.GETTING_FRIEND_LIST:
						
						var getFriendListEvt:GetFriendsListEvent = new GetFriendsListEvent(GetFriendsListEvent.STATUS);	
						getFriendListEvt.platform = platform;
						getFriendListEvt.status = status;
						getFriendListEvt.error = error;
						getFriendListEvt.reqID = reqID;
						if (getFriendListEvt.status == ResponseState.SUCCESS && res)
						{
							getFriendListEvt.data = res;
						}
						
						this.dispatchEvent(getFriendListEvt);
						break;
						
				}
			}
		}
		
		/**
		 * @inheritDoc
		 * 
		 */		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			context.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		/**
		 * @inheritDoc
		 * 
		 */	
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			context.removeEventListener(type, listener, useCapture);
		}
		
		/**
		 * @inheritDoc
		 * 
		 */	
		public function dispatchEvent(event:Event):Boolean
		{
			return context.dispatchEvent(event);
		}
		
		/**
		 * @inheritDoc
		 * 
		 */	
		public function hasEventListener(type:String):Boolean
		{
			return context.hasEventListener(type);
		}
		
		/**
		 * @inheritDoc
		 * 
		 */	
		public function willTrigger(type:String):Boolean
		{
			return context.willTrigger(type);
		}
		
		/**
		 * 设置平台回调监听
		 * @param onComplete	完成
		 * @param onError		错误
		 * @param onCancel		取消
		 * 
		 */		
		public function setPlatformActionListener(onComplete:Function, onError:Function, onCancel:Function):void 
		{
			this.onCom = onComplete;
			this.onErr = onError;
			this.onCan = onCancel;
		}
		
		//设置平台信息
		public function initSDK(appKey:String):void
		{
			var params:Object = new Object();
			params.appKey = appKey;
			SDKKey = appKey;
			apiCaller(NativeMethodName.INIT_SDK, params);		
		}
		
		//设置平台信息
		public function setPlatformConfig(config:Object):void
		{
			var params:Object = new Object();
			params.config = config;
			//对于iOS需要将SDKKey一并传过去
	 		if (Capabilities.manufacturer.indexOf("iOS") != -1)
			{
		 		params.appkey = SDKKey;
			}
			
			apiCaller(NativeMethodName.SET_PLATFORM_CONFIG, params);		
		}
		
		//授权
		public function authorize(platform:int):int 
		{
			reqID ++;
			var params:Object = new Object();
			params.platform = platform;
			params.reqID = reqID;
			apiCaller(NativeMethodName.AUTHORIZE, params);
			return reqID;
		}
		
		//取消授权
		public function cancelAuthorize(platform:int):void 
		{
			var params:Object = new Object();
			params.platform = platform;
			apiCaller(NativeMethodName.CANCEL_AUTHORIZATION, params);
		}
		
		//判断授权是否有效
		public function isAuthorized(platform:int):Boolean 
		{
			var params:Object = new Object();
			params.platform = platform;
			var obj:Object = apiCaller(NativeMethodName.IS_AUTHORIZED, params);					
			if (obj == null)
			{
				return false;
			}
			else 
			{
				return obj;
			}
		}
		
		//判断客户端是否存在
		public function isClientValid(platform:int):Boolean 
		{
			var params:Object = new Object();
			params.platform = platform;
			var obj:Object = apiCaller(NativeMethodName.IS_CLIENT_VALID, params);	
			if (obj == null)
			{
				return false;
			}
			else 
			{
				return obj;
			}
			
		}
		
		//获取用户信息
		public function getUserInfo(platform:int):int 
		{
			reqID ++;
			var params:Object = new Object();
			params.platform = platform;
			params.reqID = reqID;
			apiCaller(NativeMethodName.GET_USER_INFO, params);
			return reqID;
		}
		
		//分享，没有编辑界面
		public function shareContent(platform:int, shareParams:ShareContent):int 
		{
			reqID ++;
			var params:Object = new Object();
			params.platform = platform;
			if (shareParams != null) {
				params.shareParams = shareParams.getShareParams();
			}
			params.reqID = reqID;
			apiCaller(NativeMethodName.SHARE_CONTENT, params);
			return reqID;
		}
		
		//多个平台分享，没有编辑界面；不推荐使用，用户体验不好；建议使用shareContent
		public function oneKeyShareContent(platforms:Array, shareParams:ShareContent):int 
		{
			reqID ++;
			var params:Object = new Object();
			params.platforms = platforms;
			if (shareParams != null) {
				params.shareParams = shareParams.getShareParams();
			}
			params.reqID = reqID;
			apiCaller(NativeMethodName.MULTI_SHARE, params);
			return reqID;
		}
		
		//分享，显示九宫格
		public function showPlatformList(platforms:Array = null, shareParams:ShareContent = null, x:Number = 0, y:Number = 0):int
		{
			reqID ++;
			var params:Object = new Object();
			params.platforms = platforms;
			if (shareParams != null) {
				params.shareParams = shareParams.getShareParams();
			}
			params.x = x;
			params.y = y;
			params.reqID = reqID;
			apiCaller(NativeMethodName.SHOW_PLATFORM_LIST, params);
			return reqID;
		}
		
		//分享，直接进入编辑界面
		public function showShareContentEditor(platform:int, shareParams:ShareContent = null):int 
		{
			reqID ++;
			var params:Object = new Object();
			params.platform = platform;
			if (shareParams != null) {
				params.shareParams = shareParams.getShareParams();
			}
			params.reqID = reqID;
			apiCaller(NativeMethodName.SHOW_SHARE_CONTENT_EDITOR, params);
			return reqID;
		}
		
		//关注好友
		public function addFriend(platform:int, account:String):int
		{
			reqID ++;
			var params:Object = new Object();
			params.platform = platform;
			params.account = account;
			params.reqID = reqID;
			apiCaller(NativeMethodName.ADD_FRIEND, params);
			return reqID;
		}
		
		//获取好友列表，新浪、腾讯、facebook
		public function getFriendList(platform:int, count:int, page:int):int
		{
			reqID ++;
			var params:Object = new Object();
			params.platform = platform;
			params.count = count;
			params.page = page;
			params.reqID = reqID;
			apiCaller(NativeMethodName.GET_FRIEND_LIST, params);
			return reqID;
		}
		
		//获取授权用户信息
		public function getAuthInfo(platform:int):Object
		{
			var params:Object = new Object();
			params.platform = platform;
			var authInfo:Object = apiCaller(NativeMethodName.GET_AUTH_INFO, params);	
			
			if(authInfo == null)
			{
				return null;
			}
			else
			{
				return authInfo;
			}			
		}
		
		public function toast(message:String):void 
		{
			var params:Object = new Object();
			params.message = message;
			apiCaller("toast", params);
		}
		
		//关闭SSO授权
		public function disableSSO(close:Boolean):void 
		{
			var params:Object = new Object();
			params.close = close;
			apiCaller(NativeMethodName.DISABLE_SSO, params);
		}		
		
		//监听结果：成功
		private function onComplete(reqID:int, platform:int, action:int, res:Object):void 
		{
			if (onCom != null) 
			{
				onCom(reqID, platform, action, res);
			}
		}
		
		//监听结果：取消
		private function onCancel(reqID:int, platform:int, action:int):void
		{
			if (onCan != null) 
			{
				onCan(reqID, platform, action);
			}
		}
		
		//监听结果：错误
		private function onError(reqID:int, platform:int, action:int, err:Object):void
		{
			if (onErr != null) 
			{
				onErr(reqID, platform, action, err);
			}
		}				
	}
	
}
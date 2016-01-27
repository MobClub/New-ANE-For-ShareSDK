package cn.sharesdk.ane 
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.InvokeEvent;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	
	import cn.sharesdk.ane.events.AddFriendEvent;
	import cn.sharesdk.ane.events.AuthEvent;
	import cn.sharesdk.ane.events.GetFriendsListEvent;
	import cn.sharesdk.ane.events.ShareEvent;
	import cn.sharesdk.ane.events.UserInfoEvent;
	
	public class ShareSDKExtension implements IEventDispatcher 
	{
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
		
		
		public function registerAppAndSetPlatformConfig(appkey:String ,config:Object):void
		{
			var params:Object = new Object();
			params.appkey = appkey;
			params.config = config;
			apiCaller(NativeMethodName.REGISTER_APP_AND_SET_PLATFORM_CONF, params);		
		}
		
		public function authorize(platform:int):int 
		{
			reqID ++;
			var params:Object = new Object();
			params.platform = platform;
			params.reqID = reqID;
			apiCaller(NativeMethodName.AUTHORIZE, params);
			return reqID;
		}
		
		public function cancelAuthorize(platform:int):void 
		{
			var params:Object = new Object();
			params.platform = platform;
			apiCaller(NativeMethodName.CANCEL_AUTHORIZATION, params);
		}
		
		public function isAuthorizedValid(platform:int):Boolean 
		{
			var params:Object = new Object();
			params.platform = platform;
			var obj:Object = apiCaller(NativeMethodName.IS_AUTHORIZED_VALID, params);					
			if (obj == null)
			{
				return false;
			}
			else 
			{
				return obj;
			}
		}
		
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
		public function getUserInfo(platform:int):int 
		{
			reqID ++;
			var params:Object = new Object();
			params.platform = platform;
			params.reqID = reqID;
			apiCaller(NativeMethodName.GET_USER_INFO, params);
			return reqID;
		}
		
		public function shareContent(platform:int, shareParams:Object):int 
		{
			reqID ++;
			var params:Object = new Object();
			params.platform = platform;
			params.shareParams = shareParams;
			params.reqID = reqID;
			apiCaller(NativeMethodName.SHARE_CONTENT, params);
			return reqID;
		}
		
		public function oneKeyShareContent(platforms:Array, shareParams:Object):int 
		{
			reqID ++;
			var params:Object = new Object();
			params.platforms = platforms;
			params.shareParams = shareParams;
			params.reqID = reqID;
			apiCaller(NativeMethodName.MULTI_SHARE, params);
			return reqID;
		}
		
		public function showShareMenu(platforms:Array = null, shareParams:Object = null, x:Number = 0, y:Number = 0):int
		{
			reqID ++;
			var params:Object = new Object();
			params.platforms = platforms;
			params.shareParams = shareParams;
			params.x = x;
			params.y = y;
			params.reqID = reqID;
			apiCaller(NativeMethodName.SHOW_SHARE_MENU, params);
			return reqID;
		}
		
		public function showShareView(platform:int, shareParams:Object = null):int 
		{
			reqID ++;
			var params:Object = new Object();
			params.platform = platform;
			params.shareParams = shareParams;
			params.reqID = reqID;
			apiCaller(NativeMethodName.SHOW_SHARE_VIEW, params);
			return reqID;
		}
		
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
		
		public function closeSSOWhenAuthorize(close:Boolean):void 
		{
			var params:Object = new Object();
			params.close = close;
			apiCaller(NativeMethodName.CLOSE_SSO_WHEN_AUTHORIZE, params);
		}		
		
		private function onComplete(reqID:int, platform:int, action:int, res:Object):void 
		{
			if (onCom != null) 
			{
				onCom(reqID, platform, action, res);
			}
		}
		
		private function onCancel(reqID:int, platform:int, action:int):void
		{
			if (onCan != null) 
			{
				onCan(reqID, platform, action);
			}
		}
		
		private function onError(reqID:int, platform:int, action:int, err:Object):void
		{
			if (onErr != null) 
			{
				onErr(reqID, platform, action, err);
			}
		}		
		
	}
	
}
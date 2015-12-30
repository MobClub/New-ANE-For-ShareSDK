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
		
		private var context:ExtensionContext;
		private var onCom:Function;
		private var onErr:Function;
		private var onCan:Function;
		
		public function ShareSDKExtension()
		{
			context = ExtensionContext.createExtensionContext("cn.sharesdk.ane.ShareSDKExtension","");
			context.addEventListener(StatusEvent.STATUS, javaCallback);
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
				
				callJavaFunction("handleOpenURL", params);
			}	
		}
		
		private function callJavaFunction(action:String, params:Object = null):Object 
		{
			var data:Object = new Object();
			data.action = action;
			data.params = params;
			var json:String = JSON.stringify(data);
//			trace("callJavaFunctionMethod-params : ", json);
			return context.call("ShareSDKUtils", json);
		}
		
		private function javaCallback(e:StatusEvent):void 
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
				var reqId:int = resp.reqId;
				var res:Object = resp.res;
				
				var error:Object = null;
				var user:Object = null;
				
				switch (status)
				{
					case ResponseState.SUCCESS: 
						onComplete(reqId, platform, action, res); 
						break;
					case ResponseState.FAIL:
						error = res;
						onError(reqId, platform, action, res); 
						break;
					case ResponseState.CANCEL: 
						onCancel(reqId, platform, action); 
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
						authEvt.reqId = reqId;
						this.dispatchEvent(authEvt);
						
						break;
					case Action.USER_INFO:
						
						var userEvt:UserInfoEvent = new UserInfoEvent(UserInfoEvent.STATUS);
						userEvt.platform = platform;
						userEvt.status = status;
						userEvt.error = error;
						userEvt.reqId = reqId;
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
						shareEvt.reqId = reqId;
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
						addFriendEvt.reqId = reqId;
						this.dispatchEvent(addFriendEvt);
						
						break;
					
					case Action.GETTING_FRIEND_LIST:
						
						var getFriendListEvt:GetFriendsListEvent = new GetFriendsListEvent(GetFriendsListEvent.STATUS);	
						getFriendListEvt.platform = platform;
						getFriendListEvt.status = status;
						getFriendListEvt.error = error;
						getFriendListEvt.reqId = reqId;
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
			callJavaFunction(NativeMethodName.REGISTER_APP_AND_SET_PLATFORM_CONF, params);		
		}
		
		public function Authorize(reqId:int, platform:int):void 
		{
			var params:Object = new Object();
			params.platform = platform;
			params.reqId = reqId;
			callJavaFunction(NativeMethodName.AUTHORIZE, params);
			
		}
		
		public function CancelAuthorize(platform:int):void 
		{
			var params:Object = new Object();
			params.platform = platform;
			callJavaFunction(NativeMethodName.CANCEL_AUTHORIZATION, params);
		}
		
		public function IsAuthorizedValid(platform:int):Boolean 
		{
			var params:Object = new Object();
			params.platform = platform;
			var obj:Object = callJavaFunction(NativeMethodName.IS_AUTHORIZED_VALID, params);					
			if (obj == null)
			{
				return false;
			}
			else 
			{
				return obj;
			}
		}
		
		public function IsClientValid(platform:int):Boolean 
		{
			var params:Object = new Object();
			params.platform = platform;
			var obj:Object = callJavaFunction(NativeMethodName.IS_CLIENT_VALID, params);	
			if (obj == null)
			{
				return false;
			}
			else 
			{
				return obj;
			}
			
		}
		public function GetUserInfo(reqId:int, platform:int):void 
		{
			var params:Object = new Object();
			params.platform = platform;
			params.reqId = reqId;
			callJavaFunction(NativeMethodName.GET_USER_INFO, params);
		}
		
		public function ShareContent(reqId:int,platform:int, shareParams:Object):void 
		{
			var params:Object = new Object();
			params.platform = platform;
			params.shareParams = shareParams;
			params.reqId = reqId;
			callJavaFunction(NativeMethodName.SHARE, params);
		}
		
		public function OneKeyShareContent(reqId:int, platforms:Array, shareParams:Object):void 
		{
			var params:Object = new Object();
			params.platforms = platforms;
			params.shareParams = shareParams;
			params.reqId = reqId;
			callJavaFunction(NativeMethodName.MULTI_SHARE, params);
		}
		
		public function ShowShareMenu(reqId:int, platforms:Array = null, shareParams:Object = null, x:Number = 0, y:Number = 0):void 
		{
			var params:Object = new Object();
			params.platforms = platforms;
			params.shareParams = shareParams;
			params.x = x;
			params.y = y;
			params.reqId = reqId;
			callJavaFunction(NativeMethodName.SHOW_SHARE_MENU, params);
		}
		
		public function ShowShareView(reqId:int, platform:int, shareParams:Object = null):void 
		{
			var params:Object = new Object();
			params.platform = platform;
			params.shareParams = shareParams;
			params.reqId = reqId;
			callJavaFunction(NativeMethodName.SHOW_SHARE_VIEW, params);
		}
		
		public function AddFriend(reqId:int, platform:int, account:String):void
		{
			var params:Object = new Object();
			params.platform = platform;
			params.account = account;
			params.reqId = reqId;
			callJavaFunction(NativeMethodName.ADD_FRIEND, params);
		}
		
		public function GetFriendList(reqId:int, platform:int, count:int, page:int):void
		{
			var params:Object = new Object();
			params.platform = platform;
			params.count = count;
			params.page = page;
			params.reqId = reqId;
			callJavaFunction(NativeMethodName.GET_FRIEND_LIST, params);
		}
		
		public function GetAuthInfo(platform:int):Object
		{
			var params:Object = new Object();
			params.platform = platform;
			var authInfo:Object = callJavaFunction(NativeMethodName.GET_AUTH_INFO, params);	
			
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
			callJavaFunction("toast", params);
		}
	

//		public function screenshot():String 
//		{
//			var path:Object = callJavaFunction("screenshot");
//			return path.path;
//		}
		
		
		public function onComplete(reqId:int, platform:int, action:int, res:Object):void 
		{
			if (onCom != null) 
			{
				onCom(reqId, platform, action, res);
			}
		}
		
		public function onCancel(reqId:int, platform:int, action:int):void
		{
			if (onCan != null) 
			{
				onCan(reqId, platform, action);
			}
		}
		
		public function onError(reqId:int, platform:int, action:int, err:Object):void
		{
			if (onErr != null) 
			{
				onErr(reqId, platform, action, err);
			}
		}
		
	}
	
}
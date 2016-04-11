package cn.sharesdk.ane.platform
{
	import flash.system.Capabilities;
	public class SinaWeibo extends DevInfo
	{					
		public function setAppKey (appKey:String):void 
		{
			if (Capabilities.manufacturer.indexOf("Android") != -1)
			{
				platformConf["AppKey"] = appKey;
			}
			else if (Capabilities.manufacturer.indexOf("iOS") != -1)
			{
				platformConf["app_key"] = appKey;
			}
		}
		public function setAppSecret (appSecret:String):void 
		{
			if (Capabilities.manufacturer.indexOf("Android") != -1)
			{
				platformConf["AppSecret"] = appSecret;
			}
			else if (Capabilities.manufacturer.indexOf("iOS") != -1)
			{
				platformConf["app_secret"] = appSecret;
			}
		}
		public function setRedirectUrl (redirectUrl:String):void 
		{
			if (Capabilities.manufacturer.indexOf("Android") != -1)
			{
				platformConf["RedirectUrl"] = redirectUrl;
			}
			else if (Capabilities.manufacturer.indexOf("iOS") != -1)
			{
				platformConf["redirect_uri"] = redirectUrl;
			}
		}			
		//Android Only
		public function setShareByAppClient (shareByAppClient:Boolean):void 
		{
			platformConf["ShareByAppClient"] = shareByAppClient;
		}
		//iOS Only
		public function setAuthType (authType:String):void
		{
			platformConf["auth_type"] = authType;
		}
	}
}
package cn.sharesdk.ane.platform
{
	import flash.system.Capabilities;
	public class Kaixin extends DevInfo
	{					
		public function setAppKey (appKey:String):void 
		{
			if (Capabilities.manufacturer.indexOf("Android") != -1)
			{
				platformConf["AppKey"] = appKey;
			}
			else if (Capabilities.manufacturer.indexOf("iOS") != -1)
			{
				platformConf["api_key"] = appKey;
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
				platformConf["secret_key"] = appSecret;
			}
		}
		public function setRedirectUri (redirectUri:String):void 
		{
			if (Capabilities.manufacturer.indexOf("Android") != -1)
			{
				platformConf["RedirectUri"] = redirectUri;
			}
			else if (Capabilities.manufacturer.indexOf("iOS") != -1)
			{
				platformConf["redirect_uri"] = redirectUri;
			}
		}		
	}
}
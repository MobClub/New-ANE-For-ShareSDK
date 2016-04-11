package cn.sharesdk.ane.platform
{
	import flash.system.Capabilities;
	public class MingDao extends DevInfo
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
package cn.sharesdk.ane.platform
{
	import flash.system.Capabilities;
	public class Flickr extends DevInfo
	{					
		public function setApiKey (apiKey:String):void 
		{
			if (Capabilities.manufacturer.indexOf("Android") != -1)
			{
				platformConf["ApiKey"] = apiKey;
			}
			else if (Capabilities.manufacturer.indexOf("iOS") != -1)
			{
				platformConf["api_key"] = apiKey;
			}
		}
		public function setApiSecret (apiSecret:String):void 
		{
			
			if (Capabilities.manufacturer.indexOf("Android") != -1)
			{
				platformConf["ApiSecret"] = apiSecret;
			}
			else if (Capabilities.manufacturer.indexOf("iOS") != -1)
			{
				platformConf["api_secret"] = apiSecret;
			}
		}
		//Android Only
		public function setRedirectUri (redirectUri:String):void 
		{
			platformConf["RedirectUri"] = redirectUri;
		}		
	}
}
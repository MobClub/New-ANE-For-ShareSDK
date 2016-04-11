package cn.sharesdk.ane.platform
{
	import flash.system.Capabilities;
	public class Douban extends DevInfo
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
		public function setSecret (secret:String):void 
		{
			
			if (Capabilities.manufacturer.indexOf("Android") != -1)
			{
				platformConf["Secret"] = secret;
			}
			else if (Capabilities.manufacturer.indexOf("iOS") != -1)
			{
				platformConf["secret"] = secret;
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
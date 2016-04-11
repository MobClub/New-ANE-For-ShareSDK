package cn.sharesdk.ane.platform
{
	import flash.system.Capabilities;
	public class Instagram extends DevInfo
	{					
		public function setClientId (clientId:String):void 
		{
			if (Capabilities.manufacturer.indexOf("Android") != -1)
			{
				platformConf["ClientId"] = clientId;
			}
			else if (Capabilities.manufacturer.indexOf("iOS") != -1)
			{
				platformConf["client_id"] = clientId;
			}
		}
		public function setClientSecret (clientSecret:String):void 
		{
			
			if (Capabilities.manufacturer.indexOf("Android") != -1)
			{
				platformConf["ClientSecret"] = clientSecret;
			}
			else if (Capabilities.manufacturer.indexOf("iOS") != -1)
			{
				platformConf["client_secret"] = clientSecret;
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
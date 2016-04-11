package cn.sharesdk.ane.platform
{
	import flash.system.Capabilities;
	public class Youdao extends DevInfo
	{	
		//Android Only
		public function setHostType (hostType:String):void 
		{
			platformConf["HostType"] = hostType;
		}
		public function setConsumerKey (consumerKey:String):void 
		{
			if (Capabilities.manufacturer.indexOf("Android") != -1)
			{
				platformConf["ConsumerKey"] = consumerKey;
			}
			else if (Capabilities.manufacturer.indexOf("iOS") != -1)
			{
				platformConf["consumer_key"] = consumerKey;
			}
		}
		public function setConsumerSecret (consumerSecret:String):void 
		{
			if (Capabilities.manufacturer.indexOf("Android") != -1)
			{
				platformConf["ConsumerSecret"] = consumerSecret;
			}
			else if (Capabilities.manufacturer.indexOf("iOS") != -1)
			{
				platformConf["consumer_secret"] = consumerSecret;
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
				platformConf["oauth_callback"] = redirectUri;
			}
		}			
	}
}
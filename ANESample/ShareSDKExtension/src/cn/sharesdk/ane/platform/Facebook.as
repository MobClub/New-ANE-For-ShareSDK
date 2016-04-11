package cn.sharesdk.ane.platform
{
	import flash.system.Capabilities;
	public class Facebook extends DevInfo
	{					
		public function setConsumerKey (consumerKey:String):void 
		{
			if (Capabilities.manufacturer.indexOf("Android") != -1)
			{
				platformConf["ConsumerKey"] = consumerKey;
			}
			else if (Capabilities.manufacturer.indexOf("iOS") != -1)
			{
				platformConf["api_key"] = consumerKey;
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
				platformConf["app_secret"] = consumerSecret;
			}
		}
		//Android Only
		public function setRedirectUrl (redirectUrl:String):void 
		{
			platformConf["RedirectUrl"] = redirectUrl;
		}
		//iOS Only
		public function setAuthType (authType:String):void
		{
			platformConf["auth_type"] = authType;
		}
	}
}

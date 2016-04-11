package cn.sharesdk.ane.platform
{
	import flash.system.Capabilities;
	public class Pocket extends DevInfo
	{					
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
		
		//iOS Only
		public function setRedirectUri (redirectUri:String):void
		{
			platformConf["redirect_uri"] = redirectUri;
		}
		
		//iOS Only
		public function setAuthType (authType:String):void
		{
			platformConf["auth_type"] = authType;
		}
		
	}
}
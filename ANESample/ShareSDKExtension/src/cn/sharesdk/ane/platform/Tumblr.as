package cn.sharesdk.ane.platform
{
	import flash.system.Capabilities;
	public class Tumblr extends DevInfo
	{					
		public function setOAuthConsumerKey (oAuthConsumerKey:String):void 
		{
			if (Capabilities.manufacturer.indexOf("Android") != -1)
			{
				platformConf["OAuthConsumerKey"] = oAuthConsumerKey;
			}
			else if (Capabilities.manufacturer.indexOf("iOS") != -1)
			{
				platformConf["consumer_key"] = oAuthConsumerKey;
			}
		}
		public function setSecretKey (secretKey:String):void 
		{
			if (Capabilities.manufacturer.indexOf("Android") != -1)
			{
				platformConf["SecretKey"] = secretKey;
			}
			else if (Capabilities.manufacturer.indexOf("iOS") != -1)
			{
				platformConf["consumer_secret"] = secretKey;
			}
		}
		public function setCallbackUrl (callbackUrl:String):void 
		{
			if (Capabilities.manufacturer.indexOf("Android") != -1)
			{
				platformConf["CallbackUrl"] = callbackUrl;
			}
			else if (Capabilities.manufacturer.indexOf("iOS") != -1)
			{
				platformConf["callback_url"] = callbackUrl;
			}
		}			
	}
}
package cn.sharesdk.ane.platform
{
	public class Tumblr extends DevInfo
	{					
		public function setOAuthConsumerKey (oAuthConsumerKey:String):void 
		{
			platformConf["OAuthConsumerKey"] = oAuthConsumerKey;
		}
		public function setSecretKey (secretKey:String):void 
		{
			platformConf["SecretKey"] = secretKey;
		}
		public function setCallbackUrl (callbackUrl:String):void 
		{
			platformConf["CallbackUrl"] = callbackUrl;
		}			
	}
}
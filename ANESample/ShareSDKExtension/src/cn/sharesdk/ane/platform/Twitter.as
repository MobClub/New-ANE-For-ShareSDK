package cn.sharesdk.ane.platform
{
	public class Twitter extends DevInfo
	{					
		public function setConsumerKey (consumerKey:String):void 
		{
			platformConf["ConsumerKey"] = consumerKey;
		}
		public function setConsumerSecret (consumerSecret:String):void 
		{
			platformConf["ConsumerSecret"] = consumerSecret;
		}
		public function setCallbackUrl (callbackUrl:String):void 
		{
			platformConf["CallbackUrl"] = callbackUrl;
		}			
	}
}
package cn.sharesdk.ane.platform
{
	public class Facebook extends DevInfo
	{					
		public function setConsumerKey (consumerKey:String):void 
		{
			platformConf["ConsumerKey"] = consumerKey;
		}
		public function setConsumerSecret (consumerSecret:String):void 
		{
			platformConf["ConsumerSecret"] = consumerSecret;
		}
		public function setRedirectUrl (redirectUrl:String):void 
		{
			platformConf["RedirectUrl"] = redirectUrl;
		}	
	}
}
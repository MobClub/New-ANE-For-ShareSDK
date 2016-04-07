package cn.sharesdk.ane.platform
{
	public class Evernote extends DevInfo
	{					
		public function setHostType (hostType:String):void 
		{
			platformConf["HostType"] = hostType;
		}
		public function setConsumerKey (consumerKey:String):void 
		{
			platformConf["ConsumerKey"] = consumerKey;
		}
		public function setConsumerSecret (consumerSecret:String):void 
		{
			platformConf["ConsumerSecret"] = consumerSecret;
		}		
		public function setShareByAppClient (shareByAppClient:String):void 
		{
			platformConf["ShareByAppClient"] = shareByAppClient;
		}
	}
}
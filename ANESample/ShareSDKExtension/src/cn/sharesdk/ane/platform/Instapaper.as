package cn.sharesdk.ane.platform
{
	public class Instapaper extends DevInfo
	{					
		public function setConsumerKey (consumerKey:String):void 
		{
			platformConf["ConsumerKey"] = consumerKey;
		}
		public function setConsumerSecret (consumerSecret:String):void 
		{
			platformConf["ConsumerSecret"] = consumerSecret;
		}		
	}
}
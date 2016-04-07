package cn.sharesdk.ane.platform
{
	public class Pocket extends DevInfo
	{					
		public function setConsumerKey (consumerKey:String):void 
		{
			platformConf["ConsumerKey"] = consumerKey;
		}		
	}
}
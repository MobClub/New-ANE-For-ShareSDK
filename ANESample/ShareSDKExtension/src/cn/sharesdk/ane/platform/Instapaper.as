package cn.sharesdk.ane.platform
{
	import flash.system.Capabilities;
	public class Instapaper extends DevInfo
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
	}
}
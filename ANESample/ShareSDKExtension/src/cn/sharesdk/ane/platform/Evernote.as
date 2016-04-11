package cn.sharesdk.ane.platform
{
	import flash.system.Capabilities;
	public class Evernote extends DevInfo
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
		//Android Only
		public function setHostType (hostType:String):void 
		{
			platformConf["HostType"] = hostType;
		}
		//Android Only
		public function setShareByAppClient (shareByAppClient:String):void 
		{
			platformConf["ShareByAppClient"] = shareByAppClient;	
		}
		//iOS Only
		public function setIsSandboxMode (sandbox:Boolean):void
		{
			platformConf["sandbox"] = sandbox;
		}	
	}
}
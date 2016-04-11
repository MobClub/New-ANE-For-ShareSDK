package cn.sharesdk.ane.platform
{
	import flash.system.Capabilities;
	public class Pinterest extends DevInfo
	{					
		public function setClientId (clientId:String):void 
		{
			
			if (Capabilities.manufacturer.indexOf("Android") != -1)
			{
				platformConf["ClientId"] = clientId;
			}
			else if (Capabilities.manufacturer.indexOf("iOS") != -1)
			{
				platformConf["client_id"] = clientId;
			}
			
		}
	}
}
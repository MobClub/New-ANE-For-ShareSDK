package cn.sharesdk.ane.platform
{
	import flash.system.Capabilities;
	public class Alipay extends DevInfo
	{				
		public function setAppId (appId:String):void 
		{
			if (Capabilities.manufacturer.indexOf("Android") != -1)
			{
				platformConf["AppId"] = appId;
			}
			else if (Capabilities.manufacturer.indexOf("iOS") != -1)
			{
				platformConf["app_id"] = appId;
			}	
		}					
	}
}
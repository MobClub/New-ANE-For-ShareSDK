package cn.sharesdk.ane.platform
{
	import flash.system.Capabilities;
	public class MeiPai extends DevInfo
	{				
		public function setAppKey (appId:String):void 
		{
			if (Capabilities.manufacturer.indexOf("Android") != -1)
			{
				platformConf["AppKey"] = appId;
			}
			else if (Capabilities.manufacturer.indexOf("iOS") != -1)
			{
				platformConf["app_key"] = appId;
			}	
		}					
	}
}


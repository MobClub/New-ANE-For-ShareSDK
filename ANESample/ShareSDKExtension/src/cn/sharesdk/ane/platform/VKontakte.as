package cn.sharesdk.ane.platform
{
	import flash.system.Capabilities;
	public class VKontakte extends DevInfo
	{					
		public function setApplicationId (applicationId:String):void 
		{
			
			if (Capabilities.manufacturer.indexOf("Android") != -1)
			{
				platformConf["ApplicationId"] = applicationId;
			}
			else if (Capabilities.manufacturer.indexOf("iOS") != -1)
			{
				platformConf["ApplicationId"] = applicationId;
			}
		}
		//iOS Only
		public function setSecretKey (secretKey:String):void
		{
			platformConf["secret_key"] = secretKey;
		}
		//iOS Only
		public function setAuthType (authType:String):void
		{
			platformConf["auth_type"] = authType;
		}
	}
}
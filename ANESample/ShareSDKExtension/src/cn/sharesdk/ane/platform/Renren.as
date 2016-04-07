package cn.sharesdk.ane.platform
{
	public class Renren extends DevInfo
	{					
		public function setAppId (appId:String):void 
		{
			platformConf["AppId"] = appId;
		}
		public function setApiKey (apiKey:String):void 
		{
			platformConf["ApiKey"] = apiKey;
		}
		public function setSecretKey (secretKey:String):void 
		{
			platformConf["SecretKey"] = secretKey;
		}		
	}
}
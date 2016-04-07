package cn.sharesdk.ane.platform
{
	public class LinkedIn extends DevInfo
	{					
		public function setApiKey (apiKey:String):void 
		{
			platformConf["ApiKey"] = apiKey;
		}
		public function setSecretKey (secretKey:String):void 
		{
			platformConf["SecretKey"] = secretKey;
		}
		public function setRedirectUrl (redirectUrl:String):void 
		{
			platformConf["RedirectUrl"] = redirectUrl;
		}	
	}
}
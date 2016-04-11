package cn.sharesdk.ane.platform
{
	import flash.system.Capabilities;
	public class LinkedIn extends DevInfo
	{					
		public function setApiKey (apiKey:String):void 
		{
			if (Capabilities.manufacturer.indexOf("Android") != -1)
			{
				platformConf["ApiKey"] = apiKey;
			}
			else if (Capabilities.manufacturer.indexOf("iOS") != -1)
			{
				platformConf["api_key"] = apiKey;
			}
		}
		public function setSecretKey (secretKey:String):void 
		{
			if (Capabilities.manufacturer.indexOf("Android") != -1)
			{
				platformConf["SecretKey"] = secretKey;
			}
			else if (Capabilities.manufacturer.indexOf("iOS") != -1)
			{
				platformConf["secret_key"] = secretKey;
			}
		}
		public function setRedirectUrl (redirectUrl:String):void 
		{
			if (Capabilities.manufacturer.indexOf("Android") != -1)
			{
				platformConf["RedirectUrl"] = redirectUrl;
			}
			else if (Capabilities.manufacturer.indexOf("iOS") != -1)
			{
				platformConf["redirect_url"] = redirectUrl;
			}
		}	
	}
}
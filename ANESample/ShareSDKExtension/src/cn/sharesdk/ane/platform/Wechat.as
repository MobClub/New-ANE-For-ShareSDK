package cn.sharesdk.ane.platform
{
	public class Wechat extends DevInfo
	{					
		public function setAppId (appId:String):void 
		{
			platformConf["AppId"] = appId;
		}
		public function setAppSecret (appSecret:String):void 
		{
			platformConf["AppSecret"] = appSecret;
		}
		public function setBypassApproval (bypassApproval:Boolean):void 
		{
			platformConf["BypassApproval"] = bypassApproval;
		}
	}
}
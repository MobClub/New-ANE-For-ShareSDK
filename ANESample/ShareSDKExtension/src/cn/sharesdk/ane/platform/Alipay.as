package cn.sharesdk.ane.platform
{
	public class Alipay extends DevInfo
	{				
		public function setAppId (appId:String):void 
		{
			platformConf["AppId"] = appId;
		}					
	}
}
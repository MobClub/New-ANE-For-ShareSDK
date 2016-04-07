package cn.sharesdk.ane.platform
{
	public class YiXin extends DevInfo
	{					
		public function setAppId (appId:String):void 
		{
			platformConf["AppId"] = appId;
		}		
		public function setBypassApproval (bypassApproval:Boolean):void 
		{
			platformConf["BypassApproval"] = bypassApproval;
		}
	}
}
public class V11_callComarchImport {

    public static List<V11_PartnerExportData.Partner> importPartners(WebserviceLog__c wsLog)
    {

        V11_PartnerExport.ExportRequest exportRequest = new V11_PartnerExport.ExportRequest();
        V11_PartnerExport.Export_x exportAccounts = new  V11_PartnerExport.Export_x();
        List<V11_PartnerExportData.Partner> returnedAccounts = new List<V11_PartnerExportData.Partner>();        

        //exportRequest.timeout_x = 120000;
        exportAccounts.timeout_x = 120000;
        exportAccounts.inputHttpHeaders_x = new Map<String, String>();
        String userAuth = V11_helperClass.getPassword('Comarch');
        exportAccounts.inputHttpHeaders_x.put('Authorization', 'Basic '+userAuth);
        exportAccounts.endpoint_x = V11_helperClass.getEndpoint('PartnerExport');

        List<InboundCallState__c> inboundCallState = [SELECT Id, TimeStamp__c, Custom_Call__c,Custom_OQL__c FROM InboundCallState__c WHERE Object__c ='Account' AND System__c ='Comarch'];
        Datetime timeStamp = inboundCallState.get(0).TimeStamp__c;
        String timeString = '(\'CET\',' +timeStamp.year()+','+timeStamp.month()+','+timeStamp.day()+','+timeStamp.hour()+','+timeStamp.minute()+','+timeStamp.second()+',0)';       
        exportRequest.dynamicOQLSearch = 'SELECT o:guid FROM com.cisag.app.general.obj.Partner o WHERE (o:updateInfo.updateTime > TOTIMESTAMP' + timeString +' OR o:updateInfo.createTime > TOTIMESTAMP' + timeString + ')AND o:human = false AND NOT(o:updateInfo.updateUser = toguid(\'16C063FBB14230109CABC0A850270000\'))';
        if(inboundCallState.get(0).Custom_Call__c){
            exportRequest.dynamicOQLSearch = inboundCallState.get(0).Custom_OQL__c;
        }
        exportRequest.processLogLevel ='ENABLED';

        V11_PartnerExport.ExportResponse exportResponse = new V11_PartnerExport.ExportResponse();
        wsLog.Endpoint__c = exportAccounts.endpoint_x;
        wsLog.TimeStamp__c = Datetime.now();
        wsLog.Type__c = 'Inbound';

        try{                  
            exportResponse = exportAccounts.export_x(exportRequest);
        }catch(Exception e){
            wsLog.Status__c = 'Error';
            wsLog.HttpRepsonse__c = e.getMessage();
            insert wsLog;
        }        

        if(wsLog.Status__c != 'Error')
        {
            wsLog.Status__c = 'Success';
            insert wsLog;
            inboundCallState.get(0).TimeStamp__c = Datetime.now();
            Update inboundCallState;
            if(exportResponse.result.exportedObjectCount>0)
            {
                returnedAccounts = exportResponse.result.exportData.Partner;
            }
        }
        
        return returnedAccounts;

    }
    public static List<V11_ProductExportData.Item> importProducts(WebserviceLog__c wsLog)
    {

        V11_ProductExport.ExportRequest exportRequest = new V11_ProductExport.ExportRequest();
        V11_ProductExport.Export_x exportProducts = new  V11_ProductExport.Export_x();
        List<V11_ProductExportData.Item> returnedProducts = new List<V11_ProductExportData.Item>();

        exportProducts.timeout_x = 120000;
        exportProducts.inputHttpHeaders_x = new Map<String, String>();
        String userAuth = V11_helperClass.getPassword('Comarch');
        exportProducts.inputHttpHeaders_x.put('Authorization', 'Basic '+userAuth);
        exportProducts.endpoint_x = V11_helperClass.getEndpoint('ProductExport');

        List<InboundCallState__c> inboundCallState = [SELECT Id, TimeStamp__c,Custom_Call__c,Custom_OQL__c FROM InboundCallState__c WHERE Object__c ='Product' AND System__c ='Comarch'];
        Datetime timeStamp = inboundCallState.get(0).TimeStamp__c;
        String timeString = '(\'CET\',' +timeStamp.year()+','+timeStamp.month()+','+timeStamp.day()+','+timeStamp.hour()+','+timeStamp.minute()+','+timeStamp.second()+',0)';       
        exportRequest.dynamicOQLSearch = 'SELECT o:guid FROM com.cisag.app.general.obj.Item o WHERE o:updateInfo.updateTime > TOTIMESTAMP' + timeString +' OR o:updateInfo.createTime > TOTIMESTAMP' + timeString;
        if(inboundCallState.get(0).Custom_Call__c){
            exportRequest.dynamicOQLSearch = inboundCallState.get(0).Custom_OQL__c;
        }
        exportRequest.processLogLevel ='ENABLED';

        V11_ProductExport.ExportResponse exportResponse = new V11_ProductExport.ExportResponse();
        wsLog.Endpoint__c = exportProducts.endpoint_x;
        wsLog.TimeStamp__c = Datetime.now();
        wsLog.Type__c = 'Inbound';

        try{                  
            exportResponse = exportProducts.export_x(exportRequest);
        }catch(Exception e){
            wsLog.Status__c = 'Error';
            wsLog.HttpRepsonse__c = e.getMessage();
            insert wsLog;
        }        

        if(wsLog.Status__c != 'Error')
        {
            wsLog.Status__c = 'Success';
            insert wsLog;
            inboundCallState.get(0).TimeStamp__c = Datetime.now();
            Update inboundCallState;
            if(exportResponse.result.exportedObjectCount>0)
            {
                returnedProducts = exportResponse.result.exportData.Item;
            }
        }
        
        return returnedProducts;

    }

    public static List<V11_OrderExportData.SalesOrder> importOrders(WebserviceLog__c wsLog , string orderIds)
    {

        V11_OrderExport.ExportRequest exportRequest = new V11_OrderExport.ExportRequest();
        V11_OrderExport.Export_x exportProducts = new  V11_OrderExport.Export_x();
        List<V11_OrderExportData.SalesOrder> returnedProducts = new List<V11_OrderExportData.SalesOrder>();

        exportProducts.timeout_x = 120000;
        exportProducts.inputHttpHeaders_x = new Map<String, String>();
        String userAuth = V11_helperClass.getPassword('Comarch');
        exportProducts.inputHttpHeaders_x.put('Authorization', 'Basic '+userAuth);
        exportProducts.endpoint_x = V11_helperClass.getEndpoint('OrderExport');

        List<InboundCallState__c> inboundCallState = [SELECT Id, TimeStamp__c, Custom_Call__c,Custom_OQL__c FROM InboundCallState__c WHERE Object__c ='Order' AND System__c ='Comarch'];
        Datetime timeStamp = inboundCallState.get(0).TimeStamp__c;
        String timeString = '(\'CET\',' +timeStamp.year()+','+timeStamp.month()+','+timeStamp.day()+','+timeStamp.hour()+','+timeStamp.minute()+','+timeStamp.second()+',0)';       
        exportRequest.dynamicOQLSearch = 'SELECT o:guid FROM com.cisag.app.sales.obj.SalesOrder o WHERE o:number in('+ orderIds +')';
        exportRequest.processLogLevel ='ENABLED';

        V11_OrderExport.ExportResponse exportResponse = new V11_OrderExport.ExportResponse();
        wsLog.Endpoint__c = exportProducts.endpoint_x;
        wsLog.TimeStamp__c = Datetime.now();
        wsLog.Type__c = 'Inbound';

        try{                  
            exportResponse = exportProducts.export_x(exportRequest);
        }catch(Exception e){
            wsLog.Status__c = 'Error';
            wsLog.HttpRepsonse__c = e.getMessage()+'\n'+orderIds;

            insert wsLog;
        }        

        if(wsLog.Status__c != 'Error')
        {
            wsLog.Status__c = 'Success';
            insert wsLog;
            if(exportResponse.result.exportedObjectCount>0)
            {
                returnedProducts = exportResponse.result.exportData.SalesOrder;
            }
        }
        
        return returnedProducts;

    }

    public static List<String> getOrderIds(WebserviceLog__c wsLog)
    {
        List<String> orderIds = new List<String>();
        V11_OrderIDExport.ExportRequest exportRequest = new V11_OrderIDExport.ExportRequest();
        V11_OrderIDExport.Export_x exportProducts = new  V11_OrderIDExport.Export_x();

        exportProducts.timeout_x = 120000;
        exportProducts.inputHttpHeaders_x = new Map<String, String>();
        String userAuth = V11_helperClass.getPassword('Comarch');
        exportProducts.inputHttpHeaders_x.put('Authorization', 'Basic '+userAuth);
        exportProducts.endpoint_x = V11_helperClass.getEndpoint('OrderIDExport');

        List<InboundCallState__c> inboundCallState = [SELECT Id, TimeStamp__c, Custom_Call__c, Custom_OQL__c FROM InboundCallState__c WHERE Object__c ='Order' AND System__c ='Comarch'];
        Datetime timeStamp = inboundCallState.get(0).TimeStamp__c;
        String timeString = '(\'CET\',' +timeStamp.year()+','+timeStamp.month()+','+timeStamp.day()+','+timeStamp.hour()+','+timeStamp.minute()+','+timeStamp.second()+',0)';       
        exportRequest.dynamicOQLSearch = 'SELECT o:guid FROM com.cisag.app.sales.obj.SalesOrder o WHERE o:updateInfo.updateTime > TOTIMESTAMP' + timeString +' OR o:updateInfo.createTime > TOTIMESTAMP' + timeString;
        
        if(inboundCallState.get(0).Custom_Call__c){
            exportRequest.dynamicOQLSearch = inboundCallState.get(0).Custom_OQL__c;
        }
                
        exportRequest.processLogLevel ='ENABLED';

        V11_OrderIDExport.ExportResponse exportResponse = new V11_OrderIDExport.ExportResponse();
        wsLog.Endpoint__c = exportProducts.endpoint_x;
        wsLog.TimeStamp__c = Datetime.now();
        wsLog.Type__c = 'Inbound';

        try{                  
            exportResponse = exportProducts.export_x(exportRequest);
        }catch(Exception e){
            wsLog.Status__c = 'Error';
            wsLog.HttpRepsonse__c = e.getMessage();
            insert wsLog;
        }        

        if(wsLog.Status__c != 'Error')
        {
            wsLog.Status__c = 'Success';
            inboundCallState.get(0).TimeStamp__c = Datetime.now();
            Update inboundCallState;
            wsLog.HttpRepsonse__c = 'Order Ids: ';
            if(exportResponse.result.exportedObjectCount>0)
            {
                for(V11_OrderIDExportData.SalesOrder ids: exportResponse.result.exportData.SalesOrder){
                    orderIds.add(ids.number_x);
                    wsLog.HttpRepsonse__c = wsLog.HttpRepsonse__c + ids.number_x + ', ';
                }
            }
            
            insert wsLog;
        }

        
        return orderIds;

    }

    public static List<V11_QuoteExportData.CustomerProposal> importQuotes(WebserviceLog__c wsLog)
    {

        V11_QuoteExport.ExportRequest exportRequest = new V11_QuoteExport.ExportRequest();
        V11_QuoteExport.Export_x exportQuotes = new  V11_QuoteExport.Export_x();
        List<V11_QuoteExportData.CustomerProposal> returnedProducts = new List<V11_QuoteExportData.CustomerProposal>();

        exportQuotes.timeout_x = 120000;
        exportQuotes.inputHttpHeaders_x = new Map<String, String>();
        String userAuth = V11_helperClass.getPassword('Comarch');
        exportQuotes.inputHttpHeaders_x.put('Authorization', 'Basic '+userAuth);
        exportQuotes.endpoint_x = V11_helperClass.getEndpoint('QuoteExport');

        List<InboundCallState__c> inboundCallState = [SELECT Id, TimeStamp__c, Custom_Call__c,Custom_OQL__c FROM InboundCallState__c WHERE Object__c ='Quote' AND System__c ='Comarch'];
        Datetime timeStamp = inboundCallState.get(0).TimeStamp__c;
        String timeString = '(\'CET\',' +timeStamp.year()+','+timeStamp.month()+','+timeStamp.day()+','+timeStamp.hour()+','+timeStamp.minute()+','+timeStamp.second()+',0)';       
        exportRequest.dynamicOQLSearch = 'SELECT o:guid FROM com.cisag.app.sales.obj.CustomerProposal o WHERE o:updateInfo.updateTime > TOTIMESTAMP' + timeString +' OR o:updateInfo.createTime > TOTIMESTAMP' + timeString;
        if(inboundCallState.get(0).Custom_Call__c){
            exportRequest.dynamicOQLSearch = inboundCallState.get(0).Custom_OQL__c;
        }
        exportRequest.processLogLevel ='ENABLED';

        V11_QuoteExport.ExportResponse exportResponse = new V11_QuoteExport.ExportResponse();
        wsLog.Endpoint__c = exportQuotes.endpoint_x;
        wsLog.TimeStamp__c = Datetime.now();
        wsLog.Type__c = 'Inbound';

        try{                  
            exportResponse = exportQuotes.export_x(exportRequest);
        }catch(Exception e){
            wsLog.Status__c = 'Error';
            wsLog.HttpRepsonse__c = e.getMessage();
            insert wsLog;
        }        

        if(wsLog.Status__c != 'Error')
        {
            wsLog.Status__c = 'Success';
            insert wsLog;
            inboundCallState.get(0).TimeStamp__c = Datetime.now();
            Update inboundCallState;
            if(exportResponse.result.exportedObjectCount>0)
            {
                returnedProducts = exportResponse.result.exportData.CustomerProposal;
            }
        }
        
        return returnedProducts;

    }
    public static List<V11_EntityExtensionExportData.EntityExtensionHierarchy> importEntityExtension(WebserviceLog__c wsLog)
    {

        V11_EntityExtensionExport.ExportRequest exportRequest = new V11_EntityExtensionExport.ExportRequest();
        V11_EntityExtensionExport.Export_x exportEntityExtensions = new  V11_EntityExtensionExport.Export_x();
        List<V11_EntityExtensionExportData.EntityExtensionHierarchy> returnedEntityExtensions = new List<V11_EntityExtensionExportData.EntityExtensionHierarchy>();        

        exportEntityExtensions.timeout_x = 120000;
        exportEntityExtensions.inputHttpHeaders_x = new Map<String, String>();
        String userAuth = V11_helperClass.getPassword('Comarch');
        exportEntityExtensions.inputHttpHeaders_x.put('Authorization', 'Basic '+userAuth);
        exportEntityExtensions.endpoint_x = V11_helperClass.getEndpoint('EntityExtensionExport');

        List<InboundCallState__c> inboundCallState = [SELECT Id, TimeStamp__c, Custom_Call__c,Custom_OQL__c FROM InboundCallState__c WHERE Object__c ='Entity Extension' AND System__c ='Comarch'];
        Datetime timeStamp = inboundCallState.get(0).TimeStamp__c;
        String timeString = '(\'CET\',' +timeStamp.year()+','+timeStamp.month()+','+timeStamp.day()+','+timeStamp.hour()+','+timeStamp.minute()+','+timeStamp.second()+',0)';       
        exportRequest.dynamicOQLSearch = 'SELECT o:guid FROM com.cisag.app.general.extension.obj.EntityExtensionHierarchy o WHERE o:updateInfo.updateTime > TOTIMESTAMP' + timeString +' OR o:updateInfo.createTime > TOTIMESTAMP' + timeString ;
        if(inboundCallState.get(0).Custom_Call__c){
            exportRequest.dynamicOQLSearch = inboundCallState.get(0).Custom_OQL__c;
        }
        exportRequest.processLogLevel ='ENABLED';

        V11_EntityExtensionExport.ExportResponse exportResponse = new V11_EntityExtensionExport.ExportResponse();
        wsLog.Endpoint__c = exportEntityExtensions.endpoint_x;
        wsLog.TimeStamp__c = Datetime.now();
        wsLog.Type__c = 'Inbound';

        try{                  
            exportResponse = exportEntityExtensions.export_x(exportRequest);
        }catch(Exception e){
            wsLog.Status__c = 'Error';
            wsLog.HttpRepsonse__c = e.getMessage();
            insert wsLog;
        }        

        if(wsLog.Status__c != 'Error')
        {
            wsLog.Status__c = 'Success';
            insert wsLog;
            inboundCallState.get(0).TimeStamp__c = Datetime.now();
            Update inboundCallState;
            if(exportResponse.result.exportedObjectCount>0)
            {
                returnedEntityExtensions = exportResponse.result.exportData.EntityExtensionHierarchy;
            }
        }
        
        return returnedEntityExtensions;

    }
}
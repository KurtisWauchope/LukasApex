public class V11_importFailedCalls {

    @AuraEnabled(cacheable=false)
    public static void importFailedCall(string ibcID){

        InboundCall__c ibc = [SELECT Data__c,Object__c,Data_2__c,Data_3__c,Data_4__c FROM InboundCall__c WHERE Id=:ibcID];
        String data = ibc.Data__c + ibc.Data_2__c + ibc.Data_3__c + ibc.Data_4__c;
        if(ibc.Object__c == 'Account'){
            importAccount(data);
        }else if(ibc.Object__c == 'Order'){
            importOrder(data);
        }else if(ibc.Object__c == 'Quote'){
            importQuote(data);
        }else if(ibc.Object__c == 'Product'){
            importProduct(data);
        }else if(ibc.Object__c == 'Entity Extension'){
            importEntityExtension(data);
        }

    }

    public static void importAccount(string data){

        V11_PartnerExportData.Partner ped = (V11_PartnerExportData.Partner) System.JSON.deserialize(data, V11_PartnerExportData.Partner.class);
        List<V11_PartnerExportData.Partner> dataList = new List<V11_PartnerExportData.Partner>();
        dataList.add(ped);
        V11_batchAccountUpdate batch = new V11_batchAccountUpdate(dataList);
        Database.executeBatch(batch);
    }
    
    public static void importOrder(string data){

        V11_OrderExportData.SalesOrder ped = (V11_OrderExportData.SalesOrder) System.JSON.deserialize(data, V11_OrderExportData.SalesOrder.class);
        List<V11_OrderExportData.SalesOrder> dataList = new List<V11_OrderExportData.SalesOrder>();
        dataList.add(ped);
        V11_batchOrderUpsert batch = new V11_batchOrderUpsert(dataList);
        Database.executeBatch(batch);
    }
    
    public static void importQuote(string data){

        V11_QuoteExportData.CustomerProposal ped = (V11_QuoteExportData.CustomerProposal) System.JSON.deserialize(data, V11_QuoteExportData.CustomerProposal.class);
        List<V11_QuoteExportData.CustomerProposal> dataList = new List<V11_QuoteExportData.CustomerProposal>();
        dataList.add(ped);
        V11_batchQuoteUpsert batch = new V11_batchQuoteUpsert(dataList);
        Database.executeBatch(batch);
    }

    public static void importProduct(string data){

        V11_ProductExportData.Item ped = (V11_ProductExportData.Item) System.JSON.deserialize(data, V11_ProductExportData.Item.class);
        List<V11_ProductExportData.Item> dataList = new List<V11_ProductExportData.Item>();
        dataList.add(ped);
        V11_batchProductsUpsert batch = new V11_batchProductsUpsert(dataList);
        Database.executeBatch(batch);
    }
    public static void importEntityExtension(string data){

        V11_EntityExtensionExportData.EntityExtensionHierarchy ped = (V11_EntityExtensionExportData.EntityExtensionHierarchy) System.JSON.deserialize(data, V11_EntityExtensionExportData.EntityExtensionHierarchy.class);
        List<V11_EntityExtensionExportData.EntityExtensionHierarchy> dataList = new List<V11_EntityExtensionExportData.EntityExtensionHierarchy>();
        dataList.add(ped);
        V11_batchEntityExtensionUpsert batch = new V11_batchEntityExtensionUpsert(dataList);
        Database.executeBatch(batch);
    }

}
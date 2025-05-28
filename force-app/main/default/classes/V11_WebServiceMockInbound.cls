@istest
public class V11_WebServiceMockInbound implements WebServiceMock{

    String object_x;

    public V11_WebServiceMockInbound(String object_x){
        this.object_x = object_x;
    }
    public V11_WebServiceMockInbound(){}

    public void doInvoke(
        Object stub,
        Object request,
        Map<String, Object> response,
        String endpoint,
        String soapAction,
        String requestName,
        String responseNS,
        String responseName,
        String responseType) {

            if(object_x == 'Partner'){

                V11_PartnerExportData.Partner partner = new V11_PartnerExportData.Partner();
                V11_PartnerExport.exportResponse_element responseElement = new V11_PartnerExport.exportResponse_element();
                responseElement.exportReturn.result.exportData.Partner.add(partner);
                response.put('response_x', responseElement);

            }else if(stub instanceOf V11_EntityExtensionExport.Export_x){

                V11_EntityExtensionExportData.EntityExtensionHierarchy entity = new V11_EntityExtensionExportData.EntityExtensionHierarchy();
                V11_EntityExtensionExport.exportResponse_element responseElement = new V11_EntityExtensionExport.exportResponse_element();
                responseElement.exportReturn.result.exportData.EntityExtensionHierarchy.add(entity);
                response.put('response_x',responseElement);

            }else if( stub instanceOf V11_OrderExport.Export_x){
                V11_OrderExportData.SalesOrder order = new V11_OrderExportData.SalesOrder();
                V11_OrderExport.exportResponse_element responseElement = new V11_OrderExport.exportResponse_element();
                responseElement.exportReturn.result.exportData.SalesOrder.add(order);
                response.put('response_x',responseElement );

            }else if (stub instanceOf V11_ProductExport.Export_x){
                V11_ProductExportData.Item product = new V11_ProductExportData.Item();
                V11_ProductExport.exportResponse_element responseElement = new V11_ProductExport.exportResponse_element();
                responseElement.exportReturn.result.exportData.Item.add(product);
                response.put('response_x',responseElement );

            }else{
                
                V11_PartnerExportData.Partner partner = new V11_PartnerExportData.Partner();
                V11_PartnerExport.exportResponse_element responseElement = new V11_PartnerExport.exportResponse_element();
                responseElement.exportReturn.result.exportData.Partner.add(partner);
                response.put('response_x', responseElement);
            }
    }
}
@istest
public class V11_InboundTest {

    @TestSetup
    static void makeData(){
        Test.setMock(HttpCalloutMock.class, new V11_WebServiceMock());

        List<InboundCallState__c> ibcs = new List<InboundCallState__c>();

        InboundCallState__c ibcsA = new InboundCallState__c();
        ibcsA.TimeStamp__c = Datetime.now();
        ibcsA.Object__c = 'Account';
        ibcsA.System__c = 'Comarch';
		ibcsA.Custom_Call__c = true;
		ibcsA.Custom_OQL__c = '';
        ibcs.add(ibcsA);

        InboundCallState__c ibcsEE = new InboundCallState__c();
        ibcsEE.TimeStamp__c = Datetime.now();
        ibcsEE.Object__c = 'Entity Extension';
        ibcsEE.System__c = 'Comarch';
		ibcsEE.Custom_Call__c = true;
		ibcsEE.Custom_OQL__c = '';
        ibcs.add(ibcsEE);

        InboundCallState__c ibcsP = new InboundCallState__c();
        ibcsP.TimeStamp__c = Datetime.now();
        ibcsP.Object__c = 'Product';
        ibcsP.System__c = 'Comarch';
		ibcsP.Custom_Call__c = true;
		ibcsP.Custom_OQL__c = '';
        ibcs.add(ibcsP);
        
        InboundCallState__c ibcsQ = new InboundCallState__c();
        ibcsQ.TimeStamp__c = Datetime.now();
        ibcsQ.Object__c = 'Quote';
        ibcsQ.System__c = 'Comarch';
		ibcsQ.Custom_Call__c = true;
		ibcsQ.Custom_OQL__c = '';
        ibcs.add(ibcsQ);

        InboundCallState__c ibcsO = new InboundCallState__c();
        ibcsO.TimeStamp__c = Datetime.now();
        ibcsO.Object__c = 'Order';
        ibcsO.System__c = 'Comarch';
		ibcsO.Custom_Call__c = true;
		ibcsO.Custom_OQL__c = '';
        ibcs.add(ibcsO);

        insert ibcs;


        Account_Template__c temp = new Account_Template__c();
        temp.Key__c ='1000';
        insert temp;

        List<Account> accs = new List<Account>();

        Account acc = new Account();
        acc.Name = 'Test';
        acc.Account_Template__c = temp.Id;
        acc.ComarchAccountNumber__c = '20000007';
        acc.BillingStreet = 'Test Street 1';
        acc.BillingCity = 'Testtown';
        acc.BillingPostalCode = '12345';
        acc.BillingCountryCode = 'DE';
        accs.add(acc);


        insert accs;

        List<Contact> contacts = new List<Contact>();
        Contact c = new Contact();

        c.ExternalComarchContactId__c = '40000001';
        c.AccountId = acc.Id;
        c.Salutation = 'Ms.';
        c.Title__c = 'ArchitektIn';
        c.LastName = 'Test';
        c.FirstName = 'hm';
        c.MiddleName = 'Lol';
        c.MobilePhone = '+491234';
        c.Phone = '+491234';
        c.Email = 'test@test.com';
        c.Language__c = 'de';

        contacts.add(c);

        insert contacts;

        BuildingProject__c bp = new BuildingProject__c();

        bp.Name='Test Schnitti';
        bp.Amount__c=12300000;
        bp.ProjectSupported__c=true;
        bp.AwardDate__c=Date.today()+10;
        bp.BuildingType__c='Culture';
        bp.ConstructionEndPlanned__c=Date.today()+10;
        bp.DateOfServiceSpecification__c=Date.today()+10;
        //bp.InternalNote__c='dfgdfg';
        bp.ExternalNote__c='fghfgh';
        bp.LeadSource__c='Construction site';
        bp.Material__c='Aluminium';
        bp.NonDisclosureAgreement__c=true;
        bp.OrderEntry__c=Date.today()+10;
        bp.ProjectAddress__Street__s='Pettenkoferstraße 13';
        bp.ProjectAddress__City__s='Berlin';
        bp.ProjectAddress__PostalCode__s='10247';
        bp.ProjectAddress__CountryCode__s='DE';
        bp.ProjectPreview__c=true;
        bp.ProjectPriority__c='Prio A';
        bp.Stage__c='Award System house';
        bp.SubmissionDate__c=Date.today()+10;
        bp.TenderType__c='Competitive bidding';
        bp.TotalSize__c=123;
        bp.Type__c='New construction';
        bp.ConstructionStart__c=Date.today()+10;
        bp.RAICOSpecification__c=true;
        bp.Allocationfabricator__r= acc;
        bp.ComarchBuildingProjectNumber__c='VS00000127';
        bp.BidderListSent__c=true;
        bp.ComarchSyncStatus__c='Success';
        bp.Service_specifications_sent__c=false;
        bp.Probability__c='0';

        insert bp;

        Product2 prod = new Product2(ExternalId__c ='123');

        prod.Name = 'test';

        insert prod;

        List<InboundCall__c> ibc = new List<InboundCall__c>();

        InboundCall__c ibcAcc = new InboundCall__c();

        ibcAcc.Status__c = 'Error';
        ibcAcc.Outdated__c = false;
        ibcAcc.Object__c = 'Account';
        ibcAcc.Object_ID__C = '20000007';
        ibc.add(ibcAcc);

        InboundCall__c ibcE = new InboundCall__c();

        ibcE.Status__c = 'Error';
        ibcE.Outdated__c = false;
        ibcE.Object__c = 'Entity Extension';
        ibcE.Object_ID__C = '56D00000-8872-102D-B2-5A-00005A50A8C7';
        ibc.add(ibcE);

        InboundCall__c ibcO = new InboundCall__c();

        ibcO.Status__c = 'Error';
        ibcO.Outdated__c = false;
        ibcO.Object__c = 'Order';
        ibcO.Object_ID__C = '221A600A-9E50-1030-94-20-0000100A0A0A';
        ibc.add(ibcO);


        insert ibc;

        
    }

	static testmethod void failedCalls(){
		Test.startTest();
		
		V11_importFailedCalls.importAccount('{"person":null,"PartnerRelations":null,"PartnerAccountingData":null,"OrganizationalUnitPartner":[{"OrganizationalUnit":{"code":"900000"},"customerStatus":"RELEASED"},{"OrganizationalUnit":{"code":"915000"},"customerStatus":"RELEASED"},{"OrganizationalUnit":{"code":"940000"},"customerStatus":"RELEASED"},{"OrganizationalUnit":{"code":"953000"},"customerStatus":"RELEASED"},{"OrganizationalUnit":{"code":"930000"},"customerStatus":"RELEASED"},{"OrganizationalUnit":{"code":"914000"},"customerStatus":"RELEASED"},{"OrganizationalUnit":{"code":"933000"},"customerStatus":"RELEASED"},{"OrganizationalUnit":{"code":"910000"},"customerStatus":"RELEASED"},{"OrganizationalUnit":{"code":"950000"},"customerStatus":"RELEASED"},{"OrganizationalUnit":{"code":"920000"},"customerStatus":"RELEASED"},{"OrganizationalUnit":{"code":"923000"},"customerStatus":"RELEASED"},{"OrganizationalUnit":{"code":"913000"},"customerStatus":"RELEASED"},{"OrganizationalUnit":{"code":"943000"},"customerStatus":"RELEASED"}],"organizationalUnit":{"type_x":"COMPANY","name":{"input":null,"index_att_info":["index"],"index":2}},"number_x":"20000017","name":"das reicht","MaintainingOrganization":{"number_x":"910000"},"Language":{"isoCode":"de"},"human":false,"EntityExtension":{"SPERRGRUND":{"value":"0"},"SALESFORCEID":{"value":"0012600001oYcT8AAK"}},"Employee":null,"Customer":null,"CommunicationData":null,"addressData":{"street":"Konrad-Adenauer-Allee 34","postalCode":"93051","Country":{"isoCode":"DE"},"city":"Regensburg"}}');
		V11_importFailedCalls.importOrder('{"totalValues":{"netWeight":{"Uom":{"code":"kg"},"amount":"0"},"netValueDomestic":{"Currency1":{"isoCode":"EUR"},"amount1":"0"},"netValue":{"Currency_x":{"isoCode":"EUR"},"amount":"0"},"grossWeight":{"Uom":{"code":"kg"},"amount":"0"},"grossValueDomestic":{"Currency1":{"isoCode":"EUR"},"amount1":"0"},"grossValue":{"Currency_x":{"isoCode":"EUR"},"amount":"0"}},"status":"ORDER_ENTERED","SalesRepresentatives":[{"number_x":"98000200","name":"Thomas Peter","index_att_info":["index"],"index":0},{"number_x":null,"name":null,"index_att_info":["index"],"index":1},{"number_x":null,"name":null,"index_att_info":["index"],"index":2}],"ResponsiblePartner":{"number_x":"98000392","name":"Serviceuser authentSalesforce"},"Rai_ResponsibleEmployee":{"number_x":"98000123","name":"Jürgen Blum"},"Rai_Opportunity":null,"rai_objectName":"","rai_infoText":"","PriceListing":{"description":"Objektpreise 2014 - bis 30.09.2015","code":"2014"},"number_x":"VA00252039","invoicingData":{"PaymentTerms":{"description":"nach Absprache und Berücksichtigung der Bonitätsprüfung","code":"217"}},"guid":"F4180011-9E47-1030-94-20-0000100A0A0A","grossMargin":"0","DocumentDiscounts":null,"discounts":[{"value":"0","index_att_info":["index"],"index":0},{"value":"0","index_att_info":["index"],"index":1},{"value":"0","index_att_info":["index"],"index":2},{"value":"0","index_att_info":["index"],"index":3}],"Details":null,"deliveryData":{"ShippingTerms":null,"DeliveryTerms":{"description":"Ab Werk inkl. Verpackung"}},"deliveryCustomerData":{"name":"Vision 11 Metallbau","CustomerPartner":{"number_x":"20000007"},"addressData":{"street":"Beim Glaspalast 1","postalCode":"86153","Country":{"isoCode":"DE"},"city":"Augsburg"}},"date_x":"2022-12-07T23:00:00.000Z","CustomerProposal":null,"customerData":{"name":"Vision 11 Metallbau","CustomerPartner":{"number_x":"20000007"},"customer":"40F38007-93D1-1030-94-20-0000100A0A0A","CareOfPartner":null,"careOfName":"","careOf":null},"costOfGoods":{"Currency1":{"isoCode":"EUR"},"amount1":"0"},"Classification1":{"description":"STAHL","code":"100"}}');
		V11_importFailedCalls.importQuote('{"Type_x_CustomerProposal":{"description":"Logikal Kalkulation","code":"200"},"type_x":"C0AA8001-A60F-1024-98-94-0000225FA8C0","totalValues":{"netValueDomestic":{"Currency1":{"isoCode":"EUR"},"amount1":"0"},"netValue":{"Currency_x":{"isoCode":"EUR"},"amount":"0"},"grossWeight":{"Uom":{"description":"Kilogramm","code":"kg"},"amount":"lol"},"grossValueDomestic":{"Currency1":{"isoCode":"EUR"},"amount1":"0"},"grossValue":{"Currency_x":{"isoCode":"EUR"},"amount":"0"}},"status":"ORDER_ENTERED","SalesRepresentative_CustomerProposal":{"number_x":"98000200","name":"Thomas Peter"},"salesRepresentative":"C5AD2000-3727-1027-96-3D-0000225FA8C1","reviewDate":"0001-12-29T23:00:01.000Z","ResponsiblePartner":{"number_x":"98000392","name":"Serviceuser authentSalesforce"},"Responsible_CustomerProposal":{"text":null,"stc_mdeUser":"","guid":"1664A000-42B4-1030-9C-AB-00002750A8C0"},"responsible":"1664A000-42B4-1030-9C-AB-00002750A8C0","Rai_ResponsibleEmployee_CustomerProposal":{"number_x":"98000123","name":"Jürgen Blum"},"rai_responsibleEmployee":"1F8A2000-CF43-1024-A5-CC-0000225FA8C0","Rai_Opportunity":{"type_x":"41790000-BAA9-1024-83-93-0000225FA8C0","number_x":"VS00000127","guid":"D83D6004-9D91-1030-94-20-0000100A0A0A","description":"Test Schnitti, Berlin"},"rai_objectName":"","rai_infoText":"","PriceListing":null,"number_x":"VG00083775","invoicingData":{"PaymentTerms":{"description":"14 Tage - 2,00 % Skonto, 30 Tage netto","code":"103"}},"guid":"CB08A009-9E4E-1030-94-20-0000100A0A0A","DocumentDiscounts":null,"discounts":[{"value":"0","index_att_info":["index"],"index":0},{"value":"0","index_att_info":["index"],"index":1},{"value":"0","index_att_info":["index"],"index":2},{"value":"0","index_att_info":["index"],"index":3}],"Details":null,"date_x":"2022-12-07T23:00:00.000Z","customerData":{"name":"Vision 11 Metallbau","CustomerPartner":{"number_x":"20000007"},"customer":"40F38007-93D1-1030-94-20-0000100A0A0A","CareOfPartner":null,"careOfName":"","careOf":null},"Classification3":null,"Classification2":null,"Classification1":{"description":"HOLZ"}}');
		V11_importFailedCalls.importProduct('{"Uoms_type_info":["Uoms","http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data",null,"0","4","true"]}');
		V11_importFailedCalls.importEntityExtension('{"updateInfo":{"updateUser":null,"updateTime":"0001-12-29T23:00:01.000Z","deleteUser":null,"deleteTime":"0001-12-29T23:00:01.000Z","createUser":"DD684000-820C-1024-86-98-0000225FA8C0","createTime":"2016-05-03T11:56:54.900Z"},"path":"86","managingSystem":"EE268002-3D04-1024-B6-80-00002350A8C0","guid":"40020000-8ECF-102A-B3-42-00005A50A8C4","description":{"text":["Geomet 500, gleitmo beschichtet","Geomet 500 beschichtet","Geomet 500 beschichtet"]},"datatype":"Oberfläche/Farbe"}');

		Test.stopTest();
	}

	static testmethod void scheduler(){
		Test.startTest();
		Test.setMock(WebServiceMock.class, new V11_WebServiceMockInbound());
		V11_scheduleComarchImport schedule = new V11_scheduleComarchImport();
		schedule.scheduleImports();
		Test.stopTest();

	}
    static testmethod void partnerImport(){

        Account acc = [SELECT Id FROM Account WHERE ComarchAccountNumber__c ='20000007'];
        String idAcc = acc.Id;

        Test.startTest();
        Test.setMock(WebServiceMock.class, new V11_WebServiceMockInbound('Partner'));
        Test.setMock(HttpCalloutMock.class, new V11_WebServiceMock());

        V11_batchAccountUpdate batch = new V11_batchAccountUpdate();
        Database.executeBatch(batch);

        V11_PartnerExportData.Partner partner = (V11_PartnerExportData.Partner) System.JSON.deserialize('{"person":null,"PartnerRelations":[{"Type_x":{"type_x":"STANDARD","description":"Ansprechpartner"},"Target":{"number_x":"40000001"}},{"Type_x":{"type_x":"STANDARD","description":"Zuständiger Mitarbeiter"},"Target":{"number_x":"98000392"}}],"PartnerAccountingData":[{"SalesPaymentTerms":{"OrganizationalUnit":{"number_x":"910000"},"description":"nach Absprache und Berücksichtigung der Bonitätsprüfung","code":"217"},"CustomerOutstandingDebt":{"transferredUnpaidValue":{"amount1":"0"}},"creditLimit":{"Currency_x":{"isoCode":"EUR"},"amount":"1"}},{"SalesPaymentTerms":{"OrganizationalUnit":{"number_x":"900000"},"description":"nach Absprache","code":"217"},"CustomerOutstandingDebt":{"transferredUnpaidValue":{"amount1":"0"}},"creditLimit":{"Currency_x":{"isoCode":"EUR"},"amount":"5"}}],"OrganizationalUnitPartner":[{"OrganizationalUnit":{"code":"900000"},"customerStatus":"RELEASED"},{"OrganizationalUnit":{"code":"915000"},"customerStatus":"RELEASED"},{"OrganizationalUnit":{"code":"940000"},"customerStatus":"RELEASED"},{"OrganizationalUnit":{"code":"953000"},"customerStatus":"RELEASED"},{"OrganizationalUnit":{"code":"930000"},"customerStatus":"RELEASED"},{"OrganizationalUnit":{"code":"914000"},"customerStatus":"RELEASED"},{"OrganizationalUnit":{"code":"933000"},"customerStatus":"RELEASED"},{"OrganizationalUnit":{"code":"910000"},"customerStatus":"RELEASED"},{"OrganizationalUnit":{"code":"950000"},"customerStatus":"RELEASED"},{"OrganizationalUnit":{"code":"920000"},"customerStatus":"RELEASED"},{"OrganizationalUnit":{"code":"923000"},"customerStatus":"RELEASED"},{"OrganizationalUnit":{"code":"913000"},"customerStatus":"RELEASED"},{"OrganizationalUnit":{"code":"943000"},"customerStatus":"RELEASED"}],"organizationalUnit":{"type_x":"COMPANY","name":{"input":null,"index_att_info":["index"],"index":2}},"number_x":"20000007","name":"Vision 11 Metallbau!","MaintainingOrganization":{"number_x":"910000"},"Language":{"isoCode":"de"},"human":false,"EntityExtension":{"SPERRGRUND":{"value":"2"},"SALESFORCEID":{"value":"'+idAcc+'"}},"Employee":null,"Customer":[{"OrganizationalUnit":null,"deliveryDataInfo":{"deliveryTermsLocation":"","DeliveryTerms":{"incoTerms":false,"code":"130"}},"classification1":"999"},{"OrganizationalUnit":null,"deliveryDataInfo":{"deliveryTermsLocation":"","DeliveryTerms":{"incoTerms":false,"code":"130"}},"classification1":"999"}],"CommunicationData":null,"addressData":{"street":"Beim Glaspalast 1","postalCode":"86153","Country":{"isoCode":"DE"},"city":"Augsburg"}}', V11_PartnerExportData.Partner.class);
        V11_PartnerExportData.Partner partner2 = new V11_PartnerExportData.Partner();
        V11_PartnerExportData.Partner partner3 = (V11_PartnerExportData.Partner) System.JSON.deserialize('{"person":null,"PartnerRelations":null,"PartnerAccountingData":null,"OrganizationalUnitPartner":[{"OrganizationalUnit":{"code":"900000"},"customerStatus":"ON_HOLD"},{"OrganizationalUnit":{"code":"915000"},"customerStatus":"RELEASED"},{"OrganizationalUnit":{"code":"940000"},"customerStatus":"RELEASED"},{"OrganizationalUnit":{"code":"953000"},"customerStatus":"RELEASED"},{"OrganizationalUnit":{"code":"930000"},"customerStatus":"RELEASED"},{"OrganizationalUnit":{"code":"914000"},"customerStatus":"RELEASED"},{"OrganizationalUnit":{"code":"933000"},"customerStatus":"RELEASED"},{"OrganizationalUnit":{"code":"910000"},"customerStatus":"ON_HOLD"},{"OrganizationalUnit":{"code":"950000"},"customerStatus":"RELEASED"},{"OrganizationalUnit":{"code":"920000"},"customerStatus":"RELEASED"},{"OrganizationalUnit":{"code":"923000"},"customerStatus":"RELEASED"},{"OrganizationalUnit":{"code":"913000"},"customerStatus":"RELEASED"},{"OrganizationalUnit":{"code":"943000"},"customerStatus":"RELEASED"}],"organizationalUnit":{"type_x":"COMPANY","name":{"input":null,"index_att_info":["index"],"index":2}},"number_x":"20000017","name":"das reicht jetzt","MaintainingOrganization":{"number_x":"910000"},"Language":{"isoCode":"de"},"human":false,"EntityExtension":{"SPERRGRUND":{"value":"1"},"SALESFORCEID":{"value":"iohujohoiojbvhb"}},"Employee":null,"Customer":[{"OrganizationalUnit":null,"deliveryDataInfo":{"deliveryTermsLocation":"","DeliveryTerms":{"incoTerms":false,"code":"110"}},"classification1":"4"}],"CommunicationData":null,"addressData":{"street":"Konrad-Adenauer-Allee 6","postalCode":"93051","Country":{"isoCode":"D"},"city":"Regensburg"}}', V11_PartnerExportData.Partner.class);

        List<V11_PartnerExportData.Partner> partners = new  List<V11_PartnerExportData.Partner>();
        partners.add(partner);
        partners.add(partner2);
        partners.add(partner3);
        V11_batchAccountUpdate batch2 = new V11_batchAccountUpdate(partners);
        Database.executeBatch(batch2);


        Test.stopTest();
    }

    static testmethod void entityExtensionImport(){

        Test.startTest();
        Test.setMock(WebServiceMock.class, new V11_WebServiceMockInbound());
        Test.setMock(HttpCalloutMock.class, new V11_WebServiceMock());

        V11_batchEntityExtensionUpsert batch = new V11_batchEntityExtensionUpsert();
        Database.executeBatch(batch);

        V11_EntityExtensionExportData.EntityExtensionHierarchy entityExtension = (V11_EntityExtensionExportData.EntityExtensionHierarchy) System.JSON.deserialize('{"updateInfo":{"updateUser":"8D412002-C579-1024-87-BE-0000225FA8C0","updateTime":"2019-07-30T16:15:31.822Z","deleteUser":null,"deleteTime":"0001-12-29T23:00:01.000Z","createUser":"8D412002-C579-1024-87-BE-0000225FA8C0","createTime":"2019-07-30T15:51:55.711Z"},"path":"60-17","managingSystem":"EE268002-3D04-1024-B6-80-00002350A8C0","guid":"56D00000-8872-102D-B2-5A-00005A50A8C7","description":{"text":["Spezial-Holzschrauben","Spezial-Holzschrauben","Spezial-Holzschrauben"]},"datatype":"Produktgruppe"}', V11_EntityExtensionExportData.EntityExtensionHierarchy.class);
        V11_EntityExtensionExportData.EntityExtensionHierarchy entityExtension1 = (V11_EntityExtensionExportData.EntityExtensionHierarchy) System.JSON.deserialize('{"updateInfo":{"updateUser":"8D412002-C579-1024-87-BE-0000225FA8C0","updateTime":"2019-07-30T16:15:31.822Z","deleteUser":null,"deleteTime":"0001-12-29T23:00:01.000Z","createUser":"8D412002-C579-1024-87-BE-0000225FA8C0","createTime":"2019-07-30T15:51:55.735Z"},"path":"60-11","managingSystem":"EE268002-3D04-1024-B6-80-00002350A8C0","guid":"280CC000-8872-102D-B2-5A-00005A50A","description":{"text":["Linsensenkschrauben","Linsensenkschrauben","Linsensenkschrauben"]},"datatype":"Oberfläche/Farbe"}', V11_EntityExtensionExportData.EntityExtensionHierarchy.class);
        V11_EntityExtensionExportData.EntityExtensionHierarchy entityExtension2 = (V11_EntityExtensionExportData.EntityExtensionHierarchy) System.JSON.deserialize('{"updateInfo":{"updateUser":"8D412002-C579-1024-87-BE-0000225FA8C0","updateTime":"2019-07-30T16:15:31.822Z","deleteUser":null,"deleteTime":"0001-12-29T23:00:01.000Z","createUser":"8D412002-C579-1024-87-BE-0000225FA8C0","createTime":"2019-07-30T15:51:55.711Z"},"path":"60-17","managingSystem":"EE268002-3D04-1024-B6-80-00002350A8C0","guid":"56D00000-8872-102D-B25A-00005A58C7","description":{"text":["Spezial-Holzschrauben","Spezial-Holzschrauben","Spezial-Holzschrauben"]},"datatype":"Artikelgruppe"}', V11_EntityExtensionExportData.EntityExtensionHierarchy.class);
        V11_EntityExtensionExportData.EntityExtensionHierarchy entityExtension3 = (V11_EntityExtensionExportData.EntityExtensionHierarchy) System.JSON.deserialize('{"updateInfo":{"updateUser":"8D412002-C579-1024-87-BE-0000225FA8C0","updateTime":"2019-07-30T16:15:31.822Z","deleteUser":null,"deleteTime":"0001-12-29T23:00:01.000Z","createUser":"8D412002-C579-1024-87-BE-0000225FA8C0","createTime":"2019-07-30T15:51:55.711Z"},"path":"60-17","managingSystem":"EE268002-3D04-1024-B6-80-00002350A8C0","guid":"56D00-8872-102D-B2-5A-00005A50A8C7","description":{"text":["Spezial-Holzschrauben","Spezial-Holzschrauben","Spezial-Holzschrauben"]},"datatype":"Warengruppe"}', V11_EntityExtensionExportData.EntityExtensionHierarchy.class);
        V11_EntityExtensionExportData.EntityExtensionHierarchy entityExtension4 = (V11_EntityExtensionExportData.EntityExtensionHierarchy) System.JSON.deserialize('{"updateInfo":{"updateUser":"8D412002-C579-1024-87-BE-0000225FA8C0","updateTime":"2019-07-30T16:15:31.822Z","deleteUser":null,"deleteTime":"0001-12-29T23:00:01.000Z","createUser":"8D412002-C579-1024-87-BE-0000225FA8C0","createTime":"2019-07-30T15:51:55.711Z"},"path":"60-17","managingSystem":"EE268002-3D04-1024-B6-80-00002350A8C0","guid":"56D00000-8872-10D-B2-5A-000A50A8C7","description":{"text":["Spezial-Holzschrauben","Spezial-Holzschrauben","Spezial-Holzschrauben"]},"datatype":"Werkstoff"}', V11_EntityExtensionExportData.EntityExtensionHierarchy.class);
        V11_EntityExtensionExportData.EntityExtensionHierarchy entityExtension5 = (V11_EntityExtensionExportData.EntityExtensionHierarchy) System.JSON.deserialize('{"updateInfo":{"updateUser":"8D412002-C579-1024-87-BE-0000225FA8C0","updateTime":"2019-07-30T16:15:31.822Z","deleteUser":null,"deleteTime":"0001-12-29T23:00:01.000Z","createUser":"8D412002-C579-1024-87-BE-0000225FA8C0","createTime":"2019-07-30T15:51:55.711Z"},"path":"60-17","managingSystem":"EE268002-3D04-1024-B6-80-00002350A8C0","guid":"56D00000-8872-102D-2-5A-00005A0A8C7","description":{"text":["Spezial-Holzschrauben","Spezial-Holzschrauben","Spezial-Holzschrauben"]},"datatype":""}', V11_EntityExtensionExportData.EntityExtensionHierarchy.class); 
        List<V11_EntityExtensionExportData.EntityExtensionHierarchy> entityExtensions = new  List<V11_EntityExtensionExportData.EntityExtensionHierarchy>();
        entityExtensions.add(entityExtension);
        entityExtensions.add(entityExtension1);
        entityExtensions.add(entityExtension2);
        entityExtensions.add(entityExtension3);
        entityExtensions.add(entityExtension4);
        entityExtensions.add(entityExtension5);
        V11_batchEntityExtensionUpsert batch2 = new V11_batchEntityExtensionUpsert(entityExtensions);
        Database.executeBatch(batch2);

        Test.stopTest();

    }
	static testmethod void orderIdImport(){
		Test.startTest();
		Test.setMock(WebServiceMock.class, new V11_WebServiceMockInbound());

		V11_batchGetOrderIDs batch = new V11_batchGetOrderIDs();
		Database.executeBatch(batch,200);

		Test.stopTest();

	}

    static testmethod void orderImport(){

        Test.startTest();
        Test.setMock(WebServiceMock.class, new V11_WebServiceMockInbound());
        Test.setMock(HttpCalloutMock.class, new V11_WebServiceMock());
		List<string> orderIds = new List<String>();
		orderIds.add('1');
        V11_batchOrderUpsert batchable = new V11_batchOrderUpsert(orderIds);
        Database.executeBatch(batchable);

        V11_OrderExportData.SalesOrder order = (V11_OrderExportData.SalesOrder) System.JSON.deserialize('{"totalValues":{"netWeight":{"Uom":{"code":"kg"},"amount":"0"},"netValueDomestic":{"Currency1":{"isoCode":"EUR"},"amount1":"0"},"netValue":{"Currency_x":{"isoCode":"EUR"},"amount":"0"},"grossWeight":{"Uom":{"code":"kg"},"amount":"0"},"grossValueDomestic":{"Currency1":{"isoCode":"EUR"},"amount1":"0"},"grossValue":{"Currency_x":{"isoCode":"EUR"},"amount":"0"}},"status":"ORDER_ENTERED","SalesRepresentatives":[{"number_x":"98000200","name":"Thomas Peter","index_att_info":["index"],"index":0},{"number_x":null,"name":null,"index_att_info":["index"],"index":1},{"number_x":null,"name":null,"index_att_info":["index"],"index":2}],"ResponsiblePartner":{"number_x":"98000392","name":"Serviceuser authentSalesforce"},"Rai_ResponsibleEmployee":{"number_x":"98000123","name":"Jürgen Blum"},"Rai_Opportunity":null,"rai_objectName":"","rai_infoText":"","PriceListing":{"description":"Objektpreise 2014 - bis 30.09.2015","code":"2014"},"number_x":"VA00252039","invoicingData":{"PaymentTerms":{"description":"nach Absprache und Berücksichtigung der Bonitätsprüfung","code":"217"}},"guid":"F4180011-9E47-1030-94-20-0000100A0A0A","grossMargin":"0","DocumentDiscounts":null,"discounts":[{"value":"0","index_att_info":["index"],"index":0},{"value":"0","index_att_info":["index"],"index":1},{"value":"0","index_att_info":["index"],"index":2},{"value":"0","index_att_info":["index"],"index":3}],"Details":null,"deliveryData":{"ShippingTerms":null,"DeliveryTerms":{"description":"Ab Werk inkl. Verpackung"}},"deliveryCustomerData":{"name":"Vision 11 Metallbau","CustomerPartner":{"number_x":"20000007"},"addressData":{"street":"Beim Glaspalast 1","postalCode":"86153","Country":{"isoCode":"DE"},"city":"Augsburg"}},"date_x":"2022-12-07T23:00:00.000Z","CustomerProposal":null,"customerData":{"name":"Vision 11 Metallbau","CustomerPartner":{"number_x":"20000007"},"customer":"40F38007-93D1-1030-94-20-0000100A0A0A","CareOfPartner":null,"careOfName":"","careOf":null},"costOfGoods":{"Currency1":{"isoCode":"EUR"},"amount1":"0"},"Classification1":{"description":"STAHL","code":"100"}}', V11_OrderExportData.SalesOrder.class);
        V11_OrderExportData.SalesOrder order1 = (V11_OrderExportData.SalesOrder) System.JSON.deserialize('{"totalValues":{"netWeight":{"Uom":{"code":"kg"},"amount":"0"},"netValueDomestic":{"Currency1":{"isoCode":"EUR"},"amount1":"0"},"netValue":{"Currency_x":{"isoCode":"EUR"},"amount":"0"},"grossWeight":{"Uom":{"code":"kg"},"amount":"0"},"grossValueDomestic":{"Currency1":{"isoCode":"EUR"},"amount1":"0"},"grossValue":{"Currency_x":{"isoCode":"EUR"},"amount":"0"}},"status":"ORDER_ENTERED","SalesRepresentatives":[{"number_x":"98000200","name":"Thomas Peter","index_att_info":["index"],"index":0},{"number_x":null,"name":null,"index_att_info":["index"],"index":1},{"number_x":null,"name":null,"index_att_info":["index"],"index":2}],"ResponsiblePartner":{"number_x":"98000392","name":"Serviceuser authentSalesforce"},"Rai_ResponsibleEmployee":{"number_x":"98000123","name":"Jürgen Blum"},"Rai_Opportunity":null,"rai_objectName":"","rai_infoText":"","PriceListing":{"description":"Objektpreise 2014 - bis 30.09.2015","code":"2014"},"number_x":"VA00252037","invoicingData":{"PaymentTerms":{"description":"nach Absprache und Berücksichtigung der Bonitätsprüfung","code":"217"}},"guid":"F4180011-9E47-1030-94-20-0000100A0A0A","grossMargin":"0","DocumentDiscounts":[{"CustomerProposal":null}],"discounts":[{"value":"0","index_att_info":["index"],"index":0},{"value":"0","index_att_info":["index"],"index":1},{"value":"0","index_att_info":["index"],"index":2},{"value":"0","index_att_info":["index"],"index":3}],"Details":[{"totalValues":{"grossValue":{"amount":"0"}},"totalQuantity":{"Uom":{"description":"Stück","code":"Stk"},"amount":"0"},"totalQuantities":null,"subNumber":0,"status":"ORDER_ENTERED","shippingDate":"2022-12-06T23:00:00.000Z","retailNetValueDomestic":{"Currency1":{"isoCode":"EUR"},"amount1":"0"},"retailNetValue":{"Currency_x":{"isoCode":"EUR"},"amount":"0"},"number_x":10,"netPriceDomestic":{"Currency1_SalesOrder_Details_netPriceDomestic":{"isoCode":"EUR"},"currency1":"11BEE001-01E3-1021-AA-9E-000066966484","amount1":"0"},"netPrice":{"Currency_x":{"isoCode":"EUR"},"amount":"0"},"Item":{"number_x":"000010"},"invoiceStatus":"NONE","guid":"3300A053-9E48-1030-94-20-0000100A0A0A","grossPrice":{"amount":"0"},"grossMargin":"0","dispoDate":"2022-12-06T23:00:00.000Z","discounts":{"value":"0","index_att_info":["index"],"index":3,"DiscountType":null},"detailType":"NORMAL","deliveryStatus":"COMPLETE","deliveryManualCompleted":false,"deliveryDate":"2022-12-07T23:00:00.000Z","deliveryData":{"ShippingTerms":null,"deliveryTermsLocation":"","DeliveryTerms":{"description":"Ab Werk inkl. Verpackung","code":"130"}},"deliveryCustomerData":{"name":"Vision 11 Metallbau","addressData":{"street":"Beim Glaspalast 1","postalCode":"86153","Country":{"isoCode":"DE"},"city":"Augsburg"}},"CustomerProposal":null,"costOfGoods":{"currency1":"11BEE001-01E3-1021-AA-9E-000066966484","amount1":"0"},"canceled":false}],"deliveryData":{"ShippingTerms":null,"DeliveryTerms":{"description":"Ab Werk inkl. Verpackung"}},"deliveryCustomerData":{"name":"Vision 11 Metallbau","CustomerPartner":{"number_x":"20000017"},"addressData":{"street":"Beim Glaspalast 1","postalCode":"86153","Country":{"isoCode":"DE"},"city":"Augsburg"}},"date_x":"2022-12-07T23:00:00.000Z","CustomerProposal":null,"customerData":{"name":"Vision 11 Metallbau","CustomerPartner":{"number_x":"200000017"},"customer":"40F38007-93D1-1030-94-20-0000100A0A0A","CareOfPartner":null,"careOfName":"","careOf":null},"costOfGoods":{"Currency1":{"isoCode":"EUR"},"amount1":"0"},"Classification1":{"description":"STAHL","code":"100"}}', V11_OrderExportData.SalesOrder.class);
        V11_OrderExportData.SalesOrder order2 = (V11_OrderExportData.SalesOrder) System.JSON.deserialize('{"totalValues":{"netWeight":{"Uom":{"code":"kg"},"amount":"0"},"netValueDomestic":{"Currency1":{"isoCode":"EUR"},"amount1":"150"},"netValue":{"Currency_x":{"isoCode":"EUR"},"amount":"150"},"grossWeight":{"Uom":{"code":"kg"},"amount":"0"},"grossValueDomestic":{"Currency1":{"isoCode":"EUR"},"amount1":"150"},"grossValue":{"Currency_x":{"isoCode":"EUR"},"amount":"150"}},"status":"ORDER_ENTERED","SalesRepresentatives":[{"number_x":"98000200","name":"Thomas Peter","index_att_info":["index"],"index":0},{"number_x":null,"name":null,"index_att_info":["index"],"index":1},{"number_x":null,"name":null,"index_att_info":["index"],"index":2}],"ResponsiblePartner":{"number_x":"98000390","name":"Serviceuser Salesforce"},"Rai_ResponsibleEmployee":{"number_x":"98000123","name":"Jürgen Blum"},"Rai_Opportunity":{"number_x":"VS00000127"},"rai_objectName":"","rai_infoText":"Dies ist ein Test. Wird der Infotext mitgesendet? Mit Sicherheit wird er das.","PriceListing":{"description":"Standard laufend gültig","code":"100"},"number_x":"VA00252038","invoicingData":{"PaymentTerms":{"description":"nach Absprache und Berücksichtigung der Bonitätsprüfung","code":"217"}},"guid":"221A600A-9E50-1030-94-20-0000100A0A0A","grossMargin":"100","DocumentDiscounts":[{"CustomerProposal":null},{"CustomerProposal":null}],"discounts":[{"value":"0","index_att_info":["index"],"index":0},{"value":"0","index_att_info":["index"],"index":1},{"value":"0","index_att_info":["index"],"index":2},{"value":"0","index_att_info":["index"],"index":3}],"Details":[{"totalValues":{"grossValue":{"amount":"150"}},"totalQuantity":{"Uom":{"description":"Stück","code":"Stk"},"amount":"0"},"totalQuantities":null,"subNumber":0,"status":"ORDER_ENTERED","shippingDate":"2022-12-06T23:00:00.000Z","retailNetValueDomestic":{"Currency1":{"isoCode":"EUR"},"amount1":"0"},"retailNetValue":{"Currency_x":{"isoCode":"EUR"},"amount":"0"},"number_x":10,"netPriceDomestic":{"Currency1_SalesOrder_Details_netPriceDomestic":{"isoCode":"EUR"},"currency1":"11BEE001-01E3-1021-AA-9E-000066966484","amount1":"150"},"netPrice":{"Currency_x":{"isoCode":"EUR"},"amount":"150"},"Item":{"number_x":"123"},"invoiceStatus":"NONE","guid":"D4874011-9E50-1030-94-20-0000100A0A0A","grossPrice":{"amount":"150"},"grossMargin":"100","dispoDate":"2022-12-06T23:00:00.000Z","discounts":{"value":"0","index_att_info":["index"],"index":3,"DiscountType":null},"detailType":"NORMAL","deliveryStatus":"COMPLETE","deliveryManualCompleted":false,"deliveryDate":"2022-12-07T23:00:00.000Z","deliveryData":{"ShippingTerms":{"description":"Lieferung per DPD","code":"120"},"deliveryTermsLocation":"","DeliveryTerms":{"description":"Ab Werk inkl. Verpackung","code":"130"}},"deliveryCustomerData":{"name":"Vision 11 Metallbau","addressData":{"street":"Beim Glaspalast 1","postalCode":"86153","Country":{"isoCode":"DE"},"city":"Augsburg"}},"CustomerProposal":null,"costOfGoods":{"currency1":"11BEE001-01E3-1021-AA-9E-000066966484","amount1":"0"},"canceled":false},{"totalValues":{"grossValue":{"amount":"0"}},"totalQuantity":{"Uom":{"description":"Stück","code":"Stk"},"amount":"0"},"totalQuantities":null,"subNumber":0,"status":"ORDER_ENTERED","shippingDate":"2022-12-06T23:00:00.000Z","retailNetValueDomestic":{"Currency1":{"isoCode":"EUR"},"amount1":"0"},"retailNetValue":{"Currency_x":{"isoCode":"EUR"},"amount":"0"},"number_x":20,"netPriceDomestic":{"Currency1_SalesOrder_Details_netPriceDomestic":{"isoCode":"EUR"},"currency1":"11BEE001-01E3-1021-AA-9E-000066966484","amount1":"0"},"netPrice":{"Currency_x":{"isoCode":"EUR"},"amount":"0"},"Item":{"number_x":"001022"},"invoiceStatus":"NONE","guid":"0B75A001-9E51-1030-94-20-0000100A0A0A","grossPrice":{"amount":"0"},"grossMargin":"0","dispoDate":"2022-12-06T23:00:00.000Z","discounts":{"value":"0","index_att_info":["index"],"index":3,"DiscountType":null},"detailType":"NORMAL","deliveryStatus":"COMPLETE","deliveryManualCompleted":false,"deliveryDate":"2022-12-07T23:00:00.000Z","deliveryData":{"ShippingTerms":{"description":"Lieferung per DPD","code":"120"},"deliveryTermsLocation":"","DeliveryTerms":{"description":"Ab Werk inkl. Verpackung","code":"130"}},"deliveryCustomerData":{"name":"Vision 11 Metallbau","addressData":{"street":"Beim Glaspalast 1","postalCode":"86153","Country":{"isoCode":"DE"},"city":"Augsburg"}},"CustomerProposal":null,"costOfGoods":{"currency1":"11BEE001-01E3-1021-AA-9E-000066966484","amount1":"0"},"canceled":false}],"deliveryData":{"ShippingTerms":{"description":"Lieferung per DPD"},"DeliveryTerms":{"description":"Ab Werk inkl. Verpackung"}},"deliveryCustomerData":{"name":"Vision 11 Metallbau","CustomerPartner":{"number_x":"20000007"},"addressData":{"street":"Beim Glaspalast 1","postalCode":"86153","Country":{"isoCode":"DE"},"city":"Augsburg"}},"date_x":"2022-12-07T23:00:00.000Z","CustomerProposal":null,"customerData":{"name":"Vision 11 Metallbau","CustomerPartner":{"number_x":"20000007"},"customer":"40F38007-93D1-1030-94-20-0000100A0A0A","CareOfPartner":{"number_x":"40000001","human":true},"careOfName":"Gut Morgen","careOf":"67760001-93F1-1030-94-20-0000100A0A0A"},"costOfGoods":{"Currency1":{"isoCode":"EUR"},"amount1":"0"},"Classification1":{"description":"FRAME+/WING","code":"500"}}', V11_OrderExportData.SalesOrder.class);
        /*V11_OrderExportData.SalesOrder_Details detail = new V11_OrderExportData.SalesOrder_Details();
        detail.guid = '3300A053-9E48-1030-94-20-0000100A0A0A"';
        detail.item = new V11_OrderExportData.SalesOrder_Details_Item();
        detail.Item.number_x = '123';
        order2.Details.add(detail);*/
        List<V11_OrderExportData.SalesOrder> orders = new List<V11_OrderExportData.SalesOrder>();
        orders.add(order);
        orders.add(order1);
        orders.add(order2);

        V11_batchOrderUpsert batchable2 = new V11_batchOrderUpsert(orders);
        Database.executeBatch(batchable2);
        V11_OrderExportData.SalesOrder order3 = (V11_OrderExportData.SalesOrder) System.JSON.deserialize('{"totalValues":{"netWeight":{"Uom":{"code":"kg"},"amount":"0"},"netValueDomestic":{"Currency1":{"isoCode":"EUR"},"amount1":"150"},"netValue":{"Currency_x":{"isoCode":"EUR"},"amount":"150"},"grossWeight":{"Uom":{"code":"kg"},"amount":"0"},"grossValueDomestic":{"Currency1":{"isoCode":"EUR"},"amount1":"150"},"grossValue":{"Currency_x":{"isoCode":"EUR"},"amount":"150"}},"status":"ORDER_ENTERED","SalesRepresentatives":[{"number_x":"98000200","name":"Thomas Peter","index_att_info":["index"],"index":0},{"number_x":null,"name":null,"index_att_info":["index"],"index":1},{"number_x":null,"name":null,"index_att_info":["index"],"index":2}],"ResponsiblePartner":{"number_x":"98000390","name":"Serviceuser Salesforce"},"Rai_ResponsibleEmployee":{"number_x":"98000123","name":"Jürgen Blum"},"Rai_Opportunity":{"number_x":"VS00000127"},"rai_objectName":"","rai_infoText":"Dies ist ein Test. Wird der Infotext mitgesendet? Mit Sicherheit wird er das.","PriceListing":{"description":"Standard laufend gültig","code":"100"},"number_x":"VA00252038","invoicingData":{"PaymentTerms":{"description":"nach Absprache und Berücksichtigung der Bonitätsprüfung","code":"217"}},"guid":"221A600A-9E50-1030-94-2-0000100A0A0A","grossMargin":"100","DocumentDiscounts":[{"CustomerProposal":null},{"CustomerProposal":null}],"discounts":[{"value":"0","index_att_info":["index"],"index":0},{"value":"0","index_att_info":["index"],"index":1},{"value":"0","index_att_info":["index"],"index":2},{"value":"0","index_att_info":["index"],"index":3}],"Details":[{"totalValues":{"grossValue":{"amount":"150"}},"totalQuantity":{"Uom":{"description":"Stück","code":"Stk"},"amount":"0"},"totalQuantities":null,"subNumber":0,"status":"ORDER_ENTERED","shippingDate":"2022-12-06T23:00:00.000Z","retailNetValueDomestic":{"Currency1":{"isoCode":"EUR"},"amount1":"0"},"retailNetValue":{"Currency_x":{"isoCode":"EUR"},"amount":"0"},"number_x":10,"netPriceDomestic":{"Currency1_SalesOrder_Details_netPriceDomestic":{"isoCode":"EUR"},"currency1":"11BEE001-01E3-1021-AA-9E-000066966484","amount1":"150"},"netPrice":{"Currency_x":{"isoCode":"EUR"},"amount":"150"},"Item":{"number_x":"FE014"},"invoiceStatus":"NONE","guid":"D4874011-9E50-1030-94-20-0000100A0A0A","grossPrice":{"amount":"150"},"grossMargin":"100","dispoDate":"2022-12-06T23:00:00.000Z","discounts":{"value":"0","index_att_info":["index"],"index":3,"DiscountType":null},"detailType":"NORMAL","deliveryStatus":"COMPLETE","deliveryManualCompleted":false,"deliveryDate":"2022-12-07T23:00:00.000Z","deliveryData":{"ShippingTerms":{"description":"Lieferung per DPD","code":"120"},"deliveryTermsLocation":"","DeliveryTerms":{"description":"Ab Werk inkl. Verpackung","code":"130"}},"deliveryCustomerData":{"name":"Vision 11 Metallbau","addressData":{"street":"Beim Glaspalast 1","postalCode":"86153","Country":{"isoCode":"DE"},"city":"Augsburg"}},"CustomerProposal":null,"costOfGoods":{"currency1":"11BEE001-01E3-1021-AA-9E-000066966484","amount1":"0"},"canceled":false},{"totalValues":{"grossValue":{"amount":"0"}},"totalQuantity":{"Uom":{"description":"Stück","code":"Stk"},"amount":"0"},"totalQuantities":null,"subNumber":0,"status":"ORDER_ENTERED","shippingDate":"2022-12-06T23:00:00.000Z","retailNetValueDomestic":{"Currency1":{"isoCode":"EUR"},"amount1":"0"},"retailNetValue":{"Currency_x":{"isoCode":"EUR"},"amount":"0"},"number_x":20,"netPriceDomestic":{"Currency1_SalesOrder_Details_netPriceDomestic":{"isoCode":"EUR"},"currency1":"11BEE001-01E3-1021-AA-9E-000066966484","amount1":"0"},"netPrice":{"Currency_x":{"isoCode":"EUR"},"amount":"0"},"Item":{"number_x":"001022"},"invoiceStatus":"NONE","guid":"0B75A001-9E51-1030-94-20-0000100A0A0A","grossPrice":{"amount":"0"},"grossMargin":"0","dispoDate":"2022-12-06T23:00:00.000Z","discounts":{"value":"0","index_att_info":["index"],"index":3,"DiscountType":null},"detailType":"NORMAL","deliveryStatus":"COMPLETE","deliveryManualCompleted":false,"deliveryDate":"2022-12-07T23:00:00.000Z","deliveryData":{"ShippingTerms":{"description":"Lieferung per DPD","code":"120"},"deliveryTermsLocation":"","DeliveryTerms":{"description":"Ab Werk inkl. Verpackung","code":"130"}},"deliveryCustomerData":{"name":"Vision 11 Metallbau","addressData":{"street":"Beim Glaspalast 1","postalCode":"86153","Country":{"isoCode":"DE"},"city":"Augsburg"}},"CustomerProposal":null,"costOfGoods":{"currency1":"11BEE001-01E3-1021-AA-9E-000066966484","amount1":"0"},"canceled":false}],"deliveryData":{"ShippingTerms":{"description":"Lieferung per DPD"},"DeliveryTerms":{"description":"Ab Werk inkl. Verpackung"}},"deliveryCustomerData":{"name":"Vision 11 Metallbau","CustomerPartner":{"number_x":"20000007"},"addressData":{"street":"Beim Glaspalast 1","postalCode":"86153","Country":{"isoCode":"DE"},"city":"Augsburg"}},"date_x":"2022-12-07T23:00:00.000Z","CustomerProposal":null,"customerData":{"name":"Vision 11 Metallbau","CustomerPartner":{"number_x":"20000007"},"customer":"40F38007-93D1-1030-94-20-0000100A0A0A","CareOfPartner":{"number_x":"40000001","human":true},"careOfName":"Gut Morgen","careOf":"67760001-93F1-1030-94-20-0000100A0A0A"},"costOfGoods":{"Currency1":{"isoCode":"EUR"},"amount1":"0"},"Classification1":{"description":"FRAME+/WING","code":"500"}}', V11_OrderExportData.SalesOrder.class);

        order3.number_x = '12357';
        orders.add(order3);

        V11_batchOrderUpsert batchable3 = new V11_batchOrderUpsert(orders);
        Database.executeBatch(batchable3);

        order2.Details[0].grossPrice.amount = 'test';
        List<V11_OrderExportData.SalesOrder> orders2 = new List<V11_OrderExportData.SalesOrder>();
        orders2.add(order2);
        V11_batchOrderUpsert batchable4 = new V11_batchOrderUpsert(orders2);
        Database.executeBatch(batchable4);



        Test.stopTest();



    }

    static testmethod void productImport(){

        Test.startTest();
        Test.setMock(WebServiceMock.class, new V11_WebServiceMockInbound());
        Test.setMock(HttpCalloutMock.class, new V11_WebServiceMock());

        V11_batchProductsUpsert batch = new V11_batchProductsUpsert();
        Database.executeBatch(batch);

        V11_ProductExportData.Item product = (V11_ProductExportData.Item) System.JSON.deserialize('{"Uoms_type_info":["Uoms","http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data",null,"0","4","true"],"Uoms":[{"type_x_type_info":["type","http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data",null,"0","1","false"],"type_x":"OTHER","index_att_info":["index"],"index":0,"field_order_type_info":["code","description","type_x"],"description_type_info":["description","http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data",null,"0","1","true"],"description":{"text_type_info":["text","http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data",null,"1","-1","true"],"text":"Stück","field_order_type_info":["text"],"apex_schema_type_info":["http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data","true","false"]},"code_type_info":["code","http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data",null,"0","1","false"],"code":"Stk","apex_schema_type_info":["http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data","true","false"]}],"Stc_Material_type_info":["Stc_Material","http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data",null,"0","1","true"],"Stc_Material":null,"rai_prototypeStatus_type_info":["rai_prototypeStatus","http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data",null,"0","1","false"],"rai_prototypeStatus":"RELEASED","number_x_type_info":["number","http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data",null,"0","1","false"],"number_x":"000010","measurements_type_info":["measurements","http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data",null,"0","1","true"],"measurements":{"netWeight_type_info":["netWeight","http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data",null,"0","1","true"],"netWeight":{"field_order_type_info":["amount"],"apex_schema_type_info":["http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data","true","false"],"amount_type_info":["amount","http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data",null,"0","1","true"],"amount":"0"},"field_order_type_info":["netWeight"],"apex_schema_type_info":["http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data","true","false"]},"longDescription_type_info":["longDescription","http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data",null,"0","1","true"],"longDescription":{"text_type_info":["text","http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data",null,"1","-1","true"],"text":["Verpackungskosten!","Verpackungskosten,","Frais de conditionnement"],"field_order_type_info":["text"],"apex_schema_type_info":["http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data","true","false"]},"ItemPackagingUoms_type_info":["ItemPackagingUoms","http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data",null,"0","-1","true"],"ItemPackagingUoms":null,"guid_type_info":["guid","http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data",null,"0","1","true"],"guid":"C658E004-6661-1024-BF-0C-0000225FA8C1","field_order_type_info":["guid","number_x","description","longDescription","measurements","rai_prototypeStatus","Stc_Material","Uoms","EntityExtension","ItemPackagingUoms"],"EntityExtension_type_info":["EntityExtension","http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data",null,"0","1","true"],"EntityExtension":{"WERKSTOFF_NEU_type_info":["WERKSTOFF_NEU","http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data",null,"0","1","true"],"WERKSTOFF_NEU":{"field_order_type_info":["classification"],"classification_type_info":["classification","http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data",null,"0","1","false"],"classification":"","apex_schema_type_info":["http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data","true","false"]},"WARENGRUPPE_type_info":["WARENGRUPPE","http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data",null,"0","1","true"],"WARENGRUPPE":{"field_order_type_info":["classification"],"classification_type_info":["classification","http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data",null,"0","1","false"],"classification":"10","apex_schema_type_info":["http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data","true","false"]},"PRODUKTGRUPPE_type_info":["PRODUKTGRUPPE","http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data",null,"0","1","true"],"PRODUKTGRUPPE":{"field_order_type_info":["classification"],"classification_type_info":["classification","http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data",null,"0","1","false"],"classification":"","apex_schema_type_info":["http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data","true","false"]},"OBERFLAECHE_FARBE_type_info":["OBERFLAECHE_FARBE","http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data",null,"0","1","true"],"OBERFLAECHE_FARBE":{"field_order_type_info":["classification"],"classification_type_info":["classification","http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data",null,"0","1","false"],"classification":"","apex_schema_type_info":["http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data","true","false"]},"LANGEMAXIMAL_type_info":["LANGEMAXIMAL","http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data",null,"0","1","true"],"LANGEMAXIMAL":{"value_type_info":["value","http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data",null,"0","1","false"],"value":"","field_order_type_info":["value"],"apex_schema_type_info":["http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data","true","false"]},"field_order_type_info":["ARTIKELGRUPP","LANGEMAXIMAL","OBERFLAECHE_FARBE","PRODUKTGRUPPE","WARENGRUPPE","WERKSTOFF_NEU"],"ARTIKELGRUPP_type_info":["ARTIKELGRUPP","http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data",null,"0","1","true"],"ARTIKELGRUPP":{"field_order_type_info":["classification"],"classification_type_info":["classification","http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data",null,"0","1","false"],"classification":"6","apex_schema_type_info":["http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data","true","false"]},"apex_schema_type_info":["http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data","true","false"]},"description_type_info":["description","http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data",null,"0","1","true"],"description":{"text_type_info":["text","http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data",null,"1","-1","true"],"text":["Verpackungskosten","Verpackungskosten","Frais de conditionnement"],"field_order_type_info":["text"],"apex_schema_type_info":["http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data","true","false"]},"apex_schema_type_info":["http://webservices.semiramis.com/2006-01/Export/extended/PRODUCTSALESFORCE/data","true","false"]}', V11_ProductExportData.Item.class);
        List<V11_ProductExportData.Item> products = new List<V11_ProductExportData.Item>();
        products.add(product);
        V11_batchProductsUpsert batchable = new V11_batchProductsUpsert(products);
        Database.executeBatch(batchable);

        Test.stopTest();
    }

    static testmethod void quoteImport(){

        Test.startTest();
        Test.setMock(WebServiceMock.class, new V11_WebServiceMockInbound());
        Test.setMock(HttpCalloutMock.class, new V11_WebServiceMock());

        V11_batchQuoteUpsert batch = new V11_batchQuoteUpsert();
        Database.executeBatch(batch);

        V11_QuoteExportData.CustomerProposal quote = (V11_QuoteExportData.CustomerProposal) System.JSON.deserialize('{"Type_x_CustomerProposal":{"description":"Logikal Kalkulation","code":"200"},"type_x":"C0AA8001-A60F-1024-98-94-0000225FA8C0","totalValues":{"netValueDomestic":{"Currency1":{"isoCode":"EUR"},"amount1":"0"},"netValue":{"Currency_x":{"isoCode":"EUR"},"amount":"0"},"grossWeight":{"Uom":{"description":"Kilogramm","code":"kg"},"amount":"lol"},"grossValueDomestic":{"Currency1":{"isoCode":"EUR"},"amount1":"0"},"grossValue":{"Currency_x":{"isoCode":"EUR"},"amount":"0"}},"status":"ORDER_ENTERED","SalesRepresentative_CustomerProposal":{"number_x":"98000200","name":"Thomas Peter"},"salesRepresentative":"C5AD2000-3727-1027-96-3D-0000225FA8C1","reviewDate":"0001-12-29T23:00:01.000Z","ResponsiblePartner":{"number_x":"98000392","name":"Serviceuser authentSalesforce"},"Responsible_CustomerProposal":{"text":null,"stc_mdeUser":"","guid":"1664A000-42B4-1030-9C-AB-00002750A8C0"},"responsible":"1664A000-42B4-1030-9C-AB-00002750A8C0","Rai_ResponsibleEmployee_CustomerProposal":{"number_x":"98000123","name":"Jürgen Blum"},"rai_responsibleEmployee":"1F8A2000-CF43-1024-A5-CC-0000225FA8C0","Rai_Opportunity":{"type_x":"41790000-BAA9-1024-83-93-0000225FA8C0","number_x":"VS00000127","guid":"D83D6004-9D91-1030-94-20-0000100A0A0A","description":"Test Schnitti, Berlin"},"rai_objectName":"","rai_infoText":"","PriceListing":null,"number_x":"VG00083775","invoicingData":{"PaymentTerms":{"description":"14 Tage - 2,00 % Skonto, 30 Tage netto","code":"103"}},"guid":"CB08A009-9E4E-1030-94-20-0000100A0A0A","DocumentDiscounts":null,"discounts":[{"value":"0","index_att_info":["index"],"index":0},{"value":"0","index_att_info":["index"],"index":1},{"value":"0","index_att_info":["index"],"index":2},{"value":"0","index_att_info":["index"],"index":3}],"Details":null,"date_x":"2022-12-07T23:00:00.000Z","customerData":{"name":"Vision 11 Metallbau","CustomerPartner":{"number_x":"20000007"},"customer":"40F38007-93D1-1030-94-20-0000100A0A0A","CareOfPartner":null,"careOfName":"","careOf":null},"Classification3":null,"Classification2":null,"Classification1":{"description":"HOLZ"}}', V11_QuoteExportData.CustomerProposal.class);
        List<V11_QuoteExportData.CustomerProposal> quotes = new List<V11_QuoteExportData.CustomerProposal>();
        quotes.add(quote);
        V11_batchQuoteUpsert batch1 = new V11_batchQuoteUpsert(quotes);
        Database.executeBatch(batch1);

        V11_QuoteExportData.CustomerProposal quote2 = (V11_QuoteExportData.CustomerProposal) System.JSON.deserialize('{"Type_x_CustomerProposal":{"description":"Logikal Kalkulation","code":"200"},"type_x":"C0AA8001-A60F-1024-98-94-0000225FA8C0","totalValues":{"netValueDomestic":{"Currency1":{"isoCode":"EUR"},"amount1":"123"},"netValue":{"Currency_x":{"isoCode":"EUR"},"amount":"123"},"grossWeight":{"Uom":{"description":"Kilogramm","code":"kg"},"amount":"0.1"},"grossValueDomestic":{"Currency1":{"isoCode":"EUR"},"amount1":"123"},"grossValue":{"Currency_x":{"isoCode":"EUR"},"amount":"123"}},"status":"ORDER_ENTERED","SalesRepresentative_CustomerProposal":{"number_x":"98000200","name":"Thomas Peter"},"salesRepresentative":"C5AD2000-3727-1027-96-3D-0000225FA8C1","reviewDate":"0001-12-29T23:00:01.000Z","ResponsiblePartner":{"number_x":"98000392","name":"Serviceuser authentSalesforce"},"Responsible_CustomerProposal":{"text":null,"stc_mdeUser":"","guid":"1664A000-42B4-1030-9C-AB-00002750A8C0"},"responsible":"1664A000-42B4-1030-9C-AB-00002750A8C0","Rai_ResponsibleEmployee_CustomerProposal":{"number_x":"98000123","name":"Jürgen Blum"},"rai_responsibleEmployee":"1F8A2000-CF43-1024-A5-CC-0000225FA8C0","Rai_Opportunity":{"type_x":"41790000-BAA9-1024-83-93-0000225FA8C0","number_x":"VS00000127","guid":"D83D6004-9D91-1030-94-20-0000100A0A0A","description":"Test Schnitti, Berlin"},"rai_objectName":"","rai_infoText":"","PriceListing":null,"number_x":"VG00083775","invoicingData":{"PaymentTerms":{"description":"14 Tage - 2,00 % Skonto, 30 Tage netto","code":"103"}},"guid":"CB08A009-9E4E-1030-94-20-0000100A0A0A","DocumentDiscounts":[{"value":{"amount":"123"},"type_x":"HEADER_DISCOUNT","discounts":{"value":"0","index_att_info":["index"],"index":3,"DiscountType":null}},{"value":{"amount":"0"},"type_x":"ORDER_VALUE_DISCOUNT","discounts":{"value":"0","index_att_info":["index"],"index":3,"DiscountType":null}}],"discounts":[{"value":"0","index_att_info":["index"],"index":0},{"value":"0","index_att_info":["index"],"index":1},{"value":"0","index_att_info":["index"],"index":2},{"value":"0","index_att_info":["index"],"index":3}],"Details":[{"totalValues":{"grossValue":{"amount":"haha"}},"totalQuantity":{"Uom":{"description":"Stück","code":"Stk"},"amount":"1"},"totalQuantities":null,"TextAssignments":[{"text":null}],"subNumber":0,"SubDetails":null,"rai_positionType":"STANDARD","preferredDate":{"value":"08#12#2022"},"number_x":10,"netPrice":{"Currency_x":{"isoCode":"EUR"},"amount":"1230000000000000000000000000000000000000000000000000000000000000000000000000000000"},"Item":{"number_x":"123","guid":"F96DC002-2C37-1029-87-D1-0000225FA8C4","description":"Wandplaner groß"},"guid":"59124003-9E4F-1030-94-20-0000100A0A0A","grossPrice":{"amount":"123"},"detailType":"NORMAL","deliveryDate":"2022-12-07T23:00:00.000Z"}],"date_x":"2022-12-07T23:00:00.000Z","customerData":{"name":"Vision 11 Metallbau","CustomerPartner":{"number_x":"20000007"},"customer":"40F38007-93D1-1030-94-20-0000100A0A0A","CareOfPartner":null,"careOfName":"","careOf":null},"Classification3":null,"Classification2":null,"Classification1":{"description":"HOLZ"}}', V11_QuoteExportData.CustomerProposal.class);
        List<V11_QuoteExportData.CustomerProposal> quotes2 = new List<V11_QuoteExportData.CustomerProposal>();
        quotes2.add(quote2);
        V11_batchQuoteUpsert batch2 = new V11_batchQuoteUpsert(quotes2);
        Database.executeBatch(batch2);

        V11_QuoteExportData.CustomerProposal quote3 = (V11_QuoteExportData.CustomerProposal) System.JSON.deserialize('{"Type_x_CustomerProposal":{"description":"Logikal Kalkulation","code":"200"},"type_x":"C0AA8001-A60F-1024-98-94-0000225FA8C0","totalValues":{"netValueDomestic":{"Currency1":{"isoCode":"EUR"},"amount1":"0"},"netValue":{"Currency_x":{"isoCode":"EUR"},"amount":"0"},"grossWeight":{"Uom":{"description":"Kilogramm","code":"kg"},"amount":"0.1"},"grossValueDomestic":{"Currency1":{"isoCode":"EUR"},"amount1":"123"},"grossValue":{"Currency_x":{"isoCode":"EUR"},"amount":"123"}},"status":"ORDER_ENTERED","SalesRepresentative_CustomerProposal":{"number_x":"98000200","name":"Thomas Peter"},"salesRepresentative":"C5AD2000-3727-1027-96-3D-0000225FA8C1","reviewDate":"2022-12-14T23:00:00.000Z","ResponsiblePartner":{"number_x":"98000392","name":"Serviceuser authentSalesforce"},"Responsible_CustomerProposal":{"text":null,"stc_mdeUser":"","guid":"1664A000-42B4-1030-9C-AB-00002750A8C0"},"responsible":"1664A000-42B4-1030-9C-AB-00002750A8C0","Rai_ResponsibleEmployee_CustomerProposal":{"number_x":"98000123","name":"Jürgen Blum"},"rai_responsibleEmployee":"1F8A2000-CF43-1024-A5-CC-0000225FA8C0","Rai_Opportunity":{"type_x":"41790000-BAA9-1024-83-93-0000225FA8C0","number_x":"VS00000127","guid":"D83D6004-9D91-1030-94-20-0000100A0A0A","description":"Test Schnitti, Berlin"},"rai_objectName":"","rai_infoText":"","PriceListing":null,"number_x":"VG00083775","invoicingData":{"PaymentTerms":{"description":"14 Tage - 2,00 % Skonto, 30 Tage netto","code":"103"}},"guid":"CB08A009-9E4E-1030-94-20-0000100A0A0A","DocumentDiscounts":[{"value":{"amount":"123"},"type_x":"HEADER_DISCOUNT","discounts":{"value":"234","index_att_info":["index"],"index":3,"DiscountType":{"code":"299"}}},{"value":{"amount":"0"},"type_x":"ORDER_VALUE_DISCOUNT","discounts":{"value":"0","index_att_info":["index"],"index":3,"DiscountType":null}}],"discounts":[{"value":"123","index_att_info":["index"],"index":0},{"value":"123","index_att_info":["index"],"index":1},{"value":"324","index_att_info":["index"],"index":2},{"value":"234","index_att_info":["index"],"index":3}],"Details":[{"totalValues":{"grossValue":{"amount":"123000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"}},"totalQuantity":{"Uom":{"description":"Stück","code":"Stk"},"amount":"1"},"totalQuantities":null,"TextAssignments":[{"text":null}],"subNumber":0,"SubDetails":null,"rai_positionType":"STANDARD","preferredDate":{"value":"08#12#2022"},"number_x":10,"netPrice":{"Currency_x":{"isoCode":"EUR"},"amount":"0"},"Item":{"number_x":"001057","guid":"F96DC002-2C37-1029-87-D1-0000225FA8C4","description":"Wandplaner groß"},"guid":"59124003-9E4F-1030-94-20-0000100A0A0A","grossPrice":{"amount":"123"},"detailType":"NORMAL","deliveryDate":"2022-12-07T23:00:00.000Z"}],"date_x":"2022-12-07T23:00:00.000Z","customerData":{"name":"Vision 11 Metallbau","CustomerPartner":{"number_x":"20000007"},"customer":"40F38007-93D1-1030-94-20-0000100A0A0A","CareOfPartner":{"number_x":"40000001"},"careOfName":"Gut Morgen","careOf":"67760001-93F1-1030-94-20-0000100A0A0A"},"Classification3":{"path":"100-103","description":"50%","code":"103"},"Classification2":{"code":"100"},"Classification1":{"description":"HOLZ"}}', V11_QuoteExportData.CustomerProposal.class);
        List<V11_QuoteExportData.CustomerProposal> quotes3 = new List<V11_QuoteExportData.CustomerProposal>();
        quotes3.add(quote3);
        V11_batchQuoteUpsert batch3 = new V11_batchQuoteUpsert(quotes3);
        Database.executeBatch(batch3);

        V11_QuoteExportData.CustomerProposal quote4 = (V11_QuoteExportData.CustomerProposal) System.JSON.deserialize('{"Type_x_CustomerProposal":{"description":"Logikal Kalkulation","code":"100"},"type_x":"C0AA8001-A60F-1024-98-94-0000225FA8C0","totalValues":{"netValueDomestic":{"Currency1":{"isoCode":"EUR"},"amount1":"0"},"netValue":{"Currency_x":{"isoCode":"EUR"},"amount":"0"},"grossWeight":{"Uom":{"description":"Kilogramm","code":"kg"},"amount":"0"},"grossValueDomestic":{"Currency1":{"isoCode":"EUR"},"amount1":"0"},"grossValue":{"Currency_x":{"isoCode":"EUR"},"amount":"0"}},"status":"ORDER_ENTERED","SalesRepresentative_CustomerProposal":{"number_x":"98000200","name":"Thomas Peter"},"salesRepresentative":"C5AD2000-3727-1027-96-3D-0000225FA8C1","reviewDate":"0001-12-29T23:00:01.000Z","ResponsiblePartner":{"number_x":"98000392","name":"Serviceuser authentSalesforce"},"Responsible_CustomerProposal":{"text":null,"stc_mdeUser":"","guid":"1664A000-42B4-1030-9C-AB-00002750A8C0"},"responsible":"1664A000-42B4-1030-9C-AB-00002750A8C0","Rai_ResponsibleEmployee_CustomerProposal":{"number_x":"98000123","name":"Jürgen Blum"},"rai_responsibleEmployee":"1F8A2000-CF43-1024-A5-CC-0000225FA8C0","Rai_Opportunity":{"type_x":"41790000-BAA9-1024-83-93-0000225FA8C0","number_x":"VS00000128","guid":"D83D6004-9D91-1030-94-20-0000100A0A0A","description":"Test Schnitti, Berlin"},"rai_objectName":"","rai_infoText":"","PriceListing":null,"number_x":"VG00083775","invoicingData":{"PaymentTerms":{"description":"14 Tage - 2,00 % Skonto, 30 Tage netto","code":"103"}},"guid":"CB08A009-9E4E-1030-94-20-0000100A0A0A","DocumentDiscounts":null,"discounts":[{"value":"0","index_att_info":["index"],"index":0},{"value":"0","index_att_info":["index"],"index":1},{"value":"0","index_att_info":["index"],"index":2},{"value":"0","index_att_info":["index"],"index":3}],"Details":null,"date_x":"2022-12-07T23:00:00.000Z","customerData":{"name":"Vision 11 Metallbau","CustomerPartner":{"number_x":"20000007"},"customer":"40F38007-93D1-1030-94-20-0000100A0A0A","CareOfPartner":null,"careOfName":"","careOf":null},"Classification3":null,"Classification2":null,"Classification1":{"description":"HOLZ"}}', V11_QuoteExportData.CustomerProposal.class);
        List<V11_QuoteExportData.CustomerProposal> quotes4 = new List<V11_QuoteExportData.CustomerProposal>();
        quotes4.add(quote4);
        V11_batchQuoteUpsert batch4 = new V11_batchQuoteUpsert(quotes4);
        Database.executeBatch(batch4);

        Database.executeBatch(batch4);

        V11_QuoteExportData.CustomerProposal quote5 = (V11_QuoteExportData.CustomerProposal) System.JSON.deserialize('{"Type_x_CustomerProposal":{"description":"Standard Angebot","code":"100"},"type_x":"A2366000-A60F-1024-98-94-0000225FA8C0","totalValues":{"netValueDomestic":{"Currency1":{"isoCode":"EUR"},"amount1":"0"},"netValue":{"Currency_x":{"isoCode":"EUR"},"amount":"0"},"grossWeight":{"Uom":{"description":"Kilogramm","code":"kg"},"amount":"0"},"grossValueDomestic":{"Currency1":{"isoCode":"EUR"},"amount1":"0"},"grossValue":{"Currency_x":{"isoCode":"EUR"},"amount":"0"}},"status":"ORDER_ENTERED","SalesRepresentative_CustomerProposal":{"number_x":"98000200","name":"Thomas Peter"},"salesRepresentative":"C5AD2000-3727-1027-96-3D-0000225FA8C1","reviewDate":"0001-12-29T23:00:01.000Z","ResponsiblePartner":{"number_x":"98000392","name":"Serviceuser authentSalesforce"},"Responsible_CustomerProposal":{"text":null,"stc_mdeUser":"","guid":"1664A000-42B4-1030-9C-AB-00002750A8C0"},"responsible":"1664A000-42B4-1030-9C-AB-00002750A8C0","Rai_ResponsibleEmployee_CustomerProposal":{"number_x":"98000123","name":"Jürgen Blum"},"rai_responsibleEmployee":"1F8A2000-CF43-1024-A5-CC-0000225FA8C0","Rai_Opportunity":null,"rai_objectName":"","rai_infoText":"","PriceListing":{"description":"Goldbeck Standard Preislistung","code":"100.GOLD"},"number_x":"VG00083770","invoicingData":{"PaymentTerms":{"description":"10 Tage - 3,00 % Skonto, 30 Tage netto","code":"108"}},"guid":"B2EE2002-9C3E-1030-94-20-0000100A0A0A","DocumentDiscounts":null,"discounts":[{"value":"0","index_att_info":["index"],"index":0},{"value":"0","index_att_info":["index"],"index":1},{"value":"0","index_att_info":["index"],"index":2},{"value":"0","index_att_info":["index"],"index":3}],"Details":null,"date_x":"2022-12-04T23:00:00.000Z","customerData":{"name":"Vision 11 Metallbau","CustomerPartner":{"number_x":"20000007"},"customer":"40F38007-93D1-1030-94-20-0000100A0A0A","CareOfPartner":null,"careOfName":"","careOf":null},"Classification3":null,"Classification2":null,"Classification1":{"description":"HOLZ"}}', V11_QuoteExportData.CustomerProposal.class);
        List<V11_QuoteExportData.CustomerProposal> quotes5 = new List<V11_QuoteExportData.CustomerProposal>();
        quotes5.add(quote5);
        V11_batchQuoteUpsert batch5 = new V11_batchQuoteUpsert(quotes5);
        Database.executeBatch(batch5);

        Database.executeBatch(batch5);





        Test.stopTest();
    }
    @isTest static void coverGeneratedCodeTypesQuote() {
		Test.setMock(WebServiceMock.class, new V11_WebServiceMockInbound());
		V11_QuoteExport parentObject = new V11_QuoteExport();
		new V11_QuoteCommon.Message();
		new V11_QuoteCommon.MessageQueue();
		new V11_QuoteCommon.ParameterList();
		new V11_QuoteCommon.ParameterListEntry();
		new V11_QuoteExport.export_x_element();
		new V11_QuoteExport.ExportRequest();
		new V11_QuoteExport.ExportResponse();
		new V11_QuoteExport.exportResponse_element();
		new V11_QuoteExport.ExportResult();
		new V11_QuoteExportData.CustomerProposal();
		new V11_QuoteExportData.CustomerProposal_Classification1();
		new V11_QuoteExportData.CustomerProposal_Classification2();
		new V11_QuoteExportData.CustomerProposal_Classification3();
		new V11_QuoteExportData.CustomerProposal_customerData();
		new V11_QuoteExportData.CustomerProposal_customerData_CareOfPartner();
		new V11_QuoteExportData.CustomerProposal_customerData_CustomerPartner();
		new V11_QuoteExportData.CustomerProposal_Details();
		new V11_QuoteExportData.CustomerProposal_Details_grossPrice();
		new V11_QuoteExportData.CustomerProposal_Details_Item();
		new V11_QuoteExportData.CustomerProposal_Details_netPrice();
		new V11_QuoteExportData.CustomerProposal_Details_netPrice_Currency();
		new V11_QuoteExportData.CustomerProposal_Details_preferredDate();
		new V11_QuoteExportData.CustomerProposal_Details_SubDetails();
		new V11_QuoteExportData.CustomerProposal_Details_SubDetails_totalValues();
		new V11_QuoteExportData.CustomerProposal_Details_SubDetails_totalValues_netValue();
		new V11_QuoteExportData.CustomerProposal_Details_SubDetails_totalValues_netValue_Currency();
		new V11_QuoteExportData.CustomerProposal_Details_SubDetails_totalValues_netValueDomestic();
		new V11_QuoteExportData.CustomerProposal_Details_SubDetails_totalValues_netValueDomestic_Currency1();
		new V11_QuoteExportData.CustomerProposal_Details_TextAssignments();
		new V11_QuoteExportData.CustomerProposal_Details_TextAssignments_text();
		new V11_QuoteExportData.CustomerProposal_Details_totalQuantities();
		new V11_QuoteExportData.CustomerProposal_Details_totalQuantities_Uom();
		new V11_QuoteExportData.CustomerProposal_Details_totalQuantity();
		new V11_QuoteExportData.CustomerProposal_Details_totalQuantity_Uom();
		new V11_QuoteExportData.CustomerProposal_Details_totalValues();
		new V11_QuoteExportData.CustomerProposal_Details_totalValues_grossValue();
		new V11_QuoteExportData.CustomerProposal_discounts();
		new V11_QuoteExportData.CustomerProposal_DocumentDiscounts();
		new V11_QuoteExportData.CustomerProposal_DocumentDiscounts_discounts();
		new V11_QuoteExportData.CustomerProposal_DocumentDiscounts_discounts_DiscountType();
		new V11_QuoteExportData.CustomerProposal_DocumentDiscounts_value();
		new V11_QuoteExportData.CustomerProposal_invoicingData();
		new V11_QuoteExportData.CustomerProposal_invoicingData_PaymentTerms();
		new V11_QuoteExportData.CustomerProposal_PriceListing();
		new V11_QuoteExportData.CustomerProposal_Rai_Opportunity();
		new V11_QuoteExportData.CustomerProposal_Rai_ResponsibleEmployee();
		new V11_QuoteExportData.CustomerProposal_Responsible();
		new V11_QuoteExportData.CustomerProposal_ResponsiblePartner();
		new V11_QuoteExportData.CustomerProposal_SalesRepresentative();
		new V11_QuoteExportData.CustomerProposal_totalValues();
		new V11_QuoteExportData.CustomerProposal_totalValues_grossValue();
		new V11_QuoteExportData.CustomerProposal_totalValues_grossValue_Currency();
		new V11_QuoteExportData.CustomerProposal_totalValues_grossValueDomestic();
		new V11_QuoteExportData.CustomerProposal_totalValues_grossValueDomestic_Currency1();
		new V11_QuoteExportData.CustomerProposal_totalValues_grossWeight();
		new V11_QuoteExportData.CustomerProposal_totalValues_grossWeight_Uom();
		new V11_QuoteExportData.CustomerProposal_totalValues_netValue();
		new V11_QuoteExportData.CustomerProposal_totalValues_netValue_Currency();
		new V11_QuoteExportData.CustomerProposal_totalValues_netValueDomestic();
		new V11_QuoteExportData.CustomerProposal_totalValues_netValueDomestic_Currency1();
		new V11_QuoteExportData.CustomerProposal_Type();
		new V11_QuoteExportData.x_EntityWrapper();
	}

    @isTest static void coverGeneratedCodeTypesEntity() {
		Test.setMock(WebServiceMock.class, new V11_WebServiceMockInbound());
		V11_EntityExtensionExport parentObject = new V11_EntityExtensionExport();
		new V11_EntityExtensionCommon.Message();
		new V11_EntityExtensionCommon.MessageQueue();
		new V11_EntityExtensionCommon.ParameterList();
		new V11_EntityExtensionCommon.ParameterListEntry();
		new V11_EntityExtensionExport.export_x_element();
		new V11_EntityExtensionExport.ExportRequest();
		new V11_EntityExtensionExport.ExportResponse();
		new V11_EntityExtensionExport.exportResponse_element();
		new V11_EntityExtensionExport.ExportResult();
		new V11_EntityExtensionExportData.EntityExtensionHierarchy();
		new V11_EntityExtensionExportData.EntityExtensionHierarchy_description();
		new V11_EntityExtensionExportData.EntityExtensionHierarchy_description_text();
		new V11_EntityExtensionExportData.EntityExtensionHierarchy_updateInfo();
		new V11_EntityExtensionExportData.x_EntityWrapper();
	}

    @isTest static void coverGeneratedCodeTypesPartner() {
		Test.setMock(WebServiceMock.class, new V11_WebServiceMockInbound());
		V11_PartnerExport parentObject = new V11_PartnerExport();
		new V11_PartnerCommon.Message();
		new V11_PartnerCommon.MessageQueue();
		new V11_PartnerCommon.ParameterList();
		new V11_PartnerCommon.ParameterListEntry();
		new V11_PartnerExport.export_x_element();
		new V11_PartnerExport.ExportRequest();
		new V11_PartnerExport.ExportResponse();
		new V11_PartnerExport.exportResponse_element();
		new V11_PartnerExport.ExportResult();
		new V11_PartnerExportData.Partner();
		new V11_PartnerExportData.Partner_addressData();
		new V11_PartnerExportData.Partner_addressData_Country();
		new V11_PartnerExportData.Partner_CommunicationData();
		new V11_PartnerExportData.Partner_CommunicationData_Method();
		new V11_PartnerExportData.Partner_Customer();
		new V11_PartnerExportData.Partner_Customer_deliveryDataInfo();
		new V11_PartnerExportData.Partner_Customer_deliveryDataInfo_DeliveryTerms();
		new V11_PartnerExportData.Partner_Employee();
		new V11_PartnerExportData.Partner_Employee_JobCategory();
		new V11_PartnerExportData.Partner_Employee_PartnerRelations();
		new V11_PartnerExportData.Partner_Employee_PartnerRelations_SourceOrganizationalUnit();
		new V11_PartnerExportData.Partner_Employee_PartnerRelations_Target();
		new V11_PartnerExportData.Partner_Employee_PartnerRelations_Type();
		new V11_PartnerExportData.Partner_EntityExtension();
		new V11_PartnerExportData.Partner_EntityExtension_SALESFORCEID();
		new V11_PartnerExportData.Partner_EntityExtension_SPERRGRUND();
		new V11_PartnerExportData.Partner_Language();
		new V11_PartnerExportData.Partner_MaintainingOrganization();
		new V11_PartnerExportData.Partner_organizationalUnit();
		new V11_PartnerExportData.Partner_organizationalUnit_name();
		new V11_PartnerExportData.Partner_OrganizationalUnitPartner();
		new V11_PartnerExportData.Partner_OrganizationalUnitPartner_OrganizationalUnit();
		new V11_PartnerExportData.Partner_PartnerAccountingData();
		new V11_PartnerExportData.Partner_PartnerAccountingData_creditLimit();
		new V11_PartnerExportData.Partner_PartnerAccountingData_creditLimit_Currency();
		new V11_PartnerExportData.Partner_PartnerAccountingData_CustomerOutstandingDebt();
		new V11_PartnerExportData.Partner_PartnerAccountingData_CustomerOutstandingDebt_transferredUnpaidValue();
		new V11_PartnerExportData.Partner_PartnerAccountingData_SalesPaymentTerms();
		new V11_PartnerExportData.Partner_PartnerAccountingData_SalesPaymentTerms_OrganizationalUnit();
		new V11_PartnerExportData.Partner_PartnerRelations();
		new V11_PartnerExportData.Partner_PartnerRelations_Target();
		new V11_PartnerExportData.Partner_PartnerRelations_Target_organizationalUnit();
		new V11_PartnerExportData.Partner_PartnerRelations_Type();
		new V11_PartnerExportData.Partner_person();
		new V11_PartnerExportData.Partner_person_Salutation();
		new V11_PartnerExportData.Partner_person_Title();
		new V11_PartnerExportData.Partner_updateInfo();
		new V11_PartnerExportData.x_EntityWrapper();
	}

    @isTest static void coverGeneratedCodeTypesProduct() {
		Test.setMock(WebServiceMock.class, new V11_WebServiceMockInbound());
		V11_ProductExport parentObject = new V11_ProductExport();
		new V11_ProductCommon.Message();
		new V11_ProductCommon.MessageQueue();
		new V11_ProductCommon.ParameterList();
		new V11_ProductCommon.ParameterListEntry();
		new V11_ProductExport.export_element();
		new V11_ProductExport.ExportRequest();
		new V11_ProductExport.ExportResponse();
		new V11_ProductExport.exportResponse_element();
		new V11_ProductExport.ExportResult();
		new V11_ProductExportData.Item();
		new V11_ProductExportData.Item_description();
		new V11_ProductExportData.Item_description_text();
		new V11_ProductExportData.Item_EntityExtension();
		new V11_ProductExportData.Item_EntityExtension_ARTIKELGRUPP();
		new V11_ProductExportData.Item_EntityExtension_LANGEMAXIMAL();
		new V11_ProductExportData.Item_EntityExtension_OBERFLAECHE_FARBE();
		new V11_ProductExportData.Item_EntityExtension_PRODUKTGRUPPE();
		new V11_ProductExportData.Item_EntityExtension_WARENGRUPPE();
		new V11_ProductExportData.Item_EntityExtension_WERKSTOFF_NEU();
		new V11_ProductExportData.Item_ItemPackagingUoms();
		new V11_ProductExportData.Item_ItemPackagingUoms_StorageUnit();
		new V11_ProductExportData.Item_longDescription();
		new V11_ProductExportData.Item_longDescription_text();
		new V11_ProductExportData.Item_measurements();
		new V11_ProductExportData.Item_measurements_netWeight();
		new V11_ProductExportData.Item_Stc_Material();
		new V11_ProductExportData.Item_Stc_Material_description();
		new V11_ProductExportData.Item_Stc_Material_description_text();
		new V11_ProductExportData.Item_Uoms();
		new V11_ProductExportData.Item_Uoms_description();
		new V11_ProductExportData.Item_Uoms_description_text();
		new V11_ProductExportData.x_EntityWrapper();
	}

    @isTest static void coverGeneratedCodeTypesOrder() {
		Test.setMock(WebServiceMock.class, new V11_WebServiceMockInbound());
		V11_OrderExport parentObject = new V11_OrderExport();
		new V11_OrderCommon.Message();
		new V11_OrderCommon.MessageQueue();
		new V11_OrderCommon.ParameterList();
		new V11_OrderCommon.ParameterListEntry();
		new V11_OrderExport.export_x_element();
		new V11_OrderExport.ExportRequest();
		new V11_OrderExport.ExportResponse();
		new V11_OrderExport.exportResponse_element();
		new V11_OrderExport.ExportResult();
		new V11_OrderExportData.SalesOrder();
		new V11_OrderExportData.SalesOrder_Type();
		new V11_OrderExportData.SalesOrder_Classification1();
		new V11_OrderExportData.SalesOrder_costOfGoods();
		new V11_OrderExportData.SalesOrder_costOfGoods_Currency1();
		new V11_OrderExportData.SalesOrder_customerData();
		new V11_OrderExportData.SalesOrder_customerData_CareOfPartner();
		new V11_OrderExportData.SalesOrder_customerData_CustomerPartner();
		new V11_OrderExportData.SalesOrder_CustomerProposal();
		new V11_OrderExportData.SalesOrder_deliveryCustomerData();
		new V11_OrderExportData.SalesOrder_deliveryCustomerData_addressData();
		new V11_OrderExportData.SalesOrder_deliveryCustomerData_addressData_Country();
		new V11_OrderExportData.SalesOrder_deliveryCustomerData_CustomerPartner();
		new V11_OrderExportData.SalesOrder_deliveryData();
		new V11_OrderExportData.SalesOrder_deliveryData_DeliveryTerms();
		new V11_OrderExportData.SalesOrder_deliveryData_ShippingTerms();
		new V11_OrderExportData.SalesOrder_Details();
		new V11_OrderExportData.SalesOrder_Details_costOfGoods();
		new V11_OrderExportData.SalesOrder_Details_CustomerProposal();
		new V11_OrderExportData.SalesOrder_Details_deliveryCustomerData();
		new V11_OrderExportData.SalesOrder_Details_deliveryCustomerData_addressData();
		new V11_OrderExportData.SalesOrder_Details_deliveryCustomerData_addressData_Country();
		new V11_OrderExportData.SalesOrder_Details_deliveryData();
		new V11_OrderExportData.SalesOrder_Details_deliveryData_DeliveryTerms();
		new V11_OrderExportData.SalesOrder_Details_deliveryData_ShippingTerms();
		new V11_OrderExportData.SalesOrder_Details_discounts();
		new V11_OrderExportData.SalesOrder_Details_discounts_DiscountType();
		new V11_OrderExportData.SalesOrder_Details_grossPrice();
		new V11_OrderExportData.SalesOrder_Details_Item();
		new V11_OrderExportData.SalesOrder_Details_netPrice();
		new V11_OrderExportData.SalesOrder_Details_netPrice_Currency();
		new V11_OrderExportData.SalesOrder_Details_netPriceDomestic();
		new V11_OrderExportData.SalesOrder_Details_netPriceDomestic_Currency1();
		new V11_OrderExportData.SalesOrder_Details_retailNetValue();
		new V11_OrderExportData.SalesOrder_Details_retailNetValue_Currency();
		new V11_OrderExportData.SalesOrder_Details_retailNetValueDomestic();
		new V11_OrderExportData.SalesOrder_Details_retailNetValueDomestic_Currency1();
		new V11_OrderExportData.SalesOrder_Details_totalQuantities();
		new V11_OrderExportData.SalesOrder_Details_totalQuantities_Uom();
		new V11_OrderExportData.SalesOrder_Details_totalQuantity();
		new V11_OrderExportData.SalesOrder_Details_totalQuantity_Uom();
		new V11_OrderExportData.SalesOrder_Details_totalValues();
		new V11_OrderExportData.SalesOrder_Details_totalValues_grossValue();
		new V11_OrderExportData.SalesOrder_discounts();
		new V11_OrderExportData.SalesOrder_DocumentDiscounts();
		new V11_OrderExportData.SalesOrder_DocumentDiscounts_CustomerProposal();
		new V11_OrderExportData.SalesOrder_DocumentDiscounts_CustomerProposal_costOfGoods();
		new V11_OrderExportData.SalesOrder_DocumentDiscounts_CustomerProposal_costOfGoods_Currency1();
		new V11_OrderExportData.SalesOrder_invoicingData();
		new V11_OrderExportData.SalesOrder_invoicingData_PaymentTerms();
		new V11_OrderExportData.SalesOrder_PriceListing();
		new V11_OrderExportData.SalesOrder_Rai_Opportunity();
		new V11_OrderExportData.SalesOrder_Rai_ResponsibleEmployee();
		new V11_OrderExportData.SalesOrder_ResponsiblePartner();
		new V11_OrderExportData.SalesOrder_SalesRepresentatives();
		new V11_OrderExportData.SalesOrder_totalValues();
		new V11_OrderExportData.SalesOrder_totalValues_grossValue();
		new V11_OrderExportData.SalesOrder_totalValues_grossValue_Currency();
		new V11_OrderExportData.SalesOrder_totalValues_grossValueDomestic();
		new V11_OrderExportData.SalesOrder_totalValues_grossValueDomestic_Currency1();
		new V11_OrderExportData.SalesOrder_totalValues_grossWeight();
		new V11_OrderExportData.SalesOrder_totalValues_grossWeight_Uom();
		new V11_OrderExportData.SalesOrder_totalValues_netValue();
		new V11_OrderExportData.SalesOrder_totalValues_netValue_Currency();
		new V11_OrderExportData.SalesOrder_totalValues_netValueDomestic();
		new V11_OrderExportData.SalesOrder_totalValues_netValueDomestic_Currency1();
		new V11_OrderExportData.SalesOrder_totalValues_netWeight();
		new V11_OrderExportData.SalesOrder_totalValues_netWeight_Uom();
		new V11_OrderExportData.x_EntityWrapper();
	}

}